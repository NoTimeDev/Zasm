const std = @import("std");
const ArrayList = std.ArrayList;
const Instructions = @import("instructions.zig");

pub const AsmError = @import("errors.zig").AsmError;
pub const Emitter = @import("emitter/emitter.zig");
pub const Register = @import("emitter/register.zig").Register;
pub const Memory = Emitter.Memory;
pub const Jcc = Instructions.Jcc;
pub const Setcc = Instructions.Setcc;


/// Patch Kind 
/// Label is used for jmps, e.g `jmp .cond`
/// AbsLabel is used when you want to write the address of .cond 
/// into a register e.g `mov rax, .cond`
const Patch = union(enum){
    label: struct {
        pos: usize,
        label_id: usize
    },
    abs_label: struct {
        pos: usize,
        label_id: usize
    }
};

/// Operands 
pub const Operand = union(enum){
    Register: Register,
    Immediate: i64,
    Memory: Memory,
    // label id!
    Offset: usize,
};



/// A Function struct which hold the excutable code
pub const Function = struct{
    code: []u8,
    len: usize,

    /// Returns a func pointer to the allocated memory
    pub fn asptr(self: *const Function, comptime funcptr: type) funcptr{
        return @ptrCast(self.code.ptr);
    }

    /// Creates a new Function code should be executable memory  
    fn init(code: []u8, len: usize) Function{
        return Function{
            .code = code,
            .len = len 
        };
    }

    /// Pretty obv, returns the allocated memory back to the system  
    pub fn deinit(self: *const Function) void {
        std.posix.munmap(@alignCast(self.code));
    }

    /// This writes the bytes into a file used with a tool like objdump 
    /// to see the human readable representation
    pub fn write_bytes(self: *const Function, filename: []const u8, allocator: std.mem.Allocator) !void{
        var threaded: std.Io.Threaded = .init(allocator, .{});
        defer threaded.deinit();
        const io = threaded.io();
        {
            const cwd = std.Io.Dir.cwd();
            var file = try cwd.createFile(io, filename, .{});
            defer file.close(io);
            try file.writeStreamingAll(io, self.code[0..self.len]);
        }
    }

};


/// An x86_64 assembler
/// This is a wrapper over the x86_64 emitter
/// To make writing code simpler
pub const Assembler = struct {
    allocator: std.mem.Allocator,
    emitter:  Emitter.Emitter,
    patches: ArrayList(Patch),
    labels: std.AutoHashMap(usize, usize),
    lab_id: usize = 0,

    /// Creates a new Assembler
    pub fn init(allocator: std.mem.Allocator) Assembler{
        return .{
            .allocator = allocator,
            .emitter = .init(allocator),
            .patches = .empty,
            .labels = .init(allocator),
        };
    }

    /// Creates a function from the bytes in the emitter struct
    fn createfunc(self: *Assembler) !Function{
        const size = std.mem.alignForward(usize, self.emitter.bytes.items.len, std.heap.pageSize());
        var ptr = try std.posix.mmap(
            null, 
            size, 
            .{.READ = true, .WRITE = true},
            .{.ANONYMOUS = true, .TYPE = .PRIVATE}, 
            -1, 
            0
        );
        @memcpy(ptr[0..self.emitter.bytes.items.len], self.emitter.bytes.items);
        for(self.patches.items)|patch|{
            switch(patch){
                .label => |label|{
                    const call_offset = &ptr[label.pos];
                    const abs: usize = @intCast(@intFromPtr(&ptr[self.labels.get(label.label_id).?]));
                    const offset: i64 = @as(i64, @intCast(abs)) - @as(i64, @intCast(@intFromPtr(call_offset) + 5));
                    if(std.math.cast(i32, offset))|posoff|{
                        for(std.mem.asBytes(&posoff), 0..)|byte, i|{
                            ptr[patch.label.pos+i+1] = byte;
                        }
                    }else{
                        return AsmError.RelOutOfRange;
                    }    
                },
                .abs_label => |label|{
                    const abs: usize = @intCast(@intFromPtr(&ptr[self.labels.get(label.label_id).?]));
                    for(std.mem.asBytes(&abs), 0..)|byte, i|{
                        ptr[label.pos+i] = byte;
                    }
                }
            }
        }
        if(std.os.linux.mprotect(ptr.ptr, size, .{.READ = true, .EXEC = true}) != 0){
            return AsmError.MprotectFailed;
        }
        const len = self.emitter.bytes.items.len; 
        return Function.init(ptr, len);
    }

    /// Returns a Function, this clears the current bytes and binded labels 
    pub fn takefunc(self: *Assembler) !Function{
        if(self.emitter.bytes.items.len == 0){
            try self.emitter.bytes.append(self.allocator, 0xc3);
        }
        const func = try self.createfunc();
        self.emitter.bytes.clearRetainingCapacity();
        self.patches.clearRetainingCapacity();
        self.lab_id = 0;
        self.labels.clearRetainingCapacity();
        return func; 
    }

    /// Frees the data structures used by the Assembler
    pub fn deinit(self: *Assembler) void{
        self.emitter.deinit();
        self.labels.deinit();
        self.patches.deinit(self.allocator);
    }

    /// Creates a new label and returns the id 
    /// You will not be able to jump to this unless you call `.bind()`
    pub fn new_label(self: *Assembler) usize{
        self.lab_id+=1;
        return self.lab_id-1;
    }
    
   
    /// Converts the Assembler operands to the Emitter operands
    fn from(operands :[]const Operand, eoperands: []Emitter.Operand) void {
        for(operands, 0..operands.len)|op, indx|{
            switch (op){
                .Immediate => |imm|{
                    eoperands[indx] = .{.Immediate = imm}; 
                },
                .Memory => |mem|{
                    eoperands[indx] = .{.Memory = mem}; 
                },
                .Register => |reg|{
                    eoperands[indx] = .{.Register = reg}; 
                },
                .Offset => {
                    eoperands[indx] = .{.Immediate = 0}; 
                },
            }
        }
    }

    /// Takes in a label id and binds it to the current position
    pub fn bind(self: *Assembler, label: usize) !void{
        try self.labels.put(label, self.emitter.bytes.items.len);
    }

    /// Jumps to a position via register or label id 
    pub fn jmp(self: *Assembler, src: Operand) !void{
        var ops: [1]Emitter.Operand = undefined;
        if(src == .Offset){
            try self.patches.append(self.allocator, .{ .label = .{ 
                .label_id = src.Offset,
                .pos = self.emitter.bytes.items.len
            }});
            Assembler.from(
                &[_]Operand{
                    .{. Immediate = 0},
                },
                &ops,
            );
        }else {
            Assembler.from(
                &[_]Operand{
                    src
                },
                &ops,
            );
        }
        try self.emitter.emit(Instructions.jmp, &ops);  
    }

    /// Calls a block of code via register or label id 
    pub fn call(self: *Assembler, src: Operand) !void{
        var ops: [1]Emitter.Operand = undefined;
        if(src == .Offset){
            try self.patches.append(self.allocator, .{ .label = .{ 
                .label_id = src.Offset,
                .pos = self.emitter.bytes.items.len
            }});
            Assembler.from(
                &[_]Operand{
                    .{. Immediate = 0},
                },
                &ops,
            );
        }else {
            Assembler.from(
                &[_]Operand{
                    src
                },
                &ops,
            );
        }
        try self.emitter.emit(Instructions.call, &ops);
        
    }

    /// Moves a value into a register or into memory
    pub fn mov(self: *Assembler, dest: Operand, src: Operand) !void{
        if(dest == .Immediate){return AsmError.SizeMisMatch;}
        var nsrc: Operand = src;
        if(src == .Offset){
            nsrc = .{ .Immediate = 0 };
        }
        var ops: [2]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                dest,
                nsrc
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.mov, &ops);
        if(src == .Offset){
            try self.patches.append(self.allocator, .{ .abs_label = .{ 
                .label_id = src.Offset,
                .pos = self.emitter.bytes.items.len-8
            }});
        }
    }

    /// Adds a two values and stores it in dest 
    pub fn add(self: *Assembler, dest: Operand, src: Operand) !void{
        if(dest == .Immediate){return AsmError.SizeMisMatch;}
        var ops: [2]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                dest,
                src
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.add, &ops);
    }
    
    /// Compares two operands
    pub fn cmp(self: *Assembler, dest: Operand, src: Operand) !void{
        if(dest == .Immediate){return AsmError.SizeMisMatch;}
        var ops: [2]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                dest,
                src
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.cmp, &ops);
    }

    /// Subtarcts src from dest
    pub fn sub(self: *Assembler, dest: Operand, src: Operand) !void{
        if(dest == .Immediate){return AsmError.SizeMisMatch;}
        var ops: [2]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                dest,
                src
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.sub, &ops);
    }

    /// Pushes an operand
    pub fn push(self: *Assembler, src: Operand) !void{
        if(src == .Offset){return AsmError.OperandMisMatch;}
        var ops: [1]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                src
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.push, &ops);
    }

    /// Pops a value into the operand
    pub fn pop(self: *Assembler, src: Operand) !void{
        if(src != .Memory and src != .Register){return AsmError.OperandMisMatch;}
        var ops: [1]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                src
            },
            &ops, 
        );
        try self.emitter.emit(Instructions.pop, &ops);
    }
    
    /// Jumps conditionally expects a condition
    /// You Can find these conditions in `Jcc` 
    pub fn jcc(self: *Assembler, condition: u8, to: usize) !void {
        try self.patches.append(self.allocator, .{ .label = .{ 
            .label_id = to,
            .pos = self.emitter.bytes.items.len+1
        }});
        try self.emitter.emit(Instructions.generate_jcc(condition), &.{ .{.Immediate = 0} });  
    }

    /// Takes in at max 3 operands 
    /// This does not support imul reg rm imm8
    /// You will have to do that manually
    pub fn imul(self: *Assembler, operand: []const Operand) !void{
        const ops: []Emitter.Operand = try self.allocator.alloc(Emitter.Operand, operand.len);
        Assembler.from(operand, ops);
        try self.emitter.emit(Instructions.imul, ops);
        self.allocator.free(ops);
    }

    /// Sets the Operand to a value based on if a condition is true  
    /// You can find these conditions in 'Setcc' 
    pub fn setcc(self: *Assembler, condition: u8, src: Operand) !void{
        var ops: [1]Emitter.Operand = undefined;
        Assembler.from(
            &[_]Operand{
                src
            },
            &ops,
        );
        try self.emitter.emit(Instructions.generate_setcc(condition), &ops);
    }

    /// Loads an effective address idk what else to say man! 
    pub fn lea(self: *Assembler, dest: Register, src: Memory) !void{
        const ops: [2]Emitter.Operand = .{ .{.Register = dest}, .{.Memory = src} };
        try self.emitter.emit(Instructions.lea, &ops);
    }


    /// Returns, THIS IS NOT THERE BY DEFAULT!
    pub fn ret(self: *Assembler) !void{
        try self.emitter.bytes.append(self.allocator, 0xc3);
    }

    /// function epilogue 
    pub fn leave(self: *Assembler) !void{
        try self.emitter.bytes.append(self.allocator, 0xc9);
    }

    /// Emits and instruction 
    pub fn emit(self: *Assembler, instruction: []const Emitter.Encoding, operands: []const Operand) !void{
        const ops: []Emitter.Operand = try self.allocator.alloc(Emitter.Operand, operands.len);
        Assembler.from(operands, ops);
        std.debug.print("{any}\n", .{ops});
        try self.emitter.emit(instruction, ops);
        self.allocator.free(ops);
    }
};


test "Testing code lol"{
    const allocator = std.testing.allocator;
    var a: Assembler = .init(allocator);
    defer a.deinit();

 
    const main: usize = a.new_label();
    try a.push(.{ .Register = .rbp });
    try a.mov(.{ .Register = .rbp }, .{ .Register = .rsp });
    try a.bind(main);
    try a.sub(.{ .Register = .rsp }, .{ .Immediate = 16 });
    
    try a.mov(.{ .Register = .rax }, .{ .Offset = main });
    const mem: Memory = .{
        .base = .rdx,
        .size = 1, 
    };
    try a.imul(&.{
        .{.Register = .rax},
        .{.Memory = mem},
        .{.Immediate = 90}
    });

    try a.lea(Register.Register.rax, mem);

    try a.cmp(.{ .Register = .rax }, .{ .Immediate = 90 });
    try a.mov(.{ .Register = .rsp }, .{ .Register = .rbp });
    try a.pop(.{ .Register = .rbp });
    try a.jcc(Jcc.Ja, main);
    try a.setcc(Setcc.E, .{ .Register = .r12 });
    try a.ret();

    const func = try a.takefunc();
    try func.print_bytes(allocator);
    defer func.deinit();
    //func.asptr(*const fn () callconv(.c) void)();
}

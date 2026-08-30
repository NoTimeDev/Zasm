const std = @import("std");
const ArrayList = std.ArrayList;
const Emitter = @import("emitter/emitter.zig");
const Instructions = @import("instructions.zig");

pub const Register = @import("emitter/register.zig");
pub const Memory = Emitter.Memory;
pub const Jcc = Instructions.Jcc;
pub const Setcc = Instructions.Setcc;

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
    Register: Register.Register,
    Immediate: i64,
    Memory: Memory,
    // label id!
    Offset: usize,
};

/// AsmErrors 
pub const AsmError = error{
    MprotectFailed,
    SizeMisMatch,
    OperandMisMatch,
    RelOutOfRange,
};

/// Used to manage functions 
pub const Function = struct{
    code: []u8,
    len: usize,

    fn asptr(self: *const Function, comptime funcptr: type) funcptr{
        return @ptrCast(self.code.ptr);
    }

    fn init(code: []u8, len: usize) Function{
        return Function{
            .code = code,
            .len = len 
        };
    }

    fn deinit(self: *const Function) void {
        std.posix.munmap(@alignCast(self.code));
    }

    pub fn print_bytes(self: *const Function, allocator: std.mem.Allocator) !void{
        var threaded: std.Io.Threaded = .init(allocator, .{});
        defer threaded.deinit();
        const io = threaded.io();
        {
            const cwd = std.Io.Dir.cwd();
            var file = try cwd.createFile(io, "code.bin", .{});
            defer file.close(io);
            try file.writeStreamingAll(io, self.code[0..self.len]);
        }
        //for (self.bytes.items) |byte| {
          //std.debug.print("{x:0>2} ", .{byte});
        //}
        //std.debug.print("\n", .{});
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

    pub fn init(allocator: std.mem.Allocator) Assembler{
        return .{
            .allocator = allocator,
            .emitter = .init(allocator),
            .patches = .empty,
            .labels = .init(allocator),
        };
    }

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

    pub fn takefunc(self: *Assembler) !Function{
        if(self.emitter.bytes.items.len == 0){
            try self.emitter.bytes.append(self.allocator, 0xc3);
        }
        const func = try self.createfunc();
        self.emitter.bytes.clearRetainingCapacity();
        return func; 
    }

    pub fn deinit(self: *Assembler) void{
        self.emitter.deinit();
        self.labels.deinit();
        self.patches.deinit(self.allocator);
    }

    pub fn new_label(self: *Assembler) usize{
        self.lab_id+=1;
        return self.lab_id-1;
    }
    
    
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

    pub fn bind(self: *Assembler, label: usize) !void{
        try self.labels.put(label, self.emitter.bytes.items.len);
    }

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

    pub fn jcc(self: *Assembler, condition: u8, to: usize) !void {
        try self.patches.append(self.allocator, .{ .label = .{ 
            .label_id = to,
            .pos = self.emitter.bytes.items.len+1
        }});
        try self.emitter.emit(Instructions.generate_jcc(condition), &.{ .{.Immediate = 0} });  
    }

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

    pub fn ret(self: *Assembler) !void{
        try self.emitter.bytes.append(self.allocator, 0xc3);
    }

    pub fn leave(self: *Assembler) !void{
        try self.emitter.bytes.append(self.allocator, 0xc9);
    }
};

test "Leaks"{
    const allocator = std.testing.allocator;
    var a: Assembler = .init(allocator);
    defer a.deinit();

 
    const main: usize = a.new_label();
    try a.push(.{ .Register = .rbp });
    try a.mov(.{ .Register = .rbp }, .{ .Register = .rsp });
    try a.bind(main);
    try a.sub(.{ .Register = .rsp }, .{ .Immediate = 16 });
    
    try a.mov(.{ .Register = .rax }, .{ .Offset = main });

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

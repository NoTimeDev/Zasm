const std = @import("std");
const registers = @import("register.zig");
const bits = @import("bits.zig");
const ArrayList = std.ArrayList;

pub const Instructions = @import("instructions.zig");
pub const Register = @import("register.zig").Register;
pub const Jcc = Instructions.Jcc;
pub const Setcc = Instructions.Setcc;

pub const AsmError = error{
    ///Failed to set memory protection
    MprotectFailed,
    ///Size mis match when generating an instruction
    SizeMisMatch,
    ///Invalid operands for an instruction
    OperandMisMatch,
    ///Relative is out of range
    RelOutOfRange,
    ///Non gpr value in a Memory operand
    NonGPRInMem,
};


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
/// Patch Kind 
/// Label is used for jmps, e.g `jmp .cond`
/// AbsLabel is used when you want to write the address of .cond 
/// into a register e.g `mov rax, .cond`
const Patch = union(enum){
    label: struct {
        pos: usize,
        label_id: usize,
    },
    abs_label: struct {
        pos: usize,
        label_id: usize
    }
};

/// This is a structure used to emit instructions based on the provided info 
pub const Emitter = struct{
    allocator: std.mem.Allocator, 
    bytes: ArrayList(u8),
    patches: ArrayList(Patch),
    labels: std.AutoHashMap(usize, usize),
    lab_id: usize = 0,
    next: usize = 0, 

    pub fn init(allocator: std.mem.Allocator) Emitter{
        return .{
            .allocator = allocator,
            .bytes = .empty, 
            .patches = .empty,
            .labels = .init(allocator)
        };
    }
    
    fn verifymem(mem: Memory) !void{
        if(mem.base)|base|{
            if(base.class != .gpr){return AsmError.NonGPRInMem;}
        }
        if(mem.index)|index|{
            if(index.class != .gpr){return AsmError.NonGPRInMem;}
        }
    }
    ///Matches operands againts encodings and verify's Memory struct 
    fn match(encoding: Encoding, operands: []const Operand) !bool{
        if(encoding.operands.len != operands.len){return false;}
        for(encoding.operands, operands)|opk, op|{
            if(opk == .reg and op != .Register){return false;}
            else if(opk == .imm and op != .Immediate){
                return false;
            }else if(opk == .imm and op == .Immediate){
                if(op.Immediate.size > encoding.imm_max or encoding.imm_min > op.Immediate.size){
                    return false;
                }
            }
            else if(opk == .mem and op != .Memory){return false;}
            else if(opk == .rm and (op != .Register and op != .Memory)){return false;}
            else if(opk == .xmm){
                if(op != .Register){
                    return false;
                }
                if(op.Register.class != .xmm){return false;}
            }
            else if(opk == .xmm_m){
                if(op != .Register and op != .Memory){
                    return false;
                }
                if(op == .Register and op.Register.class != .xmm){return false;}
            }else{
                if(op == .Memory){try verifymem(op.Memory);}
            }
        }
        return true;
    }
   
    fn emitencoding(self: *Emitter, encoding: Encoding, operands: []const Operand) !void{
        if(operands.len == 0){
            try self.bytes.appendSlice(self.allocator, encoding.opcode.other.?);
            return;
        }

        if(encoding.prefix)|prefix|{
            try self.bytes.append(self.allocator, prefix);
        }
        var rex_w: u1 = 0;
        var rex_r: u1 = 0;
        var rex_x: u1 = 0;
        var rex_b: u1 = 0;
        if(encoding.rex)|rex|{
            if(rex.r)|r|{
                if(operands[r] == .Register){
                    rex_r = @intFromBool(operands[r].Register.rex);   
                }
            }
            if(rex.b)|b|{
                if(operands[b] == .Register){
                    rex_b = @intFromBool(operands[b].Register.rex);   
                }
                if(operands[b] == .Memory){
                    rex_b = if(operands[b].Memory.base)|base|
                        @intFromBool(base.rex)
                    else 
                        0;
                }
            }
        }
        const size = if(encoding.size)|size| size else operands[0].get_size(); 
        rex_w = if(size == 8 and encoding.rex64) 1 else 0;
        rex_x = 0;
        if(encoding.modr)|modr|{
            if(modr.rm == .operand and operands[modr.rm.operand] == .Memory and operands[modr.rm.operand].Memory.index != null){
                rex_x = @intFromBool(operands[modr.rm.operand].Memory.index.?.rex);
            }
        }
        if(size == 2){
            try self.bytes.append(self.allocator, 0x66);
        }
        if(rex_w == 1 or rex_r == 1 or rex_x == 1 or rex_b == 1){
            try self.bytes.append(self.allocator, bits.create_rex(rex_w, rex_r, rex_x, rex_b));
        }else if(size == 1){
            for(operands)|op|{
                if(op == .Register and op.Register.encoding >= 4){
                    try self.bytes.append(self.allocator, bits.create_rex(rex_w, rex_r, rex_x, rex_b));
                }
            }
        }

        var opcode: []const u8 = undefined;
        if(size == 8 and encoding.opcode.s64 != null){
            opcode = encoding.opcode.s64.?;
        }else if(size == 4 and encoding.opcode.s32 != null){
            opcode = encoding.opcode.s32.?;
        }else if(size == 2 and encoding.opcode.s16 != null){
            opcode = encoding.opcode.s16.?;
        }else if(size == 1 and encoding.opcode.s8 != null){
            opcode = encoding.opcode.s8.?;
        }else{
            if(encoding.opcode.other)|eopcode|{
                opcode = eopcode;
            }else{
                return AsmError.SizeMisMatch;
            }
        }

        
        if(encoding.modr)|modr|{
            if(modr.rm == .none){
                var last = opcode[opcode.len-1];
                if(modr.reg == .operand){
                    const reg = operands[modr.reg.operand].Register.encoding;
                    bits.setBit(&last, 2, bits.getBit(reg, 2));
                    bits.setBit(&last, 1, bits.getBit(reg, 1));
                    bits.setBit(&last, 0, bits.getBit(reg, 0));

                    try self.bytes.appendSlice(self.allocator, opcode[0..opcode.len-1]);
                    try self.bytes.append(self.allocator, last);
                }else{
                    try self.bytes.appendSlice(self.allocator, opcode);
                }
            }else{
                try self.bytes.appendSlice(self.allocator, opcode);
                var modr_bits: u8 = 0;
                const reg = if(modr.reg == .operand)
                    operands[modr.reg.operand].Register.encoding
                else if (modr.reg == .none)
                    0
                else
                    @as(u8, modr.reg.fixed);
                
                const rm = if(modr.rm == .operand)
                    if(operands[modr.rm.operand] == .Register) 
                        operands[modr.rm.operand].Register.encoding
                    else if(operands[modr.rm.operand] == .Memory)
                        if(operands[modr.rm.operand].Memory.base)|base| base.encoding else 0b00000100
                    else 
                        0
                else
                    @as(u8, modr.rm.fixed);
               
                // Fix this and rex.x
                var sibreq: bool = false;
                if(modr.rm == .operand){
                    //const op_reg = operands[modr.reg.operand];
                    const op_rm = operands[modr.rm.operand];
                    if(op_rm == .Memory){
                        if(op_rm.Memory.index != null or 
                            (op_rm.Memory.base != null and 
                             (op_rm.Memory.base.?.encoding == registers.Register.rsp.encoding)
                            )
                        ){
                            sibreq = true;
                        }
                        if(op_rm.Memory.base == null or op_rm.Memory.displacement == 0 and (op_rm.Memory.base != null and op_rm.Memory.base.?.encoding != registers.Register.rbp.encoding)){
                            bits.setBit(&modr_bits, 7, 0);
                            bits.setBit(&modr_bits, 6, 0);
                        }else if(std.math.cast(i8, op_rm.Memory.displacement) != null or (op_rm.Memory.base != null and op_rm.Memory.displacement == 0 and op_rm.Memory.base.?.encoding == registers.Register.rbp.encoding)){
                            bits.setBit(&modr_bits, 7, 0);
                            bits.setBit(&modr_bits, 6, 1);
                        }else{
                            bits.setBit(&modr_bits, 7, 1);
                            bits.setBit(&modr_bits, 6, 0);
                        }
                   }else{
                        bits.setBit(&modr_bits, 7, 1);
                        bits.setBit(&modr_bits, 6, 1);
                    }
                }else{
                    bits.setBit(&modr_bits, 7, 1);
                    bits.setBit(&modr_bits, 6, 1);
                }
               
                bits.setBit(&modr_bits, 5, bits.getBit(reg, 2));
                bits.setBit(&modr_bits, 4, bits.getBit(reg, 1));
                bits.setBit(&modr_bits, 3, bits.getBit(reg, 0));

                if(sibreq){
                    bits.setBit(&modr_bits, 2, 1);
                    bits.setBit(&modr_bits, 1, 0);
                    bits.setBit(&modr_bits, 0, 0);
                }else{
                    bits.setBit(&modr_bits, 2, bits.getBit(rm, 2));
                    bits.setBit(&modr_bits, 1, bits.getBit(rm, 1));
                    bits.setBit(&modr_bits, 0, bits.getBit(rm, 0));
                }
                try self.bytes.append(self.allocator, modr_bits);
            }
        }

        for(operands)|operand|{
            switch(operand){
                .Memory => |mem|{
                    if(mem.index != null or 
                        (mem.base != null and 
                         (mem.base.?.encoding == registers.Register.rsp.encoding)
                        )
                    ){
                        var sib: u8 = 0;
                        bits.setBit(&sib, 7, bits.getBit(mem.scale, 1));
                        bits.setBit(&sib, 6, bits.getBit(mem.scale, 0));

                        if(mem.index)|index|{
                            bits.setBit(&sib, 5, bits.getBit(index.encoding, 2));
                            bits.setBit(&sib, 4, bits.getBit(index.encoding, 1));
                            bits.setBit(&sib, 3, bits.getBit(index.encoding, 0));
                        }else{
                            bits.setBit(&sib, 5, 1);
                            bits.setBit(&sib, 4, 0);
                            bits.setBit(&sib, 3, 0);
                        }

                        if(mem.base)|base|{
                            bits.setBit(&sib, 2, bits.getBit(base.encoding, 2));
                            bits.setBit(&sib, 1, bits.getBit(base.encoding, 1));
                            bits.setBit(&sib, 0, bits.getBit(base.encoding, 0));
                        }else{
                            bits.setBit(&sib, 2, 1);
                            bits.setBit(&sib, 1, 0);
                            bits.setBit(&sib, 0, 1);
                        }
                        try self.bytes.append(self.allocator, sib);
                    }
                    if(mem.displacement >= 0 and mem.base == null){
                        for (std.mem.asBytes(&@as(i32, 0)))|byte|{
                            try self.bytes.append(self.allocator, byte);
                        }
                    }else if(mem.displacement != 0 or (mem.base != null and mem.base.?.encoding == registers.Register.rbp.encoding)){
                        if(std.math.cast(i8, mem.displacement))|v|{
                            try self.bytes.append(self.allocator, @bitCast(v));
                        }else{
                            for (std.mem.asBytes(&mem.displacement))|byte|{
                                try self.bytes.append(self.allocator, byte);
                            }
                        }
                    }
                },
                .Immediate => |imm|{
                    for (std.mem.asBytes(&imm.value)[0..imm.size])|byte|{
                        try self.bytes.append(self.allocator, byte);
                    }
                },
                else => {}
            }
        }
    }


    
    /// Creates a new label and returns the id 
    /// You will not be able to jump to this unless you call `.bind()`
    pub fn new_label(self: *Emitter) usize{
        self.lab_id+=1;
        return self.lab_id-1;
    }

    /// Takes in a label id and binds it to the current position
    pub fn bind(self: *Emitter, label: usize) !void{
        try self.labels.put(label, self.bytes.items.len);
    }

    /// Patches previous 8 bytes with the abs position to an offset 
    pub fn patch_abs(self: *Emitter, id: usize) !void{
        try self.patches.append(self.allocator, .{ .abs_label = .{ 
            .label_id = id,
            .pos = self.bytes.items.len-8
        }});
    }

    /// Pacthes previous 4 bytes with a rel32, Must be below the instruction to be patched 
    pub fn patch_rel(self: *Emitter, id: usize) !void{
        try self.patches.append(self.allocator, .{ .label = .{ 
            .label_id = id,
            .pos = self.bytes.items.len,
        }});
    }

    /// Creates a function from the bytes in the emitter struct
    fn createfunc(self: *Emitter) !Function{
        const size = std.mem.alignForward(usize, self.bytes.items.len, std.heap.pageSize());
        var ptr = try std.posix.mmap(
            null, 
            size, 
            .{.READ = true, .WRITE = true},
            .{.ANONYMOUS = true, .TYPE = .PRIVATE}, 
            -1, 
            0
        );
        @memcpy(ptr[0..self.bytes.items.len], self.bytes.items);
        for(self.patches.items)|patch|{
            switch(patch){
                .label => |label|{
                    const next = @intFromPtr(&ptr[label.pos]);
                    const target: usize = @intCast(@intFromPtr(&ptr[self.labels.get(label.label_id).?]));
                    const offset: i64 = @as(i64, @intCast(target)) - @as(i64, @intCast(next));
                    if(std.math.cast(i32, offset))|posoff|{
                        for(std.mem.asBytes(&posoff), 0..)|byte, i|{
                            ptr[patch.label.pos+i-4] = byte;
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
        const len = self.bytes.items.len; 
        return Function.init(ptr, len);
    }
    /// Returns a Function, this clears the current bytes and binded labels 
    pub fn takefunc(self: *Emitter) !Function{
        if(self.bytes.items.len == 0){
            try self.bytes.append(self.allocator, 0xc3);
        }
        const func = try self.createfunc();
        
        self.bytes.clearRetainingCapacity();
        self.patches.clearRetainingCapacity();
        self.labels.clearRetainingCapacity();
        
        self.lab_id = 0;
        return func; 
    }

    /// Emits an instructions
    pub fn emit(self: *Emitter, encodings: []const Encoding,  operands: []const Operand) !void {
        const start = self.bytes.items.len;
        for(encodings)|encoding|{
            if(try Emitter.match(encoding, operands)){
                try self.emitencoding(encoding, operands);
                return;
            }
        }
        self.next = self.bytes.items.len - start;
        return AsmError.OperandMisMatch;
    }
    
    pub fn deinit(self: *Emitter) void{
        self.bytes.deinit(self.allocator);
        self.labels.deinit();
        self.patches.deinit(self.allocator);
    }
};

test "Testing code lol"{
    const allocator = std.testing.allocator;
    var e: Emitter = .init(allocator);
    defer e.deinit();

  
    try e.emit(Instructions.imul, &.{ .{.Register = .ax}, .{.Register = .bl}, .{.Immediate = .{.value = 10, .size = 2}} }); 
    
    
    const func = try e.takefunc();
    try func.write_bytes("code.bin", allocator);
    defer func.deinit();

    //func.asptr(*const fn () callconv(.c) void)();
}

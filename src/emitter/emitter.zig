const builtin = @import("builtin");
const std = @import("std");
const registers = @import("register.zig");
const bits = @import("bits.zig");
const ArrayList = std.ArrayList;
pub const AsmError = @import("../errors.zig").AsmError;

/// Struct used to describe memory accses eg. `inst op, *[...]*`
pub const Memory = struct {
    base: ?registers.Register = null,
    index: ?registers.Register = null,
    scale: u8 = 0, 
    displacement: i32 = 0,
    size: u8,
};

pub const scale1: u8 = 0b00;
pub const scale2: u8 = 0b01;
pub const scale4: u8 = 0b10;
pub const scale8: u8 = 0b11;


/// The Data the asm operators act upon 
pub const Operand = union(enum){
    Register: registers.Register,
    Immediate: i64,
    Memory: Memory,
    
    fn get_size(self: *const Operand) u8{
        if(self.* == .Register){return self.Register.size;}
        else if(self.* == .Immediate){
            const x = self.Immediate;
            if (@as(i64, -128) <= x and x <= 127)
                return 1;

            if (@as(i64, -32768) <= x and x <= 32767)
                return 2;

            if (@as(i64, -2147483648) <= x and x <= 2147483647)
                return 4;

            return 8;
        }else{
            return self.Memory.size;
        }
    }
};

/// Used to represent the operand data 
pub const OperandKind = enum {
    reg, 
    rm,
    imm,
    mem,
};

// Encoding for Rex 
pub const RexSpec = struct {
    r: ?u4 = null, 
    b: ?u4 = null
};

/// Field for modr 
pub const ModrField = union(enum){
    operand: u8,
    fixed: u3,
    none,
};

/// Encoding for modr
pub const ModrSpec = struct {
    reg: ModrField = .none, 
    rm: ModrField = .none,
};

/// Encoding for opcode 
pub const OpCode = struct {
    s64: ?[]const u8 = null,
    s32: ?[]const u8 = null,
    s16: ?[]const u8 = null,
    s8: ?[]const u8 = null,
    other: ?[]const u8 = null,
};

/// An encoding for a specific instructions operand group(8 bit && 16-64 bit)
/// eg `mov reg/mem, reg`
pub const Encoding = struct {
    opcode: OpCode,
    operands: []const OperandKind,
    rex: ?RexSpec = null,
    modr: ?ModrSpec = null,
    imm_max: u8 = 8,
    imm_min: u8 = 1,
    rex64: bool = true,
    size: ?u8 = null,
};

/// This is a structure used to emit instructions based on the provided info 
pub const Emitter = struct{
    allocator: std.mem.Allocator, 
    bytes: ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) Emitter{
        return .{
            .allocator = allocator,
            .bytes = .empty, 
        };
    }
    
    fn match(encoding: []const OperandKind, operands: []const Operand) bool{
        if(encoding.len != operands.len){return false;}
        for(encoding, operands)|opk, op|{
            if(opk == .reg and op != .Register){return false;}
            if(opk == .imm and op != .Immediate){return false;}
            if(opk == .mem and op != .Memory){return false;}
            if(opk == .rm and (op != .Register and op != .Memory)){return false;}
        }
        return true;
    }
   
    fn emitencoding(self: *Emitter, encoding: Encoding, operands: []const Operand) !void{
        if(operands.len == 0){
            try self.bytes.appendSlice(self.allocator, encoding.opcode.other.?);
            return;
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
            opcode = encoding.opcode.other.?;
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
                    for (std.mem.asBytes(&imm)[0..@max(encoding.imm_min, @min(size, encoding.imm_max))])|byte|{
                        try self.bytes.append(self.allocator, byte);
                    }
                },
                else => {}
            }
        }
    }

    /// Emits an instructions
    pub fn emit(self: *Emitter, encodings: []const Encoding,  operands: []const Operand) !void {
        for(encodings)|encoding|{
            if(Emitter.match(encoding.operands, operands)){
                try self.emitencoding(encoding, operands);
                return;
            }
        }
        return AsmError.OperandMisMatch;
    }

    pub fn deinit(self: *Emitter) void{
        self.bytes.deinit(self.allocator);
    }
};



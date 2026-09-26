const std = @import("std");
const bits = @import("bits.zig");
const ArrayList = std.ArrayList;
const root = @import("root.zig");
const Size = root.operands.Size;

/// Holds the bytes for a function, which is written to executable memory
/// This struct is used to manage these bytes across platforms & architechures
pub const Function = struct{
    code: []u8,

    /// Returns a function pointer to the allocated memory
    pub fn asptr(self: *const Function, comptime funcptr: type) funcptr{
        return @ptrCast(self.code.ptr);
    }

    /// Creates a new Function
    /// `code` is expected to be executable memory
    fn init(code: []u8, len: usize) Function{
        return Function{
            .code = code,
            .len = len 
        };
    }

    /// Returns the allocated memory back to the os 
    pub fn deinit(self: *const Function) void {
        std.posix.munmap(@alignCast(self.code));
    }

    /// A debug utility, used to write the bytes of the function to a file
    /// To be used with a tool like objdump
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

/// Defines the types of patches used internally to record patches  
/// `pos` Stores the position of the location to be patched
/// `label_id` Stores the id of the label which is used to determine the value of the patched offset
const Patch = union(enum){
    /// Relative label used for jmp instruction, calls
    /// E.g jmp <label_1>
    label: struct {
        pos: usize,
        label_id: usize,
    },
    /// An absoulte position use for mov instruction
    /// E.g movabs rax, <label_1>
    ///     jmp rax
    abs_label: struct {
        pos: usize,
        label_id: usize
    }
};

///Returns the size of an operand
fn get_size(self: *const root.operands.Operand) Size{
    if(self.* == .Register){
        return self.Register.size;
    }
    else if(self.* == .Immediate){
        return self.Immediate.size;
    }else{
        return self.Memory.size;
    }
}

/// This struct is what is used to turn instructions + operands into actual bytes
pub const Emitter = struct{
    allocator: std.mem.Allocator, 
    bytes: ArrayList(u8),
    patches: ArrayList(Patch),
    labels: std.AutoHashMap(usize, usize),
    lab_id: usize = 0,
    next: usize = 0, 

    /// Creates a new Emitter
    pub fn init(allocator: std.mem.Allocator) Emitter{
        return .{
            .allocator = allocator,
            .bytes = .empty, 
            .patches = .empty,
            .labels = .init(allocator)
        };
    }
 
    // Internal function used to check that a `Memory` operand only contains gpr registers
    fn verifymem(mem: root.operands.Memory) !void{
        if(mem.base)|base|{
            if(base.class != .gpr){return root.AsmError.NonGPRInMem;}
        }
        if(mem.index)|index|{
            if(index.class != .gpr){return root.AsmError.NonGPRInMem;}
        }

        if(mem.base == null and mem.index == null){
            return root.AsmError.NullBaseAndIndex;
        }
    }

    // Used to match operands against, an Encoding
    fn match(encoding: root.encoding.Encoding, operands: []const root.operands.Operand) !bool{
        if(encoding.operands.len != operands.len){
            return false;
        }
        // opk -> operand kind, op -> operand
        for(encoding.operands, operands)|opk, op|{
            if(opk == .gpr and op != .Register){
                return false;
            }

            else if(opk == .imm and op != .Immediate){
                return false;
            }else if(opk == .imm and op == .Immediate){
                if(op.Immediate.size > encoding.imm_max or encoding.imm_min > op.Immediate.size){
                    return false;
                }
            }
            else if(opk == .mem and op != .Memory){
                return false;
            }
            else if(opk == .gpr_m){
                if(op != .Register and op != .Memory){
                    return false;
                }
                if(op == .Register and op.Register.class != .gpr){return false;}
            }
            else if(opk == .xmm){
                if(op != .Register){
                    return false;
                }
                if(op.Register.class != .xmm){
                    return false;
                }
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
   
    /// This function is what actually emits the bytes for an encoding 
    fn emitencoding(self: *Emitter, encoding: root.encoding.Encoding, operands: []const root.operands.Operand) !void{
        if(operands.len == 0){
            if(encoding.opcode.all)|bytes|{
                try self.bytes.appendSlice(self.allocator, bytes);
            }else{
                return root.AsmError.AllNotDefined;
            }
            return;
        }

        switch(encoding.prefix.prefix){
            .sse => |prefix|{
                try self.bytes.append(self.allocator, prefix);
            }, 
            .none => {},
            else => {
                @panic("Unsupported encoding fix me!!!!");
            }
        }

        const size = if(encoding.size)|size| size else get_size(&operands[0]); 
        if(encoding.prefix.legacy.rex){
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
            rex_w = if(size == 8) 1 else 0;
            rex_x = 0;
            if(encoding.modr)|modr|{
                if(modr.rm == .operand and operands[modr.rm.operand] == .Memory and operands[modr.rm.operand].Memory.index != null){
                    rex_x = @intFromBool(operands[modr.rm.operand].Memory.index.?.rex);
                }
            }
            try self.bytes.append(self.allocator, bits.create_rex(rex_w, rex_r, rex_x, rex_b));
        }

        if(encoding.prefix.legacy.operand_size and size == 2){
            try self.bytes.append(self.allocator, 0x66);
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
            if(encoding.opcode.all)|eopcode|{
                opcode = eopcode;
            }else{
                return root.AsmError.AllNotDefined;
            }
        }

        if(encoding.modr)|modr|{
            if(modr.rm == .none and modr.reg != .none){
                return root.AsmError.ModrMisMatch;
            }
            if(modr.rm == .none){
                // If only reg is defined, We encode the register in the last byte of the opcode list
                var last = opcode[opcode.len-1];
                if(modr.reg == .operand){
                    const reg = operands[modr.reg.operand].Register.encoding;
                    bits.setBit(&last, 2, bits.getBit(reg, 2));
                    bits.setBit(&last, 1, bits.getBit(reg, 1));
                    bits.setBit(&last, 0, bits.getBit(reg, 0));

                    try self.bytes.appendSlice(self.allocator, opcode[0..opcode.len-1]);
                    try self.bytes.append(self.allocator, last);
                }else if(modr.reg == .none){
                    try self.bytes.appendSlice(self.allocator, opcode);
                } 
            }else{
                // Otherwise we generate the modr byte 
                try self.bytes.appendSlice(self.allocator, opcode);
                var modr_bits: u8 = 0;
                
                // The register bits can only be.. well a regitser lol
                const reg = if(modr.reg == .operand)
                    operands[modr.reg.operand].Register.encoding
                else
                    @as(u8, modr.reg.fixed);
                
                const rm = if(modr.rm == .operand)
                    if(operands[modr.rm.operand] == .Register)
                        operands[modr.rm.operand].Register.encoding

                    else if(operands[modr.rm.operand] == .Memory)
                        if(operands[modr.rm.operand].Memory.base)|base| base.encoding else 0 
                    else 
                        0
                else
                    @as(u8, modr.rm.fixed);
               
                var sibreq: bool = false;
                if(modr.rm == .operand){
                    const op_rm = operands[modr.rm.operand];
                    if(op_rm == .Memory){
                        //Special cases were sib is required
                        if(op_rm.Memory.index != null or 
                            (op_rm.Memory.base != null and 
                             (op_rm.Memory.base.?.encoding == root.Register.rsp.encoding)
                            )
                        ){
                            sibreq = true;
                        }

                        //Decides if bit 7 and 6 
                        //00 indirect addressing
                        //01 indirect addressing 8 bit disp
                        //10 indirect addressing 32 bit disp
                        //11 register direct
                        
                        //X86 is dumb so there are some Special cases here with rsp, rbp, r12, r13
                        //Rsp and rbp are used here since they have the same encoding as r12 and r13 but note when you see
                        //....rbp.encoding is checking for rbp and r13 etc etc 
                        if(op_rm.Memory.base == null or op_rm.Memory.displacement == 0 and (op_rm.Memory.base != null and op_rm.Memory.base.?.encoding != root.Register.rbp.encoding)){
                            bits.setBit(&modr_bits, 7, 0);
                            bits.setBit(&modr_bits, 6, 0);
                        }else if(std.math.cast(i8, op_rm.Memory.displacement) != null or (op_rm.Memory.base != null and std.math.cast(i8, op_rm.Memory.displacement) != null and op_rm.Memory.base.?.encoding == root.Register.rbp.encoding)){
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
                    // 100 means sib required, No magic numbers here!
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

        // This MIGHT have to change later idk though
        for(operands)|operand|{
            switch(operand){
                .Memory => |mem|{
                    if(mem.index != null or 
                        (mem.base != null and 
                         (mem.base.?.encoding == root.Register.r12.encoding)
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
                            // No index or if r12 is used
                            bits.setBit(&sib, 5, 1);
                            bits.setBit(&sib, 4, 0);
                            bits.setBit(&sib, 3, 0);
                        }

                        if(mem.base)|base|{
                            bits.setBit(&sib, 2, bits.getBit(base.encoding, 2));
                            bits.setBit(&sib, 1, bits.getBit(base.encoding, 1));
                            bits.setBit(&sib, 0, bits.getBit(base.encoding, 0));
                        }else{
                            // A 32bit displacement must be present since we only have an index
                            bits.setBit(&sib, 2, 1);
                            bits.setBit(&sib, 1, 0);
                            bits.setBit(&sib, 0, 1);
                        }
                        try self.bytes.append(self.allocator, sib);
                    }
                    if(mem.displacement >= 0 and mem.base == null){
                        for (0..4)|_|{
                            try self.bytes.append(self.allocator, 0);
                        }
                    }else if(mem.displacement != 0 or (mem.base != null and mem.base.?.encoding == root.Register.rbp.encoding)){
                        // Force displacement byte if its rsp stuff 
                        if(std.math.cast(i8, mem.displacement))|v|{
                            try self.bytes.append(self.allocator, @bitCast(v));
                        }else{
                            // If it cannot fit into 8 bits used 32 bits instead 
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
                        return root.AsmError.RelOutOfRange;
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
            return root.AsmError.MprotectFailed;
        }

        return Function.init(ptr);
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
    pub fn emit(self: *Emitter, encodings: []const root.encoding.Encoding,  operands: []const root.operands.Operand) !void {
        const start = self.bytes.items.len;
        for(encodings)|encoding|{
            if(try Emitter.match(encoding, operands)){
                try self.emitencoding(encoding, operands);
                return;
            }
        }
        self.next = self.bytes.items.len - start;
        return root.AsmError.OperandMisMatch;
    }
    
    pub fn deinit(self: *Emitter) void{
        self.bytes.deinit(self.allocator);
        self.labels.deinit();
        self.patches.deinit(self.allocator);
    }
};

/// Describes the kind of operand an instruction expects
pub const OperandKind = enum {
    /// Gpr Register
    gpr, 
    /// Register or Memory
    gpr_m,
    
    /// Immediate
    imm,
    /// Memory
    mem,

    /// Xmm Register
    xmm,

    /// Xmmm Register or Memory
    xmm_m,
};

/// Describes how the REX prefix is generated for an instruction
/// The REX.W and REX.X bits are determined automatically from the
/// instruction and its operands. `r` and `b` specify which operands
/// are used to determine the REX.R and REX.B bits.
pub const RexSpec = struct {
    /// Index of the operand used to determine the REX.R bit
    /// `null` means the REX.R bit is set to 0
    r: ?u4 = null,

    /// Index of the operand used to determine the REX.B bit
    /// `null` means the REX.B bit is set to 0 
    b: ?u4 = null,
};

/// Decides what the modr field should be set to
pub const ModrField = union(enum){
    /// Index of the operand used to determine the modr fields bits.
    operand: u4,
    /// A fixed 3 bit value to be put in the modr field 
    fixed: u3,
    /// The modr field is determined by the instruction
    none,
};

/// Encoding for modr
pub const ModrSpec = struct {
    /// Decides what the reg field in modr should be set to .none by default
    reg: ModrField = .none, 
    /// Decides what the rm field in modr should be set to .none by default
    rm: ModrField = .none,
};

/// Encoding for opcode
/// s8 - the opcode if the operands are a byte
/// s16 - the opcode if the operands are a word
/// s32 - the opcode if the operands are a dword
/// s64 - the opcode if the operands are a qword
/// If a field is set to null, it means the emmitter will not generate
/// an instruction if the operands size match that field
pub const OpCode = struct {
    s64: ?[]const u8 = null,
    s32: ?[]const u8 = null,
    s16: ?[]const u8 = null,
    s8: ?[]const u8 = null,
};

pub const Vex = struct{

};

pub const Evex = struct{

};

/// A prefix to be generated before an instruction this 
pub const Prefix = union(enum){
    sse: u8,
    vex: Vex,
    evex: Evex,
    rex,
    none 
};

/// An encoding for a specific instructions operand group(8 bit && 16-64 bit)
/// eg `mov reg/mem, reg`
pub const Encoding = struct {
    prefix: Prefix = .rex,
    opcode: OpCode,
    operands: []const OperandKind,

    rex: ?RexSpec = null,
    
    modr: ?ModrSpec = null,
    
    imm_max: u8 = 8,
    
    imm_min: u8 = 1,
};



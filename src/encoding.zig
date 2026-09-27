const Size = @import("root.zig").Size;

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

    /// Mmx Register
    mmx, 

    /// Mmx Register or Memory
    mmx_m,

    /// x87 Register
    x87, 

    /// Xmm Register
    xmm,

    /// Xmm Register or Memory
    xmm_m,
    
    /// Ymm Register
    ymm,

    /// Ymm Register or Memory
    ymm_m,

    /// zmm Register
    zmm,

    /// Zmm Register or Memory
    zmm_m,
};

/// Describes how the REX prefix is generated for an instruction
/// The REX.W and REX.X bits are determined automatically from the
/// instruction and its operands. `r` and `b` specify which operands
/// are used to determine the REX.R and REX.B bits.
pub const Rex = struct {
    w: u1 = 0,
    r: ?u4 = null,
    x: ?u4 = null,
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
/// s8 - the opcode emitted if the operands are a byte
/// s16 - the opcode emitted if the operands are a word
/// s32 - the opcode emitted if the operands are a dword
/// s64 - the opcode emitted if the operands are a qword
/// s128 - the opcode emitted if the operands are a oword 
/// s256 - the opcode emitted if the operands are a yword
/// s512 - the opcode emitted if the operands are a zword
/// If a field is set to null, it means the emmitter will not generate
/// an instruction if the operands size match that field
/// if `all` is defined it is used as the opcode regardless of the size of the operands 
pub const OpCode = struct {
    all: ?[]const u8 = null,
    s512: ?[]const u8 = null,
    s256: ?[]const u8 = null,
    s128: ?[]const u8 = null,
    s80: ?[]const u8 = null,
    s64: ?[]const u8 = null,
    s32: ?[]const u8 = null,
    s16: ?[]const u8 = null,
    s8: ?[]const u8 = null,
};

pub const SsePrefix = enum(u8){
    none = 0,
    p66 = 0x66,
    pF3 = 0xF3,
    pF2 = 0xF2
};

pub const VexPrefixSize = enum {
    bytes2,
    bytes3
};

pub const VexLen = enum{
   s128,
   s256,
   s512,
   ignored,
};

pub const OpCodeMap = enum(u5){
    ignored = 0,
    m0F = 0b00001,
    m0F38 = 0b00010,
    m0F3A = 0b00011
};

pub const Vex = struct{
    use: VexPrefixSize,
    w: ?u1 = 0,
    r: ?u4 = null,
    x: ?u4 = null,
    b: ?u4 = null,
    
    vvvv: ?u4 = null,
    L: VexLen = .ignored,
    pp: SsePrefix,
    map: OpCodeMap
};

pub const Evex = struct{
    use: VexPrefixSize,
    w: ?u1 = 0,
    r: ?u4 = null,
    x: ?u4 = null,
    b: ?u4 = null,
    
    pp: SsePrefix,
    vvvvv: ?u4 = null,
    map: OpCodeMap, 
};

/// A prefix to be generated before an instruction
pub const Prefix = struct{
    pub const LegacyPrefix = struct{
        operand_size: bool = false,
        sse: ?SsePrefix = null,
        forcerex: bool = false
    };
    pub const PrefixEncoding = union(enum){
        rex: Rex, 
        vex: Vex,
        evex: Evex,
        none 
    };

    legacy: LegacyPrefix,
    prefix: PrefixEncoding,
};

pub const SizeConstraint = struct {
    cond: ?OperandKind = null,
    sizes: []const Size,
};

/// An encoding for a specific instructions operand group(8 bit && 16-64 bit)
/// eg `mov reg/mem, reg`
pub const Encoding = struct {
    prefix: Prefix = .{ .legacy = .{}, .prefix = .none },
    opcode: OpCode,
    operands: []const OperandKind,
    modr: ?ModrSpec = null,
    instrsize: u4 = 0,
    size_constraints: []const []const SizeConstraint, 
};

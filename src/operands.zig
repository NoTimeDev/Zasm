pub const Register = @import("register.zig").Register;

///Scaling factor used in memory addressing
pub const Scale = enum(u2){
    ///SIB Scale 1, `[gpr*1]`
    scale1 = 0b00,
    ///SIB Scale 2, `[gpr*2]``
    scale2 = 0b01,
    ///SIB Scale 4, `[gpr*4]`
    scale4 = 0b10,
    ///SIB Scale 8, `[gpr*8]`
    scale8 = 0b11,
};

///Size used to match operands to their instruction
pub const Size = enum(u8){
    ///byte - 1 byte(lol)
    byte = 1,
    ///Word - 2 bytes
    word = 2,
    ///Dword - 4 bytes
    dword = 4,
    ///Qword - 8 bytes
    qword = 8
};

///Struct describing memory operand 
///`[ base + index * scale + displacement]`
///`base` and `index` cannot both be null `displacement` cannot be specified without base or null 
///
///`size` is the size of memory being accsesed in bytes(1, 2, 4 or 8)
pub const Memory = struct{
    ///Base for addressing, must be set if index is null  
    base: ?Register = null,
    ///Index for addressing, must be set if base is null
    index: ?Register = null,
    ///SIB Scale, 1, 2, 4, or 8 
    scale: Scale = Scale.scale1,
    ///Displacement for addressing, cannot be set by itself
    displacement: i32 = 0,
    ///Size, used for matching
    size: Size,
};

///The Data the asm operators act upon
///May be an immediate value, regitser or memory operand 
pub const Operand = union(enum){
    ///A register operand
    Register: Register,

    ///An immediate value, 
    ///`size` represents the encoded immediate size in bytes 
    Immediate: struct {value: u64, size: Size},

    ///A memory operand
    Memory: Memory,
};

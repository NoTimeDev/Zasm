pub const emitter = @import("emitter.zig");
pub const operands = @import("operands.zig");
pub const encoding = @import("encoding.zig");

pub const Operand = operands.Operand;
pub const Memory = operands.Memory;
pub const Scale = operands.Scale;
pub const Modifier = operands.Modifier;

pub const Instructions = @import("instructions.zig");
pub const Register = @import("register.zig").Register;
pub const AsmError = error{
    /// Failed to set memory protection
    MprotectFailed,
    /// Size mis match when generating an instruction
    SizeMisMatch,
    /// Invalid operands for an instruction
    OperandMisMatch,
    /// Relative is out of range
    RelOutOfRange,
    /// Non gpr value in a Memory operand
    NonGPRInMem,
    /// <RegKind>16+ found in Memory operand
    ExtendedRegInMem,
    /// encoding.OpCode.all is not defined, when s8-s64 arent defined
    /// Or if instruction encoding expects encoding.OpCode.all 
    AllNotDefined,
    /// Mis match with modr, eg .rm = .none & .reg = .fixed
    ModrMisMatch,
    /// If base and index are null in a memory field
    NullBaseAndIndex,
    /// Tried to create a 512 instruction using vex 
    s512InVex
};

/// Size used to match operands to their instruction
pub const Size = enum(u8){
    /// Byte - 1 byte(lol)
    byte = 1,
    /// Word - 2 bytes
    word = 2,
    /// Doubleword - 4 bytes
    dword = 4,
    /// Quadword - 8 bytes
    qword = 8,
    /// Tenbyte - 10 bytes
    tbyte = 10,
    /// OctoWord - 16 bytes
    oword = 16,
    /// YmmWord - 32 bytes 
    yword = 32,
    /// ZmmWord - 64 bytes 
    zword = 64,
};
test "Testing code lol"{
    const std = @import("std");
    const allocator = std.testing.allocator;
    
    var e: emitter.Emitter = .init(allocator);
    defer e.deinit();

    const mem: Memory = .{
        .size = .dword,
        .base = .rax,
        .displacement = 120,
        .index = .rbx,
        .scale = .scale4,
    };
    try e.emit(Instructions.vaddss, &.{ .{.Register = .xmm19}, .{.Register = .xmm20}, .{.Register = .xmm18} }, null);     
    try e.emit(Instructions.vaddss, &.{ .{.Register = .xmm16}, .{.Register = .xmm17}, .{.Memory = mem} }, .{
       .mask = .{
           .reg = 4,
           .zero = true,
       },
       .rounding = .none,
    });     
    
    const func = try e.takefunc();
    try func.write_bytes("code.bin", allocator);
    defer func.deinit();

    //func.asptr(*const fn () callconv(.c) void)();
}

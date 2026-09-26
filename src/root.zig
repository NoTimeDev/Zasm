pub const emitter = @import("emitter.zig");
pub const operands = @import("operands.zig");
pub const encoding = @import("encoding.zig");

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
    /// encoding.OpCode.all is not defined, when s8-s64 arent defined
    /// Or if instruction encoding expects encoding.OpCode.all 
    AllNotDefined,
    /// Mis match with modr, eg .rm = .none & .reg = .fixed
    ModrMisMatch,
    /// If base and index are null in a memory field
    NullBaseAndIndex
};

test "Testing code lol"{
    const std = @import("std");
    const allocator = std.testing.allocator;
    
    var e: emitter.Emitter = .init(allocator);
    defer e.deinit();

    try e.emit(Instructions.movq, &.{ .{.Register = .xmm0}, .{.Register = .xmm1} });     
    
    const func = try e.takefunc();
    try func.write_bytes("code.bin", allocator);
    defer func.deinit();

    //func.asptr(*const fn () callconv(.c) void)();
}

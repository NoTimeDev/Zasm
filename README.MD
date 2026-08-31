# Zasm
Zasm is an x86_64 machine code generator lib in Zig.  

Zasm lets you describe instructions and generate the corresponding x86_64 machine code.  
You can then load these bytes into executable memory to be called like a normal function.  

# Examples 
## Basic usage 
```zig 
var e: zasm.Emitter = .init(std.testing.allocator);
defer e.deinit();

// Mov 4290 into rax an return 
try e.emit(zasm.Instructions.mov, &.{ 
	.{ .Register = .rax },
	.{ .Immediate = 4290 }
});
try e.emit(zasm.Instructions.ret, &.{}); 

// Creates a function struct which holds the executable memory
const func: zasm.Function = try e.takefunc();
defer func.deinit();

// Creates a function pointer 
const Fn = *const fn () callconv(.c) u64;
const funcptr: Fn = func.asptr(Fn);

//Should return 4290 
std.debug.print("{}\n", .{funcptr()});
```

## Describing instructions
Zasm also allows you to describe instructions and use them. For example, the example above

```zig
// describe our instruction
const ret: []const zasm.Encoding = &.{
	.{
		.opcode = .{.other = &.{0xc3}},
		.operands = &.{},
	}
};

const mov: []const zasm.Encoding = &.{
	.{
		.opcode = .{ .s8 = &.{0x88}, .other = &.{0x89}},
		.operands = &.{.rm, .reg},
		.rex = .{ .r = 1, .b = 0},
		.modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
	},
	.{
		.opcode = .{ .s8 = &.{0x8A}, .other = &.{0x8B}},
		.operands = &.{.reg, .rm},
		.rex = .{ .r = 0, .b = 1},
		.modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
	},
	.{
		.opcode = .{ .s8 = &.{0xB0}, .other = &.{0xB8}},
		.operands = &.{.reg, .imm},
		.rex = .{ .b = 0},
		.modr = .{.reg = .{ .operand = 0 }}
	},
	.{
		.opcode = .{ .s8 = &.{0xC6}, .other = &.{0xC7}},
		.operands = &.{.rm, .imm},
		.rex = .{ .b = 0},
		.modr = .{.reg = .{ .fixed = 0 }, .rm = .{ .operand = 0 }},
		.imm_max = 4,
	},
};

var e: zasm.Emitter = .init(std.testing.allocator);
defer e.deinit();

// Mov 4290 into rax an return 
try e.emit(mov, &.{ 
	.{ .Register = .rax },
	.{ .Immediate = 4290 }
});
try e.emit(ret, &.{}); 

// Creates a function struct which holds the executable memory
const func: zasm.Function = try e.takefunc();
defer func.deinit();

// Creates a function pointer 
const Fn = *const fn () callconv(.c) u64;
const funcptr: Fn = func.asptr(Fn);

//Should return 4290 
std.debug.print("{}\n", .{funcptr()});
```

# Development status
Zasm is still in its early development stage, so breaking changes should be expected.  
As for documentation, right now you'll have to read the source code. its quite small dont worry!

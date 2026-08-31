const Emitter = @import("emitter/emitter.zig");

/// Instructions used by the defined functions in the Assembler struct 

pub const ret: []const Emitter.Encoding = &.{
    .{
        .opcode = .{.other = &.{0xc3}},
        .operands = &.{},
    }
};

pub const cmp: []const Emitter.Encoding = &.{
    .{
        .opcode = .{ .s8 = &.{0x38}, .other = &.{0x39}},
        .operands = &.{.rm, .reg},
        .rex = .{ .r = 1, .b = 0},
        .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x3A}, .other = &.{0x3B}},
        .operands = &.{.reg, .rm},
        .rex = .{ .r = 0, .b = 1},
        .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
        .operands = &.{.rm, .imm},
        .rex = .{ .b = 0},
        .modr = .{.reg = .{ .fixed = 7 }, .rm = .{ .operand = 0 }},
        .imm_max = 4,
    },
};

pub const add: []const Emitter.Encoding = &.{
    .{
        .opcode = .{ .s8 = &.{0x00}, .other = &.{0x01}},
        .operands = &.{.rm, .reg},
        .rex = .{ .r = 1, .b = 0},
        .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x02}, .other = &.{0x03}},
        .operands = &.{.reg, .rm},
        .rex = .{ .r = 0, .b = 1},
        .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
        .operands = &.{.rm, .imm},
        .rex = .{ .b = 0},
        .modr = .{.reg = .{ .fixed = 0 }, .rm = .{ .operand = 0 }},
        .imm_max = 4,
    },
};

pub const sub: []const Emitter.Encoding = &.{
    .{
        .opcode = .{ .s8 = &.{0x28}, .other = &.{0x29}},
        .operands = &.{.rm, .reg},
        .rex = .{ .r = 1, .b = 0},
        .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x2A}, .other = &.{0x2B}},
        .operands = &.{.reg, .rm},
        .rex = .{ .r = 0, .b = 1},
        .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
    },
    .{
        .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
        .operands = &.{.rm, .imm},
        .rex = .{ .b = 0},
        .modr = .{.reg = .{ .fixed = 5 }, .rm = .{ .operand = 0 }},
        .imm_max = 4,
    },
};

pub const mov: []const Emitter.Encoding = &.{
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

pub const push: []const Emitter.Encoding = &.{
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0xFF} },
        .operands = &.{.rm},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 6 } }
    },
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0x50} },
        .operands = &.{.reg},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .none, .reg = .{ .operand = 0 } }
    },
    .{
        .rex64 = false,
        .opcode = .{ .s8 = &.{0x6A}, .other = &.{0x68} },
        .operands = &.{.imm},
        .modr = .{ .rm = .none, .reg = .none },
        .imm_max = 4 
    }
};

pub const pop: []const Emitter.Encoding = &.{
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0x8F} },
        .operands = &.{.rm},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 0 } }
    },
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0x58} },
        .operands = &.{.reg},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .none, .reg = .{ .operand = 0 } }
    }
};

pub const jmp: []const Emitter.Encoding = &.{
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0xFF} },
        .operands = &.{.rm},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 4} }
    },
    .{
        .rex64 = false,
        .opcode = .{.other = &.{0xE9} },
        .operands = &.{.imm},
        .modr = .{ .rm = .none, .reg = .none },
        .imm_max = 4,
        .size = 4
    }
};

pub const call: []const Emitter.Encoding = &.{
    .{
        .rex64 = false,
        .opcode = .{ .other = &.{0xFF} },
        .operands = &.{.rm},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 2} }
    },
    .{
        .rex64 = false,
        .opcode = .{.other = &.{0xE8} },
        .operands = &.{.imm},
        .modr = .{ .rm = .none, .reg = .none },
        .imm_max = 4,
        .size = 4
    }
};

pub const imul_imm8: []const Emitter.Encoding = &.{
    .{
        .opcode = .{.other = &.{0x6B} },
        .operands = &.{.reg, .rm, .imm},
        .rex = .{ .r = 0, .b = 1 },
        .modr = .{ .rm = .{ .operand = 1 }, .reg = .{ .operand = 0 } },
        .imm_max = 1,
    }
};

pub const lea: []const Emitter.Encoding = &.{
    .{
        .opcode = .{.other = &.{0x8D}},
        .operands = &.{.reg, .mem},
        .rex = .{.r = 0, .b = 1},
        .modr = .{.rm = .{ .operand = 1 }, .reg = .{ .operand = 0 }},
    }
};

pub const imul: []const Emitter.Encoding = &.{
    .{
        .opcode = .{ .s8 = &.{0xF6},  .other = &.{0xF7} },
        .operands = &.{.rm},
        .rex = .{ .b = 0 },
        .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 5 } }
    },
    .{
        .opcode = .{.other = &.{0x69} },
        .operands = &.{.reg, .rm, .imm},
        .rex = .{ .r = 0, .b = 1 },
        .modr = .{ .rm = .{ .operand = 1 }, .reg = .{ .operand = 0 } },
        .imm_max = 4,
        .imm_min = 2,
    }
};
pub fn generate_jcc(condition: u8) []const Emitter.Encoding{
    return &.{
        .{
            .rex64 = false,
            .opcode = .{.other = &.{0x0F, condition} },
            .operands = &.{.imm},
            .modr = .{ .rm = .none, .reg = .none },
            .imm_max = 4,
            .size = 4
        }
    };
}

pub fn generate_setcc(condition: u8) []const Emitter.Encoding{
    return &.{
       .{
            .rex64 = false,
            .opcode = .{.other = &.{0x0F, condition} },
            .operands = &.{.rm},
            .rex = .{.b = 0},
            .modr = .{ .rm = .{. operand = 0}, .reg = .none },
            .imm_max = 4,
            .size = 4
        }
    };
}
pub const Jcc = struct {
    pub const Ja = 0x87;
    pub const Jae = 0x83;
    pub const Jb = 0x82;
    pub const Jbe = 0x86;
    pub const Jc = 0x82;
    pub const Je = 0x84;
    pub const Jz = 0x84;
    pub const Jg = 0x8F;
    pub const Jge = 0x8D;
    pub const Jl = 0x8C;
    pub const Jle = 0x8E;
    pub const Jna = 0x86;
    pub const Jnae = 0x82;
    pub const Jnb = 0x83;
    pub const Jnbe = 0x87;
    pub const Jnc = 0x83;
    pub const Jne = 0x85;
    pub const Jng = 0x8E;
    pub const Jnge = 0x8C;
    pub const Jnl = 0x8D;
    pub const Jnle = 0x8F;
    pub const Jno = 0x81;
    pub const Jnp = 0x8B;
    pub const Jns = 0x89;
    pub const Jnz = 0x85;
    pub const Jo = 0x80;
    pub const Jp = 0x8A;
    pub const Jpe = 0x8A;
    pub const Jpo = 0x8B;
    pub const Js = 0x88;
};

pub const Setcc = struct {
    pub const A = 0x97;
    pub const AE = 0x93;
    pub const B = 0x92;
    pub const BE = 0x96;
    pub const C = 0x92;
    pub const E = 0x94;
    pub const Z = 0x94;
    pub const G = 0x9F;
    pub const GE = 0x9D;
    pub const L = 0x9C;
    pub const LE = 0x9E;
    pub const NA = 0x96;
    pub const NAE = 0x92;
    pub const NB = 0x93;
    pub const NBE = 0x97;
    pub const NC = 0x93;
    pub const NE = 0x95;
    pub const NG = 0x9E;
    pub const NGE = 0x9C;
    pub const NL = 0x9D;
    pub const NLE = 0x9F;
    pub const NO = 0x91;
    pub const NP = 0x9B;
    pub const NS = 0x99;
    pub const NZ = 0x95;
    pub const O = 0x90;
    pub const P = 0x9A;
    pub const PE = 0x9A;
    pub const PO = 0x9B;
    pub const S = 0x98;
};

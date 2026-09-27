///! Predefined common instructions 
const Encoding = @import("encoding.zig");
const Size = @import("root.zig").Size;

pub const pmulld: []const Encoding.Encoding = &.{
   .{
        .prefix = .{
            .prefix = .{
                .vex = .{
                    .use = .bytes3,
                    .pp = .p66,
                    .L = .s128,
                    .vvvv = 1,
                    .r = 0,
                    .map = .m0F38
                }
            },
            .legacy = .{}
        },
        .opcode = .{ .s128 = &.{0x40} },
        .operands = &.{.xmm, .xmm, .xmm_m},
        .modr = .{
            .reg = .{ .operand = 0 },
            .rm = .{ .operand = 2 },
        },
        .instrsize = 0,
        .size_constraints = &.{
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .sizes = &.{Size.oword}
                }
            }
        }
    }
};

pub const addss: []const Encoding.Encoding = &.{
    .{
        .prefix = .{
            .prefix = .{
                .vex = .{
                    .use = .bytes2,
                    .pp = .pF3,
                    .map = .m0F,
                    .r = 0,
                    .vvvv = 1,
                } 
            },
            .legacy = .{}
        },
        .opcode = .{ .s128 = &.{0x58} },
        .operands = &.{.xmm, .xmm, .xmm_m},
        .modr = .{
            .reg = .{ .operand = 0 },
            .rm = .{ .operand = 2 },
        },
        .instrsize = 0,
        .size_constraints = &.{
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .cond = .mem,
                    .sizes = &.{
                        Size.dword
                    }
                },
                .{
                    .sizes = &.{Size.oword}
                }
            }
        }
    }
};

pub const movq: []const Encoding.Encoding = &.{
    .{  
        .prefix = .{
            .prefix = .{ 
                .rex = .{
                    .w = 1,
                    .r = 0,
                    .b = 1,
                    .x = 1
                }
            },
            .legacy = .{ .operand_size = true }
        },
        .operands = &.{.xmm, .gpr_m},
        .opcode = .{.s128 = &.{0x0F, 0x6E}},
        .modr = .{
            .reg = .{ .operand = 0 },
            .rm = .{ .operand = 1 }
        },
        .instrsize = 0,
        .size_constraints = &.{
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .sizes = &.{Size.qword}
                }
            }
        }
    },
    .{
        .prefix = .{ 
            .prefix = .{ 
                .rex = .{
                    .w = 0,
                    .r = 0,
                    .b = 1,
                    .x = 1
                }
            },
            .legacy = .{.sse = .pF3}
        },
        .opcode = .{ .s128 = &.{0x0F, 0x7E} },
        .operands = &.{.xmm, .xmm_m},
        .modr = .{
            .reg = .{ .operand = 0 },
            .rm = .{ .operand = 1 }
        },
        .instrsize = 0,
        .size_constraints = &.{
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            },
            &.{
                .{
                    .cond = .mem,
                    .sizes = &.{Size.qword}
                },
                .{
                    .sizes = &.{Size.oword}
                }
            }
        }
    },
    .{
        .prefix = .{ 
            .prefix = .none,
            .legacy = .{ .sse = .p66 }
        },
        .opcode = .{ .s128 = &.{0x0F, 0xd6} },
        .operands = &.{.xmm_m, .xmm},
        .modr = .{
            .reg = .{ .operand = 1 },
            .rm = .{ .operand = 0}
        },
        .instrsize = 1,
        .size_constraints = &.{
            &.{
                .{
                    .cond = .mem,
                    .sizes = &.{Size.qword}
                },
                .{
                    .sizes = &.{Size.oword}
                }
            },
            &.{
                .{
                    .sizes = &.{
                        Size.oword
                    }
                }
            }
        }
    }
};

// pub const smovq: []const emitter.encoding = &.{
//     .{
//         .rex64 = false,
//         .prefix = 0xf3,
//         .opcode = .{.s64 = &.{0x0f, 0x7e}},
//         .operands = &.{.xmm, .xmm_m},
//         .rex = .{.r = 0, .b = 1},
//         .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }},
//         .size  = 8,
//     },
//     .{
//         .rex64 = false,
//         .prefix = 0x66,
//         .opcode = .{.s64 = &.{0x0f, 0xd6}},
//         .operands = &.{.xmm_m, .xmm},
//         .rex = .{.r = 1, .b = 0},
//         .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }},
//         .size = 8 
//     }
// };

// pub const cmp: []const emitter.encoding = &.{
//     .{
//         .opcode = .{ .s8 = &.{0x38}, .other = &.{0x39}},
//         .operands = &.{.rm, .reg},
//         .rex = .{ .r = 1, .b = 0},
//         .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x3a}, .other = &.{0x3b}},
//         .operands = &.{.reg, .rm},
//         .rex = .{ .r = 0, .b = 1},
//         .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
//         .operands = &.{.rm, .imm},
//         .rex = .{ .b = 0},
//         .modr = .{.reg = .{ .fixed = 7 }, .rm = .{ .operand = 0 }},
//         .imm_max = 4,
//     },
// };

// pub const add: []const emitter.encoding = &.{
//     .{
//         .opcode = .{ .s8 = &.{0x00}, .other = &.{0x01}},
//         .operands = &.{.rm, .reg},
//         .rex = .{ .r = 1, .b = 0},
//         .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x02}, .other = &.{0x03}},
//         .operands = &.{.reg, .rm},
//         .rex = .{ .r = 0, .b = 1},
//         .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
//         .operands = &.{.rm, .imm},
//         .rex = .{ .b = 0},
//         .modr = .{.reg = .{ .fixed = 0 }, .rm = .{ .operand = 0 }},
//         .imm_max = 4,
//     },
// };

// pub const sub: []const emitter.encoding = &.{
//     .{
//         .opcode = .{ .s8 = &.{0x28}, .other = &.{0x29}},
//         .operands = &.{.rm, .reg},
//         .rex = .{ .r = 1, .b = 0},
//         .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x2a}, .other = &.{0x2b}},
//         .operands = &.{.reg, .rm},
//         .rex = .{ .r = 0, .b = 1},
//         .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x80}, .other = &.{0x81}},
//         .operands = &.{.rm, .imm},
//         .rex = .{ .b = 0},
//         .modr = .{.reg = .{ .fixed = 5 }, .rm = .{ .operand = 0 }},
//         .imm_max = 4,
//     },
// };

// pub const mov: []const emitter.encoding = &.{
//     .{
//         .opcode = .{ .s8 = &.{0x88}, .other = &.{0x89}},
//         .operands = &.{.rm, .reg},
//         .rex = .{ .r = 1, .b = 0},
//         .modr = .{.reg = .{ .operand = 1 }, .rm = .{ .operand = 0 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0x8a}, .other = &.{0x8b}},
//         .operands = &.{.reg, .rm},
//         .rex = .{ .r = 0, .b = 1},
//         .modr = .{.reg = .{ .operand = 0 }, .rm = .{ .operand = 1 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0xb0}, .other = &.{0xb8}},
//         .operands = &.{.reg, .imm},
//         .rex = .{ .b = 0},
//         .modr = .{.reg = .{ .operand = 0 }}
//     },
//     .{
//         .opcode = .{ .s8 = &.{0xc6}, .other = &.{0xc7}},
//         .operands = &.{.rm, .imm},
//         .rex = .{ .b = 0},
//         .modr = .{.reg = .{ .fixed = 0 }, .rm = .{ .operand = 0 }},
//         .imm_max = 4,
//     },
// };

// pub const push: []const emitter.encoding = &.{
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0xff} },
//         .operands = &.{.rm},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 6 } }
//     },
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0x50} },
//         .operands = &.{.reg},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .none, .reg = .{ .operand = 0 } }
//     },
//     .{
//         .rex64 = false,
//         .opcode = .{ .s8 = &.{0x6a}, .other = &.{0x68} },
//         .operands = &.{.imm},
//         .modr = .{ .rm = .none, .reg = .none },
//         .imm_max = 4 
//     }
// };

// pub const pop: []const emitter.encoding = &.{
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0x8f} },
//         .operands = &.{.rm},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 0 } }
//     },
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0x58} },
//         .operands = &.{.reg},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .none, .reg = .{ .operand = 0 } }
//     }
// };

// pub const jmp: []const emitter.encoding = &.{
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0xff} },
//         .operands = &.{.rm},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 4} }
//     },
//     .{
//         .rex64 = false,
//         .opcode = .{.other = &.{0xe9} },
//         .operands = &.{.imm},
//         .modr = .{ .rm = .none, .reg = .none },
//         .imm_max = 4,
//         .size = 4
//     }
// };

// pub const call: []const emitter.encoding = &.{
//     .{
//         .rex64 = false,
//         .opcode = .{ .other = &.{0xff} },
//         .operands = &.{.rm},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 2} }
//     },
//     .{
//         .rex64 = false,
//         .opcode = .{.other = &.{0xe8} },
//         .operands = &.{.imm},
//         .modr = .{ .rm = .none, .reg = .none },
//         .imm_max = 4,
//         .size = 4
//     }
// };

// pub const lea: []const emitter.encoding = &.{
//     .{
//         .opcode = .{.other = &.{0x8d}},
//         .operands = &.{.reg, .mem},
//         .rex = .{.r = 0, .b = 1},
//         .modr = .{.rm = .{ .operand = 1 }, .reg = .{ .operand = 0 }},
//     }
// };

// pub const imul: []const emitter.encoding = &.{
//     .{
//         .opcode = .{ .s8 = &.{0xf6},  .other = &.{0xf7} },
//         .operands = &.{.rm},
//         .rex = .{ .b = 0 },
//         .modr = .{ .rm = .{ .operand = 0 }, .reg = .{ .fixed = 5 } }
//     },
//     .{
//         .opcode = .{.other = &.{0x69} },
//         .operands = &.{.reg, .rm, .imm},
//         .rex = .{ .r = 0, .b = 1 },
//         .modr = .{ .rm = .{ .operand = 1 }, .reg = .{ .operand = 0 } },
//         .imm_max = 4,
//         .imm_min = 2,
//     },
//     .{
//         .opcode = .{.s16 = &.{0x6b}, .s32 = &.{0x6b}, .s64 = &.{0x6b}},
//         .operands = &.{.reg, .rm, .imm},
//         .rex = .{ .r = 0, .b = 1 },
//         .modr = .{ .rm = .{ .operand = 1 }, .reg = .{ .operand = 0 } },
//         .imm_max = 1,
//     }
// };
// pub fn generate_jcc(condition: u8) []const emitter.encoding{
//     return &.{
//         .{
//             .rex64 = false,
//             .opcode = .{.other = &.{0x0f, condition} },
//             .operands = &.{.imm},
//             .modr = .{ .rm = .none, .reg = .none },
//             .imm_max = 4,
//             .size = 4
//         }
//     };
// }

// pub fn generate_setcc(condition: u8) []const emitter.encoding{
//     return &.{
//        .{
//             .rex64 = false,
//             .opcode = .{.other = &.{0x0f, condition} },
//             .operands = &.{.rm},
//             .rex = .{.b = 0},
//             .modr = .{ .rm = .{. operand = 0}, .reg = .none },
//             .imm_max = 4,
//             .size = 4
//         }
//     };
// }
// pub const jcc = struct {
//     pub const ja    = 0x87;
//     pub const jae   = 0x83;
//     pub const jb    = 0x82;
//     pub const jbe   = 0x86;
//     pub const jc    = 0x82;
//     pub const je    = 0x84;
//     pub const jz    = 0x84;
//     pub const jg    = 0x8f;
//     pub const jge   = 0x8d;
//     pub const jl    = 0x8c;
//     pub const jle   = 0x8e;
//     pub const jna   = 0x86;
//     pub const jnae  = 0x82;
//     pub const jnb   = 0x83;
//     pub const jnbe  = 0x87;
//     pub const jnc   = 0x83;
//     pub const jne   = 0x85;
//     pub const jng   = 0x8e;
//     pub const jnge  = 0x8c;
//     pub const jnl   = 0x8d;
//     pub const jnle  = 0x8f;
//     pub const jno   = 0x81;
//     pub const jnp   = 0x8b;
//     pub const jns   = 0x89;
//     pub const jnz   = 0x85;
//     pub const jo    = 0x80;
//     pub const jp    = 0x8a;
//     pub const jpe   = 0x8a;
//     pub const jpo   = 0x8b;
//     pub const js    = 0x88;
// };

// pub const setcc = struct {
//     pub const a    = 0x97;
//     pub const ae   = 0x93;
//     pub const b    = 0x92;
//     pub const be   = 0x96;
//     pub const c    = 0x92;
//     pub const e    = 0x94;
//     pub const z    = 0x94;
//     pub const g    = 0x9f;
//     pub const ge   = 0x9d;
//     pub const l    = 0x9c;
//     pub const le   = 0x9e;
//     pub const na   = 0x96;
//     pub const nae  = 0x92;
//     pub const nb   = 0x93;
//     pub const nbe  = 0x97;
//     pub const nc   = 0x93;
//     pub const ne   = 0x95;
//     pub const ng   = 0x9e;
//     pub const nge  = 0x9c;
//     pub const nl   = 0x9d;
//     pub const nle  = 0x9f;
//     pub const no   = 0x91;
//     pub const np   = 0x9b;
//     pub const ns   = 0x99;
//     pub const nz   = 0x95;
//     pub const o    = 0x90;
//     pub const p    = 0x9a;
//     pub const pe   = 0x9a;
//     pub const po   = 0x9b;
//     pub const s    = 0x98;
// };

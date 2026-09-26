/// Describing registers and some pre defined ones 
pub const RegisterClass = enum{
    gpr,
    xmm,
};

const Size = @import("root.zig").Size;
pub const Register = struct{
    size: Size, 
    encoding: u8,
    rex: bool,
    class: RegisterClass,

    pub const rax = Register{ .size = Size.qword, .encoding = 0, .rex = false, .class = .gpr };
    pub const eax = Register{ .size = Size.dword, .encoding = 0, .rex = false, .class = .gpr };
    pub const ax  = Register{ .size = Size.word, .encoding = 0, .rex = false, .class = .gpr };
    pub const al  = Register{ .size = Size.byte, .encoding = 0, .rex = false, .class = .gpr };

    pub const rcx = Register{ .size = Size.qword, .encoding = 1, .rex = false, .class = .gpr };
    pub const ecx = Register{ .size = Size.dword, .encoding = 1, .rex = false, .class = .gpr };
    pub const cx  = Register{ .size = Size.word, .encoding = 1, .rex = false, .class = .gpr };
    pub const cl  = Register{ .size = Size.byte, .encoding = 1, .rex = false, .class = .gpr };

    pub const rdx = Register{ .size = Size.qword, .encoding = 2, .rex = false, .class = .gpr };
    pub const edx = Register{ .size = Size.dword, .encoding = 2, .rex = false, .class = .gpr };
    pub const dx  = Register{ .size = Size.word, .encoding = 2, .rex = false, .class = .gpr };
    pub const dl  = Register{ .size = Size.byte, .encoding = 2, .rex = false, .class = .gpr };

    pub const rbx = Register{ .size = Size.qword, .encoding = 3, .rex = false, .class = .gpr };
    pub const ebx = Register{ .size = Size.dword, .encoding = 3, .rex = false, .class = .gpr };
    pub const bx  = Register{ .size = Size.word, .encoding = 3, .rex = false, .class = .gpr };
    pub const bl  = Register{ .size = Size.byte, .encoding = 3, .rex = false, .class = .gpr };

    pub const rsp = Register{ .size = Size.qword, .encoding = 4, .rex = false, .class = .gpr };
    pub const esp = Register{ .size = Size.dword, .encoding = 4, .rex = false, .class = .gpr };
    pub const sp  = Register{ .size = Size.word, .encoding = 4, .rex = false, .class = .gpr };
    pub const spl = Register{ .size = Size.byte, .encoding = 4, .rex = false, .class = .gpr };

    pub const rbp = Register{ .size = Size.qword, .encoding = 5, .rex = false, .class = .gpr };
    pub const ebp = Register{ .size = Size.dword, .encoding = 5, .rex = false, .class = .gpr };
    pub const bp  = Register{ .size = Size.word, .encoding = 5, .rex = false, .class = .gpr };
    pub const bpl = Register{ .size = Size.byte, .encoding = 5, .rex = false, .class = .gpr };

    pub const rsi = Register{ .size = Size.qword, .encoding = 6, .rex = false, .class = .gpr };
    pub const esi = Register{ .size = Size.dword, .encoding = 6, .rex = false, .class = .gpr };
    pub const si  = Register{ .size = Size.word, .encoding = 6, .rex = false, .class = .gpr };
    pub const sil = Register{ .size = Size.byte, .encoding = 6, .rex = false, .class = .gpr };

    pub const rdi = Register{ .size = Size.qword, .encoding = 7, .rex = false, .class = .gpr };
    pub const edi = Register{ .size = Size.dword, .encoding = 7, .rex = false, .class = .gpr };
    pub const di  = Register{ .size = Size.word, .encoding = 7, .rex = false, .class = .gpr };
    pub const dil = Register{ .size = Size.byte, .encoding = 7, .rex = false, .class = .gpr };

    pub const r8  = Register{ .size = Size.qword, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8d = Register{ .size = Size.dword, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8w = Register{ .size = Size.word, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8b = Register{ .size = Size.byte, .encoding = 0, .rex = true, .class = .gpr };

    pub const r9  = Register{ .size = Size.qword, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9d = Register{ .size = Size.dword, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9w = Register{ .size = Size.word, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9b = Register{ .size = Size.byte, .encoding = 1, .rex = true, .class = .gpr };

    pub const r10  = Register{ .size = Size.qword, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10d = Register{ .size = Size.dword, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10w = Register{ .size = Size.word, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10b = Register{ .size = Size.byte, .encoding = 2, .rex = true, .class = .gpr };

    pub const r11  = Register{ .size = Size.qword, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11d = Register{ .size = Size.dword, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11w = Register{ .size = Size.word, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11b = Register{ .size = Size.byte, .encoding = 3, .rex = true, .class = .gpr };

    pub const r12  = Register{ .size = Size.qword, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12d = Register{ .size = Size.dword, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12w = Register{ .size = Size.word, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12b = Register{ .size = Size.byte, .encoding = 4, .rex = true, .class = .gpr };

    pub const r13  = Register{ .size = Size.qword, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13d = Register{ .size = Size.dword, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13w = Register{ .size = Size.word, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13b = Register{ .size = Size.byte, .encoding = 5, .rex = true, .class = .gpr };

    pub const r14  = Register{ .size = Size.qword, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14d = Register{ .size = Size.dword, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14w = Register{ .size = Size.word, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14b = Register{ .size = Size.byte, .encoding = 6, .rex = true, .class = .gpr };

    pub const r15  = Register{ .size = Size.qword, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15d = Register{ .size = Size.dword, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15w = Register{ .size = Size.word, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15b = Register{ .size = Size.byte, .encoding = 7, .rex = true, .class = .gpr };

    pub const xmm0 = Register{ .size = Size.oword, .encoding = 0, .rex = false, .class = .xmm };
    pub const xmm1 = Register{ .size = Size.oword, .encoding = 1, .rex = false, .class = .xmm };
    pub const xmm2 = Register{ .size = Size.oword, .encoding = 2, .rex = false, .class = .xmm };
    pub const xmm3 = Register{ .size = Size.oword, .encoding = 3, .rex = false, .class = .xmm };
    pub const xmm4 = Register{ .size = Size.oword, .encoding = 4, .rex = false, .class = .xmm };
    pub const xmm5 = Register{ .size = Size.oword, .encoding = 5, .rex = false, .class = .xmm };
    pub const xmm6 = Register{ .size = Size.oword, .encoding = 6, .rex = false, .class = .xmm };
    pub const xmm7 = Register{ .size = Size.oword, .encoding = 7, .rex = false, .class = .xmm };
    pub const xmm8 = Register{ .size = Size.oword, .encoding = 0, .rex = true, .class = .xmm };
    pub const xmm9 = Register{ .size = Size.oword, .encoding = 1, .rex = true, .class = .xmm };
    pub const xmm10 = Register{ .size = Size.oword, .encoding = 2, .rex = true, .class = .xmm };
    pub const xmm11 = Register{ .size = Size.oword, .encoding = 3, .rex = true, .class = .xmm };
    pub const xmm12 = Register{ .size = Size.oword, .encoding = 4, .rex = true, .class = .xmm };
    pub const xmm13 = Register{ .size = Size.oword, .encoding = 5, .rex = true, .class = .xmm };
    pub const xmm14 = Register{ .size = Size.oword, .encoding = 6, .rex = true, .class = .xmm };
    pub const xmm15 = Register{ .size = Size.oword, .encoding = 7, .rex = true, .class = .xmm };
};

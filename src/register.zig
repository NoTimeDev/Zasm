/// Describing registers and some pre defined ones 

pub const RegisterClass = enum{
    gpr,
    xmm,
};

pub const Register = struct{
    size: u8, 
    encoding: u8,
    rex: bool,
    class: RegisterClass,

    pub const rax = Register{ .size = 8, .encoding = 0, .rex = false, .class = .gpr };
    pub const eax = Register{ .size = 4, .encoding = 0, .rex = false, .class = .gpr };
    pub const ax  = Register{ .size = 2, .encoding = 0, .rex = false, .class = .gpr };
    pub const al  = Register{ .size = 1, .encoding = 0, .rex = false, .class = .gpr };

    pub const rcx = Register{ .size = 8, .encoding = 1, .rex = false, .class = .gpr };
    pub const ecx = Register{ .size = 4, .encoding = 1, .rex = false, .class = .gpr };
    pub const cx  = Register{ .size = 2, .encoding = 1, .rex = false, .class = .gpr };
    pub const cl  = Register{ .size = 1, .encoding = 1, .rex = false, .class = .gpr };

    pub const rdx = Register{ .size = 8, .encoding = 2, .rex = false, .class = .gpr };
    pub const edx = Register{ .size = 4, .encoding = 2, .rex = false, .class = .gpr };
    pub const dx  = Register{ .size = 2, .encoding = 2, .rex = false, .class = .gpr };
    pub const dl  = Register{ .size = 1, .encoding = 2, .rex = false, .class = .gpr };

    pub const rbx = Register{ .size = 8, .encoding = 3, .rex = false, .class = .gpr };
    pub const ebx = Register{ .size = 4, .encoding = 3, .rex = false, .class = .gpr };
    pub const bx  = Register{ .size = 2, .encoding = 3, .rex = false, .class = .gpr };
    pub const bl  = Register{ .size = 1, .encoding = 3, .rex = false, .class = .gpr };

    pub const rsp = Register{ .size = 8, .encoding = 4, .rex = false, .class = .gpr };
    pub const esp = Register{ .size = 4, .encoding = 4, .rex = false, .class = .gpr };
    pub const sp  = Register{ .size = 2, .encoding = 4, .rex = false, .class = .gpr };
    pub const spl = Register{ .size = 1, .encoding = 4, .rex = false, .class = .gpr };

    pub const rbp = Register{ .size = 8, .encoding = 5, .rex = false, .class = .gpr };
    pub const ebp = Register{ .size = 4, .encoding = 5, .rex = false, .class = .gpr };
    pub const bp  = Register{ .size = 2, .encoding = 5, .rex = false, .class = .gpr };
    pub const bpl = Register{ .size = 1, .encoding = 5, .rex = false, .class = .gpr };

    pub const rsi = Register{ .size = 8, .encoding = 6, .rex = false, .class = .gpr };
    pub const esi = Register{ .size = 4, .encoding = 6, .rex = false, .class = .gpr };
    pub const si  = Register{ .size = 2, .encoding = 6, .rex = false, .class = .gpr };
    pub const sil = Register{ .size = 1, .encoding = 6, .rex = false, .class = .gpr };

    pub const rdi = Register{ .size = 8, .encoding = 7, .rex = false, .class = .gpr };
    pub const edi = Register{ .size = 4, .encoding = 7, .rex = false, .class = .gpr };
    pub const di  = Register{ .size = 2, .encoding = 7, .rex = false, .class = .gpr };
    pub const dil = Register{ .size = 1, .encoding = 7, .rex = false, .class = .gpr };

    pub const r8  = Register{ .size = 8, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8d = Register{ .size = 4, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8w = Register{ .size = 2, .encoding = 0, .rex = true, .class = .gpr };
    pub const r8b = Register{ .size = 1, .encoding = 0, .rex = true, .class = .gpr };

    pub const r9  = Register{ .size = 8, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9d = Register{ .size = 4, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9w = Register{ .size = 2, .encoding = 1, .rex = true, .class = .gpr };
    pub const r9b = Register{ .size = 1, .encoding = 1, .rex = true, .class = .gpr };

    pub const r10  = Register{ .size = 8, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10d = Register{ .size = 4, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10w = Register{ .size = 2, .encoding = 2, .rex = true, .class = .gpr };
    pub const r10b = Register{ .size = 1, .encoding = 2, .rex = true, .class = .gpr };

    pub const r11  = Register{ .size = 8, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11d = Register{ .size = 4, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11w = Register{ .size = 2, .encoding = 3, .rex = true, .class = .gpr };
    pub const r11b = Register{ .size = 1, .encoding = 3, .rex = true, .class = .gpr };

    pub const r12  = Register{ .size = 8, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12d = Register{ .size = 4, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12w = Register{ .size = 2, .encoding = 4, .rex = true, .class = .gpr };
    pub const r12b = Register{ .size = 1, .encoding = 4, .rex = true, .class = .gpr };

    pub const r13  = Register{ .size = 8, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13d = Register{ .size = 4, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13w = Register{ .size = 2, .encoding = 5, .rex = true, .class = .gpr };
    pub const r13b = Register{ .size = 1, .encoding = 5, .rex = true, .class = .gpr };

    pub const r14  = Register{ .size = 8, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14d = Register{ .size = 4, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14w = Register{ .size = 2, .encoding = 6, .rex = true, .class = .gpr };
    pub const r14b = Register{ .size = 1, .encoding = 6, .rex = true, .class = .gpr };

    pub const r15  = Register{ .size = 8, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15d = Register{ .size = 4, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15w = Register{ .size = 2, .encoding = 7, .rex = true, .class = .gpr };
    pub const r15b = Register{ .size = 1, .encoding = 7, .rex = true, .class = .gpr };

    pub const xmm0 = Register{ .size = 16, .encoding = 0, .rex = false, .class = .xmm };
    pub const xmm1 = Register{ .size = 16, .encoding = 1, .rex = false, .class = .xmm };
    pub const xmm2 = Register{ .size = 16, .encoding = 2, .rex = false, .class = .xmm };
    pub const xmm3 = Register{ .size = 16, .encoding = 3, .rex = false, .class = .xmm };
    pub const xmm4 = Register{ .size = 16, .encoding = 4, .rex = false, .class = .xmm };
    pub const xmm5 = Register{ .size = 16, .encoding = 5, .rex = false, .class = .xmm };
    pub const xmm6 = Register{ .size = 16, .encoding = 6, .rex = false, .class = .xmm };
    pub const xmm7 = Register{ .size = 16, .encoding = 7, .rex = false, .class = .xmm };
    pub const xmm8 = Register{ .size = 16, .encoding = 0, .rex = true, .class = .xmm };
    pub const xmm9 = Register{ .size = 16, .encoding = 1, .rex = true, .class = .xmm };
    pub const xmm10 = Register{ .size = 16, .encoding = 2, .rex = true, .class = .xmm };
    pub const xmm11 = Register{ .size = 16, .encoding = 3, .rex = true, .class = .xmm };
    pub const xmm12 = Register{ .size = 16, .encoding = 4, .rex = true, .class = .xmm };
    pub const xmm13 = Register{ .size = 16, .encoding = 5, .rex = true, .class = .xmm };
    pub const xmm14 = Register{ .size = 16, .encoding = 6, .rex = true, .class = .xmm };
    pub const xmm15 = Register{ .size = 16, .encoding = 7, .rex = true, .class = .xmm };
};

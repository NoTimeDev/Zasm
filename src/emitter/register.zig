pub const Register = struct{
    size: u8, 
    encoding: u8,
    rex: bool,

    pub const rax = Register{ .size = 8, .encoding = 0, .rex = false };
    pub const eax = Register{ .size = 4, .encoding = 0, .rex = false };
    pub const ax  = Register{ .size = 2, .encoding = 0, .rex = false };
    pub const al  = Register{ .size = 1, .encoding = 0, .rex = false };

    pub const rcx = Register{ .size = 8, .encoding = 1, .rex = false };
    pub const ecx = Register{ .size = 4, .encoding = 1, .rex = false };
    pub const cx  = Register{ .size = 2, .encoding = 1, .rex = false };
    pub const cl  = Register{ .size = 1, .encoding = 1, .rex = false };

    pub const rdx = Register{ .size = 8, .encoding = 2, .rex = false };
    pub const edx = Register{ .size = 4, .encoding = 2, .rex = false };
    pub const dx  = Register{ .size = 2, .encoding = 2, .rex = false };
    pub const dl  = Register{ .size = 1, .encoding = 2, .rex = false };

    pub const rbx = Register{ .size = 8, .encoding = 3, .rex = false };
    pub const ebx = Register{ .size = 4, .encoding = 3, .rex = false };
    pub const bx  = Register{ .size = 2, .encoding = 3, .rex = false };
    pub const bl  = Register{ .size = 1, .encoding = 3, .rex = false };

    pub const rsp = Register{ .size = 8, .encoding = 4, .rex = false };
    pub const esp = Register{ .size = 4, .encoding = 4, .rex = false };
    pub const sp  = Register{ .size = 2, .encoding = 4, .rex = false };
    pub const spl = Register{ .size = 1, .encoding = 4, .rex = false };

    pub const rbp = Register{ .size = 8, .encoding = 5, .rex = false };
    pub const ebp = Register{ .size = 4, .encoding = 5, .rex = false };
    pub const bp  = Register{ .size = 2, .encoding = 5, .rex = false };
    pub const bpl = Register{ .size = 1, .encoding = 5, .rex = false };

    pub const rsi = Register{ .size = 8, .encoding = 6, .rex = false };
    pub const esi = Register{ .size = 4, .encoding = 6, .rex = false };
    pub const si  = Register{ .size = 2, .encoding = 6, .rex = false };
    pub const sil = Register{ .size = 1, .encoding = 6, .rex = false };

    pub const rdi = Register{ .size = 8, .encoding = 7, .rex = false };
    pub const edi = Register{ .size = 4, .encoding = 7, .rex = false };
    pub const di  = Register{ .size = 2, .encoding = 7, .rex = false };
    pub const dil = Register{ .size = 1, .encoding = 7, .rex = false };

    pub const r8  = Register{ .size = 8, .encoding = 0, .rex = true };
    pub const r8d = Register{ .size = 4, .encoding = 0, .rex = true };
    pub const r8w = Register{ .size = 2, .encoding = 0, .rex = true };
    pub const r8b = Register{ .size = 1, .encoding = 0, .rex = true };

    pub const r9  = Register{ .size = 8, .encoding = 1, .rex = true };
    pub const r9d = Register{ .size = 4, .encoding = 1, .rex = true };
    pub const r9w = Register{ .size = 2, .encoding = 1, .rex = true };
    pub const r9b = Register{ .size = 1, .encoding = 1, .rex = true };

    pub const r10  = Register{ .size = 8, .encoding = 2, .rex = true };
    pub const r10d = Register{ .size = 4, .encoding = 2, .rex = true };
    pub const r10w = Register{ .size = 2, .encoding = 2, .rex = true };
    pub const r10b = Register{ .size = 1, .encoding = 2, .rex = true };

    pub const r11  = Register{ .size = 8, .encoding = 3, .rex = true };
    pub const r11d = Register{ .size = 4, .encoding = 3, .rex = true };
    pub const r11w = Register{ .size = 2, .encoding = 3, .rex = true };
    pub const r11b = Register{ .size = 1, .encoding = 3, .rex = true };

    pub const r12  = Register{ .size = 8, .encoding = 4, .rex = true };
    pub const r12d = Register{ .size = 4, .encoding = 4, .rex = true };
    pub const r12w = Register{ .size = 2, .encoding = 4, .rex = true };
    pub const r12b = Register{ .size = 1, .encoding = 4, .rex = true };

    pub const r13  = Register{ .size = 8, .encoding = 5, .rex = true };
    pub const r13d = Register{ .size = 4, .encoding = 5, .rex = true };
    pub const r13w = Register{ .size = 2, .encoding = 5, .rex = true };
    pub const r13b = Register{ .size = 1, .encoding = 5, .rex = true };

    pub const r14  = Register{ .size = 8, .encoding = 6, .rex = true };
    pub const r14d = Register{ .size = 4, .encoding = 6, .rex = true };
    pub const r14w = Register{ .size = 2, .encoding = 6, .rex = true };
    pub const r14b = Register{ .size = 1, .encoding = 6, .rex = true };

    pub const r15  = Register{ .size = 8, .encoding = 7, .rex = true };
    pub const r15d = Register{ .size = 4, .encoding = 7, .rex = true };
    pub const r15w = Register{ .size = 2, .encoding = 7, .rex = true };
    pub const r15b = Register{ .size = 1, .encoding = 7, .rex = true };
};


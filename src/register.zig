/// Describing registers and some pre defined ones 
pub const RegisterClass = enum{
    gpr,
    mmx,
    xmm,
    zmm,
    ymm,
    x87,
};

const Size = @import("root.zig").Size;
pub const Register = struct{
    size: Size, 
    encoding: u5,
    class: RegisterClass,

    pub const rax = Register{ .size = Size.qword, .encoding = 0,  .class = .gpr };
    pub const eax = Register{ .size = Size.dword, .encoding = 0,  .class = .gpr };
    pub const ax  = Register{ .size = Size.word,  .encoding = 0,  .class = .gpr };
    pub const al  = Register{ .size = Size.byte,  .encoding = 0,  .class = .gpr };

    pub const rcx = Register{ .size = Size.qword, .encoding = 1,  .class = .gpr };
    pub const ecx = Register{ .size = Size.dword, .encoding = 1,  .class = .gpr };
    pub const cx  = Register{ .size = Size.word,  .encoding = 1,  .class = .gpr };
    pub const cl  = Register{ .size = Size.byte,  .encoding = 1,  .class = .gpr };

    pub const rdx = Register{ .size = Size.qword, .encoding = 2,  .class = .gpr };
    pub const edx = Register{ .size = Size.dword, .encoding = 2,  .class = .gpr };
    pub const dx  = Register{ .size = Size.word,  .encoding = 2,  .class = .gpr };
    pub const dl  = Register{ .size = Size.byte,  .encoding = 2,  .class = .gpr };

    pub const rbx = Register{ .size = Size.qword, .encoding = 3,  .class = .gpr };
    pub const ebx = Register{ .size = Size.dword, .encoding = 3,  .class = .gpr };
    pub const bx  = Register{ .size = Size.word,  .encoding = 3,  .class = .gpr };
    pub const bl  = Register{ .size = Size.byte,  .encoding = 3,  .class = .gpr };

    pub const rsp = Register{ .size = Size.qword, .encoding = 4,  .class = .gpr };
    pub const esp = Register{ .size = Size.dword, .encoding = 4,  .class = .gpr };
    pub const sp  = Register{ .size = Size.word,  .encoding = 4,  .class = .gpr };
    pub const spl = Register{ .size = Size.byte,  .encoding = 4,  .class = .gpr };

    pub const rbp = Register{ .size = Size.qword, .encoding = 5,  .class = .gpr };
    pub const ebp = Register{ .size = Size.dword, .encoding = 5,  .class = .gpr };
    pub const bp  = Register{ .size = Size.word,  .encoding = 5,  .class = .gpr };
    pub const bpl = Register{ .size = Size.byte,  .encoding = 5,  .class = .gpr };

    pub const rsi = Register{ .size = Size.qword, .encoding = 6,  .class = .gpr };
    pub const esi = Register{ .size = Size.dword, .encoding = 6,  .class = .gpr };
    pub const si  = Register{ .size = Size.word,  .encoding = 6,  .class = .gpr };
    pub const sil = Register{ .size = Size.byte,  .encoding = 6,  .class = .gpr };

    pub const rdi = Register{ .size = Size.qword, .encoding = 7,  .class = .gpr };
    pub const edi = Register{ .size = Size.dword, .encoding = 7,  .class = .gpr };
    pub const di  = Register{ .size = Size.word,  .encoding = 7,  .class = .gpr };
    pub const dil = Register{ .size = Size.byte,  .encoding = 7,  .class = .gpr };

    pub const r8  = Register{ .size = Size.qword, .encoding = 8,  .class = .gpr };
    pub const r8d = Register{ .size = Size.dword, .encoding = 8,  .class = .gpr };
    pub const r8w = Register{ .size = Size.word,  .encoding = 8,  .class = .gpr };
    pub const r8b = Register{ .size = Size.byte,  .encoding = 8,  .class = .gpr };

    pub const r9  = Register{ .size = Size.qword, .encoding = 9,  .class = .gpr };
    pub const r9d = Register{ .size = Size.dword, .encoding = 9,  .class = .gpr };
    pub const r9w = Register{ .size = Size.word,  .encoding = 9,  .class = .gpr };
    pub const r9b = Register{ .size = Size.byte,  .encoding = 9,  .class = .gpr };

    pub const r10  = Register{ .size = Size.qword, .encoding = 10, .class = .gpr };
    pub const r10d = Register{ .size = Size.dword, .encoding = 10, .class = .gpr };
    pub const r10w = Register{ .size = Size.word,  .encoding = 10, .class = .gpr };
    pub const r10b = Register{ .size = Size.byte,  .encoding = 10, .class = .gpr };

    pub const r11  = Register{ .size = Size.qword, .encoding = 11, .class = .gpr };
    pub const r11d = Register{ .size = Size.dword, .encoding = 11, .class = .gpr };
    pub const r11w = Register{ .size = Size.word,  .encoding = 11, .class = .gpr };
    pub const r11b = Register{ .size = Size.byte,  .encoding = 11, .class = .gpr };

    pub const r12  = Register{ .size = Size.qword, .encoding = 12, .class = .gpr };
    pub const r12d = Register{ .size = Size.dword, .encoding = 12, .class = .gpr };
    pub const r12w = Register{ .size = Size.word,  .encoding = 12, .class = .gpr };
    pub const r12b = Register{ .size = Size.byte,  .encoding = 12, .class = .gpr };

    pub const r13  = Register{ .size = Size.qword, .encoding = 13, .class = .gpr };
    pub const r13d = Register{ .size = Size.dword, .encoding = 13, .class = .gpr };
    pub const r13w = Register{ .size = Size.word,  .encoding = 13, .class = .gpr };
    pub const r13b = Register{ .size = Size.byte,  .encoding = 13, .class = .gpr };

    pub const r14  = Register{ .size = Size.qword, .encoding = 14, .class = .gpr };
    pub const r14d = Register{ .size = Size.dword, .encoding = 14, .class = .gpr };
    pub const r14w = Register{ .size = Size.word,  .encoding = 14, .class = .gpr };
    pub const r14b = Register{ .size = Size.byte,  .encoding = 14, .class = .gpr };

    pub const r15  = Register{ .size = Size.qword, .encoding = 15, .class = .gpr };
    pub const r15d = Register{ .size = Size.dword, .encoding = 15, .class = .gpr };
    pub const r15w = Register{ .size = Size.word,  .encoding = 15, .class = .gpr };
    pub const r15b = Register{ .size = Size.byte,  .encoding = 15, .class = .gpr };


    pub const mm0 = Register{ .size = Size.qword, .encoding = 0, .class = .mmx };
    pub const mm1 = Register{ .size = Size.qword, .encoding = 1, .class = .mmx };
    pub const mm2 = Register{ .size = Size.qword, .encoding = 2, .class = .mmx };
    pub const mm3 = Register{ .size = Size.qword, .encoding = 3, .class = .mmx };
    pub const mm4 = Register{ .size = Size.qword, .encoding = 4, .class = .mmx };
    pub const mm5 = Register{ .size = Size.qword, .encoding = 5, .class = .mmx };
    pub const mm6 = Register{ .size = Size.qword, .encoding = 6, .class = .mmx };
    pub const mm7 = Register{ .size = Size.qword, .encoding = 7, .class = .mmx };
    
    pub const st1 = Register{ .size = Size.tbyte, .encoding = 1, .class = .x87 };
    pub const st2 = Register{ .size = Size.tbyte, .encoding = 2, .class = .x87 };
    pub const st3 = Register{ .size = Size.tbyte, .encoding = 3, .class = .x87 };
    pub const st4 = Register{ .size = Size.tbyte, .encoding = 4, .class = .x87 };
    pub const st5 = Register{ .size = Size.tbyte, .encoding = 5, .class = .x87 };
    pub const st6 = Register{ .size = Size.tbyte, .encoding = 6, .class = .x87 };
    pub const st7 = Register{ .size = Size.tbyte, .encoding = 7, .class = .x87 };
    
    pub const xmm0  = Register{ .size = Size.oword, .encoding = 0,  .class = .xmm };
    pub const xmm1  = Register{ .size = Size.oword, .encoding = 1,  .class = .xmm };
    pub const xmm2  = Register{ .size = Size.oword, .encoding = 2,  .class = .xmm };
    pub const xmm3  = Register{ .size = Size.oword, .encoding = 3,  .class = .xmm };
    pub const xmm4  = Register{ .size = Size.oword, .encoding = 4,  .class = .xmm };
    pub const xmm5  = Register{ .size = Size.oword, .encoding = 5,  .class = .xmm };
    pub const xmm6  = Register{ .size = Size.oword, .encoding = 6,  .class = .xmm };
    pub const xmm7  = Register{ .size = Size.oword, .encoding = 7,  .class = .xmm };
    pub const xmm8  = Register{ .size = Size.oword, .encoding = 8,  .class = .xmm };
    pub const xmm9  = Register{ .size = Size.oword, .encoding = 9,  .class = .xmm };
    pub const xmm10 = Register{ .size = Size.oword, .encoding = 10, .class = .xmm };
    pub const xmm11 = Register{ .size = Size.oword, .encoding = 11, .class = .xmm };
    pub const xmm12 = Register{ .size = Size.oword, .encoding = 12, .class = .xmm };
    pub const xmm13 = Register{ .size = Size.oword, .encoding = 13, .class = .xmm };
    pub const xmm14 = Register{ .size = Size.oword, .encoding = 14, .class = .xmm };
    pub const xmm15 = Register{ .size = Size.oword, .encoding = 15, .class = .xmm };
    pub const xmm16 = Register{ .size = Size.oword, .encoding = 16, .class = .xmm };
    pub const xmm17 = Register{ .size = Size.oword, .encoding = 17, .class = .xmm };
    pub const xmm18 = Register{ .size = Size.oword, .encoding = 18, .class = .xmm };
    pub const xmm19 = Register{ .size = Size.oword, .encoding = 19, .class = .xmm };
    pub const xmm20 = Register{ .size = Size.oword, .encoding = 20, .class = .xmm };
    pub const xmm21 = Register{ .size = Size.oword, .encoding = 21, .class = .xmm };
    pub const xmm22 = Register{ .size = Size.oword, .encoding = 22, .class = .xmm };
    pub const xmm23 = Register{ .size = Size.oword, .encoding = 23, .class = .xmm };
    pub const xmm24 = Register{ .size = Size.oword, .encoding = 24, .class = .xmm };
    pub const xmm25 = Register{ .size = Size.oword, .encoding = 25, .class = .xmm };
    pub const xmm26 = Register{ .size = Size.oword, .encoding = 26, .class = .xmm };
    pub const xmm27 = Register{ .size = Size.oword, .encoding = 27, .class = .xmm };
    pub const xmm28 = Register{ .size = Size.oword, .encoding = 28, .class = .xmm };
    pub const xmm29 = Register{ .size = Size.oword, .encoding = 29, .class = .xmm };
    pub const xmm30 = Register{ .size = Size.oword, .encoding = 30, .class = .xmm };
    pub const xmm31 = Register{ .size = Size.oword, .encoding = 31, .class = .xmm };

    pub const ymm0  = Register{ .size = Size.yword, .encoding = 0,  .class = .ymm };
    pub const ymm1  = Register{ .size = Size.yword, .encoding = 1,  .class = .ymm };
    pub const ymm2  = Register{ .size = Size.yword, .encoding = 2,  .class = .ymm };
    pub const ymm3  = Register{ .size = Size.yword, .encoding = 3,  .class = .ymm };
    pub const ymm4  = Register{ .size = Size.yword, .encoding = 4,  .class = .ymm };
    pub const ymm5  = Register{ .size = Size.yword, .encoding = 5,  .class = .ymm };
    pub const ymm6  = Register{ .size = Size.yword, .encoding = 6,  .class = .ymm };
    pub const ymm7  = Register{ .size = Size.yword, .encoding = 7,  .class = .ymm };
    pub const ymm8  = Register{ .size = Size.yword, .encoding = 8,  .class = .ymm };
    pub const ymm9  = Register{ .size = Size.yword, .encoding = 9,  .class = .ymm };
    pub const ymm10 = Register{ .size = Size.yword, .encoding = 10, .class = .ymm };
    pub const ymm11 = Register{ .size = Size.yword, .encoding = 11, .class = .ymm };
    pub const ymm12 = Register{ .size = Size.yword, .encoding = 12, .class = .ymm };
    pub const ymm13 = Register{ .size = Size.yword, .encoding = 13, .class = .ymm };
    pub const ymm14 = Register{ .size = Size.yword, .encoding = 14, .class = .ymm };
    pub const ymm15 = Register{ .size = Size.yword, .encoding = 15, .class = .ymm };
    pub const ymm16 = Register{ .size = Size.yword, .encoding = 16, .class = .ymm };
    pub const ymm17 = Register{ .size = Size.yword, .encoding = 17, .class = .ymm };
    pub const ymm18 = Register{ .size = Size.yword, .encoding = 18, .class = .ymm };
    pub const ymm19 = Register{ .size = Size.yword, .encoding = 19, .class = .ymm };
    pub const ymm20 = Register{ .size = Size.yword, .encoding = 20, .class = .ymm };
    pub const ymm21 = Register{ .size = Size.yword, .encoding = 21, .class = .ymm };
    pub const ymm22 = Register{ .size = Size.yword, .encoding = 22, .class = .ymm };
    pub const ymm23 = Register{ .size = Size.yword, .encoding = 23, .class = .ymm };
    pub const ymm24 = Register{ .size = Size.yword, .encoding = 24, .class = .ymm };
    pub const ymm25 = Register{ .size = Size.yword, .encoding = 25, .class = .ymm };
    pub const ymm26 = Register{ .size = Size.yword, .encoding = 26, .class = .ymm };
    pub const ymm27 = Register{ .size = Size.yword, .encoding = 27, .class = .ymm };
    pub const ymm28 = Register{ .size = Size.yword, .encoding = 28, .class = .ymm };
    pub const ymm29 = Register{ .size = Size.yword, .encoding = 29, .class = .ymm };
    pub const ymm30 = Register{ .size = Size.yword, .encoding = 30, .class = .ymm };
    pub const ymm31 = Register{ .size = Size.yword, .encoding = 31, .class = .ymm };

    pub const zmm0  = Register{ .size = Size.zword, .encoding = 0,  .class = .zmm };
    pub const zmm1  = Register{ .size = Size.zword, .encoding = 1,  .class = .zmm };
    pub const zmm2  = Register{ .size = Size.zword, .encoding = 2,  .class = .zmm };
    pub const zmm3  = Register{ .size = Size.zword, .encoding = 3,  .class = .zmm };
    pub const zmm4  = Register{ .size = Size.zword, .encoding = 4,  .class = .zmm };
    pub const zmm5  = Register{ .size = Size.zword, .encoding = 5,  .class = .zmm };
    pub const zmm6  = Register{ .size = Size.zword, .encoding = 6,  .class = .zmm };
    pub const zmm7  = Register{ .size = Size.zword, .encoding = 7,  .class = .zmm };
    pub const zmm8  = Register{ .size = Size.zword, .encoding = 8,  .class = .zmm };
    pub const zmm9  = Register{ .size = Size.zword, .encoding = 9,  .class = .zmm };
    pub const zmm10 = Register{ .size = Size.zword, .encoding = 10, .class = .zmm };
    pub const zmm11 = Register{ .size = Size.zword, .encoding = 11, .class = .zmm };
    pub const zmm12 = Register{ .size = Size.zword, .encoding = 12, .class = .zmm };
    pub const zmm13 = Register{ .size = Size.zword, .encoding = 13, .class = .zmm };
    pub const zmm14 = Register{ .size = Size.zword, .encoding = 14, .class = .zmm };
    pub const zmm15 = Register{ .size = Size.zword, .encoding = 15, .class = .zmm };
    pub const zmm16 = Register{ .size = Size.zword, .encoding = 16, .class = .zmm };
    pub const zmm17 = Register{ .size = Size.zword, .encoding = 17, .class = .zmm };
    pub const zmm18 = Register{ .size = Size.zword, .encoding = 18, .class = .zmm };
    pub const zmm19 = Register{ .size = Size.zword, .encoding = 19, .class = .zmm };
    pub const zmm20 = Register{ .size = Size.zword, .encoding = 20, .class = .zmm };
    pub const zmm21 = Register{ .size = Size.zword, .encoding = 21, .class = .zmm };
    pub const zmm22 = Register{ .size = Size.zword, .encoding = 22, .class = .zmm };
    pub const zmm23 = Register{ .size = Size.zword, .encoding = 23, .class = .zmm };
    pub const zmm24 = Register{ .size = Size.zword, .encoding = 24, .class = .zmm };
    pub const zmm25 = Register{ .size = Size.zword, .encoding = 25, .class = .zmm };
    pub const zmm26 = Register{ .size = Size.zword, .encoding = 26, .class = .zmm };
    pub const zmm27 = Register{ .size = Size.zword, .encoding = 27, .class = .zmm };
    pub const zmm28 = Register{ .size = Size.zword, .encoding = 28, .class = .zmm };
    pub const zmm29 = Register{ .size = Size.zword, .encoding = 29, .class = .zmm };
    pub const zmm30 = Register{ .size = Size.zword, .encoding = 30, .class = .zmm };
    pub const zmm31 = Register{ .size = Size.zword, .encoding = 31, .class = .zmm };
};

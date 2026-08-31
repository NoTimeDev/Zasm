/// Errors used by the package 
pub const AsmError = error{
    MprotectFailed,
    SizeMisMatch,
    OperandMisMatch,
    RelOutOfRange,
    NonGPRInMem,
};

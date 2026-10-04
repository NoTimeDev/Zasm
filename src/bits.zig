///! Helper fuctions to manipulate bits 

/// Sets a bit in a u8 to 1 or 0 
pub fn setBit(value: *u8, bit: u3, to: u1) void {
    const mask = @as(u8, 1) << bit;
    if (to == 1)
        value.* |= mask
    else
        value.* &= ~mask;
}

/// Gets a bit from a u8 
pub inline fn getBit(value: u8, index: u3) u1 {
    return @truncate(value >> index);
}

/// Helper function to create rex
pub inline fn create_rex(w: u1, r: u1, x: u1, b: u1) u8{
    return 0b01000000
        | (@as(u8, w) << 3)
        | (@as(u8, r) << 2)
        | (@as(u8, x) << 1)
        | @as(u8, b);
}

/// Gets the rex bit from a register(u5)
pub inline fn get_rex(reg: u5) u1{
    return @truncate(reg >> 3);
}

/// Gets evex extension bit
pub inline fn get_evex(reg: u5) u1{
    return @truncate(reg >> 4);
}


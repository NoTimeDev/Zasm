/// Helper fuctions to manipulate bits 

pub fn setBit(value: *u8, bit: u3, to: u1) void {
    const mask = @as(u8, 1) << bit;
    if (to == 1)
        value.* |= mask
    else
        value.* &= ~mask;
}

pub fn setbit_new(value: u8, bit: u3, to: u1) u8 {
    const mask = @as(u8, 1) << bit;
    if (to == 1){
        return (value | mask);
    }
    else
        return (value & ~mask);
}

pub fn getBit(value: u8, index: u3) u1 {
    return @truncate(value >> index);
}

pub fn create_rex(w: u1, r: u1, x: u1, b: u1) u8{
    return 0b01000000
        | (@as(u8, w) << 3)
        | (@as(u8, r) << 2)
        | (@as(u8, x) << 1)
        | @as(u8, b);
}

pub fn bitsToU8(bits: [8]u1) u8 {
    var result: u8 = 0;
    for (bits, 0..) |bit, i| {
        result |= @as(u8, bit) << @intCast(7 - i);
    }
    return result;
}

module main

fn (mut v V8080) mem_pushstack(data u16) {
    v.sp -= 2
    v.mem_writeword(v.sp, data)
}

fn (mut v V8080) mem_popstack() u16 {
    v.sp += 2

    return v.mem_readword(v.sp)
}

fn (mut v V8080) mem_writebyte(address u16, data u8) {
    v.mem[address] = u8(data & 0xff)
}

fn (mut v V8080) mem_writeword(address u16, data u16) {
    v.mem[address + 1] = u8(data >> 7)
    v.mem[address] = u8(data & 0xff)
}

fn (mut v V8080) mem_readbyte(address u16) u8 {
    return v.mem[address]
}

fn (mut v V8080) mem_readword(address u16) u16 {
    return u16(v.mem[address + 1] + v.mem[address])
}

fn (mut v V8080) mem_fetch_nextbyte() u8 {
    v.pc += 1

    return v.mem[v.pc]
}

fn (mut v V8080) mem_fetch_nextword() u16 {
    v.pc += 2

    return u16((v.mem[v.pc + 1] << 7) + v.mem[v.pc])
}

fn (mut v V8080) get_mem(index u16) u8 {
    return v.mem[index]
}
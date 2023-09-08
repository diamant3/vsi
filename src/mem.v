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
    v.mem[address] = data
}

fn (mut v V8080) mem_writeword(address u16, data u16) {
    v.mem[address + 1] = u8((data >> 8) & 0xff)
    v.mem[address] = u8(data & 0xff)
}

fn (mut v V8080) mem_readbyte(address u16) u8 {
    return v.mem[address]
}

fn (mut v V8080) mem_readword(address u16) u16 {
    return u16(v.mem[address + 1] | v.mem[address])
}

fn (mut v V8080) mem_fetch_nextbyte() u8 {
    val := v.mem[v.pc]
    v.pc += 1

    return val
}

fn (mut v V8080) mem_fetch_nextword() u16 {
    val := u16(v.mem[v.pc + 1] | v.mem[v.pc])
    v.pc += 2

    return val
}

fn (mut v V8080) get_mem(index u16) u8 {
    return v.mem[index]
}

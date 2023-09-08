module main

fn (mut v V8080) util_setreg_b(data u8) {
    v.reg.b = data
    v.reg.bc = u16(v.reg.b | v.reg.c)
}

fn (mut v V8080) util_setreg_c(data u8) {
    v.reg.c = data
    v.reg.bc = u16(v.reg.b | v.reg.c)
}

fn (mut v V8080) util_setreg_d(data u8) {
    v.reg.d = data
    v.reg.de = u16(v.reg.d | v.reg.e)
}

fn (mut v V8080) util_setreg_e(data u8) {
    v.reg.e = data
    v.reg.de = u16(v.reg.d | v.reg.e)
}

fn (mut v V8080) util_setreg_h(data u8) {
    v.reg.h = data
    v.reg.hl = u16(v.reg.h | v.reg.l)
}

fn (mut v V8080) util_setreg_l(data u8) {
    v.reg.l = data
    v.reg.hl = u16(v.reg.h | v.reg.l)
}

fn (mut v V8080) util_setreg_bc(data u16) {
    v.reg.bc = data
    v.reg.b = u8(v.reg.bc >> 8) & 0xff
    v.reg.c = u8(v.reg.bc & 0xff)
}

fn (mut v V8080) util_setreg_de(data u16) {
    v.reg.de = data
    v.reg.d = u8(v.reg.de >> 8) & 0xff
    v.reg.e = u8(v.reg.de & 0xff)
}

fn (mut v V8080) util_setreg_hl(data u16) {
    v.reg.hl = data
    v.reg.h = u8(v.reg.hl >> 8) & 0xff
    v.reg.l = u8(v.reg.hl & 0xff)
}

fn (mut v V8080) util_addreg_hl(data u16) {
    val := u16(v.reg.hl + data)
    v.util_setreg_hl(val)
    if val > 0xffff {
        v.flag.cf = true
    }
}

fn (mut v V8080) util_inc(data u8) u8 {
    val := data + 1
    v.flag.zf = if val == 0 { true } else { false }
    v.flag.sf = if (val & 0x80) > 0 { true } else { false }
    v.flag.af = if data == 0xf { true } else { false }
    v.flag.pf = if (val % 2) == 0 { true } else { false }

    return val
}

fn (mut v V8080) util_dec(data u8) u8 {
    val := data - 1
    v.flag.zf = if val == 0 { true } else { false }
    v.flag.sf = if (val & 0x80) > 0 { true } else { false }
    v.flag.af = if (data & 0x0f) == 0 { true } else { false }
    v.flag.pf = if (val % 2) == 0 { true } else { false }

    return val
}

fn (mut v V8080) util_and(val u8) {
    if val > 0xff {
        println("Bitwise AND value error")
        exit(1)
    }

    v.reg.a &= val
    v.flag.cf = true
    v.flag.zf = if v.reg.a == 0 { true } else { false }
    v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
    v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_xor(val u8) {
    v.reg.a ^= v.reg.a
    v.flag.cf = false
    v.flag.zf = if v.reg.a == 0 { true } else { false }
    v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
    v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_or(val u8) {
    v.reg.a |= v.reg.a
    v.flag.cf = false
    v.flag.zf = if v.reg.a == 0 { true } else { false }
    v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
    v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_add(in_val u8) {
    val := v.reg.a + in_val

    result := (((v.reg.a ^ val) ^ in_val) & 0x10)
    v.flag.af = if result > 0 { true } else { false }

    v.reg.a = val
    v.flag.cf = if (val > 0xff) || (val < 0) { true } else { false }
    v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
    v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_add_c(in_val u8) {
    carry := u8(if v.flag.cf { 1 } else { 0 })

    val := v.reg.a + in_val + carry

    result := (((v.reg.a ^ val) ^ in_val) & 0x10)
    v.flag.af = if result > 0 { true } else { false }

    v.reg.a = val
    v.flag.cf = if (val > 0xff) || (val < 0) { true } else { false }
    v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
    v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_sub(in_val u8) {
    val := v.reg.a - in_val

    result := u8(((v.reg.a ^ val) ^ in_val) & 0x10)
    v.flag.af = if result > 0 { true } else { false }

    v.reg.a = val
    v.flag.cf = if (val > 0xff) || (val < 0) { true } else { false }
    v.flag.sf = if (val & 0x80) > 0 { true } else { false }
    v.flag.pf = if (val % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_sub_c(in_val u8) {
    carry := u8(if v.flag.cf { 1 } else { 0 })

    val := v.reg.a - in_val + carry

    result := (((v.reg.a ^ val) ^ in_val) & 0x10)
    v.flag.af = if result > 0 { true } else { false }

    v.reg.a = val
    v.flag.cf = if (val > 0xff) || (val < 0) { true } else { false }
    v.flag.sf = if (val & 0x80) > 0 { true } else { false }
    v.flag.pf = if (val % 2) == 0 { true } else { false }
}

fn (mut v V8080) util_cmpsub(in_val u8) {
    val := v.reg.a - in_val

    v.flag.cf = if (val >= 0xff) || (val < 0) { true } else { false }

    result := (((v.reg.a ^ val) ^ in_val) & 0x10)
    v.flag.af = if result > 0 { true } else { false }
    v.flag.zf = if val == 0 { true } else { false }
    v.flag.sf = if (val & 0x80)  > 0 { true } else { false }
    v.flag.pf = if (val % 2) == 0 { true } else { false } 
}

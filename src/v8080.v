module main

import os

struct Flag {
mut:
    sf bool
    zf bool
    af bool
    pf bool
    cf bool
}

struct Reg {
mut:
    a u8
    b u8
    c u8
    d u8
    e u8
    h u8
    l u8
    bc u16
    de u16
    hl u16
}

pub struct V8080 {
pub mut:
    pc u16
    sp u16
    mem []u8
    reg &Reg = unsafe { nil }
    flag &Flag = unsafe { nil }
    port &Port = unsafe { nil }
    interrupt_enable bool
}

fn (mut v V8080) exec_ins() {
    opcode := v.mem_fetch_nextbyte()

    match u8(opcode) {
        0x0 { println("NOP") }
        0x1 { v.util_setreg_bc(v.mem_fetch_nextword()) }
        0x2 { v.mem_writebyte(v.reg.bc, v.reg.a) }
        0x3 { v.util_setreg_bc(v.reg.bc + 1) }
        0x4 { v.util_setreg_b(v.util_inc(v.reg.b)) }
        0x5 { v.util_setreg_b(v.util_dec(v.reg.b)) }
        0x6 { v.util_setreg_b(v.mem_fetch_nextbyte()) }
        0x7 {
            v.flag.cf = if (v.reg.a >> 0x4) == 0x1 { true } else { false }
            v.reg.a = u8((v.reg.a << 1) + (v.reg.a >> 0x7))
        
        }
        0x8 { println("ToImplement") }
        0x9 { v.util_addreg_hl(v.reg.bc) }
        0xa { v.reg.a = v.mem_readbyte(v.reg.bc) }
        0xb { v.util_setreg_bc(v.reg.bc - 1) }
        0xc { v.util_setreg_c(v.util_inc(v.reg.c)) }
        0xd { v.util_setreg_c(v.util_dec(v.reg.c)) }
        0xe { v.util_setreg_c(v.mem_fetch_nextbyte()) }
        0xf { 
            v.flag.cf = if (v.reg.a & 0x1) == 0x1 { true } else { false }
            v.reg.a = u8(v.reg.a >> 1) + u8(v.reg.a >> 4)
        
        }
        0x10 { println("ToImplement") }
        0x11 { v.flag.cf = if (v.reg.a & 0x1) == 0x1 { true } else { false } }
        0x12 { v.mem_writebyte(v.reg.de, v.reg.a) }
        0x13 { v.util_setreg_de(v.reg.de + 1) }
        0x14 { v.util_setreg_d(v.util_inc(v.reg.d)) }
        0x15 { v.util_setreg_d(v.util_dec(v.reg.d)) }
        0x16 { v.util_setreg_d(v.mem_fetch_nextbyte()) }
        0x17 {
            mut tmp := v.reg.a
            v.reg.a = (v.reg.a << 1) & 0xff
            if v.flag.cf {  v.reg.a++ }
            v.flag.cf = if (tmp & 0x80) > 0 { true } else { false }
        
        }
        0x18 { println("ToImplement") }
        0x19 { v.util_addreg_hl(v.reg.de) }
        0x1a { v.mem_readbyte(v.reg.de) }
        0x1b { v.util_setreg_de(v.reg.de - 1) }
        0x1c { v.util_setreg_e(v.util_inc(v.reg.e)) }
        0x1d { v.util_setreg_e(v.util_dec(v.reg.e)) }
        0x1e { v.util_setreg_e(v.mem_fetch_nextbyte()) }
        0x1f {
            mut tmp := v.reg.a
            v.reg.a >>= 1
            if v.flag.cf { v.reg.a += 0x80 }
            v.flag.cf = if (tmp & 0x1) > 0 { true } else { false }
        
        }
        0x20 { println("ToImplement") }
        0x21 { v.util_setreg_hl(v.mem_fetch_nextword()) }
        0x22 { v.mem_writeword(v.mem_fetch_nextword(), v.reg.hl) }
        0x23 { v.util_setreg_hl(v.reg.hl + 1) }
        0x24 { v.util_setreg_h(v.util_inc(v.reg.h)) }
        0x25 { v.util_setreg_h(v.util_dec(v.reg.h)) }
        0x26 { v.util_setreg_h(v.mem_fetch_nextbyte()) }
        0x27 {
            if (v.reg.a & 0x0f) > 9 || v.flag.af {
                v.reg.a += 0x06
                v.flag.af = true
            }

            if v.reg.a > 0x9f || v.flag.af {
                v.reg.a += 0x60
                v.flag.cf = true
            }

            v.flag.zf = if v.reg.a == 0 { true } else { false }
            v.flag.sf = if (v.reg.a & 0x80) > 0 { true } else { false }
            v.flag.pf = if (v.reg.a % 2) == 0 { true } else { false }
        
        }
        0x28 { println("ToImplement") }
        0x29 { v.util_addreg_hl(v.reg.hl) }
        0x2a { v.util_setreg_hl(v.mem_readword(v.mem_fetch_nextword())) }
        0x2b { v.util_setreg_hl(v.reg.hl - 1) }
        0x2c { v.util_setreg_l(v.util_inc(v.reg.l)) }
        0x2d { v.util_setreg_l(v.util_dec(v.reg.l)) }
        0x2e { v.util_setreg_l(v.mem_fetch_nextbyte()) }
        0x2f { v.reg.a = ~v.reg.a }
        0x30 { println("ToImplement") }
        0x31 { v.sp = v.mem_fetch_nextword() }
        0x32 { v.mem_writebyte(v.mem_fetch_nextword(), v.reg.a) }
        0x33 { v.sp++ }
        0x34 { v.mem_writebyte(v.reg.hl, v.util_inc(v.mem_readbyte(v.reg.hl))) }
        0x35 { v.mem_writebyte(v.reg.hl, v.util_dec(v.mem_readbyte(v.reg.hl))) }
        0x36 { v.mem_writebyte(v.reg.hl, v.mem_fetch_nextbyte()) }
        0x37 { v.flag.cf = true }
        0x38 { println("ToImplement") }
        0x39 { v.util_addreg_hl(v.sp) }
        0x3a { v.reg.a = v.mem_readbyte(v.mem_fetch_nextword()) }
        0x3b { v.sp-- }
        0x3c { v.reg.a = v.util_inc(v.reg.a) }
        0x3d { v.reg.a = v.util_dec(v.reg.a) }
        0x3e { v.reg.a = v.mem_fetch_nextbyte() }
        0x3f { v.flag.cf = if v.flag.cf { false } else { true } }
        0x40 { v.reg.b = v.reg.b }
        0x41 { v.util_setreg_b(v.reg.c) }
        0x42 { v.util_setreg_b(v.reg.d) }
        0x43 { v.util_setreg_b(v.reg.e) }
        0x44 { v.util_setreg_b(v.reg.h) }
        0x45 { v.util_setreg_b(v.reg.l) }
        0x46 { v.util_setreg_b(v.mem_readbyte(v.reg.hl)) }
        0x47 { v.util_setreg_b(v.reg.a) }
        0x48 { v.util_setreg_c(v.reg.b) }
        0x49 { v.reg.c = v.reg.c }
        0x4a { v.util_setreg_c(v.reg.d) }
        0x4b { v.util_setreg_c(v.reg.e) }
        0x4c { v.util_setreg_c(v.reg.h) }
        0x4d { v.util_setreg_c(v.reg.l) }
        0x4e { v.util_setreg_c(v.mem_readbyte(v.reg.hl)) }
        0x4f { v.util_setreg_c(v.reg.a) }
        0x50 { v.util_setreg_d(v.reg.b) }
        0x51 { v.util_setreg_d(v.reg.c) }
        0x52 { v.reg.d = v.reg.d }
        0x53 { v.util_setreg_d(v.reg.e) }
        0x54 { v.util_setreg_d(v.reg.h) }
        0x55 { v.util_setreg_d(v.reg.l) }
        0x56 { v.util_setreg_d(v.mem_readbyte(v.reg.hl)) }
        0x57 { v.util_setreg_d(v.reg.a) }
        0x58 { v.util_setreg_e(v.reg.b) }
        0x59 { v.util_setreg_e(v.reg.c) }
        0x5a { v.util_setreg_e(v.reg.d) }
        0x5b { v.reg.e = v.reg.e }
        0x5c { v.util_setreg_e(v.reg.h) }
        0x5d { v.util_setreg_e(v.reg.l) }
        0x5e { v.util_setreg_e(v.mem_readbyte(v.reg.hl)) }
        0x5f { v.util_setreg_e(v.reg.a) }
        0x60 { v.util_setreg_h(v.reg.b) }
        0x61 { v.util_setreg_h(v.reg.c) }
        0x62 { v.util_setreg_h(v.reg.d) }
        0x63 { v.util_setreg_h(v.reg.e) }
        0x64 { v.reg.h = v.reg.h }
        0x65 { v.util_setreg_h(v.reg.l) }
        0x66 { v.util_setreg_h(v.mem_readbyte(v.reg.hl)) }
        0x67 { v.util_setreg_h(v.reg.a) }
        0x68 { v.util_setreg_l(v.reg.b) }
        0x69 { v.util_setreg_l(v.reg.c) }
        0x6a { v.util_setreg_l(v.reg.d) }
        0x6b { v.util_setreg_l(v.reg.e) }
        0x6c { v.util_setreg_l(v.reg.h) }
        0x6d { v.reg.l = v.reg.l }
        0x6e { v.util_setreg_l(v.mem_readbyte(v.reg.hl)) }
        0x6f { v.util_setreg_l(v.reg.a) }
        0x70 { v.mem_writebyte(v.reg.hl, v.reg.b) }
        0x71 { v.mem_writebyte(v.reg.hl, v.reg.c) }
        0x72 { v.mem_writebyte(v.reg.hl, v.reg.d) }
        0x73 { v.mem_writebyte(v.reg.hl, v.reg.e) }
        0x74 { v.mem_writebyte(v.reg.hl, v.reg.h) }
        0x75 { v.mem_writebyte(v.reg.hl, v.reg.l) }
        0x76 { println("HALT") exit(0) }
        0x77 { v.mem_writebyte(v.reg.hl, v.reg.a) }
        0x78 { v.reg.a = v.reg.b }
        0x79 { v.reg.a = v.reg.c }
        0x7a { v.reg.a = v.reg.d }
        0x7b { v.reg.a = v.reg.e }
        0x7c { v.reg.a = v.reg.h }
        0x7d { v.reg.a = v.reg.l }
        0x7e { v.mem_readbyte(v.reg.hl) }
        0x7f { v.reg.a = v.reg.a }
        0x80 { v.util_add(v.reg.b) }
        0x81 { v.util_add(v.reg.c) }
        0x82 { v.util_add(v.reg.d) }
        0x83 { v.util_add(v.reg.e) }
        0x84 { v.util_add(v.reg.h) }
        0x85 { v.util_add(v.reg.l) }
        0x86 { v.util_add(v.mem_readbyte(v.reg.hl)) }
        0x87 { v.util_add(v.reg.a) }
        0x88 { v.util_add_c(v.reg.b) }
        0x89 { v.util_add_c(v.reg.c) }
        0x8a { v.util_add_c(v.reg.d) }
        0x8b { v.util_add_c(v.reg.e) }
        0x8c { v.util_add_c(v.reg.h) }
        0x8d { v.util_add_c(v.reg.l) }
        0x8e { v.util_add_c(v.mem_readbyte(v.reg.hl)) }
        0x8f { v.util_add_c(v.reg.b) }
        0x90 { v.util_sub(v.reg.b) }
        0x91 { v.util_sub(v.reg.c) }
        0x92 { v.util_sub(v.reg.d) }
        0x93 { v.util_sub(v.reg.e) }
        0x94 { v.util_sub(v.reg.h) }
        0x95 { v.util_sub(v.reg.l) }
        0x96 { v.util_sub(v.mem_readbyte(v.reg.hl)) }
        0x97 { v.util_sub(v.reg.a) }
        0x98 { println("ToImplement") }
        0x99 { println("ToImplement") }
        0x9a { println("ToImplement") }
        0x9b { println("ToImplement") }
        0x9c { println("ToImplement") }
        0x9d { println("ToImplement") }
        0x9e { println("ToImplement") }
        0x9f { println("ToImplement") }
        0xa0 { v.util_and(v.reg.b) }
        0xa1 { v.util_and(v.reg.c) }
        0xa2 { v.util_and(v.reg.d) }
        0xa3 { v.util_and(v.reg.e) }
        0xa4 { v.util_and(v.reg.h) }
        0xa5 { v.util_and(v.reg.l) }
        0xa6 { v.util_and(v.mem_readbyte(v.reg.hl)) }
        0xa7 { v.util_and(v.reg.a) }
        0xa8 { v.util_xor(v.reg.b) }
        0xa9 { v.util_xor(v.reg.c) }
        0xaa { v.util_xor(v.reg.d) }
        0xab { v.util_xor(v.reg.e) }
        0xac { v.util_xor(v.reg.h) }
        0xad { v.util_xor(v.reg.l) }
        0xae { v.util_xor(v.mem_readbyte(v.reg.hl)) }
        0xaf { v.util_xor(v.reg.a) }
        0xb0 { v.util_or(v.reg.b) }
        0xb1 { v.util_or(v.reg.c) }
        0xb2 { v.util_or(v.reg.d) }
        0xb3 { v.util_or(v.reg.e) }
        0xb4 { v.util_or(v.reg.h) }
        0xb5 { v.util_or(v.reg.l) }
        0xb6 { v.util_or(v.mem_readbyte(v.reg.hl)) }
        0xb7 { v.util_or(v.reg.a) }
        0xb8 { v.util_cmpsub(v.reg.b) }
        0xb9 { v.util_cmpsub(v.reg.c) }
        0xba { v.util_cmpsub(v.reg.d) }
        0xbb { v.util_cmpsub(v.reg.e) }
        0xbc { v.util_cmpsub(v.reg.h) }
        0xbd { v.util_cmpsub(v.reg.l) }
        0xbe { v.util_cmpsub(v.mem_readbyte(v.reg.hl)) }
        0xbf { v.util_cmpsub(v.reg.a) }
        0xc0 { if v.flag.zf { v.pc = v.mem_popstack() } }
        0xc1 { v.util_setreg_bc(v.mem_popstack()) }
        0xc2 { if v.flag.zf != true { v.pc = v.mem_fetch_nextword() } }
        0xc3 { v.pc = v.mem_fetch_nextword() }
        0xc4 {
            if v.flag.zf != true { 
                v.mem_pushstack(v.pc)
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xc5 { v.mem_pushstack(v.reg.bc) }
        0xc6 { v.util_add(v.mem_fetch_nextbyte()) }
        0xc7 {
            v.pc = v.mem_popstack()
            v.pc = 0x0
        
        }
        0xc8 { if v.flag.zf { v.pc = v.mem_popstack() } }
        0xc9 { v.pc = v.mem_popstack() }
        0xca { if v.flag.zf { v.pc = v.mem_fetch_nextword() } }
        0xcb { println("ToImplement") }
        0xcc {
            if  v.flag.zf {
                v.mem_pushstack(v.pc)
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xcd {
            v.mem_pushstack(v.pc)
            v.pc = v.mem_fetch_nextword()
        
        }
        0xce { v.util_add_c(v.mem_fetch_nextbyte()) }
        0xcf {
            v.mem_pushstack(v.pc)
            v.pc = 0x8
        
        }
        0xd0 { if v.flag.cf != true { v.pc = v.mem_popstack() } }
        0xd1 { v.util_setreg_de(v.mem_popstack()) }
        0xd2 { if v.flag.cf != true { v.pc = v.mem_fetch_nextword() } }
        0xd3 {
            port := v.mem_fetch_nextbyte()
            v.port.output_port(port, v.reg.a)
        
        }
        0xd4 {
            if v.flag.cf != true {
                v.mem_pushstack(v.pc)
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xd5 { v.mem_pushstack(v.reg.de) }
        0xd6 { v.util_sub(v.mem_fetch_nextbyte()) }
        0xd7 {
            v.mem_pushstack(v.pc)
            v.pc = 0x10
        
        }
        0xd8 { if v.flag.cf { v.pc = v.mem_popstack() } }
        0xd9 { println("ToImplement") }
        0xda { if v.flag.cf { v.pc = v.mem_fetch_nextword() } }
        0xdb {
            port := v.mem_fetch_nextbyte()
            v.reg.a = v.port.input_port(port)
        
        }
        0xdc {
            if v.flag.cf {
                v.mem_pushstack(v.pc)
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xdd { println("ToImplement") }
        0xde {
            data := v.mem_fetch_nextbyte()
            v.util_sub_c(data)
        
        }
        0xdf {
            v.mem_pushstack(v.pc)
            v.pc = 0x18
        
        }
        0xe0 { println("ToImplement") }
        0xe1 { v.util_setreg_hl(v.mem_popstack()) }
        0xe2 { println("ToImplement") }
        0xe3 {
            mut tmp := v.reg.h
            v.util_setreg_h(v.mem_readbyte(v.sp + 1))
            v.mem_writebyte(v.sp + 1, tmp)

            tmp = v.reg.l
            v.util_setreg_l(v.mem_readbyte(v.sp))
            v.mem_writebyte(v.sp, tmp)
        
        }
        0xe4 { println("ToImplement") }
        0xe5 { v.mem_pushstack(v.reg.bc) }
        0xe6 { v.util_and(v.mem_fetch_nextbyte()) }
        0xe7 {
            v.mem_pushstack(v.pc)
            v.pc = 0x20
        
        }
        0xe8 { println("ToImplement") }
        0xe9 { v.pc = v.reg.hl }
        0xea { println("ToImplement") }
        0xeb {
            tmp := v.reg.hl
            v.util_setreg_hl(v.reg.de)
            v.util_setreg_de(tmp)
        
        }
        0xec { println("ToImplement") }
        0xed { println("ToImplement") }
        0xee { v.util_xor(v.mem_fetch_nextbyte()) }
        0xef {
            v.mem_pushstack(v.pc)
            v.pc = 0x28
        
        }
        0xf0 { println("ToImplement") }
        0xf1 {
            val := v.mem_popstack()
            v.reg.a = u8(val)
            v.flag.sf = if (val & 0x80) > 0 { true } else { false }
            v.flag.zf = if (val & 0x40) > 0 { true } else { false }
            v.flag.af = if (val & 0x10) > 0 { true } else { false }
            v.flag.pf = if (val & 0x04) > 0 { true } else { false }
            v.flag.cf = if (val & 0x01) > 0 { true } else { false } 
        
        }
        0xf2 {
            if v.flag.sf != true {
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xf3 { v.interrupt_enable = false }
        0xf4 { println("ToImplement") }
        0xf5 {
            mut val := v.reg.a + 0x2
            if v.flag.sf {val += 0x80 }
            if v.flag.zf {val += 0x40 }
            if v.flag.af {val += 0x10 }
            if v.flag.pf {val += 0x04 }
            if v.flag.cf {val += 0x01 }

            v.mem_pushstack(val)
        
        }
        0xf6 { v.util_or(v.mem_fetch_nextbyte()) }
        0xf7 {
            v.mem_pushstack(v.pc)
            v.pc = 0x30
        
        }
        0xf8 { println("ToImplement") }
        0xf9 { println("ToImplement") }
        0xfa {
            if v.flag.sf {
                v.pc = v.mem_fetch_nextword()
            }
        
        }
        0xfb { v.interrupt_enable = true }
        0xfc { println("ToImplement") }
        0xfd { println("NOP") }
        0xfe {
            val := v.mem_fetch_nextbyte()
            v.util_cmpsub(val)
        
        }
        0xff {
            v.mem_pushstack(v.pc)
            v.pc = 0x38
        
        }
        else { println("Unknown Opcode") }
    }
}

fn (mut v V8080) load_rom()! {
    file_path := os.args[1]
    if os.args.len == 2 && os.exists(file_path) {
        buffer := os.read_file(file_path)!
        
        for index in buffer {
            v.mem[index] = u8(buffer[index])
        }
        println("[SUCCESS] ROM Loaded.")
    } else {
        println("[INFO] Usage: v . invaders/invaders")
        exit(0)
    }
}

fn new_v8080() &V8080 {
    return &V8080 {
        pc: 0
        sp: 0xf000
        mem: []u8 { len:0xffff, init:0 }
        reg: &Reg { a: 0, b: 0, c: 0, d: 0, e: 0, h: 0, l: 0, bc: 0, de: 0, hl: 0 }
        flag: &Flag { sf: false, zf: false, af: false, pf: false, cf: false }
        port: &Port {
            in_port1: 0,
            in_port2: 0,
            out_port2: 0,
            out_port3: 0,
            out_port4_hi: 0,
            out_port4_lo: 0,
            out_port5: 0
        }
        interrupt_enable: false
    }
}

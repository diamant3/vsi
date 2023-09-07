module main

struct Port {
mut:
	in_port1 u8
	in_port2 u8
	out_port2 u8
	out_port3 u8
	out_port4_hi u8
	out_port4_lo u8
	out_port5 u8
}

fn (mut p Port) output_port(port u8, val u8) {
	match port {
		2 { p.out_port2 = val }
		3 { p.out_port3 = val }
		4 {
			p.out_port4_lo = p.out_port4_hi
			p.out_port4_hi = val
		}
		5 { p.out_port5 = val }
		else { println("Input Port Error") }
	}
}

fn (mut p Port) input_port(port u8) u8 {
	mut result := u8(0)
	match port {
		1 {
			result = p.in_port1
			p.in_port1 &= 0xfe
		}
		2 { result = u8((p.in_port2 & 0x8f) | (p.in_port2 & 0x70)) }
		3 { result = u8(p.out_port4_hi | p.out_port4_lo << p.out_port2) }
		else { println("Input Port Error") }
	}

	if result > 0xff {
		println("[ERROR] Input error: ${result}")
		exit(1)
	}

	return result
}
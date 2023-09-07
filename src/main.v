module main

import os
import gg
import gx

struct App {
mut:
	gg &gg.Context = unsafe { nil }
	core &V8080 = unsafe { nil }
}

fn main() {
	mut app := &App {
		gg: 0
		core: new_v8080()
	}

	app.core.load_rom()!

	app.gg = gg.new_context(
		width: 256
		height: 224
		bg_color: gx.black
		window_title: "VSI [" + os.args[1] + "]"
		frame_fn: frame
		user_data: app
	)

	app.gg.run()
}

fn frame(mut a App) {
	a.core.exec_ins()

	a.gg.begin()
	for height in 0..224 {
		mut index := u16(0x2400 + (height << 5))
		for width in 0..32 {
			mut vram := u8(a.core.get_mem(index))
			index++
			for px in 0..8 {
				if (vram & 0x01) == 0x1 {
					a.gg.draw_rect_filled(height, 255 - width * 8 - px, 8, 8, gx.white)
				} else {
					a.gg.draw_rect_filled(height, 255 - width * 8 - px, 8, 8, gx.black)
				}
				vram >>= 0x1
			}
		}
	}
	a.gg.end()
}

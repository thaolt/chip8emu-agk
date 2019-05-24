function chip8emu_get_keystate(cpu ref as chip8cpu, idx as integer)
	if (idx = 0) then idx = 0x10
	keystate = GetVirtualButtonState(idx)
endfunction keystate


function chip8emu_draw(cpu ref as chip8cpu, imgId)
	virtWidth = GetVirtualWidth()
	virtHeight = GetVirtualHeight()
	SetRenderToImage(imgId, 0)
	
	if cpu.disp_height = 32
		/* 64x32 */
		SetVirtualResolution(384,192)
		ClearScreen()
		
		color = MakeColor(105,105,3)
		DrawBox(0, 0, 384, 192, color, color, color, color, 1)
		
		color = MakeColor(32,60,50)
		for y = 0 to 31
			for x = 0 to 63
				if cpu.disp[y*64 + x] > 0
					dx = x*6
					dy = y*6
					DrawBox(dx, dy, dx+6, dy+5, color, color, color, color, 1)
				endif
			next x
		next y
	else
		/* 128x64 */
		SetVirtualResolution(768,384)
		ClearScreen()
		
		color = MakeColor(105,105,3)
		DrawBox(0, 0, 768, 384, color, color, color, color, 1)
		
		ox = 0
		
		if (cpu.disp_width = 64) /* hires: 64x64 */
			color = MakeColor(32,60,50)
			DrawBox(186, 0, 191, 383, color, color, color, color, 1)
			DrawBox(576, 0, 581, 383, color, color, color, color, 1)
			ox = 192
		endif
		
		color = MakeColor(32,60,50)
		for y = 0 to cpu.disp_height - 1
			for x = 0 to cpu.disp_width - 1
				if cpu.disp[y*cpu.disp_width + x] > 0
					dx = x*6
					dy = y*6
					DrawBox(ox + dx, dy, ox + dx+6, dy+5, color, color, color, color, 1)
				endif
			next x
		next y
	endif
	
	
	cpu.draw_flag = 0
	SetRenderToScreen()
	SetVirtualResolution(virtWidth,virtHeight)
endfunction


function chip8emu_beep(cpu ref as chip8cpu)
	StopSound(1)
	PlaySound(1)
endfunction

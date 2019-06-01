function chip8emu_get_keystate(cpu ref as chip8cpu, idx as integer)
	keystate = 0
	if emu.is_mobile = 0
		if (emu.romcfg.keymap[idx] > 0) then keystate = GetButtonState(emu.romcfg.keymap[idx])
	endif
	if keystate = 0
		if (idx = 0) then idx = 0x10
		keystate = GetVirtualButtonState(idx)
	endif
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
				if GetMemblockByte(cpu.disp, y*64 + x) > 0
					dx = x*6
					dy = y*6
					DrawBox(dx, dy, dx+6, dy+5, color, color, color, color, 1)
				endif
			next x
		next y
	else
		/* SCHIP: 128x64 */
		SetVirtualResolution(768,384)
		SetClearColor(105,105,3)
		ClearScreen()
		
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
				if GetMemblockByte(cpu.disp, y*cpu.disp_width + x) > 0
					dx = x*6
					dy = y*6
					DrawBox(ox + dx, dy, ox + dx+6, dy+6, color, color, color, color, 1)
				endif
			next x
		next y
	endif
	
	cpu.draw_flag = 0
	SetRenderToScreen()
	SetVirtualResolution(virtWidth,virtHeight)
endfunction

function chip8emu_beep(cpu ref as chip8cpu, beep ref as BeepConfig)
	if beep.beeping = 1 then exitfunction
	beep.beeping = 1
	if cpu.sound_timer > 1
		PlayMusicOGG(beep.sndLongBeep)
	else
		PlaySound(beep.sndShortBeep)
	endif
endfunction

function chip8emu_stopbeep(cpu ref as chip8cpu, beep ref as BeepConfig)
	if GetMusicPlayingOGG(beep.sndLongBeep) then StopMusicOGG(beep.sndLongBeep)
	beep.beeping = 0
endfunction

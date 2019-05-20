#include "chip8emu.agc"

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "First project" )
SetWindowSize( 640, 320, 0 )

// set display properties
SetVirtualResolution( 640, 320 )
SetOrientationAllowed( 1, 1, 1, 1 )
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 )
UseNewDefaultFonts( 1 ) // since version 2.0.20 we can use nicer default fonts

function chip8_render_disp(cpu ref as chip8cpu, imgId)
	SetRenderToImage(imgId, 0)
	color = MakeColor(255,255,255)
	
	for y = 0 to 31
		for x = 0 to 63
			if cpu.disp[y*64 + x] > 0
				DrawBox(x*10, y*10, x*10+10, y*10+10, color, color, color, color, 1)
				//DrawLine(x*10, y*10, x*10, y*10, 255, 255, 255)
			endif
		next x
	next y
	
	cpu.draw_flag = 0
	SetRenderToScreen()
	CreateSprite(imgId)
endfunction

emu as chip8cpu

chip8emu_init(emu)

chip8emu_load_rom(emu, "roms/TETRIS")

screenBuf = CreateRenderImage(640, 320, 0, 0)

do
	chip8emu_exec_cycle(emu)
	
	chip8emu_timer_tick(emu)
	
	if (emu.draw_flag > 0)
		chip8_render_disp(emu, screenBuf)
		Sync()
	endif
	
    
loop

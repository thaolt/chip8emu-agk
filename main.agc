#include "chip8emu.agc"

function chip8_render_disp(cpu ref as chip8cpu, imgId)
	SetRenderToImage(imgId, 0)
	ClearScreen()
	color = MakeColor(135,135,3)
	DrawBox(0, 0, 448, 223, color, color, color, color, 1)
	color = MakeColor(32,60,50)
	
	for y = 0 to 31
		for x = 0 to 63
			if cpu.disp[y*64 + x] > 0
				dx = x*7
				dy = y*7
				DrawBox(dx, dy, dx+7, dy+6, color, color, color, color, 1)
				//DrawLine(x*10, y*10, x*10, y*10, 255, 255, 255)
			endif
		next x
	next y
	
	cpu.draw_flag = 0
	SetRenderToScreen()
endfunction

/* main */

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Chip8 Emulator" )
SetWindowSize( 512, 768, 0 )

// set display properties
SetVirtualResolution( 512, 768 )
SetOrientationAllowed( 1, 1, 0, 0 )
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
UseNewDefaultFonts( 1 ) // since version 2.0.20 we can use nicer default fonts

emu as chip8cpu

chip8emu_init(emu)

chip8emu_load_rom(emu, "roms/Tron.ch8")

screenBuf = CreateRenderImage(512, 768, 0, 0)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0) 

sprDisplay = CreateSprite(screenBuf)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

sprBg = CreateSprite(LoadImage("bg.png"))
SetSpriteTransparency(sprBg, 1)


lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#

do
	now# = Timer()
	
	if (emu.draw_flag > 0)
		chip8_render_disp(emu, screenBuf)
		continue
	endif
	
	if (now# - lastCycle# > 0.002) /* 500 hz */
		chip8emu_exec_cycle(emu)
		lastCycle# = Timer()
		continue
	endif
	
	if (now# - lastTick# > 0.0166666) /* 60 hz */
		chip8emu_timer_tick(emu)
		lastTick# = Timer()
		continue
	endif
	
	
	
	if (now# - lastSync# > 0.0333333) /* 30 hz */
		Sync()
		lastSync# = Timer()
    endif
    
loop

/* end main */

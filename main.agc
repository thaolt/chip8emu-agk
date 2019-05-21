#include "chip8emu.agc"

function chip8_render_disp(cpu ref as chip8cpu, imgId)
	SetRenderToImage(imgId, 0)
	ClearScreen()
	color = MakeColor(135,135,3)
	color = MakeColor(105,105,3)
	DrawBox(0, 0, 448, 223, color, color, color, color, 1)
	color = MakeColor(32,60,50)
	
	for y = 0 to 31
		for x = 0 to 63
			if cpu.disp[y*64 + x] > 0
				dx = x*7
				dy = y*7
				DrawBox(dx, dy, dx+7, dy+6, color, color, color, color, 1)
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

chip8emu_load_rom(emu, "roms/TETRIS")

screenBuf = CreateRenderImage(512, 768, 0, 0)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0) 

sprDisplay = CreateSprite(screenBuf)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

sprBg = CreateSprite(LoadImage("bg.png"))
SetSpriteTransparency(sprBg, 1)

for i = 1 to 9
	AddVirtualButton(i, 82 + (mod(i-1,3) * 112), 350 + ((i-1)/3) * 112, 100)
	SetVirtualButtonText(i, Str(i))
next i

AddVirtualButton(0xA, 82, 686, 100)
SetVirtualButtonText(0xA, "A")

AddVirtualButton(0x10, 194, 686, 100)
SetVirtualButtonText(0x10, "0")

AddVirtualButton(0xB, 306, 686, 100)
SetVirtualButtonText(0xB, "B")

AddVirtualButton(0xC, 418, 686, 100)
SetVirtualButtonText(0xC, "C")

AddVirtualButton(0xD, 418, 574, 100)
SetVirtualButtonText(0xD, "D")

AddVirtualButton(0xE, 418, 462, 100)
SetVirtualButtonText(0xE, "E")

AddVirtualButton(0xF, 418, 350, 100)
SetVirtualButtonText(0xF, "F")

lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#
lastKeyCheck# = lastSync#

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

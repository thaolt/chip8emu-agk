
#include "chip8emu.agc"

function chip8_render_disp(cpu ref as chip8cpu, imgId)
	
	SetRenderToImage(imgId, 0)
	SetVirtualResolution( 512, 768 )
	ClearScreen()
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
SetWindowTitle( "CHIP8 Emulator" )
SetWindowSize( 512, 768, 0)

// set display properties
SetVirtualResolution( 512, 768 )
SetOrientationAllowed( 1, 1, 0, 0 )
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
UseNewDefaultFonts( 1 ) // since version 2.0.20 we can use nicer default fonts

emu as chip8cpu

chip8emu_init(emu)

chip8emu_load_rom(emu, "roms/TETRIS.ch8")

screenBuf = CreateRenderImage(512, 768, 0, 0)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0) 

sprDisplay = CreateSprite(screenBuf)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

imgBg = LoadImage("bg.png")
SetImageMagFilter(imgBg, 1)
SetImageMinFilter(imgBg, 1) 
sprBg = CreateSprite(imgBg)
SetSpriteTransparency(sprBg, 1)


for i = 1 to 9
	AddVirtualButton(i, 118 + (mod(i-1,3) * 92), 584 - ((i-1)/3) * 92, 80)
	SetVirtualButtonText(i, Str(i))
next i

AddVirtualButton(0xA, 118, 676, 80)
SetVirtualButtonText(0xA, "A")

AddVirtualButton(0x10, 210, 676, 80)
SetVirtualButtonText(0x10, "0")

AddVirtualButton(0xB, 302, 676, 80)
SetVirtualButtonText(0xB, "B")

AddVirtualButton(0xC, 394, 676, 80)
SetVirtualButtonText(0xC, "C")

AddVirtualButton(0xD, 394, 584, 80)
SetVirtualButtonText(0xD, "D")

AddVirtualButton(0xE, 394, 492, 80)
SetVirtualButtonText(0xE, "E")

AddVirtualButton(0xF, 394, 400, 80)
SetVirtualButtonText(0xF, "F")

imgBtnUp = LoadImage("red_btnup.png")
imgBtnDn = LoadImage("red_btndn.png")


btnRST = 0x11
AddVirtualButton(btnRST, 465, 315, 40)
SetVirtualButtonAlpha(btnRST, 255)
SetVirtualButtonImageUp(btnRST, imgBtnUp)
SetVirtualButtonImageDown(btnRST, imgBtnDn)

btnLD = 0x12
AddVirtualButton(btnLD, 52, 315, 40)
SetVirtualButtonText(btnLD, "LD")

lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#

do
	now# = Timer()
	
	if GetVirtualButtonReleased(btnRST)=1
		chip8emu_init(emu)
		sync()
		continue
	endif
	
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

#include "chip8emu.agc"


/* main */

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Chip8 Emulator" )
SetWindowSize( 640, 320, 0 )

// set display properties
SetVirtualResolution( 640, 320 )
SetOrientationAllowed( 1, 1, 1, 1 )
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 )
UseNewDefaultFonts( 1 ) // since version 2.0.20 we can use nicer default fonts

emu as chip8cpu

chip8emu_init(emu)

chip8emu_load_rom(emu, "roms/AstroDodge.ch8")

screenBuf = CreateRenderImage(640, 320, 0, 0)

lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#
CreateSprite(screenBuf)
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

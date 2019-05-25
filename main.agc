#include "chip8emu.agc"
#include "chip8callback.agc"

#insert "config.agc"

#insert "ui_setup.agc"

global sndLongBeep
global sndShortBeep

sndShortBeep = LoadSoundOGG("short_beep.ogg")
sndLongBeep = LoadMusicOGG("long_beep.ogg")

global beeping
beeping = 0

emu as chip8cpu

chip8emu_load_rom(emu, "roms/BRIX.ch8")
chip8emu_init(emu)

desired_speed# = 400 /* hertz */

cpu_clk# = 1.0 / desired_speed#
tmr_clk# = 1.0 / 60.0
refresh_rate# = 1.0 / 30.0

lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#

do
	now# = Timer()
	
	if GetVirtualButtonReleased(btnRST)=1
		chip8emu_init(emu)
		Sync()
		continue
	endif
	
	if (GetVirtualButtonReleased(btnPWR) = 1)
		exit
	endif
	
	if (now# - lastCycle# > cpu_clk#)
		chip8emu_exec_cycle(emu)
		lastCycle# = Timer()
		continue
	endif
	
	if (now# - lastTick# > tmr_clk#)
		chip8emu_timer_tick(emu)
		lastTick# = Timer()
		continue
	endif
	
	if (emu.draw_flag > 0)
		chip8emu_draw(emu, screenBuf)
		continue
	endif
	
	
	if (now# - lastSync# > refresh_rate#)
		select emu.mode
			case 0:
				SetSpriteVisible(sprGrid64, 1)
				SetSpriteVisible(sprGrid128, 0)
			endcase
			case default:
				SetSpriteVisible(sprGrid64, 0)
				SetSpriteVisible(sprGrid128, 1)
			endcase
		endselect
		print(ScreenFPS())
		Sync()
		lastSync# = Timer()
    endif
    
loop

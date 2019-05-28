#include "chip8emu.agc"
#include "chip8callback.agc"
#include "menu.agc"

#insert "config.agc"
#insert "ui_setup.agc"

global sndLongBeep
global sndShortBeep

sndShortBeep = LoadSoundOGG("short_beep.ogg")
sndLongBeep = LoadMusicOGG("long_beep.ogg")

global beeping
beeping = 0
global paused
paused = 0


emu as chip8cpu

chip8emu_load_rom(emu, "roms/BRIX.ch8")
chip8emu_init(emu)

cpu_speed# = 400 /* hertz */

cpu_clk# = 1.0 / cpu_speed#
tmr_clk# = 1.0 / 60.0
refresh_rate# = 1.0 / 30.0

lastSync# = Timer()
lastCycle# = lastSync#
lastTick# = lastSync#

menu as MenuConfig

initMenu(menu, menuImg, btnUP, btnDN, btnSEL, sprMenu, sprDisplay)

renderMenu(menu)

do
	now# = Timer()
	
	if GetVirtualButtonReleased(btnRST)=1
		SetSpriteVisible(sprMenu, 0)
		SetSpriteVisible(sprDisplay, 1)
		paused = 0
		chip8emu_init(emu)
		Sync()
		lastSync# = Timer()
		continue
	endif
	
	if (GetVirtualButtonReleased(btnPWR) = 1)
		Sync()
		exit
	endif
	
	if (GetVirtualButtonReleased(btnMENU) = 1)
		if paused = 0
			paused = 1
			SetSpriteVisible(sprDisplay, 0)
			SetSpriteVisible(sprGrid64, 0)
			SetSpriteVisible(sprGrid128, 0)
			SetSpriteVisible(sprMenu, 1)
			resetMenu(menu)
			renderMenu(menu)
		else
			SetSpriteVisible(sprMenu, 0)
			SetSpriteVisible(sprDisplay, 1)
			paused = 0
		endif
		Sync()
		continue
	endif
	
	if paused = 0
		if (now# - lastCycle# > cpu_clk#)
			lastCycle# = Timer()
			chip8emu_exec_cycle(emu)
			continue
		endif
		
		if (now# - lastTick# > tmr_clk#)
			lastTick# = Timer()
			chip8emu_timer_tick(emu)
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
			Sync()
			lastSync# = Timer()
		endif
    
    else
		if (menuLoop(menu) = 1)
			chip8emu_load_rom(emu, menu.cur_path + "/" + menu.dir_entries[menu.fb_sel])
			chip8emu_init(emu)
			paused = 0
			Sync()
			lastSync# = Timer()
		endif
	endif
loop

end

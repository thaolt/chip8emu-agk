#include "chip8emu.agc"
#include "chip8callback.agc"
#include "menu.agc"
#include "snd.agc"

#insert "config.agc"
#insert "ui_setup.agc"

Type Emulation
	paused
	cpu_speed#
	cpu_clk#
	tmr_clk#
	refresh_rate#
EndType

beepcfg as BeepConfig
beep_config_init(beepcfg)

cpu as chip8cpu

chip8emu_load_rom(cpu, "roms/BRIX.ch8")
chip8emu_init(cpu)

emu as Emulation

emu.paused = 0
emu.cpu_speed# = 400 /* hertz */
emu.cpu_clk# = 1.0 / emu.cpu_speed#
emu.tmr_clk# = 1.0 / 60.0
emu.refresh_rate# = 1.0 / 30.0

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
		emu.paused = 0
		chip8emu_init(cpu)
		chip8emu_stopbeep(cpu, beepcfg)
		Sync()
		lastSync# = Timer()
		continue
	endif
	
	if (GetVirtualButtonReleased(btnPWR) = 1)
		Sync()
		exit
	endif
	
	if (GetVirtualButtonReleased(btnMENU) = 1)
		if emu.paused = 0
			emu.paused = 1
			SetSpriteVisible(sprDisplay, 0)
			SetSpriteVisible(sprGrid64, 0)
			SetSpriteVisible(sprGrid128, 0)
			SetSpriteVisible(sprMenu, 1)
			resetMenu(menu)
			renderMenu(menu)
		else
			SetSpriteVisible(sprMenu, 0)
			SetSpriteVisible(sprDisplay, 1)
			emu.paused = 0
		endif
		Sync()
		continue
	endif
	
	if emu.paused = 0
		if (now# - lastCycle# > emu.cpu_clk#)
			lastCycle# = Timer()
			chip8emu_exec_cycle(cpu)
			continue
		endif
		
		if (now# - lastTick# > emu.tmr_clk#)
			lastTick# = Timer()
			if cpu.sound_timer > 0 
				chip8emu_beep(cpu, beepcfg)
			else
				chip8emu_stopbeep(cpu, beepcfg)
			endif
			if cpu.skip_frame > 0
				dec cpu.skip_frame
				if (cpu.skip_frame = 0) then cpu.draw_flag = 1
			endif
			chip8emu_timer_tick(cpu)
			continue
		endif
		
		if (cpu.draw_flag > 0)
			chip8emu_draw(cpu, screenBuf)
			continue
		endif
		
		if (now# - lastSync# > emu.refresh_rate#)
			select cpu.mode
				case 0: /* 64x32 */
					SetSpriteVisible(sprGrid64, 1)
					SetSpriteVisible(sprGrid128, 0)
				endcase
				case default:  /* 64x64 */
					SetSpriteVisible(sprGrid64, 0)
					SetSpriteVisible(sprGrid128, 1)
				endcase
			endselect
			Sync()
			lastSync# = Timer()
		endif
    
    else
		if (menuLoop(menu, emu) = 1)
			chip8emu_load_rom(cpu, menu.cur_path + "/" + menu.dir_entries[menu.fb_sel])
			chip8emu_init(cpu)
			chip8emu_stopbeep(cpu, beepcfg)
			emu.paused = 0
			Sync()
			lastSync# = Timer()
		endif
	endif
loop

end

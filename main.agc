#include "chip8cpu.agc"
#include "chip8callback.agc"
#include "menu.agc"
#include "snd.agc"

#insert "config.agc"
#insert "ui_setup.agc"

Type RomConfig
	/* 5 keys support by AGK: Space, E, R, Q, CTRL
	 * key index is from 0x0 to 0xF
	 * possible value:
	 * 		0: nomap
	 * 	1 - 5: map to AGK key
	 * example for TETRIS
	 *   keymap[4] = 1 ; Space: rotate
	 *   keymap[5] = 2 ; E: left
	 *   keymap[6] = 3 ; R: right 
	 *   keymap[7] = 5 ; Q: No Map
	 */
	cpu_speed
	keymap as Integer[15]
	help_pc as String
	help_mobile as String
EndType

Type Emulation
	paused
	cpu_speed#
	cpu_clk#
	tmr_clk#
	refresh_rate#
	
	is_mobile
	
	cpu as chip8cpu
	romcfg as RomConfig
	beepcfg as BeepConfig
EndType

function emu_load_rom(filename as String)
	chip8emu_load_rom(emu.cpu, filename)
	cfgname$ = LEFT(filename, Len(filename) - 4) + ".cfg"
	If GetFileExists(cfgname$)
		fromcfg = CreateMemblockFromFile(cfgname$)
		emu.romcfg.fromJSON(GetMemblockString(fromcfg, 0, GetMemblockSize(fromcfg)))
		DeleteMemblock(fromcfg)
	else
		emu.romcfg.cpu_speed = 0
		for i = 0 to 15
			emu.romcfg.keymap[i] = 0
		next i
		emu.romcfg.help_pc = ""
		emu.romcfg.help_mobile = ""
	endif

	if emu.romcfg.cpu_speed > 0
		emu.cpu_speed# = emu.romcfg.cpu_speed
	else
		emu.cpu_speed# = 400 /* hertz */
	endif
	emu.cpu_clk# = 1.0 / emu.cpu_speed#
endfunction

global emu as Emulation

emu.is_mobile = isMobileDevice
emu.paused = 0
emu.tmr_clk# = 1.0 / 60.0
emu.refresh_rate# = 1.0 / 30.0

beep_config_init(emu.beepcfg)
emu_load_rom("roms/BRIX.ch8")
chip8emu_init(emu.cpu)

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
		chip8emu_init(emu.cpu)
		chip8emu_stopbeep(emu.cpu, emu.beepcfg)
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
			chip8emu_exec_cycle(emu.cpu)
			continue
		endif
		
		if (now# - lastTick# > emu.tmr_clk#)
			lastTick# = Timer()
			if emu.cpu.sound_timer > 0 
				chip8emu_beep(emu.cpu, emu.beepcfg)
			else
				chip8emu_stopbeep(emu.cpu, emu.beepcfg)
			endif
			if emu.cpu.skip_frame > 0
				dec emu.cpu.skip_frame
				if (emu.cpu.skip_frame = 0) then emu.cpu.draw_flag = 1
			endif
			chip8emu_timer_tick(emu.cpu)
			continue
		endif
		
		if (emu.cpu.draw_flag > 0)
			chip8emu_draw(emu.cpu, screenBuf)
			continue
		endif
		
		if (now# - lastSync# > emu.refresh_rate#)
			select emu.cpu.mode
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
			emu_load_rom(menu.cur_path + "/" + menu.dir_entries[menu.fb_sel])
			chip8emu_init(emu.cpu)
			chip8emu_stopbeep(emu.cpu, emu.beepcfg)
			emu.paused = 0
			Sync()
			lastSync# = Timer()
		endif
	endif
loop

end

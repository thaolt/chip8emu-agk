#include "chip8emu.agc"
#include "chip8callback.agc"

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "CHIP8 Emulator" )
SetWindowSize(512, 768, 0)

isMobileDevice = 1
deviceOS$ = GetDeviceBaseName()
if (deviceOS$ = "mac" OR deviceOS$ = "windows" OR deviceOS$ = "linux") 
	isMobileDevice = 0
	UpdateDeviceSize(512, 768)
endif

if deviceOS$ = "android"
	SetAdMobDetails("ca-app-pub-7150691103537981/1488015021")
	CreateAdvert(5, 1, 2, 1)
	SetAdvertVisible ( 1 )
	RequestAdvertRefresh()
endif


SetVirtualResolution( 512, Round(GetDeviceHeight()*(512.0/GetDeviceWidth())) )
SetOrientationAllowed( 1, 1, 0, 0 )
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
UseNewDefaultFonts( 1 ) // since version 2.0.20 we can use nicer default fonts
SetScissor(0,0,0,0)

screenBuf = CreateImageColor(0,0,0,0xff)
ResizeImage(screenBuf, 448, 224)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0) 
sprDisplay = CreateSprite(screenBuf)
SetSpriteSize(sprDisplay, 448, 224)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

imgBg = LoadImage("bg.png")
SetImageMagFilter(imgBg, 1)
SetImageMinFilter(imgBg, 1) 
sprBg = CreateSprite(imgBg)
SetSpriteTransparency(sprBg, 1)

sprGrid64 = CreateSprite(LoadImage("grid64.png"))
SetSpriteTransparency(sprGrid64, 1)
SetSpriteSize(sprGrid64, 448, 224)
SetSpriteY(sprGrid64, 60)
SetSpriteX(sprGrid64, 32)

sprGrid128 = CreateSprite(LoadImage("grid128.png"))
SetSpriteTransparency(sprGrid128, 1)
SetSpriteSize(sprGrid128, 448, 224)
SetSpriteY(sprGrid128, 60)
SetSpriteX(sprGrid128, 32)
SetSpriteVisible(sprGrid128, 0)

sprGlossy = CreateSprite(LoadImage("glossy.png"))
SetSpriteTransparency(sprGlossy, 1)
SetSpriteSize(sprGlossy, 448, 224)
SetSpriteY(sprGlossy, 60)
SetSpriteX(sprGlossy, 32)

for i = 1 to 9
	AddVirtualButton(i, 118 + (mod(i-1,3) * 92), 400 + ((i-1)/3) * 92, 80)
	SetVirtualButtonText(i, Str(i))
next i

AddVirtualButton(0xA, 118, 676, 80)
SetVirtualButtonAlpha(0xA, 255)
SetVirtualButtonImageUp(0xA, LoadImage("btnAup.png"))
SetVirtualButtonImageDown(0xA,  LoadImage("btnAdn.png"))

AddVirtualButton(0x10, 210, 676, 80)
SetVirtualButtonAlpha(0x10, 255)
SetVirtualButtonImageUp(0x10, LoadImage("btn0up.png"))
SetVirtualButtonImageDown(0x10,  LoadImage("btn0dn.png"))

AddVirtualButton(0xB, 302, 676, 80)
SetVirtualButtonText(0xB, "B")

AddVirtualButton(0xF, 394, 676, 80)
SetVirtualButtonText(0xF, "F")

AddVirtualButton(0xE, 394, 584, 80)
SetVirtualButtonText(0xE, "E")

AddVirtualButton(0xD, 394, 492, 80)
SetVirtualButtonText(0xD, "D")

AddVirtualButton(0xC, 394, 400, 80)
SetVirtualButtonText(0xC, "C")

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


btnPWR = 0x13
AddVirtualButton(btnPWR, 468, 29, 42)
SetVirtualButtonAlpha(btnPWR, 255)
SetVirtualButtonImageUp(btnPWR, LoadImage("pwrup.png"))
SetVirtualButtonImageDown(btnPWR, LoadImage("pwrdn.png"))

LoadSoundOGG(1, "beep.ogg")

emu as chip8cpu
chip8emu_init(emu)

chip8emu_load_rom(emu, "roms/BRIX.ch8")

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
	
	if (GetVirtualButtonReleased(btnPWR) = 1)
		exit
	endif
	
	if (emu.draw_flag > 0)
		chip8emu_draw(emu, screenBuf)
		continue
	endif
	
	if (now# - lastCycle# > 0.004) /* 1000 hz */
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
    
loop

/* end main */

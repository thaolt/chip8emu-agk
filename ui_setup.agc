
screenBuf = CreateImageColor(0,0,0,0xff)
ResizeImage(screenBuf, 448, 224)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0) 
sprDisplay = CreateSprite(screenBuf)
SetSpriteSize(sprDisplay, 448, 224)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

sprBg = CreateSprite(LoadImage("bg.png"))
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

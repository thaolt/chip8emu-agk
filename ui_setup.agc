
screenBuf = CreateImageColor(0,0,0,0xff)
ResizeImage(screenBuf, 448, 224)
SetImageMagFilter(screenBuf, 0)
SetImageMinFilter(screenBuf, 0)

sprDisplay = CreateSprite(screenBuf)
SetSpriteSize(sprDisplay, 448, 224)
SetSpriteY(sprDisplay, 60)
SetSpriteX(sprDisplay, 32)

menuImg = CreateImageColor(105,105,3,0xff)
ResizeImage(menuImg, 448, 224)

sprMenu = CreateSprite(menuImg)
SetSpriteSize(sprMenu, 448, 224)
SetSpriteY(sprMenu, 60)
SetSpriteX(sprMenu, 32)
SetSpriteVisible(sprMenu, 0)

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

btnRST = 0x11
AddVirtualButton(btnRST, 52, 315, 40)
SetVirtualButtonAlpha(btnRST, 255)
SetVirtualButtonImageUp(btnRST, LoadImage("red_btnup.png"))
SetVirtualButtonImageDown(btnRST, LoadImage("red_btndn.png"))

btnSEL = 0x12
AddVirtualButton(btnSEL, 465, 315, 40)
SetVirtualButtonAlpha(btnSEL, 255)
SetVirtualButtonImageUp(btnSEL, LoadImage("blue_btnup.png"))
SetVirtualButtonImageDown(btnSEL, LoadImage("blue_btndn.png"))

btnMENU = 0x13
AddVirtualButton(btnMENU, 256, 315, 40)
SetVirtualButtonAlpha(btnMENU, 255)
SetVirtualButtonImageUp(btnMENU, LoadImage("yellow_btnup.png"))
SetVirtualButtonImageDown(btnMENU, LoadImage("yellow_btndn.png"))

btnUP = 0x14
AddVirtualButton(btnUP, 505, 140, 40)
SetVirtualButtonAlpha(btnUP, 255)
SetVirtualButtonText(btnUP, "UP")

btnDN = 0x15
AddVirtualButton(btnDN, 505, 200, 40)
SetVirtualButtonAlpha(btnDN, 255)
SetVirtualButtonText(btnDN, "DN")

btnPWR = 0x16
AddVirtualButton(btnPWR, 468, 29, 42)
SetVirtualButtonAlpha(btnPWR, 255)
SetVirtualButtonImageUp(btnPWR, LoadImage("pwrup.png"))
SetVirtualButtonImageDown(btnPWR, LoadImage("pwrdn.png"))

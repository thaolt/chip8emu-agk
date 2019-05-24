
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


type MenuConfig
	imgId
	
	w
	h
	
	font
	
	selIdx /* selected index */
	
	btnUP
	btnDN
	btnSEL
	
	sprMenu
	sprDisplay
	
	/* 0: main menu
	 * 1: Load ROM
	 * 2: Help (ROM instructions)
	 * 3: About */
	stage
	
	/* ----- for file browser ----- */
	cur_path as String
	dir_entries  as String[]
	fb_sel
	fb_top
endtype

function resetMenu(cfg ref as MenuConfig)
	cfg.selIdx = 0
	cfg.stage = 0

	cfg.cur_path = "/media/roms"
	cfg.fb_top = 0
	cfg.fb_sel = 0
endfunction

function initMenu(cfg ref as MenuConfig, imgId, btnUP, btnDN, btnSEL, sprMenu, sprDisplay)
	cfg.w = 448
	cfg.h = 224
	cfg.imgId = imgId
	cfg.font = LoadFont("GNUUnifont9FullHintInstrUCSUR.ttf")
	cfg.btnUP = btnUP
	cfg.btnDN = btnDN
	cfg.btnSEL = btnSEL
	cfg.sprMenu = sprMenu
	cfg.sprDisplay = sprDisplay
	cfg.selIdx = 0
	cfg.stage = 0

	cfg.cur_path = "/media/roms"
	cfg.fb_top = 0
	cfg.fb_sel = 0
endfunction

function renderMenu(cfg ref as MenuConfig)
	fg = MakeColor(32,60,50)
	bg = MakeColor(105,105,3)
	
	virtWidth = GetVirtualWidth()
	virtHeight = GetVirtualHeight()
	SetRenderToImage(cfg.imgId, 0)

	SetVirtualResolution(cfg.w,cfg.h)
	SetClearColor(105,105,3)
	ClearScreen()
	
	lbl = CreateText("")
	SetTextFont(lbl, cfg.font)
	SetTextSize(lbl, 30)
	SetTextAlignment(lbl, 1)
	SetTextBold(lbl, 1)
	
	SetTextString(lbl, "RESUME")
	SetTextPosition(lbl, 224, 50)
	SetTextColor(lbl,32,60,50,0xff)
	if cfg.selIdx = 0 then SetTextColor(lbl,0xff,0xff,0xff,0xff)
	DrawText(lbl)
	
	SetTextString(lbl, "LOAD ROM")
	SetTextPosition(lbl, 224, 80)
	SetTextColor(lbl,32,60,50,0xff)
	if cfg.selIdx = 1 then SetTextColor(lbl,0xff,0xff,0xff,0xff)
	DrawText(lbl)
	
	SetTextString(lbl, "HELP")
	SetTextPosition(lbl, 224, 110)
	SetTextColor(lbl,32,60,50,0xff)
	if cfg.selIdx = 2 then SetTextColor(lbl,0xff,0xff,0xff,0xff)
	DrawText(lbl)
	
	SetTextString(lbl, "ABOUT")
	SetTextPosition(lbl, 224, 140)
	SetTextColor(lbl,32,60,50,0xff)
	if cfg.selIdx = 3 then SetTextColor(lbl,0xff,0xff,0xff,0xff)
	DrawText(lbl)
	
	DeleteText(lbl)
	
	SetRenderToScreen()
	SetClearColor(0,0,0)
	SetVirtualResolution(virtWidth,virtHeight)
endfunction

function scanForRoms(entries ref as String[], path as String)
	entries.length = -1
	SetFolder(path)
	if (path <> "/media/roms") then entries.insert("../")
	dn$ = GetFirstFolder()
	while dn$ <> ""
		entries.insert( dn$ + "/" )
		dn$=GetNextFolder()
	endwhile
	
	fn$ = GetFirstFile()
	while fn$ <> ""
		if (Right(fn$, 4) = ".ch8") then entries.insert( fn$ )
		fn$=GetNextFile()
	endwhile
endfunction

function renderLoadRom(cfg ref as MenuConfig)
	
	/* handled buttons press */
	if (GetVirtualButtonState(cfg.btnUP) = 1)
		if (cfg.fb_sel > 0) then dec cfg.fb_sel
		if (cfg.fb_sel < cfg.fb_top) then dec cfg.fb_top
	endif

	if (GetVirtualButtonState(cfg.btnDN) = 1) 
		if (cfg.fb_sel < cfg.dir_entries.length) then inc cfg.fb_sel
		if (cfg.fb_sel - cfg.fb_top > 10) then inc cfg.fb_top
	endif
	
	virtWidth = GetVirtualWidth()
	virtHeight = GetVirtualHeight()
	selcolor = MakeColor(32,60,50)
	
	SetRenderToImage(cfg.imgId, 0)
	SetVirtualResolution(cfg.w, cfg.h)
	
	SetClearColor(105,105,3)
	ClearScreen()

	lbl = CreateText("")
	
	SetTextFont(lbl, cfg.font)
	SetTextSize(lbl, 20)
	SetTextAlignment(lbl, 0)
	SetTextVisible(lbl, 1)
	
	bottom = cfg.fb_top + 10
	
	if (bottom > cfg.dir_entries.length) then bottom = cfg.dir_entries.length
	
	for i = cfg.fb_top to bottom
		if (i = cfg.fb_sel)
			SetTextColor(lbl, 0xff, 0xff, 0xff, 0xff)
		else
			SetTextColor(lbl,32,60,50,0xff)
		endif
		SetTextPosition(lbl, 5, 20*(i-cfg.fb_top) + 2)
		If RIGHT(cfg.dir_entries[i], 1) = "/"
			SetTextString(lbl, Chr( 0x1F4C2 ) + cfg.dir_entries[i])
		else
			SetTextString(lbl, cfg.dir_entries[i])
		endif
		SetTextBold(lbl, 1)
		DrawText(lbl)
	next i
	
	SetTextVisible(lbl, 0)
	DeleteText(lbl)
	
	SetRenderToScreen()
	SetClearColor(0,0,0)
	SetVirtualResolution(virtWidth,virtHeight)
endfunction

function menuLoop(cfg ref as MenuConfig, emu ref as Emulation)
	loadNewRom = 0
	
	select cfg.stage
		case 0: /* main menu */
			if (GetVirtualButtonReleased(cfg.btnUP) = 1)
				if cfg.selIdx > 0 then dec cfg.selIdx
				renderMenu(cfg)
			endif

			if (GetVirtualButtonReleased(cfg.btnDN) = 1) 
				if cfg.selIdx < 3 then inc cfg.selIdx
				renderMenu(cfg)
			endif

			if (GetVirtualButtonReleased(cfg.btnSEL) = 1) 
				select cfg.selIdx
					case 0:
						SetSpriteVisible(cfg.sprMenu, 0)
						SetSpriteVisible(cfg.sprDisplay, 1)
						emu.paused = 0
					endcase
					case 1:
						cfg.stage = 1
						scanForRoms(cfg.dir_entries, cfg.cur_path)
						renderLoadRom(cfg)
					endcase
					
				endselect
			endif
		endcase
		case 1:
			if (GetVirtualButtonState(cfg.btnUP) = 1)
				renderLoadRom(cfg)
				Sleep(50)
				Sync()
			endif

			if (GetVirtualButtonState(cfg.btnDN) = 1) 
				renderLoadRom(cfg)
				Sleep(50)
				Sync()
			endif

			if (GetVirtualButtonReleased(cfg.btnSEL) = 1) 
				name$ = cfg.dir_entries[cfg.fb_sel]
				if (RIGHT(name$,1) = "/")
					if name$ = "../"
						cfg.cur_path = LEFT(cfg.cur_path, FindStringReverse(cfg.cur_path, "/") - 1)
					else
						cfg.cur_path = cfg.cur_path + "/" + LEFT(name$, len(name$) - 1)
					endif
					scanForRoms(cfg.dir_entries, cfg.cur_path)
					cfg.fb_sel = 0
					renderLoadRom(cfg)
				elseif (RIGHT(name$,4) = ".ch8")
					SetSpriteVisible(cfg.sprMenu, 0)
					SetSpriteVisible(cfg.sprDisplay, 1)
					loadNewRom = 1
				endif
			endif
		endcase
		case 2:
			cfg.stage = 0
		endcase
		case 3:
			cfg.stage = 0
		endcase
	endselect

	Sync()

endfunction loadNewRom


type MenuConfig
	imgId
	
	w
	h
	
	font
	
	txtRSM
	txtLR
	txtHLP
	txtABT
	
	btnUP
	btnDN
	btnSEL
	
	selIdx
endtype

function initMenu(cfg ref as MenuConfig, imgId, btnUP, btnDN, btnSEL)
	cfg.w = 448
	cfg.h = 224
	cfg.imgId = imgId
	cfg.font = LoadFont("DisposableDroidBB.otf")
	cfg.btnUP = btnUP
	cfg.btnDN = btnDN
	cfg.btnSEL = btnSEL
	cfg.selIdx = 0
	
	cfg.txtRSM = CreateText("RESUME")
	SetTextPosition(cfg.txtRSM, 224, 60)
	SetTextFont(cfg.txtRSM, cfg.font)
	SetTextSize(cfg.txtRSM, 20)
	SetTextColor(cfg.txtRSM,32,60,50,0xff)
	SetTextAlignment(cfg.txtRSM, 1)
	SetTextVisible(cfg.txtRSM, 0)
	
	cfg.txtLR = CreateText("LOAD ROM")
	SetTextPosition(cfg.txtLR, 224, 90)
	SetTextFont(cfg.txtLR, cfg.font)
	SetTextSize(cfg.txtLR, 20)
	SetTextColor(cfg.txtLR,32,60,50,0xff)
	SetTextAlignment(cfg.txtLR, 1)
	SetTextVisible(cfg.txtLR, 0)

	cfg.txtHLP = CreateText("HELP")
	SetTextPosition(cfg.txtHLP, 224,120)
	SetTextFont(cfg.txtHLP, cfg.font)
	SetTextSize(cfg.txtHLP, 20)
	SetTextColor(cfg.txtHLP,32,60,50,0xff)
	SetTextAlignment(cfg.txtHLP, 1)
	SetTextVisible(cfg.txtHLP, 0)
	
	cfg.txtABT = CreateText("ABOUT")
	SetTextPosition(cfg.txtABT, 224,150)
	SetTextFont(cfg.txtABT, cfg.font)
	SetTextSize(cfg.txtABT, 20)
	SetTextColor(cfg.txtABT,32,60,50,0xff)
	SetTextAlignment(cfg.txtABT, 1)
	SetTextVisible(cfg.txtABT, 0)	

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
	
	SetTextVisible(cfg.txtRSM, 1)
	SetTextColor(cfg.txtRSM,32,60,50,0xff)
	if cfg.selIdx = 0 then SetTextColor(cfg.txtRSM,0xff,0xff,0xff,0xff)
	DrawText(cfg.txtRSM)
	SetTextVisible(cfg.txtRSM, 0)
	
	SetTextVisible(cfg.txtLR, 1)
	SetTextColor(cfg.txtLR,32,60,50,0xff)
	if cfg.selIdx = 1 then SetTextColor(cfg.txtLR,0xff,0xff,0xff,0xff)
	DrawText(cfg.txtLR)
	SetTextVisible(cfg.txtLR, 0)
	
	SetTextVisible(cfg.txtHLP, 1)
	SetTextColor(cfg.txtHLP,32,60,50,0xff)
	if cfg.selIdx = 2 then SetTextColor(cfg.txtHLP,0xff,0xff,0xff,0xff)
	DrawText(cfg.txtHLP)
	SetTextVisible(cfg.txtHLP, 0)
	
	SetTextVisible(cfg.txtABT, 1)
	SetTextColor(cfg.txtABT,32,60,50,0xff)
	if cfg.selIdx = 3 then SetTextColor(cfg.txtABT,0xff,0xff,0xff,0xff)
	DrawText(cfg.txtABT)
	SetTextVisible(cfg.txtABT, 0)
	
	SetRenderToScreen()
	SetClearColor(0,0,0)
	SetVirtualResolution(virtWidth,virtHeight)
endfunction

function menuLoop(cfg ref as MenuConfig)
		
	if (GetVirtualButtonReleased(cfg.btnUP) = 1)
		if cfg.selIdx > 0 then dec cfg.selIdx
		renderMenu(cfg)
	endif

	if (GetVirtualButtonReleased(cfg.btnDN) = 1) 
		if cfg.selIdx < 3 then inc cfg.selIdx
		renderMenu(cfg)
	endif

	if (GetVirtualButtonReleased(cfg.btnSEL) = 1) 
		
		renderMenu(cfg)
	endif

	Sync()

endfunction

Type BeepConfig
	sndLongBeep
	sndShortBeep
	beeping
EndType

function beep_config_init(cfg ref as BeepConfig)
	
	cfg.sndShortBeep = LoadSoundOGG("short_beep.ogg")
	cfg.sndLongBeep = LoadMusicOGG("long_beep.ogg")
	cfg.beeping = 0

endfunction

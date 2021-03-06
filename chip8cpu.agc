type chip8cpu
	V as integer[15]
	user_flags as integer[7]
	disp as integer /* memblock id */
	mem as integer /* memblock id */
	stack as integer[23]
	
	I as integer
	pc as integer // program counter
	opcode as integer
	sp as integer // stack pointer
	
	delay_timer as integer
	sound_timer as integer
	
	disp_width as integer
	disp_height as integer
	
	/* emulation mode
	 * 0 - CHIP8
	 * 1 - CHIP8 HiRES
	 * 2 - SCHIP */
	mode as integer
	
	rom as integer

	draw_flag as integer
	skip_frame as integer
endtype

global chip8_font_8x5 as integer[79] = [
  0xF0, 0x90, 0x90, 0x90, 0xF0, /* 0 */
  0x20, 0x60, 0x20, 0x20, 0x70, /* 1 */
  0xF0, 0x10, 0xF0, 0x80, 0xF0, /* 2 */
  0xF0, 0x10, 0xF0, 0x10, 0xF0, /* 3 */
  0x90, 0x90, 0xF0, 0x10, 0x10, /* 4 */
  0xF0, 0x80, 0xF0, 0x10, 0xF0, /* 5 */
  0xF0, 0x80, 0xF0, 0x90, 0xF0, /* 6 */
  0xF0, 0x10, 0x20, 0x40, 0x40, /* 7 */
  0xF0, 0x90, 0xF0, 0x90, 0xF0, /* 8 */
  0xF0, 0x90, 0xF0, 0x10, 0xF0, /* 9 */
  0xF0, 0x90, 0xF0, 0x90, 0x90, /* A */
  0xE0, 0x90, 0xE0, 0x90, 0xE0, /* B */
  0xF0, 0x80, 0x80, 0x80, 0xF0, /* C */
  0xE0, 0x90, 0x90, 0x90, 0xE0, /* D */
  0xF0, 0x80, 0xF0, 0x80, 0xF0, /* E */
  0xF0, 0x80, 0xF0, 0x80, 0x80  /* F */ ]
  
global chip8_font_8x10 as integer[159] = [
	0x3E, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41,
	0x41, 0x3E, 0x08, 0x18, 0x28, 0x48, 0x08, 0x08,
	0x08, 0x08, 0x08, 0x7F, 0x3E, 0x41, 0x41, 0x41,
	0x01, 0x02, 0x1C, 0x20, 0x41, 0x7F, 0x3E, 0x41,
	0x01, 0x01, 0x1E, 0x01, 0x01, 0x01, 0x41, 0x3E,
	0x02, 0x06, 0x0A, 0x12, 0x22, 0x42, 0x82, 0xFF,
	0x02, 0x1F, 0x7F, 0x40, 0x40, 0x40, 0x7E, 0x01,
	0x01, 0x01, 0x81, 0x7E, 0x1F, 0x20, 0x40, 0x40,
	0x7E, 0x41, 0x41, 0x41, 0x41, 0x3E, 0x7F, 0x41,
	0x02, 0x02, 0x04, 0x04, 0x08, 0x08, 0x10, 0x10,
	0x3E, 0x41, 0x41, 0x41, 0x3E, 0x41, 0x41, 0x41,
	0x41, 0x3E, 0x3E, 0x41, 0x41, 0x41, 0x41, 0x3F,
	0x01, 0x01, 0x02, 0x7C, 0x70, 0x18, 0x24, 0x42,
	0x42, 0x7E, 0x42, 0x42, 0x42, 0xE7, 0xFE, 0x41,
	0x41, 0x41, 0x7E, 0x41, 0x41, 0x41, 0x41, 0xFE,
	0x3E, 0x41, 0x41, 0x40, 0x40, 0x40, 0x40, 0x41,
	0x41, 0x3E, 0xFC, 0x42, 0x41, 0x41, 0x41, 0x41,
	0x41, 0x41, 0x42, 0xFC, 0xFF, 0x41, 0x40, 0x44,
	0x7C, 0x44, 0x40, 0x40, 0x41, 0xFF, 0xFF, 0x41,
	0x41, 0x44, 0x7C, 0x44, 0x40, 0x40, 0x40, 0xFC ]

function chip8emu_clear_disp(cpu ref as chip8cpu)
	DeleteMemblock(cpu.disp)
	cpu.disp = CreateMemblock(cpu.disp_width * cpu.disp_height)
endfunction

function chip8emu_init(cpu ref as chip8cpu)
	for i = 0 to cpu.V.length
		cpu.V[i] = 0
	next i
	
	DeleteMemblock(cpu.mem)
	cpu.mem = CreateMemblock(4096)
	
	/* Load fontset */
    for i = 0 to chip8_font_8x5.length
		SetMemblockByte(cpu.mem, i, chip8_font_8x5[i])
    next i
    /*
    for i = 0 to chip8_font_8x10.length
		SetMemblockByte(cpu.mem, 80 + i, chip8_font_8x10[i])
    next i*/
	
	for i = 0 to cpu.stack.length
		cpu.stack[i] = 0
	next i
	
	cpu.I = 0
	cpu.pc = 0x200
	cpu.opcode = 0
	cpu.sp = 0
	cpu.delay_timer = 0
	cpu.sound_timer = 0
	cpu.mode = 0
	
	cpu.disp_width = 64
	cpu.disp_height = 32
	cpu.skip_frame = 0
	cpu.draw_flag = 1
	chip8emu_clear_disp(cpu)
	
	/* load rom if available */
	if cpu.rom > 0 
		if GetMemblockSize(cpu.rom) > 0 then CopyMemblock(cpu.rom, cpu.mem, 0, 0x200, GetMemblockSize(cpu.rom))
	endif
endfunction

function chip8emu_load_rom(cpu ref as chip8cpu, filename$)
    if cpu.rom > 0 then DeleteMemblock(cpu.rom)
    cpu.rom = CreateMemblockFromFile(filename$)
endfunction

function chip8emu_timer_tick(cpu ref as chip8cpu)
	if cpu.delay_timer > 0 then dec cpu.delay_timer
	if cpu.sound_timer > 0 then dec cpu.sound_timer
endfunction

function chip8emu_exec_cycle(cpu ref as chip8cpu)
	cpu.opcode = GetMemblockByte(cpu.mem, cpu.pc) << 8 || GetMemblockByte(cpu.mem, cpu.pc + 1)
	
	select (cpu.opcode && 0xF000)
		case 0x0000:
			select (cpu.opcode)
				case 0x00E0: /* clear screen */
					chip8emu_clear_disp(cpu)
					inc cpu.pc, 2
				endcase

				case 0x00EE: /* subroutine return */
					dec cpu.sp
					cpu.pc = cpu.stack[cpu.sp && 0xF] + 2
				endcase
				
				case 0x00FB: /* SCHIP: scroll screen 4 pixels right */
					for y = cpu.disp_height - 1 to 0 step -1
						for x = cpu.disp_width - 1 to 0 step -1
							dx = x - 4
							SetMemblockByte(cpu.disp, y*cpu.disp_width + x, GetMemblockByte(cpu.disp,y*cpu.disp_width + dx))
						next x
					next y
					
					for y = 0 to cpu.disp_height - 1
						for x = 0 to 3
							SetMemblockByte(cpu.disp, y*cpu.disp_width + x, 0)
						next x
					next y
					
					if cpu.V[0xF] = 0
						if cpu.skip_frame = 0 then cpu.draw_flag = 1
					else
						/* VF = 1 */
						if cpu.skip_frame = 0 then cpu.skip_frame = 3
					endif
					
					inc cpu.pc, 2
				endcase
				
				case 0x00FC: /* SCHIP: scroll screen 4 pixels left */
					for y = 0 to cpu.disp_height - 1
						for x = 4 to cpu.disp_width - 1
							dx = x - 4
							SetMemblockByte(cpu.disp, y*cpu.disp_width + dx, GetMemblockByte(cpu.disp,y*cpu.disp_width + x))
						next x
					next y
					
					for y = 0 to cpu.disp_height - 1
						for x = cpu.disp_width - 1 to cpu.disp_width - 4 step -1
							SetMemblockByte(cpu.disp, y*cpu.disp_width + x, 0)
						next x
					next y
					
					if cpu.V[0xF] = 0
						if cpu.skip_frame = 0 then cpu.draw_flag = 1
					else
						/* VF = 1 */
						if cpu.skip_frame = 0 then cpu.skip_frame = 3
					endif
					
					inc cpu.pc, 2
				endcase
				
				case 0x00FE: /* SCHIP: disable extended screen mode  */
					if not cpu.mode = 0
						cpu.mode = 0
						cpu.disp_width = 64
						cpu.disp_height = 32
						chip8emu_clear_disp(cpu)
					endif
					inc cpu.pc, 2
				endcase
				
				case 0x00FF: /* SCHIP: enable extended screen mode (128 x 64)  */
					if not cpu.mode = 2
						cpu.mode = 2
						cpu.disp_width = 128
						cpu.disp_height = 64
						chip8emu_clear_disp(cpu)
					endif
					inc cpu.pc, 2
				endcase
				
				case 0x0230: /* HI-RES: clear screen */
					chip8emu_clear_disp(cpu)
					inc cpu.pc, 2
				endcase

				case default: 
					if cpu.opcode && 0xF0 = 0xC0 /* SCHIP: scroll the screen down N lines */
						N = cpu.opcode && 0x000F
						displen = cpu.disp_width * cpu.disp_height
						rmbytes = N * cpu.disp_width
						new_disp = CreateMemblock(displen)
						CopyMemblock(cpu.disp, new_disp, 0, rmbytes, displen - rmbytes)
						DeleteMemblock(cpu.disp)
						cpu.disp = new_disp
						inc cpu.pc, 2
					else
						/* 0NNN: call program at NNN address */
						`message("Unknown opcode " + Str(cpu.opcode))
					endif
				endcase
			endselect
		endcase
		
		case 0x1000: /* 1NNN: absolute jump */
			if (cpu.pc = 0x200) and ((GetMemblockByte(cpu.mem, 0x200) << 8 || GetMemblockByte(cpu.mem, 0x201)) = 0x1260)
				/* 64x64 hi-res mode */
				cpu.mode = 1
				cpu.disp_width = 64
				cpu.disp_height = 64
				cpu.pc = 0x2C0  /* Make the interperter jump to address 0x2c0 */
				chip8emu_clear_disp(cpu)
			else
				cpu.pc = cpu.opcode && 0xFFF
			endif
		endcase
		
		case 0x2000: /* 2NNN: call subroutine */
			cpu.stack[cpu.sp] = cpu.pc
			inc cpu.sp
			cpu.pc = cpu.opcode && 0x0FFF
		endcase
		
		case 0x3000: /* 3XNN: Skips the next instruction if VX equals NN */
			if (cpu.V[(cpu.opcode && 0x0F00) >> 8] = (cpu.opcode && 0x00FF))
				inc cpu.pc, 4
			else
				inc cpu.pc, 2
			endif
		endcase
		
		case 0x4000: /* 4XNN: Skips the next instruction if VX doesn't equal NN */
			if not (cpu.V[(cpu.opcode && 0x0F00) >> 8] = (cpu.opcode && 0x00FF))
				inc cpu.pc, 4
			else
				inc cpu.pc, 2
			endif
		endcase
		
		case 0x5000: /* 5XY0: Skips the next instruction if VX equals VY */
			if (cpu.V[(cpu.opcode && 0x0F00) >> 8] = cpu.V[(cpu.opcode && 0x00F0) >> 4])
				inc cpu.pc, 4
			else
				inc cpu.pc, 2
			endif
		endcase
		
		case 0x6000: /* 6XNN: Sets VX to NN */
			cpu.V[(cpu.opcode && 0x0F00) >> 8] = cpu.opcode && 0x00FF
			inc cpu.pc, 2
		endcase
		
		case 0x7000: /* 7XNN: Adds NN to VX */
			X = (cpu.opcode && 0x0F00) >> 8
			inc cpu.V[X], (cpu.opcode && 0x00FF)
			cpu.V[X] = mod(cpu.V[X], 256)
			inc cpu.pc, 2
		endcase
		
		case 0x8000:
			select (cpu.opcode && 0x000F)
				case 0x0000: /* 8XY0: Vx = Vy  */
					cpu.V[(cpu.opcode && 0x0F00) >> 8] = cpu.V[(cpu.opcode && 0x00F0) >> 4]
					inc cpu.pc, 2
				endcase
				case 0x0001: /* 8XY1: Vx = Vx | Vy */
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.V[X] = cpu.V[X] || cpu.V[(cpu.opcode && 0x00F0) >> 4]
					inc cpu.pc, 2
				endcase
				case 0x0002: /* 8XY2: Vx = Vx && Vy*/
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.V[X] = cpu.V[X] && cpu.V[(cpu.opcode && 0x00F0) >> 4]
					inc cpu.pc, 2
				endcase
				case 0x0003: /* 8XY3: Vx = Vx XOR Vy */
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.V[X] = cpu.V[X] ~~ cpu.V[(cpu.opcode && 0x00F0) >> 4]
					inc cpu.pc, 2
				endcase
				case 0x0004: /* 8XY4: Vx += Vy Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't */
					X = (cpu.opcode && 0x0F00) >> 8
					Y = (cpu.opcode && 0x00F0) >> 4
					
					if(cpu.V[Y] > (0xFF - cpu.V[X]))
						cpu.V[0xF] = 1 /* carry over */
					else
						cpu.V[0xF] = 0
					endif
					
					cpu.V[X] = mod(cpu.V[X] + cpu.V[Y], 256)
					inc cpu.pc, 2
				endcase
				case 0x0005: /* 8XY5: Vx -= Vy VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't */
					X = (cpu.opcode && 0x0F00) >> 8
					Y = (cpu.opcode && 0x00F0) >> 4
					
					if (cpu.V[Y] > cpu.V[X])
						cpu.V[0xF] = 0
						cpu.V[X] = 256 - (cpu.V[Y] - cpu.V[X])
					else
						cpu.V[0xF] = 1
						dec cpu.V[X], cpu.V[Y]
					endif
					
					inc cpu.pc, 2
				endcase
				case 0x0006: /* 8XY6: Vx>>=1 Stores the least significant bit of VX in VF and then shifts VX to the right by 1 */
					
					/* Vx = Vy >> 1
					 * Store the value of register VY shifted right one bit in register VX
					 * Set register VF to the least significant bit prior to the shift
					 */
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.V[0xF] = cpu.V[X] && 0x1
					cpu.V[X] = cpu.V[X] >> 1
					inc cpu.pc, 2
				endcase
				case 0x0007: /* 8XY7: Vx=Vy-Vx Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't */
					X = (cpu.opcode && 0x0F00) >> 8
					Y = (cpu.opcode && 0x00F0) >> 4
					
					if (cpu.V[X] > cpu.V[Y])
						cpu.V[0xF] = 0
						cpu.V[X] = 256 - (cpu.V[Y] - cpu.V[X])
					else
						cpu.V[0xF] = 1
						cpu.V[X] = cpu.V[Y] - cpu.V[X]
					endif
					
					inc cpu.pc, 2
				endcase
				case 0x000E: /* 8XYE: Vx<<=1 Stores the most significant bit of VX in VF and then shifts VX to the left by 1 */
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.V[0xF] = cpu.V[X] >> 7
					cpu.V[X] = cpu.V[X] << 1
					cpu.V[X] = mod(cpu.V[X], 256)
					inc cpu.pc, 2
				endcase
				case default:
					`message("Unknown opcode " + Str(cpu.opcode))
				endcase
			endselect
		endcase
		
		case 0x9000: /* 9XY0: Skips the next instruction if VX doesn't equal VY */
			if not (cpu.V[(cpu.opcode && 0x0F00) >> 8] = cpu.V[(cpu.opcode && 0x00F0) >> 4])
				inc cpu.pc, 4
			else
				inc cpu.pc, 2
			endif
		endcase
		
		case 0xA000: /* ANNN: Sets I to the address NNN */
			cpu.I = cpu.opcode && 0x0FFF
			inc cpu.pc, 2
		endcase
		
		case 0xB000: /* BNNN: Jumps to the address NNN plus V0 */
			cpu.pc = (cpu.opcode && 0x0FFF) + cpu.V[0]
		endcase
		
		case 0xC000: /* CXNN: Vx=rand() && NN */
			X = (cpu.opcode && 0x0F00) >> 8
			cpu.V[X] = Mod(Random(), (0xFF + 1)) && (cpu.opcode && 0x00FF)
			inc cpu.pc, 2
		endcase
		
		case 0xD000: /* DXYN: draw(Vx,Vy,N) draw at X,Y width 8, height N sprite from I register */
			xo = cpu.V[(cpu.opcode && 0x0F00) >> 8] /* x origin */
			yo = cpu.V[(cpu.opcode && 0x00F0) >> 4]
			height = cpu.opcode && 0x000F
			sprite as integer[15]
			width = 8
			pad = 0x80 /* 10000000b */
			
			if height = 0 
				height = 16
				if cpu.mode = 2
					/* SCHIP sprite */
					width = 16
					pad = 0x8000
				endif
			endif
			
			for i = 0 to height - 1
				if cpu.mode = 2 and height = 16
					sprite[i] = GetMemblockByte(cpu.mem, cpu.I + i*2) << 8
					sprite[i] = sprite[i] || GetMemblockByte(cpu.mem, cpu.I + i*2 + 1)
				else
					sprite[i] = GetMemblockByte(cpu.mem, cpu.I + i)
				endif
			next i

			cpu.V[0xF] = 0
			for y = 0 to height - 1
				for x = 0 to width - 1
					dx = Mod(xo + x, cpu.disp_width) /* display x or dest x*/
					dy = Mod(yo + y,  cpu.disp_height)
					if not ((sprite[y] && (pad >> x)) = 0) 
						offset = dx + (dy * cpu.disp_width)
						pixel = GetMemblockByte(cpu.disp, offset)
						if (cpu.V[0xF] = 0) and (pixel > 0) then cpu.V[0xF] = 1
						SetMemblockByte(cpu.disp, offset, pixel ~~ 1)
					endif
				next x
			next y
			
			
			if cpu.V[0xF] = 0
				if cpu.skip_frame = 0 then cpu.draw_flag = 1
			else
				/* VF = 1 */
				if cpu.skip_frame = 0 then cpu.skip_frame = 3
			endif
			
			inc cpu.pc, 2
		endcase
		
		case 0xE000:
			select (cpu.opcode && 0x00FF)
				case 0x009E: /* EX9E: Skips the next instruction if the key stored in VX is pressed */
					if (chip8emu_get_keystate(cpu, cpu.V[(cpu.opcode && 0x0F00) >> 8]) > 0)
						inc cpu.pc, 4
					else
						inc cpu.pc, 2
					endif
				endcase
				case 0x00A1: /* EXA1: Skips the next instruction if the key stored in VX isn't pressed */
					if not (chip8emu_get_keystate(cpu, cpu.V[(cpu.opcode && 0x0F00) >> 8]) > 0)
						inc cpu.pc, 4
					else
						inc cpu.pc, 2
					endif
				endcase
				case default:
					`message("Unknown opcode " + Str(cpu.opcode))
				endcase
			endselect			
		endcase
		
		case 0xF000:
			select (cpu.opcode && 0x00FF)
				case 0x0007: /* FX07: Sets VX to the value of the delay timer */
					cpu.V[(cpu.opcode && 0x0F00) >> 8] = cpu.delay_timer
					inc cpu.pc, 2
				endcase
				case 0x000A: /* FX0A: A key press is awaited, and then stored in VX. (blocking) */
					X = (cpu.opcode && 0x0F00) >> 8
					for i = 0 to 0xF
						if (chip8emu_get_keystate(cpu, i) > 0)
							cpu.V[X] = mod(i, 0x10)
							inc cpu.pc, 2
							exit
						endif
					next i
				endcase
				case 0x0015: /* FX15: Sets the delay timer to VX */
					cpu.delay_timer = cpu.V[(cpu.opcode && 0x0F00) >> 8]
					inc cpu.pc, 2
				endcase
				case 0x0018: /* FX18: Sets the sound timer to VX */
					cpu.sound_timer = cpu.V[(cpu.opcode && 0x0F00) >> 8]
					inc cpu.pc, 2
				endcase
				case 0x001E: /* FX1E: Add VX to I register */
					inc cpu.I, cpu.V[(cpu.opcode && 0x0F00) >> 8]
					cpu.I = Mod(cpu.I, 0xFFFF)
					inc cpu.pc, 2
				endcase
				case 0x0029: /* FX29: I=sprite_addr[Vx] Sets I to the location of the sprite for the character in VX */
					cpu.I = cpu.V[(cpu.opcode && 0x0F00) >> 8] * 5
					inc cpu.pc, 2
				endcase
				case 0x0030: /* FX30: SCHIP: I=sprite_addr[Vx] Sets I to the location of the sprite for the character in VX Sprite is 10 bytes high */
					cpu.I = 0x50 + (cpu.V[(cpu.opcode && 0x0F00) >> 8] * 10)
					inc cpu.pc, 2
				endcase
				case 0x0033: /* FX33: Store a Binary Coded Decimal (BCD) of register VX to memory started from I */
					X = (cpu.opcode && 0x0F00) >> 8
					SetMemblockByte(cpu.mem, cpu.I,cpu.V[X] / 100)
					SetMemblockByte(cpu.mem, cpu.I + 1, Mod(cpu.V[X] / 10, 10))
					SetMemblockByte(cpu.mem, cpu.I + 2, Mod(cpu.V[X], 10))
					inc cpu.pc, 2
				endcase
				case 0x0055: /* FX55: */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						SetMemblockByte(cpu.mem, cpu.I+i, cpu.V[i])
					next i

					`inc cpu.I, X + 1
					inc cpu.pc, 2
				endcase
				case 0x0065: /* FX65: */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						cpu.V[i] = GetMemblockByte(cpu.mem, cpu.I + i)
					next i
					
					`inc cpu.I, X + 1
					inc cpu.pc, 2
				endcase
				case 0x0075: /* FX75: Store V0..VX in RPL user flags (X<=7) */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						cpu.user_flags[i] = cpu.V[i]
					next i
					
					inc cpu.pc, 2
				endcase
				case 0x0085: /* FX85: Read V0..VX from RPL user flags (X<=7) */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						cpu.V[i] = cpu.user_flags[i]
					next i
					
					inc cpu.pc, 2
				endcase
				case default:
					`message("Unknown opcode " + Str(cpu.opcode))
				endcase
			endselect
		endcase
	endselect
endfunction

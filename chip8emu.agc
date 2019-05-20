type chip8cpu
	V as integer[15]
	disp as integer[2047]
	mem as integer[4095]
	stack as integer[23]
	keystate as integer[15]
	
	I as integer
	pc as integer // program counter
	opcode as integer
	sp as integer // stack pointer
	
	delay_timer as integer
	sound_timer as integer

	draw_flag as integer
endtype

global chip8_fontset as integer[79] = [
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

function chip8emu_clear_disp(cpu ref as chip8cpu)
	for i = 0 to cpu.disp.length
		cpu.disp[i] = 0
	next i
	cpu.draw_flag = 1
endfunction

function chip8emu_init(cpu ref as chip8cpu)
	for i = 0 to cpu.V.length
		cpu.V[i] = 0
		cpu.keystate[i] = 0
	next i
	
	for i = 0 to cpu.disp.length
		cpu.disp[i] = 0
	next i
	
	chip8emu_clear_disp(cpu)
	
	/* Load fontset */
    for i = 0 to i < chip8_fontset.length
        cpu.mem[i] = chip8_fontset[i]
    next i
	
	for i = 0 to cpu.stack.length
		cpu.stack[i] = 0
	next i
	
	cpu.I = 0
	cpu.pc = 0x200
	cpu.opcode = 0
	cpu.sp = 0
	cpu.delay_timer = 0
	cpu.sound_timer = 0
	cpu.draw_flag = 1
endfunction

function chip8emu_load_rom(cpu ref as chip8cpu, filename$)
    romFile = OpenToRead(fileName$)
    idx = 0x200
    
    while FileEOF(romFile) = 0
        cpu.mem[idx] = ReadByte(romFile)
        idx = idx + 1
    endwhile
endfunction

function chip8emu_timer_tick(cpu ref as chip8cpu)
	if cpu.delay_timer > 0 then dec cpu.delay_timer
	if cpu.sound_timer > 0 then dec cpu.sound_timer
endfunction

function chip8emu_exec_cycle(cpu ref as chip8cpu)
	cpu.opcode = cpu.mem[cpu.pc] << 8 || cpu.mem[cpu.pc + 1]
	
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

				case default: /* 0NNN: call program at NNN address */
				endcase
			endselect
		endcase
		
		case 0x1000: /* 1NNN: absolute jump */
			cpu.pc = cpu.opcode && 0xFFF
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
			
			for i = 0 to height - 1
				sprite[i] = cpu.mem[cpu.I + i]
			next i

			cpu.V[0xF] = 0
			for y = 0 to height - 1
				for x = 0 to 8 - 1
					dx = Mod(xo + x, 64) /* display x or dest x*/
					dy = Mod(yo + y, 32)
					if not ((sprite[y] && (0x80 >> x)) = 0) /* 0x80 -> 10000000b */
						if cpu.V[0xF] = 0 and cpu.disp[(dx + (dy * 64))] > 0 then cpu.V[0xF] = 1
						cpu.disp[dx + (dy * 64)] = cpu.disp[dx + (dy * 64)] ~~ 1
					endif
				next x
			next y

			cpu.draw_flag = 1
			inc cpu.pc, 2
		endcase
		
		case 0xE000:
			select (cpu.opcode && 0x00FF)
				case 0x009E: /* EX9E: Skips the next instruction if the key stored in VX is pressed */
					if (cpu.keystate[ cpu.V[(cpu.opcode && 0x0F00) >> 8] ] > 0)
						inc cpu.pc, 4
					else
						inc cpu.pc, 2
					endif
				endcase
				case 0x00A1: /* EXA1: Skips the next instruction if the key stored in VX isn't pressed */
					if not (cpu.keystate[ cpu.V[(cpu.opcode && 0x0F00) >> 8] ] > 0)
						inc cpu.pc, 4
					else
						inc cpu.pc, 2
					endif
				endcase
				case default:
					Log("Unknown opcode")
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
					for i = 0 to cpu.keystate.length
						if (cpu.keystate[i] > 0)
							cpu.V[(cpu.opcode && 0x0F00) >> 8] = i
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
					inc cpu.pc, 2
				endcase
				case 0x0029: /* FX29: I=sprite_addr[Vx] Sets I to the location of the sprite for the character in VX */
					cpu.I = cpu.V[(cpu.opcode && 0x0F00) >> 8] * 5
					inc cpu.pc, 2
				endcase
				case 0x0033: /* FX33: Store a Binary Coded Decimal (BCD) of register VX to memory started from I */
					X = (cpu.opcode && 0x0F00) >> 8
					cpu.mem[cpu.I]     = cpu.V[X] / 100
					cpu.mem[cpu.I + 1] = Mod(cpu.V[X] / 10, 10)
					cpu.mem[cpu.I + 2] = Mod(cpu.V[X], 10)
					inc cpu.pc, 2
				endcase
				case 0x0055: /* FX55: */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						cpu.mem[cpu.I+i] = cpu.V[i]
					next i

					inc cpu.I, X + 1
					inc cpu.pc, 2
				endcase
				case 0x0065: /* FX65: */
					X = (cpu.opcode && 0x0F00) >> 8
					
					for i = 0 to X
						cpu.V[i] = cpu.mem[cpu.I + i]
					next i
					
					inc cpu.I, X + 1
					inc cpu.pc, 2
				endcase
				case default:
					Log("Unknown opcode")
				endcase
			endselect
		endcase
		
	endselect

endfunction


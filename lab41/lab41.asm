.include "m328pdef.inc"

init:
	LDI R16, 0b11110011
	OUT DDRD, R16
	LDI R16, 0b00111111
	OUT DDRB, R16
	LDI R16, 0b00000000
	OUT DDRC, R16

	ldi r16, 0b10101010
	ldi r17, 0b00001010

	ldi r18, 0b01010101

	clr r24
	clr r25


main:
	IN R23, PINC
	CPI R23, 0b00010000
	breq s1
	CPI R23, 0b00100000
	breq s2

	RJMP print
s1:
	rcall s1_proceed
	RJMP print
s2:
	rcall s2_proceed
	RJMP print

print:
	mov r24, r16
	mov r25, r17

	lsl r24
	rol r25
	lsl r24
	rol r25

	mov r26, r24
	andi r24, 0b11110000
	andi r26, 0b00001111
	lsr r26
	lsr r26
	or r24, r26

	OUT PORTD, R24
	OUT PORTB, R25
	rjmp main


s1_proceed:
	LDI R19, 0x00
	LDI R20, 0xC4
	LDI R21, 0x09

	brbs 6, skip_s1_set
	ldi r16, 0b00000000
	ldi r17, 0b00001000
	bset 6
	rjmp ret_s1
skip_s1_set:

	ror r17
	ror r16
	brcc skip_shift
	ror r17
	ror r17
	ror r17
	ror r17
	ror r17
skip_shift:

	rcall delay
ret_s1:	ret

s2_proceed:
	LDI R19, 0x00
	LDI R20, 0x27
	LDI R21, 0x38

	brbc 6, skip_s2_set
	ldi r16, 0b10101010
	ldi r17, 0b00001010
	bclr 6
	rjmp ret_s2
skip_s2_set:

	eor r16, r18
	eor r17, r18

	rcall delay
ret_s2:	ret

delay:.
	SUBI R19, 0x01
	SBCI R20, 0x00
	SBCI R21, 0x00
	BRCC delay
	ret

;In clear timer on compare or CTC mode (WGM02:0 = 2), the OCR0A register is used to manipulate the counter resolution. In
;CTC mode the counter is cleared to zero when the counter value (TCNT0) matches the OCR0A. The OCR0A defines the top
;value for the counter, hence also its resolution.


.include "m328pdef.inc"

.cseg
.org 0x0000 jmp Reset
.org 0x0020 jmp TIMER0_OVF

.org INT_VECTORS_SIZE

Reset:
	ldi R16, Low(RAMEND)
	out SPL, R16
	ldi R16, High(RAMEND)
	out SPH, R16

	ldi R16, 0b00000001
	sts TIMSK0, r16
	sei

	ldi R20, 0x00
	out TCNT0, R20
	;configure timer (CTC MODE: WGM02=1) 1.1
	ldi R16, 0b00001101 ; CS02=1, CS01=0, CS00=1 => clc/1024 ~ 62500t/sec => 1 timer clock ~ 16mks
	out TCCR0B, R16
	;configure max TCNT0 value 
	ldi r16, 0x7D ;overflow after 125 clock ~ 8ms
	out OCR0A, r16
	ldi r16, 0x00
	out OCR0B, r16
	;configure output
	LDI R16, 0b11110011
	OUT DDRD, R16
	LDI R16, 0b00111111
	OUT DDRB, R16
	LDI R16, 0b00000000
	OUT DDRC, R16

	ldi r16, 0b10101010
	ldi r17, 0b00001010

	ldi r18, 0b01010101

	clr r20

off:
	clr r19
	clr r21
main:
	IN R23, PINC
	CPI R23, 0b00000000
	breq off
	CPI R23, 0b00110000
	breq off

	cp R19, r21
	brne main

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

	clr r19
	rjmp main


TIMER0_OVF:
	inc R19
	out TCNT0, R20
	reti


s1_proceed:
	ldi r21, 0x19
	clr r19
	brbs 6, skip_s1_set
	ldi r16, 0b00000000
	ldi r17, 0b00001000
	bset 6
	rjmp ret_s1
skip_s1_set:
	ror r17
	ror r16
	brcc ret_s1
	ror r17
	ror r17
	ror r17
	ror r17
	ror r17
ret_s1:	ret


s2_proceed:
	ldi r21, 0x90
	clr r19
	brbc 6, skip_s2_set
	ldi r16, 0b10101010
	ldi r17, 0b00001010
	bclr 6
	rjmp ret_s2
skip_s2_set:
	eor r16, r18
	eor r17, r18
ret_s2:	ret

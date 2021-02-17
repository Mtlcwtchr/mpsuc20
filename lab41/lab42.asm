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

	ldi R16, 0b00000011
	sts TIMSK0, r16
	sei

	ldi R20, 0x00
	out TCNT0, R20
	;configure timer (CTC MODE: WGM01=1) 1.1
	ldi R16, 0b00000010
	out TCCR0A, R16
	ldi R16, 0b00000101
	out TCCR0B, R16

	;configure output
	LDI R16, 0b11110011
	OUT DDRD, R16
	LDI R16, 0b00111111
	OUT DDRB, R16
	LDI R16, 0b00000000
	OUT DDRC, R16

	ldi r18, 0b01010101

clear_cmprs:
	clr r20
	clr r21
clear_counter:
	clr r19
main:
	;if none pressed or pressed both skip
	IN R23, PINC
	CPI R23, 0b00000000
	breq clear_cmprs
	CPI R23, 0b00110000
	breq clear_cmprs
delay:
	cp R19, r21
	brne delay

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
	;required cause INT0 and INT1 are clear and output shifted
	rcall modify_out

	OUT PORTD, R24
	OUT PORTB, R25

	rjmp clear_counter


s1_proceed:
	;check if s1-pressed-case-flag set
	cpi r22, 0b00000001
	breq skip_s1_set
	;set output to default for s1-pressed-case
	ldi r16, 0b00000000
	ldi r17, 0b00001000
	;set s1-pressed-case-flag
	ldi r22, 0b00000001

	;configure max TCNT0 value 
	ldi r16, 0x7C
	out OCR0A, r16

	;clear timer and delay counter, set count of skipping overflows to required for s1-pressed-case
	clr r19
	out TCNT0, R20
	ldi r21, 0x19

	;skip 1 iteration
	rjmp ret_s1
skip_s1_set:
	;shift right high
	ror r17
	;shift right low
	ror r16
	brcc ret_s1
	ror r17
	;shift to output
	ror r17
	ror r17
	ror r17
	ror r17
ret_s1:	ret


s2_proceed:
	;check if s2-pressed-case-flag set
	cpi r22, 0b00000010
	;if set skip setting
	breq skip_s2_set
	;set output to default for s2-pressed-case
	ldi r16, 0b10101010
	ldi r17, 0b00001010
	;set s2-pressed-case-flag
	ldi r22, 0b00000010

	;configure max TCNT0 value 
	ldi r16, 0x96
	out OCR0A, r16

	;clear timer and delay counter, set count of skipping overflows to required for s2-pressed-case
	clr r19
	out TCNT0, R20
	ldi r21, 0x77

	;skip 1 iteration
	rjmp ret_s2
skip_s2_set:
	;apply invert mask
	eor r16, r18
	eor r17, r18
ret_s2:	ret

modify_out:
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
ret_modify_out:	ret


TIMER0_OVF:
	inc R19
	out TCNT0, R20
	reti

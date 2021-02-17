.include "m2560def.inc"

init:    
	 ldi r16, 0b00000000 ; configure all PORTB to input
	 out DDRB, r16
	 ldi r16, 0b10000000 ; configure PORTD7 to output
	 out DDRD, r16
	 ldi r17, 0b00100000 ; input mask (5 in)
	 ldi r19, 0b10000000 ; output mask (7 out)

main:
	 ldi r18, 0b10000000 ; out 7th lamp
	 in r16, PINB ; get input
	 cp r16, r17 ; check if input match mask (is 5 in)
	 brcs iftrue ; do nothing if match
	 eor r18, r19 ; drop out
iftrue:
	 out PORTD,r18 ; write out (7 lamp or nothing)
	 rjmp main

.include "m328pdef.inc"

init:   
		ldi r16, 0b00000000
        out DDRC, r16
        ldi r16, 0b11110000
        out DDRD, r16
        ldi r16, 0b00001111
        out DDRB, r16

		ldi r18, 0b00010000
		ldi r19, 0b00001111
		ldi r20, 0b11110000

		ldi r21, 0x11

		clr r16

main:
		sbis PIND, 1
	    clr r16
        
		sbic PINC, 5
        rjmp off
        brbs 6, nozero
        inc r16
nozero:
		bset 6
        rjmp end

off:	bclr 6

end:    
		mov r17, r16
		and r17, r19
		cpi r17, 0b00001010
        brne checklimit
        add r16, r18
		and r16, r20

checklimit:
		cp r16, r21
		brne print
		dec r16
		
print:  
		out PORTB, r16
		out PORTD, r16
        rjmp main

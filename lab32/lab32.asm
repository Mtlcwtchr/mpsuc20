.include "m328pdef.inc"

init:   
		;configure i/o (all pc to input, high pd to output, low pb to output)
		ldi r16, 0b00000000
        out DDRC, r16
        ldi r16, 0b11110000
        out DDRD, r16
        ldi r16, 0b00001111
        out DDRB, r16

		;high-digit increase value
		ldi r18, 0b00010000
		;high-digit clear mask
		ldi r19, 0b00001111
		;low-digit clear mask
		ldi r20, 0b11110000

		;configure limit (limit+1)
		ldi r21, 0x86

		;clear counter
		clr r16

main:
		; check if pc1 clear (clear button pressed)
		sbis PIND, 1
		;clear counter
	    clr r16
        
		;check if pc5 clear (increment button pressed)
		sbic PINC, 5
		;if not do nothing
        rjmp off
		;if true check T flag
        brbs 6, nozero
		;increment counter if clear
        inc r16
nozero:
		;set T flag
		bset 6
		;do nothing
        rjmp end
		;clear T flag
off:	bclr 6

end:    ;save counter to buffer
		mov r17, r16
		;cut out high digits
		and r17, r19
		;check if low digits are equal to A (exceed 9)
		cpi r17, 0b00001010
		;if not check limit
        brne checklimit
		;if true add high digit increment value to counter (increase high-digit)
        add r16, r18
		;cut out low digits
		and r16, r20

checklimit:
		;check if counter exceed max value
		cp r16, r21
		;if not print
		brne print
		;if true decrease counter
		dec r16
		
print:  ;print counter
		out PORTB, r16
		out PORTD, r16
        rjmp main

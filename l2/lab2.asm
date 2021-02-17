.include "m328pdef.inc"

;i=5, j=7, k=1, l=3

rjmp q4

q1:
	ldi r16, 0b10100000 ; set mask
	ldi r17, 0b01011111 ; discard/invert mask

	ldi r24, 0xFF
	;ldi r24, 0xF0
	;ldi r24, 0x0F
	;ldi r24, 0x00

	and r24, r17 ; discard
	or r24, r16 ; set
	eor r24, r16 ; invert


q2:
	ldi r16, 0b00100000 ; check mask
	ldi r17, 0b00010100 ; var=20

	;ldi r24, 0xFF
	ldi r24, 0xF0
	;ldi r24, 0x0F
	;ldi r24, 0x00

	and r24, r16
	cp r24, r16
	brne iftrue
	ldi r18, 0b01010101 ; even invert mask
	eor r17, r18 ; invert even
iftrue:
	sts 0x0285, r17 


q3: ;y=xi*xj+xk*NOT(xl)
	ldi r16, 0b10100000 ; select xi & xj mask
	ldi r17, 0b00001010 ; select xk & xl mask
	ldi r18, 0b00001000 ; invert xl mask
	ldi r19, 0x01 ; predict result is true

	ldi r24, 0x1F
	;ldi r24, 0x2B
	;ldi r24, 0x0C
	;ldi r24, 0xA1

	mov r14, r24
	and r14, r16 ; select xi & xj
	cp r14, r16 ; check if xi & xj
	breq setres
	dec r19

	mov r14, r24
	and r14, r17 ; select xk & xl
	eor r14, r18 ; invert xl
	cp r14, r17 ; check if xk & !xl
	brne setres
	inc r19
	
setres:
	sts 0x0285, r19


q4:
	ldi zl, LOW(array*2)
    ldi zh, HIGH(array*2)

	ldi r17, 0x0A ; number of array elements
	ldi r18, 0x00 ; cycle counter

c1:
	lpm r0, z+

c2:
	lsl r0
	brcc s
	inc r1
s: brne c2
	inc r18
	cp r17, r18
	brne c1

	mov r4, r1
	rjmp end

array: .db 0x0F, 0xFF, 0x77, 0x45, 0xF0, 0xAB, 0x85, 0x49, 0xA0, 0x0A


q5:
	;ldi r24, 0x02
	;ldi r25, 0x00

	;ldi r24, 0x10
	;ldi r25, 0x00

	;ldi r24, 0x00
	;ldi r25, 0x01

	;ldi r24, 0x5B
	;ldi r25, 0xA8

	mov r0, r24
	mov r1, r25

	rjmp div4

mul4:
	ldi r16, 0b00000000
	ldi r17, 0b00000000

	lsl r0
	brcc noinc1
	inc r16
	lsl r16
noinc1:
	lsl r0
	brcc noinc2
	inc r16
noinc2:
	lsl r1
	brcc noinc3
	inc r17
	lsl r17
noinc3:
	lsl r1
	brcc noinc4
	inc r17
noinc4:
	or r1, r16

	sts 0x0385, r17
	sts 0x0386, r1
	sts 0x0387, r0

rjmp endq5

div4:
	lsr r0
	lsr r0

	lsr r1
	brcc noset1
	ldi r16, 0b01000000
	or r0, r16
	clr r16
noset1:
	lsr r1
	brcc noset2
	ldi r16, 0b10000000
	or r0, r16
	clr r16
noset2:

	sts 0x0386, r1
	sts 0x0387, r0
	
endq5:

end: rjmp end

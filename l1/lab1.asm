.include "m328pdef.inc"

rjmp q1

q1:
	;ldi r24, 0x88
	ldi r24, 0x00
	;ldi r24, 0xFF
lds r14, 0x0285
	;add r24, r14
	sub r24, r14
sts 0x0385, r24


q2:
	ldi r16, 0x88
	ldi r24, 0x88
	;ldi r16, 0x00
	;ldi r24, 0x00
	;ldi r16, 0xFF
	;ldi r24, 0xFF
lds r4, 0x0285
lds r14, 0x0286

	;add r24, r14
	;adc r16, r4
	sub r24, r14
	sbc r16, r4

sts 0x0385, r16
sts 0x0386, r24


q3:
ldi r24, 0x85
lds r4, 0x0285
lds r14, 0x0286

mul r14, r24

mov r2, r1
mov r3, r0

mul r4, r24
mov r1, r0
sub r0, r1

add r0, r3
add r1, r2

sts 0x0385, r1
sts 0x0386, r0


q4:
	lds r4, 0x0285
	ldi r24, 0x02
	;ldi r24, 0x10
	;ldi r24, 0x0F
	ldi r16, 0x00

div:
	mov r14, r4
	sub r4, r24
	brcs endiv
	inc r16
	rjmp div
endiv:
	sts 0x0385, r16
	sts 0x0386, r14


q5:
	lds r14, 0x0285
	ldi r24, 0x49
	;ldi r24, 0x00
	;ldi r24, 0x99

	ldi r20, 0b11110000
	ldi r21, 0b00001111
	ldi r22, 0b00010000

	clr r0

	mov r16, r24
	and r24, r20 ;r24 handles high digit of first operand
	and r16, r21 ;r16 handles low digit of first operand

	mov r17, r14
	and r14, r20 ;r14 handles high digit of second operand
	and r17, r21 ;r17 handles low digit of second operand

	rjmp p2 ; adding
p1:
	add r16, r17
	mov r18, r16
	subi r18, 0x0A
	brcs noinc
	add r24, r22
	mov r16, r18
noinc:
	add r24, r14
	mov r18, r24
	subi r18, 0xA0
	brcs res
	mov r24, r18
	inc r0
	rjmp res

p2:
	mov r18, r16
	sub r16, r17
	brcc nodec
	sub r17, r18
	mov r16, r17
	sub r24, r22
	cpi r24, 0xF0
	brne nodec
	clr r24
nodec:
	mov r18, r24
	sub r24, r14
	brcc res
	sub r14, r18
	mov r24, r14
	inc r0
	rjmp res
	
res:	
	or r24, r16
	sts 0x0385, r0
	sts 0x0386, r24


end: rjmp end
	

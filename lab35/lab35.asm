.include "m328pdef.inc"

.cseg
.org $0000 rjmp Reset
.org $002A rjmp ADC_Int

.org INT_VECTORS_SIZE

Reset:
	ldi r16,Low(RAMEND)
    out SPL,r16
    ldi r16,High(RAMEND)
    out SPH,r16

    ldi r16,0b11111111
    out DDRD,r16
    ldi r16,0b00011110
    out DDRC,r16
    sei

	ldi r18, 0b00010000 ; high bit increment value
	ldi r19, 0b11110000 ; hight bit mask
	ldi r20, 0b00001111 ; low bit mask
	ldi r22, 0b00001001 ; low bit top value
	ldi r24, 0x0C ; lerp delta
	ldi r25, 0x01 ; inc/dec delta
	ldi r26, 0xFF ; 


;          7     6     5     4     3     2     1     0
;ADMUX = REFS1 REFS0 ADLAR  MUX4  MUX3  MUX2  MUX1  MUX0
    ldi r16,0b01000000
    sts ADMUX,r16

;           7    6    5     4     3     2     1     0
;ADCSRA = ADEN ADSC ADATE ADIF  ADIE  ADPS2 ADPS1 ADPS0
    ldi r16,0b11001111
    sts ADCSRA,r16

main: rjmp main

ADC_Int:
    lds r17,ADCL
    lds r16,ADCH
	rcall proceed_delta

    out PORTD,r23

    lds r16,ADCSRA
    sbr r16,(1 << ADSC)
    sts ADCSRA,r16
    reti

proceed_delta:
	;save actual value to buffer
	mov r2, r16
	mov r3, r17

	;substract previous value from buffered actual value
	sub r3, r1
	sbc r2, r0
	;check if actual value < previous value
	brcs set_decrease_flag
	;if false clear decrease flag
	bclr 6
	rjmp clear_decrease_flag
set_decrease_flag:
	;if true set decrase flag
	bset 6
	;save previous value to buffer
	mov r2, r0
	mov r3, r1
	;substract actual value from buffered previous value
	sub r3, r17
	sbc r2, r16
clear_decrease_flag:
	
	;actualize previous value
	mov r0, r16
	mov r1, r17
	
cycle:
	;save value to buffer
	mov r4, r3
	;substract lerp step
	sub r3, r24
	;check if borrow required
	brcs borrow
	;if false check if decrease flag is set
	brbs 6, on_decrease
	;if false increase counter
	rcall inccounter
	rjmp cycle
on_decrease:
	;decrease counter
	rcall deccounter
	rjmp cycle
borrow:
	;save rest
	add r5, r4
	;decrease gigh-digit register (borrow)
	sub r2, r25
	;check if borrowed
	brcs check_rest
	;if borrowed set low-digit register to 0xFF
	mov r3, r26
	rjmp cycle

check_rest:
	;save rest to buffer
	mov r4, r5
	;substract lerp step from rest
	sub r5, r24
	;check if substracted well
	brcs save_rest
	;if substracted well check if decrease flag set
	brbs 6, on_decrease_by_rest
	;if false increase counter
	rcall inccounter
	rjmp check_rest
on_decrease_by_rest:
	;decrease counter
	rcall deccounter
	rjmp check_rest

save_rest:
	;save rest	
	mov r5, r4

return_proceed_delta: ret




inccounter:
	;check if value is already max
	cpi r23, 0x85
	;ret if true
	breq ret2
	;increment value
	inc r23
	;save value to buffer
	mov r21, r23
	;cut out high bits
	and r21, r20
	;check if low bits max value exceeded
	cpi r21, 0b00001010
	;ret if false
	brne ret2
	;if true increase value's high bits
	add r23, r18
	;cut out value's low bits
	and r23, r19
ret2: ret


deccounter:
	;check if value is already min
	cpi r23, 0x00
	;ret if true
	breq ret3
	;decrement value
	dec r23
	;save value to buffer
	mov r21, r23
	;cut out high bits
	and r21, r20
	;check if low bits are equals F
	cp r21, r20
	;ret if false
	brne ret3
	;if true increase value
	inc r23
	;cut out value's low bits
	and r23, r19
	;add 0x09 (set value's low bits to 0x09)
	add r23, r22
	;decrease value's high bits
	sub r23, r18
ret3: ret

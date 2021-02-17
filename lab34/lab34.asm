.include "m328pdef.inc"

.cseg
.org $0000 jmp RESET    ; (Reset)
.org $0002 jmp Ext_INT0 ; (INT0) External Interrupt Request 0
.org $0004 jmp Ext_INT1 ; (INT1) External Interrupt Request 1
.org $0006 reti         ; (PCINT0) Pin Change Interrupt Request 0
.org $0008 reti         ; (INT1) External Interrupt Request 1
.org $000A reti         ; (INT2) External Interrupt Request 2
.org $000C reti         ; (WDT) Watchdog Time-out Interrupt
.org $000E reti         ; (TIMER2_COMPA) Timer2 Compare Match A
.org $0010 reti         ; (TIMER2_COMPB) Timer2 Compare Match B
.org $0012 reti         ; (TIMER2_OVF) Timer2 Overflow
.org $0014 reti         ; (TIMER1_CAPT) Timer1 Capture Event
.org $0016 reti         ; (TIMER1_COMPA) Timer1 Compare Match A
.org $0018 reti         ; (TIMER1_COMPB) Timer1 Compare Match B
.org $001A reti         ; (TIMER1_OVF) Timer1 Overflow
.org $001C reti         ; (TIMER0_COMPA) Timer0 Compare Match A
.org $001E reti         ; (TIMER0_COMPB) Timer0 Compare Match B
.org $0020 reti         ; (TIMER0_OVF) Timer0 Overflow
.org $0022 reti         ; (SPI_STC) Serial Transfer Complete
.org $0024 reti         ; (USART_RX) USART Rx Complete
.org $0026 reti         ; (USART_UDRE) USART Data Register Empty
.org $0028 reti         ; (USART_TX) USART Tx Complete
.org $002A reti         ; (ADC) ADC Conversion Complete
.org $002C reti         ; (EE_READY) EEPROM Ready
.org $002E reti         ; (ANALOG_COMP) Analog Comparator
.org $0030 reti         ; (TWI) 2-wire Serial Interface
.org $0032 reti         ; (SPM_RDY) Store Program Memory Ready

.org INT_VECTORS_SIZE

Ext_INT0:
	rcall checkstate
ret0:  reti

Ext_INT1:
	rcall checkstate
ret1:  reti


Reset:
	;configure interruptions
	ldi r16,Low(RAMEND)
    out SPL,r16
    ldi r16,High(RAMEND)
    out SPH,r16
    ldi r16,0b00000011 
    out EIMSK,r16
    ldi r16,0b00001010
    sts EICRA,r16
    sei
	;configure i/o
	ldi r16, 0b00000000
	out DDRC, r16
	ldi r16, 0b11110000
	out DDRD, r16
	ldi r16, 0b00001111
	out DDRB, r16
	
	ldi r17, 0b01000010 ; reset value
	ldi r18, 0b00010000 ; high bit increment value
	ldi r19, 0b11110000 ; hight bit mask
	ldi r20, 0b00001111 ; low bit mask
	ldi r22, 0b00001001 ; decrement low bit top value

	clr r23 ; pind handler
	clr r25 ; pind buffer


main:
	;reset value if pinc 5 clear (button pressed)
	sbis PINC, 5
	ldi r17, 0b01000010 
	;save pind value to its buffer
	mov r25, r23 
	;clear pind handler
	clr r23 
	;out high
	out PORTD, r17
	;out low
	out PORTB, r17 
	rjmp main


checkstate: 
	;read pind status to handler
	in r23, PIND
	;cut out high bits
	and r23, r20
	;doubleshift handler due to offset of INT0/INT1
	lsr r23
	lsr r23

	;swith-case previous pind value by checking buffer
	cpi r25, 0x00
	breq case0
	cpi r25, 0x01
	breq case1
	cpi r25, 0x02
	breq case2
	cpi r25, 0x03
	breq case3
cb:	ret


case0:
	cpi r23, 0x02
	breq ic
	cpi r23, 0x01
	breq dc
rjmp cb

case1:
	cpi r23, 0x00
	breq ic
	cpi r23, 0x03
	breq dc
rjmp cb

case2:
	cpi r23, 0x03
	breq ic
	cpi r23, 0x00
	breq dc
rjmp cb

case3:
	cpi r23, 0x01
	breq ic
	cpi r23, 0x02
	breq dc
rjmp cb


ic:
	rcall inccounter
	rjmp cb

dc:
	rcall deccounter
	rjmp cb


inccounter:
	;check if value is already max
	cpi r17, 0x85
	;ret if true
	breq ret2
	;increment value
	inc r17
	;save value to buffer
	mov r21, r17
	;cut out high bits
	and r21, r20
	;check if low bits max value exceeded
	cpi r21, 0b00001010
	;ret if false
	brne ret2
	;if true increase value's high bits
	add r17, r18
	;cut out value's low bits
	and r17, r19
ret2: ret


deccounter:
	;check if value is already min
	cpi r17, 0x00
	;ret if true
	breq ret3
	;decrement value
	dec r17
	;save value to buffer
	mov r21, r17
	;cut out high bits
	and r21, r20
	;check if low bits are equals F
	cp r21, r20
	;ret if false
	brne ret3
	;if true increase value
	inc r17
	;cut out value's low bits
	and r17, r19
	;add 0x09 (set value's low bits to 0x09)
	add r17, r22
	;decrease value's high bits
	sub r17, r18
ret3: ret

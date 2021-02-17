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
       inc r24
	   inc r25
       cpi r24, 0x3A
       brne checklimit
       inc r23
	   ldi r24, 0x30

checklimit:
	   cpi r25, 0x85
	   breq Ext_INT1
	   
ret0:  reti

Ext_INT1:
       dec r24
	   dec r25
       cpi r24, 0x2F
       brne ret1
       ldi r24, 0x39
	   dec r23
	   cpi r23, 0x2F
	   brne ret1
	   rcall clearall
ret1:  reti

Reset: 
	   ldi r16,Low(RAMEND)
       out SPL,r16
       ldi r16,High(RAMEND)
       out SPH,r16
       ldi r16,0b00000011
       out EIMSK,r16
       ldi r16,0b00001010
       sts EICRA,r16
       sei
       clr r16
       out DDRC, r16
       rcall LCD_Init

	   rcall clearall

main:  
	    sbis PINC, 5
        rcall clearall
        sts 0x0200, r23
		sts 0x0201, r24
        ldi r17,0x02
        rcall LCD_Update
        rjmp main

clearall:
		ldi r23, 0x30
		ldi r24, 0x30
		ldi r25, 0x06
		ret

.include "hd44780.asm"

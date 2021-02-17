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
	   ;increment low-digit value
       inc r24
	   ;increment counter
	   inc r25
	   ;check if low-digit value exceeded 9
       cpi r24, 0x3A
	   ;if not skip high-digit increment
       brne checklimit
	   ;if exceeded increment high-digit value
       inc r23
	   ;set low-digit value to 0 (ascii-code)
	   ldi r24, 0x30

checklimit:
	   ;check if counter is exceeded max value
	   cpi r25, 0x86
	   ;if exceeded jump to decrement
	   breq Ext_INT1

ret0:  reti


Ext_INT1:
	   ;decrease low-digit value
       dec r24
	   ;decrease counter
	   dec r25
	   ;check if low-digit value is less than ascii-code of 0
       cpi r24, 0x2F
	   ;if not return
       brne ret1
	   ;if true set low-digit value to 9
       ldi r24, 0x39
	   ;decrease high-digit value
	   dec r23
	   ;check if high-digit value is less than ascii-code of 0
	   cpi r23, 0x2F
	   ;if not return
	   brne ret1
	   ;if true clear all counters
	   rcall clearall
ret1:  reti

Reset: 
	   ;configure stack
	   ldi r16,Low(RAMEND)
       out SPL,r16
       ldi r16,High(RAMEND)
       out SPH,r16
	   ;configure EIMSK (allow INT0, INT1)
       ldi r16,0b00000011
       out EIMSK,r16
	   ;configure EICRA (allow external interrupts)
       ldi r16,0b00001010
       sts EICRA,r16
	   ;configure interrupts globally
       sei

	   ;configure PORTC to all-input
       clr r16
       out DDRC, r16
	   ;init LCD
       rcall LCD_Init
	   ;clear both counter-handling registers
	   rcall clearall

main:  
		;check if PC5 port clear (clear button pressed)
	    sbis PINC, 5
		;if clear call counter-clearing function
        rcall clearall
		;write counter to memory
        sts 0x0200, r23 ;high digit
		sts 0x0201, r24 ;low digit
		;configure LCD to show 2 digits
        ldi r17,0x02
		;update LCD (show actual value)
        rcall LCD_Update
        rjmp main

clearall:
		;clear low-digit counter (set to ascii-code of 0)
		ldi r23, 0x30
		;clear low-digit counter (set to ascii-code of 0)
		ldi r24, 0x30
		;clear smth idr
		ldi r25, 0x06
		ret

.include "hd44780.asm"

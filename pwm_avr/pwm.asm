.include "m8def.inc" "   

;= Start 	macro.inc ========================================
   .macro    OUTI         
      ldi    R16,@1
   .if @0 < 0x40
      out    @0,R16         
   .else
      sts      @0,R16
   .endif
   .endm

   	.macro    UOUT        
   	.if	@0 < 0x40
      	out	@0,@1         
	.else
      	sts	@0,@1
   	.endif
   	.endm
;= End 		macro.inc ========================================



; RAM ========================================================
		.DSEG


; FLASH ======================================================
         .CSEG

         .ORG $000        ; (RESET) 
         RJMP   Reset
         .ORG $002
         RETI             ; (INT0) External Interrupt Request 0
         .ORG $004
         RETI             ; (INT1) External Interrupt Request 1
         .ORG $006
         RETI		      ; (TIMER2 COMP) Timer/Counter2 Compare Match
         .ORG $008
         RETI             ; (TIMER2 OVF) Timer/Counter2 Overflow
         .ORG $00A
         RETI		      ; (TIMER1 CAPT) Timer/Counter1 Capture Event
         .ORG $00C 
         RETI             ; (TIMER1 COMPA) Timer/Counter1 Compare Match A
         .ORG $00E
         RETI             ; (TIMER1 COMPB) Timer/Counter1 Compare Match B
         .ORG $010
         RETI             ; (TIMER1 OVF) Timer/Counter1 Overflow
         .ORG $012
         RETI             ; (TIMER0 OVF) Timer/Counter0 Overflow
         .ORG $014
         RETI             ; (SPI,STC) Serial Transfer Complete
         .ORG $016
         RETI     		 ; (USART,RXC) USART, Rx Complete
         .ORG $018
         RETI             ; (USART,UDRE) USART Data Register Empty
         .ORG $01A
         RETI             ; (USART,TXC) USART, Tx Complete
         .ORG $01C
         RETI		    ; (ADC) ADC Conversion Complete
         .ORG $01E
         RETI             ; (EE_RDY) EEPROM Ready
         .ORG $020
         RETI             ; (ANA_COMP) Analog Comparator
         .ORG $022
         RETI             ; (TWI) 2-wire Serial Interface
         .ORG $024
         RETI             ; (INT2) External Interrupt Request 2
         .ORG $026
         RETI             ; (TIMER0 COMP) Timer/Counter0 Compare Match
         .ORG $028
         RETI             ; (SPM_RDY) Store Program Memory Ready

	 	.ORG   INT_VECTORS_SIZE      	; ????? ??????? ??????????

; Interrupts ==============================================




; End Interrupts ==========================================


Reset:   	LDI 	R16,Low(RAMEND)	; ������������� �����
		    OUT 	SPL,R16			; 

		 	LDI 	R16,High(RAMEND)
		 	OUT 	SPH,R16
	 
; Start coreinit.inc (������� ������)
RAM_Flush:	LDI		ZL,Low(SRAM_START)	; ����� ������ ��� � ������
			LDI		ZH,High(SRAM_START)
			CLR		R16					; �������� R16
Flush:		ST 		Z+,R16				; �������� 0 � ������ ������
			CPI		ZH,High(RAMEND)		; �������� ����� ���
			BRNE	Flush				; ���������� �������� ���
 
			CPI		ZL,Low(RAMEND)		; ������� ���� ������ �����
			BRNE	Flush
 
			CLR		ZL					; ������� ���������
			CLR		ZH
			CLR		R0
			CLR		R1
			CLR		R2
			CLR		R3
			CLR		R4
			CLR		R5
			CLR		R6
			CLR		R7
			CLR		R8
			CLR		R9
			CLR		R10
			CLR		R11
			CLR		R12
			CLR		R13
			CLR		R14
			CLR		R15
			CLR		R16
			CLR		R17
			CLR		R18
			CLR		R19
			CLR		R20
			CLR		R21
			CLR		R22
			CLR		R23
			CLR		R24
			CLR		R25
			CLR		R26
			CLR		R27
			CLR		R28
			CLR		R29
; End coreinit.inc



; Internal Hardware Init  ======================================

; End Internal Hardware Init ===================================



; External Hardware Init  ======================================

; End Internal Hardware Init ===================================



; Run ==========================================================

; End Run ======================================================



; Main =========================================================
Main:

		JMP	Main
; End Main =====================================================


; Procedure ====================================================

; End Procedure ================================================


; EEPROM =====================================================
			.ESEG				; ??????? EEPROM

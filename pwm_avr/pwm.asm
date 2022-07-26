.include "m8def.inc" 
.LIST    

.def temp = R16 ;������� ����������
.def temp_port = R17
.def count_time = R18 ;������� ��������

.equ BAUD = 0x0C //�������� ��� UART                      
;= Start 	macro.inc ========================================
   .macro    OUTI         
      ldi    R16,@1 ; @1 - ������ �������� �������
   .if @0 < 0x40 
      out    @0,R16 ; @0 - ������ �������� �������       
   .else
      sts    @0,R16
   .endif
   .endm

; ============================================================
   	.macro    OUTU        
   	.if	@0 < 0x40
      	out	@0,@1 ; @0 - 1 �������� �������, ����� ������� ���         
	.else
      	sts	@0,@1 ; @1 - 2 �������� �������, ����� ������� ���
   	.endif
   	.endm


; ============================================================
	.MACRO	INCM
	lds		R16,@0 		;�������� �� ��� �������� ����� 4 �������� �����
	lds		R17,@0+1
	lds		R18,@0+2
	lds		R19,@0+3

	subi	R16,(-1) ;�������� �������� ����� 4 �������� ����� � 1 
	sbci	R17,(-1) ;�������� � ��������� ������� ����� 4 �������� ����� � 1 � ���������
	sbci	R18,(-1) 
	sbci	R19,(-1)

	sts		@0,R16
	sts		@0+1,R17
	sts		@0+2,R18
	sts		@0+3,R19
	.ENDM

; ============================================================
.MACRO	INVB
	.if	@0 < 0x40
	in		@2,@0
	ldi		@3,1<<@1
	eor		@3,@2
	out		@0,@3
	.else
	lds		@2,@0
	ldi		@3,1<<@1
	eor		@2,@3
	sts		@0,@2
	.endif
	.ENDM

; ============================================================
	.MACRO PUSHF
	push	R16
	in	R16,SREG
	push	R16
	.ENDM

; ============================================================
	.MACRO POPF
	pop	R16
	out	SREG,R16
	pop	R16
	.ENDM

;= End 		macro.inc ========================================



; RAM ========================================================
		.DSEG

	TCNT:	.byte	4 ;��������� 4 ���� ��� ���������� �������
	StrPtr: .byte	2

; FLASH ======================================================
     .CSEG

    .ORG $000        ; (RESET) 
  	RJMP Reset ; Reset Handler
	RETI ;RJMP EXT_INT0 ; IRQ0 Handler
	RETI ;RJMP EXT_INT1 ; IRQ1 Handler
	RETI ;RJMP TIM2_COMP ; Timer2 Compare Handler
	RETI ;RJMP TIM2_OVF ; Timer2 Overflow Handler
	RETI ;RJMP TIM1_CAPT ; Timer1 Capture Handler
	RETI ;RJMP TIM1_COMPA ; Timer1 CompareA Handler
	RETI ;RJMP TIM1_COMPB ; Timer1 CompareB Handler
	RETI ;RJMP TIM1_OVF ; Timer1 Overflow Handler
	RJMP TIM0 ; Timer0 Overflow Handler
	RETI ;RJMP SPI_STC ; SPI Transfer Complete Handler
	RETI ;RJMP USART_RXC ; USART RX Complete Handler
	RETI ;RJMP USART_UDRE ; UDR Empty Handler
	RETI ;RJMP USART_TXC ; USART TX Complete Handler
	RETI ;RJMP ADC ; ADC Conversion Complete Handler
	RETI ;RJMP EE_RDY ; EEPROM Ready Handler
	RETI ;RJMP ANA_COMP ; Analog Comparator Handler
	RETI ;RJMP TWSI ; Two-wire Serial Interface Handler
	RETI ;RJMP SPM_RDY ; Store Program Memory Ready Handler


; Interrupts ==============================================
; ----- ���������� ���������� Timer0 -----
TIM0:
		PUSHF
		push	R17
		push	R18
		push	R19
		
		lds		R16,TCNT 		;�������� �� ��� �������� ����� 4 �������� �����
		lds		R17,TCNT+1
		lds		R18,TCNT+2
		lds		R19,TCNT+3

		subi	R16,(-1) ;�������� �������� ����� 4 �������� ����� � 1 
		sbci	R17,(-1) ;�������� � ��������� ������� ����� 4 �������� ����� � 1 � ���������
		sbci	R18,(-1) 
		sbci	R19,(-1)

		sts		TCNT,R16
		sts		TCNT+1,R17
		sts		TCNT+2,R18
		sts		TCNT+3,R19

		pop	R19
		pop	R18
		pop	R17
		POPF

reti ;����� ��������� ���������� �������



; End Interrupts ==========================================

String:		.DB	"HELLO",'\r','\n',0

Reset:   	LDI 	R16,Low(RAMEND)	; ������������� �����
		    OUT 	SPL,R16			; 

		 	LDI 	R16,High(RAMEND)
		 	OUT 	SPH,R16
	 
; Start coreinit.inc (������� ������)
RAM_Flush:	LDI		ZL,Low(SRAM_START)	; ����� ������ ��� � ������
			LDI		ZH,High(SRAM_START)
			CLR		temp					; �������� R16
Flush:		ST 		Z+,temp				; �������� 0 � ������ ������
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

; ----- ���������������� ������� 1 -----
ldi 	temp , ((1<<COM1A1)|(0<<COM1A0)|(1<<COM1B1)|(0<<COM1B0)|(1<<WGM10)|(0<<WGM11)) 
out 	TCCR1A, temp
ldi 	temp , ((0<<WGM13)|(1<<WGM12)|(1<<CS10)) 
out 	TCCR1B, temp	

CLI
OUTI	OCR1AH,0
OUTI	OCR1AL,15
 
OUTI	OCR1BH,0
OUTI	OCR1BL,32
SEI
; End coreinit.inc

; Internal Hardware Init  ======================================
; ----- ��� ����� �� ������� 1 � 2 ����� B -----
ldi 	temp , ((1 <<DDB1)|(1 <<DDB2)|(1 <<DDB3))	
out 	DDRB, temp

; End Internal Hardware Init ===================================

; External Hardware Init  ======================================
; ----- ���������������� UART -----
ldi temp,BAUD ;�������� �������� 19200 ��� 4 ���
out UBRRL, temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ; ������ 8n1
out UCSRC,temp
ldi temp, (1<<TXEN) ;���������� �������� �� UART
out UCSRB, temp

ldi 	temp,low(String*2) 	; 
ldi  	temp_port, high(String*2)
sts		StrPtr,temp		
sts		StrPtr+1,temp_port		; ��������� ������� ���� ��������� String
; End External Hardware Init ===================================

; Run ==========================================================
sei ;���������� ����������
; End Run ======================================================



; Main =========================================================
Main:
NOP

rjmp	Main

; ----- ������������ �������� ����� �� UART -----
/*out_byte: 
sbis UCSRA,UDRE ;SBIS - ���������� ���� ��� UDRE (����� � ��������) ����������
rjmp out_byte
out UDR,temp ;�������� �����
ret ;*/
	
; End Main =====================================================


; Procedure ====================================================

; End Procedure ================================================


; EEPROM =====================================================
			.ESEG				; ??????? EEPROM

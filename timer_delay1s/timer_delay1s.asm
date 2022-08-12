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
		sbci	R17,(-1) ;�������� ������� ����� 4 �������� ����� � 1 � � ������ �������� (�) �������� SREG (���� �������� ����� ����, ���� ���������� �������� ������� ������������ )
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

String:		.DB	"HELLO",'\r','\n'

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

; ----- ���������������� ������� 0 -----
clr temp  ;������� ���� � ������� R16
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;��������� ���������� Timer0 

ldi temp, (1<<CS00) 
out TCCR0,temp ;��������� Timer0 no prescaling

; End coreinit.inc

; Internal Hardware Init  ======================================
; ----- ������������� ���� PC3 � PC4 ����� PORTC �� ����� -----
ldi 	temp, ((1 << DDC3) | (1 << DDC4))  
out 	DDRC, temp         ;���� PC3 � PC4 �� �����
sbi 	PORTC, PORTC3;	 	������ �� ��� PC3 �������� ������
cbi 	PORTC, PORTC4 ; 	������ �� ��� PC4 ������� ������ (CBI - �������� ��� � �������� I/O)
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

Next: 
lds 	temp, TCNT ; 	������ ����� � ��������
lds 	temp_port,TCNT+1

cpi		temp,0x09 ;��������� R16 � ����������, ������������� � 1 ��� � �������� SREG, ���� �������� ������ R16	
;cpi		temp,0x12 
brcs	NoMatch ;������� ���� ���������� ��� � �������� SREG
cpi		temp_port,0x3D ;�������� ~1c ��� 4 ���
;cpi 	temp_port,0x7A
brcs	NoMatch

Match:		INVB	PORTC,PORTC3,temp,temp_port	; �������������� PC3
			INVB	PORTC,PORTC4,temp,temp_port	; �������������� PC4

; ������ ���� �������� �������, ����� �� ��� �� �������� �������� �����
; �� ���� ������ ��� �� ���� ��� -- ������ �� �� ������ �������� 255 ��������
; ����� ����� � ������ ���� ������ �������� ���������� 

clr		temp	;������� R16
cli 	;������ ����������

sts		TCNT0,temp //������� �������� �������� �������				
sts		TCNT,temp  //������� 4 �������� �����		
sts		TCNT+1,temp		
sts		TCNT+2,temp		
sts		TCNT+3,temp		

PUSHF
push	temp_port
push	R18
push	R19

lds	ZL, StrPtr	; ����������� ���������� �� ������ � ��������� ��������
lds	ZH, StrPtr+1

continue_TX:
lpm	temp,Z+	
	
out_byte: 
sbis UCSRA,UDRE 		;SBIS - ���������� ���� ��� UDRE (����� � ��������) ����������
rjmp out_byte
out UDR,temp		 ;�������� �����

cpi temp,'\n'		; 	���� �� \n, ���������� �������� �� ����
brne continue_TX	; 	����� ��������� �������� (brne - ������� ���� �� �����)

pop	R19
pop	R18
pop	temp_port
POPF
sei ;���������� ����������

NoMatch:				
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


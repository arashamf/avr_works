.include "m8def.inc" 
.LIST    

.def temp = R16 ;рабочая переменная
.def temp_port = R17
.def count_time = R18 ;счетчик задержки

.equ BAUD = 0x0C //делитель для UART                      
;= Start 	macro.inc ========================================
   .macro    OUTI         
      ldi    R16,@1 ; @1 - второй параметр макроса
   .if @0 < 0x40 
      out    @0,R16 ; @0 - первый параметр макроса       
   .else
      sts    @0,R16
   .endif
   .endm

; ============================================================
   	.macro    OUTU        
   	.if	@0 < 0x40
      	out	@0,@1 ; @0 - 1 параметр макроса, здесь регистр ОЗУ         
	.else
      	sts	@0,@1 ; @1 - 2 параметр макроса, здесь регистр РОН
   	.endif
   	.endm


; ============================================================
	.MACRO	INCM
	lds		R16,@0 		;выгрузка из ОЗУ младшего байта 4 байтного числа
	lds		R17,@0+1
	lds		R18,@0+2
	lds		R19,@0+3

	subi	R16,(-1) ;сложение младшего байта 4 байтного числа с 1 
	sbci	R17,(-1) ;сложение с переносом второго байта 4 байтного числа с 1 с переносом
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

	TCNT:	.byte	4 ;выделение 4 байт под глобальный счётчик
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
; ----- обработчик прерывания Timer0 -----
TIM0:
		PUSHF
		push	R17
		push	R18
		push	R19
		
		lds		R16,TCNT 		;выгрузка из ОЗУ младшего байта 4 байтного числа
		lds		R17,TCNT+1
		lds		R18,TCNT+2
		lds		R19,TCNT+3

		subi	R16,(-1) ;сложение младшего байта 4 байтного числа с 1 
		sbci	R17,(-1) ;сложение второго байта 4 байтного числа с 1 и с флагом переноса (С) регистра SREG (флаг переноса равен нулю, если предыдущее действие вызвало переполнение )
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

reti ;конец обработки прерывания таймера



; End Interrupts ==========================================

String:		.DB	"HELLO",'\r','\n'

Reset:   	LDI 	R16,Low(RAMEND)	; инициализация стека
		    OUT 	SPL,R16			; 

		 	LDI 	R16,High(RAMEND)
		 	OUT 	SPH,R16
	 
; Start coreinit.inc (очитска памяти)
RAM_Flush:	LDI		ZL,Low(SRAM_START)	; адрес начала ОЗУ в индекс
			LDI		ZH,High(SRAM_START)
			CLR		temp					; обнуляем R16
Flush:		ST 		Z+,temp				; сохранем 0 в ячейку памяти
			CPI		ZH,High(RAMEND)		; проверка конца ОЗУ
			BRNE	Flush				; продолжаем обнулять ОЗУ
 
			CPI		ZL,Low(RAMEND)		; младший байт достиг конца
			BRNE	Flush
 
			CLR		ZL					; очистка регистров
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

; ----- конфигурирование таймера 0 -----
clr temp  ;запишем нуль в регистр R16
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;разрешаем прерывания Timer0 

ldi temp, (1<<CS00) 
out TCCR0,temp ;запускаем Timer0 no prescaling

; End coreinit.inc

; Internal Hardware Init  ======================================
; ----- устанавливаем пины PC3 и PC4 порта PORTC на вывод -----
ldi 	temp, ((1 << DDC3) | (1 << DDC4))  
out 	DDRC, temp         ;пины PC3 и PC4 на выход
sbi 	PORTC, PORTC3;	 	подача на пин PC3 высокого уровня
cbi 	PORTC, PORTC4 ; 	подача на пин PC4 низкого уровня (CBI - Очистить бит в регистре I/O)
; End Internal Hardware Init ===================================

; External Hardware Init  ======================================
; ----- конфигурирование UART -----
ldi temp,BAUD ;скорость передачи 19200 при 4 МГц
out UBRRL, temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ; формат 8n1
out UCSRC,temp
ldi temp, (1<<TXEN) ;разрешение передачи по UART
out UCSRB, temp

ldi 	temp,low(String*2) 	; 
ldi  	temp_port, high(String*2)
sts		StrPtr,temp		
sts		StrPtr+1,temp_port		; сохраняем старший байт указателя String
; End External Hardware Init ===================================

; Run ==========================================================
sei ;разрешения прерываний
; End Run ======================================================



; Main =========================================================
Main:

Next: 
lds 	temp, TCNT ; 	Грузим числа в регистры
lds 	temp_port,TCNT+1

cpi		temp,0x09 ;сравнение R16 с константой, устанавливает в 1 бит С регистра SREG, если костанта больше R16	
;cpi		temp,0x12 
brcs	NoMatch ;переход если установлен бит С регистра SREG
cpi		temp_port,0x3D ;задержка ~1c при 4 МГц
;cpi 	temp_port,0x7A
brcs	NoMatch

Match:		INVB	PORTC,PORTC3,temp,temp_port	; инвертирование PC3
			INVB	PORTC,PORTC4,temp,temp_port	; инвертирование PC4

; теперь надо обнулить счётчик, иначе за эту же итерациб главного цикла
; мы сюда попадём ещё не один раз -- таймер то не успеет натикать 255 значений
; чтобы число в первых двух байтах счётчика изменилось 

clr		temp	;очистка R16
cli 	;Запрет прерываний

sts		TCNT0,temp //очистка счётного регистра таймера				
sts		TCNT,temp  //очистка 4 байтного числа		
sts		TCNT+1,temp		
sts		TCNT+2,temp		
sts		TCNT+3,temp		

PUSHF
push	temp_port
push	R18
push	R19

lds	ZL, StrPtr	; копирование указателей на строку в индексные регистры
lds	ZH, StrPtr+1

continue_TX:
lpm	temp,Z+	
	
out_byte: 
sbis UCSRA,UDRE 		;SBIS - пропустить если бит UDRE (готов к передаче) установлен
rjmp out_byte
out UDR,temp		 ;отправка байта

cpi temp,'\n'		; 	если не \n, продолжаем отправку по УАРТ
brne continue_TX	; 	иначе остановка передачи (brne - перейти если не равно)

pop	R19
pop	R18
pop	temp_port
POPF
sei ;разрешения прерываний

NoMatch:				
rjmp	Main

; ----- подпрограмма отправки байта по UART -----
/*out_byte: 
sbis UCSRA,UDRE ;SBIS - пропустить если бит UDRE (готов к передаче) установлен
rjmp out_byte
out UDR,temp ;отправка байта
ret ;*/
	
; End Main =====================================================


; Procedure ====================================================

; End Procedure ================================================


; EEPROM =====================================================
			.ESEG				; ??????? EEPROM


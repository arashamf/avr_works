;частота 4 МГц
.include "m8def.inc" //загрузка предопределений для ATmega8
.LIST                           ; включить генерацию листинга

.def temp = R16 ;рабочая переменная
.def temp_port = R17
.def count_time = R18 ;счетчик задержки

; RAM ========================================================
.DSEG
StrPtr: .BYTE 2

; FLASH ======================================================
.CSEG                           ; начало сегмента кода (FLASH)
.ORG 0x0000                     ; начальное значение для адресации памяти (org, которая устанавливает абсолютный адрес в памяти программ)

RJMP RESET ; Reset Handler
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
RJMP USART_UDRE ; UDR Empty Handler
RETI ;RJMP USART_TXC ; USART TX Complete Handler
RETI ;RJMP ADC ; ADC Conversion Complete Handler
RETI ;RJMP EE_RDY ; EEPROM Ready Handler
RETI ;RJMP ANA_COMP ; Analog Comparator Handler
RETI ;RJMP TWSI ; Two-wire Serial Interface Handler
RETI ;RJMP SPM_RDY ; Store Program Memory Ready Handler

; Interrupts ==============================================
; ----- обработчик прерывания Timer0 -----
TIM0:
dec count_time ;в каждом прерывании уменьшаем на 1
breq end_timer ;если ноль, то на конец отсчета (BREQ - gерейти на метку если 0 в предыдущем выражении, или на следующее выражение если не ноль)
reti ;иначе выход из прерывания

end_timer:
ldi temp, LED_Mask //запись битовой маски в регистр
IN temp_port, PORTC //Чтение порта C
EOR temp_port, temp //исключающее или
OUT PORTC, temp_port //Запись в порт C
ldi count_time, 0x32 //установка нового значения задержки

ldi 	ZL,low(String*2) 	; запись младшего байта адреса, в регистровую пару Z
ldi  	ZH, high(String*2)	; запись старшего байта адреса, в регистровую пару Z

ldi 	temp, (1<<RXEN)|(1<<TXEN)|(1<<RXCIE)|(1<<TXCIE)|(1<<UDRIE) //разрешение приёма, передачи, прерывания по опустошению регистра UDR
//ldi 	temp, (1<<RXEN)|(1<<TXEN)
//out 	UCSRB, temp
//lpm 	temp, Z ;Загрузка байта памяти программ
//ldi temp, 0x48
rcall	out_byte	; Вызываем процедуру отправки байта.
reti ;конец обработки прерывания таймера

; ----------------------------------------------------------------------
USART_UDRE:
//rcall PUSHF ; Макрос, сохраняющий SREG
/*IN	temp, SREG
push temp
push ZL		; Сохраняем в стеке Z
push ZH*/

ldi 	ZL,low(String*2) 	; запись младшего байта адреса, в регистровую пару Z
ldi  	ZH, high(String*2)	; запись старшего байта адреса, в регистровую пару Z

/*sts	StrPtr,temp		; сохраняем младший байт указателя на String (sts - вывод регистров периферии по полному адресу)
sts	StrPtr+1,temp_port		; сохраняем сташрий байт

lds	ZL,StrPtr	; сохранение указателей в индексные регистры
lds	ZH,StrPtr+1*/

lpm	temp,Z		; копирование байт из строки
 

/*cpi temp,0		; если не ноль,продолжаем чтение
breq stop_TX	; иначе остановка передачи (breq - Перейти если равно)*/
 
out	UDR,temp		; Выдача данных в уарт.
 
/*sts	StrPtr,ZL	; Сохраняем указатель обратно, в память
sts	StrPtr+1,ZH	; 

Exit_TX:	
pop	ZH		; копирование из стека
pop	ZL
pop	temp
out	SREG,temp
reti ;конец обработки прерывания

stop_TX:
ldi 	temp, (0<<RXEN)|(0<<TXEN)|(0<<UDRIE) ; отключение прерывания по опустошению, выход из обработчика
out 	UCSRB, temp
rjmp	Exit_TX*/

ldi 	temp, (0<<RXEN)|(0<<TXEN)|(0<<RXCIE)|(0<<TXCIE)|(0<<UDRIE) ; отключение прерывания по опустошению, выход из обработчика
out 	UCSRB, temp
reti
; End Interrupts ==========================================

String:		.DB	"HELLO",0

Reset:
; ----- инициализация стека -----
ldi temp, Low(RAMEND)  ; младший байт конечного адреса ОЗУ в R16 (LDI - Загрузить непосредственное значение)
out SPL, temp          ; установка младшего байта указателя стека (OUT - Записать данные из регистра)
ldi temp, High(RAMEND) ; старший байт конечного адреса ОЗУ в R16
out SPH, temp          ; установка старшего байта указателя стека

.equ LED_Mask = 0x3 
.equ BAUD = 0x0C //делитель для UART 

; ----- устанавливаем пины PC0 и PC1 порта PORTC на вывод -----
ldi temp, 0b00000011   ; поместим в регистр R16 число 3 (0x3)
out DDRC, temp         ; загрузим значение из регистра R16 в порт DDRC
sbi PORTC, PORTC0 ; подача на пин PD0 высокого уровня (SBI - Установить бит в регистр I/O)
cbi PORTC, PORTC1 ; подача на пин PD1 низкого уровня (CBI - Очистить бит в регистре I/O)

; ----- конфигурирование таймера 0 -----
clr temp  ;запишем нуль в регистр R16
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;разрешаем прерывания Timer0 
ldi temp, (1<<CS02) 
out TCCR0,temp ;запускаем Timer0 div 1:256
ldi count_time, 0x32
sei ;разрешаем прерывания

; ----- конфигурирование UART -----
ldi temp,BAUD ;скорость передачи 19200 при 4 МГц
out UBRRL, temp
ldi temp,(1<<RXEN)|(1<<TXEN) ;разрешение прием-передачу
out UCSRB,temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ;UCSZ0=1, UCSZ1=1, формат 8n1
out UCSRC,temp

Main:
rjmp Main


; ----- подпрограмма отправки байта по UART -----
out_byte: ;посылка байта из temp с ожиданием готовности
sbis UCSRA,UDRE ;SBIS - пропустить если бит UDRE (готов к передаче) в регистре UCSRA установлен
rjmp out_byte
out UDR,temp ;посылка байта
ret ;возврат из процедуры Out_com             ; возврат из подпрограммы Wait

; ----- подпрограмма сохранения регистра статуса в стеке -----
PUSHF:
;PUSH	temp
IN	temp, SREG
PUSH temp
ret

; ----- подпрограмма чтения регистра статуса из стека -----
POPF:
POP	temp
OUT	SREG,temp
;POP temp
ret

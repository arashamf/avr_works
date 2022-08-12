;частота 4 МГц
.include "m8def.inc" //загрузка предопределений для ATmega8
.LIST                           ; включить генерацию листинга

.def temp = R16 ;рабочая переменная
.def temp_port = R17
.def count_time = R18 ;счетчик задержки

.equ LED_Mask = 0x3 
.equ BAUD = 0x0C //делитель для UART 

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
in temp_port, PORTC //Чтение порта C
eor temp_port, temp //исключающее или
out PORTC, temp_port //Запись в порт C
ldi count_time, 0x32 //установка нового значения задержки

ldi 	temp,low(String*2) 	; запись младшего байта адреса, в регистровую пару Z
ldi  	temp_port, high(String*2)	; запись старшего байта адреса, в регистровую пару Z
sts	StrPtr,temp		; сохраняем младший байт указателя на String (sts - вывод регистров периферии по полному адресу)
sts	StrPtr+1,temp_port		; сохраняем сташрий байт

in temp_port, UCSRB //Чтение порта UCSRB
ldi temp, (1<<UDRIE) //разрешение прерывания по опустошению регистра UDR
add temp_port, temp //сложение без переноса
out UCSRB, temp_port
reti ;конец обработки прерывания таймера

; ----------------------------------------------------------------------
USART_UDRE:
in	temp, SREG
push temp
push ZL		; Сохраняем в стеке Z
push ZH


lds	ZL, StrPtr	; сохранение указателей в индексные регистры
lds	ZH, StrPtr+1

lpm	temp,Z+		; копирование байт из строки
out	UDR,temp		; Выдача данных в уарт. 

cpi temp,'\n'		; если не \n,продолжаем чтение
breq stop_TX	; иначе остановка передачи (breq - Перейти если равно)
 
sts	StrPtr,ZL	; Сохраняем указатель обратно, в память
sts	StrPtr+1,ZH	; sts - загрузить непосредственно в СОЗУ

Exit_TX:	
pop	ZH		; копирование из стека
pop	ZL
pop	temp
out	SREG,temp
reti ;конец обработки прерывания

stop_TX:
in temp_port, UCSRB ;чтение порта UCSRB
ldi temp, (1<<UDRIE) ;запрещение прерывания по опустошению регистра UDR
com temp ;побитная инверсия ( дополнение до единицы)
and temp_port, temp ;логическое AND
out UCSRB, temp_port
rjmp	Exit_TX

; End Interrupts ==========================================

String:		.DB	"HELLO",'\r','\n',0 //0 - признак конца строки

Reset:
; ----- инициализация стека -----
ldi temp, Low(RAMEND)  ; младший байт конечного адреса ОЗУ в R16 
out SPL, temp          ; установка младшего байта указателя стека (OUT - Записать данные из регистра)
ldi temp, High(RAMEND) ; старший байт конечного адреса ОЗУ в R16
out SPH, temp          ; установка старшего байта указателя стека

; ----- устанавливаем пины PC0 и PC1 порта PORTC на вывод -----
ldi temp, 0b00000011   ; поместим в регистр R16 число 3 (0x3)
out DDRC, temp         ; загрузим значение из регистра R16 в порт DDRC
sbi PORTC, PORTC0 ; подача на пин PD0 высокого уровня (SBI - Установить бит в регистр I/O)
cbi PORTC, PORTC1 ; подача на пин PD1 низкого уровня (CBI - Очистить бит в регистре I/O)

; ----- конфигурирование таймера 0 -----
clr temp  ;очистка регистра R16
ldi temp,(1<<TOIE0) ;разрешаем прерывания Timer0  
out TIMSK, temp
ldi temp, (1<<CS02) ;предделитель 256
out TCCR0,temp 
ldi count_time, 0x32

; ----- конфигурирование UART -----
ldi temp,BAUD ;скорость передачи 19200 при 4 МГц
out UBRRL, temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ;UCSZ0=1, UCSZ1=1, формат 8n1
out UCSRC,temp
ldi temp, (1<<RXEN)|(1<<TXEN)|((1<<RXCIE))|(1<<TXCIE) //разрешение прерываний UART
out UCSRB, temp

; ----- присвоение указателя StrPtr на массив String-----
ldi 	temp,low(String*2) 	; запись младшего байта адреса массива
ldi  	temp_port, high(String*2)	; запись старшего байта адреса массива
sts	StrPtr,temp		; сохраняем младший байт указателя на String (sts - вывод регистров периферии по полному адресу)
sts	StrPtr+1,temp_port		; сохраняем старший байт указателя на String

sei ;разрешаем прерывания

;-----------------------------------------------------------------------------------;
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
;push	temp
in	temp, SREG
push temp
ret

; ----- подпрограмма чтения регистра статуса из стека -----
POPF:
pop	temp
out	SREG,temp
;pop temp
ret

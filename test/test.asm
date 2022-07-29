;частота 4 МГц
.include "m8def.inc" //загрузка предопределений для ATmega8
.LIST                           ; включить генерацию листинга

.def temp = R16 ;рабочая переменная
.def count_time = R17 ;счетчик задержки
.def leds_port = R18
.equ leds = 0x3

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
RETI ;RJMP USART_UDRE ; UDR Empty Handler
RETI ;RJMP USART_TXC ; USART TX Complete Handler
RETI ;RJMP ADC ; ADC Conversion Complete Handler
RETI ;RJMP EE_RDY ; EEPROM Ready Handler
RETI ;RJMP ANA_COMP ; Analog Comparator Handler
RETI ;RJMP TWSI ; Two-wire Serial Interface Handler
RETI ;RJMP SPM_RDY ; Store Program Memory Ready Handler

; ----- обработчик прерывания Timer0 -----
TIM0:
dec count_time ;в каждом прерывании уменьшаем на 1
breq end_timer ;если ноль, то на конец отсчета (BREQ - gерейти на метку если 0 в предыдущем выражении, или на следующее выражение если не ноль)
reti ;иначе выход из прерывания

end_timer:
//clr temp ;запишем нуль в регистр R16
//out TCCR0,temp //Запись в регистр TCCR0  нуля (выключение таймера)
IN leds_port, PORTD
COM leds_port
OUT PORTD, leds_port
ldi count_time, 0x32
reti ;конец обработки прерывания таймера

Reset:
; ----- инициализация стека -----
ldi temp, Low(RAMEND)  ; младший байт конечного адреса ОЗУ в R16 (LDI - Загрузить непосредственное значение)
out SPL, temp          ; установка младшего байта указателя стека (OUT - Записать данные из регистра)
ldi temp, High(RAMEND) ; старший байт конечного адреса ОЗУ в R16
out SPH, temp          ; установка старшего байта указателя стека

//.equ Delay = 5        ; установка константы времени задержки (.equ - присвоение выражения или константы какой либо символической метке)

; ----- устанавливаем пины PD0 и PD1 порта PORTD (PD) на вывод -----
ldi temp, 0b00000011   ; поместим в регистр R16 число 3 (0x3)
out DDRD, temp         ; загрузим значение из регистра R16 в порт DDRD
sbi PORTD, PORTD0 ; подача на пин PD0 высокого уровня (SBI - Установить бит в регистр I/O)
cbi PORTD, PORTD1 ; подача на пин PD1 низкого уровня (CBI - Очистить бит в регистре I/O)

; ----- конфигурирование таймера 0 -----
clr temp  ;запишем нуль в регистр R16
//out TCNT0, temp  ;обнулим счётный регистр таймера
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;разрешаем прерывания Timer0 
ldi temp, (1<<CS02) 
out TCCR0,temp ;запускаем Timer0 div 1:256
ldi count_time, 0x32
//ldi leds, 0x3
sei ;разрешаем прерывания

G_cykle:
rjmp G_cykle

; ----- основной цикл программы -----
/*Start:
    sbi PORTD, PORTD0 ; подача на пин PD0 высокого уровня (SBI - Установить бит в регистр I/O)
    cbi PORTD, PORTD1 ; подача на пин PD1 низкого уровня (CBI - Очистить бит в регистре I/O)
    rcall Wait        ; вызываем подпрограмму задержки по времени (RCALL - вызов подпрограммы относительно)
	cbi PORTD, PORTD0 ; подача на пин PD0 низкого уровня
    sbi PORTD, PORTD1 ; подача на пин PD1 высокого уровня    
    rcall Wait
    rjmp Start        ; возврат к метке Start, повторяем все в цикле ( RJMP - перейти относительно)

; ----- подпрограмма задержки по времени -----
Wait:
    ldi  R17, Delay   ; загрузка константы для задержки в регистр R17
WLoop0:  
    ldi  R18, 50      ; загружаем число 50 (0x32) в регистр R18
WLoop1:  
    ldi  R19, 0xC8    ; загружаем число 200 (0xC8, $C8) в регистр R19
WLoop2:  
    dec  R19          ; уменьшаем значение в регистре R19 на 1
    brne WLoop2       ; возврат к WLoop2 если значение в R19 не равно 0 
    dec  R18          ; уменьшаем значение в регистре R18 на 1
    brne WLoop1       ; возврат к WLoop1 если значение в R18 не равно 0
    dec  R17          ; уменьшаем значение в регистре R17 на 1
    brne WLoop0       ; возврат к WLoop0 если значение в R17 не равно 0
ret */                  ; возврат из подпрограммы Wait

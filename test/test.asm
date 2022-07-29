;������� 4 ���
.include "m8def.inc" //�������� ��������������� ��� ATmega8
.LIST                           ; �������� ��������� ��������

.def temp = R16 ;������� ����������
.def count_time = R17 ;������� ��������
.def leds_port = R18
.equ leds = 0x3

.CSEG                           ; ������ �������� ���� (FLASH)
.ORG 0x0000                     ; ��������� �������� ��� ��������� ������ (org, ������� ������������� ���������� ����� � ������ ��������)

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

; ----- ���������� ���������� Timer0 -----
TIM0:
dec count_time ;� ������ ���������� ��������� �� 1
breq end_timer ;���� ����, �� �� ����� ������� (BREQ - g������ �� ����� ���� 0 � ���������� ���������, ��� �� ��������� ��������� ���� �� ����)
reti ;����� ����� �� ����������

end_timer:
//clr temp ;������� ���� � ������� R16
//out TCCR0,temp //������ � ������� TCCR0  ���� (���������� �������)
IN leds_port, PORTD
COM leds_port
OUT PORTD, leds_port
ldi count_time, 0x32
reti ;����� ��������� ���������� �������

Reset:
; ----- ������������� ����� -----
ldi temp, Low(RAMEND)  ; ������� ���� ��������� ������ ��� � R16 (LDI - ��������� ���������������� ��������)
out SPL, temp          ; ��������� �������� ����� ��������� ����� (OUT - �������� ������ �� ��������)
ldi temp, High(RAMEND) ; ������� ���� ��������� ������ ��� � R16
out SPH, temp          ; ��������� �������� ����� ��������� �����

//.equ Delay = 5        ; ��������� ��������� ������� �������� (.equ - ���������� ��������� ��� ��������� ����� ���� ������������� �����)

; ----- ������������� ���� PD0 � PD1 ����� PORTD (PD) �� ����� -----
ldi temp, 0b00000011   ; �������� � ������� R16 ����� 3 (0x3)
out DDRD, temp         ; �������� �������� �� �������� R16 � ���� DDRD
sbi PORTD, PORTD0 ; ������ �� ��� PD0 �������� ������ (SBI - ���������� ��� � ������� I/O)
cbi PORTD, PORTD1 ; ������ �� ��� PD1 ������� ������ (CBI - �������� ��� � �������� I/O)

; ----- ���������������� ������� 0 -----
clr temp  ;������� ���� � ������� R16
//out TCNT0, temp  ;������� ������� ������� �������
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;��������� ���������� Timer0 
ldi temp, (1<<CS02) 
out TCCR0,temp ;��������� Timer0 div 1:256
ldi count_time, 0x32
//ldi leds, 0x3
sei ;��������� ����������

G_cykle:
rjmp G_cykle

; ----- �������� ���� ��������� -----
/*Start:
    sbi PORTD, PORTD0 ; ������ �� ��� PD0 �������� ������ (SBI - ���������� ��� � ������� I/O)
    cbi PORTD, PORTD1 ; ������ �� ��� PD1 ������� ������ (CBI - �������� ��� � �������� I/O)
    rcall Wait        ; �������� ������������ �������� �� ������� (RCALL - ����� ������������ ������������)
	cbi PORTD, PORTD0 ; ������ �� ��� PD0 ������� ������
    sbi PORTD, PORTD1 ; ������ �� ��� PD1 �������� ������    
    rcall Wait
    rjmp Start        ; ������� � ����� Start, ��������� ��� � ����� ( RJMP - ������� ������������)

; ----- ������������ �������� �� ������� -----
Wait:
    ldi  R17, Delay   ; �������� ��������� ��� �������� � ������� R17
WLoop0:  
    ldi  R18, 50      ; ��������� ����� 50 (0x32) � ������� R18
WLoop1:  
    ldi  R19, 0xC8    ; ��������� ����� 200 (0xC8, $C8) � ������� R19
WLoop2:  
    dec  R19          ; ��������� �������� � �������� R19 �� 1
    brne WLoop2       ; ������� � WLoop2 ���� �������� � R19 �� ����� 0 
    dec  R18          ; ��������� �������� � �������� R18 �� 1
    brne WLoop1       ; ������� � WLoop1 ���� �������� � R18 �� ����� 0
    dec  R17          ; ��������� �������� � �������� R17 �� 1
    brne WLoop0       ; ������� � WLoop0 ���� �������� � R17 �� ����� 0
ret */                  ; ������� �� ������������ Wait

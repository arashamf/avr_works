;������� 4 ���
.include "m8def.inc" //�������� ��������������� ��� ATmega8
.LIST                           ; �������� ��������� ��������

.def temp = R16 ;������� ����������
.def temp_port = R17
.def count_time = R18 ;������� ��������

; RAM ========================================================
.DSEG
StrPtr: .BYTE 2

; FLASH ======================================================
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
RJMP USART_UDRE ; UDR Empty Handler
RETI ;RJMP USART_TXC ; USART TX Complete Handler
RETI ;RJMP ADC ; ADC Conversion Complete Handler
RETI ;RJMP EE_RDY ; EEPROM Ready Handler
RETI ;RJMP ANA_COMP ; Analog Comparator Handler
RETI ;RJMP TWSI ; Two-wire Serial Interface Handler
RETI ;RJMP SPM_RDY ; Store Program Memory Ready Handler

; Interrupts ==============================================
; ----- ���������� ���������� Timer0 -----
TIM0:
dec count_time ;� ������ ���������� ��������� �� 1
breq end_timer ;���� ����, �� �� ����� ������� (BREQ - g������ �� ����� ���� 0 � ���������� ���������, ��� �� ��������� ��������� ���� �� ����)
reti ;����� ����� �� ����������

end_timer:
ldi temp, LED_Mask //������ ������� ����� � �������
IN temp_port, PORTC //������ ����� C
EOR temp_port, temp //����������� ���
OUT PORTC, temp_port //������ � ���� C
ldi count_time, 0x32 //��������� ������ �������� ��������

ldi 	ZL,low(String*2) 	; ������ �������� ����� ������, � ����������� ���� Z
ldi  	ZH, high(String*2)	; ������ �������� ����� ������, � ����������� ���� Z

ldi 	temp, (1<<RXEN)|(1<<TXEN)|(1<<RXCIE)|(1<<TXCIE)|(1<<UDRIE) //���������� �����, ��������, ���������� �� ����������� �������� UDR
//ldi 	temp, (1<<RXEN)|(1<<TXEN)
//out 	UCSRB, temp
//lpm 	temp, Z ;�������� ����� ������ ��������
//ldi temp, 0x48
rcall	out_byte	; �������� ��������� �������� �����.
reti ;����� ��������� ���������� �������

; ----------------------------------------------------------------------
USART_UDRE:
//rcall PUSHF ; ������, ����������� SREG
/*IN	temp, SREG
push temp
push ZL		; ��������� � ����� Z
push ZH*/

ldi 	ZL,low(String*2) 	; ������ �������� ����� ������, � ����������� ���� Z
ldi  	ZH, high(String*2)	; ������ �������� ����� ������, � ����������� ���� Z

/*sts	StrPtr,temp		; ��������� ������� ���� ��������� �� String (sts - ����� ��������� ��������� �� ������� ������)
sts	StrPtr+1,temp_port		; ��������� ������� ����

lds	ZL,StrPtr	; ���������� ���������� � ��������� ��������
lds	ZH,StrPtr+1*/

lpm	temp,Z		; ����������� ���� �� ������
 

/*cpi temp,0		; ���� �� ����,���������� ������
breq stop_TX	; ����� ��������� �������� (breq - ������� ���� �����)*/
 
out	UDR,temp		; ������ ������ � ����.
 
/*sts	StrPtr,ZL	; ��������� ��������� �������, � ������
sts	StrPtr+1,ZH	; 

Exit_TX:	
pop	ZH		; ����������� �� �����
pop	ZL
pop	temp
out	SREG,temp
reti ;����� ��������� ����������

stop_TX:
ldi 	temp, (0<<RXEN)|(0<<TXEN)|(0<<UDRIE) ; ���������� ���������� �� �����������, ����� �� �����������
out 	UCSRB, temp
rjmp	Exit_TX*/

ldi 	temp, (0<<RXEN)|(0<<TXEN)|(0<<RXCIE)|(0<<TXCIE)|(0<<UDRIE) ; ���������� ���������� �� �����������, ����� �� �����������
out 	UCSRB, temp
reti
; End Interrupts ==========================================

String:		.DB	"HELLO",0

Reset:
; ----- ������������� ����� -----
ldi temp, Low(RAMEND)  ; ������� ���� ��������� ������ ��� � R16 (LDI - ��������� ���������������� ��������)
out SPL, temp          ; ��������� �������� ����� ��������� ����� (OUT - �������� ������ �� ��������)
ldi temp, High(RAMEND) ; ������� ���� ��������� ������ ��� � R16
out SPH, temp          ; ��������� �������� ����� ��������� �����

.equ LED_Mask = 0x3 
.equ BAUD = 0x0C //�������� ��� UART 

; ----- ������������� ���� PC0 � PC1 ����� PORTC �� ����� -----
ldi temp, 0b00000011   ; �������� � ������� R16 ����� 3 (0x3)
out DDRC, temp         ; �������� �������� �� �������� R16 � ���� DDRC
sbi PORTC, PORTC0 ; ������ �� ��� PD0 �������� ������ (SBI - ���������� ��� � ������� I/O)
cbi PORTC, PORTC1 ; ������ �� ��� PD1 ������� ������ (CBI - �������� ��� � �������� I/O)

; ----- ���������������� ������� 0 -----
clr temp  ;������� ���� � ������� R16
ldi temp,(1<<TOIE0) 
out TIMSK, temp ;��������� ���������� Timer0 
ldi temp, (1<<CS02) 
out TCCR0,temp ;��������� Timer0 div 1:256
ldi count_time, 0x32
sei ;��������� ����������

; ----- ���������������� UART -----
ldi temp,BAUD ;�������� �������� 19200 ��� 4 ���
out UBRRL, temp
ldi temp,(1<<RXEN)|(1<<TXEN) ;���������� �����-��������
out UCSRB,temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ;UCSZ0=1, UCSZ1=1, ������ 8n1
out UCSRC,temp

Main:
rjmp Main


; ----- ������������ �������� ����� �� UART -----
out_byte: ;������� ����� �� temp � ��������� ����������
sbis UCSRA,UDRE ;SBIS - ���������� ���� ��� UDRE (����� � ��������) � �������� UCSRA ����������
rjmp out_byte
out UDR,temp ;������� �����
ret ;������� �� ��������� Out_com             ; ������� �� ������������ Wait

; ----- ������������ ���������� �������� ������� � ����� -----
PUSHF:
;PUSH	temp
IN	temp, SREG
PUSH temp
ret

; ----- ������������ ������ �������� ������� �� ����� -----
POPF:
POP	temp
OUT	SREG,temp
;POP temp
ret

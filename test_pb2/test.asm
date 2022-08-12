;������� 4 ���
.include "m8def.inc" //�������� ��������������� ��� ATmega8
.LIST                           ; �������� ��������� ��������

.def temp = R16 ;������� ����������
.def temp_port = R17
.def count_time = R18 ;������� ��������

.equ LED_Mask = 0x3 
.equ BAUD = 0x0C //�������� ��� UART 

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
in temp_port, PORTC //������ ����� C
eor temp_port, temp //����������� ���
out PORTC, temp_port //������ � ���� C
ldi count_time, 0x32 //��������� ������ �������� ��������

ldi 	temp,low(String*2) 	; ������ �������� ����� ������, � ����������� ���� Z
ldi  	temp_port, high(String*2)	; ������ �������� ����� ������, � ����������� ���� Z
sts	StrPtr,temp		; ��������� ������� ���� ��������� �� String (sts - ����� ��������� ��������� �� ������� ������)
sts	StrPtr+1,temp_port		; ��������� ������� ����

in temp_port, UCSRB //������ ����� UCSRB
ldi temp, (1<<UDRIE) //���������� ���������� �� ����������� �������� UDR
add temp_port, temp //�������� ��� ��������
out UCSRB, temp_port
reti ;����� ��������� ���������� �������

; ----------------------------------------------------------------------
USART_UDRE:
in	temp, SREG
push temp
push ZL		; ��������� � ����� Z
push ZH


lds	ZL, StrPtr	; ���������� ���������� � ��������� ��������
lds	ZH, StrPtr+1

lpm	temp,Z+		; ����������� ���� �� ������
out	UDR,temp		; ������ ������ � ����. 

cpi temp,'\n'		; ���� �� \n,���������� ������
breq stop_TX	; ����� ��������� �������� (breq - ������� ���� �����)
 
sts	StrPtr,ZL	; ��������� ��������� �������, � ������
sts	StrPtr+1,ZH	; sts - ��������� ��������������� � ����

Exit_TX:	
pop	ZH		; ����������� �� �����
pop	ZL
pop	temp
out	SREG,temp
reti ;����� ��������� ����������

stop_TX:
in temp_port, UCSRB ;������ ����� UCSRB
ldi temp, (1<<UDRIE) ;���������� ���������� �� ����������� �������� UDR
com temp ;�������� �������� ( ���������� �� �������)
and temp_port, temp ;���������� AND
out UCSRB, temp_port
rjmp	Exit_TX

; End Interrupts ==========================================

String:		.DB	"HELLO",'\r','\n',0 //0 - ������� ����� ������

Reset:
; ----- ������������� ����� -----
ldi temp, Low(RAMEND)  ; ������� ���� ��������� ������ ��� � R16 
out SPL, temp          ; ��������� �������� ����� ��������� ����� (OUT - �������� ������ �� ��������)
ldi temp, High(RAMEND) ; ������� ���� ��������� ������ ��� � R16
out SPH, temp          ; ��������� �������� ����� ��������� �����

; ----- ������������� ���� PC0 � PC1 ����� PORTC �� ����� -----
ldi temp, 0b00000011   ; �������� � ������� R16 ����� 3 (0x3)
out DDRC, temp         ; �������� �������� �� �������� R16 � ���� DDRC
sbi PORTC, PORTC0 ; ������ �� ��� PD0 �������� ������ (SBI - ���������� ��� � ������� I/O)
cbi PORTC, PORTC1 ; ������ �� ��� PD1 ������� ������ (CBI - �������� ��� � �������� I/O)

; ----- ���������������� ������� 0 -----
clr temp  ;������� �������� R16
ldi temp,(1<<TOIE0) ;��������� ���������� Timer0  
out TIMSK, temp
ldi temp, (1<<CS02) ;������������ 256
out TCCR0,temp 
ldi count_time, 0x32

; ----- ���������������� UART -----
ldi temp,BAUD ;�������� �������� 19200 ��� 4 ���
out UBRRL, temp
ldi temp, (1<<URSEL)|(3<<UCSZ0) ;UCSZ0=1, UCSZ1=1, ������ 8n1
out UCSRC,temp
ldi temp, (1<<RXEN)|(1<<TXEN)|((1<<RXCIE))|(1<<TXCIE) //���������� ���������� UART
out UCSRB, temp

; ----- ���������� ��������� StrPtr �� ������ String-----
ldi 	temp,low(String*2) 	; ������ �������� ����� ������ �������
ldi  	temp_port, high(String*2)	; ������ �������� ����� ������ �������
sts	StrPtr,temp		; ��������� ������� ���� ��������� �� String (sts - ����� ��������� ��������� �� ������� ������)
sts	StrPtr+1,temp_port		; ��������� ������� ���� ��������� �� String

sei ;��������� ����������

;-----------------------------------------------------------------------------------;
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
;push	temp
in	temp, SREG
push temp
ret

; ----- ������������ ������ �������� ������� �� ����� -----
POPF:
pop	temp
out	SREG,temp
;pop temp
ret

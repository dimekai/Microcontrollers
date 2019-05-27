.include "p30F4013.inc"
    

.GLOBAL _comandoLCD
.GLOBAL _busyFlagLCD
.GLOBAL _iniLCD
.GLOBAL _charLCD
.GLOBAL _stringLCD

.EQU RS_LCD, RD3
.EQU RW_LCD, RD9
.EQU ENABLE_LCD, RD2
.EQU BF_LCD, RB7
  

_busyFlagLCD:
    BCLR PORTD, #RS_LCD       ;RS = 0
    NOP
    BSET PORTD, #RW_LCD       ;RW = 1
    NOP
    BSET PORTD, #ENABLE_LCD   ;ENABLE = 1
    NOP
    SETM.B TRISB              ;Puerto B como entrada
    NOP
WAIT:
    BTSC PORTB, #BF_LCD
    GOTO WAIT
    BCLR PORTD, #ENABLE_LCD   ;ENABLE = 0
    NOP
    BCLR PORTD, #RW_LCD       ;RW = 0
    NOP
    CLR.B TRISB               ;Puerto B como salida
    NOP
    RETURN

_comandoLCD:
    CALL _busyFlagLCD
    BCLR PORTD, #RS_LCD       ;RS = 0
    NOP
    BCLR PORTD, #RW_LCD       ;RW = 0
    NOP
    BSET PORTD, #ENABLE_LCD   ;ENABLE = 1
    NOP	
    MOV.B WREG, PORTB         ;PORTB = W0
    NOP
    BCLR PORTD, #ENABLE_LCD   ;ENABLE = 0
    NOP
    RETURN
	
_iniLCD:
    ;Inicializacion
    CALL _retardo15ms         ;Retardo 1
    MOV #0X30, W0
    CALL _comandoLCD          ;comandoLCD(0x30)

    CALL _retardo15ms         ;Retardo 2
    MOV #0X30, W0
    CALL _comandoLCD          ;comandoLCD(0x30)

    CALL _retardo15ms         ;Retardo 3
    MOV #0X30, W0
    CALL _comandoLCD          ;comandoLCD(0x30)

    ;Configuracion
    MOV #0X38, W0             ;0X38: FUNCTION SET
    CALL _comandoLCD          ;comandoLCD(0x38)

    MOV #0X08, W0             ;0X08: DISPLAY ON/OFF
    CALL _comandoLCD          ;comandoLCD(0x08)

    MOV #0X01, W0             ;0X01: CLEAR DISPLAY
    CALL _comandoLCD          ;comandoLCD(0x01)

    MOV #0X06, W0             ;0X06: ENTRY MODE SET
    CALL _comandoLCD          ;comandoLCD(0x06)

    MOV #0X0F, W0             ;0X0F: DISPLAY ON/OFF
    CALL _comandoLCD          ;comandoLCD(0x0F)
    RETURN
	
_charLCD:
    CALL _busyFlagLCD
    BSET PORTD, #RS_LCD       ;RS = 1
    NOP
    BCLR PORTD, #RW_LCD       ;RW = 0
    NOP
    BSET PORTD, #ENABLE_LCD   ;ENABLE = 1
    NOP
    MOV.B WREG, PORTB         ;PORTB = W0
    NOP
    BCLR PORTD, #ENABLE_LCD   ;ENABLE = 0
    NOP
    RETURN
	
_stringLCD:
    PUSH W1
    MOV W0, W1
    CLR W0
CICLO:
    MOV.B [W1++], W0
    CP0.B W0
    BRA Z, FIN
    CALL _charLCD
    GOTO CICLO
FIN:
    POP W1
    RETURN
	
; Cabecera del DSPIC30F4013 -----------------------------------------
.include "p30F4013.inc" ; Aqui estan todos los registros del micro.

; Equivalencias
;  .EQU    RS_LCD,	RF2 ; RS

.GLOBAL __U1RXInterrupt	    ; Interrupcion del UART

    
__U1RXInterrupt:
    MOV	    U1RXREG,	W0
    CALL    _busyFlagLCD
    CALL    _datoLCD
    BCLR    IFS0,   #U1RXIF
    RETFIE
    
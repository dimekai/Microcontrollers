        .include "p30F4013.inc"
	.EQU	RS_LCD,	    RD0
	.EQU	RW_LCD,	    RD1
	.EQU	E_LCD,	    RD2
	
        .global _comandoLCD      
	.global _datoLCD      
	.global _busyFlagLCD
	.global _iniLCD8bits
;/**@brief ESTA RUTINA INICIALIZA EL LCD EN MODO 
; * DE 8 BITS.
; */
_iniLCD8bits:
    PUSH    W0
    
    CALL    _RETARDO_15ms
    MOV	    #0X30,	W0
    CALL    _comandoLCD

    CALL    _RETARDO_15ms
    MOV	    #0X30,	W0
    CALL    _comandoLCD

    ;CONTINUARA...
    POP	    W0
    RETURN
;/**@brief ESTA RUTINA VERIFICA LA BANDERA BF DEL LCD
; */
_busyFlagLCD:
    PUSH	W0
    
    MOV		#0X00FF,    W0
    IOR		TRISB		;TRISB = TRISB OR W0
    NOP
    BCLR	PORTD,	    #RS_LCD
    NOP
    ;CONTINUARA....
    
    POP		W0
    RETURN
;/**@brief ESTA RUTINA MANDA COMANDOS AL LCD
; * @param: W0, COMANDO A ENVIAR
; */
_comandoLCD:
    BCLR	PORTD,	    #RS_LCD
    NOP
    BCLR	PORTD,	    #RW_LCD
    NOP
    BSET	PORTD,	    #E_LCD
    NOP
    MOV.B	WREG,	    PORTB
    NOP
    BCLR	PORTD,	    #E_LCD
    NOP
    
    RETURN
;/**@brief ESTA RUTINA MANDA DATOS AL LCD
; * @param: W0, DATO A ENVIAR
; */
_datoLCD:
    ;CONTINUARA...
    RETURN

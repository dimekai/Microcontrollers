    
    ; |------------ CABECERA ------------|
    .include "p30F4013.inc"	    ; Aqui estan todos los registros del micro.
            
    ; |------------ FUNCION COMANDO AT ------------|
    .GLOBAL _comandoAT
    
    ; |------------ Interrupciones ----------------|
    .GLOBAL __U1RXInterrupt
    .GLOBAL __U2RXInterrupt
    

;// Envia comando AT mediante el UART1
;void comandoAT(const char * s) {
;    while (*s) {
;        IFS0bits.U1TXIF = 0;
;        U1TXREG = *s;
;        while (IFS0bits.U1TXIF == 0); // Ya se envio
;        ++s;
;    }
;}
_comandoAT:
    PUSH	W0
    MOV	W1,	W0	; W0 = W1
LoopA:
    CLR	W1
    MOV.B	[W0++],	W1	;   W1 = [W0++]
    CP0.B	W1		;   COMPARAMOS SI W1 = 0, Si es final de cadena
    BRA	Z   ,	SALIR	;   W1 = 0, entonces terminamos programa
    BCLR	IFS0,	#U1TXIF	;   W1 != 0, entonces IFS0, #U1TxIF = 0
    MOV	W1,	U1TXREG	;   U1TXREG = W1
    NOP
LoopB:
    BTSS	IFS0,	#U1TXIF	;   COMPARAMOS SI U1TXREG = 1
    GOTO	LoopB		;   U1TXREG != 1
    GOTO	LoopA		;   U1TXREG = 1 - Ya se envio
SALIR:
    POP	W0
    RETURN
    
;// UART1 - ESP8266, interrupcion de recepcion WIFI 
__U1RXInterrupt:
    PUSH    W0
    MOV	    U1RXREG,	W0
    
    MOV	    W0,		U2TXREG	; Mandar al FT232
    
    BCLR    IFS0,	#U1RXIF
    POP	    W0
    RETFIE
    
; Deprecated
; Receive interruption from UART 2 which is used for handling FT-232 module
;__U2RXInterrupt:
;    PUSH    W0			; Apilar registros sensibles
;    MOV	    U2RXREG,	W0	; W0 = U2RXREG
;    BCLR    IFS0,	#U1TXIF ; Apagar bandera de transmision del ESP 8266
;    MOV	    W0,		U1TXREG 
;u2rxint_notsent:
;    BTSS    IFS0,	#U1TXIF
;    GOTO    u2rxint_notsent
;    BCLR    IFS1,	#U2RXIF ; limpiar bandera de transmision del ESP 8266
;    POP	    W0
;    RETFIE


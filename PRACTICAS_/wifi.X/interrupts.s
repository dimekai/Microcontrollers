.include "p30F4013.inc"
    
.global __U2RXInterrupt
    
; Receive interruption from UART 2 which is used for handling FT-232 module
__U2RXInterrupt:
    MOV	    U2RXREG,	W0
    MOV	    W0,		U1TXREG ; As soon as there's content loaded at UXTXREG it'll be sent
    CALL    _retardo1s
    BCLR    IFS1,	#U2RXIF ; Clear flag interrupt
    RETFIE
    
    
; UART2 - PC, interrupcion de recepcion
;void __attribute__((__interrupt__)) _U2RXInterrupt( void ){
;    char c = U2RXREG;
;    IFS0bits.U1TXIF = 0;
;    U1TXREG = c;
;    while (IFS0bits.U1TXIF == 0) { }
;    IFS1bits.U2RXIF = 0; // Desactivar interrupcion
;}

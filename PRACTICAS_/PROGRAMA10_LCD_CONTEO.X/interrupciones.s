	.include "p30F4013.inc"
    
	.GLOBAL _INT0Interrupt
	.GLOBAL _uni
	.GLOBAL _dece
	.GLOBAL _cen
	.GLOBAL _umi
	
_INT0Interrupt:
    PUSH	W0
    
    INC.B	_uni
    MOV		#10,    W0
    CP.B	_uni		    ; si son iguales, no brinca
    BRA		NZ,	FIN
    CLR.B	_uni
    INC.B	_dec
    
FIN:
    BCLR    IFS0,   #INT0IF
    
    POP	    W0
    retfie
    
    



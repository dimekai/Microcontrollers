	.include "p30F4013.inc"
    
	.GLOBAL _INT0Interrupt
	.GLOBAL _uni		; unidades
	.GLOBAL _dec		; decenas
	.GLOBAL _cen		; centenas
	.GLOBAL _umi		; unidades de millar
	
_INT0Interrupt:
    PUSH	W0		    ; lo metemos a la pila
    
    INC.B	_uni		    ; UNI++    -  incrementamos en uno
    MOV		#10,    W0	    ; W0 = 10
    CP.B	_uni		    ; UNI == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_uni		    ; UNI = 0
    
    INC.B	_dec		    ; DECE++   -  incrementamos en uno
    MOV		#10,    W0	    ; W0 = 10
    CP.B	_dec		    ; DEC == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_dec		    ; DEC = 0
    
    INC.B	_cen		    ; CEN++   -  incrementamos en uno
    MOV		#10,    W0	    ; W0 = 10
    CP.B	_cen		    ; CEN == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_cen		    ; CEN = 0
    
    INC.B	_umi		    ; UMI++   -  incrementamos en uno
    MOV		#10,    W0	    ; W0 = 10
    CP.B	_umi		    ; UMI == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_umi		    ; UMI = 0
    
FIN:
    BCLR    IFS0,   #INT0IF
    
    POP	    W0
    RETFIE
    
    



	.include "p30F4013.inc"
    
	.GLOBAL _INT0Interrupt
	.GLOBAL _uni		; unidades
	.GLOBAL _dec		; decenas
	.GLOBAL _cen		; centenas
	.GLOBAL _umi		; unidades de millar

; |================== INT0Interrupt ==================|
; |@brief: ISR externa por INT0
; |@param: void
_INT0Interrupt:
    PUSH	W0		    ; lo metemos a la pila
    
    MOV     #10,    W0      ; W0 = 10: Nos servira para las comparaciones

    INC.B	_uni		    ; UNI++    -  incrementamos en uno
    CP.B	_uni		    ; UNI == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_uni		    ; UNI = 0
    
    INC.B	_dec		    ; DECE++   -  incrementamos en uno
    CP.B	_dec		    ; DEC == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_dec		    ; DEC = 0
    
    INC.B	_cen		    ; CEN++   -  incrementamos en uno
    CP.B	_cen		    ; CEN == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_cen		    ; CEN = 0
    
    INC.B	_umi		    ; UMI++   -  incrementamos en uno
    CP.B	_umi		    ; UMI == 10 - si son iguales, no ejecuta el BRA y se pasa al CLR.B
    BRA		NZ,	FIN
    CLR.B	_umi		    ; UMI = 0
    
FIN:
    BCLR    IFS0,   #INT0IF ; Se apaga la bandera de activación de la interrupción.
    
    POP	    W0              ; Sacamos de la pila-Restauramos valor de W0
    RETFIE
    
    
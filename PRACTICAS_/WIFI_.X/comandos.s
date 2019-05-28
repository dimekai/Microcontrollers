    ; |------------ CABECERA ------------|
    .include "p30F4013.inc"	    ; Aqui estan todos los registros del micro.
            
    ; |------------ FUNCION COMANDO AT ------------|
    .GLOBAL _comandoAT
    
    _comandoAT:
	MOV	W1,	W0
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
	RETURN
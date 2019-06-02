    ; |------------ CABECERA ------------|
    .include "p30F4013.inc"	    ; Aqui estan todos los registros del micro.
        
    ; |===================== FUNCIONES DE RETARDO =====================|
    ; Estas funciones son para generar retardos de 1 segundo en el cto.
    .GLOBAL _retardo_1s
    
    _retardo_1s:
	PUSH	W0
	PUSH	W1
	
	MOV	#10,	W1
    CICLOA:
	CLR	W0
    CICLOB:
	DEC	W0,	W0
	BRA	NZ,	CICLOB
	
	DEC	W1,	W1
	BRA	NZ,	CICLOA
	
	POP	W1
	POP	W0
	RETURN	
    



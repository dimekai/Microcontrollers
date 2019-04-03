	.include "p30F4013.inc"

	.GLOBAL _RETARDO_15ms
	.GLOBAL _RETARDO_30ms

;|---------- FUNCION DE RETARDO DE 15 ms ----------|
_RETARDO_15ms:
	PUSH    W0
    PUSH    W1	
    CLR	    W0
CICLO_15ms:
    DEC	    W0,	    W0
    BRA	    NZ,	    CICLO_15ms

    POP	    W1
    POP	    W0
    RETURN	

;|---------- FUNCION DE RETARDO DE 30 ms ----------|
_RETARDO_30ms:
	CALL _RETARDO_15ms
	CALL _RETARDO_15ms
	RETURN
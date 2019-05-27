
.include "p30F4013.inc"

.GLOBAL _retardo1s
.GLOBAL _retardo15ms


; delay one second approximately
_retardo1s:
    PUSH    W0  ; PUSH.D W0
    PUSH    W1
    MOV	    #10,    W1
CICLO2_1S:
    CLR	    W0  
CICLO1_1S:	
    DEC	    W0,	    W0
    BRA	    NZ,	    CICLO1_1S	

    DEC	    W1,	    W1
    BRA	    NZ,	    CICLO2_1S

    POP	    W1  ; POP.D W0
    POP	    W0
    RETURN
	
_retardo15ms:
    PUSH	W0
    CLR		W0
    MOV		#9275,	    W0
ciclo_15ms:
    DEC		W0,	    W0
    BRA		NZ,	    ciclo_15ms
    POP		W0
    RETURN

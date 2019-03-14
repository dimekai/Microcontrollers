    ; Cabecera
    .include "p30F4013.inc"
    .GLOBAL _funcion1	    ;Se hace global y puedo mandar a llamarla desde lenguaje C.
    .GLOBAL _funcion2
    
_funcion1:
    return

_funcion2:
    mov	#12,	W0
    mov	#3 ,	W1
    add	W0 ,	W1,	W0
    return
; Cabecera del DSPIC30F4013 -----------------------------------------
.include "p30F4013.inc" ; Aqui estan todos los registros del micro.

; Declaraciones globales 
; Funciones 
.GLOBAL _INT0Interrupt

.GLOBAL _clk_start
.GLOBAL _clk_remove_lock 

; Variables 
.GLOBAL _dhr  ; decenas de hora
.GLOBAL _uhr  ; unidades de hora
.GLOBAL _dmin ; decenas de minuto
.GLOBAL _umin ; unidad de minuto
.GLOBAL _dseg ; decena de segundo
.GLOBAL _useg ; unidad de segundo

; Equivalencias
;  .EQU    RS_LCD,	RF2 ; RS

; Oscilador externo de 32768 Hz regexp(0b 0001 0000 0000 0000 0000)

_clk_remove_lock:
	mov.b 	#0x46, 		w1 			; follow write sequence
	mov.b 	#0x57, 		w2 			; for OSCCONL writes
	mov 	#OSCCONL, 	w3 
	mov.b 	w1, 		w3
	mov.b 	w2, 		w3
	bset 	OSCCONL, 	#LPOSCEN 	; enable 32kHz external xtal 

_clk_start:
	BSET	T1CON, 	#TON

; Variables 
.GLOBAL _dhr  ; decenas de hora
.GLOBAL _uhr  ; unidades de hora
.GLOBAL _dmin ; decenas de minuto
.GLOBAL _umin ; unidad de minuto
.GLOBAL _dseg ; decena de segundo
.GLOBAL _useg ; unidad de segundo

_INT0Interrupt:
    PUSH.S				; push w0, ..., w3 (registros sombra)
    
    ; Almacenamos en registros para hacer comparaciones posteriores
    MOV     #6,    W0      
    MOV     #10,   W1      
    MOV     #24,   W2     
    MOV	    #60,   W3

    INC.B 	_useg 			; Segundos ----------------------------------------
    MOV.B		#_useg,	W1
    CP		w1, 	#10 	; segundo operando a lo mas tiene 5 bits
    BRA 	NZ, 	FIN 
    CLR.B 	_useg

    INC.B	_dseg		    
    MOV.B		_dseg,	W1
    CP.B	W1,	#6 		; NZ = !(W3 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_dseg		    
    
    INC.B	_umin		   	; Minutos ---------------------------------------- 
    MOV.B		_umin,	W1
    CP.B	W1,	#10 	; NZ = !(W3 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_umin		    
    
    INC.B	_dmin		    
    MOV.B		_dmin,	W1
    CP.B	W1,	#6 		; NZ = !(W3 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_dmin		    

	; TODO
    INC.B	_uhr 			; Horas -----------------------------------------		    
    MOV.B		_uhr,	W1
    CP.B	W1,  #10 	; NZ = !(W3 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_uhr		    

    INC.B	_dhr 			; 
    MOV.B		_dhr,	W1
    CP.B	W1,	#3 	; NZ = !(W3 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_dhr		    

FIN:
    BCLR    IFS0,   #INT0IF ; Se apaga la bandera de activación de la interrupción.
    
    POP.S 					; POP registros sombra
    RETFIE
    

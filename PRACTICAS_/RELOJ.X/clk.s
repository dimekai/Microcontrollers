; Cabecera del DSPIC30F4013 -----------------------------------------
.include "p30F4013.inc" ; Aqui estan todos los registros del micro.

; Declaraciones globales 
; interrupcion. 
.GLOBAL __T1Interrupt

; funciones
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

; |------------ FUNCION DE INICIALIZACIÓN ------------|
.GLOBAL _iniInterrupciones  ; Esta en C
    
_iniInterrupciones:
    BCLR IFS0,      #INT1IF
    BSET IEC0,      #INT1IE
    return

_clk_remove_lock:
	mov.b 	#0x46, 		w1 			; follow write sequence
	mov.b 	#0x57, 		w2 			; for OSCCONL writes
	mov 	#OSCCONL, 	w3 
	mov.b 	w1, 		w3
	mov.b 	w2, 		w3
	bset 	OSCCONL, 	#LPOSCEN 	; enable 32kHz external xtal 
	return

_clk_start:
	BSET	T1CON, 	#TON
	return

; |================ ISR_T1 ================|
; @brief: Genera el reloj por software.
; DOS guiones bajos como prefijo denota interrupcion.
__T1Interrupt:
    PUSH.S			; push w0, ..., w3 (registros sombra)

    MOV.B	#10,   W0
    INC.B 	_useg 		; Segundos -----------------------------
    CP.B	_useg		; Compare la variable con WREG
    BRA 	NZ, 	FIN 
    CLR.B 	_useg

    MOV 	#6,    W0
    INC.B	_dseg		    
    CP.B	_dseg 		; NZ = !(6 - _dseg)
    BRA		NZ,	FIN
    CLR.B	_dseg		    
    
    MOV 	#10, 	W0
    INC.B	_umin		; Minutos ------------------------------ 
    CP.B	_umin		; NZ = !(10 - _umin)
    BRA		NZ,	FIN
    CLR.B	_umin		    
    
    MOV 	#6, 	W0
    INC.B	_dmin		    
    CP.B	_dmin 		; NZ = !(6 - _dmin)
    BRA		NZ,	FIN
    CLR.B	_dmin		    

    MOV     	#10,	W0    	
    BTSC 	_dhr,	#1	; W0 = (_dhr == 2) ? 4 : 10
    MOV     	#4,	W0     

    INC.B	_uhr 		; Horas --------------------------------
    CP.B	_uhr	 	; NZ = !(Wn - f)
    BRA		NZ,	FIN
    CLR.B	_uhr		    

    MOV		#3,	W0
    INC.B	_dhr 	
    CP.B	_dhr		; NZ = !(Wn - f)
    BRA		NZ,	FIN
    CLR.B	_dhr		    

FIN:
    BCLR    IFS0,   #INT0IF	; Se apaga la bandera de activacion de la interrupcion.
    
    POP.S 			; POP registros sombra
    RETFIE
    

    ; |------------ CABECERA ------------|
    .include "p30F4013.inc" ; Aqui estan todos los registros del micro.
        
    ; |------------ FUNCIONES LCD ------------|
    ; Estas funciones son de los diagramas que definimos
    .GLOBAL _comandoLCD	    
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD
    .GLOBAL _iniLCD8bits
    .GLOBAL _imprimeLCD
    
    ; |------------ EQUIVALENCIAS ------------|
    ; Este es el equivalente a definicion de macros (#define) en C
    .EQU    RS_LCD,	RF2 ; RS
    .EQU    RW_LCD,	RF3 ; RW
    .EQU    ENABLE_LCD, RD2 ; ENABLE
    .EQU    BF_LCD,	RB7 ; BF: BUSY_FLAG
    
    ; |------------ FUNCION DE INICIALIZACI�N ------------|
    .GLOBAL _iniInterrupciones	; Esta en C
    .GLOBAL _T1Interrupt	; ISR_T1
    
    ; |=============== NOTAS MUSICALES ===============|
    .GLOBAL _NOTA_DO	    ; preescalar = 64
    .GLOBAL _NOTA_RE	    ; preescalar = 64
    .GLOBAL _NOTA_MI	    ; preescalar = 256
    .GLOBAL _NOTA_FA	    ; preescalar = 1
    .GLOBAL _NOTA_SOL	    ; preescalar = 1
    .GLOBAL _NOTA_LA	    ; preescalar = 8
    .GLOBAL _NOTA_SI	    ; preescalar = 1
    
    .GLOBAL _MENSAJE_DO
    .GLOBAL _MENSAJE_RE
    .GLOBAL _MENSAJE_MI
    .GLOBAL _MENSAJE_FA
    .GLOBAL _MENSAJE_SOL
    .GLOBAL _MENSAJE_LA
    .GLOBAL _MENSAJE_SI
    
; |------------------ FUNCION COMANDO_LCD ------------------|
_comandoLCD:
    CLR	    TRISD
    NOP
    
    BCLR    PORTF, #RS_LCD	; RS = 0
    NOP
    BCLR    PORTF, #RW_LCD	; RW = 0
    NOP
    BSET    PORTD, #ENABLE_LCD	; ENABLE = 1
    NOP
    
    MOV.B   WREG,   PORTB	; PORTB = W0
    NOP

    BCLR    PORTD, #ENABLE_LCD	; ENABLE = 0
    NOP
  
    RETURN
	    
; |------------------- FUNCION DATO LCD -------------------|    
_datoLCD:
    CLR	    TRISF
    CLR	    TRISD
    
    BSET    PORTF, #RS_LCD	;   RS = 1
    NOP
    BCLR    PORTF, #RW_LCD	;   RW = 0
    NOP
    BSET    PORTD, #ENABLE_LCD	;   ENABLE = 1
    NOP
    
    MOV.B   WREG,   PORTB	;   PORTB = W0
    NOP

    BCLR    PORTD, #ENABLE_LCD	;   ENABLE = 0
    NOP
  
    RETURN    

; |------------------- FUNCION BUSY_FLAG -------------------|   
_busyFlagLCD:
    PUSH    W0
    CLR	    TRISF
    CLR	    TRISD
    
    BCLR    PORTF,  #RS_LCD	;   RS = 0
    NOP

    SETM.B  TRISB		;   Prendemos la parte baja - TRISB OR 0X00FF
    NOP

    BSET    PORTF,  #RW_LCD	;   RW = 1
    NOP

    BSET    PORTD,  #ENABLE_LCD	;   ENABLE = 1
    NOP

PROCESO:
    BTSC	PORTB,	#BF_LCD	;   VERIFICA SI BF = 0, SI NO, SE EJECUTA EL GOTO
    GOTO	PROCESO
    
    BCLR	PORTD,	#ENABLE_LCD ;	ENABLE = 0
    NOP
    BCLR	PORTF, #RW_LCD	    ;   RW = 0
    NOP
    
    SETM	TRISB		    ; TRISB = 0xFFFF
    NOP
    CLR.B	TRISB		    ; TRISB = 0xFF00 ; APAGA LA PARTE BAJA
    NOP
    
    POP	    W0
    RETURN;
    
; |------------------- FUNCION INICIALIZAR LCD DE 8 BITS -------------------|
; | ---- INICIALIZACION ---|
; | D7 | D6 | D5 | D4 | D3 |  D2 |  D1 |  D0 |     COMANDO    | CODIGO |
; | 0  | 0  | 1  | 1  | X  |  X  |  X  |  X  |   FUNCION SET  |  0X30  |    ; RETARDO 01
; | 0  | 0  | 1  | 1  | X  |  X  |  X  |  X  |   FUNCION SET  |  0X30  |    ; RETARDO 02
; | 0  | 0  | 1  | 1  | X  |  X  |  X  |  X  |   FUNCION SET  |  0X30  |    ; RETARDO 03
; | ---- CONFIGURACION ----|
; | 0  | 0  | 1  | 1  | N=1| F=0 |  X  |  X  |   FUNCION SET  |  0X38  |
; | 0  | 0  | 0  | 0  | 1  | D=0 | C=0 | B=0 | DISPLAY ON/OFF |  0X08  |
; | 0  | 0  | 0  | 0  | 0  |  0  |  0  |  1  |  CLEAR DISPLAY |  0X01  |
; | 0  | 0  | 0  | 0  | 0  |  1  |I/D=1| S=0 | ENTRY MODE SET |  0X06  |
; | 0  | 0  | 0  | 0  | 1  | D=1 | C=1 | B=1 | DISPLAY ON/OFF |  0X0F  |
    
_iniLCD8bits:
    CLR	    W0
    ; ------- TABLA DE INICIALIZACION -------------
    CALL    RETARDO_15ms	; -- RETARDO 01
    MOV	    #0X30,  W0
    CALL    _comandoLCD

    CALL    RETARDO_15ms	; -- RETARDO 02
    MOV	    #0X30,  W0
    CALL    _comandoLCD
    
    CALL    RETARDO_15ms	; -- RETARDO 03
    MOV	    #0X30,  W0
    CALL    _comandoLCD
    
    ; ------- TABLA DE CONFIGURACION ---------------
    CALL    _busyFlagLCD
    MOV	    #0X38,  W0	    ;	CODIGO: 0X38 - FUNCTION SET
    CALL    _comandoLCD
    
    CALL    _busyFlagLCD
    MOV	    #0X08,  W0	    ;	CODIGO: 0X08 - DISPLAY ON/OFF
    CALL    _comandoLCD
    
    CALL    _busyFlagLCD
    MOV	    #0X01,  W0	    ;	CODIGO: 0X01 - CLEAR DISPLAY
    CALL    _comandoLCD
    
    CALL    _busyFlagLCD
    MOV	    #0X06,  W0	    ;	CODIGO: 0X06 - ENTRY MODE SET
    CALL    _comandoLCD
    
    CALL    _busyFlagLCD
    MOV	    #0X0F,  W0	    ;	CODIGO: 0X0F - DISPLAY ON/OFF
    CALL    _comandoLCD
    
    RETURN

; |=============== RETARDO ============|
; @brief: Genera un retardo de 15ms
RETARDO_15ms:
    PUSH    W0
    PUSH    W1  
    CLR     W0
CICLO1_1S:
    DEC     W0,     W0
    BRA     NZ,     CICLO1_1S

    POP     W1
    POP     W0
    return

; |================ ISR_T1 ================|
; @brief: Genera el reloj por software.
_T1Interrupt:
    BTG	    LATD,   #LATD8
    NOP
    BCLR    IFS0,   #T1IF
    RETFIE    
    
; |================== IMPRIMI EN LCD ==================|
; |@brief: Imprime en el LCD una cadena de caracteres
; |@param: Cadena de caracteres
_imprimeLCD:
    ; Se manda la direccion asociada a la variable
    ; A partir de esto, utilizamos [] para tomar la direccion que se manda
    PUSH    W1 
    MOV	    W0,	    W1
CICLO:
    MOV.B   [W1++], W0	    ; Se utiliza .b ya que cada elemento, cada letra, es un byte
    CP0.B   W0		    ; Compara el primer byte de W0 con 0
    BRA	    Z, FIN	    ; Si ya llego al final, si es nulo, terminamos el programa
    CALL    _busyFlagLCD
    CALL    _datoLCD
    GOTO    CICLO
FIN:
    POP	    W1
    RETURN
    
    
; |=============== NOTAS MUSICALES ===============|
_NOTA_DO:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #55,	W0	; 
    MOV	    W0,		PR1	; PR1 = 55
    MOV	    #0x8020,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8020
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_DO, W0
    CALL    _imprimeLCD
    
    POP	    W0
    RETURN

_NOTA_RE:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #49,	W0	; 
    MOV	    W0,		PR1	; PR1 = 49
    MOV	    #0x8020,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8020
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_RE, W0
    CALL    _imprimeLCD
    
    POP	    W0
    RETURN
    
_NOTA_MI:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #11,	W0	; 
    MOV	    W0,		PR1	; PR1 = 11
    MOV	    #0x8030,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8030
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_MI, W0
    CALL    _imprimeLCD
    
    POP	    W0
    RETURN    

_NOTA_FA:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #2639,	W0	; 
    MOV	    W0,		PR1	; PR1 = 2639
    MOV	    #0x8000,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8000
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_FA, W0
    CALL    _imprimeLCD
    
    POP	    W0
    RETURN

_NOTA_SOL:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #2351,	W0	; 
    MOV	    W0,		PR1	; PR1 = 2351
    MOV	    #0x8000,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8000
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_SOL, W0
    CALL    _imprimeLCD
    
    POP	    W0    
    RETURN
    
_NOTA_LA:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #262,	W0	; 
    MOV	    W0,		PR1	; PR1 = 262
    MOV	    #0x8010,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8010
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_LA, W0
    CALL    _imprimeLCD
    
    POP	    W0    
    RETURN

_NOTA_SI:
    
    PUSH    W0
    
    CLR	    TMR1		; TMR1 = 0
    MOV	    #1866,	W0	; 
    MOV	    W0,		PR1	; PR1 = 1866
    MOV	    #0x8000,	W0	
    MOV	    W0,		T1CON	; T1CON = 0x8000
    
    CALL    _busyFlagLCD
    MOV	    0x1,    W0		; Limpia la pantalla del LCD.
    MOV	    #_MENSAJE_SI, W0
    CALL    _imprimeLCD
    
    POP	    W0
    RETURN    
    
_iniInterrupciones:
    BCLR IFS0,	    #INT1IF
    BSET IEC0,	    #INT1IE
    return
    
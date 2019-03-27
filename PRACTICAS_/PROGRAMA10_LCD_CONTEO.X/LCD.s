    ; |------------ CABECERA ------------|
    .include "p30F4013.inc" ; Aqui estan todos los registros del micro.
    
    ; |------------ FUNCIONES ------------|
    ; Estas funciones son de los diagramas que definimos
    .GLOBAL _comandoLCD	    
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD
    .GLOBAL _iniLCD8bits
    .GLOBAL _imprimeLCD
    
    ; |------------ EQUIVALENCIAS ------------|
    ; Este es el equivalente a definicion de macros (#define) en C
    ; Estas nos siven para mapear las banderas del LCD
    .EQU    RS_LCD,	RF2 ; RS
    .EQU    RW_LCD,	RF3 ; RW
    .EQU    ENABLE_LCD, RD2 ; ENABLE
    .EQU    BF_LCD,	RB7 ; BF: BUSY_FLAG
    
; |================== FUNCION COMANDO_LCD ==================| LISTA
; |@brief: Ejecuta un comando del LCD
; |@param: Un comando

_comandoLCD:
    CLR     TRISD
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
    
; |================== FUNCION DATO LCD ==================| Lista   
; |@brief: Escribe un dato en el LCD
; |@param: Un dato
_datoLCD:
    CLR     TRISF
    CLR     TRISD
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

; |================== FUNCION BUSY_FLAG ==================|   
; |@brief: Se ejecuta mientras el LCD aun no está listo para  
; |        recibir un nuevo dato o comando
; |@param: void
_busyFlagLCD:
    PUSH    W0
    CLR     TRISF
    CLR     TRISD

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
;   SETM    TRISB 
    MOV		#0XFF00,    W0	    ;   Se usara para realizar la masacara de bits
    NOP
    IOR		TRISB,	    WREG    ;	TRISB = TRISB OR 0XFF00 
    NOP

    POP     W0
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
    CLR     W0
    ;|================== TABLA DE INICIALIZACION ==================|
    CALL    _RETARDO_15ms	; -- RETARDO 01
    MOV	    #0X30,  W0
    CALL    _comandoLCD
    
    CALL    _RETARDO_15ms	; -- RETARDO 02
    MOV	    #0X30,  W0
    CALL    _comandoLCD
    
    CALL    _RETARDO_15ms	; -- RETARDO 03
    MOV	    #0X30,  W0
    CALL    _comandoLCD
    
    ;|================== TABLA DE CONFIGURACIÓN ==================|
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
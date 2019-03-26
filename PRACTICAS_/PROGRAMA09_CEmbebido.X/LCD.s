    ; |------------ CABECERA ------------|
    .include "p30F4013.inc" ; Aqui estan todos los registros del micro.
    .GLOBAL _funcion1	    ; Se hace global y puedo mandar a llamarla desde lenguaje C.
    .GLOBAL _funcion2	    ; Con esta directiva puedo compartir los modulos
    .GLOBAL _funcion3
    .GLOBAL _funcion4
    .GLOBAL _var	    ; Esta variable es global para que pueda ser llamda desde lenguaje C
    
    ; |------------ FUNCIONES ------------|
    ; Estas funciones son de los diagramas que definimos
    .GLOBAL _comandoLCD	    
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD
    .GLOBAL _iniLCD8bits
    
    ; |------------ EQUIVALENCIAS ------------|
    ; Este es el equivalente a definicion de macros (#define) en C
    .EQU    RS_LCD,	RF2 ; RS
    .EQU    RW_LSD,	RF3 ; RW
    .EQU    ENABLE_LCD, RD2 ; ENABLE
    .EQU    BF_LCD,	RB7 ; BF: BUSY_FLAG
    
; |------------------ FUNCION COMANDO_LCD ------------------|
_comandoLCD:
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

; En el DSPIC cada instruccion tarda 542 ns en ejecutarse, la instruccion DEC
; requiere un ciclo de trabajo util, BRA siempre requiere dos, en caso de no 
; ejecutarse el salto se remplaza por la instruccion NOP. Asi, las instrucciones
; DEC W0, W0
; BRA NZ, LABEL
; requieren tres ciclos de reloj, 542 ns * 3 = 1716 ns, 
; tenemos 1716 n W = 15 ms -> W \aprox 8741.2588, pongo valores de mas en w0
; por paranoico.
RETARDO_15ms:	
	PUSH.S					; push w0, w1, w2, w3
	MOV	#8750,	w0	
RETARDO_15ms_loop:
	DEC 	w0, 	w0
	BRA 	NZ, 	RETARDO_15ms_loop	; if nz goto label
	POP.S					; pop w0, ..., w3
	RETURN
	
;	funcion int_to_char ====================================================
int_to_char:
	ADD    w0,    #0x30,    w0
	RETURN

; 	FUNCION imprimeLCD =====================================================
_imprimeLCD:
	push 	w2			; pointer
	mov 	w0,	w2		; w2 = &string[0]
imprimeLcdLoop:
	mov.b	[W2++],	w0
	cp0.b	w0
	bra 	z,	imprimeLcdEnd	; if w0 = '\0' goto label
	call 	_busyFlagLCD 		; ESTO ESTA BIEN ????????????????????????
	call 	_datoLCD		; Warning, _datoLCD escribe en w0
	goto 	imprimeLcdLoop
imprimeLcdEnd:
	POP 	w2
	RETURN
    
; |------------------- FUNCION DATO LCD -------------------|    
_datoLCD:
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
    MOV		#0XFF00,    W0	    ;   Se usara para realizar la masacara de bits
    IOR		TRISB,	    WREG    ;	TRISB = TRISB OR 0XFF00 
    
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
    
    ; ------- TABLA DE CONFIGURACIÓN ---------------
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

    
    
; |------------------- FUNCION REALIZADAS EN CLASE -------------------|       
_funcion1:
    push	w0
    mov	#3,	w0
    mov w0,	_var
    pop		w0
    return

    ; El valor del primer registro del procesador
    ; es el primer registro que siempre se retorna
    ; En este ejemplo, el primer registro es W0, y por 
    ; tanto aquel valor que se va a retornar sera W0    
_funcion2:
    push	W1
    mov	#12,	W0
    mov	#3 ,	W1
    add	W0 ,	W1,	W0  
    pop		W1
    return

; Funcion con paso de parametros.
_funcion3:
    ;Cuando pasamos parametros podemos pasarlos de dos manera, dependiendo de la arquitectura
    ; 1.- Usando la pila
    ;	    Se meten en la pila, se sacan y se realiza la operacion
    ; 2.- A traves de registros
    ; Los parametros que le estoy enviando ya estan los parametros cargados en w0
    ; Usa los primos 8 registros con respecto a los primeros 8 parametros
    add	    W0,	    W1,	    W0
    return

    
_funcion4:
    ; Se manda la direccion asociada a la variable
    ; A partir de esto, utilizamos [] para tomar la direccion que se manda
    clr W2		    ; Este sera nuestro apuntador   W2 = 0
    push W1
    push W2
    ciclo:
	mov.b   [W0++],   W1	    ; Se utiliza .b ya que cada elemento, cada letra, es un byte
	cp0.b	W1		    ; Compara el primer byte de W1 con 0
	bra	z,	    fin	    ; Si ya llego al final, si es nulo, terminamos el programa
	inc	W2,	    W2	    ; W2++
	goto    ciclo
    fin:
	MOV	    W2,	W0
	pop	    W2
	pop	    W1	
	return    

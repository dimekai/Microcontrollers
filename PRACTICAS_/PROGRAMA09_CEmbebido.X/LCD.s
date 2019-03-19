    ; Cabecera
    .include "p30F4013.inc" ; Aqui estan todos los registros del micro.
    .GLOBAL _funcion1	    ; Se hace global y puedo mandar a llamarla desde lenguaje C.
    .GLOBAL _funcion2	    ; Con esta directiva puedo compartir los modulos
    .GLOBAL _funcion3
    .GLOBAL _funcion4
    .GLOBAL _var
    .GLOBAL _comandoLCD
    .GLOBAL _datoLCD
    .GLOBAL _busyFlagLCD
    .GLOBAL _iniLCD8bits
    
    .EQU    RS_LCD,	RF2  
    .EQU    RW_LSD,	RF3
    .EQU    ENABLE_LCD, RD2
    
_comandoLCD:
    BCLR    PORTF, #RS_LCD
    NOP
    BCLR    PORTF, #RW_LCD
    NOP
    BSET    PORTD, #ENABLE_LCD
    NOP
    
    MOV.B   WREG,   PORTB
    NOP
    BCLR    PORTD, #ENABLE_LCD
    NOP
  
    RETURN

_datoLCD:
    BSET    PORTF, #RS_LCD
    NOP
    BCLR    PORTF, #RW_LCD
    NOP
    BSET    PORTD, #ENABLE_LCD
    NOP
    
    MOV.B   WREG,   PORTB
    NOP
    BCLR    PORTD, #ENABLE_LCD
    NOP
  
    RETURN    
    
_busyFlagLCD:
    ;.... aqui va el demas choro
    RETURN;
    
 
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
    MOV	    #0X38,  W0
    CALL    _comandoLCD
    ; CONTINUARA..... CON LA TABLA
    
    RETURN
    
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
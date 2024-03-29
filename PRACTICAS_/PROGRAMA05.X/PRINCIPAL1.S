;/**@brief ESTE PROGRAMA LEE LOS VALORES COLOCADOS EN EL PUERTO D
; * (RD3, RD2, RD2, RD0) MEDIANTE UN DIP-SWITCH Y LOS COLOCA EN EL 
; * PUERTO B (RB3, RB2, RB1, RB0) DONDE SE TIENEN CONECTADOS LEDS
; * PARA VISUALIZAR LA SALIDA
; * @device: DSPIC30F4013
; */
        .equ __30F4013, 1
        .include "p30F4013.inc"
;******************************************************************************
; BITS DE CONFIGURACIÓN
;******************************************************************************
;..............................................................................
;SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 
;ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR
;FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 
;EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA TRAMPA
;Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  
;..............................................................................
        config __FOSC, CSW_FSCM_OFF & FRC   
;..............................................................................
;SE DESACTIVA EL WATCHDOG
;..............................................................................
        config __FWDT, WDT_OFF 
;..............................................................................
;SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), POWER UP TIMER (PWRT)
;Y EL MASTER CLEAR (MCLR)
;POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE 
;ALIMENTACIÓN ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V
;BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACIÓN DECAE
;POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 
;PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO AYUDA
;A ASEGURAR QUE EL VOLTAJE DE ALIMENTACIÓN SE HA ESTABILIZADO (16ms) 
;..............................................................................
        config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
;..............................................................................
;SE DESACTIVA EL CÓDIGO DE PROTECCIÓN
;..............................................................................
   	config __FGS, CODE_PROT_OFF & GWRP_OFF      

;******************************************************************************
; SECCIÓN DE DECLARACIÓN DE CONSTANTES CON LA DIRECTIVA .EQU (= DEFINE EN C)
;******************************************************************************
        .equ MUESTRAS,	64	    ;NÚMERO DE MUESTRAS
	.equ DIG_0,	0X7E	    ; 0 EN DISPLAY
	.equ DIG_1,	0X30	    ; 1 EN DISPLAY
	.equ DIG_2,	0X6D	    ; 2 EN DISPLAY
	.equ DIG_3,	0X79	    ; 3 EN DISPLAY
	.equ DIG_4,	0X33	    ; 4 EN DISPLAY
	.equ DIG_5,	0X5B	    ; 5 EN DISPLAY
	.equ DIG_6,	0X5F	    ; 6 EN DISPLAY
	.equ DIG_7,	0X70	    ; 7 EN DISPLAY
	.equ DIG_8,	0X7F	    ; 8 EN DISPLAY
	.equ DIG_9,	0X7B	    ; 9 EN DISPLAY 
;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
;..............................................................................
;PROPORCIONA ALCANCE GLOBAL A LA FUNCIÓN _wreg_init, ESTO PERMITE LLAMAR A LA 
;FUNCIÓN DESDE UN OTRO PROGRAMA EN ENSAMBLADOR O EN C COLOCANDO LA DECLARACIÓN
;"EXTERN"
;..............................................................................
        .global _wreg_init     
;..............................................................................
;ETIQUETA DE LA PRIMER LINEA DE CÓDIGO
;..............................................................................
        .global __reset          
;..............................................................................
;DECLARACIÓN DE LA ISR DEL TIMER 1 COMO GLOBAL
;..............................................................................
        .global __T1Interrupt    

;******************************************************************************
;CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA
;******************************************************************************
        .section .myconstbuffer, code
;..............................................................................
;ALINEA LA SIGUIENTE PALABRA ALMACENADA EN LA MEMORIA 
;DE PROGRAMA A UNA DIRECCION MULTIPLO DE 2
;..............................................................................
        .palign 2                

ps_coeff:
        .hword   0x0002, 0x0003, 0x0005, 0x000A

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS
;******************************************************************************
         .section .xbss, bss, xmemory

x_input: .space 2*MUESTRAS        ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO Y DE LA MEMORIA DE DATOS
;******************************************************************************

          .section .ybss, bss, ymemory

y_input:  .space 2*MUESTRAS       ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE
;******************************************************************************
;VARIABLES NO INICIALIZADAS LA MEMORIA DE DATOS CERCANA (NEAR), LOCALIZADA
;EN LOS PRIMEROS 8KB DE RAM
;******************************************************************************
          .section .nbss, bss, near

var1:     .space 2               ;LA VARIABLE VAR1 RESERVA 1 WORD DE ESPACIO

;******************************************************************************
;SECCION DE CODIGO EN LA MEMORIA DE PROGRAMA
;******************************************************************************
.text					;INICIO DE LA SECCION DE CODIGO

__reset:
        MOV	#__SP_init, 	W15	;INICIALIZA EL STACK POINTER

        MOV 	#__SPLIM_init, 	W0     	;INICIALIZA EL REGISTRO STACK POINTER LIMIT 
        MOV 	W0, 		SPLIM

        NOP                       	;UN NOP DESPUES DE LA INICIALIZACION DE SPLIM

        CALL 	_WREG_INIT          	;SE LLAMA A LA RUTINA DE INICIALIZACION DE REGISTROS
                                  	;OPCIONALMENTE USAR RCALL EN LUGAR DE CALL
        CALL    INI_PERIFERICOS
CICLO:
	MOV	PORTD,		W0	; W0 = PORTD
        NOP
	AND	#0XF,		W0	; W0 = W0 & 0X000F
	
	
	; ----- COMPARACIONES -------
	
	; COMPARACION W0 = 2
	    CP	W0,	    #2
	    BRA Z,	    DIGITO_2	
	; COMPARACION W0 = 0
	    CP	W0,	    #0
	    BRA Z,	    DIGITO_0
	; COMPARACION W0 = 1
	    CP	W0,	    #1
	    BRA Z,	    DIGITO_1
	; COMPARACION W0 = 3
	    CP	W0,	    #3
	    BRA Z,	    DIGITO_3
	; COMPARACION W0 = 4
	    CP	W0,	    #0
	    BRA Z,	    DIGITO_4	
	; COMPARACION W0 = 5
	    CP	W0,	    #1
	    BRA Z,	    DIGITO_5
	; COMPARACION W0 = 6
	    CP	W0,	    #2
	    BRA Z,	    DIGITO_6
	; COMPARACION W0 = 7
	    CP	W0,	    #3
	    BRA Z,	    DIGITO_7 
	; COMPARACION W0 = 8
	    CP	W0,	    #3
	    BRA Z,	    DIGITO_8 
	; COMPARACION W0 = 9
	    CP	W0,	    #9
	    BRA	Z,	    DIGITO_9
	; COMPARACIÓN W0 ES OTRO NUMERO
	    CP	W0,	    #9
	    BRA	Z,	    ERROR
	        
	ERROR:
	    MOV	    #0X4F,  W0
	    NOP
	    MOV	    W0,	    PORTB
	    NOP
	    GOTO    CICLO
	
	DIGITO_0:
	    MOV	    #DIG_0,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X7E
	    NOP
	    GOTO    CICLO	    
	
	DIGITO_1:
	    MOV	    #DIG_1,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X30
	    NOP
	    GOTO    CICLO	        
	    
	DIGITO_2:
	    MOV	    #DIG_2,	W0	    
	    NOP
	    MOV	    W0,		PORTB	    ;	PORTB =  0X6D
	    NOP
	    GOTO    CICLO
	
	DIGITO_3:
	    MOV	    #DIG_3,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X79
	    NOP
	    GOTO    CICLO	    
	    
	DIGITO_4:
	    MOV	    #DIG_4,	W0	    
	    NOP
	    MOV	    W0,		PORTB	    ;	PORTB =  0X33
	    NOP
	    GOTO    CICLO
	
	DIGITO_5:
	    MOV	    #DIG_5,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X5B
	    NOP
	    GOTO    CICLO	    
	    
	DIGITO_6:
	    MOV	    #DIG_6,	W0	    
	    NOP
	    MOV	    W0,		PORTB	    ;	PORTB =  0X5F
	    NOP
	    GOTO    CICLO
	
	DIGITO_7:
	    MOV	    #DIG_7,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X70
	    NOP
	    GOTO    CICLO	    
	    
	DIGITO_8:
	    MOV	    #DIG_8,	W0	    
	    NOP
	    MOV	    W0,		PORTB	    ;	PORTB =  0X7F
	    NOP
	    GOTO    CICLO
	
	DIGITO_9:
	    MOV	    #DIG_9,	W0
	    NOP
	    MOV	    W0,	PORTB		    ;	PORTB =  0X7B
	    NOP
	    GOTO    CICLO	    
	    	    
	NOP
	GOTO    CICLO     
	
;/**@brief ESTA RUTINA INICIALIZA LOS PERIFERICOS DEL DSC
; * PORTD: 
; * RD0 - ENTRADA, DIPSWITCH 0 
; * RD1 - ENTRADA, DIPSWITCH 1 
; * RD2 - ENTRADA, DIPSWITCH 2 
; * RD3 - ENTRADA, DIPSWITCH 3 
; * PORTB: 
; * RB0 - SALIDA, LED 0 
; * RB1 - SALIDA, LED 1 
; * RB2 - SALIDA, LED 2 
; * RB3 - SALIDA, LED 3 
; */
INI_PERIFERICOS:
	; -------- INICIALIZACIÓN DE PERIFERICOS DE ENTRADA
	CLR	PORTD
	NOP
	CLR	LATD
	NOP
	SETM	TRISD
	NOP
	
	; -------- INICIALIZACIÓN DE PERIFERICOS DE SALIDA
	CLR	PORTB
	NOP
	CLR	LATB
	NOP
	CLR	TRISB
	NOP
	
	; -------- DESACTIVAMOS LA SALIDA DEL CONVERTIDOR ANALOGICO A DIGITAL
	SETM	ADPCFG
	
        RETURN

;/**@brief ESTA RUTINA INICIALIZA LOS REGISTROS Wn A 0X0000
; */
_WREG_INIT:
        CLR 	W0
        MOV 	W0, 				W14
        REPEAT 	#12
        MOV 	W0, 				[++W14]
        CLR 	W14
        RETURN

;/**@brief ISR (INTERRUPT SERVICE ROUTINE) DEL TIMER 1
; * SE USA PUSH.S PARA GUARDAR LOS REGISTROS W0, W1, W2, W3, 
; * C, Z, N Y DC EN LOS REGISTROS SOMBRA
; */
__T1Interrupt:
        PUSH.S 


        BCLR IFS0, #T1IF           ;SE LIMPIA LA BANDERA DE INTERRUPCION DEL TIMER 1

        POP.S

        RETFIE                     ;REGRESO DE LA ISR


.END                               ;TERMINACION DEL CODIGO DE PROGRAMA EN ESTE ARCHIVO

/**@brief: Este programa muestra los bloques de un 
 * programa en C embebido para el DSPIC, los bloques son:
 * BLOQUE 1. OPCIONES DE CONFIGURACION DEL DSC: OSCILADOR, WATCHDOG,
 * BROWN OUT RESET, POWER ON RESET Y CODIGO DE PROTECCION
 * BLOQUE 2. EQUIVALENCIAS Y DECLARACIONES GLOBALES
 * BLOQUE 3. ESPACIOS DE MEMORIA: PROGRAMA, DATOS X, DATOS Y, DATOS NEAR
 * BLOQUE 4. CÓDIGO DE APLICACIÓN
 * @device: DSPIC30F4013
 * @oscillator: FRC, 7.3728MHz
 */

#include "p30F4013.h"

/********************************************************************************/
/* SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 	*/
/* ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR							*/
/* FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 	*/
/* EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA 		*/
/* TRAMPA Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  								*/
/********************************************************************************/
//_FOSC(CSW_FSCM_OFF & FRC); 
//SON DIRECTIVAS DE CONFIGURACIÓN.
#pragma config FOSFPR = FRC             // Oscillator (Internal Fast RC (No change to Primary Osc Mode bits))
#pragma config FCKSMEN = CSW_FSCM_OFF   // Clock Switching and Monitor (Sw Disabled, Mon Disabled)/********************************************************************************/
/* SE DESACTIVA EL WATCHDOG														*/
/********************************************************************************/
//_FWDT(WDT_OFF); 
#pragma config WDT = WDT_OFF            // Watchdog Timer (Disabled)
/********************************************************************************/
/* SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), 					*/	
/* POWER UP TIMER (PWRT) Y EL MASTER CLEAR (MCLR)								*/
/* POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE 	*/	
/* ALIMENTACIÓN ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V			*/
/* BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACIÓN DECAE		*/
/* POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 							*/
/* PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO 		*/
/* AYUDA A ASEGURAR QUE EL VOLTAJE DE ALIMENTACIÓN SE HA ESTABILIZADO (16ms) 	*/
/********************************************************************************/
//_FBORPOR( PBOR_ON & BORV27 & PWRT_16 & MCLR_EN ); 
// FBORPOR
#pragma config FPWRT  = PWRT_16          // POR Timer Value (16ms)
#pragma config BODENV = BORV20           // Brown Out Voltage (2.7V)
#pragma config BOREN  = PBOR_ON          // PBOR Enable (Enabled)
#pragma config MCLRE  = MCLR_EN          // Master Clear Enable (Enabled)
/********************************************************************************/
/*SE DESACTIVA EL CÓDIGO DE PROTECCIÓN											*/
/********************************************************************************/
//_FGS(CODE_PROT_OFF);      
// FGS
#pragma config GWRP = GWRP_OFF          // General Code Segment Write Protect (Disabled)
#pragma config GCP = CODE_PROT_OFF      // General Segment Code Protection (Disabled)

/********************************************************************************/
/* SECCIÓN DE DECLARACIÓN DE CONSTANTES CON DEFINE								*/
/********************************************************************************/
#define EVER 1
#define MUESTRAS 64

/********************************************************************************/
/* DECLARACIONES GLOBALES														*/
/********************************************************************************/
/*DECLARACIÓN DE LA ISR DEL TIMER 1 USANDO __attribute__						*/
/********************************************************************************/
void __attribute__((__interrupt__)) _T1Interrupt( void );   // ESTO ES UNA INTERRUPCION

/********************************************************************************/
/* CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA				*/
/********************************************************************************/
int ps_coeff __attribute__ ((aligned (2), space(prog)));    // DECLARAR UNA ARREGLO EN UNA ZONA ESPECIFICA.
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS			*/
/********************************************************************************/
int x_input[MUESTRAS] __attribute__ ((space(xmemory)));
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS EN EL ESPACIO Y DE LA MEMORIA DE DATOS			*/
/********************************************************************************/
int y_input[MUESTRAS] __attribute__ ((space(ymemory)));
/********************************************************************************/
/* VARIABLES NO INICIALIZADAS LA MEMORIA DE DATOS CERCANA (NEAR), LOCALIZADA	*/
/* EN LOS PRIMEROS 8KB DE RAM													*/
/********************************************************************************/
int var1 __attribute__ ((near));    // int var1;   es lo mismo

// inicio ================================================================
void iniPerifericos( void );
void iniInterrupciones( void );

/* |----- FUNCIONES DECLARADAS EN ENSABLADOR ----| */
void comandoLCD( char );
void datoLCD( char );
void busyFlagLCD( void );
void iniLCD8bits( void );
void imprimeLCD( char * );

// Formato de hora de 24 horas
// iniPerifericos();
// iniInterrupciones();
// iniLCD8bits();

// pseudo codigo --------------------------------------------------------------
// Inicializar PORTB, PORTD como entrada, PORTC como salida

// iniLCD8bits

// TMR1 el unico al cual se le puede conectar un cristal
// Habilitar LPOSCEN = 1 (se encuentar en oscconl)
// escribir 0x46, 0x57 en OSCCONL para remover el candado y usar el osilador externo
// Ensamblador forzoso
// TMR1 = 0
// PR1 = 0x8000 (bit no. 16 en 1)
// T1CON = 0x0002

// CALL candado

// Configuracion del TMR1
// IFS0, #T1If = 0  
// IEC0, #T1IE = 1

// useg = dseg = 0
// umin = dmin = 0
// uhr = dhr = 0

// imprimirLCD("Reloj")

// T1CON, #TON = 1 PONER AL FINAL, inicializa el contador

typedef unsigned char byte;
byte dhr, uhr, dmin, umin, dseg, useg; // variables compartidas con el ensamblador

// assembler definitions
void clk_remove_lock(void);
void clk_start(void);

// variables compartidas con el ensamblador
void init_counters() {
	dhr  = 0;
	uhr  = 0;
	dmin = 0;
	umin = 0;
	dseg = 0;
	useg = 0; 
}

void init_clock() {
	TMR1 = 0;
	PR1 = 0x8000;
	T1CON = 0x0002;

	clk_remove_lock(); // remover el candado que tiene el reloj
}

int main (void){       
	iniPerifericos();
	iniLCD8bits();
	init_clock(); // configura el timer 1 como un reloj externo usando un cristal de 32kHz
	iniInterrupciones(); 

    init_counters(); // inicializa los registros que almacenan los digitos del reloj
	imprimeLCD("Reloj");
	clk_start(); // T1CON, #TON = 1

	while (1) {
		busyFlagLCD(); // Espere hasta que el LCD este listo
		// DD RAM address set as 00 1100 0100 = 0xC4
		// 						    | Renglon                 		
		// Pone el cursor en el renglon inferior, posicion 0x44						  
	  	comandoLCD(0xc4); 
		busyFlagLCD();
		datoLCD(dhr + '0'); busyFlagLCD(); // horas
		datoLCD(uhr + '0'); busyFlagLCD();
		datoLCD(':'); busyFlagLCD();
		datoLCD(dmin + '0'); busyFlagLCD(); // minutos
		datoLCD(umin + '0'); busyFlagLCD();
		datoLCD(':'); busyFlagLCD();
		datoLCD(dseg + '0'); busyFlagLCD(); // segundos
		datoLCD(useg + '0');
	}

    while (1) { Nop(); }
    return 0;
}


/****************************************************************************/
/* DESCRICION:	ESTA RUTINA INICIALIZA LAS INTERRPCIONES    				*/
/* PARAMETROS: NINGUNO                                                      */
/* RETORNO: NINGUNO															*/
/****************************************************************************/
/*void iniInterrupciones( void ){
    // Habilitacion de interrupcion del periférico 1
    // Habilitacion de interrupcion del periférico 2
    // Habilitacion de interrupcion del periférico 3
}*/

/****************************************************************************/
/* DESCRICION:	ESTA RUTINA INICIALIZA LOS PERIFERICOS						*/
/* PARAMETROS: NINGUNO                                                      */
/* RETORNO: NINGUNO															*/
/****************************************************************************/
void iniPerifericos( void ){
	// output
    LATB = 0;           Nop();
    TRISB = 0;          Nop();
    PORTB = 0;          Nop();
    ADPCFG=0xFFFF;      Nop();
    
    LATD = 0;           Nop();
    TRISD = 0;          Nop();
    PORTD = 0;          Nop();

	// input
    LATC = 0;           Nop();
    TRISC = 1;          Nop();
    PORTC = 0;          Nop();
    
    // PORTF = 0;          Nop();
    // LATF = 0;           Nop();
    // TRISF = 0xFFFF;     Nop();
}

/********************************************************************************/
/* DESCRICION:	ISR (INTERRUPT SERVICE ROUTINE) DEL TIMER 1						*/
/* LA RUTINA TIENE QUE SER GLOBAL PARA SER UNA ISR								*/	
/* SE USA PUSH.S PARA GUARDAR LOS REGISTROS W0, W1, W2, W3, C, Z, N Y DC EN LOS */
/* REGISTROS SOMBRA																*/
/********************************************************************************/
void __attribute__((__interrupt__)) _T1Interrupt( void )
{
        IFS0bits.T1IF = 0;    //SE LIMPIA LA BANDERA DE INTERRUPCION DEL TIMER 1                      
}

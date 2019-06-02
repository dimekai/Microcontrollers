
/**@brief: Este programa muestra los bloques de un 
 * programa en C embebido para el DSPIC, los bloques son:
 * BLOQUE 1. OPCIONES DE CONFIGURACION DEL DSC: OSCILADOR, WATCHDOG,
 * BROWN OUT RESET, POWER ON RESET Y CODIGO DE PROTECCION
 * BLOQUE 2. EQUIVALENCIAS Y DECLARACIONES GLOBALES
 * BLOQUE 3. ESPACIOS DE MEMORIA: PROGRAMA, DATOS X, DATOS Y, DATOS NEAR
 * BLOQUE 4. C�DIGO DE APLICACI�N
 * @device: DSPIC30F4013
 * @oscillator: FRC, 7.3728MHz
 */
#include "p30F4013.h"
/********************************************************************************/
/* 						BITS DE CONFIGURACI�N									*/	
/********************************************************************************/
/* SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 	*/
/* ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR							*/
/* FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 	*/
/* EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA 		*/
/* TRAMPA Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  								*/
/********************************************************************************/
//_FOSC(CSW_FSCM_OFF & FRC); 
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
/* ALIMENTACI�N ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V			*/
/* BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACI�N DECAE		*/
/* POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 							*/
/* PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO 		*/
/* AYUDA A ASEGURAR QUE EL VOLTAJE DE ALIMENTACI�N SE HA ESTABILIZADO (16ms) 	*/
/********************************************************************************/
//_FBORPOR( PBOR_ON & BORV27 & PWRT_16 & MCLR_EN ); 
// FBORPOR
#pragma config FPWRT  = PWRT_16          // POR Timer Value (16ms)
#pragma config BODENV = BORV20           // Brown Out Voltage (2.7V)
#pragma config BOREN  = PBOR_ON          // PBOR Enable (Enabled)
#pragma config MCLRE  = MCLR_EN          // Master Clear Enable (Enabled)
/********************************************************************************/
/*SE DESACTIVA EL C�DIGO DE PROTECCI�N											*/
/********************************************************************************/
//_FGS(CODE_PROT_OFF);      
// FGS
#pragma config GWRP = GWRP_OFF          // General Code Segment Write Protect (Disabled)
#pragma config GCP = CODE_PROT_OFF      // General Segment Code Protection (Disabled)

/********************************************************************************/
/* SECCI�N DE DECLARACI�N DE CONSTANTES CON DEFINE								*/
/********************************************************************************/
#define EVER 1
#define MUESTRAS 64

/********************************************************************************/
/* CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA				*/
/********************************************************************************/
int ps_coeff __attribute__ ((aligned (2), space(prog)));
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
int var1 __attribute__ ((near));



// begin -----------------------------------------------------------------------=========
#define nop_after(arg_var, arg_val) arg_var = arg_val; Nop();

//Funciones del LCD
// void retardo15ms();
// void comandoLCD(char);
// void busyFlagLCD();
// void iniLCD();
// void charLCD(char);
// void stringLCD(char *);

// retardos.s
void retardo_1s();

void delay_s(unsigned char seconds) {
    while (seconds--) retardo_1s();
}


/**
 * 
 *                   _________________
 *                  |      DSPIC chido|
 *                  |                 |
 * analog input --->|AN1(4)           |
 *                  |                 |
 *                  |          RD0(34)|---> TMR3 output 256 Hz
 *                  |                 |     ___________
 *                  |         U1RX(26)|<---|Tx   FT-232|  
 *                  |         U1TX(25)|--->|Rx         |
 *                  |                 |    |           |
 *                  |                 |    |           |
 *                   -----------------      ----------- 
 */
void iniPerifericos() {
    // Modificar TRISX para poner entrada o salida
    PORTB = 0; Nop();
    LATB = 0; Nop();
    TRISBbits.TRISB2 = 1; Nop(); // entrada analogica
    
    // ADPCFG = 0xFFFF; Nop(); // En este caso usaremos el ADC
    
    PORTF = 0; Nop();
    LATF = 0; Nop();
    TRISF = 0; Nop();
    TRISFbits.TRISF2 = 1; Nop(); // Recepcion del UART 1
}

// f_{T31F} = f_s = 512 Hz
void iniTMR3() {
    TMR3 = 0;
    PR3 = 3600;
    T3CON = 0;
}

// 115200 Baudios
void iniUART1() {
    U1MODE = 0x0000;
    U1STA = 0x8000; // 0b 1000 0000 0000 0000
    U1BRG = 0;
}

// Info: dsPIC30F_FamilyReferenceManual pag. 465
void iniADC() {
    ADCON1 = 0x0044;    // 0b 0000 0000 0100 0100
    ADCON2 = 0x6000;    // 0b 0110 0000 0000 0000
    ADCON3 = 0x0f02;    // 0b 0000 1111 0000 0010
    ADCHS  = 2;          // canal
    ADPCFG = 0xFFF8;    // AD PORT config
    ADCSSL = 0;         // 
}

void habilitarUART1() {
    U1MODEbits.UARTEN = 1; // Habilitar UART1
    U1STAbits.UTXEN = 1;   // Habilitar transmision del UART1
}

void habilitarADC() {
    ADCON1bits.ADON = 1;
    T3CONbits.TON = 1; // TMR3 controla al ADC
}

void habilitarInterrupciones() {
    // TMR3
    IFS0bits.T3IF = 0;   
    IEC0bits.T3IE = 1;

    // ADC
    IFS0bits.ADIF = 0;
    IEC0bits.ADIE = 1; 

}

int main() {
    iniPerifericos();
    iniTMR3();
    iniUART1();
    iniADC();

    habilitarInterrupciones();    
    habilitarUART1();
    habilitarADC();
    
    while (1) { Nop(); }
    return 0;
}


// Probabilidad condicionada
// informavion mutua
// maximun likilihood estimaion

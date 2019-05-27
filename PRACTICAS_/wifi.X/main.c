
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
/* 						BITS DE CONFIGURACIÓN									*/	
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

// Begin -----------------------------------------------------------------------=============================

// Macros
#define nop_after(variable, value) variable = value; Nop(); 
#define delay_one_sec_after(arg_expression) arg_expression; retardo1s(); 

// delay.s
void retardo15ms();
void retardo1s();

// LCD functions
//void comandoLCD(char);
//void busyFlagLCD();
//void iniLCD();
//void charLCD(char);
//void stringLCD(char *);


void sleep(char t) {
    while (t--) retardo1s();
}

void iniPerifericos() {
    // LCD, opcional
    // PORTB = 0; Nop();
    // LATB = 0; Nop();
    // TRISB = 0; Nop();
    // ADPCFG = 0xFFFF; Nop();
    
    PORTA = 0; Nop();
    LATA = 0; Nop();
    TRISAbits.TRISA11 = 0; Nop(); // EN ESP8266
    
    PORTD = 0; Nop();
    LATD = 0; Nop();
    TRISDbits.TRISD0 = 0; Nop(); // RST ESP8266
    
    // UARTs config
    PORTF = 0; Nop();
    LATF = 0; Nop();
    
    TRISFbits.TRISF2 = 1; Nop(); // Rx UART1
    TRISFbits.TRISF3 = 0; Nop(); // Tx UART1
    
    TRISFbits.TRISF4 = 1; Nop(); // Rx UART2
    TRISFbits.TRISF5 = 0; Nop(); // Tx UART2
}

void iniUARTs() {
    U1MODE = 0x0000;
    U1STA = 0x8000; // 0b 1000 0000 0000 0000
    U1BRG = 0;
    
    U2MODE = 0x0000;
    U2STA = 0x8000; // 0b 1000 0000 0000 0000
    U2BRG = 0;   
}

void iniInterrupciones() {
    IFS0bits.U1RXIF = 0;
    IEC0bits.U1RXIE = 1; 
    
    // reception 
    IFS1bits.U2RXIF = 0; // interrupt flag
    IEC1bits.U2RXIE = 1; // enable reception interrupt from UART2
}

void habilitarUARTs() {
    U1MODEbits.UARTEN = 1; // Habilitar UART1
    U1STAbits.UTXEN = 1;   // Habilitar transmision del UART1
    
    U2MODEbits.UARTEN = 1; // Habilitar UART2
    U2STAbits.UTXEN = 1;   // Habilitar transmision del UART2
}

void iniWifi() {
    PORTAbits.RA11 = 1; // EN
    retardo1s();
    PORTDbits.RD0 = 1; // RST
    retardo1s();
    PORTDbits.RD0 = 0; // RST
    retardo1s();
    PORTDbits.RD0 = 1; // RST
    retardo1s();
}

// Envia comando AT mediante el UART1
void cmdWifi(const char * s) {
    while (*s) {
        //IFS0bits.U1TXIF = 0;
        U1TXREG = *s;
        //while (IFS0bits.U1TXIF == 0) { }
        ++s;
    }
}


// Comandos AT
const char CMD_RST[]      = "AT+RST\r\n"; // Manda reset al modulo wi-fi
const char CMD_CWMODE[]   = "AT+CWMODE=1\r\n"; // Establece el modo wifi, 1: Modo SoftAp
const char CMD_CIPMUX[]   = "AT+CIPMUX=0\r\n"; // Habilita multiples conexiones, 0: single connection
const char CMD_CWJAP[]    = "AT+CWJAP=\"INFINITUM3F97_2.4\",\"t81r1rdEna\"\r\n"; // Join access point
const char CMD_CIFSR[]    = "AT+CIFSR\r\n"; // Obtiene una direccion IP local
const char CMD_CIPSTART[] = "AT+CIPSTART=\"TCP\",\"192.168.1.73\",50007\r\n"; // Se conecta al servidor como cliente
const char CMD_CIPMODE[]  = "AT+CIPMODE=1\r\n";
const char CMD_CIPSEND[]  = "AT+CIPSEND=4\r\n"; // Establece la cantidad de bytes a enviar
const char CMD_STOPPT[]   = "+++";
const char CMD_CIPCLOSE[] = "AT+CIPCLOSE\r\n";

void configWifi() {
    cmdWifi(CMD_RST); retardo1s(); // Reinicie modulo wifi
	cmdWifi(CMD_CWMODE); retardo1s(); // Estableciendo
	cmdWifi(CMD_CIPMUX); retardo1s(); // Estableciendo 
   	cmdWifi(CMD_CWJAP); retardo1s(); // Conectando al punto de acceso
    cmdWifi(CMD_CIFSR); retardo1s(); // Obtenga direccion ip local 
	cmdWifi(CMD_CIPSTART); retardo1s(); // Conectese
	cmdWifi(CMD_CIPMODE); retardo1s(); // ?
	cmdWifi(CMD_CIPSEND); retardo1s(); // Configure cantidad de bytes a enviar
}

void cerrarConexion() {
	cmdWifi(CMD_STOPPT); 
    sleep(5);
	cmdWifi(CMD_CIPCLOSE); 
    sleep(5);
}

int main() {
    iniPerifericos();
	// iniLCD();
    iniUARTs();
    iniInterrupciones();
    habilitarUARTs();
    
    iniWifi();
    configWifi();
    
    U1TXREG = 'H';
    U1TXREG = 'O';
    U1TXREG = 'L';
    U1TXREG = 'A';
    
    retardo1s();
    cerrarConexion();
    
    
    while (1) { Nop(); }
    return 0;
}

// UART1 - ESP8266, interrupcion de recepcion WIFI
//void __attribute__((__interrupt__)) _U1RXInterrupt( void ) {
//    char c = U1RXREG;
//    IFS1bits.U2TXIF = 0;
//    U2TXREG = c;
//    while (IFS1bits.U2TXIF != 1) { }
//    IFS0bits.U1RXIF = 0; //Desactivar interrupcion
//}

// UART2 - PC, interrupcion de recepcion
//void __attribute__((__interrupt__)) _U2RXInterrupt( void ){
//    char c = U2RXREG;
//    IFS0bits.U1TXIF = 0;
//    U1TXREG = c;
//    while (IFS0bits.U1TXIF == 0) { }
//    IFS1bits.U2RXIF = 0; // Desactivar interrupcion
//}



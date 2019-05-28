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
/* DECLARACIONES GLOBALES														*/
/********************************************************************************/
/*DECLARACI�N DE LA ISR DEL TIMER 1 USANDO __attribute__						*/
/********************************************************************************/
void __attribute__((__interrupt__)) _T1Interrupt( void );

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

/**
 * @brief   Incializacion de funciones necesarias
 *          para que la practica puede ejecutarse
 *          de manera adecuada.
 */
void iniPerifericos( void );    // Inicializacion de perifericos
void iniWIFI( void );           // Inicializacion del WiFi
void configWIFI( void );        // Configuracion del WiFi
void cerrarConexion( void );    // Cerramos la conexion para deshabilitar modo continuo
void comandoAT( char * );   // Funcion para mandar comandos AT.

void retardo_1s( void );        // Generacion de retardos de 1 segundo - Esta en retardos.s


void iniUART1( void );             // Inicializamos UART1
void iniUART2( void );             // Inicializamos UART1
void iniInterrupciones( void );    // Establecemos las interrupciones


// Comandos AT
// la funcion comandoAT no soporta const char *
char CMD_RST[]      = "AT+RST\r\n"; // Manda reset al modulo wi-fi
char CMD_CWMODE[]   = "AT+CWMODE=1\r\n"; // Establece el modo wifi, 1: Modo SoftAp
char CMD_CIPMUX[]   = "AT+CIPMUX=0\r\n"; // Habilita multiples conexiones, 0: single connection
char CMD_CWJAP[]    = "AT+CWJAP=\"RED_WIFI\",\"PASSWORD_WIFI\"\r\n"; // Join access point
char CMD_CIFSR[]    = "AT+CIFSR\r\n"; // Obtiene una direccion IP local
char CMD_CIPSTART[] = "AT+CIPSTART=\"TCP\",\"IP_COMPU\",PTO_SERVER\r\n"; // Se conecta al servidor como cliente
char CMD_CIPMODE[]  = "AT+CIPMODE=1\r\n";
char CMD_CIPSEND[]  = "AT+CIPSEND=4\r\n"; // Establece la cantidad de bytes a enviar
char CMD_STOPPT[]   = "+++";
char CMD_CIPCLOSE[] = "AT+CIPCLOSE\r\n";

int main (void){
    iniPerifericos();
    iniUART1(); // Establecemos el BAUDAJE del UART a 11520 
    iniUART2();
    
    // Establecemos las interrupciones
    iniInterrupciones();
    
    // Habilitamos el UART1
    U1MODEbits.UARTEN = 1;      // Habilitar UART1
    U1STAbits.UTXEN = 1;        // Habilitar transmision del UART1
    
    // Habilitamos el UART2 
    U2MODEbits.UARTEN = 1;      // Habilitar UART2
    U2STAbits.UTXEN = 1;        // Habilitar transmision del UART2
    // RXEN habilitada por defecto
    
    iniWIFI();
    configWIFI();
    
    U1TXREG = 'H';
    U1TXREG = 'O';
    U1TXREG = 'L';
    U1TXREG = 'A'; // Cuando se llene el buffer con 4 caracteres se envia ?
    //comandoAT("HOLA");
    
    retardo_1s();
    cerrarConexion();
    
    for (;EVER;) { Nop(); }
    return 0;
}

void delay_s(unsigned char seconds) { 
    while (seconds--) {
        retardo_1s();
    }
}

/**
 * @name            UART1
 * @param           void
 * @return          void
 * @description     Establece el baudaje del UART1 en 115200
 */
void iniUART1( void ) {
    U1MODE = 0x0000;
    U1STA  = 0x8000;    // 0b 1000 0000 0000 0000
    U1BRG  = 0; 
}

/**
 * @name            UART2
 * @param           void
 * @return          void
 * @description     Establece el baudaje del UART2 en 115200
 */
void iniUART2( void ) {
    U2MODE = 0x0000;
    U2STA  = 0x8000;    // 0b 1000 0000 0000 0000
    U2BRG  = 0; 
}

/**
 * @name            iniInterrupciones
 * @param           void
 * @return          void
 * @description     Establece las interrupciones para el programa
 */
void iniInterrupciones( void ) {
    // ESP 8266
    IFS0bits.U1RXIF = 0; // flag 
    IEC0bits.U1RXIE = 1; // enable
    
    // FT232
    //IFS1bits.U2RXIF = 0; // Interrupt Flag
    //IEC1bits.U2RXIE = 1; // Enable reception interrupt from UART2
}

/**
 * @name            iniPerifericos
 * @param           void
 * @return          void
 * @description     Se inicializan los perifericos que se van a 
 *                  usar durante la pr�ctica, utilizando ambos UARTs
 * 
 *          -------------------------
 *          |         FT232         |
 *          |                       |
 *          |    Tx    Rx    GND    |
 *          -------------------------
 *               |     ^      |
 *               |     |      --
 *               |     |      ---
 *           RF4 |     |RF5      
 *               V     |
 *          -------------------------
 *          |   Rx     Tx           |
 *          |                       |
 *          |       UART2           |
 *          -------------------------
 *          |       UART1           |
 *          |                       |
 *          |              Rx   Tx  |
 *          ------------------------- 
 *         RD0|  RA11|  RF2^  RF3|      
 *            |      |     |     |      
 *            |      |     |     |      
 *            |      |     |     |
 *            V      V     |     v
 *         --------------------------
 *         | RST    EN    Tx     Rx |
 *         |                        |
 *         |        ESP8266         |
 *         |         WiFi           |
 *         --------------------------
 * 
 */
void iniPerifericos( void ) {
    PORTB = 0;                  Nop();
    LATB = 0;                   Nop();
    TRISB = 0;                  Nop();
    ADPCFG = 0xFFFF;            Nop();
    
    PORTA = 0;                  Nop();
    LATA = 0;                   Nop();
    TRISAbits.TRISA11 = 0;      Nop(); // EN ESP8266
    
    PORTD = 0;                  Nop();
    LATD = 0;                   Nop();
    TRISDbits.TRISD0 = 0;       Nop(); // RST ESP8266
    
    // Configuracion de UARTs
    PORTF = 0;                  Nop();
    LATF = 0;                   Nop();
    
    TRISFbits.TRISF2 = 1;       Nop(); // Rx UART1
    TRISFbits.TRISF3 = 0;       Nop(); // Tx UART1
    
    TRISFbits.TRISF4 = 1;       Nop(); // Rx UART2
    TRISFbits.TRISF5 = 0;       Nop(); // Tx UART2
}

/**
 * @name            iniWIFI
 * @param           void
 * @return          void
 * @description     Inicializar el wifi 
 */
void iniWIFI(void){
    PORTAbits.RA11 = 1;      // EN = 1
    Nop();
    retardo_1s();
  
    PORTDbits.RD0 = 1;      // RST = 1  
    Nop();
    retardo_1s();
    
    PORTDbits.RD0 = 0;      // RST = 0
    Nop();
    retardo_1s();

    PORTDbits.RD0 = 1;      // RST = 1
    Nop();
    retardo_1s();  
}

void configWIFI(void) {
    comandoAT(CMD_RST); // Reiniciar modulo WiFi
    delay_s(5);
    comandoAT(CMD_CWMODE); // Estableciendo CWMODE = 1
    delay_s(5);
    comandoAT(CMD_CIPMUX); // Establecienod CIPMUX = 0
    delay_s(5);
    comandoAT(CMD_CWJAP); // Conectando al punto de acceso
    delay_s(5);
    comandoAT(CMD_CIFSR); // Obtener IP Local
    delay_s(5);
    comandoAT(CMD_CIPSTART); // Conectandose
    delay_s(5);
    comandoAT(CMD_CIPMODE); // Debemos dehabilitar el modo continuo
    delay_s(5);
    comandoAT(CMD_CIPSEND); // Configuracion de cantidad de bytes
    delay_s(5);
}

void cerrarConexion( void ) {
    comandoAT(CMD_STOPPT);     // Reiniciar modulo WiFi
    delay_s(5);
    comandoAT(CMD_CIPCLOSE);  // Estableciendo CWMODE = 1
    delay_s(5);
}
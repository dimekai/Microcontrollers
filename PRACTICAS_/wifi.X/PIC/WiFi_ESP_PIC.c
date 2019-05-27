/*
* Example for WiFi ESP click
*
* Date         Mar 2017
* Author       Stefan Popovic
* Copyright    GNU Public License v2
*
* Test configuration PIC :
*  MCU           :        P18F45K22
*  Dev. Board    :        EasyPIC PRO v7
*  SW            :        mikroC PRO for PIC v7.0.0
*  NOTES:
     - This example demonstrates the functionality of WiFi ESP as server.
       When button RA1 is toggled, LED RA0 is changing state and
       logging event on server
     - Connect EasyLCD and turn on the BACKLIGHT
     - Change SSID and password to match your WiFi
     - Turn ON the PORTA/E LEDs at SW3.1
     - Put button jumper (J17) into VCC position and pull-down PORTA1
 ******************************************************************************/
#include <stdbool.h>

// module connections
sbit CH_PD  at LATE0_bit;
sbit GPIO15 at LATE1_bit;
sbit CH_PD_Direction  at TRISE0_bit;
sbit GPIO15_Direction at TRISE1_bit;

// Lcd module connections
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;

sbit LCD_RS at LATB4_bit;
sbit LCD_EN at LATB5_bit;
sbit LCD_D4 at LATB0_bit;
sbit LCD_D5 at LATB1_bit;
sbit LCD_D6 at LATB2_bit;
sbit LCD_D7 at LATB3_bit;
// End Lcd module connections

extern void WiFI_Configure();

// Responses to parse
const OK = 1;
const ERROR = 2;
const NO_CHANGE = 3;
const FAIL = 4;
const READY = 5;
const SEND = 6;

char ip_address[40];
unsigned short i;
unsigned short DataReady;
unsigned int oldstate;
unsigned int length;

char txt_val[ 10 ];
char state;
char response_rcvd;
char responseID, response = 0;
char is_receiving_data = 0;
char LED_switching = 0;
int cntr = 0;

// Change following information to match your network settings
unsigned char *SSID = "MikroE Public";
unsigned char *password = "mikroe.guest";
char txt1[] = "<a href=\"https://www.mikroe.com/\">MikroElektronika</a>";
char txt2[] = "<h1 style=\"color:red;\">WiFi ESP click board</h1>";
char txt3[] = "<h1>Server example</h1";
char txt4[] = "<p> LED RA0 is ";

bool A0_change = false;

char txt_state_A0[9] = "OFF</p>";

char data_[ 500 ] = { 0 };

// Get response
char Get_Response()
{
  if (response_rcvd)
  {
    response_rcvd = 0;
    return responseID;
  }
  else
    return 0;
}

void WiFi_Init()
{
  CH_PD = 1;
  delay_ms(500);                // Perform reset procedure
  GPIO15 = 0;
  delay_ms(500);
  GPIO15 = 1;
  Delay_ms(5000);               // wait five seconds on power-on
}

void sending_data( void )
{
   UART1_Write_Text("AT+CIPSEND=0");
   UART1_Write_Text(",");
   UART1_Write_Text( txt_val );
   UART1_Write(0x0D);
   UART1_Write(0x0A);
   Delay_ms(100);
   UART1_Write_Text( data_ );

   Delay_ms( 200 );

   UART1_Write_Text("AT+CIPSEND=1");
   UART1_Write_Text(",");
   UART1_Write_Text( txt_val );
   UART1_Write(0x0D);
   UART1_Write(0x0A);
   Delay_ms(100);
   UART1_Write_Text( data_ );

   Delay_ms( 200 );

   UART1_Write_Text("AT+CIPSEND=2");
   UART1_Write_Text(",");
   UART1_Write_Text( txt_val );
   UART1_Write(0x0D);
   UART1_Write(0x0A);
   Delay_ms(100);
   UART1_Write_Text( data_ );

   Delay_ms( 200 );

   UART1_Write_Text("AT+CIPSEND=3");
   UART1_Write_Text(",");
   UART1_Write_Text( txt_val );
   UART1_Write(0x0D);
   UART1_Write(0x0A);
   Delay_ms(100);
   UART1_Write_Text( data_ );
}

void WiFi_Send()
{
    if( !LED_switching ) {

    length += strlen( txt1 );
    length += strlen( txt2 );
    length += strlen( txt4 );
    length += strlen( txt_state_A0 );

    IntToStr( length, txt_val );
    Ltrim( txt_val );

    strcat( data_, txt1 );
    strcat( data_, txt2 );
    strcat( data_, txt4 );
    strcat( data_, txt_state_A0 );
    Rtrim( data_ );

    sending_data();
    }
    else
    {
       if ( A0_change )
       {
         A0_change = false;
         length += strlen( txt4 );
         length += strlen( txt_state_A0 );
         strcat( data_, txt4 );
         strcat( data_, txt_state_A0 );
       }

       IntToStr( length, txt_val );
       Ltrim( txt_val );
       Rtrim( data_ );

       sending_data();
    }

    strcpy(data_, "");
    length = 0;

    Delay_ms(100);
}

void main() {

  length = 0;

  ANSELA = 0;
  ANSELB = 0;
  ANSELC = 0;
  ANSELD = 0;
  ANSELE = 0;
  TRISA1_bit = 1;
  TRISA0_bit = 0;
  
  CH_PD_Direction = 0;          // Set Power down pin as output
  GPIO15_Direction = 0;         // Set GPIO15 pin as output
  

  // Initialize variables
  state = 0;
  response_rcvd = 0;
  responseID = 0;
  response = 0;
  i = 0;

  Lcd_Init();                   // Lcd Init
  Lcd_Cmd(_LCD_CLEAR);          // Clear display
  Lcd_Cmd(_LCD_CURSOR_OFF);     // Cursor off

  UART1_init(115200);             // Initialize UART1 module

  RCIE_bit = 1;                 // Enable UART RX interrupt
  PEIE_bit = 1;                 // Enable Peripheral interrupt
  GIE_bit  = 1;                 // Enable Global interrupt

  // Receive data
  Lcd_Cmd(_LCD_CLEAR);
  Lcd_Out(1,2,"WiFi ESP click");
  Lcd_Out(2,3,"Demo Example");

  // Initialize WiFI module
  WiFi_Init();

  //Setting WiFi Mode - station mode
  WiFI_Configure();

  state = 100;
  i = 0;

  Lcd_Out(1, 1,"Connect to STAIP");
  // Waiting for multiple connections to Server STAIP
  Delay_ms(20000);

  // Sending Initial data to server
  WiFi_Send();

  Lcd_Out(1, 1,"Press Button RA1");

  LED_switching = 1;

    while( 1 )
    {
      // detect logical one on PA4 pin
      if (Button(&PORTA, 1, 1, 1))
      {
       oldstate = 1;
      }
      // detect logical one-to-zero transition on PA4 pin
      if (oldstate && Button(&PORTA, 1, 1, 0))
      {
        if ( !strcmp(txt_state_A0, "OFF</p>" ))
        {
          strncpy( txt_state_A0, "ON </p>", 8 );
          LATA0_bit = 1;
        }
        else
        {
          strncpy( txt_state_A0, "OFF</p>", 8 );
          LATA0_bit = 0;
        }
        oldstate = 0;
        A0_change = true;
        WiFi_Send();
      }
    }
}

// Uart Rx interrupt handler
void interrupt(){
  if (RCIF_bit == 1) {                          // Do we have uart rx interrupt request?
    char tmp = UART1_Read();                         // Get received byte
    // Process reception through state machine
    switch (state) {
      case 0: {
                response = 0;                   // Clear response
                if (tmp == 'O')
                  state = 1;
                if (tmp == 'E')
                  state = 10;
                if (tmp == 'n')
                  state = 20;
                if (tmp == 'F')
                  state = 30;
                if (tmp == 'A')
                  state = 40;
                if (tmp == '+')
                  state = 54;

                if (tmp == 'r')
                  state = 50;

                if (tmp == '>')
                {
                  state = 54;
                }
                break;
      }

      case 1: {
                if (tmp == 'K'){
                  response = OK;                // OK
                  state = 2;
                }
                else
                  state = 0;
                break;
      }

      case 10: {
                if (tmp == 'R')
                  state = 11;
                else
                  state = 0;
                break;
      }

      case 11: {
                if (tmp == 'R')
                  state = 12;
                else
                  state = 0;
                break;
      }

      case 12: {
                if (tmp == 'O')
                  state = 13;
                else
                  state = 0;
                break;
      }

      case 13: {
                if (tmp == 'R') {
                  response = ERROR;             // ERROR
                  state = 2;
                }
                else
                  state = 0;
                break;
      }

      case 20: {
                if (tmp == 'o')
                  state = 21;
                else
                  state = 0;
                break;
      }

      case 21: {
                if (tmp == ' ')
                  state = 22;
                else
                  state = 0;
                break;
      }

      case 22: {
                if (tmp == 'c')
                  state = 23;
                else
                  state = 0;
                break;
      }

      case 23: {
                if (tmp == 'h')
                  state = 24;
                else
                  state = 0;
                break;
      }

      case 24: {
                if (tmp == 'a')
                  state = 25;
                else
                  state = 0;
                break;
      }

      case 25: {
                if (tmp == 'n')
                  state = 26;
                else
                  state = 0;
                break;
      }

      case 26: {
                if (tmp == 'g')
                  state = 27;
                else
                  state = 0;
                break;
      }

      case 27: {
                if (tmp == 'e'){
                  response = NO_CHANGE;         // NO CHANGE
                  state = 2;
                }
                else
                  state = 0;
                break;
      }

      case 30: {
                if (tmp == 'A')
                  state = 31;
                else
                  state = 0;
                break;
      }

      case 31: {
                if (tmp == 'I')
                  state = 32;
                else
                  state = 0;
                break;
      }

      case 32: {
                if (tmp == 'L') {
                  response = FAIL;              // FAIL
                  state = 2;
                }
                else
                  state = 0;
                break;
      }

      case 40: {
                if (tmp == 'T')
                  state = 41;
                else
                  state = 0;
                break;
      }

      case 41: {
                if (tmp == '+')
                  state = 42;
                else
                  state = 0;
                break;
      }

      case 42: {
                if (tmp == 'C')
                  state = 43;
                else
                  state = 0;
                break;
      }

      case 43: {
                if (tmp == 'I')
                  state = 44;
                else
                  state = 0;
                break;
      }

      case 44: {
                if (tmp == 'F')
                  state = 45;
                else
                  state = 0;
                break;
      }

      case 45: {
                if (tmp == 'S')
                  state = 46;
                else
                  state = 0;
                break;
      }

      case 46: {
                if (tmp == 'R')
                  state = 47;
                else
                  state = 0;
                break;
      }

      case 47: {
                if (tmp == 10) {
                  state = 48;
                  i = 0;
                }
                else if (tmp == 13){

                }
                else
                  state = 0;
                break;
      }

      case 48: {
                if (tmp == 13){
                  state = 3;
                  response = OK;
                }
                else {
                  ip_address[i] = tmp;              // get IP address
                  i++;
                }
                break;
      }

      case 50: {
                if (tmp == 'e')
                  state = 51;
                else
                  state = 0;
                break;
      }

      case 51: {
                if (tmp == 'a')
                  state = 52;
                else
                  state = 0;
                break;
      }

      case 52: {
                if (tmp == 'd')
                  state = 53;
                else
                  state = 0;
                break;
      }

      case 53: {
                if (tmp == 'y') {
                  response = READY;              // READY
                  state = 2;
                }
                else
                  state = 0;
                break;
      }

       case 54: {
                state = 0;
                response = SEND;
                response_rcvd = 1;
                responseID = response;
                break;
      }

      case 2: {
                if (tmp == 13)
                  state = 3;
                else
                  state = 0;
                break;
      }

      case 3: {
                if (tmp == 10){
                  response_rcvd = 1;
                  responseID = response;
                }
                state = 0;
                break;
      }

      default: {
                state = 0;
                break;
      }
    }
  }
  RCIF_bit = 0;                                     // Disable UART RX interrupt
}
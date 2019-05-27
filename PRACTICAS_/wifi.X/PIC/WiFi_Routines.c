//  Configure WiFI ESP Click module responses to parse
extern const OK;
extern const NO_CHANGE;
extern const READY;
extern char Get_Response();

extern unsigned char *SSID;
extern unsigned char *password;
extern unsigned char *port;
extern unsigned char ip_address[40];

void WiFI_Configure() {

  //Resetting WiFi module
  Lcd_Out(2, 1,"Resetting Module");
  do {
    UART1_Write_Text("AT+RST");
    UART1_Write(0x0D);
    UART1_Write(0x0A);
    Delay_ms(2000);
  } while(Get_Response() != READY);
  Delay_ms(1000);

  // Setting WiFi Mode - station mode
  Lcd_Out(2, 1,"Station mode....");
  do {
    UART1_Write_Text("AT+CWMODE=1");
    UART1_Write(0x0D);
    UART1_Write(0x0A);
    Delay_ms(2000);
  } while(Get_Response() != OK);
  Delay_ms(2000);

  //Enable multIPle connection
  Lcd_Out(2, 1,"MultipleConn EN");
  do {
    UART1_Write_Text("AT+CIPMUX=1");
    UART1_Write(0x0D);
    UART1_Write(0x0A);
    Delay_ms(2000);
  } while(Get_Response() != OK);
  Delay_ms(2000);

  do {
     // AT+CWJAP="SSID","pasword" <CR><LF>
     Lcd_Out(2, 1,"Joining AP......");
     UART1_Write_Text("AT+CWJAP=");
     UART1_Write('"');
     UART1_Write_Text(SSID);
     UART1_Write('"');
     UART1_Write(',');
     UART1_Write('"');
     UART1_Write_Text(password);
     UART1_Write('"');
     UART1_Write(0x0D);
     UART1_Write(0x0A);
     Delay_ms(1000);
  } while(Get_Response() != OK);
  Delay_ms(1000);

  do {
     UART1_Write_Text("AT+CWLAP");
     UART1_Write(0x0D);
     UART1_Write(0x0A);
     Delay_ms(1000);
  } while(Get_Response() != OK);
  Delay_ms(1000);

  // Checking WiFi connection status
  do {
    UART1_Write_Text("AT+CIPSTATUS");
    UART1_Write(0x0D);
    UART1_Write(0x0A);
    Delay_ms(1000);
  } while(Get_Response() != OK);
  Delay_ms(1000);

  do {
    Lcd_Out(2, 1,"Setting Server..");
    //AT+CIPSERVER=<mode>,<port><CR><LF>
    UART1_Write_Text("AT+CIPSERVER=1,80");
    UART1_Write(0x0D);
    UART1_Write(0x0A);
    Delay_ms(1000);
  } while(Get_Response() != OK);
  Delay_ms(1000);

  UART1_Write_Text("AT+CIPSTO?");
  UART1_Write(0x0D);
  UART1_Write(0x0A);
  Delay_ms(1000);

  memset(ip_address, 0, 16);

  Lcd_Out(1, 1,"Getting STAIP");
  UART1_Write_Text("AT+CIFSR");
  UART1_Write(0x0D);
  UART1_Write(0x0A);
  Delay_ms(1000);
  while(Get_Response() != OK);
  Delay_ms(1000);
  
  Lcd_Out(2, 1,"                ");
  Lcd_Out(2, 1, ip_address + 13);
}
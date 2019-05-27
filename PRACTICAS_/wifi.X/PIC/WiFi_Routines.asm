
_WiFI_Configure:

	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
L_WiFI_Configure0:
	MOVLW       ?lstr2_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr2_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       82
	MOVWF       R11, 0
	MOVLW       43
	MOVWF       R12, 0
	MOVLW       0
	MOVWF       R13, 0
L_WiFI_Configure3:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure3
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure3
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure3
	NOP
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _READY+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure41
	MOVLW       _READY
	XORWF       R0, 0 
L__WiFI_Configure41:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure4:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure4
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure4
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure4
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr3_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr3_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
L_WiFI_Configure5:
	MOVLW       ?lstr4_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr4_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       82
	MOVWF       R11, 0
	MOVLW       43
	MOVWF       R12, 0
	MOVLW       0
	MOVWF       R13, 0
L_WiFI_Configure8:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure8
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure8
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure8
	NOP
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure42
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure42:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure5
	MOVLW       82
	MOVWF       R11, 0
	MOVLW       43
	MOVWF       R12, 0
	MOVLW       0
	MOVWF       R13, 0
L_WiFI_Configure9:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure9
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure9
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure9
	NOP
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr5_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr5_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
L_WiFI_Configure10:
	MOVLW       ?lstr6_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr6_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       82
	MOVWF       R11, 0
	MOVLW       43
	MOVWF       R12, 0
	MOVLW       0
	MOVWF       R13, 0
L_WiFI_Configure13:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure13
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure13
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure13
	NOP
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure43
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure43:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure10
	MOVLW       82
	MOVWF       R11, 0
	MOVLW       43
	MOVWF       R12, 0
	MOVLW       0
	MOVWF       R13, 0
L_WiFI_Configure14:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure14
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure14
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure14
	NOP
L_WiFI_Configure15:
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr7_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr7_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
	MOVLW       ?lstr8_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr8_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       34
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _SSID+0, 0 
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVF        _SSID+1, 0 
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       34
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       44
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       34
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _password+0, 0 
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVF        _password+1, 0 
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       34
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure18:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure18
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure18
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure18
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure44
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure44:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure15
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure19:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure19
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure19
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure19
L_WiFI_Configure20:
	MOVLW       ?lstr9_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr9_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure23:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure23
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure23
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure23
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure45
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure45:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure20
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure24:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure24
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure24
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure24
L_WiFI_Configure25:
	MOVLW       ?lstr10_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr10_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure28:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure28
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure28
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure28
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure46
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure46:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure25
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure29:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure29
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure29
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure29
L_WiFI_Configure30:
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr11_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr11_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
	MOVLW       ?lstr12_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr12_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure33:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure33
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure33
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure33
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure47
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure47:
	BTFSS       STATUS+0, 2 
	GOTO        L_WiFI_Configure30
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure34:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure34
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure34
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure34
	MOVLW       ?lstr13_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr13_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure35:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure35
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure35
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure35
	MOVLW       _ip_address+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_ip_address+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       16
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr14_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr14_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
	MOVLW       ?lstr15_WiFi_Routines+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr15_WiFi_Routines+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
	MOVLW       13
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       10
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure36:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure36
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure36
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure36
L_WiFI_Configure37:
	CALL        _Get_Response+0, 0
	MOVLW       0
	XORLW       _OK+1
	BTFSS       STATUS+0, 2 
	GOTO        L__WiFI_Configure48
	MOVLW       _OK
	XORWF       R0, 0 
L__WiFI_Configure48:
	BTFSC       STATUS+0, 2 
	GOTO        L_WiFI_Configure38
	GOTO        L_WiFI_Configure37
L_WiFI_Configure38:
	MOVLW       41
	MOVWF       R11, 0
	MOVLW       150
	MOVWF       R12, 0
	MOVLW       127
	MOVWF       R13, 0
L_WiFI_Configure39:
	DECFSZ      R13, 1, 1
	BRA         L_WiFI_Configure39
	DECFSZ      R12, 1, 1
	BRA         L_WiFI_Configure39
	DECFSZ      R11, 1, 1
	BRA         L_WiFI_Configure39
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr16_WiFi_Routines+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr16_WiFi_Routines+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _ip_address+13
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_ip_address+13)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
L_end_WiFI_Configure:
	RETURN      0
; end of _WiFI_Configure


_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Techometer_Src.c,52 :: 		void interrupt(){
;Techometer_Src.c,54 :: 		if (INTF_bit){
	BTFSS      INTF_bit+0, BitPos(INTF_bit+0)
	GOTO       L_interrupt0
;Techometer_Src.c,55 :: 		pulseCount++;
	MOVF       _pulseCount+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _pulseCount+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _pulseCount+0
	MOVF       R0+1, 0
	MOVWF      _pulseCount+1
;Techometer_Src.c,56 :: 		revoCount++;
	MOVF       _revoCount+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _revoCount+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _revoCount+0
	MOVF       R0+1, 0
	MOVWF      _revoCount+1
;Techometer_Src.c,57 :: 		INTF_bit = 0;
	BCF        INTF_bit+0, BitPos(INTF_bit+0)
;Techometer_Src.c,58 :: 		}
L_interrupt0:
;Techometer_Src.c,61 :: 		if (TMR1IF_bit) {
	BTFSS      TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
	GOTO       L_interrupt1
;Techometer_Src.c,62 :: 		timer_count++;
	INCF       _timer_count+0, 1
	BTFSC      STATUS+0, 2
	INCF       _timer_count+1, 1
;Techometer_Src.c,63 :: 		TMR1IF_bit = 0;
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;Techometer_Src.c,64 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;Techometer_Src.c,65 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;Techometer_Src.c,67 :: 		if (timer_count >= 4) {
	MOVLW      0
	SUBWF      _timer_count+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt37
	MOVLW      4
	SUBWF      _timer_count+0, 0
L__interrupt37:
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt2
;Techometer_Src.c,68 :: 		update_rpm_flag = 1;
	BSF        _update_rpm_flag+0, BitPos(_update_rpm_flag+0)
;Techometer_Src.c,69 :: 		}
L_interrupt2:
;Techometer_Src.c,70 :: 		}
L_interrupt1:
;Techometer_Src.c,71 :: 		}
L_end_interrupt:
L__interrupt36:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_Init_LCD:

;Techometer_Src.c,74 :: 		void Init_LCD() {
;Techometer_Src.c,75 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;Techometer_Src.c,76 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Techometer_Src.c,77 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Techometer_Src.c,78 :: 		}
L_end_Init_LCD:
	RETURN
; end of _Init_LCD

_LCD_Display_RPM:

;Techometer_Src.c,81 :: 		void LCD_Display_RPM(unsigned int rpm) {
;Techometer_Src.c,82 :: 		IntToStr(rpm, RPM_str);
	MOVF       FARG_LCD_Display_RPM_rpm+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       FARG_LCD_Display_RPM_rpm+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _RPM_str+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;Techometer_Src.c,83 :: 		Lcd_Out(1, 1, "RPM: ");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_Techometer_Src+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Techometer_Src.c,84 :: 		Lcd_Out(1, 6, RPM_str);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _RPM_str+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Techometer_Src.c,85 :: 		}
L_end_LCD_Display_RPM:
	RETURN
; end of _LCD_Display_RPM

_LCD_Display_Revo:

;Techometer_Src.c,88 :: 		void LCD_Display_Revo(unsigned int revoCount) {
;Techometer_Src.c,89 :: 		IntToStr((revoCount/20), REVO_str);
	MOVLW      20
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FARG_LCD_Display_Revo_revoCount+0, 0
	MOVWF      R0+0
	MOVF       FARG_LCD_Display_Revo_revoCount+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _REVO_str+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;Techometer_Src.c,90 :: 		Lcd_Out(2, 1, "REVO: ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_Techometer_Src+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Techometer_Src.c,91 :: 		Lcd_Out(2, 6, REVO_str);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _REVO_str+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Techometer_Src.c,92 :: 		}
L_end_LCD_Display_Revo:
	RETURN
; end of _LCD_Display_Revo

_UART_Display_Data:

;Techometer_Src.c,95 :: 		void UART_Display_Data(unsigned int rpm, unsigned int revoCount, unsigned int PWM_Cycle) {
;Techometer_Src.c,96 :: 		IntToStr(rpm, RPM_str);
	MOVF       FARG_UART_Display_Data_rpm+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       FARG_UART_Display_Data_rpm+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _RPM_str+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;Techometer_Src.c,97 :: 		IntToStr((revoCount/20), REVO_str);
	MOVLW      20
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FARG_UART_Display_Data_revoCount+0, 0
	MOVWF      R0+0
	MOVF       FARG_UART_Display_Data_revoCount+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _REVO_str+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;Techometer_Src.c,98 :: 		IntToStr(((PWM_Cycle*100)/255), Duty_str);
	MOVF       FARG_UART_Display_Data_PWM_Cycle+0, 0
	MOVWF      R0+0
	MOVF       FARG_UART_Display_Data_PWM_Cycle+1, 0
	MOVWF      R0+1
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _Duty_str+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;Techometer_Src.c,100 :: 		UART1_Write_Text(RPM_str);
	MOVLW      _RPM_str+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,101 :: 		UART1_Write_Text("|");
	MOVLW      ?lstr3_Techometer_Src+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,103 :: 		UART1_Write_Text(REVO_str);
	MOVLW      _REVO_str+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,104 :: 		UART1_Write_Text("|");
	MOVLW      ?lstr4_Techometer_Src+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,106 :: 		UART1_Write_Text(Duty_str);
	MOVLW      _Duty_str+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,107 :: 		UART1_Write_Text("%");
	MOVLW      ?lstr5_Techometer_Src+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,108 :: 		UART1_Write_Text("|");
	MOVLW      ?lstr6_Techometer_Src+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,109 :: 		UART1_Write_Text("\n");
	MOVLW      ?lstr7_Techometer_Src+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;Techometer_Src.c,110 :: 		}
L_end_UART_Display_Data:
	RETURN
; end of _UART_Display_Data

_main:

;Techometer_Src.c,113 :: 		void main() {
;Techometer_Src.c,115 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;Techometer_Src.c,116 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;Techometer_Src.c,117 :: 		TRISD.F2 = 1;  // Input: Button for motor toggle
	BSF        TRISD+0, 2
;Techometer_Src.c,118 :: 		TRISD.F3 = 1;  // Input: Button to reset REVO count
	BSF        TRISD+0, 3
;Techometer_Src.c,119 :: 		TRISB.F0 = 1;  // Input: RPM sensor
	BSF        TRISB+0, 0
;Techometer_Src.c,122 :: 		INTCON.GIE = 1;        // interrupt confegration -> global interrupt enable
	BSF        INTCON+0, 7
;Techometer_Src.c,123 :: 		INTCON.PEIE = 1;       // interrupt confegration -> peripheral interrupt enable
	BSF        INTCON+0, 6
;Techometer_Src.c,124 :: 		INTCON.INTE = 1;       // interrupt confegration -> external interrupt enable
	BSF        INTCON+0, 4
;Techometer_Src.c,125 :: 		INTCON.INTF = 0;       // clear external interrupt flag
	BCF        INTCON+0, 1
;Techometer_Src.c,126 :: 		OPTION_REG.INTEDG = 1; // external interrupt on rising edge
	BSF        OPTION_REG+0, 6
;Techometer_Src.c,129 :: 		T1CON = 0b00110001;
	MOVLW      49
	MOVWF      T1CON+0
;Techometer_Src.c,130 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;Techometer_Src.c,131 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;Techometer_Src.c,132 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;Techometer_Src.c,135 :: 		Init_LCD();
	CALL       _Init_LCD+0
;Techometer_Src.c,136 :: 		ADC_Init();
	CALL       _ADC_Init+0
;Techometer_Src.c,139 :: 		PWM1_Init(1000);
	BSF        T2CON+0, 0
	BSF        T2CON+0, 1
	MOVLW      124
	MOVWF      PR2+0
	CALL       _PWM1_Init+0
;Techometer_Src.c,140 :: 		PWM1_Start();
	CALL       _PWM1_Start+0
;Techometer_Src.c,143 :: 		UART1_Init(9600);
	MOVLW      51
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;Techometer_Src.c,144 :: 		delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main3:
	DECFSZ     R13+0, 1
	GOTO       L_main3
	DECFSZ     R12+0, 1
	GOTO       L_main3
	DECFSZ     R11+0, 1
	GOTO       L_main3
	NOP
;Techometer_Src.c,146 :: 		UART_PWM_Enable = 0; // Default: PWM from potentiometer
	BCF        _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
;Techometer_Src.c,148 :: 		MOTOR_IN1 = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;Techometer_Src.c,149 :: 		MOTOR_IN2 = 0;
	BCF        RD0_bit+0, BitPos(RD0_bit+0)
;Techometer_Src.c,151 :: 		while (1) {
L_main4:
;Techometer_Src.c,153 :: 		if (!UART_PWM_Enable) {
	BTFSC      _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
	GOTO       L_main6
;Techometer_Src.c,154 :: 		ADC_Value = ADC_Read(0);
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	CALL       _word2double+0
	MOVF       R0+0, 0
	MOVWF      _ADC_Value+0
	MOVF       R0+1, 0
	MOVWF      _ADC_Value+1
	MOVF       R0+2, 0
	MOVWF      _ADC_Value+2
	MOVF       R0+3, 0
	MOVWF      _ADC_Value+3
;Techometer_Src.c,155 :: 		PWM_Value = (ADC_Value * 255) / 1023;
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      127
	MOVWF      R4+2
	MOVLW      134
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      192
	MOVWF      R4+1
	MOVLW      127
	MOVWF      R4+2
	MOVLW      136
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	CALL       _double2word+0
	MOVF       R0+0, 0
	MOVWF      _PWM_Value+0
	MOVF       R0+1, 0
	MOVWF      _PWM_Value+1
;Techometer_Src.c,156 :: 		PWM1_Set_Duty(PWM_Value);
	MOVF       R0+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Techometer_Src.c,157 :: 		}
L_main6:
;Techometer_Src.c,160 :: 		currentState = PORTD.F2;
	MOVLW      0
	BTFSC      PORTD+0, 2
	MOVLW      1
	MOVWF      _currentState+0
;Techometer_Src.c,161 :: 		if (currentState == 1 && prevState == 0) {
	MOVF       _currentState+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main9
	MOVF       _prevState+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main9
L__main34:
;Techometer_Src.c,162 :: 		if (PORTD.F2 == 1) {
	BTFSS      PORTD+0, 2
	GOTO       L_main10
;Techometer_Src.c,163 :: 		motorState = !motorState;
	MOVLW
	XORWF      _motorState+0, 1
;Techometer_Src.c,164 :: 		if (motorState) {
	BTFSS      _motorState+0, BitPos(_motorState+0)
	GOTO       L_main11
;Techometer_Src.c,165 :: 		MOTOR_IN1 = 1;
	BSF        RC3_bit+0, BitPos(RC3_bit+0)
;Techometer_Src.c,166 :: 		MOTOR_IN2 = 0;
	BCF        RD0_bit+0, BitPos(RD0_bit+0)
;Techometer_Src.c,167 :: 		}
	GOTO       L_main12
L_main11:
;Techometer_Src.c,169 :: 		MOTOR_IN1 = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;Techometer_Src.c,170 :: 		MOTOR_IN2 = 0;
	BCF        RD0_bit+0, BitPos(RD0_bit+0)
;Techometer_Src.c,171 :: 		}
L_main12:
;Techometer_Src.c,172 :: 		}
L_main10:
;Techometer_Src.c,173 :: 		}
L_main9:
;Techometer_Src.c,174 :: 		prevState = currentState;
	MOVF       _currentState+0, 0
	MOVWF      _prevState+0
;Techometer_Src.c,177 :: 		if (PORTD.F3) {
	BTFSS      PORTD+0, 3
	GOTO       L_main13
;Techometer_Src.c,178 :: 		revoCount = 0;
	CLRF       _revoCount+0
	CLRF       _revoCount+1
;Techometer_Src.c,179 :: 		}
L_main13:
;Techometer_Src.c,182 :: 		if (UART1_Data_Ready()) {
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main14
;Techometer_Src.c,184 :: 		if (RCSTA.OERR) {
	BTFSS      RCSTA+0, 1
	GOTO       L_main15
;Techometer_Src.c,185 :: 		RCSTA.CREN = 0;
	BCF        RCSTA+0, 4
;Techometer_Src.c,186 :: 		RCSTA.CREN = 1;
	BSF        RCSTA+0, 4
;Techometer_Src.c,187 :: 		}
L_main15:
;Techometer_Src.c,188 :: 		UART_message = UART1_Read();  // Read received character
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _UART_message+0
;Techometer_Src.c,190 :: 		switch(UART_message) {
	GOTO       L_main16
;Techometer_Src.c,192 :: 		case 'O':
L_main18:
;Techometer_Src.c,193 :: 		if (motorState) {
	BTFSS      _motorState+0, BitPos(_motorState+0)
	GOTO       L_main19
;Techometer_Src.c,194 :: 		MOTOR_IN1 = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;Techometer_Src.c,195 :: 		motorState = 0;
	BCF        _motorState+0, BitPos(_motorState+0)
;Techometer_Src.c,196 :: 		}
	GOTO       L_main20
L_main19:
;Techometer_Src.c,198 :: 		MOTOR_IN1 = 1;
	BSF        RC3_bit+0, BitPos(RC3_bit+0)
;Techometer_Src.c,199 :: 		motorState = 1;
	BSF        _motorState+0, BitPos(_motorState+0)
;Techometer_Src.c,200 :: 		}
L_main20:
;Techometer_Src.c,201 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,203 :: 		case 'R':
L_main21:
;Techometer_Src.c,204 :: 		revoCount = 0;
	CLRF       _revoCount+0
	CLRF       _revoCount+1
;Techometer_Src.c,205 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,207 :: 		case 'E':
L_main22:
;Techometer_Src.c,208 :: 		UART_PWM_Enable = 1;
	BSF        _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
;Techometer_Src.c,209 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,211 :: 		case 'P':
L_main23:
;Techometer_Src.c,212 :: 		UART_PWM_Enable = 0;
	BCF        _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
;Techometer_Src.c,213 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,215 :: 		case '+':  // Increase PWM duty cycle
L_main24:
;Techometer_Src.c,216 :: 		if (UART_PWM_Enable) {
	BTFSS      _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
	GOTO       L_main25
;Techometer_Src.c,217 :: 		if (PWM_Value <= 245) {
	MOVF       _PWM_Value+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main43
	MOVF       _PWM_Value+0, 0
	SUBLW      245
L__main43:
	BTFSS      STATUS+0, 0
	GOTO       L_main26
;Techometer_Src.c,218 :: 		PWM_Value += 10;
	MOVLW      10
	ADDWF      _PWM_Value+0, 1
	BTFSC      STATUS+0, 0
	INCF       _PWM_Value+1, 1
;Techometer_Src.c,219 :: 		}
	GOTO       L_main27
L_main26:
;Techometer_Src.c,221 :: 		PWM_Value = 255;
	MOVLW      255
	MOVWF      _PWM_Value+0
	CLRF       _PWM_Value+1
;Techometer_Src.c,222 :: 		}
L_main27:
;Techometer_Src.c,223 :: 		PWM1_Set_Duty(PWM_Value);
	MOVF       _PWM_Value+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Techometer_Src.c,224 :: 		}
L_main25:
;Techometer_Src.c,225 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,227 :: 		case '-':
L_main28:
;Techometer_Src.c,228 :: 		if (UART_PWM_Enable) {
	BTFSS      _UART_PWM_Enable+0, BitPos(_UART_PWM_Enable+0)
	GOTO       L_main29
;Techometer_Src.c,229 :: 		if (PWM_Value >= 10) {
	MOVLW      0
	SUBWF      _PWM_Value+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main44
	MOVLW      10
	SUBWF      _PWM_Value+0, 0
L__main44:
	BTFSS      STATUS+0, 0
	GOTO       L_main30
;Techometer_Src.c,230 :: 		PWM_Value -= 10;
	MOVLW      10
	SUBWF      _PWM_Value+0, 1
	BTFSS      STATUS+0, 0
	DECF       _PWM_Value+1, 1
;Techometer_Src.c,231 :: 		}
	GOTO       L_main31
L_main30:
;Techometer_Src.c,233 :: 		PWM_Value = 0;
	CLRF       _PWM_Value+0
	CLRF       _PWM_Value+1
;Techometer_Src.c,234 :: 		}
L_main31:
;Techometer_Src.c,235 :: 		PWM1_Set_Duty(PWM_Value);
	MOVF       _PWM_Value+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Techometer_Src.c,236 :: 		}
L_main29:
;Techometer_Src.c,237 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,238 :: 		default:
L_main32:
;Techometer_Src.c,239 :: 		break;
	GOTO       L_main17
;Techometer_Src.c,240 :: 		}
L_main16:
	MOVF       _UART_message+0, 0
	XORLW      79
	BTFSC      STATUS+0, 2
	GOTO       L_main18
	MOVF       _UART_message+0, 0
	XORLW      82
	BTFSC      STATUS+0, 2
	GOTO       L_main21
	MOVF       _UART_message+0, 0
	XORLW      69
	BTFSC      STATUS+0, 2
	GOTO       L_main22
	MOVF       _UART_message+0, 0
	XORLW      80
	BTFSC      STATUS+0, 2
	GOTO       L_main23
	MOVF       _UART_message+0, 0
	XORLW      43
	BTFSC      STATUS+0, 2
	GOTO       L_main24
	MOVF       _UART_message+0, 0
	XORLW      45
	BTFSC      STATUS+0, 2
	GOTO       L_main28
	GOTO       L_main32
L_main17:
;Techometer_Src.c,241 :: 		}
L_main14:
;Techometer_Src.c,244 :: 		if (update_rpm_flag) {
	BTFSS      _update_rpm_flag+0, BitPos(_update_rpm_flag+0)
	GOTO       L_main33
;Techometer_Src.c,245 :: 		rpm = (pulseCount * 60) / 20;  // Calculate RPM
	MOVF       _pulseCount+0, 0
	MOVWF      R0+0
	MOVF       _pulseCount+1, 0
	MOVWF      R0+1
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      20
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _rpm+0
	MOVF       R0+1, 0
	MOVWF      _rpm+1
;Techometer_Src.c,246 :: 		pulseCount = 0;
	CLRF       _pulseCount+0
	CLRF       _pulseCount+1
;Techometer_Src.c,247 :: 		timer_count = 0;
	CLRF       _timer_count+0
	CLRF       _timer_count+1
;Techometer_Src.c,248 :: 		update_rpm_flag = 0;
	BCF        _update_rpm_flag+0, BitPos(_update_rpm_flag+0)
;Techometer_Src.c,249 :: 		}
L_main33:
;Techometer_Src.c,252 :: 		LCD_Display_RPM(rpm);
	MOVF       _rpm+0, 0
	MOVWF      FARG_LCD_Display_RPM_rpm+0
	MOVF       _rpm+1, 0
	MOVWF      FARG_LCD_Display_RPM_rpm+1
	CALL       _LCD_Display_RPM+0
;Techometer_Src.c,253 :: 		LCD_Display_Revo(revoCount);
	MOVF       _revoCount+0, 0
	MOVWF      FARG_LCD_Display_Revo_revoCount+0
	MOVF       _revoCount+1, 0
	MOVWF      FARG_LCD_Display_Revo_revoCount+1
	CALL       _LCD_Display_Revo+0
;Techometer_Src.c,254 :: 		UART_Display_Data(rpm, revoCount, PWM_Value);
	MOVF       _rpm+0, 0
	MOVWF      FARG_UART_Display_Data_rpm+0
	MOVF       _rpm+1, 0
	MOVWF      FARG_UART_Display_Data_rpm+1
	MOVF       _revoCount+0, 0
	MOVWF      FARG_UART_Display_Data_revoCount+0
	MOVF       _revoCount+1, 0
	MOVWF      FARG_UART_Display_Data_revoCount+1
	MOVF       _PWM_Value+0, 0
	MOVWF      FARG_UART_Display_Data_PWM_Cycle+0
	MOVF       _PWM_Value+1, 0
	MOVWF      FARG_UART_Display_Data_PWM_Cycle+1
	CALL       _UART_Display_Data+0
;Techometer_Src.c,255 :: 		}
	GOTO       L_main4
;Techometer_Src.c,256 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

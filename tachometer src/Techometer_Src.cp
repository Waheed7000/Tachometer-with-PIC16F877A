#line 1 "X:/Programing/Embedded/tachometer src/Techometer_Src.c"



sbit LCD_RS at RB6_bit;
sbit LCD_EN at RB7_bit;
sbit LCD_D7 at RB5_bit;
sbit LCD_D6 at RB4_bit;
sbit LCD_D5 at RB3_bit;
sbit LCD_D4 at RB2_bit;


sbit LCD_RS_Direction at TRISB6_bit;
sbit LCD_EN_Direction at TRISB7_bit;
sbit LCD_D7_Direction at TRISB5_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D4_Direction at TRISB2_bit;


sbit MOTOR_IN1 at RC3_bit;
sbit MOTOR_IN2 at RD0_bit;


sbit SENSOR_PIN at RB0_bit;


volatile unsigned int pulseCount = 0;
volatile unsigned int revoCount = 0;
unsigned int timer_count = 0;
unsigned int rpm = 0;
bit update_rpm_flag;


char RPM_str[10];
char REVO_str[10];
char Duty_str[10];


char prevState = 0;
char currentState;
bit motorState;


float ADC_Value;
unsigned int PWM_Value;


unsigned char UART_message;
bit UART_PWM_Enable;


void interrupt(){

 if (INTF_bit){
 pulseCount++;
 revoCount++;
 INTF_bit = 0;
 }


 if (TMR1IF_bit) {
 timer_count++;
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xDC;

 if (timer_count >= 4) {
 update_rpm_flag = 1;
 }
 }
}


void Init_LCD() {
 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
}


void LCD_Display_RPM(unsigned int rpm) {
 IntToStr(rpm, RPM_str);
 Lcd_Out(1, 1, "RPM: ");
 Lcd_Out(1, 6, RPM_str);
}


void LCD_Display_Revo(unsigned int revoCount) {
 IntToStr((revoCount/20), REVO_str);
 Lcd_Out(2, 1, "REVO: ");
 Lcd_Out(2, 6, REVO_str);
}


void UART_Display_Data(unsigned int rpm, unsigned int revoCount, unsigned int PWM_Cycle) {
 IntToStr(rpm, RPM_str);
 IntToStr((revoCount/20), REVO_str);
 IntToStr(((PWM_Cycle*100)/255), Duty_str);

 UART1_Write_Text(RPM_str);
 UART1_Write_Text("|");

 UART1_Write_Text(REVO_str);
 UART1_Write_Text("|");

 UART1_Write_Text(Duty_str);
 UART1_Write_Text("%");
 UART1_Write_Text("|");
 UART1_Write_Text("\n");
}


void main() {

 TRISC = 0x00;
 TRISD = 0x00;
 TRISD.F2 = 1;
 TRISD.F3 = 1;
 TRISB.F0 = 1;


 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON.INTE = 1;
 INTCON.INTF = 0;
 OPTION_REG.INTEDG = 1;


 T1CON = 0b00110001;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
 PIE1.TMR1IE = 1;


 Init_LCD();
 ADC_Init();


 PWM1_Init(1000);
 PWM1_Start();


 UART1_Init(9600);
 delay_ms(100);

 UART_PWM_Enable = 0;

 MOTOR_IN1 = 0;
 MOTOR_IN2 = 0;

 while (1) {

 if (!UART_PWM_Enable) {
 ADC_Value = ADC_Read(0);
 PWM_Value = (ADC_Value * 255) / 1023;
 PWM1_Set_Duty(PWM_Value);
 }


 currentState = PORTD.F2;
 if (currentState == 1 && prevState == 0) {
 if (PORTD.F2 == 1) {
 motorState = !motorState;
 if (motorState) {
 MOTOR_IN1 = 1;
 MOTOR_IN2 = 0;
 }
 else {
 MOTOR_IN1 = 0;
 MOTOR_IN2 = 0;
 }
 }
 }
 prevState = currentState;


 if (PORTD.F3) {
 revoCount = 0;
 }


 if (UART1_Data_Ready()) {

 if (RCSTA.OERR) {
 RCSTA.CREN = 0;
 RCSTA.CREN = 1;
 }
 UART_message = UART1_Read();

 switch(UART_message) {

 case 'O':
 if (motorState) {
 MOTOR_IN1 = 0;
 motorState = 0;
 }
 else {
 MOTOR_IN1 = 1;
 motorState = 1;
 }
 break;

 case 'R':
 revoCount = 0;
 break;

 case 'E':
 UART_PWM_Enable = 1;
 break;

 case 'P':
 UART_PWM_Enable = 0;
 break;

 case '+':
 if (UART_PWM_Enable) {
 if (PWM_Value <= 245) {
 PWM_Value += 10;
 }
 else {
 PWM_Value = 255;
 }
 PWM1_Set_Duty(PWM_Value);
 }
 break;

 case '-':
 if (UART_PWM_Enable) {
 if (PWM_Value >= 10) {
 PWM_Value -= 10;
 }
 else {
 PWM_Value = 0;
 }
 PWM1_Set_Duty(PWM_Value);
 }
 break;
 default:
 break;
 }
 }


 if (update_rpm_flag) {
 rpm = (pulseCount * 60) / 20;
 pulseCount = 0;
 timer_count = 0;
 update_rpm_flag = 0;
 }


 LCD_Display_RPM(rpm);
 LCD_Display_Revo(revoCount);
 UART_Display_Data(rpm, revoCount, PWM_Value);
 }
}

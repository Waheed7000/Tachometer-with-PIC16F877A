#define _XTAL_FREQ 8000000  // Define system frequency for delay functions

// LCD pinout settings
sbit LCD_RS at RB6_bit;
sbit LCD_EN at RB7_bit;
sbit LCD_D7 at RB5_bit;
sbit LCD_D6 at RB4_bit;
sbit LCD_D5 at RB3_bit;
sbit LCD_D4 at RB2_bit;

// LCD pin direction settings
sbit LCD_RS_Direction at TRISB6_bit;
sbit LCD_EN_Direction at TRISB7_bit;
sbit LCD_D7_Direction at TRISB5_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D4_Direction at TRISB2_bit;

// Motor control pins
sbit MOTOR_IN1 at RC3_bit;
sbit MOTOR_IN2 at RD0_bit;

// RPM sensor pin
sbit SENSOR_PIN at RB0_bit;

// Variables for RPM measurement
volatile unsigned int pulseCount = 0;
volatile unsigned int revoCount = 0;
unsigned int timer_count = 0;
unsigned int rpm = 0;
bit update_rpm_flag;  // Flag to trigger RPM update

// Buffers for displaying data
char RPM_str[10];
char REVO_str[10];
char Duty_str[10];

// Motor state control
char prevState = 0;
char currentState;
bit motorState;

// PWM and ADC variables
float ADC_Value;
unsigned int PWM_Value;

// UART variables
unsigned char UART_message;
bit UART_PWM_Enable;  // Flag to enable PWM from UART

// Interrupt routine
void interrupt(){
    // External interrupt: triggered by RPM sensor
    if (INTF_bit){
        pulseCount++;
        revoCount++;
        INTF_bit = 0;
    }

    // Timer1 overflow interrupt for RPM timing
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

// Initialize LCD
void Init_LCD() {
    Lcd_Init();
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Cmd(_LCD_CURSOR_OFF);
}

// Display RPM value on LCD
void LCD_Display_RPM(unsigned int rpm) {
    IntToStr(rpm, RPM_str);
    Lcd_Out(1, 1, "RPM: ");
    Lcd_Out(1, 6, RPM_str);
}

// Display REVO (revolutions) on LCD
void LCD_Display_Revo(unsigned int revoCount) {
    IntToStr((revoCount/20), REVO_str);
    Lcd_Out(2, 1, "REVO: ");
    Lcd_Out(2, 6, REVO_str);
}

// Send RPM, REVO, and Duty to Bluetooth terminal
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

// Main program
void main() {
    // Pin configurations
    TRISC = 0x00;
    TRISD = 0x00;
    TRISD.F2 = 1;  // Input: Button for motor toggle
    TRISD.F3 = 1;  // Input: Button to reset REVO count
    TRISB.F0 = 1;  // Input: RPM sensor

    // Interrupts Confegration
    INTCON.GIE = 1;        // interrupt confegration -> global interrupt enable
    INTCON.PEIE = 1;       // interrupt confegration -> peripheral interrupt enable
    INTCON.INTE = 1;       // interrupt confegration -> external interrupt enable
    INTCON.INTF = 0;       // clear external interrupt flag
    OPTION_REG.INTEDG = 1; // external interrupt on rising edge

    // Configure Timer1
    T1CON = 0b00110001;
    TMR1H = 0x0B;
    TMR1L = 0xDC;
    PIE1.TMR1IE = 1;


    Init_LCD();
    ADC_Init();
    
    // Initialize PWM at 1kHz
    PWM1_Init(1000);
    PWM1_Start();
    
    // Initialize UART at 9600 baud
    UART1_Init(9600);
    delay_ms(100);

    UART_PWM_Enable = 0; // Default: PWM from potentiometer
    
    MOTOR_IN1 = 0;
    MOTOR_IN2 = 0;

    while (1) {
        // Set PWM from potentiometer if UART control not enabled
        if (!UART_PWM_Enable) {
            ADC_Value = ADC_Read(0);
            PWM_Value = (ADC_Value * 255) / 1023;
            PWM1_Set_Duty(PWM_Value);
        }

        // Motor toggle button handler
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

        // Reset REVO count button
        if (PORTD.F3) {
           revoCount = 0;
        }

        // UART command handling
        if (UART1_Data_Ready()) {
            // Handle Overrun Error
            if (RCSTA.OERR) {
                RCSTA.CREN = 0;
                RCSTA.CREN = 1;
            }
            UART_message = UART1_Read();  // Read received character

            switch(UART_message) {
                // Toggle motor ON/OFF
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
                // Reset REVO count
                case 'R':
                    revoCount = 0;
                    break;
                // Enable UART PWM control
                case 'E':
                    UART_PWM_Enable = 1;
                    break;
                // Disable UART PWM control
                case 'P':
                    UART_PWM_Enable = 0;
                    break;
                // Increase PWM duty cycle
                case '+':  // Increase PWM duty cycle
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
                // Decrease PWM duty cycle
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

        // Update RPM every 1s
        if (update_rpm_flag) {
           rpm = (pulseCount * 60) / 20;  // Calculate RPM
           pulseCount = 0;
           timer_count = 0;
           update_rpm_flag = 0;
        }

        // Display current values
        LCD_Display_RPM(rpm);
        LCD_Display_Revo(revoCount);
        UART_Display_Data(rpm, revoCount, PWM_Value);
    }
}

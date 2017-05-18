#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "soc-hw.h"

//Aqui se ponen las direcciones de los módulos

uart_t       	*uart0       	= (uart_t *)       	0x20000000;
timerH_t     	*timer0   	= (timerH_t *)     	0x40000000;
i2c_t	  	*i2c0		= (i2c_t *)		0x60000000;
fuente_t    	*fuente0    	= (fuente_t*)      	0x80000000;
//gpio_t       	*gpio0       	= (gpio_t *)       	0xA0000000;

isr_ptr_t isr_table[32];

/***************************************************************************
 * IRQ handling
 */
void isr_null(void)
{
}

void irq_handler(uint32_t pending)
{     
    uint32_t i;

    for(i=0; i<32; i++) {
        if (pending & 0x00000001){
            (*isr_table[i])();
        }
        pending >>= 1;
    }
}

void isr_init(void)
{
    int i;
    for(i=0; i<32; i++)
        isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
    isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
    isr_table[irq] = &isr_null;
}

/***************************************************************************
 * TIMER Functions
 */
uint32_t tic_msec;

void mSleep(uint32_t msec)
{
    uint32_t tcr;

    // Use timer0.1
    timer0->compare1 = (FCPU/1000)*msec;
    timer0->counter1 = 0;
    timer0->tcr1 = TIMER_EN;

    do {
        //halt();
         tcr = timer0->tcr1;
     } while ( ! (tcr & TIMER_TRIG) );
}

void uSleep(uint32_t usec)
{
    uint32_t tcr;

    // Use timer0.1
    timer0->compare1 = (FCPU/1000000)*usec;
    timer0->counter1 = 0;
    timer0->tcr1 = TIMER_EN;

    do {
        //halt();
         tcr = timer0->tcr1;
     } while ( ! (tcr & TIMER_TRIG) );
}

void tic_isr(void)
{
    tic_msec++;
    timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_init(void)
{
    tic_msec = 0;

    // Setup timer0.0
    timer0->compare0 = (FCPU/10000);
    timer0->counter0 = 0;
    timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;

    isr_register(1, &tic_isr);
}


/***************************************************************************
 * UART Functions
 */
void uart_init(void)
{
    //uart0->ier = 0x00;  // Interrupt Enable Register
    //uart0->lcr = 0x03;  // Line Control Register:    8N1
    //uart0->mcr = 0x00;  // Modem Control Register

    // Setup Divisor register (Fclk / Baud)
    //uart0->div = (FCPU/(57600*16));
}

char uart_getchar(void)
{   
    while (! (uart0->ucr & UART_DR)) ;
    return uart0->rxtx;
}

void uart_putchar(char c)
{
    while (uart0->ucr & UART_BUSY) ;
    uart0->rxtx = c;
}

void uart_putstr(char *str)
{
    char *c = str;
    while(*c) {
        uart_putchar(*c);
        c++;
    }
}

char *itoa(int i, char b[]){
    char const digit[] = "0123456789";
    char *p = b;
    if (i < 0)
    {
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    do
    { //Move to where representation ends
        ++p;
        shifter = shifter / 10;
    } while (shifter);
    *p = '\0';
    do
    { //Move back, inserting digits as u go
        *--p = digit[i % 10];
        i = i / 10;
    } while (i);
    return b;
}

/***************************************************************************
 * I2C Functions
 */
 
uint8_t i2c_read(uint8_t slave_addr, uint8_t per_addr)
{
		
	while(!(i2c0->scr & I2C_DR));		//Se verifica que el bus esté en espera
	i2c0->s_address = slave_addr;
	i2c0->s_reg 	= per_addr;
	i2c0->start_rd 	= 0x00;
	while(!(i2c0->scr & I2C_DR));
	return i2c0->i2c_rx_data;
	mSleep(2);
}

void i2c_write(uint8_t slave_addr, uint8_t per_addr, uint8_t data){
	
	while(!(i2c0->scr & I2C_DR));		//Se verifica que el bus esté en espera
	i2c0->s_address = slave_addr;
	i2c0->s_reg 	= per_addr;
	i2c0->tx_data 	= data;
	i2c0->start_wr 	= 0x00;
	mSleep(1);
}

/***************************************************************************
 * Fuente Functions
 */

uint8_t fuente_read_data(uint32_t addr){
	fuente0->addr_rd	= addr;
	fuente0->rd		= 1;
	fuente0->rd		= 0;
	return fuente0->d_out;
};

/***************************************************************************
 * Display Functions
 */

void send_command_display(uint8_t addr, uint8_t command){
	i2c_write(addr, DISPLAY_COMMAND, command);
};

void send_data_display(uint8_t addr, uint8_t data){
	i2c_write(addr, DISPLAY_INDEX, data);
};

void sec_on_display(void){
        send_command_display(DISPLAY_ADDR,0xAE); //OFF PANTALLA 
	send_command_display(DISPLAY_ADDR,0X20); // MODO DE DIRECCIONAMIENTO
	send_command_display(DISPLAY_ADDR,0x00);
	send_command_display(DISPLAY_ADDR,0xB0); // CUADRAR DIRECCIÓN INICIAL DE PAGINA
        send_command_display(DISPLAY_ADDR,0xC8); //OUTPUT SCAN COM DIRECTORY
        send_command_display(DISPLAY_ADDR,0x00); // --- SET LOW COLUMN ADDR ADDRES       
        send_command_display(DISPLAY_ADDR,0x10); // --- SET HIGH COLUMN ADDR
        send_command_display(DISPLAY_ADDR,0x40); // --- SET STAR LINE ADDR
        send_command_display(DISPLAY_ADDR,0x81); // SET CONTRAST
        send_command_display(DISPLAY_ADDR,0x3F); //
        send_command_display(DISPLAY_ADDR,0xA1); // SET SEGMENT RE-MAP. A1=addr 127 MAPPED
        send_command_display(DISPLAY_ADDR,0xA6); // SET DISPLAY MODE. A6=NORMAL
        send_command_display(DISPLAY_ADDR,0xA8); // SET MUX RATIO
        send_command_display(DISPLAY_ADDR,0x3F);
        send_command_display(DISPLAY_ADDR,0xA4); // OUTPUT RAM TO DISPLAY
        //send_command_display(DISPLAY_ADDR,0xA5); // ENTIRE DISPLAY ON
        send_command_display(DISPLAY_ADDR,0xD3); // DISPLAY OFFSET. 00= NO
        send_command_display(DISPLAY_ADDR,0x00);
        send_command_display(DISPLAY_ADDR,0xD5); //---SET DISPLAY CLOCK  DIVIDE RATIO /OSCILATOR
        send_command_display(DISPLAY_ADDR,0xF0); //-- SET DIVIDE RATIO
        send_command_display(DISPLAY_ADDR,0xD9); //SET PRE-CHARGUE PERIOD
        send_command_display(DISPLAY_ADDR,0x22);
        send_command_display(DISPLAY_ADDR,0xDA); //SET COM PINS 
        send_command_display(DISPLAY_ADDR,0x12);
        send_command_display(DISPLAY_ADDR,0xDB); //--SET VCOMH
        send_command_display(DISPLAY_ADDR,0x20); //0x20,0.77xVcc
        send_command_display(DISPLAY_ADDR,0x8D); //SET DC-DC ENABLE
        send_command_display(DISPLAY_ADDR,0x14); 
        send_command_display(DISPLAY_ADDR,0xAF); //ON PANTALLA
};	



void clear_GDRAM(void){
        uint8_t i, j;
        set_position(0x00, 0x00);
	for(j=1;j<9;j++){
          	for (i=1;i<129;i++) {
            		send_data_display(DISPLAY_ADDR, 0x00);
          	}
        }
	
};

void set_position(uint8_t posx, uint8_t posy){
	send_command_display(DISPLAY_ADDR,0x21); //Configurar el direccionamiento por columna
	send_command_display(DISPLAY_ADDR,posx);
	send_command_display(DISPLAY_ADDR,0x7F);
	send_command_display(DISPLAY_ADDR,0x22); //Configurar el direccionamiento por página
	send_command_display(DISPLAY_ADDR,posy);
	send_command_display(DISPLAY_ADDR,0x07);
};

void print_char(uint8_t code){
        uint32_t addr = (code*6);
        uint8_t data;
        uint8_t k; 
        for(k=0;k<6;k++){
        	data = fuente_read_data(addr+k);
        	send_data_display(DISPLAY_ADDR,data);
        };
};

void print_cadena_ascii(char* cadena){   			 
  	uint8_t i;
   
  	for(i = 0; cadena[i] !='\0'; i++){   	
    		print_char(cadena[i]-32); 
  	};
};

void print_entero_ascii(int numero){
    uint8_t c = numero;
    uint8_t contador = 1; 
    
     while(c/10>0)
    {
        c=c/10;
        contador++;
    };
    
    char buffer[contador];
    
    itoa(numero,buffer);
    
    print_cadena_ascii(buffer);
};

void print_wifi_hour(uint8_t hora, uint8_t minutos){
        set_position(80, 0);
        print_entero_ascii(hora);
        print_char(26);
        print_entero_ascii(minutos);
        print_char(00);
        print_char(94);
        print_char(95);
};

void init_display(void){
        uint8_t i;
        set_position(23,3);
        print_cadena_ascii("AUTOAQUARIUM");
        //peces
        set_position(19,5);
        for(i=0;i<3;i++){
                print_char(00);
                print_char(96);
                print_char(97);
                print_char(00);
                print_char(00);
        };
};

void principal_display(uint8_t hora, uint8_t minutos, uint8_t temperatura, uint8_t ph){
        print_wifi_hour(hora,minutos);
        set_position(4,1);
        print_char(98);
        print_char(99);
        set_position(4,2);
        print_char(100);
        print_char(101);
        print_cadena_ascii("Temperatura: ");
        print_entero_ascii(temperatura);
        print_char(102);
        print_char(35);
        set_position(4,3);
        print_char(103);
        print_char(104);
        set_position(4,4);
        print_char(105);
        print_char(106);
        print_cadena_ascii("Nivel de PH: ");
        print_entero_ascii(ph);        
};


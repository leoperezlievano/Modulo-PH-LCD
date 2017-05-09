#include "soc-hw.h"

//Aqui se ponen las direcciones de los módulos

uart_t       	*uart0       	= (uart_t *)       	0x20000000;
timerH_t     	*timer0   	= (timerH_t *)     	0x40000000;
i2c_t	  	*i2c0		= (i2c_t *)		0x60000000;
fuente_t    	*fuente0    	= (fuente_t*)      	0x80000000;
//gpio_t       	*gpio0       	= (gpio_t *)       	0x40000000;

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

/***************************************************************************
 * I2C Functions
 */
 
uint8_t i2c_read(uint32_t slave_addr, uint32_t per_addr)
{
		
	while(!(i2c0->scr & I2C_DR));		//Se verifica que el bus esté en espera
	i2c0->sdat = (slave_addr | per_addr<<8);
	return i2c0->sdat;

}

void i2c_write(uint32_t slave_addr, uint32_t per_addr, uint32_t data){
	
	while(!(i2c0->scr & I2C_DR));		//Se verifica que el bus esté en espera
	i2c0->sdat = (slave_addr | per_addr<<8 | data<<16);

}

/***************************************************************************
 * Fuente Functions
 */

uint32_t fuente_read_data(uint32_t addr){
	fuente0->addr_rd	= addr;
	fuente0->rd		= 1;
	fuente0->rd		= 0;
	return fuente0->d_out;
};

/***************************************************************************
 * Pantalla Functions
 */

void send_command_display(uint8_t addr, uint8_t command){
	i2c_write(addr, DISPLAY_COMMAND, command);
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
        //send_command_display(DISPLAY_ADDR,0xA4); // OUTPUT RAM TO DISPLAY
        send_command_display(DISPLAY_ADDR,0xA5); // ENTIRE DISPLAY ON
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
/*
void vaciar_pantalla(void){
        
        uSleep(50); 
         
};
*/

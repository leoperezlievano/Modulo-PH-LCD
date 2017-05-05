#include "soc-hw.h"

//Aqui se ponen las direcciones de los módulos

uart_t       	*uart0       	= (uart_t *)       	0x20000000;
timerH_t     	*timer0   	= (timerH_t *)     	0x40000000;
i2c_t	  	*i2c0		= (i2c_t *)		0x60000000;
//pantalla_t    *pantalla0    = (pantalla_t*)      0x80000000;
//gpio_t       *gpio0       = (gpio_t *)       	0x40000000;

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
 
void i2c_write_data(uint8_t addr_wr, uint8_t data){
	while(i2c0->i2c_state == 1){
		uSleep(50);
	};
	i2c0->rw 		= 0;
	uSleep(10);
	i2c0->addr	 	= addr_wr;
	uSleep(10);
	i2c0->data_wr 	= data;
	uSleep(10);
	i2c0->ena		= 1;
	uSleep(10);
	while(i2c0->i2c_state == 0){
		uSleep(50);
	};
	i2c0->ena		= 0;
};

uint8_t i2c_read_data(uint8_t addr_rd){
	while(i2c0->i2c_state == 1){
		uSleep(50);
	};
	i2c0->rw 		= 1;
	uSleep(10);
	i2c0->addr	 	= addr_rd;
	uSleep(10);
	i2c0->ena		= 1;
	uSleep(10);
	while(i2c0->i2c_state == 0){
		uSleep(50);
	};
	i2c0->ena		= 0;
	while(i2c0->i2c_state == 1){
		uSleep(50);
	};
	return i2c0->data_rd;
};

/***************************************************************************
 * Pantalla Functions
 */
 
void prender_pantalla(void){
	//Estos son los pasos que se recomiendan en el datasheet
	i2c_write_data(0x3C,0xAE); 	//Display Off
	i2c_write_data(0x3C,0xA8);	//Set MUX Ratio
	i2c_write_data(0x3C,0x3F);
	i2c_write_data(0x3C,0xD3);	//Set Display Offset
	i2c_write_data(0x3C,0x00);
	i2c_write_data(0x3C,0x40);	//Set Display Start Line
	i2c_write_data(0x3C,0xA0);	//Set Segment re-map
	i2c_write_data(0x3C,0xC0);	//Set COM Output Scan Direction
	i2c_write_data(0x3C,0xDA);	//Set COM Pins hardware configuration
	i2c_write_data(0x3C,0x02);	
	i2c_write_data(0x3C,0x81);	//Set Contrast Control
	i2c_write_data(0x3C,0x7F);
	i2c_write_data(0x3C,0xA4);	//Disable Entire Display On
	//i2c_write_data(0x3C,0xA6);	//Set Normal Display
	i2c_write_data(0x3C,0xA7);	//Set Inverse Display
	i2c_write_data(0x3C,0xD5);	//Set Osc Frequency
	i2c_write_data(0x3C,0x80);
	i2c_write_data(0x3C,0x8D);	//Enable charge pump regulator
	i2c_write_data(0x3C,0x14);
	i2c_write_data(0x3C,0xAF);	//Display On	
};

 /*
void prender_pantalla(void){
	i2c_write_data(0x3C,0xAE); //OFF PANTALLA 
	i2c_write_data(0x3C,0X20); // MODO DE DIRECCIONAMIENTO
	i2c_write_data(0x3C,0x00);
	i2c_write_data(0x3C,0xB0); // CUADRAR DIRECCIÓN INICIAL DE PAGINA
        i2c_write_data(0x3C,0xC8); //OUTPUT SCAN COM DIRECTORY
        i2c_write_data(0x3C,0x00); // --- SET LOW COLUMN ADDR ADDRES       
        i2c_write_data(0x3C,0x10); // --- SET HIGH COLUMN ADDR
        i2c_write_data(0x3C,0x40); // --- SET STAR LINE ADDR
        i2c_write_data(0x3C,0x81); // SET CONTRAST
        i2c_write_data(0x3C,0x3F); //
        i2c_write_data(0x3C,0xA1); // SET SEGMENT RE-MAP. A1=addr 127 MAPPED
        i2c_write_data(0x3C,0xA6); // SET DISPLAY MODE. A6=NORMAL
        i2c_write_data(0x3C,0xA8); // SET MUX RATIO
        i2c_write_data(0x3C,0x3F);
        i2c_write_data(0x3C,0xA4);
        i2c_write_data(0x3C,0xA5); // OUTPUT RAM TO DISPLAY
        i2c_write_data(0x3C,0xD3); // DISPLAY OFFSET. 00= NO
        i2c_write_data(0x3C,0x00);
        i2c_write_data(0x3C,0xD5); //---SET DISPLAY CLOCK  DIVIDE RATIO /OSCILATOR
        i2c_write_data(0x3C,0xF0); //-- SET DIVIDE RATIO
        i2c_write_data(0x3C,0xD9); //SET PRE-CHARGUE PERIOD
        i2c_write_data(0x3C,0x22);
        i2c_write_data(0x3C,0xDA); //SET COM PINS 
        i2c_write_data(0x3C,0x12);
        i2c_write_data(0x3C,0xDB); //--SET VCOMH
        i2c_write_data(0x3C,0x20); //0x20,0.77xVcc
        i2c_write_data(0x3C,0x8D); //SET DC-DC ENABLE
        i2c_write_data(0x3C,0x14); 
        i2c_write_data(0x3C,0xAF); //ON PANTALLA
};*/	
/*
void vaciar_pantalla(void){
        
        uSleep(50); 
         
};

void pintar_letra_pantalla (uint8_t posx_t,uint8_t posy_t, uint8_t letra){
	pantalla0->posx 	= posx_t;
	pantalla0->posy		= posy_t;
	pantalla0->caracter	= letra;
	pantalla0->wr		= 1;
	pantalla0->wr		= 0;
	uSleep(1);
}; 
*/

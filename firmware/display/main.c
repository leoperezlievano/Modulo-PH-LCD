/*- Includes ---------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "soc-hw.h"

/*- Definitions ------------------------------------------------------------*/
#ifndef UART_COMMANDS_BUFFER_SIZE
#define UART_COMMANDS_BUFFER_SIZE 100
#endif

#define FINALCHARACTER1 '\r'
#define FINALCHARACTER2 '\n'

/*- Variables --------------------------------------------------------------*/


int main(void){	
	sec_on_display();
	clear_GDRAM();   
        set_position(4,2);
        print_cadena_ascii("Color rojo: ");
        set_position(4,4);
        print_cadena_ascii("Color azul: ");
        set_position(4,6);
        print_cadena_ascii("Color verde: ");
        
        int32_t rojo, azul, verde;
        
        while(1){
        initPH(); 
        habilitar_PH_sensor();
        rojo = leer_rojo();
        set_position(80,2);
        print_char(00);
        print_char(00);
        print_char(00);
        set_position(80,2);
        print_entero_ascii(rojo);
        azul = leer_azul();
        set_position(80,4);
        print_char(00);
        print_char(00);
        print_char(00);
        set_position(80,4);
        print_entero_ascii(azul);
        verde = leer_verde();
        set_position(80,6);
        print_char(00);
        print_char(00);
        print_char(00);
        set_position(80,6);
        print_entero_ascii(verde);              
        mSleep(500);
        };
        	
    	return 0;
}

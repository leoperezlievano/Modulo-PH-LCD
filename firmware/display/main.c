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
        on_led();
        init_display();
        mSleep(3000);
        clear_GDRAM(); 
        while(1){
		principal_display(07, 50, 17);
		mSleep(100);
        };
   
        	
    	return 0;
}

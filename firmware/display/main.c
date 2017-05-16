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



int main(void)
{	
	sec_on_display();
	clear_GDRAM();
	init_display();
	mSleep(4000);
	clear_GDRAM();
	principal_display(07, 55, 19, 7);
        	
    	return 0;
}

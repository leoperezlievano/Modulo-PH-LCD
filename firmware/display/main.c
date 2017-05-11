
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
/*
char UartBuffer[UART_COMMANDS_BUFFER_SIZE];
uint32_t UartBufferPtr = 0;

char *itoa(int i, char b[])
{
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
*/
/*************************************************************************/ /**
Función que implementa una calculadora sencilla
*****************************************************************************/
/*
void commandProcessing(const char *buffer)
{

    int rgbw = atoi(buffer);
    SK6812RGBW_rgbw(rgbw);

    return;
}
*/
/*************************************************************************/ /**
*****************************************************************************/
/*
void commandUart_TaskHandler(void)
{

    //lee un byte del buffer de la UART
    char byte_u8 = uart_getchar();

    //verifica que no se ha exedido el buffer de comandos UART_COMMANDS_BUFFER_SIZE
    //Si se exede se envia una alerta y se borran los datos del buffer
    if (UartBufferPtr >= UART_COMMANDS_BUFFER_SIZE)
    {
        uart_putstr("\r\nUartBuffer size exceeded:serial commands\r\n-->");
        UartBufferPtr = 0;
        return;
    }

    //si se recibe un FINALCHARACTER se procesa el comando, de lo contrario
    //se almacena el caracter si es un caracter imprimible
    if (byte_u8 == FINALCHARACTER1 || byte_u8 == FINALCHARACTER2)
    {
        UartBuffer[UartBufferPtr++] = '\0'; // null character manually added
        uart_putstr("\r\n");
        commandProcessing(UartBuffer);
        uart_putstr("-->");
        UartBufferPtr = 0;
    }
    else if (byte_u8 >= ' ' && byte_u8 <= '~')
    {
        UartBuffer[UartBufferPtr++] = byte_u8;
        //Se hace un echo de caracteres almacenados
        uart_putchar(byte_u8);
    }
}
*/
int main(void)
{	
	uSleep(400);
	sec_on_display();
	clear_GDRAM();
	mSleep(1);
	send_command_display(DISPLAY_ADDR,0x21); //Configurar el direccionamiento por columna
        mSleep(1);
	send_command_display(DISPLAY_ADDR,0x20);
	mSleep(1);
	send_command_display(DISPLAY_ADDR,0x7F);
	mSleep(1);
	send_command_display(DISPLAY_ADDR,0x22); //Configurar el diferccionamiento por página
	mSleep(1);
	send_command_display(DISPLAY_ADDR,0x03);
	mSleep(1);
	send_command_display(DISPLAY_ADDR,0x07);
	mSleep(1);
        send_data_display(0x3C, 0x00);	//A
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x12);
        mSleep(1);
        send_data_display(0x3C, 0x11);
        mSleep(1);
        send_data_display(0x3C, 0x12);
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//u
        mSleep(1);
        send_data_display(0x3C, 0x3C);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x20);
        mSleep(1);
        send_data_display(0x3C, 0x7C);
         mSleep(1);
        send_data_display(0x3C, 0x00);	//t
        mSleep(1);
        send_data_display(0x3C, 0x04);
        mSleep(1);
        send_data_display(0x3C, 0x3F);
        mSleep(1);
        send_data_display(0x3C, 0x44);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x20);
          mSleep(1);
        send_data_display(0x3C, 0x00);	//o
        mSleep(1);
        send_data_display(0x3C, 0x38);
        mSleep(1);
        send_data_display(0x3C, 0x44);
        mSleep(1);
        send_data_display(0x3C, 0x44);
        mSleep(1);
        send_data_display(0x3C, 0x44);
        mSleep(1);
        send_data_display(0x3C, 0x38);
          mSleep(1);
        send_data_display(0x3C, 0x00);	//a
        mSleep(1);
        send_data_display(0x3C, 0x20);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x78);
          mSleep(1);
        send_data_display(0x3C, 0x00);	//q
        mSleep(1);
        send_data_display(0x3C, 0x18);
        mSleep(1);
        send_data_display(0x3C, 0x24);
        mSleep(1);
        send_data_display(0x3C, 0x24);
        mSleep(1);
        send_data_display(0x3C, 0x18);
        mSleep(1);
        send_data_display(0x3C, 0xFC);
         mSleep(1);
        send_data_display(0x3C, 0x00);	//u
        mSleep(1);
        send_data_display(0x3C, 0x3C);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x20);
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//a
        mSleep(1);
        send_data_display(0x3C, 0x20);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x54);
        mSleep(1);
        send_data_display(0x3C, 0x78);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//r
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x08);
        mSleep(1);
        send_data_display(0x3C, 0x04);
        mSleep(1);
        send_data_display(0x3C, 0x04);
        mSleep(1);
        send_data_display(0x3C, 0x08);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//i
        mSleep(1);
        send_data_display(0x3C, 0x00);
        mSleep(1);
        send_data_display(0x3C, 0x44);
        mSleep(1);
        send_data_display(0x3C, 0x7D);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x00);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//u
        mSleep(1);
        send_data_display(0x3C, 0x3C);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x40);
        mSleep(1);
        send_data_display(0x3C, 0x20);
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x00);	//m
        mSleep(1);
        send_data_display(0x3C, 0x7C);
        mSleep(1);
        send_data_display(0x3C, 0x04);
        mSleep(1);
        send_data_display(0x3C, 0x18);
        mSleep(1);
        send_data_display(0x3C, 0x04);
        mSleep(1);
        send_data_display(0x3C, 0x78);
        mSleep(1);
    	return 0;
}

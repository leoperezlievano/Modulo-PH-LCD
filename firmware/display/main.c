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


void initPH (void) 
{

/*1*/int8_t id;
     
     id = i2c_read(0x39, 0x92);
    
    if(!(id == APDS9960_ID_1 || id == APDS9960_ID_2)) {
        //return false; 
    }

    
/*2*/   i2c_write(0x39,APDS9960_ENABLE, 0);

/*3*/    i2c_write(0x39,DEFAULT_ATIME, DEFAULT_ATIME);
         i2c_write(0x39,DEFAULT_WTIME, DEFAULT_WTIME);
         i2c_write(0x39,APDS9960_PPULSE, DEFAULT_PROX_PPULSE);
         i2c_write(0x39,APDS9960_POFFSET_UR, DEFAULT_POFFSET_UR);
         i2c_write(0x39,APDS9960_POFFSET_DL, DEFAULT_POFFSET_DL );
         i2c_write(0x39,APDS9960_CONFIG1, DEFAULT_CONFIG1);
         
         //escritura en solo dos posiciones:5,6

          //*ADPS_CONTROL=00xx1001
          int8_t ctrl; int8_t val;
          ctrl=i2c_read(0x39,APDS9960_CONTROL);
          ctrl&=0x30;//00110000;//00xx0000 salvo lo que tenia en xx
          val =0x9;//  00001001;
          ctrl|=val;
          i2c_write(0x39,APDS9960_CONTROL,ctrl);          

/*4*/     
          i2c_write(0x39, APDS9960_PILT,   DEFAULT_PILT );
          i2c_write(0x39, APDS9960_PIHT,   DEFAULT_PIHT);
          i2c_write(0x39, APDS9960_AILTL,  0xFF );
          i2c_write(0x39, APDS9960_AILTH , 0xFF);
          i2c_write(0x39, APDS9960_AIHTL,  0);
          i2c_write(0x39, APDS9960_AIHTH,  0);
          i2c_write(0x39, APDS9960_PERS,   DEFAULT_PERS );
          i2c_write(0x39, APDS9960_CONFIG2,DEFAULT_CONFIG2);
          i2c_write(0x39, APDS9960_CONFIG3,DEFAULT_CONFIG3);
          i2c_write(0x39, APDS9960_GPENTH, DEFAULT_GPENTH );
          i2c_write(0x39, APDS9960_GEXTH,  DEFAULT_GEXTH );
          i2c_write(0x39, APDS9960_GCONF1, DEFAULT_GCONF1);

/*5*/     //escritura en todo menos en bit:8
          
          //*APDS9960_GCONF2=X1000001 
          int8_t gconf2; int8_t val1;
          gconf2=i2c_read(0x39,APDS9960_GCONF2);
          gconf2&=0x80; //10000000;//x000000 salvo lo que tenia en x
          val1 = 0x41;  //01000001;
          gconf2|=val1;
          i2c_write(0x39,APDS9960_GCONF2,gconf2);
          
          i2c_write(0x39,APDS9960_GOFFSET_U , DEFAULT_GOFFSET); 
          i2c_write(0x39,APDS9960_GOFFSET_D , DEFAULT_GOFFSET); 
          i2c_write(0x39,APDS9960_GOFFSET_L , DEFAULT_GOFFSET); 
          i2c_write(0x39,APDS9960_GOFFSET_R , DEFAULT_GOFFSET); 
          i2c_write(0x39,APDS9960_GPULSE    , DEFAULT_GPULSE); 
          i2c_write(0x39,APDS9960_GCONF3    , DEFAULT_GCONF3); 

           //escritura  en bit:2
          
          //*APDS9960_GCONF4=xxxxxx0x
          int8_t gconf4; int8_t val2;
          gconf4=i2c_read(0x39,APDS9960_GCONF4);
          gconf4&=0xFD;//11111101;//x000000 salvo lo que tenia en x
          val2 =  0;
          gconf4|=val2;
          i2c_write(0x39,APDS9960_GCONF4,gconf4);

         



         //return true;
    
};

void habilitar_PH_sensor (void)
{
  
  uint8_t control = i2c_read(0x39, APDS9960_CONTROL);
  control &=  0xFC;
  uint8_t val_control = 0x01;
  control |= val_control;
  i2c_write(0x39, APDS9960_CONTROL, control);

  uint8_t enable = i2c_read(0x39, APDS9960_ENABLE);
  enable &=  0xEC;
  uint8_t val_enable = 0x03;
  enable |= val_enable;
  i2c_write(0x39, APDS9960_ENABLE, enable);

  mSleep(500);

  //return true;

};

uint32_t leer_rojo (void)
{

  uint32_t RL = i2c_read(0x39, APDS9960_RDATAL);
  uint32_t RH = i2c_read(0x39, APDS9960_RDATAH);
  uint32_t R = RL + (RH << 8);

  return R;
};


void ver_entero_consola(int numero){
    uint8_t c = numero;
    uint8_t contador = 1; 
    
     while(c/10>0)
    {
        c=c/10;
        contador++;
    };
    
    char buffer[contador];
    
    itoa(numero,buffer);
    
    uart_putstr(buffer);


};





















int main(void)
{	
        //uint8_t i1,i2;
        
	sec_on_display();
	clear_GDRAM();
	init_display();
	mSleep(4000);
	/*
	initPH();
        habilitar_PH_sensor();
        
        uint32_t rojo = leer_rojo();
     
        i1 = rojo & 0xFF;
        i2 = (rojo >> 8) & 0xFF;
        mSleep(1000);*/
/*
        ver_entero_consola(i2);
        ver_entero_consola(i1);
        uart_putstr("\r\n");
        */
        mSleep(4000);
	clear_GDRAM();
	principal_display(04, 20, 17, 7);
	clear_GDRAM();
	principal_display(04, 20, 17, 7);
	clear_GDRAM();
	principal_display(04, 20, 17, 7);
        	
    	return 0;
}

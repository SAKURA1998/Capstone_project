#include "led.h"
#include "delay.h"
#include "sys.h"
#include "key.h"
#include "usart.h"
#include "exti.h"
#include "wdg.h"
#include "timer.h"
#include "pwm.h"
#include "lcd.h"
#include "dac8554.h"


int main(void)
{
	u8 key=0;
	u8 x=0;
	
	SystemInit();
	delay_init(72);	     //—” ±≥ı ºªØ
	NVIC_Configuration();
	uart_init(115200);
	LED_Init();
	KEY_Init();
//	LCD_Init();
	DAC8554_Init();

	printf("DAC8554 test\r\n");

	DAC8554_SetVol(CH0, 4.0);
	DAC8554_SetVol(CH1, 1.0);	
	DAC8554_SetVol(CH2, 2.0);
	DAC8554_SetVol(CH3, 3.0);	
	while(1)
	{
		LED0=!LED0;
		delay_ms(1000);		
	}
}

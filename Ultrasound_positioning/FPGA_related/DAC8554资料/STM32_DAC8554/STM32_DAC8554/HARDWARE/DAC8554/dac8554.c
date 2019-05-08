#include "dac8554.h"

/* DAC8554 初始化 */
void DAC8554_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStructure ;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC|RCC_APB2Periph_GPIOB|RCC_APB2Periph_GPIOA,ENABLE);

	GPIO_InitStructure.GPIO_Pin = DAC8554_SCLK|DAC8554_DIN|DAC8554_SYNC;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(DAC8554_CONTROL_PORT,&GPIO_InitStructure);
	
	DAC8554_SCLK_SET;
	DAC8554_SYNC_SET;
}

/* DAC8554 写入24位数据
前8bit指令，后16bit数据
*/
void DAC8554_Write(unsigned long data)
{
	u8 i;
	DAC8554_SYNC_SET;
	DAC8554_SYNC_CLR; 
	for(i=0;i<24;i++)
	{
		DAC8554_SCLK_SET;			 
		if((data&0x800000)) DAC8554_DIN_SET;
		else DAC8554_DIN_CLR;
		DAC8554_SCLK_CLR;
		data<<=1;
	}
	DAC8554_SYNC_SET;
}

/* DAC8554 设置通道电压
ch:0-3
vol:电压v
*/
void DAC8554_SetVol(unsigned char ch, float vol)
{
	unsigned int temp;
	
	if(vol>VREF) vol=VREF;
	temp = vol/VREF*65535.0;
	temp = (ch<<16)|temp;
	
	DAC8554_Write(temp);
}


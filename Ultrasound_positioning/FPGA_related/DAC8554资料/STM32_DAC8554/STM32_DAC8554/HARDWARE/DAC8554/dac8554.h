#ifndef __DAC8554_H
#define __DAC8554_H
#include "stm32f10x.h"

/* DAC8554基准电压v */
#define VREF  4.5

/* DAC8554控制寄存器 */
#define CH0      0x10
#define CH1      0x12
#define CH2      0x14
#define CH3      0x16

/* DAC8554控制口 */
#define DAC8554_CONTROL_PORT  GPIOC
#define DAC8554_SCLK    GPIO_Pin_4
#define DAC8554_DIN     GPIO_Pin_1
#define DAC8554_SYNC	  GPIO_Pin_5  

#define DAC8554_SCLK_SET    GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_SCLK,Bit_SET)
#define DAC8554_SCLK_CLR    GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_SCLK,Bit_RESET)
#define DAC8554_DIN_SET     GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_DIN,Bit_SET)
#define DAC8554_DIN_CLR     GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_DIN,Bit_RESET)
#define DAC8554_SYNC_SET    GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_SYNC,Bit_SET)
#define DAC8554_SYNC_CLR    GPIO_WriteBit(DAC8554_CONTROL_PORT,DAC8554_SYNC,Bit_RESET)


void DAC8554_Init(void);
void DAC8554_SetVol(unsigned char ch, float vol);

#endif


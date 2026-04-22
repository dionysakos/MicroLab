#define F_CPU 16000000UL
#include<avr/io.h>
#include<util/delay.h>

int main()
{
DDRC=0xFF; //Set PORTB as output

while(1)
{
PORTC = 0x00;
_delay_ms(500);
PORTC = 0xFF;
_delay_ms(500);
}
}
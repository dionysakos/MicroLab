#include <avr/io.h>

void main(void){
    unsigned char x0,x1,x2,x3,input,or1,and3;
    DDRA = 0x00;
    DDRB = 0x55;
    while(1){
        input = PINA; 
        x0 = (input|(input>>1)) & 0x01;
        or1 = ((input>>2)|(input>>3)) & 0x01; 
        x2 = ((input>>4)&(input>>5)) & 0x01;
        and3 = ((input>>6)&(input>>7)) & 0x01;
        x1 = or1 & x0;
        x3 = and3 ^ x2;
        PORTB = (x0<<0)|(x1<<2)|(x2<<4)|(x3<<6);
    }
}



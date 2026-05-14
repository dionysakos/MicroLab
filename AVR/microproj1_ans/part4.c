#include <avr/io.h>

void main(void){
    DDRA = 0x00;
    PORTA = 0xFF;
    DDRC = 0xFF;
    unsigned char temp,cnt,output;
    while(1){
        temp =PINA;
        if(temp>99) {PORTC = 0xFF;continue;}
        cnt=0;
        output=0;
        while(temp>=10){
            temp-=10;
            cnt++;
        }
        output=cnt<<4; //bcd : in upper nibble we want decades
        output|=temp; //in lower nibble we want units
        PORTC = output;
    }
}
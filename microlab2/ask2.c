#define F_CPU 16000000UL
#include "avr/io.h"
#include "util/delay.h"
#include "avr/interrupt.h"

volatile  int counter = 4000;


ISR(INT0_vect){
    if(counter<4000){
        counter = -1000;
    }
    else counter =0;
    EIFR = (1<<INTF0);
}
int main()
{
    DDRB = (1<<PB1) | (1<<PB2) | (1<<PB3);
    PORTB &= ~((1<<PB1)|(1<<PB2)|(1<<PB3));
    DDRD &= ~(1<<PD2); // Set PD2 as input
    PORTD |= (1<<PD2); // Enable pull-up resistor
    // ------------------------------------------
    EICRA = (1<<ISC01) | (0<<ISC00);
    EIMSK = (1<<INT0);
    sei();
    while(1){
        if(counter<4000){
            if(counter<0){
                PORTB |= ((1<<PB1)|(1<<PB2)|(1<<PB3));
            }
            else{
                PORTB &= ~((1<<PB1)|(1<<PB3));
                PORTB |= (1<<PB2);
            }
            ++counter;
            _delay_ms(1);
        }
        // Idle state
        else{
            PORTB &= ~(1<<PB2);
        }
    } 
    return 0; 
}
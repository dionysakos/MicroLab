#define F_CPU 16000000UL
#include "avr/io.h"
#include "util/delay.h"
#include "avr/interrupt.h"

volatile int counter = 4000; // 2 bytes 


ISR(INT0_vect){
    if(counter<4000){
        counter = -1000;
    }
    else counter =0;
    EIFR = (1<<INTF0);
}

int main()
{
    DDRB = (1<<PB1) | (1<<PB2) | (1<<PB3); // Set PB1, PB2, PB3 as output
    PORTB &= ~((1<<PB1)|(1<<PB2)|(1<<PB3)); // Initialize PB1, PB2, PB3 to LOW, keep other pins unchanged
    DDRD &= ~(1<<PD2); // Set PD2 as input
    PORTD |= (1<<PD2); // Enable pull-up resistor
   
    EICRA = (1<<ISC01) | (0<<ISC00); // Set INT0 to trigger on falling edge
    EIMSK = (1<<INT0); // Enable INT0
    sei(); // Enable global interrupts

    uint8_t sreg;
    int curr_cnt;

    while(1){
        /* 
        *
        * we need to create a "software" manual lock, in order to to read & modify the global
        * variable "counter" without any race condition.
        * We can achieve atomic access using the following approach:
        * Disable interrupts before accessing the counter variable, and re-enable them afterward. 
        * This ensures that the ISR cannot interrupt the main loop while it is modifying or reading 
        * the counter variable, preventing any race conditions which could lead to inconsistent 
        * or incorrect behavior.
        * We can implement this by using the cli() (after saving SREG register first)
        * and then restoring the SREG register after modifying/reading  the counter variable.
        * 
        */

       // Atomic Read:
       sreg = SREG;
       cli();
       curr_cnt = counter;
       SREG = sreg;

        if(curr_cnt<4000){
            if(curr_cnt<0){
                PORTB |= ((1<<PB1)|(1<<PB2)|(1<<PB3));
            }
            else{
                PORTB &= ~((1<<PB1)|(1<<PB3));
                PORTB |= (1<<PB2);
            }

            // Atomic Write:
            sreg = SREG;
            cli();
            ++counter;
            SREG = sreg;

            _delay_ms(1);
        }
        // Idle state
        else{
            PORTB &= ~(1<<PB2);
        }
    } 
    return 0; 
}
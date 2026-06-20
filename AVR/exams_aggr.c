/* Aggregated AVR C examples from lec_10_examples and lec_11_12_examples */
/* Generated to provide a single GitHub-visible aggregate source file. */

/* ===== BEGIN FILE: AVR/lec_11_12_examples/int0_handling.c ===== */
#include <avr/io.h>
#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/interrupt.h>

ISR(INT0_vect){
    PORTC = 0xFF;
    _delay_ms(2000);
    PORTC = 0x00;
    EIFR = (1<<INTF0);
}

ISR(INT1_vect){
    PORTC = 0xFF;
    _delay_ms(3000);
    PORTC = 0x00;
    EIFR = (1<<INTF1);
}

int main(){
    //mask and control in main
    EICRA = (1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10);
    EIMSK = (1<<INT0)|(1<<INT1);
    sei();
    DDRB = 0xFF;
    DDRC = 0xFF;
    PORTC = 0x00;
    while(1){
        PORTB = 0x00;
        _delay_ms(500);
        PORTB = 0xFF;
        _delay_ms(500);
    }
    return 0;
}



/* ===== END FILE: AVR/lec_11_12_examples/int0_handling.c ===== */

/* ===== BEGIN FILE: AVR/lec_11_12_examples/lec12_2.c ===== */
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
/* ===== END FILE: AVR/lec_11_12_examples/lec12_2.c ===== */


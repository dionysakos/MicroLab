.include "m328PBdef.inc"

; handling leds and buttons

.def temp = r16

.org $0000
    rjmp init

.org $0200

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRD, temp
    ser temp
    out PORTD, temp

    out DDRB, temp
    out PORTB, temp ; turn off leds - negative logic 

read:
   sbis PIND,0
   rjmp led_0_on
   sbis PIND,1
   rjmp led_1_on
   sbis PIND,7
   rjmp led_7_on
   in temp, PIND
   andi temp,$7C
   cpi temp, $7C
   brne led_2_6_on
led_no_button_on:
    rjmp read
led_0_on:
    ldi temp, $FE
    out PORTB, temp
    rjmp read
led_1_on:
    ldi temp, $FD
    out PORTB, temp
    rjmp read
led_2_6_on:
    ldi temp, $03
    out PORTB, temp
    rjmp read
led_7_on:
    ldi temp, $FF
    out PORTB, temp
    rjmp read


   
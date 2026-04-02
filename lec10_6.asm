.include "m328PBdef.inc"

.def temp = r16 
.def delay = r17
.def delay2 = r18

main:
    clr temp
    out DDRD, temp
    ser temp
    out PORTD, temp ;;  pull up on D
    out DDRB, temp
    ;; init all leds off
    out PORTB, temp
    ldi delay, $FF
    ldi delay2, $FF
loop:
    ;;pin0
    sbis PIND, 0
    inc temp
    ;;pin1
    sbis PIND, 1
    dec temp
    ;;pin2
    sbis PIND, 2
    ror temp
    ;;pin3
    sbis PIND, 3
    rol temp
    ;;pin4
    sbis PIND, 4
    com temp
    ;;pin5
    sbis PIND, 5
    neg temp
    ;;pin6
    sbis PIND, 6
    swap temp
    ;;pin7
    sbis PIND, 7
    ldi temp, $F0

    out PORTB, temp

dly:
    dec delay
    brne dly
    dec delay2
    brne dly
    rjmp loop
         




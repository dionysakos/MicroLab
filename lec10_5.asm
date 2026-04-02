;; playing with delays

.include "m328PBdef.inc"
.def delay = r17
.def delay2 = r18
.def temp = r16

main:
    ser temp
    out DDRB, temp

dly:
    dec delay
    brne dly
    dec delay2
    brne dly
    ldi temp, $00
    out PORTB, temp ;; turn on the led

dly2:
    dec delay
    brne dly2
    dec delay2
    brne dly2
    ldi temp,$FF
    out PORTB, temp ;; turn off the led
    rjmp main
 
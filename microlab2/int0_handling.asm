.include "m328PBdef.inc"

.def temp = r16

.org $000
    rjmp reset

.org $002
    rjmp int0_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    clr temp
    out DDRD, temp
    ser temp
    out DDRB, temp

    ldi temp, (1<<ISC01)|(1<<ISC00) ; Rising edge 
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

    sei

    clr temp
    out PORTB, temp

main:
    rjmp main

int0_handler:
    push r25
    in r25, SREG
    push r25
    push temp
    ;---
    ; when INT0 is triggered,set all the bits in PORTB
    ldi temp, $FF
    out PORTB, temp
    ; ---
    ;delay
    ldi r24,low(16*500)
    ldi r25,high(16*500)
delay1:
    ldi temp, 249
delay2:
    dec temp
    brne delay2
    sbiw r24,1
    brne delay1
    ;---

    clr temp
    out PORTB, temp

    ldi r24,(1<<INTF0)
    out EIFR, r24

    pop temp
    pop r25
    out SREG, r25
    pop r25
    reti














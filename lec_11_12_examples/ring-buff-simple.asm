.include "m328PBdef.inc"

.def temp = r16
.def data = r17
.def idx = r18

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
    out DDRC, temp
    ser temp
    out PORTC, temp

    out DDRB, temp
    clr temp
    out PORTB, temp ; all leds off

    ldi temp, (1<<ISC01)|(0<<ISC00)
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

    sei

    ldi xh, high(buffer)

    clr idx 
main:
    in data, PINC

    ldi xl, low(buffer)
    add xl,idx
    st x, data

    inc idx
    andi idx, $0F ; idx = idx % 16 - wrap around the buffer

    rjmp main

int0_handler:
    push temp
    push r0
    in r0, sreg
    push r0

    cpi data, $80
    brsh sell
buy_hold:
    ldi temp, $00
    rjmp epilog
sell:
    ldi temp, $FF
epilog:
    out PORTB, temp 
    
    ldi temp, (1<<INTF0)
    out EIFR, temp

    pop r0
    out sreg, r0
    pop r0
    pop temp
    reti


.dseg
.org $0100
buffer:
    .byte 16 ; 16 byte ring buffer
.exit 


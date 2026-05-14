.include "m328PBdef.inc"

.def A = r16
.def B = r17
.def C = r18
.def D = r19
.def E = r20
.def temp = r22

.org $000
    rjmp init

.org $100
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

main:
    in temp, PIND
    mov A, temp
    lsr temp
    mov B, temp
    com B
    lsr temp
    mov C, temp
    lsr temp
    mov D, temp
    lsr temp
    mov E, temp
    or A,B
    and C,D
    or C,E
    and A,C
    andi A, $01
    lsl A
    lsl A
    lsl A
    lsl A
    out PORTB, A
    rjmp main

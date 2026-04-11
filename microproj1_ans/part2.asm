; this is part 2

; Dionysis Katsetis el23005

.include "m328pdef.inc"
.def temp = r16
.def help = r17
.def comp = r18
.def cnt = r19
.def bits_left = r20

.org 0x000
    rjmp init

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRB, temp
    ser temp
    out PORTB, temp
    out DDRD, temp

read:
    clr cnt
    clr help
    ldi bits_left, 7 ; we want 7 comparisons 
    in temp, PINB

main:
    lsr temp
    rol help ; now help has the value of C in bit 0
    mov comp, temp
    eor comp, help
    sbrc comp, 0
    inc cnt
next:
    dec bits_left
    brne main

check:
    cpi cnt, 0
    brne prepare
    clr help
    out PORTD, help
    rjmp read

prepare:
    ser help
loop:
    lsr help
    dec cnt
    brne loop

outp:
    com help
    out PORTD, help
    rjmp read









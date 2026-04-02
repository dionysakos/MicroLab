.include "m328PBdef.inc"
.include "delays.inc"
.def temp = r16
.def walk = r17

.org $000
    rjmp init
.org $200

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    ser temp
    out DDRD, temp

main:
    ldi walk, $01
    out PORTD, walk 
walk_left:
    clc
    rcall delay_10
    rol walk
    out PORTD, walk
    cpi walk,$80 
    brne  walk_left
    rcall delay_5
walk_right:
    clc
    rcall delay_10
    ror walk
    out PORTD,walk
    cpi walk,$01
    brne walk_right
    rcall delay_5
    rjmp walk_left
    












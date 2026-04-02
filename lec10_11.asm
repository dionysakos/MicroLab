.include "m328def.inc"
.include "delays.inc"

.def S  = r17
.def M = r19
.def cnt = r18

.org $000
    rjmp init
.org $200

init:
    ldi S,low(ramend)
    out spl, S
    ldi S, high(ramend)
    out sph, S
    clr S
    out DDRB, S
    ser S
    out PORTB, S
    ldi S, $01
    out DDRD, S

idle:
    clr M
    out PORTD, M ; we just dont move 

read:
    sbic PINB, 0
    rjmp read ; we dont move until s=0

    ldi M, $01
    out PORTD, M ; we are moving
move:
    sbis PINB, 0
    rjmp move ; we are moving as s = 0
reset:
    ldi cnt, 100 ;s=1 so we have to count
wait:
    rcall DSEC
    dec cnt
    breq idle ; 10 sec are passed and s still is 1 so we have to stop moving
    sbis PINB,0 ;if s = 1 we continue to count
    rjmp move ; s=0 so we have to keep moving and reset the timer when s = 1
    rjmp wait ; we continue to count as s = 1
















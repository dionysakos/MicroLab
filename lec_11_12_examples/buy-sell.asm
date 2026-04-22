.include "m328PBdef.inc"

; Buy low, sell high

.def temp = r16
.def output = r17
.def data = r18

.org $000
    rjmp reset

.org $004
    rjmp int1_handler

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
    out PORTB, temp ;all leds off

    ldi temp, (1<<ISC11)|(0<<ISC10)
    sts EICRA, temp

    ldi temp, (1<<INT1)
    out EIMSK, temp

    sei

    clr output

    ldi xl, low(Buy_Table)
    ldi xh, high(Buy_Table)

    ldi yl, low(Sell_Table)
    ldi yh, high(Sell_Table)

main:
    in data, PINC
    rjmp main

int1_handler:
    push r22
    in r22, sreg
    push r22 
    push temp   
    

    cpi data, $40
    brlo buy
    cpi data, $C0
    brsh sell
hold:
    clr temp
    rjmp epilog
buy:
    ldi temp,$0F
    st x+, data
    rjmp epilog
sell:
    ldi temp, $F0
    st y+, data

epilog:
    out PORTB, temp
    
    ldi temp, (1<<INTF1)
    out EIFR, temp

    pop temp
    pop r22
    out sreg, r22
    pop r22

    reti 


.dseg
.org $0150
Buy_Table:
.org $0250
Sell_Table:
.exit



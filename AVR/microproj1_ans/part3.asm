;This is part 3

.include "m16def.inc"

.def x0 = r16
.def x1 = r17
.def x2 = r18
.def x3 = r19
.def or23 = r20
.def and67 = r21
.def temp = r22
.def output = r23

.org 0x00
    rjmp init

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    clr temp
    out DDRA, temp
    ldi temp, $55
    out DDRB, temp

read:
    in temp, PINA
    mov x0, temp 
    lsr temp
    or x0, temp
    andi x0, $01 ;calculate x0
    lsr temp
    mov or23, temp
    lsr temp
    or or23, temp
    andi or23, $01 ;calculate or23 which is the or of A1,B1
    lsr temp
    mov x2, temp
    lsr temp
    and x2,temp
    andi x2, $01 ;calculate x2
    lsr temp
    mov and67, temp
    lsr temp
    and and67, temp
    andi and67, $01 ;calculate and67 which is the and of A3,B3
    mov x1,or23
    and x1,x0 ;calculate x1 which is the and of x0 and or23
    mov x3,and67
    eor x3,x2 ;calculate x3 which is the xor of x2 and and67
    mov output,x0 ;the x0 is the LSB of the output
    lsl x1
    lsl x1
    or output,x1 ;the x1 is the 2 bit of the output
    swap x2 ;the x2 is the 4 bit of the output 
    or output,x2 
    swap x3 
    lsl x3
    lsl x3 ; the x3 is the 6 bit of the output
    or output,x3
    out PORTB, output
    rjmp read




    






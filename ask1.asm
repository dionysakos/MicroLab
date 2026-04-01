.include "m328def.inc"

.def temp = r16
.def temp2 = r23
.def A = r17
.def B = r18
.def C = r19
.def D = r20
.def F0  = r21
.def F1  = r22

.org $000
    rjmp init

.org $100

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    clr temp
    out DDRB, temp
    ser temp
    out PORTB, temp ;pull up on
    ldi temp, $03
    out DDRC, temp

loop:
    in temp, PINB
    mov A, temp
    lsr temp
    mov B, temp
    lsr temp
    mov C, temp
    lsr temp
    mov D, temp 
    com A; A'
    mov temp, A ; temp = A'
    com B ;B'
    com D; D'
    and temp,B ;  temp =  A'*B'
    com B ;B
    mov temp2, B ; temp2 = B
    and temp2,D ; temp2 = B*D'
    or temp,temp2 ; temp = A'*B' + B*D'
    mov F0, temp ; F0 = A'*B' + B*D'
    com D ; D
    mov temp, D
    or temp, A ; temp = A' + D
    mov temp2, C
    com B
    or temp2, B ; temp2 = B' + C
    and temp,temp2
    mov F1, temp ; F1 = (A' + D)(B' + C)
    andi F0,$01
    andi F1,$01
    lsl F1
    or F0,F1
    out PORTC, F0
    rjmp loop


    
    





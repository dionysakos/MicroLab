; this is part 2

; Dionysis Katsetis el23005

.include "m16def.inc"
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
    clr cnt ;we clear the counter
    clr help ;we clear the help reg to store the value of C in bit 0
    ldi bits_left, 7 ; we want 7 comparisons  
    in temp, PINB  

main:
    lsr temp ; we move the bit 0 of our input  to flag C of sreg
    rol help ; now help has the value of C in bit 0
    mov comp, temp ; we copy temp to comp to compare it with the next bit
    eor comp, help ;we compare the bit we just read with the previous one, using xor to check if they are different
    sbrc comp, 0 
    inc cnt ; if they are different, we have a switch and increment the counter
next:
    dec bits_left
    brne main

check:
    cpi cnt, 0  
    brne prepare ;if we have at least one switch, we prepare the output 
    clr help ;if we got here we have no switch, so we clear help to output 0
    out PORTD, help
    rjmp read

prepare:
    ser help ; we set all bits of help to 1
loop:
    lsr help  ; we shift right help to have the correct number of bits set to 0
    dec cnt 
    brne loop

outp:
    com help ; we complement help to have the correct number of bits set to 1
    out PORTD, help
    rjmp read









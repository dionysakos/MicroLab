.include "m328PBdef.inc"

.def temp = r16
.def cnt = r17
.def output = r18
.equ N15 = 15

.org $000
    rjmp reset
.org $004
    rjmp int1_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr cnt

    ldi temp , (1<<1)|(1<<2)|(1<<3)|(1<<4)
    out DDRC, temp
  
    clr temp
    out PORTC, temp

    clr temp
    out DDRD, temp

    ldi temp, 0xFF
    out PORTD, temp

    ldi temp, (1<<ISC11)|(0<<ISC10)
    sts EICRA, temp
  
    ldi temp, (1<<INT1)
    out EIMSK, temp

    sei
     
main:
    mov output, cnt
    lsl output
    in temp, PORTC
    andi temp, $E1
    or temp, output
    out PORTC, temp
    rjmp main


int1_handler:
    push temp
    in temp, sreg
    push temp
    push r24
    push r25
    sbic PIND, 0
    inc cnt
    andi cnt, $0F ;keep only the last 4 bits, so it wraps around after 15
    ;delay of 600ms
    ;cpu has frequency of 16MHz
    ldi r24, low(16*600)
    ldi r25, high(16*600)
delay1:
    ldi temp, 249 ;1cc
delay2:
    dec temp ;1cc
    nop ;1cc 
    brne delay2 ;1cc if not taken, 2cc if taken
    sbiw r24, 1 ;2cc
    brne delay1 ;1cc if not taken, 2cc if taken
    
    ldi temp, (1<<INTF1)
    out EIFR, temp ;clear interrupt 1 flag

    pop r25
    pop r24
    pop temp
    out sreg, temp
    pop temp

    reti



    


    
    
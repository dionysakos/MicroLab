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

    ;set PC1-PC4 as output and initially turn off all LEDs (positive logic)
    ldi temp , (1<<1)|(1<<2)|(1<<3)|(1<<4)
    out DDRC, temp ;set PC1-PC4 as output
    clr temp
    out PORTC, temp 

    ; set PORTD as input with pull-up resistors
    out DDRD, temp 
    ldi temp, 0xFF
    out PORTD, temp

    ; we want to trigger on the falling edge of PD3 (INT1)
    ldi temp, (1<<ISC11)|(0<<ISC10)
    sts EICRA, temp 
  
    ; enable INT1 (PD3)
    ldi temp, (1<<INT1)
    out EIMSK, temp

    sei ;enable global interrupts
     
main:
    mov output, cnt
    lsl output
    in temp, PORTC ; save current state of PORTC
    andi temp, $E1 ; prepare to set bits 1-4 by clearing them first (1110 0001)
    or temp, output ; set bits 1-4 according to cnt<<1
    out PORTC, temp ; update PORTC with new LED states in bits 1-4
    rjmp main


int1_handler:
    ;save SREG and used registers
    push temp
    in temp, sreg
    push temp
    push r24
    push r25

    sbic PIND, 0 ;check if PD0 is low (negative logic - button press)
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
    out EIFR, temp ;clear INT1 flag

    ;restore SREG and used registers
    pop r25
    pop r24
    pop temp
    out sreg, temp
    pop temp

    reti



    


    
    
.include "m328PBdef.inc"

; Matching Engine

.def temp = r16
.def data = r17
.def offs = r18

.org $000
    rjmp reset
.org $002
    rjmp int0_handler
.org OVF0addr        
    rjmp timer0_ovf_handler

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
    out PORTB, temp

    ldi temp, (1<<ISC01)|(0<<ISC00)
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

     ;timer0 setup
    ldi temp, (1<<CS02)|(1<<CS00)
    out TCCR0B, temp

    ldi temp, (1<<TOIE0)
    sts TIMSK0, temp

    sei

    clr offs

    ldi xh, high(buffer)

main:
    andi offs, $1F
    ldi xl, low(buffer)
    add xl, offs

    in data, PINC
    st x, data
    inc offs

    clr temp
    out TCNT0, temp

    rjmp main

int0_handler:
    push temp
    in temp, sreg
    push temp
    push r26
    push r27
    push data
    ldi xh, high(buffer)

    ;P_t
    mov temp,offs
    dec temp
    andi temp, $1F
    ldi xl, low(buffer)
    add xl, temp
    ld data, x

    ; P_t-1
    dec temp
    andi temp, $1F
    ldi xl, low(buffer)
    add xl, temp
    ld temp, x

    cp data, temp
    brlo buy
sell: ; down drift
    ldi temp, $F0
    rjmp epilogue
buy: ; up drift
    ldi temp, $0F
epilogue:
    out PORTB, temp

    ldi temp, (1<<INTF0)
    out EIFR, temp

    pop data
    pop r27
    pop r26
    pop temp
    out sreg, temp
    pop temp
    reti

timer0_ovf_handler:
    push temp
    in temp, sreg
    push temp

    ;error message
    ldi temp, $AA
    out PORTB, temp

    ldi temp, (1<<TOV0)
    out TIFR0, temp

    pop temp
    out sreg, temp
    pop temp

    reti

.dseg
.org $0200
buffer: .byte 32
.exit




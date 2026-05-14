; this is par4

.include "m16def.inc"

.def temp = r16
.equ N = 100
.def cnt = r17
.def output = r18

.org $000
    rjmp init

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRA, temp
    ser temp
    out PORTA, temp ; pull up on
    out DDRC, temp

read:
    in temp, PINA
    cpi temp,100
    brlo valid
    ldi temp, $FF 
    out PORTC, temp ; error, all 1s
    rjmp read

valid: ; we have a valid input in pin A
    cpi temp, $0A ; if less than 10, skip decades
    brlo outp
    clr cnt ;counter for decades
decades:
    inc cnt 
    subi temp, 10 
    cpi temp,10 
    brsh decades ; loop until less than 10
outp: ; The temp now has the units digit, and cnt has the decade count
    clr output
    swap cnt   ; BCD, we want the decade count in the high nibble
    or output, cnt
    or output, temp
    out PORTC, output
    rjmp read





















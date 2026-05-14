.include "m328PBdef.inc"

.def temp = r20

clr temp
out DDRD, temp
ser temp
out PORTD, temp ;; D is input with pull up on

out DDRB, temp ;; B is output

loop:
    ldi zl, low(lut_led<<1)
    ldi zh, high(lut_led<<1)
    in temp, PIND
    cpi temp,$FF
    breq read    

incr: ;; the pin d is not all 1 so we need to check which one is 0  
    adiw zl,1 ;; so we must increment z to move on from the current value (which is initally all 1 so no led is on)
    ror temp ;; check which one is 0 by checking C after rotating
    brlo incr

read:
    lpm
    out PORTB, r0
    rjmp loop

lut_led:
    .dw $FEFF
    .dw $F8FC
    .dw $E0F0
    .dw $80C0
    .dw $0000



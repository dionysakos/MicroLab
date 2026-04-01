.include "m328def.inc"

.def new  = r16
.def old  = r17

    clr new
    out DDRD, new
    ser new
    out PORTD, new
init:
    ldi xl, $60
    ldi xh, $00
main:
    in old, PIND
    st X+, old
check:
    in new, PIND
    cp new, old
    breq check
change:
    st X+, new
    mov old,new
    cpi xl,$51
    brne check
    cpi xh,$01
    brne check
    ldi xl, $60
    ldi xh, $00
    rjmp check



.include "m328PBdef.inc"

.def cnt = r16
.equ loc_odd = $0060
.equ loc_even = $0074
.def temp = r17

.cseg
.org 0
    rjmp main
.org $100   

main:
    ldi cnt,20
    ldi zl,low(table<<1)
    ldi zh,high(table<<1)
    ldi xl,low(loc_odd)
    ldi xh,high(loc_odd)
    ldi yl,low(loc_even)
    ldi yh,high(loc_even)

loop:
    lpm temp,Z+
    sbrc temp,0
    rjmp odd
even:
    st Y+, temp
    rjmp next
odd:
    st X+, temp
next:
    dec cnt ;; dont check Z because we know we have 20 values
    brne loop

end:
    rjmp end

.cseg
table:
    .DW 0x0100,0x0706,0x1713,0x3326,0x27C6
    .DW 0x5042,0x7A61,0xA2F1,0xE0D7,0x89FD
.exit



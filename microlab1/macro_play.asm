#include "m328PBdef.inc"
.def temp = r16

.macro TestMacro
    ldi temp,@0
    inc temp
    breq over
macro_jump:
    .endmacro

.org 0x000
    rjmp main

.org 0x200

main:
    ser temp
    out DDRB, temp

    TestMacro 0xFF

outp:
    out PORTB, temp
loop:
    rjmp loop

over:
    ser temp
    out PORTB, temp
    rjmp loop


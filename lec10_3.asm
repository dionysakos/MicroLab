.include "m32def.inc"

.def max = r22
.def min = r23
.def i = r24
;; .equ N = 0x10
.def temp = r25

clr i
ldi zl,low(array<<1)
ldi zh,high(array<<1)

lpm temp, Z+
mov max,temp
mov min,temp

inc i

loop:
    lpm temp, Z+ ;; low or high, depends on the value of Z
    cp temp,max
    brcs skipmax ;; its importan to implement negative branching -> most used case to be straightforward
    mov max,temp
    rjmp skipmin
skipmax: 
    cp temp,min
    brcc skipmin
    mov min,temp
skipmin:
    inc i
    breq end
    rjmp loop

end:
    rjmp end

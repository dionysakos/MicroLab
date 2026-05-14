;
;Dionysis Katsetis el23005
;
; part 1

.include "m16def.inc"

.def temp = r22
.def bit_left = r17
.def len = r18
.def temp2 = r19


.org 0x0000
  rjmp main

; This is part a
main:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    ldi xl, low($0200)
    ldi xh, high($0200)

    ldi temp, $FF
loop_a:
    st x+, temp 
    dec temp 
    brne loop_a
    st x, temp

; This is part b

clr r14 ;; counter for the number of 0s
clr r15 ;; counter for the number of 0s

ldi xl,low($0200) 
ldi xh,high($0200)
ldi len, 0


loop_b:
    ld temp, x+
    ldi bit_left, 8
bit_loop:
    lsr temp
    brcs next_b
    inc r14 
    brne next_b
    inc r15 ; if we get here we got 256 0s, so r14 is overflowed and we need to increment r15
next_b:
    dec bit_left
    brne bit_loop
    inc len
    brne loop_b

done_b:
    ;end of part b

; This is part c

clr r16
ldi xl, low($0200)
ldi xh, high($0200)
clr len


loop_c:
    ld temp, x+
    cpi temp, $10
    brlo next_c
    cpi temp, $81
    brsh next_c
    inc r16

next_c:
    inc len
    brne loop_c

done_c:
    ;end of part c 
    rjmp done_c ; infinite loop to stop the program from doing anything else


; end of part 1















   

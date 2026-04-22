.include "m328PBdef.inc"

; Sort numbers in ascending Order
;Bubble Sort Algorithm

.equ loc = $0060

.def temp = r16
.def temp2 = r17
.def cnt = r18



.org 0x0000
    rjmp init

init:
    ldi xl, low(loc)
    ldi xh, high(loc)

    ldi cnt, 0
    clt 

read:
    ld temp, x+
    ld temp2,x

    cp temp2, temp
    brsh next
swap_nums:
    st x, temp
    st -x, temp2
    adiw xl,1
    set 

next:
    dec cnt
    brne read
    brts init

end:
    rjmp end









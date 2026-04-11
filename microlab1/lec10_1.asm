.include "m328PBdef.inc"

; linear search

.def fnd = r22
.def num = r20
.def len = r21
.def temp = r23

;get num

clr temp
out DDRD, temp
ser temp
out PORTD, temp ;pull up resistors on
in num, PIND

loop:
    ld temp, X+
    cp temp,num
    breq found
    dec len
    brne loop
    rjmp notfound

notfound:
    clr fnd
    rjmp end

found: 
    ldi fnd,1 
    sbiw r26,1 ;

end:
    nop
    


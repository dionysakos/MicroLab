.include "m328PBdef.inc"

.def count = r22
.def num = r20
.def len = r21
.def temp = r23

clr num
out DDRD, num
ser num
out PORTD, num
in num, PIND
clr count

loop:
    ld temp, X+
    cp temp,num
    brne notfound
    inc count

notfound:
    dec len
    brne loop
    rjmp end

end:
    rjmp end

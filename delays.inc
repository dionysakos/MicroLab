.equ C1 = 48
.equ C2 = 110
.equ C3 = 100
.def delay = r23
.def delay2 = r24

.org $100

DSEC:
    push r20 ;2cc
    push r21 ;2cc
    push r22 ;2cc

    ldi r20, C1  ;1cc       
loop_outer:
    ldi r21, C2  ;1cc      
loop_middle:
    ldi r22, C3 ;1cc        
loop_inner:
    dec r22  ;1cc       
    brne loop_inner   ;2cc and  1cc in the end  
    
    dec r21   ;1cc         
    brne loop_middle   ;2cc and 1cc in the end
    
    dec r20   ;1cc        
    brne loop_outer ;2cc and 1cc in the end    

    pop r22 ;2cc
    pop r21 ;2cc
    pop r20 ;2cc
    ret  ;4cc

; Total cc = 3*C1*C2*C3 + 3*C1*C2 + 3*C1 +16 

ldi delay, 10
ldi delay2, 5

delay_10:
    ldi delay, 10
delay_10_loop:
    rcall DSEC
    dec delay
    brne delay_10_loop
    ldi delay, 10
    ret

delay_5:
    ldi delay2, 5
delay_5_loop:
    rcall DSEC
    dec delay2
    brne delay_5_loop
    ldi delay2, 5
    ret



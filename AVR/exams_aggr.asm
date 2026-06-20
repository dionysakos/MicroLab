; Aggregated AVR assembly examples from lec_10_examples and lec_11_12_examples
; Generated to provide a single GitHub-visible aggregate source file.

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_1.asm =====
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
    


; ===== END FILE: AVR/lec_10_examples/lec10_1.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_10.asm =====
.include "m328PBdef.inc"

; handling leds and buttons

.def temp = r16

.org $0000
    rjmp init

.org $0200

init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRD, temp
    ser temp
    out PORTD, temp

    out DDRB, temp
    out PORTB, temp ; turn off leds - negative logic 

read:
   sbis PIND,0
   rjmp led_0_on
   sbis PIND,1
   rjmp led_1_on
   sbis PIND,7
   rjmp led_7_on
   in temp, PIND
   andi temp,$7C
   cpi temp, $7C
   brne led_2_6_on
led_no_button_on:
    rjmp read
led_0_on:
    ldi temp, $FE
    out PORTB, temp
    rjmp read
led_1_on:
    ldi temp, $FD
    out PORTB, temp
    rjmp read
led_2_6_on:
    ldi temp, $03
    out PORTB, temp
    rjmp read
led_7_on:
    ldi temp, $FF
    out PORTB, temp
    rjmp read


   
; ===== END FILE: AVR/lec_10_examples/lec10_10.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_11.asm =====
.include "m328PBdef.inc"
.include "delays.inc"

.def S  = r17
.def M = r19
.def cnt = r18

.org $000
    rjmp init
.org $200

init:
    ldi S,low(ramend)
    out spl, S
    ldi S, high(ramend)
    out sph, S
    clr S
    out DDRB, S
    ser S
    out PORTB, S
    ldi S, $01
    out DDRD, S

idle:
    clr M
    out PORTD, M ; we just dont move 

read:
    sbic PINB, 0
    rjmp read ; we dont move until s=0

    ldi M, $01
    out PORTD, M ; we are moving
move:
    sbis PINB, 0
    rjmp move ; we are moving as s = 0
reset:
    ldi cnt, 100 ;s=1 so we have to count
wait:
    rcall DSEC
    dec cnt
    breq idle ; 10 sec are passed and s still is 1 so we have to stop moving
    sbis PINB,0 ;if s = 1 we continue to count
    rjmp move ; s=0 so we have to keep moving and reset the timer when s = 1
    rjmp wait ; we continue to count as s = 1
















; ===== END FILE: AVR/lec_10_examples/lec10_11.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_2.asm =====
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

; ===== END FILE: AVR/lec_10_examples/lec10_2.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_3.asm =====
.include "m328PBdef.inc"

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

; ===== END FILE: AVR/lec_10_examples/lec10_3.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_4.asm =====
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



; ===== END FILE: AVR/lec_10_examples/lec10_4.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_5.asm =====
;; playing with delays

.include "m328PBdef.inc"
.def delay = r17
.def delay2 = r18
.def temp = r16

main:
    ser temp
    out DDRB, temp

dly:
    dec delay
    brne dly
    dec delay2
    brne dly
    ldi temp, $00
    out PORTB, temp ;; turn on the led

dly2:
    dec delay
    brne dly2
    dec delay2
    brne dly2
    ldi temp,$FF
    out PORTB, temp ;; turn off the led
    rjmp main
 
; ===== END FILE: AVR/lec_10_examples/lec10_5.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_6.asm =====
.include "m328PBdef.inc"

.def temp = r16 
.def delay = r17
.def delay2 = r18

main:
    clr temp
    out DDRD, temp
    ser temp
    out PORTD, temp ;;  pull up on D
    out DDRB, temp
    ;; init all leds off
    out PORTB, temp
    ldi delay, $FF
    ldi delay2, $FF
loop:
    ;;pin0
    sbis PIND, 0
    inc temp
    ;;pin1
    sbis PIND, 1
    dec temp
    ;;pin2
    sbis PIND, 2
    ror temp
    ;;pin3
    sbis PIND, 3
    rol temp
    ;;pin4
    sbis PIND, 4
    com temp
    ;;pin5
    sbis PIND, 5
    neg temp
    ;;pin6
    sbis PIND, 6
    swap temp
    ;;pin7
    sbis PIND, 7
    ldi temp, $F0

    out PORTB, temp

dly:
    dec delay
    brne dly
    dec delay2
    brne dly
    rjmp loop
         




; ===== END FILE: AVR/lec_10_examples/lec10_6.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_7.asm =====
.include "m328PBdef.inc"

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



; ===== END FILE: AVR/lec_10_examples/lec10_7.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_8.asm =====
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



; ===== END FILE: AVR/lec_10_examples/lec10_8.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/lec10_9.asm =====
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









; ===== END FILE: AVR/lec_10_examples/lec10_9.asm =====

; ===== BEGIN FILE: AVR/lec_10_examples/logicalop.asm =====
.include "m328PBdef.inc"

.def A = r16
.def B = r17
.def C = r18
.def D = r19
.def E = r20
.def temp = r22

.org $000
    rjmp init

.org $100
init:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    clr temp
    out DDRD, temp
    ser temp
    out PORTD, temp
    out DDRB, temp

main:
    in temp, PIND
    mov A, temp
    lsr temp
    mov B, temp
    com B
    lsr temp
    mov C, temp
    lsr temp
    mov D, temp
    lsr temp
    mov E, temp
    or A,B
    and C,D
    or C,E
    and A,C
    andi A, $01
    lsl A
    lsl A
    lsl A
    lsl A
    out PORTB, A
    rjmp main

; ===== END FILE: AVR/lec_10_examples/logicalop.asm =====

; ===== BEGIN FILE: AVR/lec_11_12_examples/buy-sell-simple.asm =====
.include "m328PBdef.inc"

; Buy low, sell high

.def temp = r16
.def output = r17
.def data = r18

.org $000
    rjmp reset

.org $004
    rjmp int1_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRC, temp
    ser temp
    out PORTC, temp

    out DDRB, temp
    clr temp
    out PORTB, temp ;all leds off

    ldi temp, (1<<ISC11)|(0<<ISC10)
    sts EICRA, temp

    ldi temp, (1<<INT1)
    out EIMSK, temp

    sei

    clr output

    ldi xl, low(Buy_Table)
    ldi xh, high(Buy_Table)

    ldi yl, low(Sell_Table)
    ldi yh, high(Sell_Table)

main:
    in data, PINC
    rjmp main

int1_handler:
    push r22
    in r22, sreg
    push r22 
    push temp   
    

    cpi data, $40
    brlo buy
    cpi data, $C0
    brsh sell
hold:
    clr temp
    rjmp epilog
buy:
    ldi temp,$0F
    st x+, data
    rjmp epilog
sell:
    ldi temp, $F0
    st y+, data

epilog:
    out PORTB, temp
    
    ldi temp, (1<<INTF1)
    out EIFR, temp

    pop temp
    pop r22
    out sreg, r22
    pop r22

    reti 


.dseg
.org $0150
Buy_Table:
.org $0250
Sell_Table:
.exit



; ===== END FILE: AVR/lec_11_12_examples/buy-sell-simple.asm =====

; ===== BEGIN FILE: AVR/lec_11_12_examples/int0_handling.asm =====
.include "m328PBdef.inc"

.def temp = r16

.org $000
    rjmp reset

.org $002
    rjmp int0_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp
    clr temp
    out DDRD, temp
    ser temp
    out DDRB, temp

    ldi temp, (1<<ISC01)|(1<<ISC00) ; Rising edge 
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

    sei

    clr temp
    out PORTB, temp

main:
    rjmp main

int0_handler:
    push r25
    in r25, SREG
    push r25
    push temp
    ;---
    ; when INT0 is triggered,set all the bits in PORTB
    ldi temp, $FF
    out PORTB, temp
    ; ---
    ;delay
    ldi r24,low(16*500)
    ldi r25,high(16*500)
delay1:
    ldi temp, 249
delay2:
    dec temp
    brne delay2
    sbiw r24,1
    brne delay1
    ;---

    clr temp
    out PORTB, temp

    ldi r24,(1<<INTF0)
    out EIFR, r24

    pop temp
    pop r25
    out SREG, r25
    pop r25
    reti














; ===== END FILE: AVR/lec_11_12_examples/int0_handling.asm =====

; ===== BEGIN FILE: AVR/lec_11_12_examples/macro_play.asm =====
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


; ===== END FILE: AVR/lec_11_12_examples/macro_play.asm =====

; ===== BEGIN FILE: AVR/lec_11_12_examples/matcheng.asm =====
.include "m328PBdef.inc"

; Matching Engine

.def temp = r16
.def data = r17
.def offs = r18

.org $000
    rjmp reset
.org $002
    rjmp int0_handler
.org OVF0addr        
    rjmp timer0_ovf_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRC, temp
    ser temp
    out PORTC, temp

    out DDRB, temp
    clr temp
    out PORTB, temp

    ldi temp, (1<<ISC01)|(0<<ISC00)
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

     ;timer0 setup
    ldi temp, (1<<CS02)|(1<<CS00)
    out TCCR0B, temp

    ldi temp, (1<<TOIE0)
    sts TIMSK0, temp

    sei

    clr offs

    ldi xh, high(buffer)

main:
    andi offs, $1F
    ldi xl, low(buffer)
    add xl, offs

    in data, PINC
    st x, data
    inc offs

    clr temp
    out TCNT0, temp

    rjmp main

int0_handler:
    push temp
    in temp, sreg
    push temp
    push r26
    push r27
    push data
    ldi xh, high(buffer)

    ;P_t
    mov temp,offs
    dec temp
    andi temp, $1F
    ldi xl, low(buffer)
    add xl, temp
    ld data, x

    ; P_t-1
    dec temp
    andi temp, $1F
    ldi xl, low(buffer)
    add xl, temp
    ld temp, x

    cp data, temp
    brlo buy
sell: ; down drift
    ldi temp, $F0
    rjmp epilogue
buy: ; up drift
    ldi temp, $0F
epilogue:
    out PORTB, temp

    ldi temp, (1<<INTF0)
    out EIFR, temp

    pop data
    pop r27
    pop r26
    pop temp
    out sreg, temp
    pop temp
    reti

timer0_ovf_handler:
    push temp
    in temp, sreg
    push temp

    ;error message
    ldi temp, $AA
    out PORTB, temp

    ldi temp, (1<<TOV0)
    out TIFR0, temp

    pop temp
    out sreg, temp
    pop temp

    reti

.dseg
.org $0200
buffer: .byte 32
.exit




; ===== END FILE: AVR/lec_11_12_examples/matcheng.asm =====

; ===== BEGIN FILE: AVR/lec_11_12_examples/ring-buff-simple.asm =====
.include "m328PBdef.inc"

.def temp = r16
.def data = r17
.def idx = r18

.org $000
    rjmp reset

.org $002
    rjmp int0_handler

reset:
    ldi temp, low(ramend)
    out spl, temp
    ldi temp, high(ramend)
    out sph, temp

    clr temp
    out DDRC, temp
    ser temp
    out PORTC, temp

    out DDRB, temp
    clr temp
    out PORTB, temp ; all leds off

    ldi temp, (1<<ISC01)|(0<<ISC00)
    sts EICRA, temp

    ldi temp, (1<<INT0)
    out EIMSK, temp

    sei

    ldi xh, high(buffer)

    clr idx 
main:
    in data, PINC

    ldi xl, low(buffer)
    add xl,idx
    st x, data

    inc idx
    andi idx, $0F ; idx = idx % 16 - wrap around the buffer

    rjmp main

int0_handler:
    push temp
    push r0
    in r0, sreg
    push r0

    cpi data, $80
    brsh sell
buy_hold:
    ldi temp, $00
    rjmp epilog
sell:
    ldi temp, $FF
epilog:
    out PORTB, temp 
    
    ldi temp, (1<<INTF0)
    out EIFR, temp

    pop r0
    out sreg, r0
    pop r0
    pop temp
    reti


.dseg
.org $0100
buffer:
    .byte 16 ; 16 byte ring buffer
.exit 


; ===== END FILE: AVR/lec_11_12_examples/ring-buff-simple.asm =====


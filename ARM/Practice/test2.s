// same as test.s but with 64-bit logic and absolute values
// r3:r2 is the 64-bit running total
// r6 <- |mem(r5+4)|
// r3:r2 <- r3:r2 + #0:r6


// with RSB logic we can check branchlessly if a register contains a negative value
// with CMP too
// then we can conditionally execute an instruction with the suffix 'pl' or 'mi' 

//.syntax unified
//.thumb
//.cpu cortex-m4
.section .text
.global _start


_start:
    mov r5, r0 // base address of array
    mov r2,#0 // low 32 bits of total
    mov r3,#0 // high 32 bits of total

main:
    ldr r6, [r5],#4
    cmp r6, #0
    //it mi  //  for thumb-2 isa we need the it block
    rsbmi r6,r6,#0
    adds r2,r2,r6
    adc r3,r3,#0
    subs r1,r1,#1
    bne main

    
    



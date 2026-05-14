// Assume register R0 holds the starting memory address of an array of 32-bit integers. 
//Register R2 holds the exact number of elements (n) in that array.

// Write an ARM assembly loop to add all the elements of this array together. 
//Store the final sum in register R1. 
//Constraint: You must use ARM's post-indexed memory addressing to traverse the array


.section .text
.global init

init:
    ldr r3, r0
    mov r1,#0

main:
    ldr r4,[r3],#4
    subs r2,r2,#1
    add r1,r1,r4
    bne main


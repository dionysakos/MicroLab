/*
R0: Holds the current memory pointer to Array A.
R1: Holds the current memory pointer to Array B.
R2: Holds the current memory pointer to the output Array C.
R3: Holds the total number of elements to write to Array C (the combined size of A and B).
Task: Write the ARM/Thumb-2 assembly loop that compares 
the current elements of Array A and Array B, picks the smaller of the two, 
stores it into Array C, and advances the pointers appropriately until R3 reaches zero.
*/

.section .text
.global _start

_start:
    ldr r4,[r0],#4
    ldr r5, [r1],#4

main:
    cmp r4,r5

    // if r4 <= r5
    strls r4,[r2],#4
    ldrls r4,[r0],#4

    //if r5 < r4
    strhi r5,[r2],#4
    ldrhi r5,[r1],#4

    subs r3,r3,#1
    bne main

/* Note:
the 'mi' and 'pl' only work if we are comparing signed integers
they evaluate only the N flag of cpseg
If bit 31 (the most significant bit) of the subtracted result is 1, 
the N flag is set to 1 (Minus). If bit 31 is 0, the N flag is 0 (Positive).


BUT:
The LS (Unsigned Lower or Same) and HI (Unsigned Higher) condition codes completely ignore the N flag. 
Instead, they evaluate the C (Carry) flag and the Z (Zero) flag.
HI (Higher): Executes only if C = 1 and Z = 0
LS (Lower or Same): Executes if C = 0 or Z = 1

NOTE:
The ALU calculates Operand1 - Operand2 by internally performing Two's Complement addition:
 Operand1 + NOT(Operand2) + 1
*/


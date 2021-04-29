.global _start

array: .word -1, 23, 1, 12, -7
size: .word 5
_start:
	LDR R0,=array   //load array into R0 as a pointer
	LDR R6,size     // load the size of the array as input
	PUSH {R0,R6,LR} // Push all registers and LR into the stack in order
//check if the sorting is completed
Loop1:              
    MOV R1,#0    
    SUB R6,R6,#1 
	CMP R6,#0
	BLE print
//swapping algorithm
Loop2:              
    ADD R2,R1,#1
    CMP R2,R6      // Check if the completeness of the current swap
    BGT Loop1      // if yes go to loop 1
    LDR R3,[R0,R1,LSL #2]  // R3 restore the current element
    LDR R4,[R0,R2,LSL #2]  // R4 restore the next element
    CMP R3,R4              // check if R3 > R4
    STRGT R4,[R0,R1,LSL #2] // swap R3 and R4 if yes
    STRGT R3,[R0,R2,LSL #2]
    MOV R1,R2              // proceed to the next element
    B Loop2        

continue:                     
    POP {R0,R6,LR}  // Pop values stored from the stack

//load the elements and print them
print:
	LDR R1, [R0]
	LDR R2, [R0,#4]
	LDR R3, [R0,#8]
	LDR R4, [R0,#12]
	LDR R5, [R0,#16]
	B stop
 
stop:
	B stop
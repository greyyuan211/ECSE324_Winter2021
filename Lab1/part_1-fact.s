.global _start

QFact: .space 4 //specify space 

_start:
	MOV R0, #1  //R0 will restore the factorial equation
	MOV R1, #4 //R1 is the loop iteration index, and here taking factorial of 4
	PUSH {LR}  // putting the return address, in the link register, onto the stack when the subroutine is called
	BL factorial //call subroutine FACT
	STR R0, QFact  //store the sum 
	POP {LR} // pop the return address off the stack
	B stop

factorial:
	CMP R1, #2 //check if R1 greater or equal than 2		
	BGE else //if yes, branch to else
	
then:
	MOV R1, #1 // return 1
	BX LR //go back to "factorial"
	
else:
	PUSH {LR} //continue our factorial calculation
	PUSH {R1}		
	SUB R1, R1, #1
	BL factorial
	POP {R1}
	MUL R0, R0, R1
	POP {LR}
	BX LR // go back to "factorial"

stop:
	B stop
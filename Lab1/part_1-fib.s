QFib: .space 4
.global _start
_start:
	 MOV R1, #5 //R1 corresponds to n of Fib(n)
	 MOV R0, #0 //R0 is the final result of the fib series
	 MOV R2, #0 //R2 corresponds to Fib(n-1)
	 MOV R3, #0 //R3 corresponds to Fib(n-2)
	 PUSH {LR} //push the return address
	 BL Fib // call subroutine Fib
	 STR R0, QFib //pop the return address
	 POP {LR} // pop the return address of the stack
	 B stop 

Fib:
	CMP R1, #3	// check if R1 is greater or equal to 3 now
	BGE else //if yes, change to else
	
then:
	MOV R0, #1	//if no, return 1
	BX LR // go back to Fib after finished
 
else:
	PUSH {R3,R2,R1,LR} //Push LR, R1, R2, R3 in order into the stack
	SUB R1, R1, #1  // R1 = R1(which is n) -1
	BL Fib   // call Fib(n-1) again recursively
	MOV R2, R0  // R2 = Fib(n-1)
	SUB R1, R1, #1  
	BL Fib   
	MOV R3, R0 //R3 = Fib(n-2)
	ADD R0, R3, R2 //R0 = Fib(n-1) + Fib(n-2)
	POP {R3,R2,R1,LR} //Pop LR, R1, R2, R3 
	BX LR // go back to Fib after finished

stop:
	B stop
	
.global _start

//initialization
//2D image
image: .word 183, 207, 128, 30, 109, 0, 14, 52, 15, 210 ,228, 76, 48, 82, 179, 194, 22, 168, 58, 116,228, 217, 180, 181, 243, 65, 24, 127, 216, 118,64, 210, 138, 104, 80, 137, 212, 196, 150, 139,155, 154, 36, 254, 218, 65, 3, 11, 91, 95,219, 10, 45, 193, 204, 196, 25, 177, 188, 170,189, 241, 102, 237, 251, 223, 10, 24, 171, 71,0, 4, 81, 158, 59, 232, 155, 217, 181, 19,25, 12, 80, 244, 227, 101, 250, 103, 68, 46,136, 152, 144, 2, 97, 250, 47, 58, 214, 51
//Kernel
kernel: .word 1, 1, 0, -1, -1, 0, 1, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 1, 0, -1, -1, 0, 1, 1

QConv: .space 800
widthImage: .word 10  //Image width
heightImage: .word 10 //Image height
widthKernel: .word 5   //Kernel width
heightKernel: .word 5  //Kernel height

_start:
	LDR R0, heightImage	//R0 is the index for the first loop of hi
	
Loop1:
	SUB R0, R0, #1		//R0 = R0 - 1
	CMP R0, #0			//check if R0 (which is y) >= 0
	BLT stop			//terminate if y !>=0, go to loop2 if y>=0
	LDR R1, widthImage	//R0 is the index for the second loop of wi
	
Loop2:
	LDR R11, =QConv			
	LDR R8, widthImage
	MOV R7, #4			//define how many columns
	MUL R8, R8, R1		//row offset
	MUL R8, R8, R7		//row offset shown times the size
	MUL R7, R7, R0		//column offset is fixed size size is set
	ADD R9, R8, R7		//total = column + row
	STR R4, [R11, R9]	//gx[x][y] = sum	
	SUB R1, R1, #1		//R1 = R1 - 1
	CMP R1, #0			//check if R1(whcih is x) >= 0
	BLT Loop1			//go to LOOP1 if x !>= 0
	MOV R4, #0			//set sum (in C) = 0 if x >= 0
	LDR R2, widthKernel	// set i = kernel width
	
Loop3:
	SUB R2, R2, #1		//R2 = R2 -1
	CMP R2, #0			//check if R2(which is i) >= 0
	BLT Loop2			//go to Loop2 if i < 0
	LDR R3, heightKernel//set j = Kernel height if i >=0
	
Loop4:
	SUB R3, R3, #1		//R3 = R3 -1
	CMP R3, #0			//check if R3(which is j) >= 0
	BLT Loop3			//go to loop3 if not previous nested loop 3 if not
	LDR R5, widthKernel //int temp1 = x+j -ksw;
	SUB R5, R5, #1		//temp1 will be stored in R5
	ASR R5, R5, #1		
	SUB R5, R3, R5		
	ADD R5, R5, R1		//temp1 = x + j - ksw	
	LDR R6, heightKernel//int temp2 = y+i -khw;
	SUB R6, R6, #1		//temp2 will be stored in R6
	ASR R6, R6, #1		
	SUB R6, R2, R6		
	ADD R6, R6, R0		//temp2 = y + i - khw	
	//if (temp1>=0 && temp1<=9 && temp2>=0 && temp2<=9)
	CMP R5, #0	// check if temp1 >= 0
	BLT Loop4   
	CMP R5, #9  // check if temp1 <= 9
	BGT Loop4
	CMP R6, #0	// check if temp2 >= 0
	BLT Loop4
	CMP R6, #9	// check if temp2 <= 9
	BGT Loop4

	//similar approach to compute kx[j][i]
	LDR R12, =image			//store first element in 2D image
	LDR R11, =kernel		//store first element of kernel
	LDR R8, widthKernel		//temporarily store wk in R7
	MOV R7, #4
	MUL R8, R3, R8				//row
	MUL R8, R8, R7
	MUL R7, R2, R7				//column
	ADD R9, R8, R7				//total
	LDR R10, [R11, R9]			//R10 = kx[j][i]
	//similar approach to compute fx [temp1][temp2]
	LDR R8, widthImage
	MOV R7, #4
	MUL R8, R5, R8				//row
	MUL R8, R8, R7
	MUL R7, R6, R7				//cololumn
	ADD R9, R8, R7				//total
	LDR R11, [R12, R9]			//R11 = fx[temp1][temp2]
	
	MUL R11, R11, R10			//R11 = kx[j][i] * fx[temp1][temp2]
	ADD R4, R4, R11				//sum = sum + kx[j][i] * fx[temp1][temp2]
	B Loop4
	
stop:
	B stop
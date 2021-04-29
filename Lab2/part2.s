.equ LOAD_MEMORY, 0xFFFEC600
.equ COUNTER_MEMORY, 0xFFFEC604
.equ CONTROL_MEMORY, 0xFFFEC608
.equ INT_MEMORY, 0xFFFEC60C
.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000
.equ HEX_MEMORY_1, 0xFF200020
.equ HEX_MEMORY_2, 0xFF200030
.equ PB_MEMORY, 0xFF200050
.equ PB_INT_MEMORY, 0xFF200058
.equ PB_EDGE_MEMORY, 0xFF20005C


.global _start


//1- Load value: ARM A9 private timer is a down counter and requires initial count value. Use R0 to pass this argument.
//2- Configuration bits: Use R1 to pass this argument.
//The subroutine is used to configure the timer. Use the arguments discussed above to configure the timer.
ARM_TIM_config_ASM:
	LDR R1, =CONTROL_MEMORY
	STR R0, [R1]
	BX LR

// The subroutine returns the “F” value (0x00000000 or 0x00000001) from the ARM A9 private timer Interrupt status register.
ARM_TIM_read_INT_ASM:
	LDR R1, =INT_MEMORY
	LDR R0, [R1]
	BX LR
	
// The subroutine clears the “F” value in the ARM A9 private timer Interrupt status register. 
// The F bit can be cleared to 0 by writing a 0x00000001 into the Interrupt status register.
ARM_TIM_clear_INT_ASM:
	MOV R0, #1
	LDR R1, =INT_MEMORY
	STR R0, [R1]
	BX LR

//The subroutine will turn off all the segments of the HEX displays passed in the argument.
HEX_clear_ASM:
	LDR R1, =HEX_MEMORY_1
	
	LDR R2, [R1]
	TST R0, #1
	ANDGT R2, R2, #0xffffff00
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #2
	ANDGT R2, R2, #0xffff00ff
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #4
	ANDGT R2, R2, #0xff00ffff
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #8
	ANDGT R2, R2, #0x00ffffff
	STR R2, [R1]
	
	LDR R1, =HEX_MEMORY_2
	
	LDR R2, [R1]
	TST R0, #16
	ANDGT R2, R2, #0xffffff00
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #32
	ANDGT R2, R2, #0xffff00ff
	STR R2, [R1]
	
	BX LR
	
//The subroutine will turn on all the segments of the HEX displays passed in the argument. 
HEX_flood_ASM:
	LDR R1, =HEX_MEMORY_1
	
	LDR R2, [R1]
	TST R0, #1
	ORRGT R2, R2, #0x000000ff
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #2
	ORRGT R2, R2, #0x0000ff00
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #4
	ORRGT R2, R2, #0x00ff0000
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #8
	ORRGT R2, R2, #0xff000000
	STR R2, [R1]
	
	LDR R1, =HEX_MEMORY_2
	
	LDR R2, [R1]
	TST R0, #16
	ORRGT R2, R2, #0x000000ff
	STR R2, [R1]
	
	LDR R2, [R1]
	TST R0, #32
	ORRGT R2, R2, #0x0000ff00
	STR R2, [R1]
	
	BX LR
	
//The subroutine receives the HEX displays indices and an integer value between 0-15 through R0 and R1 registers as arguments, respectively.
HEX_write_ASM:
    PUSH {R2-R7,LR}
    MOV R2,#0  // loop index
    MOV R7,#0x00000001
    LDR R4,=HEX_MEMORY_1
    LDR R6,=HEX_MEMORY_2

    CMP R1, #0
    MOVEQ R3, #0b00111111
    CMP R1, #1
    MOVEQ R3, #0b00000110
    CMP R1, #2
    MOVEQ R3, #0b01011011
    CMP R1, #3
    MOVEQ R3, #0b01001111
    CMP R1, #4
    MOVEQ R3, #0b01100110
    CMP R1, #5
    MOVEQ R3, #0b01101101
    CMP R1, #6
    MOVEQ R3, #0b01111101
    CMP R1, #7
    MOVEQ R3, #0b00000111
    CMP R1, #8
    MOVEQ R3, #0b01111111
    CMP R1, #9
    MOVEQ R3, #0b01101111
    CMP R1, #10
    MOVEQ R3, #0b01110111
    CMP R1, #11
    MOVEQ R3, #0b01111100
    CMP R1, #12
    MOVEQ R3, #0b00111001
    CMP R1, #13
    MOVEQ R3, #0b01011110
    CMP R1, #14
    MOVEQ R3, #0b01111001
    CMP R1, #15
    MOVEQ R3, #0b01110001

    B loop1

loop1:
    TST R0,R7
    BGT modify1
    ADD R4,R4,#1
    LSL R7,#1
    ADD R2,R2,#1
    CMP R2,#4
    BEQ loop2
    CMP R2,#6
    BLE loop1
    
modify1:
    STRB R3,[R4]
    ADD R4,R4,#1
    LSL R7,#1
    ADD R2,R2,#1
    CMP R2,#4
    BEQ loop2
    B loop1

loop2:
    TST R0,R7
    BGT modify2
    ADD R6,R6,#1
    LSL R7,#1
    ADD R2,R2,#1
    CMP R2,#6
    BEQ end
    B loop2

modify2:
    STRB R3,[R6]
    ADD R6,R6,#1
    LSL R7,#1
    ADD R2,R2,#1
    CMP R2,#6
    BEQ end
    B loop2

end:
    POP {R2-R7,LR}
    BX LR

//The subroutine returns the indices of the pressed pushbuttons (the keys from the pushbuttons Data register) in R0.
read_PB_data_ASM:
	LDR R1, =PB_MEMORY
    LDR R0, [R1]
    BX  LR

//The subroutine receives pushbuttons indices as an argument (One index at a time). 
//Then, it returns 0x00000001 in R3 when the corresponding pushbutton is pressed.
PB_data_is_pressed_ASM:
	LDR R1, =PB_MEMORY
	// assumes R2 stores the input
	LDR R0, [R1]
	TST R0, R2
	MOVGT R3, #0x00000001	// return R3
	BX LR
	
//The subroutine returns the indices of the pushbuttons that have been pressed and then released
// (the edge bits from the pushbuttons’ Edgecapture register).
read_PB_edgecp_ASM:
	LDR R1, =PB_EDGE_MEMORY
	LDR R0, [R1]
	BX LR

//The subroutine receives pushbuttons indices as an argument (One index at a time). 
//Then, it returns 0x00000001 when the corresponding pushbutton has been asserted.
PB_edgecp_is_pressed_ASM:
	LDR R1, =PB_EDGE_MEMORY
	// assumes R2 stores the input
	LDR R0, [R1]
	TST R0, R2              //we restore the data of pressed button in R0
	MOVGT R3,#0x00000001	// return R3
	BX LR

//The subroutine clears the pushbuttons Edgecapture register. 
//You can read the edgecapture register and write what you just read back to the edgecapture register to clear it.
PB_clear_edgecp_ASM:
	PUSH {R6,R7}
	LDR R7, =PB_EDGE_MEMORY
	LDR R6, [R7]
	STR R6, [R7]
	POP {R6,R7}
	BX LR
	
//The subroutine receives pushbuttons indices as an argument. 
//Then, it enables the interrupt function for the corresponding pushbuttons by setting the interrupt mask bits to '1'.
enable_PB_INT_ASM:
	PUSH {R6,R7}
	LDR R7, =PB_INT_MEMORY
	LDR R6, [R7]
	ORR R6, R7, R2
	STR R6, [R7]
	POP {R6,R7}
	BX LR
	
//The subroutine receives pushbuttons indices as an argument. 
//Then, it disables the interrupt function for the corresponding pushbuttons by setting the interrupt mask bits to '0'.
disable_PB_INT_ASM:
	PUSH {R6,R7}
	LDR R7, =PB_INT_MEMORY
	LDR R6, [R1]
	MVN R3, R2	// flip R2!
	AND R6, R6, R3
	STR R6, [R7]
	POP {R6,R7}
	BX LR

_start:
	MOV R0, #0xffffffff
	MOV R1, #0
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	BL HEX_write_ASM
	LDR R0, =#2000000
	LDR R1, =LOAD_MEMORY
	STR R0, [R1]
	
	MOV R0, #0b00000110
	BL ARM_TIM_config_ASM
	BL PB_clear_edgecp_ASM
	
read:
	MOV R3, #0
	MOV R2, #1
	BL PB_edgecp_is_pressed_ASM
	TST R3, #0x00000001
	MOVGT R0, #0b00000111
	LDRGT R1, =CONTROL_MEMORY
	STRGT R0, [R1]
	BLGT PB_clear_edgecp_ASM
	
	MOV R3, #0
	MOV R2, #2
	BL PB_edgecp_is_pressed_ASM
	TST R3, #0x00000001
	MOVGT R0, #0b00000110
	LDRGT R1, =CONTROL_MEMORY
	STRGT R0, [R1]
	BLGT PB_clear_edgecp_ASM

	MOV R3, #0
	MOV R2, #4
	BL PB_edgecp_is_pressed_ASM
	
	TST R3, #0x00000001
	MOVGT R0, #0b00000110
	LDRGT R1, =CONTROL_MEMORY
	
	STRGT R0, [R1]
	MOVGT R12, #0
	MOVGT R11, #0
	MOVGT R10, #0
	MOVGT R9, #0
	MOVGT R8, #0
	MOVGT R7, #0
	MOVGT R0, #0xffffffff
	MOVGT R1, #0
	
	BLGT HEX_write_ASM
	BLGT PB_clear_edgecp_ASM
	BL ARM_TIM_read_INT_ASM
	TST R0, #1
	BEQ read
	
	ADD R12, R12, #1
	CMP R12, #10
	ADDEQ R11, R11, #1
	MOVEQ R12, #0
	CMP R11, #10
	ADDEQ R10, R10, #1
	MOVEQ R11, #0
	CMP R10, #10
	ADDEQ R9, R9, #1
	MOVEQ R10, #0
	CMP R9, #6
	ADDEQ R8, R8, #1
	MOVEQ R9, #0
	CMP R8, #10
	ADDEQ R7, R7, #1
	MOVEQ R8, #0
	CMP R7, #6
	
	LDREQ R1, =CONTROL_MEMORY
	MOVEQ R0, #0b00000110
	STREQ R0, [R1]
		
display:
	MOV R0, #1
	MOV R1, R12
	BL HEX_write_ASM
	MOV R0, #2
	MOV R1, R11
	BL HEX_write_ASM
	MOV R0, #4
	MOV R1, R10
	BL HEX_write_ASM
	MOV R0, #8
	MOV R1, R9
	BL HEX_write_ASM
	MOV R0, #16
	MOV R1, R8
	BL HEX_write_ASM
	MOV R0, #32
	MOV R1, R7
	BL HEX_write_ASM
	BL ARM_TIM_clear_INT_ASM
	B read

.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.text
PB_int_flag: .word 0x0
tim_int_flag: .word 0x0
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

//activate the interrupts for pushbuttons and ARM A9 private timer by calling the subroutines you wrote in the previous tasks
//(Call enable_PB_INT_ASM and ARM_TIM_config_ASM subroutines)
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
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV        R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR        CPSR_c, R1           // change to IRQ mode
    LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR        CPSR, R1             // change to supervisor mode
    LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL     CONFIG_GIC               // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
    MOV 	   R1, #0b00000110
	BL		   ARM_TIM_config_ASM
	LDR        R0, =0xFF200050      // pushbutton KEY base address
    MOV        R1, #0xF             // set interrupt mask bits
    STR        R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR        CPSR_c, R0

//You will describe the stopwatch function here.
IDLE:
    LDR R0, =PB_int_flag
	LDR R1, [R0]
	CMP R1, #1
	
	PUSH {R0, R1}
	MOVEQ R0, #0b00000111
	LDREQ R1, =CONTROL_MEMORY
	STREQ R0, [R1]
	POP {R0, R1}
	MOVEQ R1, #0
	STREQ R1, [R0]
	CMP R1, #2
	
	PUSH {R0, R1}
	MOVEQ R0, #0b00000110
	LDREQ R1, =CONTROL_MEMORY
	STREQ R0, [R1]
	POP {R0, R1}
	MOVEQ R1, #0
	STREQ R1, [R0]
	CMP R1, #4
	
	PUSH {R0, R1}
	MOVEQ R0, #0b00000110
	LDREQ R1, =CONTROL_MEMORY
	STREQ R0, [R1]
	MOVEQ R12, #0
	MOVEQ R11, #0
	MOVEQ R10, #0
	MOVEQ R9, #0
	MOVEQ R8, #0
	MOVEQ R7, #0
	MOVEQ R0, #0xffffffff
	MOVEQ R1, #0
	BLEQ HEX_write_ASM
	POP {R0, R1}
	MOVEQ R1, #0
	STREQ R1, [R0]
	
	LDR R0, =tim_int_flag
	LDR R1, [R0]
	CMP R1, #1
	BNE IDLE
	
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
	
	MOV R0, #32
	MOV R1, R7
	BL HEX_write_ASM
	MOV R0, #16
	MOV R1, R8
	BL HEX_write_ASM	
	MOV R0, #8
	MOV R1, R9
	BL HEX_write_ASM
	MOV R0, #4
	MOV R1, R10
	BL HEX_write_ASM
	MOV R0, #2
	MOV R1, R11
	BL HEX_write_ASM
	MOV R0, #1
	MOV R1, R12
	BL HEX_write_ASM
	
	LDR R0, =tim_int_flag
	MOV R1, #0
	STR R1, [R0]
	
	B IDLE // This is where you write your objective task
	
/*--- Undefined instructions --------------------------------------*/
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ----------------------------------------*/
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------*/
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------*/
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------*/
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR
/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
Interrupt_check:
	CMP R5, #29
	BNE Pushbutton_check
	BL ARM_TIM_ISR
	B EXIT_IRQ
Pushbutton_check:
    CMP R5, #73
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
    BL KEY_ISR
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------*/
SERVICE_FIQ:
    B SERVICE_FIQ
	
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #29            // KEY port (Interrupt ID = 29)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	
	MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
KEY_ISR:
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
    LDR R0, =0xFF200020    // based address of HEX display
CHECK_KEY0:
    MOV R3, #0x1
    ANDS R3, R3, R1        // check for KEY0
    BEQ CHECK_KEY1
	LDR R2, =PB_int_flag
	STR R1, [R2]	       // display "0"
    B END_KEY_ISR
CHECK_KEY1:
    MOV R3, #0x2
    ANDS R3, R3, R1        // check for KEY1
    BEQ CHECK_KEY2
	LDR R2, =PB_int_flag
	STR R1, [R2]	       // display "1"
    B END_KEY_ISR
CHECK_KEY2:
	LDR R2, =PB_int_flag
	STR R1, [R2]	       // display "2"
    B END_KEY_ISR
END_KEY_ISR:
    BX LR
	
//to be added
//for pushbuttons and ARM A9 private timer interrupt service routines, respectively.
ARM_TIM_ISR:
	LDR R2, =tim_int_flag
	MOV R1, #1
	STR R1, [R2]
	PUSH {R0, R1}
	LDR R1, =INT_MEMORY
	MOV R0, #1
	STR R0, [R1]
	POP {R0, R1}
	BX LR
	

//The subroutine receives pushbuttons indices as an argument. 
//Then, it enables the interrupt function for the corresponding pushbuttons by setting the interrupt mask bits to '1'.
enable_PB_INT_ASM:
    PUSH {R6,R7}
    LDR R7,=PB_INT_MEMORY
    MOV R6,#0b11111111    //setting the interrupt mask bits to '1'.
    STRB R6,[R7]
    POP {R6,R7}
    BX LR
	
//The subroutine receives pushbuttons indices as an argument. 
//Then, it disables the interrupt function for the corresponding pushbuttons by setting the interrupt mask bits to '0'.
disable_PB_INT_ASM:
    PUSH {R6,R7}
    LDR R7,=PB_INT_MEMORY
    MOV R6,#0b00000000    //setting the interrupt mask bits to '0'.
    STRB R6,[R7]
    POP {R6,R7}
    BX LR
	
ARM_TIM_config_ASM:
	LDR R0, =CONTROL_MEMORY
	STR R1, [R0]
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
    PUSH {R2-R7,LR}
    MOV R2,#0  // loop index
    MOV R3,#0x00 
    MOV R7,#0x00000001 
    LDR R4,=HEX_MEMORY_1
    LDR R6,=HEX_MEMORY_2
    B loop1


//The subroutine will turn on all the segments of the HEX displays passed in the argument. 
HEX_flood_ASM:
    PUSH {R2-R7,LR}
    MOV R2,#0  //loop index
    MOV R3,#0xff 
    MOV R7,#0x00000001 
    LDR R4,=HEX_MEMORY_1
    LDR R6,=HEX_MEMORY_2
    B loop1

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
	
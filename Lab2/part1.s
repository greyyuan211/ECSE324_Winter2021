.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000
.equ HEX_MEMORY_1, 0xFF200020
.equ HEX_MEMORY_2, 0xFF200030
.equ PB_MEMORY, 0xFF200050
.equ PB_INT_MEMORY, 0xFF200058
.equ PB_EDGE_MEMORY, 0xFF20005C

.global _start
_start:
    MOV R0,#0b00110000
    MOV R1,#8
    BL HEX_write_ASM
    MOV R0,#0b00001111
    BL HEX_clear_ASM
    B read
read:
    BL read_slider_switches_ASM
    BL write_LEDs_ASM
    MOV R12,#0

    TST R0,#1
    ADDGT R12,#1
    TST R0,#2
    ADDGT R12,#2
    TST R0,#4
    ADDGT R12,#4
    TST R0,#8
    ADDGT R12,#8

    TST R0,#512
    MOVGT R0,#0b00001111
    MOVGT R1,#0
    BGT display

    MOV R0,#1
    MOV R3,#0
    BL PB_edgecp_is_pressed_ASM
    TST R3,#0x00000001
    MOVGT R1,R12
    MOVGT R0,#1
    BLGT PB_clear_edgecp_ASM
    BGT display

    MOV R0, #2
    MOV R3, #0
    BL PB_edgecp_is_pressed_ASM
    TST R3, #0x00000001
    MOVGT R1, R12
    MOVGT R0, #2
    BLGT PB_clear_edgecp_ASM
    BGT display

    MOV R0, #4
    MOV R3, #0
    BL PB_edgecp_is_pressed_ASM
    TST R3, #0x00000001
    MOVGT R1, R12
    MOVGT R0, #4
    BLGT PB_clear_edgecp_ASM
    BGT display

    MOV R0, #8
    MOV R3, #0
    BL PB_edgecp_is_pressed_ASM
    TST R3, #0x00000001
    MOVGT R1, R12
    MOVGT R0, #8
    BLGT PB_clear_edgecp_ASM
    BGT display
    B read    
display:
    BL HEX_write_ASM
    B read
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
 
// Sider Switches Driver
// returns the state of slider switches in R0
read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR

// LEDs Driver
// writes the state of LEDs (On/Off state) in R0 to the LEDs memory 
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR

//The subroutine returns the indices of the pressed pushbuttons (the keys from the pushbuttons Data register) in R0.
read_PB_data_ASM:
    LDR R2,=PB_MEMORY
    LDR R0,[R2]
    BX LR
    
//The subroutine receives pushbuttons indices as an argument (One index at a time). 
//Then, it returns 0x00000001 in R3 when the corresponding pushbutton is pressed.
PB_data_is_pressed_ASM:
    LDR R2,=PB_MEMORY
    LDR R1,[R2]
    TST R0,R1     //we restore the data of pressed button in R0
    MOVGT R3,#0x00000001
    BX LR

//The subroutine returns the indices of the pushbuttons that have been pressed and then released
// (the edge bits from the pushbuttons’ Edgecapture register).
read_PB_edgecp_ASM:
    LDR R2,=PB_EDGE_MEMORY
    LDR R0,[R2]  //store the read from PB_edgecp in R0
    BX LR

//The subroutine receives pushbuttons indices as an argument (One index at a time). 
//Then, it returns 0x00000001 when the corresponding pushbutton has been asserted.
PB_edgecp_is_pressed_ASM:
    LDR R2,=PB_EDGE_MEMORY
    LDR R1,[R2]
    TST R0,R1     //we restore the data of pressed button in R0
    MOVGT R3,#0x00000001
    BX LR

//The subroutine clears the pushbuttons Edgecapture register. 
//You can read the edgecapture register and write what you just read back to the edgecapture register to clear it.
PB_clear_edgecp_ASM:
    PUSH {R6,R7}
    LDR R7,=PB_EDGE_MEMORY
    LDR R6,[R7]
    STR R6,[R7]
    POP {R6,R7}
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
 
.end
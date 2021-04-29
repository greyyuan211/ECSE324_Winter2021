.equ PIXEL_BUFFER_MEMORY, 0xc8000000
.equ CHARACTER_BUFFER_MEMORY, 0xc9000000
.equ PS2_MEMORY, 0xff200100

.global _start
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.
//draws a point on the screen with the color as indicated in the third argument, by accessing only the pixel buffer memory. 
//Hint: This subroutine should only access the pixel buffer memory.
VGA_draw_point_ASM:
		PUSH {R0-R3}
		LSL R0, R0, #1   //x-coord
        LSL R1, R1, #10  //y-coord
		ADD R1, R1, R0
		LDR R3, =PIXEL_BUFFER_MEMORY
		ADD R3, R3, R1
        STRH R2, [R3]    //color
		POP {R0-R3}
		BX LR
//clears (sets to 0) all the valid memory locations in the pixel buffer. It takes no arguments and returns nothing. 
//Hint: You can implement this function by calling VGA_draw_point_ASM with a color value of zero for every valid location on the screen.	
VGA_clear_pixelbuff_ASM:
        PUSH {R0-LR}
        MOV R0, #0      //x
        MOV R1, #0      //y
        MOV R2, #0      //color
        B colorForLoop1
        
colorForLoop1:
        MOV R1, #0
        CMP R0, #320
        BLT colorForLoop2
        B finish
        
colorForLoop2:
        MOV R3, #240
        CMP R1, R3
        BLLT VGA_draw_point_ASM
        ADDLT R1, R1, #1
        BLT colorForLoop2
        ADD R0, R0, #1
        B colorForLoop1

finish:
        POP {R0-LR}
        BX LR
//writes the ASCII code passed in the third argument (r2) to the screen at the (x, y) coordinates given in the first two arguments (r0 and r1). 
//Essentially, the subroutine will store the value of the third argument at the address calculated with the first two arguments. 
//The subroutine should check that the coordinates supplied are valid, i.e., x in [0, 79] and y in [0, 59]. 
//Hint: This subroutine should only access the character buffer memory.	
VGA_write_char_ASM:
		PUSH {R0-R3}
		LSL R1, R1, #7
		ADD R1, R1, R0
		LDR R3, =CHARACTER_BUFFER_MEMORY
		ADD R3, R3, R1
		STRB R2, [R3]
		POP {R0-R3}
		BX LR
//clears (sets to 0) all the valid memory locations in the character buffer. 
//It takes no arguments and returns nothing. 
//Hint: You can implement this function by calling VGA_write_char_ASM with a character value of zero for every valid location on the screen.	
VGA_clear_charbuff_ASM:
		PUSH {R0-LR}
	    MOV R0, #0      //x
	    MOV R1, #0      //y
	    MOV R2, #0      //color
	    B charForLoop1
	
charForLoop1:
		MOV R1, #0
		CMP R0, #80
		BLT charForLoop2
        B finish
	
charForLoop2:
		CMP R1, #60
		BLLT VGA_write_char_ASM
		ADDLT R1, R1, #1
		BLT charForLoop2
		ADD r0, r0, #1
		B charForLoop1

//here conclude the VGA driver functions

@ TODO: insert PS/2 driver here.
//The subroutine will check the RVALID bit in the PS/2 Data register. 
//If it is valid, then the data from the same register should be stored at the address in the pointer argument, 
//and the subroutine should return 1 to denote valid data. 
//If the RVALID bit is not set, then the subroutine should simply return 0.
read_PS2_data_ASM:
	    PUSH {R1-LR}
	    LDR R1,=PS2_MEMORY
	    LDR R4,[R1]
	    ASR R1,R4,#15
	    AND R1,R1,#0x1
	    CMP R1,#0
	    BEQ notValid
	    STRB R4,[R0]
	    MOV R0,#1
	    POP {R1-LR}
	    BX LR

notValid:
	    MOV R0,#0
	    POP {R1-LR}
	    BX LR

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
	
	
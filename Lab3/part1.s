.equ PIXEL_BUFFER_MEMORY, 0xc8000000
.equ CHARACTER_BUFFER_MEMORY, 0xc9000000
const_zero: .word 0x0

.global _start
_start:
        bl      draw_test_screen
end:
        b       end

@ TODO: Insert VGA driver functions here.
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

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
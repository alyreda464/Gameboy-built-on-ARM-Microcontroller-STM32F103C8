	INCLUDE DEFINITIONS.s

	AREA TFTCODE, CODE, READONLY
		
		
	
	B LTORG_LABEL
	LTORG
LTORG_LABEL

DRAW_CURSOR	FUNCTION
	PUSH{R0-R12,LR}
	;THIS FUNCTION JUST DRAWS A SPRITE FROM THE STARTING X AND STARTING Y, TAKES ARGUMENTS:
	;SPRITE_X: STARTING X
	;SPRITE_Y: STARTING Y
	;BOTH ARGUMENTS ARE INITIALLY STORED INSIDE THE DATASECTION
	LDR R5,=CURSOR_X
	LDRH R0,[R5]
	ADD R3,R0,#10
	LDR R6,=CURSOR_Y
	LDRH R1,[R6]
	ADD R4,R1,#10
	LDR R10,=BLUE
	BL DRAW_RECTANGLE_FILLED
		

	
	POP{R0-R12,PC}
	ENDFUNC



;##########################################################################################################################################
DRAW_RECTANGLE_FILLED
	;X1 = [] r0
	;Y1 = [] r1
	;X2 = [] r3
	;Y2 = [] r4
	;COLOR = [] r10
	
	
	PUSH {R0-R12, LR}
	
	push{r0-r4}


	PUSH {R1}
	PUSH {R3}
	
	pop {r1}
	pop {r3}
	
	;THE NEXT FUNCTION TAKES x1, x2, y1, y2
	;R0 = x1
	;R1 = x2
	;R3 = y1
	;R4 = y2
	bl ADDRESS_SET
	
	pop{r0-r4}
	

	SUBS R3, R3, R0
	add r3, r3, #1
	SUBS R4, R4, R1
	add r4, r4, #1
	MUL R3, R3, R4


;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


RECT_FILL_LOOP
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE

	SUBS R3, R3, #1
	CMP R3, #0
	BGT RECT_FILL_LOOP


END_RECT_FILL
	POP {R0-R12, PC}
;##########################################################################################################################################
	
LCD_WRITE FUNCTION
	;this function takes what is inside r2 and writes it to the tft
	;this function writes 8 bits only
	;later we will choose whether those 8 bits are considered a command, or just pure data
	;your job is to just write 8-bits (regardless if data or command) to PE0-7 and set WR appropriately
	;arguments: R2 = data to be written to the D0-7 bus

	PUSH {R0-R3, LR}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 0 ;;;;;;;;;;;;;;;;;;;;;
	;IN THIS STEP: RESET WR TO 0
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	LSL R3, #8
	MVN R3, R3
	AND R0, R0, R3
	STRH R0, [R1]
	;;;;;;;;;;;;; HERE YOU PUT YOUR DATA which is in R2 TO PE0-7 ;;;;;;;;;;;;;;;;;

	LDR R1, =GPIOA_ODR_OFFSET
	STRB R2, [R1]			;only write the lower byte to PE0-7
	;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #8
	STRH R0, [R1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	POP {R0-R3, PC}
	ENDFUNC
	

LCD_COMMAND_WRITE FUNCTION
	;this function writes a command to the TFT, the command is read from R2
	;it writes LOW to RS first to specify that we are writing a command not data.
	;then it normally calls the function LCD_WRITE we just defined above
	;arguments: R2 = data to be written on D0-7 bus

	
	PUSH {R0-R3, LR}
	
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #9
	STRH R0, [R1]

	;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	LSL R3, #7
	MVN R3, R3
	AND R0, R0, R3
	STRH R0, [R1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	BL LCD_WRITE


	POP {R0-R3, PC}
	ENDFUNC




LCD_DATA_WRITE FUNCTION
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing actual data not a command.
	;arguments: R2 = data

	PUSH {R0-R3, LR}

	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #9
	STRH R0, [R1]

	;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #7
	STRH R0, [R1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL LCD_WRITE

	POP {R0-R3, PC}
	ENDFUNC

ADDRESS_SET	FUNCTION
	;THIS FUNCTION TAKES X1, X2, Y1, Y2
	;IT ISSUES COLUMN ADDRESS SET TO SPECIFY THE START AND END COLUMNS (X1 AND X2)
	;IT ISSUES PAGE ADDRESS SET TO SPECIFY THE START AND END PAGE (Y1 AND Y2)
	;THIS FUNCTION JUST MARKS THE PLAYGROUND WHERE WE WILL ACTUALLY DRAW OUR PIXELS, MAYBE TARGETTING EACH PIXEL AS IT IS.
	;R0 = X1
	;R1 = X2
	;R3 = Y1
	;R4 = Y2

	;PUSHING ANY NEEDED REGISTERS
	PUSH {R0-R4, LR}
	

	;COLUMN ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2A
	BL LCD_COMMAND_WRITE

	;IN THIS STEP: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING COLUMN, AKA HIGHER 8-BITS OF X1)
	MOV R2, R0
	LSR R2, #8
	BL LCD_DATA_WRITE

	;IN THIS STEP: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING COLUMN, AKA LOWER 8-BITS OF X1)
	MOV R2, R0
	BL LCD_DATA_WRITE


	;IN THIS STEP: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING COLUMN, AKA HIGHER 8-BITS OF X2)
	MOV R2, R1
	LSR R2, #8
	BL LCD_DATA_WRITE

	;IN THIS STEP: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING COLUMN, AKA LOWER 8-BITS OF X2)
	MOV R2, R1
	BL LCD_DATA_WRITE



	;PAGE ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2B
	BL LCD_COMMAND_WRITE

	;IN THIS STEP: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING PAGE, AKA HIGHER 8-BITS OF Y1)
	MOV R2, R3
	LSR R2, #8
	BL LCD_DATA_WRITE

	;IN THIS STEP: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING PAGE, AKA LOWER 8-BITS OF Y1)
	MOV R2, R3
	BL LCD_DATA_WRITE


	;IN THIS STEP: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING PAGE, AKA HIGHER 8-BITS OF Y2)
	MOV R2, R4
	LSR R2, #8
	BL LCD_DATA_WRITE

	;IN THIS STEP: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING PAGE, AKA LOWER 8-BITS OF Y2)
	MOV R2, R4
	BL LCD_DATA_WRITE

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


	;POPPING ALL REGISTERS I PUSHED
	POP {R0-R4, PC}
	ENDFUNC


;#####################################################################################################################################################################
DRAWPIXEL
	PUSH {R0-R5, r10, LR}
	;THIS FUNCTION TAKES X AND Y AND A COLOR AND DRAWS THIS EXACT PIXEL
	;NOTE YOU HAVE TO CALL ADDRESS SET ON A SPECIFIC PIXEL WITH LENGTH 1 AND WIDTH 1 FROM THE STARTING COORDINATES OF THE PIXEL, THOSE STARTING COORDINATES ARE GIVEN AS PARAMETERS
	;THEN YOU SIMPLY ISSUE MEMORY WRITE COMMAND AND SEND THE COLOR
	;R0 = X
	;R1 = Y
	;R10 = COLOR

	;CHIP SELECT ACTIVE, WRITE LOW TO CS
	LDR R3, =GPIOB_ODR_OFFSET
	LDR R4, [R3]
	MOV R5, #1
	LSL R5, #6
	MVN R5, R5
	AND R4, R4, R5
	STR R4, [R3]

	;IN THIS STEP: SETTING PARAMETERS FOR FUNC 'ADDRESS_SET' CALL, THEN CALL FUNCTION ADDRESS SET
	;NOTE YOU MIGHT WANT TO PERFORM PARAMETER REORDERING, AS ADDRESS SET FUNCTION TAKES X1, X2, Y1, Y2 IN R0, R1, R3, R4 BUT THIS FUNCTION TAKES X,Y IN R0 AND R1
	MOV R3, R1 ;Y1
	ADD R1, R0, #1 ;X2
	ADD R4, R3, #1 ;Y2
	BL ADDRESS_SET

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE

	;SEND THE COLOR DATA | DATASHEET PAGE 114
	;HINT: WE SEND THE HIGHER 8-BITS OF THE COLOR FIRST, THEN THE LOWER 8-BITS
	;HINT: WE SEND THE COLOR OF ONLY 1 PIXEL BY 2 DATA WRITES, THE FIRST TO SEND THE HIGHER 8-BITS OF THE COLOR, THE SECOND TO SEND THE LOWER 8-BITS OF THE COLOR
	;REMINDER: WE USE 16-BIT PER PIXEL COLOR
	;IN THIS STEP: SEND THE SINGLE COLOR, PASSED IN R10
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE
	
	POP {R0-R5, r10, PC}
	
;###################################################################################################################################

  
SETUP FUNCTION
	;THIS FUNCTION ENABLES PORT A & B, MARKS THEM AS OUTPUT, CONFIGURES SOME GPIO
	;THEN FINALLY IT CALLS LCD_INIT (HINT, USE THIS SETUP FUNCTION DIRECTLY IN THE MAIN)
	PUSH {R0-R12, LR}

	;Make the clock affect port A by enabling the corresponding bit (the second bit) in RCC_APB2ENR register
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R2, #1
	ORR R1, R1, R2, LSL #2
	STR R1, [R0]
	
	;Make the clock affect port B by enabling the corresponding bit (the third bit) in RCC_APB2ENR register
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R2, #1
	ORR R1, R1, R2, LSL #3
	STR R1, [R0]
	
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R2, #1
	ORR R1, R1, R2, LSL #4
	STR R1, [R0]
	
	;Make the GPIO A (lower byte) mode as output type push-pull and setting output speed to the maximum speed
	LDR R0, =GPIOA_CRL_OFFSET
	LDR R1, [R0]
	AND R1, R1 , #0x00000000
	ORR R1, R1 , #0x33333333
	STR R1,[R0]
	
	LDR R0, =GPIOA_CRH_OFFSET
	LDR R1, [R0]
	AND R1, R1 , #0x00000000
	ORR R1, R1 , #0x33333333
	STR R1,[R0]
	;Make the GPIO B (B0, B1, B5, B6, AND B7) mode as output type push-pull and setting output speed to the maximum speed
	LDR R0, =GPIOB_CRL_OFFSET
	MOV R1, #0x33333333
	STR R1,[R0]

	LDR R0, =GPIOB_CRH_OFFSET
	MOV R1, #0x33000000
	ORR R1, R1, #0x330000
	ORR R1, R1, #0x8800
	ORR R1, R1, #0x33
	STR R1,[R0]
	
	LDR R0, =GPIOC_CRH_OFFSET
	LDR R1, [R0]
	AND R1, R1 , #0x00000000
	ORR R1, R1 , #0x88888888
	STR R1,[R0]
	
	LDR R0, =GPIOC_ODR_OFFSET
	MOV R1, #0xFFFFFFFF
	STR R1,[R0]
	
	LDR R0, =GPIOB_ODR_OFFSET
	MOV R1, #0xFFFFFFFF
	STR R1,[R0]

	BL LCD_INIT

	POP {R0-R12, PC}
	ENDFUNC
	
	
LCD_INIT FUNCTION
	;This function executes the minimum needed LCD initialization measures
	;Only the necessary Commands are covered
	;Eventho there are so many more in the DataSheet

	;IN THIS STEP: PUSH ANY NEEDED REGISTERS
  	PUSH {R0-R3, LR}

	;;;;;;;;;;;;;;;;; HARDWARE RESET (putting RST to high then low then high again) ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;IN THIS STEP: SET RESET PIN TO HIGH (THIS CORRESPONDS TO SETTING B7 TO HIGH)
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #15
	STR R0, [R1]

	;IN THIS STEP: DELAY FOR SOME TIME
	BL delay_1_second

	;IN THIS STEP: RESET RESET PIN TO LOW (SET B15 TO 0)
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	LSL R3, #15
	MVN R3, R3
	AND R0, R0, R3
	STR R0, [R1]

	;IN THIS STEP: DELAY FOR SOME TIME
	BL delay_10_milli_second

	;IN THIS STEP: SET RESET PIN TO HIGH AGAIN
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #15
	STR R0, [R1]

	;IN THIS STEP: DELAY FOR SOME TIME
	BL delay_1_second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;; PREPARATION FOR WRITE CYCLE SEQUENCE (setting CS to high, then configuring WR and RD, then resetting CS to low) ;;;;;;;;;;;;;;;;;;
	;IN THIS STEP: SET CS PIN HIGH (SET B6 TO HIGH)
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #6
	STR R0, [R1]

	;IN THIS STEP: SET WR PIN HIGH (B1)
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #8
	STRH R0, [R1]

	;IN THIS STEP: SET RD PIN HIGH (B0)
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	ORR R0, R0, R3, LSL #9
	STRH R0, [R1]

	;IN THIS STEP: SET CS PIN LOW 
	LDR R1, =GPIOB_ODR_OFFSET
	LDR R0, [R1]
	MOV R3, #1
	LSL R3, #6
	MVN R3, R3
	AND R0, R0, R3
	STR R0, [R1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOFTWARE INITIALIZATION SEQUENCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;IN THIS STEP: ISSUE THE "SET CONTRAST" COMMAND, ITS HEX CODE IS 0xC5
	MOV R2, #0xC5
	BL LCD_COMMAND_WRITE

	;THIS COMMAND REQUIRES 2 PARAMETERS TO BE SENT AS DATA, THE VCOM H, AND THE VCOM L
	;WE WANT TO SET VCOM H TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 1111111 OR 0x7F HEXA
	;IN THIS STEP: SEND THE FIRST PARAMETER (THE VCOM H) NEEDED BY THE COMMAND, WITH HEX 0x7F, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	MOV R2, #0x7F
	BL LCD_DATA_WRITE

	;WE WANT TO SET VCOM L TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 00000000 OR 0x00 HEXA
	;IN THIS STEP: SEND THE SECOND PARAMETER (THE VCOM L) NEEDED BY THE CONTRAST COMMAND, WITH HEX 0x00, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	MOV R2, #0x00
	BL LCD_DATA_WRITE


	;MEMORY ACCESS CONTROL AKA MADCLT | DATASHEET PAGE 127
	;WE WANT TO SET MX (to draw from left to right) AND SET MV (to configure the TFT to be in horizontal landscape mode, not a vertical screen)
	;IN THIS STEP: ISSUE THE COMMAND MEMORY ACCESS CONTROL, HEXCODE 0x36
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	;IN THIS STEP: SEND ONE NEEDED PARAMETER ONLY WITH MX AND MV SET TO 1. HOW WILL WE SEND PARAMETERS? AS DATA OR AS COMMAND?
	MOV R2, #0x28
	BL LCD_DATA_WRITE



	;COLMOD: PIXEL FORMAT SET | DATASHEET PAGE 134
	;THIS COMMAND LETS US CHOOSE WHETHER WE WANT TO USE 16-BIT COLORS OR 18-BIT COLORS.
	;WE WILL ALWAYS USE 16-BIT COLORS
	;IN THIS STEP: ISSUE THE COMMAND COLMOD
	MOV R2, #0x3A
	BL LCD_COMMAND_WRITE

	;IN THIS STEP: SEND THE NEEDED PARAMETER WHICH CORRESPONDS TO 16-BIT RGB AND 16-BIT MCU INTERFACE FORMAT
	MOV R2, #0x55
	BL LCD_DATA_WRITE
	


	;SLEEP OUT | DATASHEET PAGE 101
	;IN THIS STEP: ISSUE THE SLEEP OUT COMMAND TO EXIT SLEEP MODE (THIS COMMAND TAKES NO PARAMETERS, JUST SEND THE COMMAND)
	MOV R2, #0x11
	BL LCD_COMMAND_WRITE

	;NECESSARY TO WAIT 5ms BEFORE SENDING NEXT COMMAND
	;I WILL WAIT FOR 10MSEC TO BE SURE
	;IN THIS STEP: DELAY FOR AT LEAST 10ms
	BL delay_1_second


	;DISPLAY ON | DATASHEET PAGE 109
	;IN THIS STEP: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV R2, #0x29
	BL LCD_COMMAND_WRITE


	;COLOR INVERSION OFF | DATASHEET PAGE 105
	;NOTE: SOME TFTs HAS COLOR INVERTED BY DEFAULT, SO YOU WOULD HAVE TO INVERT THE COLOR MANUALLY SO COLORS APPEAR NATURAL
	;MEANING THAT IF THE COLORS ARE INVERTED WHILE YOU ALREADY TURNED OFF INVERSION, YOU HAVE TO TURN ON INVERSION NOT TURN IT OFF.
	;IN THIS STEP: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV R2, #0x20
	BL LCD_COMMAND_WRITE



	;MEMORY WRITE | DATASHEET PAGE 245
	;WE NEED TO PREPARE OUR TFT TO SEND PIXEL DATA, MEMORY WRITE SHOULD ALWAYS BE ISSUED BEFORE ANY PIXEL DATA SENT
	;IN THIS STEP: ISSUE MEMORY WRITE COMMAND
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE	


	;IN THIS STEP: POP ALL PUSHED REGISTERS
	POP {R0-R3, PC}
	ENDFUNC
	
	
;%%%%%%%%%%%%%%%%%%%%%% DELAYS %%%%%%%%%%%%%%%%%

delay_1_second FUNCTION
	;this function just delays for 1 second
	PUSH {R8, LR}
	LDR R8, =INTERVAL
delay_loop
	SUBS R8, #1
	CMP R8, #0
	BGE delay_loop
	POP {R8, PC}	
	ENDFUNC
	

delay_10_milli_second FUNCTION
	;this function just delays for 10 millisecondS
	PUSH {R8, LR}
	LDR R8, =INTERVAL
delay_loop3
	SUBS R8, #100	
	CMP R8, #0
	BGE delay_loop3

	POP {R8, PC}
	ENDFUNC
	
delay_milli_second FUNCTION
	;this function just delays for 10 millisecondS
	PUSH {R8, LR}
	LDR R8, =INTERVAL
delay_loop4
	SUBS R8, #1000	
	CMP R8, #0
	BGE delay_loop4

	POP {R8, PC}
	ENDFUNC


	B LTORG_LABEL2
	LTORG
LTORG_LABEL2
;%%%%%%%%%%%%%%%%%% SNAKE GAME LAYOUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BACKGROUND FUNCTION
	PUSH {R0-R10, LR}
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #280
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, LR}
	ENDFUNC
GAME_1 FUNCTION  ; DRAW BACKGROUND OF THE GAME
	PUSH {R0-R10, LR}
; RASM HARF EL G
 ; -
	MOV R0, #30
    MOV R1, #30
    MOV R3, #70
    MOV R4, #40
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; |
	MOV R0, #30
    MOV R1, #30
    MOV R3, #40
    MOV R4, #80
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; _	
	MOV R0, #30
    MOV R1, #80
    MOV R3, #70
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; 	
	MOV R0, #60
    MOV R1, #60
    MOV R3, #70
    MOV R4, #80
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #50
    MOV R1, #60
    MOV R3, #65
    MOV R4, #70
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DRAW A
	
	MOV R0, #90
    MOV R1, #30
    MOV R3, #100
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #120
    MOV R1, #30
    MOV R3, #130
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #30
    MOV R3, #130
    MOV R4, #40
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #60
    MOV R3, #130
    MOV R4, #70
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED

	B LTORG_LABEL3
	LTORG
LTORG_LABEL3
	; DRAW M
	
	MOV R0, #150
    MOV R1, #30
    MOV R3, #160
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #160
    MOV R1, #40
    MOV R3, #170
    MOV R4, #50
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #170
    MOV R1, #45
    MOV R3, #180
    MOV R4, #55
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #180
    MOV R1, #40
    MOV R3, #190
    MOV R4, #50
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #190
    MOV R1, #30
    MOV R3, #200
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	; DRAW E
	MOV R0, #220
    MOV R1, #30
    MOV R3, #230
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #30
    MOV R3, #260
    MOV R4, #40
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #80
    MOV R3, #260
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #55
    MOV R3, #260
    MOV R4, #65
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;DRAW 1
	
	MOV R0, #295
    MOV R1, #30
    MOV R3, #305
    MOV R4, #90
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, PC}
	ENDFUNC
	
GAME_2 FUNCTION
	PUSH {R0-R10, LR}
	; RASM HARF EL G
 ; -
	MOV R0, #30
    MOV R1, #130
    MOV R3, #70
    MOV R4, #140
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; |
	MOV R0, #30
    MOV R1, #130
    MOV R3, #40
    MOV R4, #180
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; _	
	MOV R0, #30
    MOV R1, #180
    MOV R3, #70
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
; 	
	MOV R0, #60
    MOV R1, #160
    MOV R3, #70
    MOV R4, #180
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #50
    MOV R1, #160
    MOV R3, #65
    MOV R4, #170
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DRAW A
	
	MOV R0, #90
    MOV R1, #130
    MOV R3, #100
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #120
    MOV R1, #130
    MOV R3, #130
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #130
    MOV R3, #130
    MOV R4, #140
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #160
    MOV R3, #130
    MOV R4, #170
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	; DRAW M
	
	MOV R0, #150
    MOV R1, #130
    MOV R3, #160
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #160
    MOV R1, #140
    MOV R3, #170
    MOV R4, #150
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #170
    MOV R1, #145
    MOV R3, #180
    MOV R4, #155
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #180
    MOV R1, #140
    MOV R3, #190
    MOV R4, #150
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #190
    MOV R1, #130
    MOV R3, #200
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	; DRAW E
	MOV R0, #220
    MOV R1, #130
    MOV R3, #230
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #130
    MOV R3, #260
    MOV R4, #140
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #180
    MOV R3, #260
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #155
    MOV R3, #260
    MOV R4, #165
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;DRAW 2
	
	MOV R0, #280
    MOV R1, #130
    MOV R3, #315
    MOV R4, #140
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #280
    MOV R1, #180
    MOV R3, #315
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
    MOV R0, #280
    MOV R1, #155
    MOV R3, #315
    MOV R4, #165
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #305
    MOV R1, #130
    MOV R3, #315
    MOV R4, #160
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #280
    MOV R1, #160
    MOV R3, #290
    MOV R4, #190
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, PC}
	ENDFUNC
	
GAMEOVER FUNCTION
	PUSH {R0-R10, LR}
; RASM HARF EL G
 ; -
	MOV R0, #30
    MOV R1, #30
    MOV R3, #70
    MOV R4, #40
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; |
	MOV R0, #30
    MOV R1, #30
    MOV R3, #40
    MOV R4, #80
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; _	
	MOV R0, #30
    MOV R1, #80
    MOV R3, #70
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; 	
	MOV R0, #60
    MOV R1, #60
    MOV R3, #70
    MOV R4, #80
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #50
    MOV R1, #60
    MOV R3, #65
    MOV R4, #70
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DRAW A
	
	MOV R0, #90
    MOV R1, #30
    MOV R3, #100
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #120
    MOV R1, #30
    MOV R3, #130
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #30
    MOV R3, #130
    MOV R4, #40
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #90
    MOV R1, #60
    MOV R3, #130
    MOV R4, #70
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0,#30
	MOV R1,#90
	MOV R2,#40
	MOV R3,#140
	MOV R10, #WHITE
	BL DRAW_RECTANGLE_FILLED

	
	B LTORG_LABEL77
	LTORG
LTORG_LABEL77
	; DRAW M
	
	MOV R0, #150
    MOV R1, #30
    MOV R3, #160
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #160
    MOV R1, #40
    MOV R3, #170
    MOV R4, #50
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #170
    MOV R1, #45
    MOV R3, #180
    MOV R4, #55
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #180
    MOV R1, #40
    MOV R3, #190
    MOV R4, #50
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #190
    MOV R1, #30
    MOV R3, #200
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	; DRAW E
	MOV R0, #220
    MOV R1, #30
    MOV R3, #230
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #30
    MOV R3, #260
    MOV R4, #40
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #80
    MOV R3, #260
    MOV R4, #90
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #55
    MOV R3, #260
    MOV R4, #65
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;DRAW O
	
	MOV R0, #30
    MOV R1, #130
    MOV R3, #70
    MOV R4, #140
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; |
	MOV R0, #30
    MOV R1, #130
    MOV R3, #40
    MOV R4, #180
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; _	
	MOV R0, #30
    MOV R1, #180
    MOV R3, #70
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
; 	
	MOV R0, #60
    MOV R1, #130
    MOV R3, #70
    MOV R4, #180
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DRAW V
	
	MOV R0, #90
    MOV R1, #130
    MOV R3, #100
    MOV R4, #185
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #100
    MOV R1, #180
    MOV R3, #110
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #110
    MOV R1, #190
    MOV R3, #120
    MOV R4, #195
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R0, #120
    MOV R1, #180
    MOV R3, #130
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #130
    MOV R1, #130
    MOV R3, #140
    MOV R4, #185
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; DRAW E
	MOV R0, #155
    MOV R1, #130
    MOV R3, #165
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #155
    MOV R1, #130
    MOV R3, #195
    MOV R4, #140
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #155
    MOV R1, #180
    MOV R3, #195
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #155
    MOV R1, #155
    MOV R3, #195
    MOV R4, #165
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; DRAW R
	MOV R0, #220
    MOV R1, #130
    MOV R3, #230
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #220
    MOV R1, #130
    MOV R3, #260
    MOV R4, #140
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R0, #220
    MOV R1, #155
    MOV R3, #260
    MOV R4, #165
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R0, #250
    MOV R1, #130
    MOV R3, #260
    MOV R4, #165
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #245
    MOV R1, #165
    MOV R3, #255
    MOV R4, #190
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	
	
	POP {R0-R10, PC}
	ENDFUNC
	
 
	
	
  END
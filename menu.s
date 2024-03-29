	INCLUDE DINO.s

	
  EXPORT __main
	IMPORT SNAKE_GAME
	IMPORT SNAKE_BACKGROUND
	IMPORT SNAKE_HEAD
	IMPORT MOVEHEADLEFT
	IMPORT DELETEHEAD
	IMPORT SNAKE_TAIL
	
  AREA MYCODE, CODE, READONLY
	ENTRY


	
		
__main FUNCTION
	BL SETUP
	
	BL BACKGROUND
	BL GAME_1
	BL GAME_2
	BL INITIALIZE_VARIABLES

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	LDR R0,=GPIOB_IDR_OFFSET
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
INF

	;CHECK IF DOWN BUTTON IS PRESSED, THEN MOVE THE CURSOR IF PRESSED

	LDR R1,[R0]
	;CHECK down
	MOV R2, #1
	AND R1, R1, R2, LSL #10
	CMP R1,#0
	BNE checkUp
	
repeatDown
	LDR R0,=GPIOB_IDR_OFFSET
	LDR R1,[R0]
	MOV R2, #1
	AND R1, R1, R2, LSL #10
	CMP R1,#0
	
	BEQ repeatDown
	BL DINO_GAME

	
	;CHECK IF UP BUTTON IS PRESSED, THEN MOVE THE CURSOR IF PRESSED
	
checkUp
	LDR R0,=GPIOB_IDR_OFFSET
	LDR R1,[R0]
	;CHECK RIGHT
	MOV R2, #1
	AND R1, R1, R2, LSL #11
	CMP R1,#0
	BNE INF
	
repeatUp
	LDR R1,[R0]
	MOV R2, #1
	AND R1, R1, R2, LSL #11
	CMP R1,#0
	BEQ repeatUp
	BL SNAKE_GAME

	B INF
	
	ENDFUNC
	
	
	

	
INITIALIZE_VARIABLES	FUNCTION
	PUSH{R0-R12,LR}
	;THIS FUNCTION JUST INITIALIZES ANY VARIABLE IN THE DATASECTION TO ITS INITIAL VALUES
	;ALTHOUGH WE SPECIFIED SOME VALUES IN THE DATA AREA, BUT THEIR VALUES MIGHT BE ALTERED DURING BOOT TIME.
	;SO WE NEED TO IMPLEMENT THIS FUNCTION THAT REINITIALIZES ALL VARIABLES
	
	; INITIALIZE STARTING_X TO 150, NOTICE THAT STARTING_X IS DECLARED AS 16-BITS
	LDR R0, =CURSOR_X
	MOV R1,#8
	STRH R1,[R0]
	
	LDR R0,=CURSOR_Y
	MOV R1, #55
	STRH R1,[R0]
	
	LDR R0,=CACTUS1_X
	MOV R1, #150 ;125
	STRH R1,[R0]
	
	LDR R0,=CACTUS1_Y
	MOV R1, #180
	STRH R1,[R0]
	
	LDR R0,=CACTUS2_X
	MOV R1, #300 ;245
	STRH R1,[R0]
	
	LDR R0,=CACTUS2_Y
	MOV R1, #180
	STRH R1,[R0]
	
	LDR R0,=DINO_X
	MOV R1, #30
	STRH R1,[R0]
	
	LDR R0,=DINO_Y
	MOV R1, #175
	STRH R1,[R0]
	
	LDR R0,=MAX_HEIGHTT
	MOV R1, #144
	STRH R1,[R0]
	

	; INITIALIZE STARTING_Y TO 170, NOTICE THAT STARTING_Y IS DECLARED AS 16-BITS
	
	POP{R0-R12,PC}
	ENDFUNC
	

	
	END
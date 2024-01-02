	INCLUDE TFT.s
	
	
	AREA DINOCODE, CODE, READONLY
		
		
		
DINO_GAME FUNCTION
	PUSH{R0-R12,LR}
	; %%%%%%%%%%%%%%%%%%%%
	BL DINO_BACKGROUND
	BL CLOUD
	BL DINO_PLAYER
	BL CACTUS1
	BL CACTUS2
	BL SUN
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	MOV R11,#4
MOVING	
	MOV R5,#12 ;COUNTER UP 
	MOV R6,#12   ;COUNTER DOWN



INF1

	LDR R0,=GPIOB_IDR_OFFSET
		B DUMMY_LBL8
	LTORG
DUMMY_LBL8


	BL delay_milli_second  ;MOVING BACKGROUND 
	BL DELETE_CACTUS1
	CMP R11,#0
	BLE FAST3
	BL MOVELEFT
	B CONT3
FAST3
	BL delay_milli_second
	BL MOVELEFTFASTER
CONT3	
	BL DELETE_CACTUS2
	CMP R11,#0
	BLE FAST4
	BL MOVELEFT2
	B CONT4
FAST4
	BL delay_milli_second
	BL MOVELEFTFASTER2
CONT4	
	BL LOSE_CONDITION
	
	LDR R1,[R0]
	;CHECK UP
	MOV R2, #1
	AND R1, R1, R2, LSL #11
	CMP R1,#0
	
	BNE INF1
	
repeatUp2      ;CHECK BUTTON IS NOT HELD
	LDR R1,[R0]
	MOV R2, #1
	AND R1, R1, R2, LSL #11
	CMP R1,#0
	BEQ repeatUp2
	SUB R11,R11,#1
	BL UP
	B INF1
	
UP 
	BL delay_milli_second  ;MOVING BACKGROUND IN UP
	BL DELETE_CACTUS1
	CMP R11,#0
	BLE FAST
	BL MOVELEFT
	B CONT
FAST
	BL delay_milli_second
	BL MOVELEFTFASTER
CONT	
	BL DELETE_CACTUS2
	CMP R11,#0
	BLE FAST2
	BL MOVELEFT2
	B CONT2
FAST2
	BL delay_milli_second
	BL MOVELEFTFASTER2
CONT2
	BL LOSE_CONDITION
	
	;MOVING DINO UP
	BL DELETE_DINO
	BL DINO_UP
	SUB R5,R5,#1
	CMP R5,#0
	BGE  UP
	BL LOSE_CONDITION
	
DOWN
    BL delay_milli_second ;MOVING BACKGROUND IN DOWN
	BL DELETE_CACTUS1
	CMP R11,#0
	BLE FAST5
	BL MOVELEFT
	B CONT5
FAST5 
	BL delay_milli_second
	BL MOVELEFTFASTER
CONT5	
	BL DELETE_CACTUS2
	CMP R11,#0
	BLE FAST6
	BL MOVELEFT2
	B CONT6
FAST6
	BL delay_milli_second
	BL MOVELEFTFASTER2
CONT6	
	BL LOSE_CONDITION
	
	;MOVIND DINO DOWN
	BL DELETE_DINO
	BL DINO_DOWN
	SUB R6,R6,#1
	CMP R6,#0
	BEQ SKIP_BACKGROUND_ADVANCE
	BL LOSE_CONDITION
	BL  DOWN
	

BACKGROUND_ADVANCE
    BL delay_milli_second
	BL DELETE_CACTUS1
	CMP R11,#0
	BLE FAST7
	BL MOVELEFT
	B CONT7
FAST7
	BL delay_milli_second
	BL MOVELEFTFASTER
CONT7	
	BL DELETE_CACTUS2
	CMP R11,#0
	BLE FAST8
	BL MOVELEFT2
	B CONT8
FAST8 
	BL delay_milli_second
	BL MOVELEFTFASTER2
CONT8	
	BL LOSE_CONDITION
SKIP_BACKGROUND_ADVANCE
	
	B MOVING
	
	
STOP
	B STOP
	
	POP{R0-R12,PC}
	
	ENDFUNC
	
	
	
	
DINO_BACKGROUND FUNCTION  ; DRAW BACKGROUND OF THE GAME
	PUSH {R0-R10, LR}
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #280
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #0 ;X1
    MOV R1, #210  ;Y1
    MOV R3, #320 ;X2
    MOV R4, #215 ;Y2
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, PC}
	ENDFUNC

CACTUS1 FUNCTION   ; DRAW CACTUS
	PUSH {R0-R10, LR}
		
	LDR R9,=CACTUS1_X 
	LDR R8,=CACTUS1_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	
	ADD R0,R6,#5  ;  CACTUS1 TALL RECT
	MOV R1,R7
    ADD R3,R6,#15
    ADD R4,R7,#45
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R0,R6 ;125  ;  CACTUS2 SHORT RECT
	ADD R1,R7,#10 ;190
    ADD R3,R6,#20 ; 145
    ADD R4,R7,#20 ;200
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	POP {R0-R10, PC}
	ENDFUNC

CACTUS2 FUNCTION
	PUSH {R0-R10, LR}
	LDR R9,=CACTUS2_X
	LDR R8,=CACTUS2_Y
	LDRH R6,[R9] 
    LDRH R7,[R8] 
	
	ADD R0,R6,#5    ;CACTUS2 TALLER RECT
	MOV R1,R7
    ADD R3,R6,#15
    ADD R4,R7,#45
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R0,R6 ;125   ;CACTUS2 SHORT RECT
	ADD R1,R7,#10 ;190
    ADD R3,R6,#20 ; 145
    ADD R4,R7,#20 ;200
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	POP {R0-R10, PC}
	ENDFUNC

CLOUD FUNCTION
	
	PUSH {R0-R10, LR}
	 ; %%%%%%%%%%%%%%%%%%%%CLOUD 1
	MOV R0, #50
    MOV R1, #50
    MOV R3, #100
    MOV R4, #57
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #60
    MOV R1, #45
    MOV R3, #90
    MOV R4, #50
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	;CLOUD2
	MOV R0, #150
    MOV R1, #50
    MOV R3, #200
    MOV R4, #57
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #160
    MOV R1, #45
    MOV R3, #190
    MOV R4, #50
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	;CLOUD 3
	MOV R0, #250
    MOV R1, #50
    MOV R3, #300
    MOV R4, #57
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #260
    MOV R1, #45
    MOV R3, #290
    MOV R4, #50
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED
	
	POP {R0-R10, PC}
	ENDFUNC
	
DINO_PLAYER FUNCTION   ; DRAW DINO
	PUSH {R0-R10, LR}
	
	LDR R9,=DINO_X 
	LDR R8,=DINO_Y
	LDRH R6,[R9] ;X =30
    LDRH R7,[R8] ;Y =175
	
	MOV R0,R6      ;X
    ADD R1,R7,#30   ;Y
    ADD R3,R6,#10    ;X2
    ADD R4,R7,#34   ;Y2
    MOV R10, #GREEN    
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#15
    ADD R1,R7,#30
    ADD R3,R6,#25
    ADD R4,R7,#34
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0,R6  ;LEFT LEG
    ADD R1,R7,#25
    ADD R3,R6,#2
    ADD R4,R7,#30
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#15   ;RIGH LEG
    ADD R1,R7,#25
    ADD R3,R6,#17
    ADD R4,R7,#30
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0,R6   ;BODY
    ADD R1,R7,#15
    ADD R3,R6,#25
    ADD R4,R7,#25
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#10   ;BODY
    ADD R1,R7,#5
    ADD R3,R6,#15
    ADD R4,R7,#15
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
		
	ADD R0,R6,#10   ;BODY
    MOV R1,R7
    ADD R3,R6,#25
    ADD R4,R7,#5
    MOV R10, #GREEN
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#20   ;EYE
    ADD R1,R7,#2
    ADD R3,R6,#22
    ADD R4,R7,#3
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, PC}
	ENDFUNC
DELETE_DINO FUNCTION   ;DRAW OVER DINO WITH BACKGROUND COLOR
	PUSH {R0-R10, LR}
    LDR R9,=DINO_X 
	LDR R8,=DINO_Y
	LDRH R6,[R9] ;X =30
    LDRH R7,[R8] ;Y =175
	
	MOV R0,R6      ;X
    ADD R1,R7,#30   ;Y
    ADD R3,R6,#10    ;X2
    ADD R4,R7,#34   ;Y2
    MOV R10, #WHITE    
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#15
    ADD R1,R7,#30
    ADD R3,R6,#25
    ADD R4,R7,#34
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0,R6  ;LEFT LEG
    ADD R1,R7,#25
    ADD R3,R6,#2
    ADD R4,R7,#30
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#15   ;RIGH LEG
    ADD R1,R7,#25
    ADD R3,R6,#17
    ADD R4,R7,#30
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0,R6   ;BODY
    ADD R1,R7,#15
    ADD R3,R6,#25
    ADD R4,R7,#25
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#10   ;BODY
    ADD R1,R7,#5
    ADD R3,R6,#15
    ADD R4,R7,#15
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
		
	ADD R0,R6,#10   ;BODY
    MOV R1,R7
    ADD R3,R6,#25
    ADD R4,R7,#5
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	ADD R0,R6,#20   ;EYE
    ADD R1,R7,#2
    ADD R3,R6,#22
    ADD R4,R7,#3
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	POP {R0-R10, PC}
	ENDFUNC

DINO_UP FUNCTION
	
	PUSH {R0-R10, LR}
    LDR R9,=DINO_X 
	LDR R8,=DINO_Y
	LDRH R6,[R9] ;X =30
    LDRH R7,[R8] ;Y =175
	;DECREMENTING Y TO MOVE UP
	CMP R7,#115
	BLE MAX_HEIGHT 
	SUB R7,R7,#5
	STRH R7,[R8]
	BL DINO_PLAYER
	
	
MAX_HEIGHT 
	BL DINO_PLAYER   ;DRAW DINO IN AIR AFTER LAST ERASE
	
	POP {R0-R10, PC}
	ENDFUNC
	
DINO_DOWN FUNCTION
	PUSH {R0-R10, LR}
    LDR R9,=DINO_X 
	LDR R8,=DINO_Y
	LDRH R6,[R9] ;X =30
    LDRH R7,[R8] ;Y =144
	;INCREMENTING Y TO MOVE DOWN
	ADD R7,R7,#5
	CMP R7,#175
	BGE MM
	STRH R7,[R8]
	BL DINO_PLAYER
MM	
	BL DINO_PLAYER ;DRAW DINO ON GROUND AFTER LAST ERASE
	POP {R0-R10, PC}
  ENDFUNC	
	

DELETE_CACTUS1 FUNCTION   ;DRAW OVER CACTUS WITH BAKGROUND COLOR
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS1_X 
	LDR R8,=CACTUS1_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	
	MOV R0,R6
	MOV R1,R7
    ADD R3,R6,#20
    ADD R4,R7,#45
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #0 ;X1
    MOV R1, #210  ;Y1
    MOV R3, #320 ;X2
    MOV R4, #215 ;Y2
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED

	POP{R0-R12,PC}
	ENDFUNC
	
MOVELEFT FUNCTION
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS1_X 
	LDR R8,=CACTUS1_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	SUB R6,R6,#4
	CMP R6,#0
	BGT CONTINUE
	MOV R6,#290
	
CONTINUE	
	STRH R6,[R9]
	
	BL CACTUS1
	
		
	POP{R0-R12,PC}
	ENDFUNC
	
DELETE_CACTUS2 FUNCTION
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS2_X 
	LDR R8,=CACTUS2_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	
	MOV R0,R6
	MOV R1,R7
    ADD R3,R6,#20
    ADD R4,R7,#45
    MOV R10, #WHITE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #0 ;X1
    MOV R1, #210  ;Y1
    MOV R3, #320 ;X2
    MOV R4, #215 ;Y2
    MOV R10, #BLACK
    BL DRAW_RECTANGLE_FILLED

	POP{R0-R12,PC}
	ENDFUNC
	
MOVELEFT2 FUNCTION
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS2_X 
	LDR R8,=CACTUS2_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	SUB R6,R6,#4
	CMP R6,#0
	BGT CONTINUE2
	MOV R6,#290
	
CONTINUE2	
	STRH R6,[R9]
	
	BL CACTUS2
	
		
	POP{R0-R12,PC}
	ENDFUNC
	
SUN FUNCTION
	PUSH{R0-R12,LR}
	
	MOV R0, #0 ;X1
    MOV R1, #0  ;Y1
    MOV R3, #20 ;X2
    MOV R4, #20 ;Y2
    MOV R10, #YELLOW
    BL DRAW_RECTANGLE_FILLED

	MOV R0, #0 ;X1
    MOV R1, #0  ;Y1
    MOV R3, #30 ;X2
    MOV R4, #30 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #0 ;X1
    MOV R1, #0  ;Y1
    MOV R3, #27 ;X2
    MOV R4, #27 ;Y2
    MOV R10, #YELLOW
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #6 ;X1
    MOV R1, #30  ;Y1
    MOV R3, #8 ;X2
    MOV R4, #35 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED

	
	MOV R0, #12 ;X1
    MOV R1, #30  ;Y1
    MOV R3, #14 ;X2
    MOV R4, #35 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #18 ;X1
    MOV R1, #30  ;Y1
    MOV R3, #20 ;X2
    MOV R4, #35 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED
;-----------------------------	
	MOV R0, #30 ;X1
    MOV R1, #6  ;Y1
    MOV R3, #35 ;X2
    MOV R4, #8 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED

	
	MOV R0, #30 ;X1
    MOV R1, #12  ;Y1
    MOV R3, #35 ;X2
    MOV R4, #14 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED
	
	MOV R0, #30 ;X1
    MOV R1, #18  ;Y1
    MOV R3, #35 ;X2
    MOV R4, #20 ;Y2
    MOV R10, #ORANGE
    BL DRAW_RECTANGLE_FILLED



	POP{R0-R12,PC}

	ENDFUNC

LOSE_CONDITION FUNCTION
	PUSH{R0-R12,LR}
	;55 is dino max x
	;dino head height@ 175
	;#(55,175)
	
    LDR R0,=DINO_X 
	LDR R1,=DINO_Y
	LDRH R2,[R0] ;X =30
    LDRH R3,[R1] ;Y =175
	ADD R3,R3,#34
	
	LDR R4,=CACTUS1_X 
	LDR R5,=CACTUS1_Y
	LDRH R6,[R4] ;X =125
    LDRH R7,[R5] ;Y =180
	
	LDR R8,=CACTUS2_X
	LDR R9,=CACTUS2_Y
	LDRH R10,[R8] 
    LDRH R11,[R9] 
	
	CMP R6,#50  ;55
	BGE OK
	
		
	CMP R3,#190 ;175
	BLT OK
	BGE LOSS_LBL
	
LOSS_LBL
	BL LOSS
	
OK	
	CMP R10,#50
	BGE OK2
	
		
	CMP R3,#180
	BLT OK2
	BGE LOSS_LBL2
	
LOSS_LBL2
	BL LOSS
	
OK2
	POP{R0-R12,PC}
	ENDFUNC
	
LOSS FUNCTION
	PUSH {R0-R10, LR}
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #280
    MOV R10, #RED
    BL DRAW_RECTANGLE_FILLED
	BL GAMEOVER
ENDGAME

	B ENDGAME
	POP{R0-R10,PC}
	
	ENDFUNC
MOVELEFTFASTER FUNCTION
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS1_X 
	LDR R8,=CACTUS1_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	SUB R6,R6,#5
	CMP R6,#0
	BGT CONTINUE3
	MOV R6,#290
	
CONTINUE3	
	STRH R6,[R9]
	
	BL CACTUS1		
	POP{R0-R12,PC}
	ENDFUNC
	
MOVELEFTFASTER2 FUNCTION
	PUSH{R0-R12,LR}
	LDR R9,=CACTUS2_X 
	LDR R8,=CACTUS2_Y
	LDRH R6,[R9] ;X =125
    LDRH R7,[R8] ;Y =180
	SUB R6,R6,#5
	CMP R6,#0
	BGT CONTINUE4
	MOV R6,#290
	
CONTINUE4	
	STRH R6,[R9]
	
	BL CACTUS2		
	POP{R0-R12,PC}
	ENDFUNC	
	
	
END
	
	
	
	

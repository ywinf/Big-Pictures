; Scene demo - stronger variation / alternating directions
; Final ROM used for the visual demo.
; Ground line first, then Scene A init.
    ADDI R1, R0, -1
    STORE R1, [R0 + 0xfe]
; Scene A init: build left-to-right scene state in registers.
; R1,R2 are flying object rows; R3..R7 are walker rows.
scene_a_init:
    ADDI R1, R0, 0x18
    ADDI R2, R0, 0x3c
    ADDI R3, R0, 0x4
    ADDI R4, R0, 0xe
    ADDI R5, R0, 0x4
    ADDI R6, R0, 0xa
    ADDI R7, R0, 0x11
; Initial left placement by repeated SHL on walker rows.
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
; Scene A loop: draw, add stronger variation on two walker rows,
; then move flyer and walker in opposite directions.
scene_a_loop:
    STORE R1, [R0 + 0xf1]
    STORE R2, [R0 + 0xf2]
    STORE R3, [R0 + 0xf9]
    STORE R4, [R0 + 0xfa]
    STORE R5, [R0 + 0xfb]
    STORE R6, [R0 + 0xfc]
    STORE R7, [R0 + 0xfd]
    SHL R5, R5
    SHL R7, R7
    STORE R1, [R0 + 0xf1]
    STORE R2, [R0 + 0xf2]
    STORE R3, [R0 + 0xf9]
    STORE R4, [R0 + 0xfa]
    STORE R5, [R0 + 0xfb]
    STORE R6, [R0 + 0xfc]
    STORE R7, [R0 + 0xfd]
    SHR R5, R5
    SHR R7, R7
    SHL R1, R1
    SHL R2, R2
    SHR R3, R3
    SHR R4, R4
    SHR R5, R5
    SHR R6, R6
    SHR R7, R7
    BNE R7, R0, scene_a_loop
    JMP scene_b_init
; Scene B init: rebuild mirrored direction state.
scene_b_init:
    ADDI R1, R0, -1
    STORE R1, [R0 + 0xfe]
    ADDI R1, R0, 0x18
    ADDI R2, R0, 0x3c
    ADDI R3, R0, 0x4
    ADDI R4, R0, 0xe
    ADDI R5, R0, 0x4
    ADDI R6, R0, 0xa
    ADDI R7, R0, 0x11
; Initial placement for Scene B by repeated SHL on flyer rows.
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
    SHL R1, R1
    SHL R2, R2
; Scene B loop: mirrored draw/variation/move sequence.
scene_b_loop:
    STORE R1, [R0 + 0xf1]
    STORE R2, [R0 + 0xf2]
    STORE R3, [R0 + 0xf9]
    STORE R4, [R0 + 0xfa]
    STORE R5, [R0 + 0xfb]
    STORE R6, [R0 + 0xfc]
    STORE R7, [R0 + 0xfd]
    SHR R5, R5
    SHR R7, R7
    STORE R1, [R0 + 0xf1]
    STORE R2, [R0 + 0xf2]
    STORE R3, [R0 + 0xf9]
    STORE R4, [R0 + 0xfa]
    STORE R5, [R0 + 0xfb]
    STORE R6, [R0 + 0xfc]
    STORE R7, [R0 + 0xfd]
    SHL R5, R5
    SHL R7, R7
    SHR R1, R1
    SHR R2, R2
    SHL R3, R3
    SHL R4, R4
    SHL R5, R5
    SHL R6, R6
    SHL R7, R7
    BNE R7, R0, scene_b_loop
    JMP scene_a_init
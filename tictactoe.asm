// File: tictactoe.asm
// Author: Connell Reffo
// Description:
// Recreates the Game Tic Tac Toe using A64 Assembly

define(int_bytes, 4)					// 32-bit integer = 4 bytes
define(bool_bytes, 1)					// Boolean value = 1 byte (smallest addressable unit)

define(scanf_ret_s, 16)					// Will be stack offset for return address of scanf
define(turn_s, scanf_ret_s + int_bytes)			// 0 if X turn; 1 if O turn

define(all_s, turn_s + bool_bytes)			// Offset of all stack variables combined

define(alloc, -(all_s) & 16)				// Stack memory to be allocated
define(dealloc, -alloc)					// Stack memory to be deallocated

define(turn_r, w19)					// Register designated for loading turn
define(x_r, w20)					// Register to hold inputted x coordinate
define(y_r, w21)					// Register to hold inputted y coordinate


initial_prompt_str:
	.string	"Tic Tac Toe (Enter a Negative Number to Exit)\n"

x_pos_prompt_str:
	.string	"Enter a X Position [0, 2]: "

y_pos_prompt_str:
	.string	"Enter a Y Position [0, 2]: "

scanf_fmt:
	.string "%d"					// Format string for scanf; "%d" specifies decimal integer

x_turn_prompt_str:
	.string "\nTurn for X\n"

o_turn_prompt_str:
	.string	"\nTurn for O\n"


	.balign	4
	.global main

main:
	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	mov	turn_r, 0				// turn_r = 0
	strb	turn_r, [fp, turn_s]			// turn = turn_r (X turn by default)

	ldr	x0, =initial_prompt_str
	bl	printf

next_turn_start:
	ldrsb	turn_r, [sp, turn_s]			// turn_r = turn
	mov	w20, 0

	cmp	turn_r, w20				// turn_r == w20?
	b.eq	x_turn					// Goto x_turn if turn_r == 0
	b	o_turn					// Goto o_turn otherwise

x_turn:
	ldr	x0, =x_turn_prompt_str
	bl	printf

	b	turn_input

o_turn:
	ldr	x0, =o_turn_prompt_str
	bl	printf

turn_input:
	mov	w27, 0					// w27 = 0

	ldr	x0, =x_pos_prompt_str
	bl	printf

	ldr	x0, =scanf_fmt
	add	x1, fp, scanf_ret_s
	bl	scanf
	ldr	x_r, [fp, scanf_ret_s]			// x_r is input from user

	cmp	x_r, w27				// x_r < w27?
	b.lt	exit					// Exit if true

	ldr	x0, =y_pos_prompt_str
	bl	printf

	ldr	x0, =scanf_fmt
	add	x1, fp, scanf_ret_s
	bl	scanf
	ldr	y_r, [fp, scanf_ret_s]			// y_r is input from user

	cmp	y_r, w27				// y_r < w27?
	b.lt	exit					// Exit if true

	mvn	turn_r, turn_r				// Flip every bit in turn_r
	strb	turn_r, [fp, turn_s]			// turn = turn_r

	b	next_turn_start

exit:
	mov	x0, 0
	ldp	fp, lr, [sp], dealloc
	ret

// File: tictactoe.asm
// Author: Connell Reffo
// Description:
// Recreates the Game Tic Tac Toe using A64 Assembly

define(int_bytes, 4)					// 32-bit integer = 4 bytes
define(bool_bytes, 1)					// Boolean value = 1 byte (smallest addressable unit)

define(dim1, 3)						// First dimension of grid array
define(dim2, 3)						// Second dimension of grid array
define(grid_bytes, dim1 * dim2 * int_bytes)		// Bytes of memory used to store 3x3 grid array

define(scanf_ret_s, 16)					// Will be stack offset for return address of scanf
define(turn_s, scanf_ret_s + int_bytes)			// 0 if X turn; 1 if O turn
define(grid_s, turn_s + bool_bytes)			// Offset for grid array

define(all_s, grid_s + grid_bytes)			// Offset of all stack variables combined

define(alloc, -(all_s) & 16)				// Stack memory to be allocated
define(dealloc, -alloc)					// Stack memory to be deallocated

define(turn_r, w19)					// Register designated for loading turn
define(x_r, w20)					// Register to hold inputted x coordinate
define(y_r, w21)					// Register to hold inputted y coordinate
define(grid_base_r, x22)				// Register to hold base address of grid array
define(offset_r, w23)					// Register to hold grid element offset address
define(i_r, w24)
define(j_r, w25)
define(turn_char_r, w26)

define(x_char, 88)
define(o_char, 79)
define(grid_char, 46)


clear_screen_sys_call:
	.string	"clear"

initial_prompt_str:
	.string	"Tic Tac Toe (Enter a Negative Number to Exit)\n"

x_pos_prompt_str:
	.string	"Enter a X Position [0, 2]: "

y_pos_prompt_str:
	.string	"Enter a Y Position [0, 2]: "

scanf_fmt:
	.string "%d"					// Format string for scanf; "%d" specifies decimal integer

new_line_fmt:
	.string "\n"

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

	mov	turn_char_r, x_char

	add	grid_base_r, fp, grid_s			// Calculate base address of grid array

	ldr	x0, =clear_screen_sys_call
	bl	system

init_grid_start:
	mov	i_r, 0
	mov	j_r, 0

init_grid_outer_loop:
	mov	w26, dim1				// w26 = dim1
	cmp	i_r, w26				// i_r < w26?
	b.ge	next_turn_start				// Goto next_turn_start if not

init_grid_inner_loop:
	mov	w26, dim2				// w26 = dim2
	cmp	j_r, w26				// j_r < w26?
	b.ge	init_grid_outer_end			// Goto init_grid_outer_end if not

	mul	offset_r, i_r, w26			// offset_r = i_r * dim2
	add	offset_r, offset_r, j_r			// offset_r = (i_r * dim2) + j_r
	lsl	offset_r, offset_r, 2			// offset_r = ((i * dim2) + j_r) * 4

	mov	w26, grid_char
	str	w26, [grid_base_r, offset_r, sxtw]

	add	j_r, j_r, 1				// j_r++
	b	init_grid_inner_loop			// Restart inner loop

init_grid_outer_end:
	mov	j_r, 0					// j_r = 0
	add	i_r, i_r, 1				// i_r++
	b	init_grid_outer_loop

next_turn_start:
	ldr	x0, =initial_prompt_str
	bl	printf

	ldrsb	turn_r, [sp, turn_s]			// turn_r = turn

							// Initialize loop counters
	mov	i_r, 0					// i_r = 0
	mov	j_r, 0					// j_r = 0

draw_grid_outer_loop:
	mov	w26, dim1				// w26 = dim1
	cmp	i_r, w26				// i_r < w26?
	b.ge	turn_condition				// Goto turn_condition if not

draw_grid_inner_loop:
	mov	w26, dim2				// w26 = dim2
	cmp	j_r, w26				// j_r < w26?
	b.ge	draw_grid_outer_end			// Goto draw_grid_outer_end if not

	mul	offset_r, i_r, w26			// offset_r = i_r * dim2
	add	offset_r, offset_r, j_r			// offset_r = (i_r * dim2) + j_r
	lsl	offset_r, offset_r, 2			// offset_r = ((i * dim2) + j_r) * 4

	ldr	w0, [grid_base_r, offset_r, sxtw]	// w0 = grid[i][j]
	bl	putchar					// Write grid character to standard output

	add	j_r, j_r, 1				// j_r++
	b	draw_grid_inner_loop			// Restart inner loop


draw_grid_outer_end:
	ldr	x0, =new_line_fmt
	bl	printf

	mov	j_r, 0					// j_r = 0
	add 	i_r, i_r, 1				// i_r++
	b	draw_grid_outer_loop

turn_condition:
	mov	w20, 0					// w20 = 0

	cmp	turn_r, w20				// turn_r == w20?
	b.eq	x_turn					// Goto x_turn if turn_r == 0
	b	o_turn					// Goto o_turn otherwise

x_turn:
	mov	turn_char_r, x_char

	ldr	x0, =x_turn_prompt_str
	bl	printf

	b	turn_input_x

o_turn:
	mov	turn_char_r, o_char

	ldr	x0, =o_turn_prompt_str
	bl	printf

turn_input_x:
	ldr	x0, =x_pos_prompt_str
	bl	printf

	ldr	x0, =scanf_fmt
	add	x1, fp, scanf_ret_s
	bl	scanf
	ldr	x_r, [fp, scanf_ret_s]			// x_r is input from user

	mov	w27, 0					// w27 = 0
	cmp	x_r, w27				// x_r < 0?
	b.lt	exit					// Exit if true

	mov	w27, dim1				// w27 = dim1
	cmp	x_r, w27				// x_r > dim1?
	b.gt	cap_x
	b	turn_input_y

cap_x:
	mov	x_r, (dim1 - 1)

turn_input_y:
	ldr	x0, =y_pos_prompt_str
	bl	printf

	ldr	x0, =scanf_fmt
	add	x1, fp, scanf_ret_s
	bl	scanf
	ldr	y_r, [fp, scanf_ret_s]			// y_r is input from user

	mov	w27, 0					// w27 = 0
	cmp	y_r, w27				// y_r < 0?
	b.lt	exit					// Exit if true

	mov	w27, dim2				// w27 = dim2
	cmp	y_r, w27				// y_r > dim2?
	b.gt	cap_y
	b	turn_end

cap_y:
	mov	y_r, (dim2 - 1)

turn_end:
	mov	w27, dim2				// w27 = dim2
	mul	offset_r, y_r, w27			// offset_r = y_r * dim2
	add	offset_r, offset_r, x_r			// offset_r = (y_r * dim2) + x_r
	lsl	offset_r, offset_r, 2			// offset_r = ((y_r * dim2) + x_r) * 4

	str	turn_char_r, [grid_base_r, offset_r, sxtw]

	mvn	turn_r, turn_r				// Flip every bit in turn_r
	strb	turn_r, [fp, turn_s]			// turn = turn_r

	ldr	x0, =clear_screen_sys_call
	bl	system					// system("clear")

	b	next_turn_start				// Goto next_turn_start

exit:
	mov	x0, 0
	ldp	fp, lr, [sp], dealloc
	ret

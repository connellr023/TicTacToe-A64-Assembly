// File: tictactoe.asm
// Author: Connell Reffo
// Description:
// Recreates the Game Tic Tac Toe Using A64 Assembly Language

define(int_bytes, 4)						// 32-bit integer = 4 bytes
define(bool_bytes, 1)						// Boolean value = 1 byte (smallest addressable unit)

define(grid_bytes, 9 * int_bytes)				// Bytes of memory used to store 3x3 grid array

define(scanf_ret_s, 16)						// Will be stack offset for return address of scanf
define(turn_s, scanf_ret_s + int_bytes)				// 0 if X turn; 1 if O turn
define(grid_s, turn_s + bool_bytes)				// Offset for grid array

define(all_s, grid_s + grid_bytes)				// Offset of all stack variables combined

define(alloc, -(all_s) & 16)					// Stack memory to be allocated
define(dealloc, -alloc)						// Stack memory to be deallocated

define(turn_r, w19)						// Register designated for loading turn
define(x_r, w20)						// Register to hold inputted x coordinate
define(y_r, w21)						// Register to hold inputted y coordinate
define(grid_base_r, x22)					// Register to hold base address of grid array
define(offset_r, w23)						// Register to hold grid element offset address
define(i_r, w24)						// Register to hold outer loop counter
define(j_r, w25)						// Register to hold inner loop counter
define(turn_char_r, w26)					// Register to hold current turn character

define(x_char, 88)						// ASCII(88) = "X"
define(o_char, 79)						// ASCII(79) = "O"
define(grid_char, 46)						// ASCII(46) = "."


clear_screen_sys_call:
	.string	"clear"

initial_prompt_str:
	.string	"Tic Tac Toe (Enter a Negative Number to Exit)\n"

x_pos_prompt_str:
	.string	"Enter a Vertical Position [0, 2]: "

y_pos_prompt_str:
	.string	"Enter a Horizontal Position [0, 2]: "

invalid_move_prompt_str:
	.string	"Invalid Move Entered. Must Choose Available Space\n"

scanf_fmt:
	.string "%d"						// Format string for scanf; "%d" specifies decimal integer

new_line_fmt:
	.string "\n"

x_turn_prompt_str:
	.string "\nTurn for X\n"

o_turn_prompt_str:
	.string	"\nTurn for O\n"

win_prompt_str:
	.string " Player Wins!\n"


	.balign	4
	.global main

main:
	stp	fp, lr, [sp, alloc]!				// Allocate memory onto stack
	mov	fp, sp						// Point frame pointer to top of stack

	mov	turn_r, 0					// turn_r = 0
	strb	turn_r, [fp, turn_s]				// turn = turn_r (X turn by default)

	mov	turn_char_r, x_char				// Initialize turn_char_r to x_char

	add	grid_base_r, fp, grid_s				// Calculate base address of grid array

	ldr	x0, =clear_screen_sys_call			// Load "clear" into x0
	bl	system						// system("clear")

init_grid_start:
	mov	i_r, 0						// i_r = 0
	mov	j_r, 0						// j_r = 0

init_grid_outer_loop:
	mov	w26, 3						// w26 = 3
	cmp	i_r, w26					// i_r < 3?
	b.ge	next_turn_start					// Goto next_turn_start if not

init_grid_inner_loop:
	mov	w26, 3						// w26 = 3
	cmp	j_r, w26					// j_r < 3?
	b.ge	init_grid_outer_end				// Goto init_grid_outer_end if not

	mul	offset_r, i_r, w26				// offset_r = i_r * 3
	add	offset_r, offset_r, j_r				// offset_r = (i_r * 3) + j_r
	lsl	offset_r, offset_r, 2				// offset_r = ((i_r * 3) + j_r) * 4

	mov	w26, grid_char					// w26 = grid_char
	str	w26, [grid_base_r, offset_r, sxtw]		// grid[i_r][j_r] = grid_char

	add	j_r, j_r, 1					// j_r++
	b	init_grid_inner_loop				// Restart inner loop

init_grid_outer_end:
	mov	j_r, 0						// j_r = 0
	add	i_r, i_r, 1					// i_r++
	b	init_grid_outer_loop				// Goto init_grid_outer_loop

next_turn_start:
	ldr	x0, =initial_prompt_str				// Load initial_prompt_str into x0
	bl	printf						// Print to standard output

	ldrsb	turn_r, [sp, turn_s]				// turn_r = turn

	mov	i_r, 0						// i_r = 0
	mov	j_r, 0						// j_r = 0

draw_grid_outer_loop:
	mov	w26, 3						// w26 = 3
	cmp	i_r, w26					// i_r < 3?
	b.ge	turn_condition					// Goto turn_condition if not

draw_grid_inner_loop:
	cmp	j_r, w26					// j_r < 3?
	b.ge	draw_grid_outer_end				// Goto draw_grid_outer_end if not

	mul	offset_r, i_r, w26				// offset_r = i_r * 3
	add	offset_r, offset_r, j_r				// offset_r = (i_r * 3) + j_r
	lsl	offset_r, offset_r, 2				// offset_r = ((i_r * 3) + j_r) * 4

	ldr	w0, [grid_base_r, offset_r, sxtw]		// w0 = grid[i][j]
	bl	putchar						// Write grid character to standard output

	add	j_r, j_r, 1					// j_r++
	b	draw_grid_inner_loop				// Restart inner loop

draw_grid_outer_end:
	ldr	x0, =new_line_fmt				// Load "\n" into x0
	bl	printf						// Print new line

	mov	j_r, 0						// j_r = 0
	add 	i_r, i_r, 1					// i_r++
	b	draw_grid_outer_loop

turn_condition:
	mov	w20, 0						// w20 = 0

	cmp	turn_r, w20					// turn_r == 0?
	b.eq	x_turn						// Goto x_turn if true
	b	o_turn						// Goto o_turn otherwise

x_turn:
	mov	turn_char_r, x_char				// turn_char_r = x_char

	ldr	x0, =x_turn_prompt_str				// Load x_turn_prompt_str into x0
	bl	printf						// Print to standard output

	b	turn_input_x					// Goto turn_input_x

o_turn:
	mov	turn_char_r, o_char				// turn_char_r = o_char

	ldr	x0, =o_turn_prompt_str				// Load o_turn_prompt_str into x0
	bl	printf						// Print to standard output

turn_input_x:
	ldr	x0, =x_pos_prompt_str				// Load x_pos_prompt_str into x0
	bl	printf						// Print to standard output

	ldr	x0, =scanf_fmt					// Load "%d" as argument 0
	add	x1, fp, scanf_ret_s				// Load scan_ret_s as argument 1
	bl	scanf						// Call scanf
	ldr	x_r, [fp, scanf_ret_s]				// x_r is input from user

	mov	w27, 0						// w27 = 0
	cmp	x_r, w27					// x_r < 0?
	b.lt	exit						// Exit if true

	mov	w27, 3						// w27 = 3
	cmp	x_r, w27					// x_r > 3?
	b.gt	invalid_turn					// Goto invalid_turn if true

turn_input_y:
	ldr	x0, =y_pos_prompt_str				// Load y_pos_prompt_str into x0
	bl	printf						// Print to standard output

	ldr	x0, =scanf_fmt					// Load "%d" as argument 0
	add	x1, fp, scanf_ret_s				// Load scan_ret_s as argument 1
	bl	scanf						// Call scanf
	ldr	y_r, [fp, scanf_ret_s]				// y_r is input from user

	mov	w27, 0						// w27 = 0
	cmp	y_r, w27					// y_r < 0?
	b.lt	exit						// Exit if true

	mov	w27, 3						// w27 = 3
	cmp	y_r, w27					// y_r > 3?
	b.gt	invalid_turn					// Goto invalid_turn if true

update_grid_condition:
	mov	w27, 3						// w27 = 3
	mul	offset_r, x_r, w27				// offset_r = x_r * 3
	add	offset_r, offset_r, y_r				// offset_r = (x_r * 3) + y_r
	lsl	offset_r, offset_r, 2				// offset_r = ((x_r * 3) + y_r) * 4

	ldr	w27, [grid_base_r, offset_r, sxtw]		// w27 = grid[x_r][y_r]

	mov	w28, grid_char					// w28 = grid_char
	cmp	w27, w28					// grid[x_r][y_r] == grid_char?
	b.eq	valid_turn					// Goto valid_turn if true

invalid_turn:
	ldr	x0, =invalid_move_prompt_str			// Load invalid_move_prompt_str into x0
	bl	printf						// Print to standard output

	b	turn_condition					// Goto turn_condition

valid_turn:
	mvn	turn_r, turn_r					// Flip every bit in turn_r
	strb	turn_r, [fp, turn_s]				// turn = turn_r

	str	turn_char_r, [grid_base_r, offset_r, sxtw]	// grid[x_r][y_r] = turn_char_r

	ldr	x0, =clear_screen_sys_call			// Load "clear" into x0
	bl	system						// system("clear")

evaluate_start:
	mov	i_r, 0						// i_r = 0
	mov	j_r, 0						// j_r = 0

evaluate_rows_loop:
	mov	w27, 3						// w27 = 3

	mul	w19, i_r, w27					// w19 = i_r * 3
	lsl	offset_r, w19, 2				// offset_r = (i_r * 3) * 4
	ldr	w20, [grid_base_r, offset_r, sxtw]		// w20 = grid[i_r][0]

	add	w21, w19, 1					// w21 = (i_r * 3) + 1
	lsl	offset_r, w21, 2				// offset_r = ((i_r * 3) + 1) * 4
	ldr	w21, [grid_base_r, offset_r, sxtw]		// w21 = grid[i_r][1]

	cmp	w20, w21					// grid[i_r][0] == grid[i_r][1]?
	b.ne	evaluate_rows_loop_end				// Goto evaluate_rows_loop_end if not

	add	w25, w19, 2					// w25 = (i_r * 3) + 2
	lsl	offset_r, w25, 2				// offset_r = ((i_r * 3) + 2) * 4
	ldr	w25, [grid_base_r, offset_r, sxtw]		// w25 = grid[i_r][2]

	cmp	w21, w25					// grid[i_r][1] == grid[i_r][2]?
	b.ne	evaluate_rows_loop_end				// Goto evaluate_rows_loop_end if not

	cmp	w20, turn_char_r				// grid[i_r][0] == turn_char_r?
	b.eq	win						// Goto win if true

evaluate_rows_loop_end:
	cmp	i_r, w27					// i_r < 3?
	add	i_r, i_r, 1					// i_r++
	b.lt	evaluate_rows_loop				// Goto evaluate_rows_loop if true

evaluate_columns_loop:
	lsl	offset_r, j_r, 2				// offset_r = j_r * 4
	ldr	w20, [grid_base_r, offset_r, sxtw]		// w20 = grid[0][j_r]

	mov	offset_r, 3					// offset_r = 3
	add	offset_r, offset_r, j_r				// offset_r = 3 + j_r
	lsl	offset_r, offset_r, 2				// offset_r = (3 + j_r) * 4
	ldr	w21, [grid_base_r, offset_r, sxtw]		// w21 = grid[1][j_r]

	cmp	w20, w21
	b.ne	evaluate_columns_loop_end

	mov	offset_r, 6					// offset_r = 6
	add	offset_r, offset_r, j_r				// offset_r = 6 + j_r
	lsl	offset_r, offset_r, 2				// offset_r = (6 + j_r) * 4
	ldr	w25, [grid_base_r, offset_r, sxtw]		// w25 = grid[2][j_r]

	cmp	w21, w25
	b.ne	evaluate_columns_loop_end

	cmp	w20, turn_char_r
	b.eq	win

evaluate_columns_loop_end:
	cmp	j_r, w27
	add	j_r, j_r, 1
	b.lt	evaluate_columns_loop

evaluate_diagonals_1:
	ldr	w20, [grid_base_r]				// w20 = grid[0][0]
	ldr	w21, [grid_base_r, 16]				// w21 = grid[1][1]
	ldr	w25, [grid_base_r, 32]				// w25 = grid[2][2]

	cmp	w20, w21					// grid[0][0] == grid[1][1]?
	b.ne	evaluate_diagonals_2				// Goto evaluate_diagonals_2 if not

	cmp	w21, w25					// grid[1][1] == grid[2][2]?
	b.ne	evaluate_diagonals_2				// Goto evaluate_diagonals_2 if not

	cmp	w20, turn_char_r				// grid[0][0] == turn_char_r?
	b.eq	win						// Goto win if true

evaluate_diagonals_2:
	ldr	w20, [grid_base_r, 8]				// w20 = grid[0][2]
	ldr	w25, [grid_base_r, 24]				// w25 = grid[2][0]

	cmp	w20, w21					// grid[0][2] == grid[1][1]?
	b.ne	no_win						// Goto no_win if not

	cmp	w21, w25					// grid[1][1] == grid[2][0]?
	b.ne	no_win						// Goto no_win if not

	cmp	w20, turn_char_r				// grid[0][2] == turn_char_r?
	b.eq	win						// Goto win if true

no_win:
	b	next_turn_start					// Goto next_turn_start

win:
	mov	w0, turn_char_r					// Load winning character into w0
	bl	putchar						// Display to standard output

	ldr	x0, =win_prompt_str				// Load win_prompt_str into x0
	bl	printf						// Print it to standard output

exit:
	mov	x0, 0						// Set exit status to 0
	ldp	fp, lr, [sp], dealloc				// Deallocate stack memory used
	ret							// Return control to operating system

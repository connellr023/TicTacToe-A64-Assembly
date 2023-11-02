# Tic Tac Toe

<div align="left">
	<img src="https://img.shields.io/badge/language-A64 Assembly-yellow">
	<img src="https://img.shields.io/badge/developer-Connell Reffo-red">
</div>

<br />

An A64 Assembly Tic Tac Toe Implementation.
Tested on *Ampere Altra Q64-22* 64-bit CPU which utilizes the *ARMv8-A* architecture.

# How to Run on a Linux Based System
1. Clone from: *https://github.com/connellr023/TicTacToe-A64-Assembly.git*
2. Process m4 Macros Using: *m4 tictactoe.asm > tictactoe.s*
3. Compile Using: *gcc tictactoe.s* - This will compile to a file called *a.out*
4. Run: *./a.out* or Through gdb Using: *gdb a.out*

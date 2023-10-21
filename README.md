# TicTacToe
Developed by *Connell Reffo* 2023

An A64 Assembly Tic Tac Toe Implementation.
Designed to run on the *Ampere Altra Q64-22* 64-bit CPU which implements the *ARMv8-A* instruction set.

# How to Run on a Linux Based System
1. Clone from: *https://github.com/Crisp32/TicTacToe-A64-Assembly.git*
2. Process m4 Macros Using: *m4 tictactoe.asm > tictactoe.s*
3. Compile Using: *gcc tictactoe.s* - This will compile to a file called *a.out*
4. Run: *./a.out* or Through gdb Using: *gdb a.out*

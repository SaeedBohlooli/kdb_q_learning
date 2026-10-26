/ Q for Mortals (q4m3) examples
/ https://code.kx.com/q4m3/
/ Load with: \l q4m3.q

/ ===== 1. Q Shock and Awe =====

/ Assignment is an expression: evaluated right to left, a:42 returns 42
show 1+a:42        / 43
show a             / 42

/ til n: list of the first n integers, starting at 0
show til 10        / 0 1 2 3 4 5 6 7 8 9

/ Arithmetic applies to each item of a list (no loop needed)
show 1+til 10      / 1 2 3 4 5 6 7 8 9 10
show 1 2 3+10 20 30 / 11 22 33

/ No operator precedence: strictly right to left
show 42+2*til 10   / 42 44 46 48 50 52 54 56 58 60
show 2*3+4         / 14 (not 10)
show (2*3)+4       / 10

/ Join lists with ,
show 1 2 3,4 5     / 1 2 3 4 5
show 0,1 2 3       / 0 1 2 3

/ Take #: first n items, or the last n if n is negative
show 2#til 10      / 0 1
show -2#til 10     / 8 9
/ taking more items than the list has wraps around
show 5#1 2         / 1 2 1 2 1
show 12#til 10     / 0 1 2 3 4 5 6 7 8 9 0 1
show -5#1 2 3      / 2 3 1 2 3
show 3#42          / 42 42 42
show 0#til 10      / `long$()
/ 0# makes a typed empty list
show 0#1 2 3       / `long$()
show 0#0           / `long$()
show 0#`           / `symbol$()
show 0#0.0         / `float$()
show 0#""          / ""
show type 0#`      / 11h
show type ()       / 0h (general empty list)
/ strings are lists of characters
show 3#"hello"     / "hel"
show -3#"hello"    / "llo"
/ shape a list into a matrix (rows, columns)
show 2 3#til 6     / 0 1 2 / 3 4 5
show 3 3#1 0 0 0   / identity matrix
/ dictionaries and tables
show `a`c#`a`b`c!1 2 3   / a| 1 / c| 3
t:([] a:1 2 3; b:`x`y`z)
show 2#t           / first 2 rows
show -1#t          / last row
/ compare with drop _
show 2_til 10      / 2 3 4 5 6 7 8 9
show -2_til 10     / 0 1 2 3 4 5 6 7

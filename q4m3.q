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

/ Functions: x y z are implicit params, last statement is the return value,
/ assignments inside are local
show {a:x*x;b:y*y;a+b}[3;4]   / 25
show a                        / still 42 (global a unchanged)

/ Over / : fold a two-argument function across a list using an accumulator
show (+/) 1 2 3 4 5      / 15  (first item is the starting accumulator)
show 0 +/ 1 2 3 4 5      / 15  (explicit initial accumulator)
show +/[0;1 2 3 4 5]     / 15  (bracket form)
show 10 +/ 1 2 3         / 16
show (*/) 1+til 10       / 3628800 (10 factorial)
show (|/) 20 10 40 30    / 40 (max)
show (&/) 20 10 40 30    / 10 (min)
show (,/) (1 2;3 4;5)    / 1 2 3 4 5 (raze)
/ Scan \ : like Over but returns every intermediate accumulator value
show (+\) 1 2 3 4 5      / 1 3 6 10 15
show (*\) 1 2 3 4 5      / 1 2 6 24 120
/ built-in equivalents
show sum 1 2 3 4 5       / 15
show sums 1 2 3 4 5      / 1 3 6 10 15

/ n f/ x with a one-argument f: apply f n times (Fibonacci)
show {x,sum -2#x}[1 1 2]       / 1 1 2 3
show 10 {x,sum -2#x}/ 1 1      / 1 1 2 3 5 8 13 21 34 55 89 144
show 3 {x,sum -2#x}\ 1 1       / every step

/ 1.14 FIFO allocation: sums -> cap with & -> deltas
buys:2 1 4 3 5 4f
show deltas 12&sums buys                            / 2 1 4 3 2 0f
sells:2 4 3 2f
show deltas each deltas sums[sells] &\: sums[buys]  / rows=sells, cols=buys

/ Column dictionary: keys!values, values are same-length lists
dc:`c1`c2!(10 20 30; 1.1 2.2 3.3)
show dc
show dc[`c1]       / 10 20 30
show dc[`c2;1]     / 2.2
show flip dc       / column dictionary -> table

/ Random dates: n?m = n random ints in 0..m-1; date+n = n days later
dts:2015.01.01+1000000?31
show 5#dts         / random dates in Jan 2015

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

/ wavg: weighted average sum[w*x] % sum w
show 1 1 1 wavg 10 20 30       / 20f
show 100 300 wavg 10 11        / 10.75
/ xbar: round down to a multiple of n (bucketing)
show 5 xbar 0 3 5 7 11         / 0 0 5 5 10
show 15 xbar 09:07 09:20 09:44 / 09:00 09:15 09:30

/ Max profit (buy before sell): px - running min, then max
px:15 10 12 8 11 9
show mins px                   / 15 10 10 8 8 8
show px-mins px                / 0 0 2 0 3 1
show max px-mins px            / 3 (buy 8, sell 11)
show max (maxs px)-px          / 7 (max drawdown)

/ Files: `:path is a file handle
/ (relative paths here so loading this script writes under ./q4m/examples, not the drive root)
t:([] c1:`a`b`c; c2:1.1 2.2 3.3)
/ binary save / load (keeps types)
`:q4m/examples/t set t
show get `:q4m/examples/t
/ table -> CSV text lines -> file
show csv 0: t                          / "c1,c2" "a,1.1" ...
`:q4m/examples/t.csv 0: csv 0: t
/ read raw lines
show read0 `:q4m/examples/t.csv
/ parse CSV: "SF" = symbol,float; enlist "," = first line is header -> table
show ("SF"; enlist ",") 0: `:q4m/examples/t.csv

/ IPC: needs two q sessions, so commented out (run by hand)
/ server:  \p 5042          / listen on port 5042
/ server:  f:{x*y}
/ client:  h:hopen `:localhost:5042
/ client:  h "6*7"          / 42  run a string on the server (dev only)
/ client:  h (`f; 6; 7)     / 42  call f by name (safer)
/ async (neg h): client doesn't wait, nothing returned; output shows on server
/ server:  echo:{show x}
/ client:  (neg h) (`echo; 42)   / server console prints 42
/ callback: server calls a client function back via .z.w (handle of the caller)
/ server:  rsvp:{[arg;cb] show arg; (neg .z.w) (cb; 43); show `done;}
/ client:  echo:{show x}
/ client:  (neg h) (`rsvp; 42; `echo)   / client prints 43; server prints 42, `done
/          must be async (neg h), sync h would deadlock
/ client:  hclose h

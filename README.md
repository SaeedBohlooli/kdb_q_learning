# kdb+/q Learning Notes

Notes and examples from working through [Q for Mortals (q4m3)](https://code.kx.com/q4m3/).

Runnable versions of every example are in [q4m3.q](q4m3.q). Load them in a q session with:

```q
q)\l q4m3.q
```

## Contents

<!-- Sections are added as I work through the chapters -->

## 1. Q Shock and Awe

### Assignment is an expression

```q
q)1+a:42
43
q)a
42
```

- q evaluates **right to left**. `a:42` runs first and assigns 42 to `a`.
- Assignment (`:`) also **returns the assigned value**, so `1+` is applied to 42 and the result is `43`.
- `a` itself is still `42`. Only the expression's result is 43.

### `til`: the first n integers

```q
q)til 10
0 1 2 3 4 5 6 7 8 9
```

- `til n` returns a list of the `n` integers from `0` to `n-1`. It works like Python's `range(n)`.
- Lists print with spaces between items, not brackets or commas.
- The result is a **long** (64-bit integer) list. `type til 10` returns `7h`.

### Operations on whole lists: `1+til 10`

```q
q)1+til 10
1 2 3 4 5 6 7 8 9 10
```

- Right to left: `til 10` runs first and gives `0..9`, then `1+` adds 1 to **every item**.
- Arithmetic works on a whole list at once, with no loop. A number and a list combine item by item, and so do two lists of the same length (`1 2 3+10 20 30` gives `11 22 33`).
- `1+til n` is the usual way to get `1..n`.

### No operator precedence: `42+2*til 10`

```q
q)42+2*til 10
42 44 46 48 50 52 54 56 58 60
```

- Evaluated strictly right to left: `til 10` → `0..9`, then `2*` → `0 2 4 .. 18`, then `42+` → `42 44 .. 60`.
- q has **no operator precedence**. `*` does not bind tighter than `+`; only position matters.
- Watch out: `2*3+4` is `14` in q (`2*(3+4)`), not `10`. Use parentheses to force the order: `(2*3)+4` gives `10`.
- Pattern: `start+step*til n` gives an arithmetic sequence.

### Join: `,`

```q
q)1 2 3,4 5
1 2 3 4 5
```

- `,` (join) joins two lists end to end.
- It also works with single values: `1,2` gives `1 2`, and `0,1 2 3` gives `0 1 2 3`.
- Unlike `+`, the two sides don't need the same length.

### Take: `#`

```q
q)2#til 10            / first 2 items
0 1
q)-2#til 10           / negative takes from the end
8 9
```

**Taking more items than the list has wraps around to the start:**

```q
q)5#1 2               / repeats the list until it has 5 items
1 2 1 2 1
q)12#til 10
0 1 2 3 4 5 6 7 8 9 0 1
q)-5#1 2 3            / wraps from the end; the result still ends with the last item
2 3 1 2 3
q)3#42                / a single value is repeated
42 42 42
q)0#til 10            / empty list of the same type
`long$()
```

**Typed empty lists with `0#`:** taking 0 items keeps the **type** of the right side, so `0#x` is the usual way to make an empty list of a given type:

```q
q)0#1 2 3              / from a list
`long$()
q)0#0                  / from a single value
`long$()
q)0#`                  / from the empty symbol
`symbol$()
q)0#0.0
`float$()
q)0#""                 / an empty string
""
q)type 0#`
11h
q)type ()              / () is a general (untyped) empty list
0h
```

- An empty list prints as `` `type$() ``, the type name followed by `$()`.
- This matters when building tables and lists one item at a time. Starting from `` 0#` `` gives a symbol list, while `()` has no type until something is added.

**Strings are lists of characters, so take works on them too:**

```q
q)3#"hello"
"hel"
q)-3#"hello"
"llo"
```

**Shape a list into a matrix:** a left argument of 2 numbers gives rows and columns:

```q
q)2 3#til 6
0 1 2
3 4 5
q)3 3#1 0 0 0          / wrap-around makes an identity matrix
1 0 0
0 1 0
0 0 1
```

**Take from dictionaries and tables:**

```q
q)`a`c#`a`b`c!1 2 3    / a list of keys picks entries from a dictionary
a| 1
c| 3
q)t:([] a:1 2 3; b:`x`y`z)
q)2#t                  / first 2 rows
a b
---
1 x
2 y
q)-1#t                 / last row
a b
---
3 z
```

**Compare with drop `_`**, which removes items instead of keeping them:

```q
q)2_til 10
2 3 4 5 6 7 8 9
q)-2_til 10
0 1 2 3 4 5 6 7
```

### Functions (lambdas): `{...}[args]`

```q
q){a:x*x;b:y*y;a+b}[3;4]
25
```

- `{...}` defines a function. Here it is called right away with the arguments in brackets, separated by `;`.
- **Implicit parameters:** `x`, `y`, `z` are the first, second and third arguments. You don't need to declare them.
- Statements inside the function are separated by `;`, and the **value of the last statement is returned**. No `return` keyword is needed.
- `a` and `b` are **local** to the function. They don't overwrite a global `a` (for example the `a:42` set earlier).
- Here: `a:3*3` → 9, `b:4*4` → 16, `a+b` → 25.

### Over `/`: fold (accumulate) across a list

`+` on its own works item by item. To **add up** a list, you need a higher-order function that turns `+` into something that runs across the list. In functional programming this is called a **fold**. In q it is **Over** (`/`).

How it works: start with an initial value in an **accumulator**, then combine each item into the accumulator in turn. When the list runs out, the accumulator holds the result.

```q
q)(+/) 1 2 3 4 5        / ((((1+2)+3)+4)+5)
15
q)0 +/ 1 2 3 4 5        / explicit initial accumulator 0: (((((0+1)+2)+3)+4)+5)
15
q)+/[0;1 2 3 4 5]       / same, written with brackets
15
q)10 +/ 1 2 3           / initial value 10
16
```

- `(+/)` without an initial value uses the **first item** as the starting accumulator.
- Writing `(+/)` in parentheses makes it clear that `+/` is a single function.
- **Gotcha:** `/` must come **right after** the function (`+/`). With a space or at the start of a line (` /`), `/` starts a **comment**.

**Any two-argument function can be folded:**

```q
q)(*/) 1+til 10         / product: 10 factorial
3628800
q)(|/) 20 10 40 30      / | is max, so this is the largest item
40
q)(&/) 20 10 40 30      / & is min, so this is the smallest item
10
q)(,/) (1 2;3 4;5)      / join all the lists together
1 2 3 4 5
```

**Scan `\` shows each step of the accumulator** (a running total):

```q
q)(+\) 1 2 3 4 5
1 3 6 10 15
q)(*\) 1 2 3 4 5
1 2 6 24 120
```

- `/` returns only the **final** value. `\` returns **every intermediate** value.
- q has built-in versions of the common ones: `sum`, `prd`, `max`, `min`, `raze` (= `,/`), `sums` (= `+\`), `prds` (= `*\`).

```q
q)sum 1+til 10          / same as (+/): only the final total
55
q)sums 1+til 10         / same as (+\): running total at every step
1 3 6 10 15 21 28 36 45 55
```

- The last item of `sums` always equals `sum`.

### Repeat a function n times with `/`: Fibonacci

The function on its own adds the next Fibonacci number to the end of the list:

```q
q){x,sum -2#x}[1 1 2]
1 1 2 3
```

| Step | Expression | Result |
|---|---|---|
| 1 | `-2#x` | `1 2` (last 2 items) |
| 2 | `sum -2#x` | `3` |
| 3 | `x,sum -2#x` | `1 1 2 3` (put the sum on the end) |

> **Note:** `x` is the input (the list so far). `sum -2#x` is only the next number. The **output** is `x,sum -2#x` (old list + new number), and it becomes the next `x`.

Run it 10 times:

```q
q)10 {x,sum -2#x}/ 1 1
1 1 2 3 5 8 13 21 34 55 89 144
```

- This is **not** a fold. The function takes **one** argument, so the number on the left (`10`) is **how many times to run it**, not a starting accumulator.
- `n f/ x` means "apply `f` to `x`, `n` times, feeding each result back in".
- It starts with 2 items and adds 1 each time, so the result has 12.

Swap `/` for `\` to see each step:

```q
q)3 {x,sum -2#x}\ 1 1
1 1
1 1 2
1 1 2 3
1 1 2 3 5
```

**Summary:** with a two-argument function (`+/`), `/` folds across a list. With a one-argument function and a number on the left, `/` repeats the function that many times.

### 1.14 FIFO Allocation

Use up the oldest buys first. The trick: turn the buys into running totals (`sums`), cap them at the sell amount (`&` = min), then turn them back into amounts per buy (`deltas`).

```q
q)buys:2 1 4 3 5 4f
q)deltas 12&sums buys                            / one sell of 12
2 1 4 3 2 0f
q)sells:2 4 3 2f
q)deltas each deltas sums[sells] &\: sums[buys]  / several sells: rows=sells, cols=buys
2 0 0 0 0 0
0 1 3 0 0 0
0 0 1 2 0 0
0 0 0 1 1 0
```

- `&\:` (each-left) applies `&` with each item on the left, giving one row per sell.

**Walkthrough, following sell 2 (amount 4).** `sums sells` = `2 6 9 11`, so after sell 2, **6** units have been sold in total.

```
6&sums buys      → 2 3 6 6 6 6     sells 1 and 2 together (running totals)
2&sums buys      → 2 2 2 2 2 2     sell 1 alone
subtract         → 0 1 4 4 4 4     sell 2 only        ← deltas (down the rows)
deltas           → 0 1 3 0 0 0     amount per buy     ← deltas each (across each row)
```

- `deltas` on a matrix subtracts whole rows (down). `deltas each` works inside each row (across).

### Column dictionary → table

```q
q)dc:`c1`c2!(10 20 30; 1.1 2.2 3.3)
q)dc
c1| 10  20  30
c2| 1.1 2.2 3.3
q)dc[`c1]              / look up a key → the whole column
10 20 30
q)dc[`c2;1]            / key, then index → one value
2.2
q)flip dc              / flip a column dictionary → a table
c1 c2
------
10 1.1
20 2.2
30 3.3
```

- `keys!values` makes a dictionary. Here the keys are the symbols `` `c1`c2 `` and the values are 2 lists of the same length.
- A dictionary whose values are same-length lists is a **column dictionary**. `flip` turns it into a **table**, which is how q stores tables.

### Random dates

```q
q)dts:2015.01.01+1000000?31
```

- `n?m` gives `n` random integers from `0` to `m-1` (`5?31` → e.g. `12 3 27 0 19`).
- `date+n` moves forward `n` days (a date is stored as days since 2000.01.01). The result is 1 million random dates in January 2015.

### Sort a table: `xasc`

```q
q)trades:`dt`tm xasc trades
```

- Sorts the table ascending by `dt`, then by `tm` for rows with the same date, and saves the result back to `trades`. `xasc` doesn't change the table in place.
- `xdesc` sorts descending. `xasc` also gives the first sort column the sorted attribute (`s`), which makes searches on it faster.

### qSQL `select` with aggregates and `by`

```q
q)select avg px, avg vol from trades          / one row: averages over the whole table
q)select avg px, avg vol by sym from trades   / one row per sym (a keyed table)
```

- `avg px` gives a result column that is still named `px`.
- `by sym` groups the rows by `sym` and calculates the averages for each group. `sym` becomes the key column, shown to the left of the `|`.

### VWAP by time bucket: `wavg` and `xbar`

```q
q)select vwap:vol wavg px by sym,bkt:100000000 xbar tm from trades
```

- Gives the VWAP (volume-weighted average price) for each `sym` and each 100 ms time bucket.
- `name:expr` names a result column (`vwap`, `bkt`).

**`w wavg x`**: weighted average, `sum[w*x] % sum w`

```q
q)1 1 1 wavg 10 20 30          / equal weights = ordinary avg
20f
q)100 300 wavg 10 11           / (100*10 + 300*11) % 400
10.75
```

**`n xbar x`**: round down to a multiple of `n` (puts each value in a bucket)

```q
q)5 xbar 0 3 5 7 11
0 0 5 5 10
q)15 xbar 09:07 09:20 09:44    / minute type: 15-minute buckets
09:00 09:15 09:30
```

- `tm` is a timespan, counted in nanoseconds, so `100000000 xbar tm` makes 100 ms buckets.

### Max profit (one buy, then one later sell): `mins`

```q
q)select max px-mins px from trades where sym=`aapl
```

`max-min` is wrong, because the high might come **before** the low. Instead, for each possible sell day, look back for the cheapest buy so far:

```q
q)px:15 10 12 8 11 9
q)mins px              / running minimum = best buy so far
15 10 10 8 8 8
q)px-mins px           / profit if I sell today
0 0 2 0 3 1
q)max px-mins px       / buy 8, sell 11 (not 15-8: the 15 came first)
3
```

- Max drawdown (the worst fall from a high): `max (maxs px)-px` → `7` here.

### Saving and loading files: `set`/`get`, `0:`, `read0`

```q
q)t:([] c1:`a`b`c; c2:1.1 2.2 3.3)
```

A symbol starting with `:` is a **file handle**: `` `:/q4m/examples/t ``. On Windows, `/q4m/...` means the current drive, e.g. `C:\q4m\...`.

**Binary save and load:** fast, and keeps the types

```q
q)`:/q4m/examples/t set t        / save; returns the handle
`:/q4m/examples/t
q)get `:/q4m/examples/t          / load the same table back
c1 c2
------
a  1.1
b  2.2
c  3.3
```

**Save as CSV:** the two `0:`s do different jobs (read right to left)

```q
q)csv 0: t                       / step 1: table → CSV text lines (csv is just ",")
"c1,c2"
"a,1.1"
"b,2.2"
"c,3.3"
q)`:/q4m/examples/t.csv 0: csv 0: t   / step 2: write the lines to a file
```

**Read raw lines:** no parsing

```q
q)read0 `:/q4m/examples/t.csv
"c1,c2"
"a,1.1"
"b,2.2"
"c,3.3"
```

**Parse the CSV back into a table:**

```q
q)("SF"; enlist ",") 0: `:/q4m/examples/t.csv
c1 c2
------
a  1.1
b  2.2
c  3.3
```

- `"SF"` gives one type letter per column: `S` symbol, `F` float. Others: `I` int, `J` long, `D` date, `T` time, `*` string, a space to skip a column.
- `enlist ","` means the first line is the header, so the result is a table. With a plain `","`, every line is read as data and you get a list of columns.
- CSV doesn't store types, which is why you supply them when reading.

| Command | Does |
|---|---|
| `` `:f set t `` / `` get `:f `` | binary save / load |
| `` `:f.csv 0: csv 0: t `` | table → CSV text → file |
| `` read0 `:f `` | file → raw lines |
| `` ("SF";enlist ",") 0: `:f `` | CSV file → table |

### IPC: talking to another q process

```q
/ server session
q)\p 5042                     / listen on port 5042
q)\p                          / check the port
5042i
q)f:{x*y}                     / a function clients can call

/ client session
q)h:hopen `:localhost:5042    / open a connection (`:host:port), h = handle
q)h "6*7"                     / send a string to run on the server (dev only, unsafe)
42
q)h (`f; 6; 7)                / call server function f by name with arguments (safer)
42
q)hclose h                    / close the connection
```

**Async call: `neg h`** (send and don't wait)

```q
q)echo:{show x}               / server: prints its argument
q)(neg h) (`echo; 42)         / client: returns at once, nothing comes back
42                            / ...printed on the SERVER console
```

- `h (...)` is sync: the client waits and gets the result. `(neg h) (...)` is async: no waiting, and no result comes back.

### Callbacks: the server calls the client back

The client sends the work plus the name of its own function. The server does the work, then calls that function on the client with the result.

```q
/ server
q)rsvp:{[arg;cb] show arg; (neg .z.w) (cb; 43); show `done;}

/ client
q)echo:{show x}                    / the function the server will call back
q)(neg h) (`rsvp; 42; `echo)       / server fn, its arg, callback name
q)43                               / printed on the client by echo

/ server console shows: 42 then `done
```

- `{[arg;cb] ...}` uses **named parameters** in place of `x` and `y`.
- `.z.w` is the handle of **who called** (the connection back to the client). It's set during each remote call.
- `(neg .z.w) (cb; 43)` asynchronously calls `` `echo `` on the client with `43`.
- The `;` at the end of the function makes it return nothing locally. The result was already sent back.
- The client **must** call asynchronously (`neg h`). If it used sync `h`, it would block waiting for `rsvp`, `rsvp` would be trying to call the client, and the two would **deadlock**.
"# kdb_q_learning" 

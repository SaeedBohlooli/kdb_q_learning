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

### Symbols: the backtick `` ` ``

A backtick makes a **symbol**: a name used as data. `apple` is the variable apple (q looks up its value), while `` `apple `` is the name itself.

```q
q)`apple`banana            / symbol list (no spaces); type 11h, a single one is -11h
q)`                        / the empty (null) symbol
q)string `apple            / symbol → string
"apple"
q)`$"hello world"          / string → symbol
`hello world
```

Where you'll see it:

```q
q)select from trades where sym=`aapl   / values in data
q)`dt`tm xasc trades                   / column names
q)cols t                               / → `c1`c2
q)d:`a`b`c!1 2 3; d `b                 / dictionary keys → 2
q)`int$12:00:00.000                    / type names in casts → 43200000i
q)`:q4m/examples/t set t               / file handle (`: prefix)
q)h:hopen `:localhost:5042             / network handle
q)h (`f; 6; 7)                         / function name for a remote call
q)get `a                               / variable name: read a
q)`a set 100                           / variable name: set a
```

- **Gotcha:** a single symbol directly before `#` is read as an **attribute**: `` `s#t `` marks `t` as sorted, it doesn't take column `s`. To take one column, use `` (enlist `c1)#t ``.

### Timestamp vs timespan

```q
q)2015.01.01D09:30:00.000000000    / timestamp (-12h): a point in time, ns since 2000.01.01
q)0D09:30:00.000000000             / timespan (-16h): a duration or time of day, in ns
q)2015.01.02D10:00 - 2015.01.01D09:00   / timestamp − timestamp = timespan
1D01:00:00.000000000
q)2015.01.01 + 0D09:30             / date + timespan = timestamp
2015.01.01D09:30:00.000000000
```

- A date before the `D` makes a timestamp; a number of days before it makes a timespan. Now: `.z.p` (timestamp), `.z.n` (timespan).

### Getting parts of a date: `` `month$dt `` and friends

`` `month$dt `` = cast `dt` to the type named `` `month ``. The backtick makes `month` a name used as data, like `cast("month", dt)` in Python or `cast(Type.MONTH, dt)` in Java. Without it, q looks for a variable called `month`.

```q
q)dt:2014.01.01
q)`month$dt          / month value (type -13h), day removed
2014.01m
q)`int$2014.01m      / stored as months since 2000.01
168i
q)`month$2014.01.01 2014.01.31 2014.02.15   / any day in a month → same month
2014.01 2014.01 2014.02m
```

| Cast | Result | Meaning |
|---|---|---|
| `` `month$dt `` | `2014.01m` | month **value** |
| `` `year$dt `` | `2014i` | year number |
| `` `mm$dt `` | `1i` | month **number** (1 to 12) |
| `` `dd$dt `` | `1i` | day of the month |
| `` `week$dt `` | `2013.12.30` | Monday of that week |

```q
q)dt.year            / dot shortcut on a variable holding a date
2014i
q)dt.month
2014.01m
q)select sum vol by `month$dt from trades   / group by month
```

- `` `month$dt `` gives a month **value** (`2014.01m`). `` `mm$dt `` gives just the **number** (`1i`).
- Like dates and times, a month is a count underneath (months since 2000.01), shown in a readable form.

## 2. Basic Data Types: Atoms

An **atom** is a single value of one type. A negative `type` means an atom, and a positive `type` means a list of that type.

### Type table (the ones to remember)

| Type | Char | Num | Example | Null | Java |
|---|---|---|---|---|---|
| boolean | b | 1 | `1b` | `0b` | boolean |
| guid | g | 2 | (generated) | `0Ng` | UUID |
| byte | x | 4 | `0x2a` | `0x00` | byte |
| short | h | 5 | `42h` | `0Nh` | short |
| int | i | 6 | `42i` | `0Ni` | int |
| **long** | j | 7 | `42` | `0N` | long |
| real | e | 8 | `4.2e` | `0Ne` | float |
| **float** | f | 9 | `4.2` | `0n` | double |
| char | c | 10 | `"z"` | `" "` | char |
| **symbol** | s | 11 | `` `zaphod `` | `` ` `` | String (interned) |
| **timestamp** | p | 12 | `2015.01.01D09:30:00.000000000` | `0Np` | Instant |
| month | m | 13 | `2006.07m` | `0Nm` | |
| **date** | d | 14 | `2006.07.21` | `0Nd` | LocalDate |
| datetime (deprecated) | z | 15 | `2006.07.21T09:13:39` | `0Nz` | |
| **timespan** | n | 16 | `0D12:00:00.000000000` | `0Nn` | Duration |
| minute | u | 17 | `23:59` | `0Nu` | |
| second | v | 18 | `23:59:59` | `0Nv` | |
| time | t | 19 | `09:01:02.042` | `0Nt` | LocalTime (ms) |
| table / dict / function | | 98 / 99 / 100 | | | |

- The **Char** letter is used in casts and parsing (`"D"$"2015.01.01"`, CSV `"SF"`) and in `meta` output. It's also the literal suffix (`42h`, `42i`, `1b`).
- Type names like `int` and `date` aren't reserved words, but don't use them as variable names.

### Integers: long (default), int, short

```q
q)42          / long (8 bytes); 42j is the same
42
q)-123h       / short (2 bytes): h is required
-123h
q)1234567890i / int (4 bytes): i is required
1234567890i
```

- Arithmetic **promotes** automatically (`1h+1` → long). But adding a narrower value to a list of a wider type **in place** is an error, not a promotion. This keeps table columns a single type.

### Floats: float (default) and real

```q
q)3.14159265  / float (8 bytes, about 15 digits); display rounds to 7
3.141593
q)1.0         / shown without the .0
1f
q)1.234e7     / scientific notation: here e is the exponent, not a type
1.234e+07
q)12.34e      / real (4 bytes, about 6 digits): avoid it, always use float
12.34e
q)\P 16       / show up to 16 digits (\P 0 = all 17)
```

### Binary: boolean, byte, guid

```q
q)42+1b       / booleans are numbers in arithmetic
43
q)base:100; flag:1b
q)base+flag*42   / no if needed: adds 42 only when flag is 1b
142
q)0x2a        / byte: 0x followed by 2 hex digits
0x2a
q)1+0x29
42
q)-2?0Ng      / 2 new GUIDs (negative = random seed; use this in production)
q)"G"$"61f35174-90bc-a48a-d88f-e15e4a377ec8"   / parse a GUID string
```

- There are no `true`/`false` keywords: use `1b` and `0b`.
- `2?0Ng` (positive) gives the **same** GUIDs in every new session, which is useful for tests only.

### Text: char vs symbol

```q
q)"q"         / char: one character
q)"\""        / escapes: \" \\ \n \r \t, and \142 = octal for "b"
q)`zaphod     / symbol: one atomic piece of text
q)`a~"a"      / a symbol is NOT a char or a string
0b
q)`$"A symbol with blanks"   / make any symbol by casting a string
```

- `~` is **match** (identical in type and value).
- You can't get at the characters inside a symbol. A string is a **list of chars** (chapter 3).

### Temporal types: all integer counts from 2000.01.01 or midnight

| Type | Literal | Counts | Since |
|---|---|---|---|
| date | `2015.01.01` | days | 2000.01.01 |
| month | `2015.01m` | months | 2000.01 |
| timestamp | `2015.01.01D12:00:00.000000000` | nanoseconds | 2000.01.01 |
| time | `12:00:00.000` | milliseconds | midnight |
| timespan | `12:00:00.000000000` (optional `0D`) | nanoseconds | midnight |
| minute | `12:00` | minutes | midnight |
| second | `12:00:00` | seconds | midnight |

```q
q)2000.01.01=0                  / dates are day counts
1b
q)`int$2000.02.01
31i
q)2015.1.1                      / leading zeros are required
'2015.1.1
q)12:00:00.000=12*60*60*1000    / time = milliseconds
1b
q)`long$12:34:56.123456789      / timespan = nanoseconds
45296123456789
q)`long$2014.11.22D17:43:40.123456789
469993420123456789
q)`date$2014.11.22D17:43:40.123456789       / split a timestamp
2014.11.22
q)`timespan$2014.11.22D17:43:40.123456789
0D17:43:40.123456789
q)`int$2015.01m
180i
q)2014.11                       / GOTCHA: without m this is a float!
2014.11
q)2015.07m=2015.07.01           / the first day of a month equals the month
1b
q)12:34:56=12:34:56.000         / different units, same clock position → equal
1b
```

- **datetime** (`T`, stored as a fractional float day count) is deprecated. Use **timestamp** (`D`), especially for keys and joins.
- Extract parts with a cast (`` `mm$dt ``, `` `dd$dt ``, `` `month$dt ``) instead of dot notation (`dt.mm`), which doesn't work inside functions.
- To get the milliseconds of a time: `` (`int$12:34:56.789) mod 1000 `` → `789`.

### Infinities: no division-by-zero errors

| Literal | Meaning |
|---|---|
| `0w` / `-0w` | float +/- infinity |
| `0n` | float null (NaN) |
| `0W` / `-0W` | long +/- infinity |
| `0N` | long null |

```q
q)1%0         / % is divide, and it always returns a float
0w
q)-1%0
-0w
q)0%0
0n
q)42<0W       / integer infinities are for comparisons
1b
q)0W+1        / GOTCHA: integer overflow isn't trapped; it wraps around
0N
```

- q prefers returning a result over raising an error, so a long calculation doesn't stop partway.
- Order for longs: `0N < -0W < normal values < 0W`. `0N` is the smallest long bit pattern.

### Nulls: typed, and always tested with `null`

- Each type has its **own** null (`0N`, `0n`, `0Nd`, `` ` ``, ...), the same size as a normal value. There's no single `NULL` like in SQL or Java.
- boolean, byte and char have **no real null**. `0b`, `0x00` and `" "` stand in for it, so you can't tell "missing" from false, 0 or a blank.
- `""` is an **empty string** (an empty list of chars), not a null char.

```q
q)null 42
0b
q)null 0N
1b
q)null `
1b
q)null " "
1b
```

- **Always use `null`** rather than `= 0N`. It works for any type, so you don't need the right null literal.

## 3. Lists

Everything in q is built from lists: a dictionary is a pair of lists, a table is a special dictionary, and a keyed table is a pair of tables. Think of q lists as **dynamic arrays**, not linked lists: they're contiguous in memory, you append at the end, and indexing is fast.

- **Simple list** = all atoms of one type (a vector): the fastest kind, with compact storage.
- **General list** = anything else (mixed types or nested lists), `type` `0h`.

### 3.1 Defining lists, `count`, `first`, `last`

General notation: items in `( )` separated by `;`.

```q
q)(1; 1.1; `1)                        / mixed → general list, one item per line
1
1.1
`1
q)(1;2;3)                             / all longs → shown as a simple list
1 2 3
q)("a";"b";"c";"d")
"abcd"
q)(`Life;`the;`Universe;`and;`Everything)
`Life`the`Universe`and`Everything
q)(-10.0; 3.1415e; 1b; `abc; "z")
-10f
3.1415e
1b
`abc
"z"
q)((1; 2; 3); (4; 5))                 / nested
1 2 3
4 5
q)((1; 2; 3); (`1; "2"; 3); 4.4)
1 2 3
(`1;"2";3)
4.4
q)L1:(1;2;3)
q)L2:("z";"a";"p";"h";"o";"d")
q)L3:((1; 2; 3); (`1; "2"; 3); 4.4)
q)count L1
3
q)count 42              / an atom has count 1 (but it isn't a list)
1
q)count `zaphod
1
q)first (1; 2; 3)
1
q)last (1; 2; 3)
3
```

- Lists are **ordered**: `(1;2)` and `(2;1)` are different. SQL tables are unordered sets; q tables keep their order, which makes time series natural.

### 3.2 Simple lists: shorter notation per type

q **automatically converts** a general list to a simple list when all items are atoms of the same type.

```q
q)(100;200;300)
100 200 300
q)100 200 300~(100; 200 ; 300)        / ~ = match (identical)
1b
q)(1h; 2h; 3h)                        / the suffix applies to the WHOLE list
1 2 3h
q)(100i; 200i; 300i)
100 200 300i
q)(1; 2; 3h)                          / mixed long/short → general
1
2
3h
```

**Floats**

```q
q)123.4567 9876.543 99
123.4567 9876.543 99
q)1.0 2.0 3.0                         / whole floats shown with a trailing f
1 2 3f
q)1 2 3f~1.0 2.0 3.0
1b
q)1.1 2 3.3~1.1 2.0 3.3               / an integer among floats is read as a float
1b
```

**Booleans, bytes, GUIDs**

```q
q)(0b;1b;0b;1b;1b)                    / booleans: digits with no spaces, then b
01011b
q)(0x20;0xa1;0xff)                    / bytes: one 0x, then the hex digits
0x20a1ff
q)0x20a1ff~(0x20;0xa1;0xff)
1b
q)3?0Ng                               / GUIDs: separated by spaces
```

- A boolean list uses **1 byte per item**. It is not packed into bits.

**Symbols**: no spaces between them

```q
q)`Life`the`Universe`and`Everything
`Life`the`Universe`and`Everything
q)`bad `news                          / spaces → error
'bad
```

**Strings = lists of chars**

```q
q)("s"; "t"; "r"; "i"; "n"; "g")
"string"
q)"string"="text"                     / = compares item by item → lengths must match
'length
q)"string"~"text"                     / ~ compares whole values
0b
```

**Temporal lists**: separated by spaces. When you mix temporal types, q converts them all to **one type** instead of making a general list (unlike numbers).

```q
q)(2000.01.01; 2001.01.01; 2002.01.01)
2000.01.01 2001.01.01 2002.01.01
q)(00:00:00.000; 00:00:01.000; 00:00:02.000)
00:00:00.000 00:00:01.000 00:00:02.000
q)12:34 01:02:03                      / minute + second → all seconds
12:34:00 01:02:03
q)01:02:03 12:34
01:02:03 12:34:00
q)01:02:03 12:34 11:59:59.999u        / a suffix forces the type (u = minute)
01:02 12:34 11:59
```

### 3.3 Empty and singleton lists

```q
q)()                                  / general empty list: prints nothing
q)L:()
q).Q.s1 L                             / .Q.s1 = any value → one-line string (shows hidden values)
"()"
q)enlist 42                           / a singleton: you can't write (42), that's just 42
,42
q)"a"                                 / a char atom, NOT a 1-char string
"a"
q)enlist "a"                          / a 1-char string
,"a"
q)enlist 1 2 3                        / a singleton holding a list (display is confusing)
1 2 3
q)enlist (10 20 30; `a`b`c)
10 20 30 a b c
```

- `,` in the display means a **1-item list**. You can't type `,42` in q to make one; use `enlist`.

### 3.4 Indexing

Indices run from `0` to `count-1`. There is **no item at index `count`**, which is a common mistake.

```q
q)(100; 200; 300)[0]
100
q)100 200 300[0]
100
q)L:100 200 300
q)L[1]
200
q)L[2]
300
q)L[3]                                / out of range → null, NOT an error
0N
```

**Indexed assignment**: the type must match exactly in a simple list

```q
q)L:1 2 3
q)L[1]:42
q)L
1 42 3
q)L:100 200 300
q)L[1]:42h                            / short into a long list: no promotion
'type
```

**Index domain**: a wrong index type is an error; out of range gives the null of item 0's type

```q
q)L:(-10.0; 3.1415e; 1b; `abc; "z")
q)L[1.0]
'type
q)L1:1 2 3 4
q)L1[4]                               / index = count → out of range
0N
q)L2:1.1 2.2 3.3
q)L2[-1]
0n
q)L3:(`1; 2; 3.3)
q)L3[0W]                              / null of item 0's type (symbol)
`
```

**Empty index and `::` (the nil item)**

```q
q)L:10 20 30 40
q)L[]                                 / no index → the whole list
10 20 30 40
q).Q.s1 L[()]                         / an empty-list index → an empty list
"()"
q)L[::]                               / :: = an explicit "all"
10 20 30 40
```

**Using `::` to keep a list general**

```q
q)L:(::; 1 ; 2 ; 3)
q)type L
0h
q).Q.s1 L[0]
"::"
q)L:(1; 2; 3; `a)
q)L[3]:4                              / now all longs → q converts it to a simple list
q)L
1 2 3 4
q)L[3]:`a                             / can't put the symbol back
'type
q)L:(::; 1 ; 2 ; 3; `a)               / with :: as a guard
q)L[4]:4
q)L[4]:`a                             / works
```

- The drawback: don't pass the `::` on to calculations that use the real data.

**Expressions inside lists**

```q
q)a:42
q)b:43
q)(a; b)
42 43
q)L1:1 2 3
q)L2:40 50
q)(L1; L2)
1 2 3
40 50
q)(count L1; sum L2)
3 90
q)a b                                 / no shorthand list of variables: this means "apply a to b"
': Bad file descriptor
```

### 3.5 Combining lists

**Join `,`**

```q
q)1 2 3,4 5
1 2 3 4 5
q)1,2 3 4                             / atoms are fine on either side
1 2 3 4
q)1 2 3,4
1 2 3 4
q)1 2 3,4.4 5.5                       / mixed types → general list
1
2
3
4.4
5.5
```

- **Idiom:** `(),x` or `x,()` makes sure `x` is a list. It wraps an atom and leaves a list unchanged. `enlist x` wouldn't work: it would **nest** a list that's already a list.

**Coalesce `^`**: the right item wins, unless it's null

```q
q)L1:10 0N 30
q)L2:100 200 0N
q)L1^L2
100 200 30
```

### 3.6 Lists as maps

A list is a **function from index → item**: `i → L[i]`. Indexing looks just like calling a function. Out-of-range indices map to null.

```
101 102 103 104          (`a; 123.45; 1b)         (1 2; 3 4)
0 → 101                  0 → `a                   0 → 1 2
1 → 102                  1 → 123.45               1 → 3 4
2 → 103                  2 → 1b
3 → 104
```

### 3.7 Nesting and depth

**Depth** = how many index steps it takes to reach atoms. An atom has depth 0, a simple list 1, a list of lists 2.

```q
q)L:(1;2;(100;200))
q)count L
3
q)L:(1;2;100 200)
q)L
1
2
100 200
q)L[0]
1
q)L[1]
2
q)L[2]
100 200
q)L2:((1;2;3);(`ab;`c))
q)count L2
2
q)L3:((1; 2h; 3j); ("a"; `bc`de); 1.23)
q)count L3
3
q)L3[1]
"a"
`bc`de
q)count L3[1]
2
q)L4:enlist 1 2 3 4
q)count L4
1
q)count L4[0]
4
q)m:((11; 12; 13; 14); (21; 22; 23; 24); (31; 32; 33; 34))
q)m
11 12 13 14
21 22 23 24
31 32 33 34
q)m[0]
11 12 13 14
q)m[1]
21 22 23 24
q)m[1][0]
21
```

### 3.8 Iterated indexing vs indexing at depth

```q
q)L:(1; (100; 200; (1000; 2000; 3000; 4000)))
q)L[0]
1
q)L[1]
100
200
1000 2000 3000 4000
q)L[1][2]                             / iterated: index the result again
1000 2000 3000 4000
q)L[1][2][0]
1000
q)L[1;2;0]                            / at depth: the same thing, one bracket with ;
1000
```

**Assignment only works with the at-depth form**

```q
q)L:(1; (100; 200; (1000 2000 3000 4000)))
q)L[1; 2; 0]: 999
q)L
1
(100;200;999 2000 3000 4000)
q)L[1][2][0]:42                       / the intermediate results are temporary
'assign
```

```q
q)m:((11; 12; 13; 14); (21; 22; 23; 24); (31; 32; 33; 34))
q)m[0][0]
11
q)m[0; 0]
11
q)m[0; 1]
12
q)m[1; 2]
23
```

- The `;` in `L[1;2;0]` are **not** a list of indices. With `,` or no separators, you'd be indexing the top level with a list.

**Reshape with `0N`**: q works out one dimension

```q
q)2 0N#til 10                         / 2 rows, columns calculated
0 1 2 3 4
5 6 7 8 9
q)0N 3#til 10                         / 3 per row, rows calculated; the last row may be short
0 1 2
3 4 5
6 7 8
,9
```

### 3.9 Indexing with lists

The result has the **same shape as the index**.

```q
q)L:100 200 300 400
q)L[0]
100
q)L[2]
300
q)L[0 2]
100 300
q)L[3 2 0 1]                          / any order
400 300 100 200
q)L[0 2 0]                            / repeats are fine
100 300 100
q)01101011b[0 2 4]
011b
q)"beeblebrox"[0 7 8]
"bro"
q)I:0 2
q)L[I]                                / indices held in a variable
100 300
q)L[(0 1; 2 3)]                       / nested index → nested result (all from the top level)
100 200
300 400
```

**Assignment with list indices**: processed left to right

```q
q)L:100 200 300 400
q)L[0]:100
q)L
100 200 300 400
q)L[1 2 3]:2000 3000 4000
q)L
100 2000 3000 4000
q)L[3 2 1]:999 888 777                / same as L[3]:999; L[2]:888; L[1]:777
q)L:100 200 300 400
q)L[0 1 0 3]:1000 2000 3000 4000      / repeated index → the rightmost assignment wins
q)L
3000 2000 300 4000
q)L:100 200 300 400
q)L[1 3]:999                          / an atom is extended to every index
q)L
100 999 300 999
```

**Juxtaposition**: brackets are optional

```q
q)L:100 200 300 400
q)L 0
100
q)L[2 1]
300 200
q)L 2 1
300 200
q)I:2 1
q)L I
300 200
q)L ::
100 200 300 400
```

**Find `?`**: the index of the first match (the inverse of indexing)

```q
q)1001 1002 1003?1002
1
q)1001 1002 1003?1004                 / not found → count (one past the end)
3
q)1001 1002 1003?1003 1001            / works on a list on the right
2 0
```

### 3.10 Elided (omitted) indices

An omitted index means **all** for that position.

```q
q)m:(1 2 3 4; 100 200 300 400; 1000 2000 3000 4000)
q)m
1    2    3    4
100  200  300  400
1000 2000 3000 4000
q)m[1;]                               / row 1
100 200 300 400
q)m[;3]                               / column 3
4 400 4000
q)m[1;]~m[1]
1b
```

**Three levels deep**

```q
q)L:((1 2 3;4 5 6 7);(`a`b`c`d;`z`y`x`;`0`1`2);("now";"is";"the"))
q)L
(1 2 3;4 5 6 7)
(`a`b`c`d;`z`y`x`;`0`1`2)
("now";"is";"the")
q)L[;1;]                              / item 1 of each top-level list
4 5 6 7
`z`y`x`
"is"
q)L[;;2]                              / item 2 at the second level
3 6
`c`x`2
"w e"
q)L[0 2;;0 1]                         / rows 0 and 2, items 0 and 1 of every inner list
(1 2;4 5)
("no";"is";"th")
```

- `"w e"`: `"is"` has no index 2, so it gives the char null `" "`.
- **Style:** keep the trailing `;`. Write `L[;1;]`, not `L[;1]`, and write `L[1]`, not `L[1;;]`.

### 3.11 Rectangular lists and matrices

A **rectangular list** is a list of lists that all have the same count. `flip` transposes it, physically copying the data.

```q
q)L:(1 2 3; (10 20; 100 200; 1000 2000))
q)L
1 2 3
10 20 100 200 1000 2000
q)L:(1 2 3; 10 20 30; 100 200 300)
q)flip L
1 10 100
2 20 200
3 30 300
q)M:flip L
q)L[1;2]
30
q)M[2;1]                              / flip swaps the first two index positions
30
```

**Matrices**: a vector is a dimension-1 matrix, and a matrix of dimension n is a list of same-size matrices of dimension n−1. A vector doesn't have to be numeric.

```q
q)v1:1 2 3
q)v2:98.60 99.72 100.34 101.93
q)v3:`so`long`and`thanks`for`all`the`fish
q)mm:((1 2;3 4;5 6);(10 20;30 40;50 60))   / a 2×3×2 matrix
q)mm                                  / the display doesn't show the structure well
1 2 3 4 5 6
10 20 30 40 50 60
q)mm[0]
1 2
3 4
5 6
q)mm[1]
10 20
30 40
50 60
q)m:(1 2; 10 20; 100 200; 1000 2000)
q)m 0 2                               / pick rows 0 and 2
1   2
100 200
```

- `m[i]` = row `i`, `m[;j]` = column `j`, and `m[i][j]` = `m[i;j]`.
- Stored **row by row**, so rows are fast and columns are slower. A **table** is the reverse: a collection of **columns**. That's why q-sql column operations are fast.

### 3.12 Useful list operations

```q
q)til 10
0 1 2 3 4 5 6 7 8 9
q)1+til 10
1 2 3 4 5 6 7 8 9 10
q)2*til 10
0 2 4 6 8 10 12 14 16 18
q)1+2*til 10
1 3 5 7 9 11 13 15 17 19
q)-5+4*til 3
-5 -1 3
q)distinct 1 2 3 2 3 4 6 4 3 5 6       / unique items, in order of first occurrence
1 2 3 4 6 5
q)where 101010b                       / indices of the 1s
0 2 4
q)L:10 20 30 40 50
q)L[where L>20]:42                    / update where a condition holds
q)L
10 20 42 42 42
q)group "i miss mississippi"          / item → the indices where it occurs
i| 0 3 8 11 14 17
 | 1 6
m| 2 7
s| 4 5 9 10 12 13
p| 15 16
```

- `f each til count x` is almost always **loop-style code**. Look for a vector version instead.
"# kdb_q_learning" 

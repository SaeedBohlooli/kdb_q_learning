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
"# kdb_q_learning" 

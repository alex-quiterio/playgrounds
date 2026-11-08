# Dancing Links

Knuth's Algorithm X with Dancing Links, in C, and the puzzles it solves.

An **exact cover** problem is a 0/1 matrix: pick a set of rows so that every column has exactly one 1 among them. Many puzzles fit this shape once you choose what the rows (choices) and columns (constraints) are. Algorithm X searches by always branching on the column with the fewest 1s left. Dancing Links makes that search cheap: the matrix is stored as circular doubly linked lists of its 1s, so taking a row or column out and putting it back are O(1) pointer swaps.

The library also supports **secondary columns**, which may be covered at most once instead of exactly once. N-Queens uses them for diagonals and Spangram for crossing paths.

## Library

[`dancing_links.h`](dancing_links.h) is the whole interface:

```c
dancing_links *links = dancing_links_new(rows, primary_columns, secondary_columns, matrix);
long count = dancing_links_solve(links, -1, NULL, NULL);  /* count every solution */

int chosen[rows];
dancing_links_first first = {chosen, 0};
dancing_links_solve(links, -1, dancing_links_take_first, &first);  /* or stop at the first */
dancing_links_free(links);
```

`dancing_links_solve` calls a visitor once per solution with the chosen row indexes, until the visitor returns `false`. Its second argument caps how many rows a solution may use (`-1` for no cap). The search order is fixed, so the first solution found is always the same.

[`puzzle.h`](puzzle.h) holds what the puzzles share: `fail()` for bad input, allocation that never returns `NULL`, and `solve_first()`, which builds the links, takes the first solution and frees them again.

## Puzzles

Each puzzle is in `<name>/<name>.c` and reads its puzzle from standard input. It turns the puzzle into a matrix, solves it, and prints the answer.

### N-Queens

Count the ways to place N queens on an NxN board so that no two attack each other, and optionally list them.

**Model.** A queen on each square is a row. Each board row and each board column needs exactly one queen, so those are primary columns. Each of the 4N-2 diagonals can hold at most one queen, so those are secondary columns.

**Input.** `N`, then `T`. With `T = 0` it prints only the count; otherwise it also lists every solution as `row column` pairs.

```sh
echo "8 0" | ./build/nqueens    # 92
```

## Running

```sh
make test                   # library unit tests, then every puzzle against its example
make run PUZZLE=nqueens     # solve one puzzle's example
make clean
```

Binaries go to `build/` and are built with AddressSanitizer and UBSan.
[`tests/test_dancing_links.c`](tests/test_dancing_links.c) checks the library itself, starting from the example matrix in Knuth's paper.
[`tests/run.sh`](tests/run.sh) runs each puzzle on `<name>/example.in`, passes the arguments in `<name>/example.args` if there is one, and compares the output with `<name>/example.out`.

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

Each puzzle is in `<name>/<name>.c` and reads its puzzle from standard input. Each one turns the puzzle into a matrix, solves it, and prints the answer.

### N-Queens

Count the ways to place N queens on an NxN board so that no two attack each other, and optionally list them.

**Model.** A queen on each square is a row. Each board row and each board column needs exactly one queen, so those are primary columns. Each of the 4N-2 diagonals can hold at most one queen, so those are secondary columns.

**Input.** `N`, then `T`. With `T = 0` it prints only the count; otherwise it also lists every solution as `row column` pairs.

```sh
echo "8 0" | ./build/nqueens    # 92
```

### Sudoku

Fill a 9x9 board so that every row, column and 3x3 box holds the digits 1 to 9 once each.

**Model.** Placing digit d in cell (r, c) is a row: 729 in all. There are four groups of 81 primary columns: every cell holds one digit, and every row, column and box holds each digit once. Given digits are removed up front, along with every choice they rule out, so the matrix only holds what is still open.

**Input.** The 81 cells row by row, with `0` for an empty cell.

```sh
make run PUZZLE=sudoku
```

### Dominosa

Tile a board of numbers with dominoes so that no domino appears twice. Play it at [puzzle-dominosa.com](http://www.puzzle-dominosa.com/).

**Model.** Every horizontal and vertical domino position is a row. Every cell must be covered once, and every pair of numbers must be used once. A `d-e` domino marks both the `(d, e)` and `(e, d)` columns, so each unordered pair is used exactly once.

**Input.** The height H, then the H x (H+1) board row by row, using the numbers 0 to H-1. The output marks each cell with `-` or `|` for the domino covering it.

```sh
make run PUZZLE=dominosa
```

### Rectangles (Shikaku)

Split a board into rectangles so that each one holds exactly one number, equal to its area. Play it at [Simon Tatham's puzzles](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/rect.html).

**Model.** Every rectangle around a number, with that number's area and no other number inside, is a row. Prefix sums make the "exactly one number" check constant time. Every cell must be covered exactly once.

**Input.** The height and width, then the board row by row with `0` for an empty cell. The output labels every cell with the rectangle it belongs to.

```sh
make run PUZZLE=rectangles
```

### Spangram (Strands)

Cover every letter of a grid with words traced through neighbouring cells, diagonals included, the way the NYT game [Strands](https://www.nytimes.com/games/strands) works. Each cell is used once and no two paths cross.

**Model.** The word list goes into a trie. A depth-first search from every cell finds every way to trace every word, and each of those is a row. Every cell is a primary column. Each 2x2 block of cells adds a secondary column: its two diagonals cross, so at most one path may step through it diagonally.

**Input.** The grid, one row of letters per line. Arguments can come in any order:

- a number: the most words the solution may use
- a name with a dot: the word list (default `words.txt`)
- any other word: a word the solution must not use

The output lists the words found, then draws their paths on the grid with each word's first letter in upper case. If the answer isn't the one you want, run it again with the unwanted words forbidden. The test uses a small word list, [`spangram/words.txt`](spangram/words.txt). For real puzzles, try a large list such as [english-words](https://github.com/dwyl/english-words/blob/master/words.txt).

```sh
./build/spangram spangram/words.txt 8 nori < spangram/example.in
```

## Running

```sh
make test                   # library unit tests, then every puzzle against its example
make run PUZZLE=sudoku      # solve one puzzle's example
make clean
```

Binaries go to `build/` and are built with AddressSanitizer and UBSan.
[`tests/test_dancing_links.c`](tests/test_dancing_links.c) checks the library itself, starting from the example matrix in Knuth's paper.
[`tests/run.sh`](tests/run.sh) runs each puzzle on `<name>/example.in`, passes the arguments in `<name>/example.args` if there is one, and compares the output with `<name>/example.out`.

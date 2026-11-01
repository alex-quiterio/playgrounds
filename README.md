# Playgrounds

[![Tests](https://github.com/alex-quiterio/playgrounds/actions/workflows/tests.yml/badge.svg)](https://github.com/alex-quiterio/playgrounds/actions/workflows/tests.yml)

Small algorithm and language exercises in C, Go, Ruby, Prolog and Common Lisp.
Each one runs on its own and has its own tests.

## Exercises

| Exercise | Language | What it does |
| --- | --- | --- |
| [`c/cyk`](c/cyk/CYK.c) | C | CYK parser that checks whether binary strings belong to a grammar in Chomsky normal form |
| [`c/doubled-linked-lists`](c/doubled-linked-lists) | C | Doubly linked list with "methods" stored as function pointers |
| [`c/rod`](c/rod/rod.c) | C | Rod cutting: the best price from cutting a rod into pieces (dynamic programming) |
| [`go/insertion-sort`](go/insertion-sort/insertion_sort.go) | Go | In-place insertion sort |
| [`go/twitter-puddle`](go/twitter-puddle/twitter_puddle.go) | Go | Twitter's "puddle" puzzle: how much water a skyline of walls holds |
| [`ruby/backtracking-algos`](ruby/backtracking-algos) | Ruby | A generic backtracking engine, used for N-Queens and Sudoku |
| [`ruby/generational-algos`](ruby/generational-algos) | Ruby | N-Queens with a genetic (generational) algorithm |
| [`prolog/oscares.pl`](prolog/oscares.pl) | Prolog | Queries over a film/Oscars database, a social-network search, and a tiny Portuguese question parser |
| [`lisp/y_game.lisp`](lisp/y_game.lisp) | Common Lisp | The game of Y on a ring board, with a minimax / alpha-beta computer player |

## Requirements

| Language | Tool | macOS | Debian/Ubuntu |
| --- | --- | --- | --- |
| C | `cc` (clang or gcc), `make` | Xcode Command Line Tools | `build-essential` |
| Go | Go 1.27+ | `brew install go` | [go.dev/dl](https://go.dev/dl/) |
| Ruby | Ruby 3.4+ (`minitest` and `rake` ship with it) | `brew install ruby` | `ruby` |
| Prolog | SWI-Prolog | `brew install swi-prolog` | `swi-prolog-nox` |
| Common Lisp | SBCL | `brew install sbcl` | `sbcl` |

## Running the tests

From the repository root:

```sh
make test          # everything
make test-c        # one language: test-c, test-go, test-ruby, test-prolog, test-lisp
make format        # clang-format for C, gofmt for Go
```

[GitHub Actions](.github/workflows/tests.yml) runs each language as its own job on every push to `main` and on every pull request.

## Running each exercise

### C

Each C exercise has a Makefile with `run`, `test` and `clean` targets. Binaries go to `build/` and are built with AddressSanitizer and UBSan.

```sh
make -C c/rod run
make -C c/doubled-linked-lists run
make -C c/cyk run < c/cyk/tests/cases/zeros_then_ones.in
```

**CYK input format.** First the grammar, one rule per line, ending with `#`:

- `XYZ` is the binary rule `X -> Y Z`
- `Xa` is the terminal rule `X -> a`
- `R` is the start symbol

Then the strings to check, one per line, ending with `#`. The program prints `yes` or `no` for each string:

```text
RAB        R -> A B
A0         A -> 0
B1         B -> 1
#
01         yes
10         no
#
```

The tests are pairs of `.in` / `.out` files in [`c/cyk/tests/cases`](c/cyk/tests/cases).

### Go

```sh
cd go
go run ./insertion-sort
go run ./twitter-puddle
go test ./...
```

### Ruby

```sh
cd ruby/backtracking-algos
rake "backtrack:nqueens[8]"
rake "backtrack:sudoku[easy01]"   # any file name from sudoku/puzzles, without .sud
rake test

cd ../generational-algos
rake "generational:nqueens[10,10]"  # board size, number of generations
rake test
```

Sudoku puzzles are 81 cells, written row by row: digits for given cells, `.` for empty ones. Whitespace and line breaks are ignored.

### Prolog

`oscares.pl` needs a database with these facts: `actividade/2`, `pessoa/4`, `filme/4`, `participa/3` and `nomeada/4`. [`prolog/tests/fixtures.pl`](prolog/tests/fixtures.pl) is a small example database:

```sh
cd prolog
swipl tests/fixtures.pl oscares.pl
?- maisOscares(realizador).
?- redeSocial(bruno, duarte).
?- questao('filmes de 1995').
```

### Common Lisp

```sh
cd lisp
sbcl --load y_game.lisp
* (executa-jogo 3 #'faz-jogador-manual #'faz-jogador-automatico 0)
```

The arguments are the number of rings, player A, player B, and the time limit per move in seconds (`0` means no limit).

## Known issues

These are bugs in the exercises themselves. Each one is covered by a test that is **skipped** for now; un-skip it once the bug is fixed.

- **`go/twitter-puddle`**: `findPuddles` gets the wrong answer for about half of all random skylines. For example, `[6 1 4 8]` should hold 7 units and the program says 0. See `TestWaterRetainedKnownFailures`.
- **`ruby/generational-algos`**:
  - `reproduce` leaves `false` values in the gene, so `run` crashes in `is_threat`.
  - `is_threat` only checks one of the two diagonal directions.
  - `evaluate` uses integer division, so fitness can only be 0 or 1.
  - The board size is taken from `size`, which is also the population size.
- **`lisp/y_game.lisp`**: `alpha-beta-decision` misses a winning move that is one turn away when the search depth is 1 or 2.

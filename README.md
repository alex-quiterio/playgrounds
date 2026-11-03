# Playgrounds

[![Tests](https://github.com/alex-quiterio/playgrounds/actions/workflows/tests.yml/badge.svg)](https://github.com/alex-quiterio/playgrounds/actions/workflows/tests.yml)

Small algorithm and language exercises in C, Go, Ruby, Prolog and Common Lisp, plus
[Advent of Code](#advent-of-code) solutions in six languages. Each one runs on its own and has its own tests.

## Exercises

| Exercise | Language | What it does |
| --- | --- | --- |
| [`c/cyk`](c/cyk/CYK.c) | C | CYK parser that checks whether binary strings belong to a grammar in Chomsky normal form |
| [`c/doubled-linked-lists`](c/doubled-linked-lists) | C | Doubly linked list with "methods" stored as function pointers |
| [`c/rod`](c/rod/rod.c) | C | Rod cutting: the best price from cutting a rod into pieces (dynamic programming) |
| [`go/insertion-sort`](go/insertion-sort/insertion_sort.go) | Go | In-place insertion sort |
| [`go/twitter-puddle`](go/twitter-puddle/twitter_puddle.go) | Go | Twitter's "puddle" puzzle: how much water a skyline of walls holds |
| [`ruby/backtracking-algos`](ruby/backtracking-algos) | Ruby | A generic backtracking engine, used for N-Queens and Sudoku |
| [`ruby/generational-algos`](ruby/generational-algos) | Ruby | N-Queens with a genetic algorithm (cycle crossover plus swap mutation) |
| [`prolog/oscares.pl`](prolog/oscares.pl) | Prolog | Queries over a film/Oscars database, a social-network search, and a tiny Portuguese question parser |
| [`lisp/y_game.lisp`](lisp/y_game.lisp) | Common Lisp | The game of Y on a ring board, with a minimax / alpha-beta computer player |

## Advent of Code

[`advent-of-code/`](advent-of-code) holds solutions to [Advent of Code](https://adventofcode.com), the December puzzle calendar. Each year picks its language (2022 uses two), and every star counted below was earned on adventofcode.com.

| Year | Language | Solved | Stars |
| --- | --- | --- | --- |
| [2025](advent-of-code/2025) | Common Lisp | all 12 days | ⭐ 24 / 24 |
| [2024](advent-of-code/2024) | Go | all 25 days | ⭐ 50 / 50 |
| [2023](advent-of-code/2023) | Ruby | all 25 days | ⭐ 50 / 50 |
| [2022](advent-of-code/2022) | C and Perl | all 25 days | ⭐ 50 / 50 |
| [2021](advent-of-code/2021) | Clojure | all 25 days (day 6 solved elsewhere) | ⭐ 50 / 50 |
| [2020](advent-of-code/2020) | C++ | all 25 days | ⭐ 50 / 50 |
| [2019](advent-of-code/2019) | Haskell | all 25 days | ⭐ 50 / 50 |
| 2018 | not in this repo | all 25 days, solved elsewhere | ⭐ 50 / 50 |
| 2017 | not in this repo | all 25 days, solved elsewhere | ⭐ 50 / 50 |
| [2016](advent-of-code/2016) | Lua | days 1-13 | ⭐ 26 / 50 |
| [2015](advent-of-code/2015) | Ruby | all 25 days (days 1-5, 7, 9 and 10 solved elsewhere) | ⭐ 50 / 50 |

**500 stars** on the account, **382** of them with code in this repository. Each year's README has a ✅ per part, filled in from the Advent of Code calendar.

### Quick start

```sh
cd advent-of-code
bin/check                          # every solved day against its examples
bin/check 2024 17                  # one day
./2023/day05/run 2023/day05/example.txt
```

### How a day works

Every day is a folder such as `2024/day17/`, with one rule: an executable `run` takes an input file and prints the **part 1 answer on line 1** and the **part 2 answer on line 2**. That keeps each year free to use any language. `run` might call `go run`, `ruby`, `sbcl --script`, `clojure -M`, `perl`, or compile C first.

- `example.txt` / `example.expected` hold the examples and answers from the puzzle text. Extra examples are `example-2`, `example-3` and so on.
- `bin/check` runs every solution against those examples. It also re-checks your real input against `input.expected` once an answer has been accepted.
- Extra runners such as `run-perl` are checked too. 2022 days 9 and 10 are solved in both C and Perl.
- Puzzle text and puzzle inputs are **not committed**: [Advent of Code asks](https://adventofcode.com/about) that they aren't shared. `bin/fetch-puzzle` and `bin/fetch-input` save them locally (gitignored).

The tooling in [`advent-of-code/bin`](advent-of-code/bin) covers the whole loop: `new-year` and `new-day` scaffold, `fetch-puzzle` / `fetch-year` / `fetch-input` download, `submit` sends an answer, and `progress` updates the ✅ marks. The full workflow is in the [Advent of Code README](advent-of-code/README.md).

### A few favourites

| Puzzle | Idea |
| --- | --- |
| [2025 day 10](advent-of-code/2025/day10/solution.lisp), Factory | Minimum button presses as a parity recursion: press a subset once to fix the parity, halve the rest, repeat |
| [2024 day 17](advent-of-code/2024/day17/main.go), Chronospatial Computer | Builds the self-printing input three bits at a time, from the last output back |
| [2024 day 24](advent-of-code/2024/day24/main.go), Crossed Wires | Finds the swapped wires by checking each gate against the rules of a ripple-carry adder |
| [2023 day 10](advent-of-code/2023/day10/solution.rb), Pipe Maze | Tiles inside the loop from the shoelace formula plus Pick's theorem, with no flood fill |
| [2023 day 24](advent-of-code/2023/day24/solution.rb), Never Tell Me The Odds | The rock's throw as six linear equations, solved exactly with rationals |
| [2022 day 10](advent-of-code/2022/day10/solution.c), Cathode-Ray Tube | Draws the CRT, then reads the letters back as text |

## Requirements

| Language | Tool | macOS | Debian/Ubuntu |
| --- | --- | --- | --- |
| C | `cc` (clang or gcc), `make` | Xcode Command Line Tools | `build-essential` |
| Go | Go 1.27+ | `brew install go` | [go.dev/dl](https://go.dev/dl/) |
| Ruby | Ruby 3.4+ (`minitest` and `rake` ship with it) | `brew install ruby` | `ruby` |
| Prolog | SWI-Prolog | `brew install swi-prolog` | `swi-prolog-nox` |
| Common Lisp | SBCL | `brew install sbcl` | `sbcl` |
| Lua (Advent of Code 2016) | Lua 5.4+ | `brew install lua` | `lua5.4` |
| Perl (Advent of Code 2022) | Perl 5 | preinstalled | preinstalled |
| C++ (Advent of Code 2020) | `c++` with C++20 (clang or gcc) | Xcode Command Line Tools | `build-essential` |
| Haskell (Advent of Code 2019) | GHC (`base` and `containers`) | `brew install ghc` | `ghc` |
| Clojure (Advent of Code 2021) | Clojure CLI and a JDK | `brew install clojure openjdk` | [clojure.org install script](https://clojure.org/guides/install_clojure) |

## Running the tests

From the repository root:

```sh
make test          # everything
make test-c        # one part: test-c, test-go, test-ruby, test-prolog, test-lisp, test-aoc
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
rake "generational:nqueens[8,1000]"  # board size, maximum number of generations
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
* (executa-jogo 3 #'faz-jogador-manual #'faz-jogador-automatico 5)
```

The arguments are the number of rings, player A, player B, and the time limit per move in seconds. The computer player searches deeper and deeper (alpha-beta) until it runs out of time. With a limit of `0` it searches every remaining move, which is only practical on 2 rings.

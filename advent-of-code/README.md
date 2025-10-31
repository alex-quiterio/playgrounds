# Advent of Code

Solutions to [Advent of Code](https://adventofcode.com), one folder per year and per day. Each day can be written in any language.

```text
advent-of-code/
├── bin/
│   ├── new-year       # create YEAR/README.md with a progress table
│   ├── new-day        # create YEAR/dayNN from the template
│   ├── fetch-puzzle   # save a puzzle's text as dayNN/puzzle.md (gitignored)
│   ├── fetch-year     # fetch every puzzle of a year and fill in the titles
│   ├── fetch-input    # download your puzzle input (needs AOC_SESSION)
│   ├── submit         # submit an answer and record it when accepted
│   ├── progress       # mark solved parts with ✅ in YEAR/README.md
│   └── check          # run every solution against its examples
├── 2023/  2024/
└── 2025/
    └── day01/
        ├── README.md          # puzzle link and notes
        ├── puzzle.md          # puzzle text (gitignored)
        ├── run                # your solution: any executable
        ├── example.txt        # example input from the puzzle text
        ├── example.expected   # the example's answers
        ├── input.txt          # your puzzle input (gitignored)
        └── input.expected     # your accepted answers (gitignored, optional)
```

## A day's contract

`run` is any executable: a script with a shebang, or a small wrapper such as `exec go run . "$@"`. The checker calls it from the day's folder:

```sh
./run example.txt
```

It must print the **part 1 answer on line 1** and the **part 2 answer on line 2**.

`example.expected` holds the answers from the puzzle text, one per line. Only the lines you have written are compared, so put in the part 1 answer first and add part 2 once it unlocks. More examples go in `example-2.txt` / `example-2.expected` and so on.

## Workflow

```sh
cd advent-of-code
bin/new-year 2027              # a new edition: writes 2027/README.md with its progress table
bin/new-day 1 2027             # creates 2027/day01 (the year defaults to the current one)
# paste the example into example.txt and its answer into example.expected
# write ./run
export AOC_SESSION=...         # the "session" cookie from adventofcode.com
bin/fetch-input 1 2027         # saves 2027/day01/input.txt
./2027/day01/run 2027/day01/input.txt
bin/check 2027                 # every day of 2027; bin/check 2027 1 for one day
```

`bin/submit DAY YEAR PART` runs `./run input.txt` and submits that part's answer (or pass the answer as a fourth argument). When it is accepted, it is saved in `input.expected` and the year's table is updated. `bin/progress YEAR` refreshes the ✅ marks on its own. With a session it reads the stars from your calendar, so days solved elsewhere count too. Without one it uses `input.expected`.

Once an answer is accepted, it lives in `input.expected`. `bin/check` will then also re-check your real input, which is useful when you refactor.

From the repository root, `make test-aoc` runs `bin/check` for every year. CI runs the same command against the examples only, because inputs are never committed. CI runs on `ubuntu-latest`, which comes with Python, Ruby and Node, and the job also installs Go (for 2024) and SBCL (for 2025). If a day needs anything else, add a setup step to the `advent-of-code` job in [`.github/workflows/tests.yml`](../.github/workflows/tests.yml).

## Puzzle text

`bin/fetch-year 2024` saves every puzzle as `dayNN/puzzle.md` and writes the titles into `2024/README.md`. `bin/fetch-puzzle DAY YEAR` does one day. Without a session you only get part 1. With one, you also get part 2 for the days you have solved. Fetch again after solving part 1. `bin/new-day` fills `example.txt` from the first example in `puzzle.md`. Puzzle text is gitignored as well.

The session cookie is read from `AOC_SESSION`, or from `~/.config/aoc/session` when that variable is not set.

## Inputs

Advent of Code [asks](https://adventofcode.com/about) that puzzle inputs and puzzle text are not shared, so `input*.txt` and `input*.expected` are gitignored. `bin/fetch-input` downloads each input only once and sends a User-Agent that points back to this repository, as the site's automation guidelines ask.

## Years

| Year | Progress |
| --- | --- |
| [2023](2023) | Ruby: days 1-15, 30 stars |
| [2024](2024) | Go: all 25 days, 50 stars |
| [2025](2025) | Common Lisp: all 12 days, 24 stars |

Add another year with `bin/new-year YEAR`. It writes the progress table: 25 days up to 2024, 12 from 2025 on.

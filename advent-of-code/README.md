# Advent of Code

Solutions to [Advent of Code](https://adventofcode.com), one folder per year and per day. Each day can be written in any language.

```text
advent-of-code/
├── bin/
│   ├── new-day        # create YEAR/dayNN from the template
│   ├── fetch-input    # download your puzzle input (needs AOC_SESSION)
│   └── check          # run every solution against its examples
└── 2026/
    └── day01/
        ├── README.md          # puzzle link and notes
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
bin/new-day 1                  # creates 2026/day01 (the year defaults to the current one)
# paste the example into example.txt and its answer into example.expected
# write ./run
export AOC_SESSION=...         # the "session" cookie from adventofcode.com
bin/fetch-input 1              # saves 2026/day01/input.txt
./2026/day01/run 2026/day01/input.txt
bin/check 2026                 # every day of 2026; bin/check 2026 1 for one day
```

Once an answer is accepted, save it in `input.expected`. `bin/check` will then also re-check your real input, which is useful when you refactor.

From the repository root, `make test-aoc` runs `bin/check` for every year. CI runs the same command against the examples only, because inputs are never committed. CI runs on `ubuntu-latest`, which comes with Python, Ruby, Go and Node. If a day needs anything else, add a setup step to the `advent-of-code` job in [`.github/workflows/tests.yml`](../.github/workflows/tests.yml).

## Inputs

Advent of Code [asks](https://adventofcode.com/about) that puzzle inputs and puzzle text are not shared, so `input*.txt` and `input*.expected` are gitignored. `bin/fetch-input` downloads each input only once and sends a User-Agent that points back to this repository, as the site's automation guidelines ask.

## Years

| Year | Progress |
| --- | --- |
| [2026](2026) | not started |

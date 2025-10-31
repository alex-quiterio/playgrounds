# Advent of Code 2022

This edition has 25 puzzles; only days 1-3 are set up here. Start a day with `bin/new-day N 2022` from `advent-of-code/`.

2022 is the **C** year. Each day will be a `solution.c`, built and run by an executable `run`:

```sh
#!/bin/sh
dir="$(dirname "$0")"
cc -std=c11 -O2 -Wall -o "$dir/solution" "$dir/solution.c" && exec "$dir/solution" "$@"
```

| Day | Puzzle | Language | Part 1 | Part 2 |
| --- | --- | --- | --- | --- |
| 1 | [Calorie Counting](https://adventofcode.com/2022/day/1) | C |  |  |
| 2 | [Rock Paper Scissors](https://adventofcode.com/2022/day/2) | C |  |  |
| 3 | [Rucksack Reorganization](https://adventofcode.com/2022/day/3) | C |  |  |

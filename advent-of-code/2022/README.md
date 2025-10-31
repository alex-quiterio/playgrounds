# Advent of Code 2022

This edition has 25 puzzles; only days 1-15 are set up here. Start a day with `bin/new-day N 2022` from `advent-of-code/`.

2022 mixes two languages, each with an executable `run`:

- **Days 1-3, 7-10 and 14-15 in C**: `run` compiles `solution.c` when it changed, then runs it.
- **Days 4-6 and 11-13 in Perl**: `run` is `exec perl "$(dirname "$0")/solution.pl" "$@"`.
- **Days 9 and 10 in both**: `run` is the C version and `run-perl` the Perl one. `bin/check` checks both.

| Day | Puzzle | Language | Part 1 | Part 2 |
| --- | --- | --- | --- | --- |
| 1 | [Calorie Counting](https://adventofcode.com/2022/day/1) | C | ✅ | ✅ |
| 2 | [Rock Paper Scissors](https://adventofcode.com/2022/day/2) | C | ✅ | ✅ |
| 3 | [Rucksack Reorganization](https://adventofcode.com/2022/day/3) | C | ✅ | ✅ |
| 4 | [Camp Cleanup](https://adventofcode.com/2022/day/4) | Perl | ✅ | ✅ |
| 5 | [Supply Stacks](https://adventofcode.com/2022/day/5) | Perl | ✅ | ✅ |
| 6 | [Tuning Trouble](https://adventofcode.com/2022/day/6) | Perl | ✅ | ✅ |
| 7 | [No Space Left On Device](https://adventofcode.com/2022/day/7) | C | ✅ | ✅ |
| 8 | [Treetop Tree House](https://adventofcode.com/2022/day/8) | C | ✅ | ✅ |
| 9 | [Rope Bridge](https://adventofcode.com/2022/day/9) | C + Perl | ✅ | ✅ |
| 10 | [Cathode-Ray Tube](https://adventofcode.com/2022/day/10) | C + Perl | ✅ | ✅ |
| 11 | [Monkey in the Middle](https://adventofcode.com/2022/day/11) | Perl | ✅ | ✅ |
| 12 | [Hill Climbing Algorithm](https://adventofcode.com/2022/day/12) | Perl | ✅ | ✅ |
| 13 | [Distress Signal](https://adventofcode.com/2022/day/13) | Perl | ✅ | ✅ |
| 14 | [Regolith Reservoir](https://adventofcode.com/2022/day/14) | C | ✅ | ✅ |
| 15 | [Beacon Exclusion Zone](https://adventofcode.com/2022/day/15) | C | ✅ | ✅ |

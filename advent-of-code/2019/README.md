# Advent of Code 2019

This edition has 25 puzzles; only day 1 is set up here. Start a day with `bin/new-day N 2019` from `advent-of-code/`.

2019 is in **Clojure**. Each day is a `solution.clj`, run by an executable `run`:

```sh
#!/bin/sh
exec clojure -M "$(dirname "$0")/solution.clj" "$@"
```

| Day | Puzzle | Language | Part 1 | Part 2 |
| --- | --- | --- | --- | --- |
| 1 | [The Tyranny of the Rocket Equation](https://adventofcode.com/2019/day/1) | Clojure | ✅ | ✅ |

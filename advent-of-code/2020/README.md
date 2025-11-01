# Advent of Code 2020

This edition has 25 puzzles, all solved. Start a day with `bin/new-day N 2020` from `advent-of-code/`.

2020 is in **C++** (C++20, standard library only). Each day is a `solution.cpp`, and its executable `run` compiles it when it changed, then runs it:

```sh
#!/bin/sh
dir="$(dirname "$0")"
if [ ! -x "$dir/solution" ] || [ "$dir/solution.cpp" -nt "$dir/solution" ]; then
    c++ -std=c++20 -O2 -Wall -Wextra -o "$dir/solution" "$dir/solution.cpp" || exit 1
fi
exec "$dir/solution" "$@"
```

| Day | Puzzle | Language | Part 1 | Part 2 |
| --- | --- | --- | --- | --- |
| 1 | [Report Repair](https://adventofcode.com/2020/day/1) | C++ | ✅ | ✅ |
| 2 | [Password Philosophy](https://adventofcode.com/2020/day/2) | C++ | ✅ | ✅ |
| 3 | [Toboggan Trajectory](https://adventofcode.com/2020/day/3) | C++ | ✅ | ✅ |
| 4 | [Passport Processing](https://adventofcode.com/2020/day/4) | C++ | ✅ | ✅ |
| 5 | [Binary Boarding](https://adventofcode.com/2020/day/5) | C++ | ✅ | ✅ |
| 6 | [Custom Customs](https://adventofcode.com/2020/day/6) | C++ | ✅ | ✅ |
| 7 | [Handy Haversacks](https://adventofcode.com/2020/day/7) | C++ | ✅ | ✅ |
| 8 | [Handheld Halting](https://adventofcode.com/2020/day/8) | C++ | ✅ | ✅ |
| 9 | [Encoding Error](https://adventofcode.com/2020/day/9) | C++ | ✅ | ✅ |
| 10 | [Adapter Array](https://adventofcode.com/2020/day/10) | C++ | ✅ | ✅ |
| 11 | [Seating System](https://adventofcode.com/2020/day/11) | C++ | ✅ | ✅ |
| 12 | [Rain Risk](https://adventofcode.com/2020/day/12) | C++ | ✅ | ✅ |
| 13 | [Shuttle Search](https://adventofcode.com/2020/day/13) | C++ | ✅ | ✅ |
| 14 | [Docking Data](https://adventofcode.com/2020/day/14) | C++ | ✅ | ✅ |
| 15 | [Rambunctious Recitation](https://adventofcode.com/2020/day/15) | C++ | ✅ | ✅ |
| 16 | [Ticket Translation](https://adventofcode.com/2020/day/16) | C++ | ✅ | ✅ |
| 17 | [Conway Cubes](https://adventofcode.com/2020/day/17) | C++ | ✅ | ✅ |
| 18 | [Operation Order](https://adventofcode.com/2020/day/18) | C++ | ✅ | ✅ |
| 19 | [Monster Messages](https://adventofcode.com/2020/day/19) | C++ | ✅ | ✅ |
| 20 | [Jurassic Jigsaw](https://adventofcode.com/2020/day/20) | C++ | ✅ | ✅ |
| 21 | [Allergen Assessment](https://adventofcode.com/2020/day/21) | C++ | ✅ | ✅ |
| 22 | [Crab Combat](https://adventofcode.com/2020/day/22) | C++ | ✅ | ✅ |
| 23 | [Crab Cups](https://adventofcode.com/2020/day/23) | C++ | ✅ | ✅ |
| 24 | [Lobby Layout](https://adventofcode.com/2020/day/24) | C++ | ✅ | ✅ |
| 25 | [Combo Breaker](https://adventofcode.com/2020/day/25) | C++ | ✅ | ✅ |

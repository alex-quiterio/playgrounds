# Advent of Code 2019

This edition has 25 puzzles; days 1-15 are solved here. Start a day with `bin/new-day N 2019` from `advent-of-code/`.

2019 is in **Haskell** (GHC, with only `base` and `containers`). Each day is a `solution.hs`, and its executable `run` compiles it when it changed, then runs it:

```sh
#!/bin/sh
dir="$(dirname "$0")"
if [ ! -x "$dir/solution" ] || [ "$dir/solution.hs" -nt "$dir/solution" ] || [ "$dir/../intcode/Intcode.hs" -nt "$dir/solution" ]; then
    ghc -O2 -v0 -i"$dir/../intcode" -outputdir "$dir/build" -o "$dir/solution" "$dir/solution.hs" || exit 1
fi
exec "$dir/solution" "$@"
```

Half of this year runs programs for the Intcode computer, so it lives once in [`intcode/Intcode.hs`](intcode/Intcode.hs) and days 2, 5, 7, 9, 11, 13 and 15 import it. A machine runs until it halts, outputs a value or needs an input, and hands control back at each of those points, so days can chain machines (7) or drive them interactively (11, 13, 15).

| Day | Puzzle | Language | Part 1 | Part 2 |
| --- | --- | --- | --- | --- |
| 1 | [The Tyranny of the Rocket Equation](https://adventofcode.com/2019/day/1) | Haskell | ✅ | ✅ |
| 2 | [1202 Program Alarm](https://adventofcode.com/2019/day/2) | Haskell | ✅ | ✅ |
| 3 | [Crossed Wires](https://adventofcode.com/2019/day/3) | Haskell | ✅ | ✅ |
| 4 | [Secure Container](https://adventofcode.com/2019/day/4) | Haskell | ✅ | ✅ |
| 5 | [Sunny with a Chance of Asteroids](https://adventofcode.com/2019/day/5) | Haskell | ✅ | ✅ |
| 6 | [Universal Orbit Map](https://adventofcode.com/2019/day/6) | Haskell | ✅ | ✅ |
| 7 | [Amplification Circuit](https://adventofcode.com/2019/day/7) | Haskell | ✅ | ✅ |
| 8 | [Space Image Format](https://adventofcode.com/2019/day/8) | Haskell | ✅ | ✅ |
| 9 | [Sensor Boost](https://adventofcode.com/2019/day/9) | Haskell | ✅ | ✅ |
| 10 | [Monitoring Station](https://adventofcode.com/2019/day/10) | Haskell | ✅ | ✅ |
| 11 | [Space Police](https://adventofcode.com/2019/day/11) | Haskell | ✅ | ✅ |
| 12 | [The N-Body Problem](https://adventofcode.com/2019/day/12) | Haskell | ✅ | ✅ |
| 13 | [Care Package](https://adventofcode.com/2019/day/13) | Haskell | ✅ | ✅ |
| 14 | [Space Stoichiometry](https://adventofcode.com/2019/day/14) | Haskell | ✅ | ✅ |
| 15 | [Oxygen System](https://adventofcode.com/2019/day/15) | Haskell | ✅ | ✅ |

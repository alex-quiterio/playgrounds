# Day 5

Puzzle: https://adventofcode.com/2016/day/5

## Part 1

## Part 2

## Notes

Lua has no MD5, so `solution.lua` carries a one-block MD5 (RFC 1321) that only returns the first 32 bits of the digest, the only part the puzzle reads. The example takes about 40 seconds, the real input about 80.

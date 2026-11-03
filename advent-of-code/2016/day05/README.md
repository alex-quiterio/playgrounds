# Day 5

Puzzle: https://adventofcode.com/2016/day/5

## Part 1

## Part 2

## Notes

Lua has no MD5, so this uses `../lib/md5.lua`. Tens of millions of hashes are needed, so no string is built per hash: the index's digits are counted up in a byte array and MD5's single block is filled straight from it. The real input takes about 5 seconds.

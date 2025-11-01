-- Day 16: Flawed Frequency Transmission
{-# LANGUAGE BangPatterns #-}

import Data.Char (digitToInt, intToDigit, isDigit)
import qualified Data.List as List
import qualified Data.Sequence as Seq
import System.Environment (getArgs)

-- | One phase. Output digit i (1-based) multiplies the input by the pattern
-- 0, 1, 0, -1 with each value repeated i times, so it is a sum of runs of
-- length i: + the runs starting at i-1, 5i-1, 9i-1, ...; - those at 3i-1, 7i-1, ...
-- With prefix sums each run costs one subtraction, n/i runs per digit.
phase :: [Int] -> [Int]
phase xs = [abs (total i) `mod` 10 | i <- [1 .. n]]
  where
    n = length xs
    prefix = Seq.fromList (scanl (+) 0 xs) -- prefix `Seq.index` k = sum of the first k
    range a b = Seq.index prefix (min n b) - Seq.index prefix (min n a)
    total i =
      sum [range s (s + i) | s <- [i - 1, 5 * i - 1 .. n - 1]]
        - sum [range s (s + i) | s <- [3 * i - 1, 7 * i - 1 .. n - 1]]

-- | Part 2 reads 8 digits at an offset in the second half of the signal. There
-- the pattern is 0 before digit i and 1 from it to the end, so each phase is a
-- suffix sum. Working on the reversed tail turns it into a running sum.
tailPhase :: [Int] -> [Int]
tailPhase = go 0
  where
    go !_ [] = []
    go !acc (x : rest) = let s = (acc + x) `mod` 10 in s : go s rest

-- | Applies a phase 100 times, forcing each result so no thunks pile up.
hundred :: ([Int] -> [Int]) -> [Int] -> [Int]
hundred f xs0 = List.foldl' (\xs _ -> force (f xs)) xs0 [1 .. 100 :: Int]
  where
    force ys = List.foldl' (flip seq) () ys `seq` ys

main :: IO ()
main = do
  [path] <- getArgs
  signal <- map digitToInt . filter isDigit <$> readFile path
  putStrLn (map intToDigit (take 8 (hundred phase signal)))
  let offset = List.foldl' (\a d -> 10 * a + d) 0 (take 7 signal)
      full = 10000 * length signal
  -- The trick only works when the offset is in the second half, which holds
  -- for real inputs but not for the puzzle's part 1 examples.
  if 2 * offset >= full && offset + 8 <= full
    then do
      let rest = take (full - offset) (drop (offset `mod` length signal) (cycle signal))
      putStrLn (map intToDigit (take 8 (reverse (hundred tailPhase (reverse rest)))))
    else pure ()

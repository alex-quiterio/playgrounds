-- Day 19: Tractor Beam
import Intcode
import System.Environment (getArgs)

-- | Is (x, y) inside the beam? The drone program handles one point per run.
pulled :: [Int] -> Int -> Int -> Bool
pulled program x y = run [x, y] (boot program) == [1]

-- | Walks down the beam's left edge. A 100x100 square whose bottom-left
-- corner is (x, y) fits when its top-right corner (x + 99, y - 99) is in the
-- beam too. Near the emitter some rows are empty, so a row whose edge is not
-- found within a few steps of the last one is skipped.
square :: [Int] -> Int
square program = go 0 100
  where
    -- The edge only moves right, by a little each row; the first row is
    -- searched in full since the beam may start far from x = 0.
    go x y = case [x' | x' <- [x .. if x == 0 then 2 * y else x + 10], pulled program x' y] of
      [] -> go x (y + 1)
      left : _
        | pulled program (left + 99) (y - 99) -> left * 10000 + (y - 99)
        | otherwise -> go left (y + 1)

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (length [() | x <- [0 .. 49], y <- [0 .. 49], pulled program x y])
  print (square program)

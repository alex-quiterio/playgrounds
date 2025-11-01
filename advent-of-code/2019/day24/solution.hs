-- Day 24: Planet of Discord
import Data.Bits (popCount, testBit, (.|.), shiftL)
import qualified Data.IntMap.Strict as IntMap
import qualified Data.Set as Set
import System.Environment (getArgs)

-- | A 5x5 layout as 25 bits: tile r * 5 + c is bit r * 5 + c. That is also
-- the biodiversity rating, which counts tile i as 2 ^ i.
type Layout = Int

-- | The rule: a bug survives with exactly one neighbour; an empty tile gets
-- a bug with one or two.
alive :: Bool -> Int -> Bool
alive bug n = n == 1 || (not bug && n == 2)

-- | Neighbours on a flat grid.
flatNeighbours :: Int -> [Int]
flatNeighbours i =
  [ r' * 5 + c'
    | (dr, dc) <- [(-1, 0), (1, 0), (0, -1), (0, 1)],
      let (r', c') = (r + dr, c + dc),
      r' >= 0, r' < 5, c' >= 0, c' < 5
  ]
  where
    (r, c) = i `divMod` 5

stepFlat :: Layout -> Layout
stepFlat g = foldl (.|.) 0 [1 `shiftL` i | i <- [0 .. 24], alive (testBit g i) (count i)]
  where
    count i = length (filter (testBit g) (flatNeighbours i))

-- | Part 1: the first layout that appears twice.
firstRepeat :: Layout -> Layout
firstRepeat = go Set.empty
  where
    go seen g
      | Set.member g seen = g
      | otherwise = go (Set.insert g seen) (stepFlat g)

-- | Neighbours in the recursive grid, as (level offset, tile). Level - 1 is the
-- grid around this one and level + 1 the grid inside the middle tile (12).
-- Stepping off the edge lands on the outer tile next to the middle; stepping
-- onto the middle reaches the whole facing edge of the inner grid.
recursiveNeighbours :: Int -> [(Int, Int)]
recursiveNeighbours i = concatMap toward [(-1, 0), (1, 0), (0, -1), (0, 1)]
  where
    (r, c) = i `divMod` 5
    toward (dr, dc)
      | r' < 0 || r' > 4 || c' < 0 || c' > 4 = [(-1, (2 + dr) * 5 + 2 + dc)]
      | (r', c') == (2, 2) = [(1, tile) | tile <- [0 .. 24], facing dr dc tile]
      | otherwise = [(0, r' * 5 + c')]
      where
        (r', c') = (r + dr, c + dc)
    -- Moving down into the middle meets the inner grid's top row, and so on.
    facing dr dc tile = case (dr, dc) of
      (1, _) -> tile < 5
      (-1, _) -> tile >= 20
      (_, 1) -> tile `mod` 5 == 0
      _ -> tile `mod` 5 == 4

stepRecursive :: IntMap.IntMap Layout -> IntMap.IntMap Layout
stepRecursive levels = IntMap.filter (/= 0) (IntMap.fromList [(l, next l) | l <- [low - 1 .. high + 1]])
  where
    low = maybe 0 fst (IntMap.lookupMin levels)
    high = maybe 0 fst (IntMap.lookupMax levels)
    layout l = IntMap.findWithDefault 0 l levels
    bug l i = testBit (layout l) i
    next l = foldl (.|.) 0 [1 `shiftL` i | i <- [0 .. 24], i /= 12, alive (bug l i) (count l i)]
    count l i = length [() | (dl, j) <- recursiveNeighbours i, bug (l + dl) j]

parse :: String -> Layout
parse s = foldl (.|.) 0 [1 `shiftL` i | (i, ch) <- zip [0 ..] (concat (lines s)), ch == '#']

main :: IO ()
main = do
  [path] <- getArgs
  start <- parse <$> readFile path
  print (firstRepeat start)
  -- Part 2: bugs across all levels after 200 minutes. (The puzzle's example
  -- only gives 10 minutes, so it is checked for part 1 alone.)
  let after = iterate stepRecursive (IntMap.singleton 0 start) !! 200
  print (sum (map popCount (IntMap.elems after)))

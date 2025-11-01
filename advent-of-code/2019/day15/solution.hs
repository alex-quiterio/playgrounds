-- Day 15: Oxygen System
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Intcode
import System.Environment (getArgs)

type Point = (Int, Int)

-- | Commands 1-4 are north, south, west, east.
moves :: [(Int, Point)]
moves = [(1, (0, -1)), (2, (0, 1)), (3, (-1, 0)), (4, (1, 0))]

-- | Sends one movement command; the droid answers 0 (wall), 1 (moved) or 2
-- (moved, and found the oxygen system).
try :: Machine -> Int -> (Int, Machine)
try m command = case step m of
  Input feed -> case step (feed command) of
    Output status m' -> (status, m')
    _ -> error "the droid did not answer"
  _ -> error "the droid is not listening"

-- | Explores the whole area breadth first. Machines are plain values, so each
-- frontier cell keeps its own droid standing there. Returns the open cells
-- and where the oxygen system is.
explore :: [Int] -> (Set.Set Point, Point)
explore program = go [((0, 0), boot program)] (Map.singleton (0, 0) 1)
  where
    go [] seen = (Map.keysSet (Map.filter (/= 0) seen), head' [p | (p, 2) <- Map.toList seen])
    go frontier seen = go next seen'
      where
        (next, seen') = foldl visit ([], seen) frontier
        visit (acc, s) ((x, y), m) = foldl (probe (x, y) m) (acc, s) moves
        probe (x, y) m (acc, s) (command, (dx, dy))
          | Map.member p s = (acc, s)
          | otherwise =
              let (status, m') = try m command
               in (if status == 0 then acc else (p, m') : acc, Map.insert p status s)
          where
            p = (x + dx, y + dy)
    head' (p : _) = p
    head' [] = error "no oxygen system found"

-- | Distance from `start` to every open cell reachable from it.
distances :: Set.Set Point -> Point -> Map.Map Point Int
distances open start = go [start] (Map.singleton start 0)
  where
    go [] dist = dist
    go (p@(x, y) : queue) dist =
      let d = dist Map.! p
          new = [q | (_, (dx, dy)) <- moves, let q = (x + dx, y + dy), Set.member q open, not (Map.member q dist)]
       in go (queue ++ new) (foldr (\q -> Map.insert q (d + 1)) dist new)

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  let (open, oxygen) = explore program
  print (distances open (0, 0) Map.! oxygen)
  -- Part 2: oxygen spreads one cell a minute, so the answer is the farthest cell.
  print (maximum (Map.elems (distances open oxygen)))

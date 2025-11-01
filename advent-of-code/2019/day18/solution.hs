-- Day 18: Many-Worlds Interpretation
import Data.Bits (bit, (.&.), (.|.))
import Data.Char (isLower, isUpper, ord)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import System.Environment (getArgs)

type Point = (Int, Int)

type Grid = Map.Map Point Char

-- | A key as a bit: a = 1, b = 2, c = 4, ...
keyBit :: Char -> Int
keyBit c = bit (ord c - ord 'a')

-- | Breadth first from one point: every key reachable from it, with the
-- distance and the doors (as key bits) standing in the way.
reach :: Grid -> Point -> [(Char, Int, Int)]
reach grid start = go [(start, 0, 0)] (Set.singleton start) []
  where
    go [] _ found = found
    go ((p@(x, y), d, doors) : queue) seen found = go (queue ++ next) seen' found'
      where
        c = Map.findWithDefault '#' p grid
        found' = if isLower c && p /= start then (c, d, doors) : found else found
        doors' = if isUpper c then doors .|. keyBit (toEnum (ord c + 32)) else doors
        steps = [q | q <- [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)], Map.findWithDefault '#' q grid /= '#', not (Set.member q seen)]
        next = [(q, d + 1, doors') | q <- steps]
        seen' = foldr Set.insert seen steps

-- | The fewest steps for the robots (one per '@') to collect every key.
-- Nodes are named by a character: robots '0' to '3' where they start, keys
-- 'a' to 'z'. A state is the node each robot stands on plus the keys held,
-- searched with Dijkstra using a Set as the priority queue.
collect :: Grid -> Int
collect grid = dijkstra (Set.singleton (0, robots, 0)) Set.empty
  where
    robots = take (length [() | '@' <- Map.elems grid]) "0123"
    places = Map.fromList (zip robots [p | (p, '@') <- Map.toList grid] ++ [(c, p) | (p, c) <- Map.toList grid, isLower c])
    edges = Map.map (reach grid) places
    allKeys = foldr (.|.) 0 [keyBit k | k <- Map.keys places, isLower k]
    dijkstra queue done = case Set.minView queue of
      Nothing -> error "the keys cannot all be collected"
      Just ((d, at, held), rest)
        | held == allKeys -> d
        | Set.member (at, held) done -> dijkstra rest done
        | otherwise -> dijkstra (foldr Set.insert rest moves) (Set.insert (at, held) done)
        where
          moves =
            [ (d + dist, take i at ++ [k] ++ drop (i + 1) at, held .|. keyBit k)
            | (i, here) <- zip [0 ..] at,
              (k, dist, doors) <- Map.findWithDefault [] here edges,
              held .&. keyBit k == 0,
              doors .&. held == doors
            ]

-- | Part 2: the 3x3 square around a lone robot becomes walls, with a robot in
-- each corner. Only possible when that square is open floor.
split :: Grid -> Maybe Grid
split grid = case [p | (p, '@') <- Map.toList grid] of
  [(x, y)]
    | all (\p -> Map.lookup p grid `elem` [Just '.', Just '@']) square ->
        Just (Map.union (Map.fromList (zip square "@#@###@#@")) grid)
    where
      square = [(x + dx, y + dy) | dy <- [-1, 0, 1], dx <- [-1, 0, 1]]
  _ -> Nothing

main :: IO ()
main = do
  [path] <- getArgs
  grid <- Map.fromList . concat . zipWith (\y row -> [((x, y), c) | (x, c) <- zip [0 ..] row]) [0 ..] . lines <$> readFile path
  -- Part 1 solves the map as given; a map that already has four robots (like
  -- the puzzle's part 2 examples) is solved the same way.
  print (collect grid)
  mapM_ (print . collect) (split grid)

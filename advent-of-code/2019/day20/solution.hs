-- Day 20: Donut Maze
import Data.Char (isUpper)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import System.Environment (getArgs)

type Point = (Int, Int)

-- | A portal tile: the open tile next to a two-letter label.
data Portal = Portal {label :: String, at :: Point, outer :: Bool}
  deriving (Eq, Ord, Show)

portals :: [String] -> [Portal]
portals rows =
  [ Portal name (x, y) (x == 2 || y == 2 || x == width - 3 || y == height - 3)
  | (y, row) <- zip [0 ..] rows,
    (x, '.') <- zip [0 ..] row,
    (dx, dy) <- [(1, 0), (-1, 0), (0, 1), (0, -1)],
    let a = cell (x + dx, y + dy)
        b = cell (x + 2 * dx, y + 2 * dy),
    isUpper a && isUpper b,
    -- The label reads left to right or top to bottom.
    let name = if dx + dy > 0 then [a, b] else [b, a]
  ]
  where
    grid = Map.fromList [((x, y), c) | (y, row) <- zip [0 ..] rows, (x, c) <- zip [0 ..] row]
    cell p = Map.findWithDefault ' ' p grid
    width = maximum (map length rows)
    height = length rows

-- | Walking distances between portal tiles that see each other without warping.
walks :: [String] -> [Portal] -> Map.Map Portal [(Portal, Int)]
walks rows ps = Map.fromList [(p, bfs p) | p <- ps]
  where
    open = Set.fromList [(x, y) | (y, row) <- zip [0 ..] rows, (x, '.') <- zip [0 ..] row]
    byPoint = Map.fromList [(at p, p) | p <- ps]
    bfs p = go [(at p, 0)] (Set.singleton (at p)) []
      where
        go [] _ found = found
        go (((x, y), d) : queue) seen found = go (queue ++ [(q, d + 1) | q <- next]) (foldr Set.insert seen next) found'
          where
            found' = case Map.lookup (x, y) byPoint of
              Just q | q /= p -> (q, d) : found
              _ -> found
            next = [q | q <- [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)], Set.member q open, not (Set.member q seen)]

-- | Shortest path from AA to ZZ. Stepping through a portal costs 1. In the
-- recursive maze an inner portal goes one level down and an outer one up;
-- outer portals are walls on level 0, and ZZ only counts on level 0. Levels
-- deeper than the number of portals cannot help, which bounds the search
-- when there is no way out.
solve :: Bool -> [Portal] -> Map.Map Portal [(Portal, Int)] -> Maybe Int
solve recursive ps graph = dijkstra (Set.fromList [(0, start, 0 :: Int) | start <- named "AA"]) Set.empty
  where
    named n = [p | p <- ps, label p == n]
    partner p = [q | q <- named (label p), q /= p]
    deepest = length ps
    dijkstra queue done = case Set.minView queue of
      Nothing -> Nothing
      Just ((d, p, level), rest)
        | label p == "ZZ" && level == 0 -> Just d
        | Set.member (p, level) done -> dijkstra rest done
        | otherwise -> dijkstra (foldr Set.insert rest (walk ++ warp)) (Set.insert (p, level) done)
        where
          walk = [(d + w, q, level) | (q, w) <- Map.findWithDefault [] p graph]
          level' = if not recursive then 0 else if outer p then level - 1 else level + 1
          warp = [(d + 1, q, level') | level' >= 0, level' <= deepest, q <- partner p]

main :: IO ()
main = do
  [path] <- getArgs
  rows <- lines <$> readFile path
  let ps = portals rows
      graph = walks rows ps
  mapM_ print (solve False ps graph)
  -- Prints nothing when the recursive maze has no way out (like the puzzle's
  -- second example).
  mapM_ print (solve True ps graph)

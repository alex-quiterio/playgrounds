-- Day 17: Set and Forget
import Data.Char (chr, ord)
import Data.List (intercalate, isPrefixOf)
import qualified Data.Map.Strict as Map
import Data.Maybe (listToMaybe)
import Intcode
import System.Environment (getArgs)

type Point = (Int, Int)

-- | A movement: turn left or right, then go forward n squares.
type Move = (Char, Int)

-- | The camera image, by position.
image :: [Int] -> Map.Map Point Char
image program =
  Map.fromList [((x, y), c) | (y, row) <- zip [0 ..] (lines (map chr (run [] (boot program)))), (x, c) <- zip [0 ..] row]

scaffold :: Map.Map Point Char -> Point -> Bool
scaffold grid p = Map.findWithDefault '.' p grid `elem` "#^v<>"

-- | Intersections are scaffold squares with scaffold on all four sides.
alignment :: Map.Map Point Char -> Int
alignment grid =
  sum [x * y | ((x, y), c) <- Map.toList grid, c == '#', all (scaffold grid) [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]]

-- | The whole path, walking straight as far as possible before each turn.
-- y grows downwards, so turning left maps (dx, dy) to (dy, -dx).
path :: Map.Map Point Char -> [Move]
path grid = go start (facing robot)
  where
    (start, robot) = case [(p, c) | (p, c) <- Map.toList grid, c `elem` "^v<>"] of
      found : _ -> found
      [] -> error "no robot on the camera"
    facing c = case c of
      '^' -> (0, -1)
      'v' -> (0, 1)
      '<' -> (-1, 0)
      _ -> (1, 0)
    ahead (x, y) (dx, dy) = (x + dx, y + dy)
    go pos (dx, dy) = case [(t, d) | (t, d) <- [('L', (dy, -dx)), ('R', (-dy, dx))], scaffold grid (ahead pos d)] of
      (turn, dir) : _ ->
        let n = length (takeWhile (scaffold grid) (drop 1 (iterate (`ahead` dir) pos)))
            end = iterate (`ahead` dir) pos !! n
         in (turn, n) : go end dir
      [] -> []

render :: [Move] -> String
render moves = intercalate "," [[turn] ++ "," ++ show n | (turn, n) <- moves]

-- | Splits the path into at most three routines of at most 20 characters,
-- and a main routine of at most 10 calls. Each step either reuses a routine
-- that matches what comes next, or, while fewer than three exist, starts a new
-- one from some prefix of what is left.
compress :: [Move] -> Maybe ([Int], [[Move]])
compress = go [] []
  where
    go calls routines [] = Just (reverse calls, routines)
    go calls routines rest
      | length calls >= 10 = Nothing
      | otherwise =
          listToMaybe
            [ found
            | (i, routine, routines') <- candidates,
              routine `isPrefixOf` rest,
              Just found <- [go (i : calls) routines' (drop (length routine) rest)]
            ]
      where
        reuse = [(i, routine, routines) | (i, routine) <- zip [0 ..] routines]
        fresh =
          [ (length routines, routine, routines ++ [routine])
          | length routines < 3,
            k <- [1 .. length rest],
            let routine = take k rest,
            length (render routine) <= 20
          ]
        candidates = reuse ++ fresh

-- | Wakes the robot (address 0 set to 2), sends it the routines and returns
-- the dust it reports, its last output.
collect :: [Int] -> [Move] -> Int
collect program moves = case compress moves of
  Nothing -> error "the path does not fit in three routines"
  Just (calls, routines) ->
    let mainRoutine = intercalate "," [[['A', 'B', 'C'] !! i] | i <- calls]
        padded = take 3 (routines ++ repeat [])
        script = unlines (mainRoutine : map render padded ++ ["n"])
     in last (run (map ord script) (poke 0 2 (boot program)))

main :: IO ()
main = do
  [path'] <- getArgs
  program <- parse <$> readFile path'
  let grid = image program
  print (alignment grid)
  print (collect program (path grid))

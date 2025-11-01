-- Day 11: Space Police
import qualified Data.Map.Strict as Map
import Intcode
import System.Environment (getArgs)

type Point = (Int, Int)

-- | Runs the painting robot on a hull whose start panel has the given colour
-- (0 black, 1 white). Returns every panel it painted and its final colour.
paint :: [Int] -> Int -> Map.Map Point Int
paint program start = go (boot program) (0, 0) (0, -1) (Map.singleton (0, 0) start)
  where
    go m pos dir hull = case step m of
      Halted _ -> hull
      Output _ _ -> error "the robot spoke before it looked"
      Input feed -> case step (feed (Map.findWithDefault 0 pos hull)) of
        Output colour m' -> case step m' of
          Output turn m'' ->
            let dir' = rotate turn dir
                hull' = Map.insert pos colour hull
             in go m'' (move pos dir') dir' hull'
          _ -> error "expected a turn"
        _ -> error "expected a colour"
    -- y grows downwards: turning left (0) maps (dx, dy) to (dy, -dx).
    rotate 0 (dx, dy) = (dy, -dx)
    rotate _ (dx, dy) = (-dy, dx)
    move (x, y) (dx, dy) = (x + dx, y + dy)

-- | The letters the robot paints: 4 columns wide, 6 rows tall, 5 columns apart.
font :: [(String, Char)]
font =
  [ (".##.#..##..######..##..#", 'A'), ("###.#..####.#..##..####.", 'B'), (".##.#..##...#...#..#.##.", 'C'),
    ("#####...###.#...#...####", 'E'), ("#####...###.#...#...#...", 'F'), (".##.#..##...#.###..#.###", 'G'),
    ("#..##..######..##..##..#", 'H'), (".###..#...#...#...#..###", 'I'), ("..##...#...#...##..#.##.", 'J'),
    ("#..##.#.##..#.#.#.#.#..#", 'K'), ("#...#...#...#...#...####", 'L'), (".##.#..##..##..##..#.##.", 'O'),
    ("###.#..##..####.#...#...", 'P'), ("###.#..##..####.#.#.#..#", 'R'), (".####...#....##....####.", 'S'),
    ("#..##..##..##..##..#.##.", 'U'), ("#...#....#.#..#...#...#.", 'Y'), ("####...#..#..#..#...####", 'Z')
  ]

-- | Reads the painted letters. The robot paints them starting one panel to
-- the right of where it starts.
readLetters :: Map.Map Point Int -> String
readLetters hull = [maybe '?' id (lookup (glyph x0) font) | x0 <- [1, 6 .. right]]
  where
    right = maximum [x | ((x, _), 1) <- Map.toList hull]
    glyph x0 = [if Map.lookup (x, y) hull == Just 1 then '#' else '.' | y <- [0 .. 5], x <- [x0 .. x0 + 3]]

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (Map.size (paint program 0))
  putStrLn (readLetters (paint program 1))

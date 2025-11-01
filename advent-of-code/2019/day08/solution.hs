-- Day 8: Space Image Format
import Data.Char (isDigit)
import Data.List (minimumBy, transpose)
import Data.Ord (comparing)
import System.Environment (getArgs)

-- | The image is always 25 pixels wide and 6 tall.
width, height :: Int
width = 25
height = 6

chunks :: Int -> [a] -> [[a]]
chunks _ [] = []
chunks n xs = take n xs : chunks n (drop n xs)

count :: Char -> String -> Int
count c = length . filter (== c)

-- | The letters the message is drawn in: 4 pixels wide, 6 tall, read row by
-- row, with one blank column between letters.
font :: [(String, Char)]
font =
  [ (".##.#..##..######..##..#", 'A'), ("###.#..####.#..##..####.", 'B'), (".##.#..##...#...#..#.##.", 'C')
  , ("#####...###.#...#...####", 'E'), ("#####...###.#...#...#...", 'F'), (".##.#..##...#.###..#.###", 'G')
  , ("#..##..######..##..##..#", 'H'), (".###..#...#...#...#..###", 'I'), ("..##...#...#...##..#.##.", 'J')
  , ("#..##.#.##..#.#.#.#.#..#", 'K'), ("#...#...#...#...#...####", 'L'), (".##.#..##..##..##..#.##.", 'O')
  , ("###.#..##..####.#...#...", 'P'), ("###.#..##..####.#.#.#..#", 'R'), (".####...#....##....####.", 'S')
  , ("#..##..##..##..##..#.##.", 'U'), ("#...#....#.#..#...#...#.", 'Y'), ("####...#..#..#..#...####", 'Z')
  ]

-- | Reads the letters off the rendered rows ('#' lit, '.' dark).
readCode :: [String] -> String
readCode rows =
  [ maybe '?' id (lookup (concatMap (take 4 . drop x) rows) font)
  | x <- [0, 5 .. width - 1]
  ]

main :: IO ()
main = do
  [path] <- getArgs
  pixels <- filter isDigit <$> readFile path
  let layers = chunks (width * height) pixels
      fewestZeros = minimumBy (comparing (count '0')) layers
  print (count '1' fewestZeros * count '2' fewestZeros)
  -- Part 2: each pixel shows its first non-transparent (not 2) layer.
  let visible = map (\ps -> case filter (/= '2') ps of (p : _) -> p; [] -> '0') (transpose layers)
      rows = chunks width [if p == '1' then '#' else '.' | p <- visible]
  putStrLn (readCode rows)

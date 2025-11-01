-- Day 2: 1202 Program Alarm
import Intcode
import System.Environment (getArgs)

-- | The value left at address 0 after running with this noun and verb.
output :: [Int] -> Int -> Int -> Int
output program noun verb = finalZero (boot program `with` [(1, noun), (2, verb)])
  where
    with = foldl (\m (a, v) -> poke a v m)
    finalZero m = case step m of
      Halted done -> peek 0 done
      _ -> error "this program neither reads nor writes"

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  if length program <= 12
    then print (output program (program !! 1) (program !! 2)) -- the example is too short to patch
    else do
      print (output program 12 2)
      let answers = [100 * noun + verb | noun <- [0 .. 99], verb <- [0 .. 99], output program noun verb == 19690720]
      mapM_ print (take 1 answers)

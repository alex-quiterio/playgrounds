-- Day 13: Care Package
import Intcode
import System.Environment (getArgs)

-- | Outputs come in threes: x, y, tile id.
triples :: [Int] -> [(Int, Int, Int)]
triples (x : y : t : rest) = (x, y, t) : triples rest
triples _ = []

-- | Plays with free coins (address 0 set to 2), always moving the paddle
-- towards the ball, and returns the score once the last block breaks.
play :: [Int] -> Int
play program = go (poke 0 2 (boot program)) [] 0 0 0
  where
    -- `pending` collects the current x, y, tile triple as it is output.
    go m pending ball paddle score = case step m of
      Halted _ -> score
      Input feed -> go (feed (signum (ball - paddle))) pending ball paddle score
      Output v m' -> case pending ++ [v] of
        [-1, 0, s] -> go m' [] ball paddle s
        [x, _, 4] -> go m' [] x paddle score
        [x, _, 3] -> go m' [] ball x score
        [_, _, _] -> go m' [] ball paddle score
        partial -> go m' partial ball paddle score

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (length [() | (_, _, 2) <- triples (run [] (boot program))])
  print (play program)

-- Day 5: Sunny with a Chance of Asteroids
import Intcode
import System.Environment (getArgs)

-- | The diagnostic code: the last thing the program outputs for a system ID.
diagnose :: [Int] -> Int -> Int
diagnose program systemId = last (run [systemId] (boot program))

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  print (diagnose program 1) -- the air conditioner
  print (diagnose program 5) -- the thermal radiator controller

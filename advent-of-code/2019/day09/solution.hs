-- Day 9: Sensor Boost
import Data.List (intercalate)
import Intcode
import System.Environment (getArgs)

-- | Every output, comma-separated (the BOOST program outputs one value
-- when the computer works, or the opcodes that failed when it does not).
outputs :: [Int] -> Int -> String
outputs program input = intercalate "," (map show (run [input] (boot program)))

main :: IO ()
main = do
  [path] <- getArgs
  program <- parse <$> readFile path
  putStrLn (outputs program 1) -- test mode
  putStrLn (outputs program 2) -- sensor boost mode

module Main where
import System.Environment

main :: IO ()
main = do args <- getArgs
          name <- getLine
          putStrLn ( "Hello, " ++ name )


module Main where
import Control.Monad
import System.Environment
import Text.ParserCombinators.Parsec hiding (spaces)

main :: IO ()
main = do args <- getArgs
          putStrLn (readExpr (args !! 0))

symbol :: Parser Char
symbol = oneOf "!$%&|*+-/:<=?>@^_~#"

readExpr :: String -> String
readExpr input = case parse parseExpr "lisp" input of
  Left err -> "No match: " ++ show err
  Right val -> "Found value"

spaces :: Parser ()
spaces = skipMany1 space

data LispVal = Atom String
               | List [LispVal]
               | DottedList [LispVal] LispVal
               | Number Integer
               | String String
               | Bool Bool

-- http://codereview.stackexchange.com/questions/2406/parsing-strings-with-escaped-characters-using-parsec
parseEscapedChar :: Parser Char
parseEscapedChar = char '\\' >> choice (zipWith escapedChar codes replacements)
                   where escapedChar code replacement = char code >> return replacement
                         codes        = ['b',  'n',  'f',  'r',  't',  '\\', '\"', '/']
                         replacements = ['\b', '\n', '\f', '\r', '\t', '\\', '\"', '/']

parseString :: Parser LispVal
parseString = do char '"'
                 x <- many ( parseEscapedChar <|> noneOf "\"")
                 char '"'
                 return $ String x


parseAtom :: Parser LispVal
parseAtom = do first <- letter <|> symbol
               rest <- many (letter <|> digit <|> symbol)
               let atom = first : rest
               return $ case atom of
                          "#t" -> Bool True
                          "#f" -> Bool False
                          otherwise -> Atom atom

parseNumber :: Parser LispVal
-- parseNumber = liftM (Number . read) $ many1 digit
-- http://stackoverflow.com/questions/5320528/monadic-type-confusion
parseNumber = many1 digit >>= (return . Number . read)

parseExpr :: Parser LispVal
parseExpr = parseAtom
        <|> parseString
        <|> parseNumber
                     


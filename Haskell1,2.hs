import System.IO

splitList :: [Int] -> ([Int], [Int])
splitList xs = ([x | x <- xs, even x], [x | x <- xs, odd x])

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") s

main :: IO ()
main = do
    hSetEncoding stdout utf8
    putStrLn "Введи числа через пробіл:"
    line <- getLine
    case isValidInput line of
        False -> putStrLn "Помилка! Можна вводити тільки числа!"
        True -> do
            let xs = map read (words line) :: [Int]
            let (evens, odds) = splitList xs
            putStrLn "Парні числа:"
            print evens
            putStrLn "Непарні числа:"
            print odds
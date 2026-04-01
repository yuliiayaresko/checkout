import System.IO

countItem :: Int -> [Int] -> Int
countItem x xs = length [y | y <- xs, y == x]

keepEvenCount :: [Int] -> [Int]
keepEvenCount xs = [x | x <- xs, even (countItem x xs)]

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
            putStrLn "Результат:"
            print (keepEvenCount xs)



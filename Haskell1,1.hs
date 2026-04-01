-- Яресько Юлія варіант 17
import System.IO

removeMatching :: [Int] -> [Int]
removeMatching xs = [x | (i, x) <- zip [0..] xs, x /= i]

isValidInput :: String -> Bool
isValidInput s = all (\c -> c == ' ' || c == '-' || c `elem` "0123456789") s

main :: IO ()
main = do
    hSetEncoding stdout utf8
    putStrLn "Введи цілі числа через пробіл:"
    line <- getLine
    case isValidInput line of
        False -> putStrLn "Помилка! Можна вводити тільки цілі числа!"
        True -> do
            let xs = map read (words line) :: [Int]
            putStrLn "Результат:"
            print (removeMatching xs)
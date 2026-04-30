import Data.List (nub, isPrefixOf)
import Data.Char (isUpper)

-- Правило: (нетермінал, права частина як список символів)
type Rule = (String, [String])

-- Пряма ліворекурсивність: A -> A...
isDirectLeftRecursive :: String -> [Rule] -> Bool
isDirectLeftRecursive nt rules =
    any (\(lhs, rhs) -> lhs == nt && not (null rhs) && head rhs == nt) rules

-- Непряма: шукаємо чи можна A =>* A...
-- Для кожного нетермінала збираємо множину тих, з яких він може починатись
reachableFirst :: [Rule] -> String -> [String]
reachableFirst rules nt = go [nt] []
  where
    go [] visited = visited
    go (x:queue) visited
        | x `elem` visited = go queue visited
        | otherwise =
            let firstSymbols = [ head rhs
                                | (lhs, rhs) <- rules
                                , lhs == x
                                , not (null rhs)
                                , isNonTerminal (head rhs) ]
                newQueue = queue ++ filter (`notElem` (x:visited)) firstSymbols
            in go newQueue (visited ++ [x])

isNonTerminal :: String -> Bool
isNonTerminal (c:_) = isUpper c
isNonTerminal _     = False

-- Нетермінал є ліворекурсивним якщо він досяжний сам з себе
isLeftRecursive :: [Rule] -> String -> Bool
isLeftRecursive rules nt =
    let reachable = reachableFirst rules nt
    in nt `elem` tail reachable || isDirectLeftRecursive nt rules

-- Зчитування правил
-- Формат вводу: A -> B C | D
readGrammar :: IO [Rule]
readGrammar = do
    putStrLn "Enter grammar rules (format: A -> B C | D E)"
    putStrLn "Type 'done' to finish"
    go []
  where
    go acc = do
        putStr "> "
        line <- getLine
        if line == "done"
            then return acc
            else case break (== "->") (words line) of
                ([lhs], _ : rest) ->
                    let alts = splitOn "|" rest
                        rules = map (\alt -> (lhs, alt)) alts
                    in go (acc ++ rules)
                _ -> do
                    putStrLn "Invalid format, try again (A -> B C | D)"
                    go acc

-- Розбити список по роздільнику
splitOn :: Eq a => a -> [a] -> [[a]]
splitOn _ [] = [[]]
splitOn sep (x:xs)
    | x == sep  = [] : splitOn sep xs
    | otherwise = let (cur:rest) = splitOn sep xs
                  in (x:cur) : rest

main :: IO ()
main = do
    rules <- readGrammar
    let nonTerminals = nub [lhs | (lhs, _) <- rules]
    putStrLn "\n=== Left-Recursive Non-Terminals ==="
    let leftRec = filter (isLeftRecursive rules) nonTerminals
    if null leftRec
        then putStrLn "No left-recursive non-terminals found."
        else mapM_ (\nt -> putStrLn $ nt ++ " is left-recursive") leftRec
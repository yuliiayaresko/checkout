import Data.List (nub, sort, intercalate)



type State  = String
type Symbol = Char

-- Перехід з множини станів по символу
move :: [(State, Symbol, [State])] -> [State] -> Symbol -> [State]
move delta states sym =
    nub $ concatMap (\s -> [ns | (st, c, nexts) <- delta, st == s, c == sym, ns <- nexts]) states

-- Чи є множина станів фінальною
isFinal :: [State] -> [State] -> Bool
isFinal finals states = any (`elem` finals) states

-- Назва стану ДКА з множини станів НКА
stateName :: [State] -> String
stateName []     = "DEAD"
stateName states = "{" ++ intercalate "," (sort states) ++ "}"

-- Алгоритм детермінізації (subset construction)
determinize :: [State] -> [(State, Symbol, [State])] -> [Symbol] -> [State] -> IO ()
determinize start delta alphabet finals = go [[start]] [] []
  where
    go [] _ table = printTable table finals alphabet
    go (cur:queue) visited table
        | stateName cur `elem` visited = go queue visited table
        | otherwise =
            let visited'  = stateName cur : visited
                nextSets  = map (move delta cur) alphabet
                newInQueue = filter (\s -> stateName s `notElem` visited') nextSets
                table'    = table ++ [(cur, zip alphabet nextSets)]
            in go (queue ++ newInQueue) visited' table'

-- Виведення таблиці
printTable :: [([State], [(Symbol, [State])])] -> [State] -> [Symbol] -> IO ()
printTable table finals alphabet = do
    putStrLn "\n=== DFA Transition Table ==="
    putStr (pad 20 "State")
    mapM_ (\c -> putStr (pad 12 [c])) alphabet
    putStrLn ""
    putStrLn (replicate (20 + 12 * length alphabet) '-')
    mapM_ (\(states, row) -> do
        let mark = if isFinal finals states then "*" else " "
        putStr (pad 20 (mark ++ stateName states))
        mapM_ (\(_, nexts) -> putStr (pad 12 (stateName nexts))) row
        putStrLn "") table

pad :: Int -> String -> String
pad n s = take n (s ++ repeat ' ')

-- Зчитування
readList' :: String -> IO [String]
readList' prompt = do
    putStr prompt
    fmap words getLine

readAlphabet :: String -> IO [Char]
readAlphabet prompt = do
    putStr prompt
    fmap (map head . words) getLine

readTransitions :: IO [(State, Symbol, [State])]
readTransitions = do
    putStrLn "Enter transitions (format: state symbol next1 next2 ...)"
    putStrLn "Type 'done' to finish"
    go []
  where
    go acc = do
        putStr "> "
        line <- getLine
        if line == "done"
            then return acc
            else case words line of
                (s : sym : nexts) ->
                    go (acc ++ [(s, head sym, nexts)])
                _ -> do
                    putStrLn "Invalid format, try again (state symbol next1 next2 ...)"
                    go acc

main :: IO ()
main = do
    putStrLn "=== NFA to DFA (Subset Construction) ==="
    alphabet <- readAlphabet "Enter alphabet symbols (space-separated): "
    _states  <- readList' "Enter all states (space-separated): "
    [start]  <- readList' "Enter start state: "
    finals   <- readList' "Enter final states (space-separated): "
    delta    <- readTransitions
    determinize [start] delta alphabet finals
% Перевірка чи є символ нетерміналом (починається з великої літери)
is_nonterminal(X) :-
    atom(X),
    atom_chars(X, [C|_]),
    char_type(C, upper).

% Пряма ліворекурсивність: A -> A ...
direct_left_recursive(NT) :-
    rule(NT, [NT|_]).

% Непряма: A =>* A через перший символ правих частин
% Збираємо всі нетермінали, з яких NT може починатись
reachable_first(NT, Visited, Result) :-
    findall(First,
        (rule(NT, [First|_]), is_nonterminal(First), \+ member(First, Visited)),
        Firsts),
    foldl([F, Acc0, Acc1]>>(
        reachable_first(F, [NT|Visited], Sub),
        append(Acc0, [F|Sub], Acc1)
    ), Firsts, [], SubResult),
    append(Firsts, SubResult, All),
    sort(All, Result).

% Нетермінал є ліворекурсивним якщо він сам у своїх reachable або пряма рекурсія
is_left_recursive(NT) :-
    direct_left_recursive(NT), !.
is_left_recursive(NT) :-
    reachable_first(NT, [NT], Reachable),
    member(NT, Reachable).

% Зчитування граматики
% Формат: A -> B C | D E
read_grammar :-
    writeln('Enter grammar rules (format: A -> B C | D E)'),
    writeln('Type "done" to finish'),
    read_grammar_loop.

read_grammar_loop :-
    write('> '),
    read_line_to_string(user_input, Line),
    (Line = "done" ->
        true
    ;
        parse_rule(Line),
        read_grammar_loop
    ).

parse_rule(Line) :-
    atomic_list_concat(Parts, ' ', Line),
    Parts = [LHS, '->' | Rest],
    split_alternatives(Rest, Alts),
    maplist([Alt]>>(assertz(rule(LHS, Alt))), Alts).

% Розбити список по '|'
split_alternatives([], [[]]).
split_alternatives(['|'|Rest], [[]|Alts]) :-
    split_alternatives(Rest, Alts).
split_alternatives([X|Rest], [[X|Cur]|Alts]) :-
    X \= '|',
    split_alternatives(Rest, [Cur|Alts]).

main :-
    read_grammar,
    findall(NT, rule(NT, _), AllNTs),
    sort(AllNTs, NTs),
    writeln('\n=== Left-Recursive Non-Terminals ==='),
    findall(NT, (member(NT, NTs), is_left_recursive(NT)), LeftRec),
    (LeftRec = [] ->
        writeln('No left-recursive non-terminals found.')
    ;
        maplist([NT]>>(format('~w is left-recursive~n', [NT])), LeftRec)
    ),
    halt.

:- initialization(main, main).
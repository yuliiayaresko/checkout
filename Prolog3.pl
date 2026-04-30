% Перехід з множини станів по символу
move_set([], _, []).
move_set([S|Rest], Sym, Result) :-
    (trans(S, Sym, Next) -> true ; Next = []),
    move_set(Rest, Sym, RestResult),
    append(Next, RestResult, Combined),
    sort(Combined, Result).

% Чи є множина фінальною
is_final_set(States) :-
    final(F),
    member(F, States), !.

% Назва стану ДКА
state_name([], 'DEAD').
state_name(States, Name) :-
    States \= [],
    atomic_list_concat(States, ',', Inner),
    atom_concat('{', Inner, Tmp),
    atom_concat(Tmp, '}', Name).

% Алгоритм детермінізації
determinize :-
    start(S),
    alphabet(Alph),
    process([[S]], [], [], Alph, Table),
    print_table(Table, Alph).

process([], _, Table, _, Table).
process([Cur|Queue], Visited, TableAcc, Alph, FinalTable) :-
    state_name(Cur, Name),
    (member(Name, Visited) ->
        process(Queue, Visited, TableAcc, Alph, FinalTable)
    ;
        maplist(move_set(Cur), Alph, NextSets),
        NewVisited = [Name|Visited],
        append(Queue, NextSets, NewQueue),
        append(TableAcc, [(Cur, Alph, NextSets)], NewTableAcc),
        process(NewQueue, NewVisited, NewTableAcc, Alph, FinalTable)
    ).

print_table(Table, Alph) :-
    writeln('\n=== DFA Transition Table ==='),
    write('State               '),
    maplist([S]>>(format('~w         ', [S])), Alph), nl,
    writeln('------------------------------------------------'),
    maplist([Row]>>(print_row(Row)), Table).

print_row((States, Alph, NextSets)) :-
    state_name(States, Name),
    (is_final_set(States) -> Prefix = '* ' ; Prefix = '  '),
    format('~w~w', [Prefix, Name]),
    write('     '),
    maplist([Next]>>(state_name(Next, N), format('~w     ', [N])), NextSets),
    nl.

% Зчитування рядка як список атомів
read_atoms(Prompt, Atoms) :-
    write(Prompt),
    read_line_to_string(user_input, Line),
    atomic_list_concat(Atoms, ' ', Line).

% Зчитування переходів
read_transitions :-
    writeln('Enter transitions (format: state symbol next1 next2 ...)'),
    writeln('Type "done" to finish'),
    read_trans_loop.

read_trans_loop :-
    write('> '),
    read_line_to_string(user_input, Line),
    (Line = "done" ->
        true
    ;
        atomic_list_concat(Parts, ' ', Line),
        Parts = [S, SymAtom | Nexts],
        atom_chars(SymAtom, [Sym|_]),
        assertz(trans(S, Sym, Nexts)),
        read_trans_loop
    ).

main :-
    writeln('=== NFA to DFA (Subset Construction) ==='),
    read_atoms('Enter alphabet symbols (space-separated): ', Alph),
    assertz(alphabet(Alph)),
    read_atoms('Enter all states (space-separated): ', _States),
    read_atoms('Enter start state: ', [Start]),
    assertz(start(Start)),
    read_atoms('Enter final states (space-separated): ', Finals),
    maplist([F]>>(assertz(final(F))), Finals),
    read_transitions,
    determinize,
    halt.

:- initialization(main, main).
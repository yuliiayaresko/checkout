% Варіант 17.Вилучити елементи списку, значення яких збігається з номерами їх позицій у списку.



remove_matching([], _, []).

remove_matching([H|T], H, Result) :-
    NextIndex is H + 1,
    remove_matching(T, NextIndex, Result).

remove_matching([H|T], Index, [H|Result]) :-
    H \= Index,
    NextIndex is Index + 1,
    remove_matching(T, NextIndex, Result).

remove_pos_match(List, Result) :-
    remove_matching(List, 0, Result).

read_numbers(Numbers) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " ", " \t\r", Parts),
    exclude(=(""), Parts, NonEmpty),
    maplist(number_string, Numbers, NonEmpty).

main :-
    write('Enter numbers separated by spaces: '),
    read_numbers(Numbers),
    (   Numbers = []
    ->  write('Error: list is empty')
    ;   (   member(X, Numbers), X < 0
        ->  write('Error: negative numbers are not allowed')
        ;   remove_pos_match(Numbers, Result),
            write('Result: '),
            write(Result)
        )
    ),
    nl,
    halt.

main :-
    write('Error: invalid input, only numbers are allowed'),
    nl,
    halt.

:- initialization(main, main).
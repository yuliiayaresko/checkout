% Варіант 25.Залишити у списку елементи, що мають парну кількість входжень у список

count_occurrences(_, [], 0).

count_occurrences(X, [X|T], Count) :-
    count_occurrences(X, T, Rest),
    Count is Rest + 1.

count_occurrences(X, [H|T], Count) :-
    X \= H,
    count_occurrences(X, T, Count).

filter_even_occurrences([], _, []).

filter_even_occurrences([H|T], List, [H|Result]) :-
    count_occurrences(H, List, Count),
    Count mod 2 =:= 0,
    filter_even_occurrences(T, List, Result).

filter_even_occurrences([H|T], List, Result) :-
    count_occurrences(H, List, Count),
    Count mod 2 =\= 0,
    filter_even_occurrences(T, List, Result).

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
    ;   filter_even_occurrences(Numbers, Numbers, Result),
        write('Result: '),
        write(Result)
    ),
    nl,
    halt.

main :-
    write('Error: invalid input, only numbers are allowed'),
    nl,
    halt.

:- initialization(main, main).

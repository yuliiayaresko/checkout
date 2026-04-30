% Варіант 55.Розбити список на два списки з парними та непарними числами відповідно.

split_even_odd([], [], []).

split_even_odd([H|T], [H|Evens], Odds) :-
    0 is H mod 2,
    split_even_odd(T, Evens, Odds).

split_even_odd([H|T], Evens, [H|Odds]) :-
    1 is H mod 2,
    split_even_odd(T, Evens, Odds).

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
        ;   split_even_odd(Numbers, Evens, Odds),
            write('Even numbers: '),
            write(Evens),
            nl,
            write('Odd numbers: '),
            write(Odds)
        )
    ),
    nl,
    halt.

main :-
    write('Error: invalid input, only numbers are allowed'),
    nl,
    halt.

:- initialization(main, main).
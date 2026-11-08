% Specs for lists.pl. Run with: swipl -g run_tests -t halt prolog/oscars/tests/lists_test.pl

:- ensure_loaded(setup).

:- begin_tests(lists).

test(print_list) :-
    with_output_to(string(S), print_list([a, b])),
    S == "a\nb\n+".
test(print_list_of_empty_list) :-
    with_output_to(string(S), print_list([])),
    S == "+".
test(remove_first) :- remove_first([a, b, c], [b, c]).
test(remove_first_of_empty_list, [fail]) :- remove_first([], _).
test(remove_last) :- remove_last([a, b, c], [a, b]).
test(remove_last_of_one_element) :- remove_last([a], []).
test(remove_last_of_empty_list, [fail]) :- remove_last([], _).
test(remove_duplicates_keeps_the_last_occurrence) :- remove_duplicates([a, b, a, c, b], [a, c, b]).
test(remove_duplicates_of_empty_list) :- remove_duplicates([], []).
test(remove_duplicates_without_duplicates) :- remove_duplicates([a, b, c], [a, b, c]).

:- end_tests(lists).

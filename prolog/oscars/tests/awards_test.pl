% Specs for awards.pl. Run with: swipl -g run_tests -t halt prolog/oscars/tests/awards_test.pl

:- ensure_loaded(setup).

:- begin_tests(awards).

test(won_oscar, [nondet]) :- won_oscar(ana, realizador).
test(nominated_without_winning, [fail]) :- won_oscar(carla, actor).
test(count_oscars, [true(N == 2)]) :- count_oscars(ana, 1, N).
test(count_oscars_is_deterministic, [all(N == [2])]) :- count_oscars(ana, 1, N).
test(count_oscars_of_a_nominee_who_never_won, [true(N == 0)]) :- count_oscars(carla, 2, N).
test(filter_by_oscars, [nondet]) :- filter_by_oscars(2, 2, [bruno, duarte], [bruno]).
test(most_oscar_winners_keeps_the_best, [nondet]) :-
    most_oscar_winners(1, [ana, carla], 0, [], Best),
    Best == [ana].
test(more_than_n_oscars) :- prints(more_than_n_oscars(1, actor), ["bruno", "duarte"]).
test(more_than_n_oscars_at_the_limit) :- prints(more_than_n_oscars(2, actor), ["bruno"]).
test(most_oscars_as_director) :- prints(most_oscars(realizador), ["ana"]).
test(most_oscars_as_actor) :- prints(most_oscars(actor), ["bruno"]).
test(most_oscars_for_an_activity_nobody_won) :- prints(most_oscars(argumentista), []).

:- end_tests(awards).

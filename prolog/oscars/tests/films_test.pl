% Specs for films.pl. Run with: swipl -g run_tests -t halt prolog/oscars/tests/films_test.pl

:- ensure_loaded(setup).

:- begin_tests(films).

test(all_films_of_a_year) :- prints(all_films(1995), ["beta", "gama"]).
test(all_films_of_a_year_without_films) :- prints(all_films(1800), []).

test(director, [all(P == [ana, ana, carla])]) :- director(P).
test(all_directors) :- prints(all_directors, ["ana", "carla"]).

test(active_for_at_least_counts_both_ends, [nondet]) :- active_for_at_least(ana, 11).
test(active_for_at_least_too_long, [fail]) :- active_for_at_least(ana, 12).
test(more_than_n_years_counts_both_ends) :- prints(more_than_n_years(11), ["ana"]).
test(more_than_n_years) :- prints(more_than_n_years(6), ["ana", "bruno", "carla"]).
test(more_than_n_years_nobody) :- prints(more_than_n_years(12), []).

% carla took part in film 3 as director, and in film 4 as actor and as writer.
test(count_participations_counts_each_activity, [true(N == 3)]) :- count_participations(3, N).
test(count_participations_of_someone_in_no_film, [true(N == 0)]) :- count_participations(5, N).
test(count_films, [true(N == 2)]) :- count_films([1, 2], 0, N).
test(count_films_fails_on_an_unknown_film, [fail]) :- count_films([1, 99, 2], 0, _).
test(filter_by_films, [nondet]) :- filter_by_films([ana, eva, bruno], 2, [ana, bruno]).
test(more_than_n_films) :- prints(more_than_n_films(2), ["ana", "bruno", "carla"]).
test(more_than_n_films_at_the_limit) :- prints(more_than_n_films(3), ["ana", "carla"]).
test(most_films_with_a_tie) :-
    prints(most_films, Lines),
    msort(Lines, ["ana", "carla"]).

:- end_tests(films).

% Specs for social_network.pl.
% Run with: swipl -g run_tests -t halt prolog/oscars/tests/social_network_test.pl

:- ensure_loaded(setup).

:- begin_tests(social_network).

test(edge_for_the_same_film) :- edge(bruno, ana).
test(edge_is_symmetric) :- edge(ana, bruno).
test(no_edge_to_oneself, [fail]) :- edge(ana, ana).
test(isolated_person_has_no_edges, [fail]) :- edge(eva, _).
test(same_film) :- same_film(1, 2).
test(no_film_together, [fail]) :- same_film(2, 4).

test(in_some_path, [nondet]) :- in_some_path(c, [[a, b], [c, d]]).
test(in_no_path, [fail]) :- in_some_path(e, [[a, b], [c, d]]).
test(breadth_first_finds_the_shortest_path, [nondet]) :-
    breadth_first([[bruno]], duarte, Path),
    Path == [duarte, ana, bruno].

test(direct_link_has_no_one_between) :- prints(social_network(ana, bruno), []).
test(link_through_one_person) :- prints(social_network(bruno, duarte), ["ana"]).

:- end_tests(social_network).

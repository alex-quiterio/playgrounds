% Tests for oscars.pl. Run with: swipl -g run_tests -t halt tests/oscars_test.pl

:- use_module(library(plunit)).
:- initialization((
       prolog_load_context(directory, Dir),
       atom_concat(Dir, '/fixtures.pl', Fixtures),
       atom_concat(Dir, '/../oscars.pl', Oscars),
       consult(Fixtures),
       consult(Oscars)
   ), now).

%! prints(:Goal, -Lines) is det.
%  Runs Goal once and returns the lines it printed, without the closing "+".
prints(Goal, Lines) :-
    with_output_to(string(Out), once(Goal)),
    split_string(Out, "\n", "", Parts),
    exclude(==(""), Parts, NonEmpty),
    (   append(Lines0, ["+"], NonEmpty) -> Lines = Lines0 ; Lines = NonEmpty ).

:- begin_tests(lists).

test(remove_first) :- remove_first([a, b, c], [b, c]).
test(remove_first_of_empty_list, [fail]) :- remove_first([], _).
test(remove_last) :- remove_last([a, b, c], [a, b]).
test(remove_last_of_one_element) :- remove_last([a], []).
test(remove_last_of_empty_list, [fail]) :- remove_last([], _).
test(remove_duplicates_keeps_the_last_occurrence) :- remove_duplicates([a, b, a, c, b], [a, c, b]).
test(remove_duplicates_of_empty_list) :- remove_duplicates([], []).
test(print_list) :-
    with_output_to(string(S), print_list([a, b])),
    S == "a\nb\n+".

:- end_tests(lists).

:- begin_tests(basic_queries).

test(all_films_of_a_year) :- prints(all_films(1995), ["beta", "gama"]).
test(all_films_of_a_year_without_films) :- prints(all_films(1800), []).
test(all_directors) :- prints(all_directors, ["ana", "carla"]).
test(more_than_n_years_counts_both_ends) :- prints(more_than_n_years(11), ["ana"]).
test(more_than_n_years) :- prints(more_than_n_years(6), ["ana", "bruno", "carla"]).
test(more_than_n_years_nobody) :- prints(more_than_n_years(12), []).

:- end_tests(basic_queries).

:- begin_tests(medium_queries).

test(won_oscar, [nondet]) :- won_oscar(ana, realizador).
test(nominated_without_winning, [fail]) :- won_oscar(carla, actor).
test(count_oscars, [true(N == 2)]) :- count_oscars(ana, 1, N).
test(count_oscars_is_deterministic, [all(N == [2])]) :- count_oscars(ana, 1, N).
test(count_participations, [true(N == 3)]) :- count_participations(3, N).
test(more_than_n_oscars) :- prints(more_than_n_oscars(1, actor), ["bruno", "duarte"]).
test(more_than_n_oscars_at_the_limit) :- prints(more_than_n_oscars(2, actor), ["bruno"]).
test(most_oscars_as_director) :- prints(most_oscars(realizador), ["ana"]).
test(most_oscars_as_actor) :- prints(most_oscars(actor), ["bruno"]).
test(more_than_n_films) :- prints(more_than_n_films(2), ["ana", "bruno", "carla"]).
test(more_than_n_films_at_the_limit) :- prints(more_than_n_films(3), ["ana", "carla"]).
test(most_films_with_a_tie) :-
    prints(most_films, Lines),
    msort(Lines, ["ana", "carla"]).

:- end_tests(medium_queries).

:- begin_tests(social_network).

test(edge_for_the_same_film) :- edge(bruno, ana).
test(edge_is_symmetric) :- edge(ana, bruno).
test(no_edge_to_oneself, [fail]) :- edge(ana, ana).
test(isolated_person_has_no_edges, [fail]) :- edge(eva, _).
test(direct_link_has_no_one_between) :- prints(social_network(ana, bruno), []).
test(link_through_one_person) :- prints(social_network(bruno, duarte), ["ana"]).

:- end_tests(social_network).

:- begin_tests(questions).

% The questions are in Portuguese: the parser reads Portuguese.
test(who_won_the_most_oscars_as) :-
    prints(question('quem ganhou mais oscares como actor'), ["bruno"]).
test(list_the_directors) :-
    prints(question('liste os realizadores'), ["ana", "carla"]).
test(who_are_the_directors) :-
    prints(question('quem sao os realizadores'), ["ana", "carla"]).
test(films_of_a_year) :-
    prints(question('filmes de 1995'), ["beta", "gama"]).
test(which_are_the_films_of_a_year) :-
    prints(question('quais os filmes de 1990'), ["alfa"]).
test(unknown_sentence) :-
    prints(question('ola mundo'), ["frase desconhecida"]).

:- end_tests(questions).

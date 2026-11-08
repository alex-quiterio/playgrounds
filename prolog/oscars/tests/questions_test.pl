% Specs for questions.pl. Run with: swipl -g run_tests -t halt prolog/oscars/tests/questions_test.pl
% The questions are in Portuguese: the parser reads Portuguese.

:- ensure_loaded(setup).

:- begin_tests(questions).

test(initial_state) :- initial_state(0).
test(transition_reads_every_word, [nondet]) :-
    % 'filmes de' leads from state 0 through 13 to 14, which still needs a year.
    state(0, [filmes, S1]), state(S1, [de, S2]),
    S2 == 14.
test(transition_rejects_an_unknown_word, [fail]) :- transition(0, [ola], _).

test(who_won_the_most_oscars_as) :-
    prints(question('quem ganhou mais oscares como actor'), ["bruno"]).
test(list_the_directors) :-
    prints(question('liste os realizadores'), ["ana", "carla"]).
test(show_the_directors) :-
    prints(question('mostre os realizadores'), ["ana", "carla"]).
test(who_are_the_directors) :-
    prints(question('quem sao os realizadores'), ["ana", "carla"]).
test(films_of_a_year) :-
    prints(question('filmes de 1995'), ["beta", "gama"]).
test(which_are_the_films_of_a_year) :-
    prints(question('quais os filmes de 1990'), ["alfa"]).
test(list_all_the_films_of_a_year) :-
    prints(question('liste todos os filmes de 2000'), ["delta"]).
test(unknown_sentence) :-
    prints(question('ola mundo'), ["frase desconhecida"]).
test(question_cut_short_is_unknown) :-
    prints(question('filmes de'), ["frase desconhecida"]).

:- end_tests(questions).

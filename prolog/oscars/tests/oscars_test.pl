% Specs for oscars.pl, the file that loads the rest.
% Run with: swipl -g run_tests -t halt prolog/oscars/tests/oscars_test.pl

:- ensure_loaded(setup).

:- begin_tests(oscars).

% One predicate from each file it loads.
test(loads_every_part) :-
    forall(member(P, [ print_list/1           % lists.pl
                     , all_films/1            % films.pl
                     , most_oscars/1          % awards.pl
                     , social_network/2       % social_network.pl
                     , question/1             % questions.pl
                     ]),
           current_predicate(P)).

test(loading_it_again_changes_nothing) :-
    oscars_file(File),
    user:consult(File),
    prints(all_films(1995), ["beta", "gama"]).

:- end_tests(oscars).

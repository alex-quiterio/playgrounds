% Runs every spec file. Run with: swipl -g run_tests -t halt prolog/oscars/tests/all_tests.pl

:- ensure_loaded(oscars_test).
:- ensure_loaded(lists_test).
:- ensure_loaded(films_test).
:- ensure_loaded(awards_test).
:- ensure_loaded(social_network_test).
:- ensure_loaded(questions_test).

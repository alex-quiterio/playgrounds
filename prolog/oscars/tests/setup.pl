% Shared by every spec file: loads the example database and the program, and
% defines prints/2. Each *_test.pl runs on its own:
%   swipl -g run_tests -t halt prolog/oscars/tests/films_test.pl
% and all_tests.pl runs them all.

:- use_module(library(plunit)).
:- ensure_loaded(fixtures).
:- ensure_loaded('../oscars').

% The loader's absolute path, for specs that load it again.
:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../oscars.pl', File),
   assertz(oscars_file(File)).

%! prints(:Goal, -Lines) is det.
%  Runs Goal once and returns the lines it printed, without the closing "+".
prints(Goal, Lines) :-
    with_output_to(string(Out), once(Goal)),
    split_string(Out, "\n", "", Parts),
    exclude(==(""), Parts, NonEmpty),
    (   append(Lines0, ["+"], NonEmpty) -> Lines = Lines0 ; Lines = NonEmpty ).

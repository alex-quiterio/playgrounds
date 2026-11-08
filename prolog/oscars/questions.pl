% questions.pl: Answers questions asked in Portuguese, with a deterministic finite automaton.

% ---------------------------------------------------------------------%
%
%       question(+Question)
%
% Answers a question asked in Portuguese, such as
% 'quem ganhou mais oscares como actor' or 'filmes de 1995'. It
% splits the question into words and runs them through the
% automaton. A question it does not know gets the reply
% 'frase desconhecida' ("unknown sentence").
%
% ---------------------------------------------------------------------%
question(Question) :-
    atomic_list_concat(Words, ' ', Question),
    automaton(Words),
    !.
question(_) :-
    write('frase desconhecida'),
    nl,
    !.

% ---------------------------------------------------------------------%
%
%       automaton(+Words)
%
% Runs the deterministic finite automaton over Words, from its
% initial state. The final state it reaches decides which query to
% answer.
%
% ---------------------------------------------------------------------%
automaton(Words) :-
    initial_state(State),
    transition(State, Words, _).

% ---------------------------------------------------------------------%
%
%       transition(+State, +Words, +PreviousWord)
%
% The transition function: moves from State on the next word. Once
% the words run out, State must be final; PreviousWord is the last
% word read, which is the query's argument (a year or an activity).
%
% ---------------------------------------------------------------------%
transition(State, [], PreviousWord) :-
    final_state(State, PreviousWord).
transition(State, [Word|Rest], _) :-
    state(State, [Word, NextState]),
    transition(NextState, Rest, Word).

% ---------------------------------------------------------------------%
%
%       state(+Name, ?Transition)
%
% The automaton's states. Transition is [Word, NextState], or [] for
% a state with no way out. A Word of _ accepts any word.
%
% ---------------------------------------------------------------------%
state(0, ['filmes', 13]).
state(0, ['quais', 11]).
state(0, ['mostre', 8]).
state(0, ['liste', 8]).
state(0, ['quem', 1]).

state(1, ['sao', 7]).
state(1, ['ganhou', 2]).
state(2, ['mais', 3]).
state(3, ['oscares', 4]).
state(4, ['como', 5]).
state(5, [_, 6]).
state(6, []).
state(7, ['os', 9]).
state(8, ['todos', 11]).
state(8, ['os', 9]).
state(9, ['realizadores', 10]).
state(10, []).
state(11, ['os', 12]).
state(12, ['filmes', 13]).
state(13, ['de', 14]).
state(14, [_, 15]).
state(15, []).

% ---------------------------------------------------------------------%
%
%       initial_state(-Name)
%
% The automaton's initial state.
%
%       final_state(+Name, +Word)
%
% The final states. Reaching one answers its query, with Word, the
% last word of the question, as the argument:
%   6:  quem ganhou mais oscares como <activity>  -> most_oscars
%   10: liste os realizadores, ...                -> all_directors
%   15: filmes de <year>, ...                     -> all_films
%
% ---------------------------------------------------------------------%
initial_state(0).

final_state(6, Activity) :-
    most_oscars(Activity).
final_state(10, _) :-
    all_directors.
final_state(15, Word) :-
    term_to_atom(Year, Word),
    all_films(Year).

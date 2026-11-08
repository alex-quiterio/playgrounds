% Queries over a film and Oscars database, a social-network search, and a tiny
% parser for questions asked in Portuguese.
%
% The database is a set of facts:
%
%   activity(Id, Name)                        e.g. activity(1, realizador)
%   person(Id, Name, Gender, BirthYear)
%   film(Id, Title, Year, Genre)
%   took_part(PersonId, FilmId, ActivityId)
%   nominated(PersonId, FilmId, ActivityId, Won)   % Won: 1 = won, 0 = only nominated
%
% Every query that lists names prints one per line, ends with a "+", and never
% repeats a name.

% ############################## Part I ############################## %

%;;;;;;;;;;;;;;;;;;;;;;;;;;
%; 1) LIST MANIPULATION   ;
%;;;;;;;;;;;;;;;;;;;;;;;;;;

% ---------------------------------------------------------------------%
%
%       print_list(+List)
%
% Prints List with each element on its own line, ending with a +.
%
% ---------------------------------------------------------------------%
print_list([]) :- print(+).
print_list([H|Tail]) :- print(H), nl, print_list(Tail).

% ---------------------------------------------------------------------%
%
%       remove_first(+List, -Result)
%
% Result is List without its first element. Fails on the empty list.
%
%       remove_last(+List, -Result)
%
% Result is List without its last element. Fails on the empty list.
%
%       remove_duplicates(+List, -Result)
%
% Result is List with repeated elements removed, keeping the last
% occurrence of each.
%
% ---------------------------------------------------------------------%
remove_first([_|Rest], Rest).

remove_last([_|[]], []).
remove_last([Elem|Rest], [Elem|Result]) :-
    remove_last(Rest, Result).

remove_duplicates([], []).
remove_duplicates([First|Rest], Result) :-
    member(First, Rest),
    !,
    remove_duplicates(Rest, Result).
remove_duplicates([First|Rest], [First|Result]) :-
    remove_duplicates(Rest, Result).

%;;;;;;;;;;;;;;;;;;;;;;;;;
%; 2) BASIC QUERIES      ;
%;;;;;;;;;;;;;;;;;;;;;;;;;

% ---------------------------------------------------------------------%
%
%       all_films(+Year)
%
% Prints the title of every film from Year.
%
% ---------------------------------------------------------------------%
all_films(Year) :-
    findall(Film, film(_, Film, Year, _), Bag),
    remove_duplicates(Bag, Films),
    print_list(Films),
    !.

% ---------------------------------------------------------------------%
%
%       all_directors
%
% Prints the name of every director in the database.
%
%       director(-Person)
%
% Person directed at least one film.
%
% ---------------------------------------------------------------------%
all_directors :-
    findall(Person, director(Person), Bag),
    remove_duplicates(Bag, People),
    print_list(People),
    !.

director(Person) :-
    activity(ActivityId, 'realizador'),
    person(PersonId, Person, _, _),
    took_part(PersonId, _, ActivityId).

% ---------------------------------------------------------------------%
%
%       more_than_n_years(+Num)
%
% Prints the name of everyone who took part in films over Num or
% more years, counting both the first and the last year, in any
% activity.
%
%       active_for_at_least(-Person, +Num)
%
% Person has films Num or more years apart, counting both ends.
%
% ---------------------------------------------------------------------%
more_than_n_years(Num) :-
    findall(Person, active_for_at_least(Person, Num), Bag),
    remove_duplicates(Bag, People),
    print_list(People),
    !.

active_for_at_least(Person, Num) :-
    person(PersonId, Person, _, _),
    took_part(PersonId, FilmId1, _),
    took_part(PersonId, FilmId2, _),
    film(FilmId1, _, Year1, _),
    film(FilmId2, _, Year2, _),
    Year2 - Year1 >= Num - 1.

%;;;;;;;;;;;;;;;;;;;;;;;;;
%; 3) MEDIUM QUERIES     ;
%;;;;;;;;;;;;;;;;;;;;;;;;;

% ---------------------------------------------------------------------%
%
%       more_than_n_oscars(+Num, +Activity)
%
% Prints the name of everyone who won Num or more Oscars for
% Activity.
%
%       filter_by_oscars(+Num, +ActivityId, +People, -Result)
%
% Result is the people in People with Num or more Oscars for the
% activity ActivityId.
%
% ---------------------------------------------------------------------%
more_than_n_oscars(Num, Activity) :-
    activity(ActivityId, Activity),
    findall(Person, won_oscar(Person, Activity), Bag),
    remove_duplicates(Bag, People),
    filter_by_oscars(Num, ActivityId, People, Result),
    print_list(Result),
    !.

filter_by_oscars(_, _, [], []).
filter_by_oscars(Num, ActivityId, [First|Rest], [First|Result]) :-
    count_oscars(First, ActivityId, N),
    N >= Num,
    filter_by_oscars(Num, ActivityId, Rest, Result).
filter_by_oscars(Num, ActivityId, [First|Rest], Result) :-
    count_oscars(First, ActivityId, N),
    N < Num,
    filter_by_oscars(Num, ActivityId, Rest, Result).

% ---------------------------------------------------------------------%
%
%       most_oscars(+Activity)
%
% Prints the name of whoever won the most Oscars for Activity;
% everyone tied for the most, if there is a tie.
%
% ---------------------------------------------------------------------%
most_oscars(Activity) :-
    activity(ActivityId, Activity),
    findall(Person, won_oscar(Person, Activity), Bag),
    remove_duplicates(Bag, Winners),
    most_oscar_winners(ActivityId, Winners, 0, [], Result),
    print_list(Result),
    !.

% ---------------------------------------------------------------------%
%
%       won_oscar(?Person, +Activity)
%
% Person won at least one Oscar for Activity.
%
% ---------------------------------------------------------------------%
won_oscar(Person, Activity) :-
    person(PersonId, Person, _, _),
    activity(ActivityId, Activity),
    nominated(PersonId, FilmId, ActivityId, 1),
    film(FilmId, _, _, _).

% ---------------------------------------------------------------------%
%
%       count_oscars(+Person, +ActivityId, -N)
%
% N is the number of Oscars Person won for the activity ActivityId,
% counting each film once.
%
%       count_oscars_from(+PersonId, +Count, +ActivityId, +Films, -N)
%
% Counts on from Count, skipping the films already in Films.
%
% ---------------------------------------------------------------------%
count_oscars(Person, ActivityId, N) :-
    person(PersonId, Person, _, _),
    % the first solution counts every film; later ones would undercount
    once(count_oscars_from(PersonId, 0, ActivityId, [], N)).

count_oscars_from(PersonId, Count, ActivityId, Films, N) :-
    nominated(PersonId, FilmId, ActivityId, 1),
    film(FilmId, _, _, _),
    not(member(FilmId, Films)),
    Next is Count + 1,
    count_oscars_from(PersonId, Next, ActivityId, [FilmId|Films], N).
count_oscars_from(_, N, _, _, N).

% ---------------------------------------------------------------------%
%
%       most_oscar_winners(+ActivityId, +People, +Max, +Best, -Result)
%
% Walks People keeping Max, the most Oscars seen so far, and Best,
% everyone with that many. Result is Best once People runs out.
%
% ---------------------------------------------------------------------%
most_oscar_winners(_, [], _, Result, Result).
most_oscar_winners(ActivityId, [First|Rest], Max, Best, Result) :-
    count_oscars(First, ActivityId, N),
    N < Max,
    most_oscar_winners(ActivityId, Rest, Max, Best, Result).
most_oscar_winners(ActivityId, [First|Rest], Max, Best, Result) :-
    count_oscars(First, ActivityId, N),
    N == Max,
    most_oscar_winners(ActivityId, Rest, Max, [First|Best], Result).
most_oscar_winners(ActivityId, [First|Rest], Max, _, Result) :-
    count_oscars(First, ActivityId, N),
    N > Max,
    most_oscar_winners(ActivityId, Rest, N, [First], Result).

% ---------------------------------------------------------------------%
%
%       more_than_n_films(+Num)
%
% Prints the name of everyone who took part in Num or more films,
% in any activity.
%
%       filter_by_films(+People, +Num, -Result)
%
% Result is the people in People with Num or more participations.
%
% ---------------------------------------------------------------------%
more_than_n_films(Num) :-
    findall(Person, person(_, Person, _, _), Bag),
    remove_duplicates(Bag, People),
    filter_by_films(People, Num, Result),
    print_list(Result),
    !.

filter_by_films([], _, []).
filter_by_films([First|Rest], Num, [First|Result]) :-
    person(PersonId, First, _, _),
    count_participations(PersonId, N),
    N >= Num,
    filter_by_films(Rest, Num, Result).
filter_by_films([First|Rest], Num, Result) :-
    person(PersonId, First, _, _),
    count_participations(PersonId, N),
    N < Num,
    filter_by_films(Rest, Num, Result).

% ---------------------------------------------------------------------%
%
%       most_films
%
% Prints the name of whoever took part in the most films, in any
% activity; everyone tied for the most, if there is a tie.
%
%       most_film_people(+People, +Max, +Best, -Result)
%
% Walks People keeping Max, the most participations seen so far,
% and Best, everyone with that many.
%
% ---------------------------------------------------------------------%
most_films :-
    findall(Person, person(_, Person, _, _), Bag),
    remove_duplicates(Bag, People),
    most_film_people(People, 0, [], Result),
    print_list(Result),
    !.

most_film_people([], _, Result, Result).
most_film_people([First|Rest], Max, Best, Result) :-
    person(FirstId, First, _, _),
    count_participations(FirstId, N),
    N < Max,
    most_film_people(Rest, Max, Best, Result).
most_film_people([First|Rest], Max, Best, Result) :-
    person(FirstId, First, _, _),
    count_participations(FirstId, N),
    N == Max,
    most_film_people(Rest, Max, [First|Best], Result).
most_film_people([First|Rest], Max, _, Result) :-
    person(FirstId, First, _, _),
    count_participations(FirstId, N),
    N > Max,
    most_film_people(Rest, N, [First], Result).

% ---------------------------------------------------------------------%
%
%       count_participations(+PersonId, -N)
%
% N is the number of participations of the person with id PersonId:
% for each activity, the number of different films they took part
% in with it, added up over every activity.
%
%       count_participations_by_activity(+PersonId, +Activities, +Count, -N)
%
% Adds the participations for each activity id in Activities to Count.
%
%       count_films(+Films, +Count, -N)
%
% Adds one to Count for each film in Films that is in the database.
%
% ---------------------------------------------------------------------%
count_participations(PersonId, N) :-
    findall(ActivityId, activity(ActivityId, _), Bag),
    remove_duplicates(Bag, Activities),
    count_participations_by_activity(PersonId, Activities, 0, N).

count_participations_by_activity(_, [], Count, Count).
count_participations_by_activity(PersonId, [ActivityId|Rest], Count, N) :-
    findall(Film, took_part(PersonId, Film, ActivityId), Bag),
    remove_duplicates(Bag, Films),
    count_films(Films, 0, M),
    Next is Count + M,
    count_participations_by_activity(PersonId, Rest, Next, N).

count_films([], Count, Count).
count_films([Film|Rest], Count, N) :-
    film(Film, _, _, _),
    Next is Count + 1,
    count_films(Rest, Next, N).

%;;;;;;;;;;;;;;;;;;;;;;;;;
%; 4) ADVANCED QUERY     ;
%;;;;;;;;;;;;;;;;;;;;;;;;;

% ---------------------------------------------------------------------%
%
%       social_network(+Name1, +Name2)
%
% Prints the people who link Name1 to Name2 through films they made
% together: the shortest chain, without the two ends.
%
% ---------------------------------------------------------------------%
social_network(Name1, Name2) :-
    breadth_first([[Name1]], Name2, Path),
    remove_first(Path, WithoutLast),
    remove_last(WithoutLast, Between),
    print_list(Between).

% ---------------------------------------------------------------------%
%
%       edge(?Person1, ?Person2)
%
% Person1 and Person2 are directly linked: two different people who
% took part in the same film.
%
%       same_film(+PersonId1, +PersonId2)
%
% The two people took part in at least one film together.
%
% ---------------------------------------------------------------------%
edge(Person1, Person2) :-
    person(PersonId1, Person1, _, _),
    person(PersonId2, Person2, _, _),
    Person1 \= Person2,
    same_film(PersonId1, PersonId2).

same_film(PersonId1, PersonId2) :-
    took_part(PersonId1, FilmId, _),
    took_part(PersonId2, FilmId, _),
    !.

% ---------------------------------------------------------------------%
%
%       breadth_first(+[[Start]], +Goal, -Path)
%
% Breadth-first search of the graph that edge/2 describes, from
% Start to Goal. Path is the path found, Goal first.
%
% ---------------------------------------------------------------------%
breadth_first([[Goal|Path]|_], Goal, [Goal|Path]).
breadth_first([Path|Queue], Goal, FinalPath) :-
    extend(Path, Queue, NewPaths),
    append(Queue, NewPaths, NewQueue),
    breadth_first(NewQueue, Goal, FinalPath).

% ---------------------------------------------------------------------%
%
%       extend(+[Node|Path], +Queue, -NewPaths)
%
% NewPaths is every path one step longer than [Node|Path], through
% a node that is neither on the path already nor on any path still
% in Queue.
%
%       simplest_path(-NewNode, +[Node|Path], +Queue)
%
% NewNode is a neighbour of Node that is a fair next step.
%
%       in_some_path(+Node, +Paths)
%
% Node is on at least one of Paths.
%
% ---------------------------------------------------------------------%
extend([Node|Path], Queue, NewPaths) :-
    findall([NewNode, Node|Path],
        simplest_path(NewNode, [Node|Path], Queue),
        NewPaths).

simplest_path(NewNode, [Node|Path], Queue) :-
    edge(Node, NewNode),
    not(member(NewNode, Path)),
    not(in_some_path(NewNode, Queue)).

in_some_path(Node, [FirstPath|_]) :-
    member(Node, FirstPath).
in_some_path(Node, [_|Rest]) :-
    in_some_path(Node, Rest).


% ############################# Part II ############################## %

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

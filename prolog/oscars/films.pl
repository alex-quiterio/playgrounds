% films.pl: Queries about films and who took part in them.

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
% N is Count plus the number of films in Films. Fails if any of them
% is not in the database.
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

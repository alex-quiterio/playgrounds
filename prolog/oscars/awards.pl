% awards.pl: Queries about Oscars.

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

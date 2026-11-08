% social_network.pl: The social network: who links two people through films made together.

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

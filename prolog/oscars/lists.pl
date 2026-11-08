% lists.pl: List helpers.

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

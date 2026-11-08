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
%
% This file loads the rest:
%   lists.pl           list helpers
%   films.pl           films, directors, and who took part in what
%   awards.pl          Oscars won
%   social_network.pl  who links two people through films made together
%   questions.pl       questions asked in Portuguese

:- ensure_loaded(lists).
:- ensure_loaded(films).
:- ensure_loaded(awards).
:- ensure_loaded(social_network).
:- ensure_loaded(questions).

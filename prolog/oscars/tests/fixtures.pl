% Small film database used by the tests.
%
%   activity(Id, Name)
%   person(Id, Name, Gender, BirthYear)
%   film(Id, Title, Year, Genre)
%   took_part(PersonId, FilmId, ActivityId)
%   nominated(PersonId, FilmId, ActivityId, Won)   % Won: 1 = won, 0 = only nominated

activity(1, realizador).
activity(2, actor).
activity(3, argumentista).

person(1, ana, f, 1950).
person(2, bruno, m, 1960).
person(3, carla, f, 1970).
person(4, duarte, m, 1980).
person(5, eva, f, 1990).

film(1, alfa, 1990, drama).
film(2, beta, 1995, comedia).
film(3, gama, 1995, drama).
film(4, delta, 2000, accao).

took_part(1, 1, 1).
took_part(1, 2, 1).
took_part(1, 4, 2).
took_part(2, 1, 2).
took_part(2, 3, 2).
took_part(3, 3, 1).
took_part(3, 4, 2).
took_part(3, 4, 3).
took_part(4, 4, 2).

nominated(1, 1, 1, 1).
nominated(1, 2, 1, 1).
nominated(3, 3, 1, 1).
nominated(2, 1, 2, 1).
nominated(2, 3, 2, 1).
nominated(4, 4, 2, 1).
nominated(3, 4, 2, 0).

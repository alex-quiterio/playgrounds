% Small film database used by the tests.
%
%   actividade(Id, Nome)
%   pessoa(Id, Nome, Genero, AnoNascimento)
%   filme(Id, Titulo, Ano, Genero)
%   participa(IdPessoa, IdFilme, IdActividade)
%   nomeada(IdPessoa, IdFilme, IdActividade, Ganhou)   % Ganhou: 1 = won, 0 = nominated

actividade(1, realizador).
actividade(2, actor).
actividade(3, argumentista).

pessoa(1, ana, f, 1950).
pessoa(2, bruno, m, 1960).
pessoa(3, carla, f, 1970).
pessoa(4, duarte, m, 1980).
pessoa(5, eva, f, 1990).

filme(1, alfa, 1990, drama).
filme(2, beta, 1995, comedia).
filme(3, gama, 1995, drama).
filme(4, delta, 2000, accao).

participa(1, 1, 1).
participa(1, 2, 1).
participa(1, 4, 2).
participa(2, 1, 2).
participa(2, 3, 2).
participa(3, 3, 1).
participa(3, 4, 2).
participa(3, 4, 3).
participa(4, 4, 2).

nomeada(1, 1, 1, 1).
nomeada(1, 2, 1, 1).
nomeada(3, 3, 1, 1).
nomeada(2, 1, 2, 1).
nomeada(2, 3, 2, 1).
nomeada(4, 4, 2, 1).
nomeada(3, 4, 2, 0).

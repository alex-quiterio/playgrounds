% ############################## Parte I ############################# %

% 1) MANIPULACOES PARA LISTAS

% ---------------------------------------------------------------------%
%
%       imprimeLista(+Lista)
%
% Imprime Lista formatada como no enunciado, isto e, com cada
% elemento numa linha diferente e terminada com um +.
%
% ---------------------------------------------------------------------%
imprimeLista([]) :- print(+).
imprimeLista([H|Tail]) :- print(H),nl, imprimeLista(Tail).
% ---------------------------------------------------------------------%
%
%       removePrimeiro(+Lista, -Resultado)
%
% Remove o primeiro elemento de Lista e devolve a nova lista em
% Resultado.
% Nao deve ser chamado com a lista vazia(devolve falso).
%
%       removeUltimo(+Lista, -Resultado)
%
% Remove o ultimo elemento de Lista e devolve a nova lista em
% Resultado.
% Nao deve ser chamado com a lista vazia(devolve falso).
%
% removeRepetidos(+Lista, -Resultado)
%
% Remove elementos repetidos de Lista, e devolve em resultado a
% lista sem elementos repetidos.
%
% ------------------------------------------------------------------------%
removePrimeiro([_|Resto],Resto).

removeUltimo([_|[]], []).
removeUltimo([Elem|Resto], [Elem|Resultado]) :-
 removeUltimo(Resto,Resultado).

removeRepetidos([], []).
removeRepetidos([Primeiro | Resto], Resultado) :-
 member(Primeiro, Resto),
 !,
 removeRepetidos(Resto, Resultado).
removeRepetidos([Primeiro | Resto], [Primeiro | Resultado]) :-
 removeRepetidos(Resto, Resultado).

%;;;;;;;;;;;;;;;;;;;;;;;;;
%; 2) PREDICADOS BASICOS ;
%;;;;;;;;;;;;;;;;;;;;;;;;;

% ------------------------------------------------------------------------%
%
%       todosFilmes(+Ano)
%
%       Devolve uma lista sem elementos repetidos contendo todos os
%       nomes dos filmes do ano Ano.
%
% ------------------------------------------------------------------------%

todosFilmes(Ano) :-
 findall(Filme,filme(_, Filme, Ano, _),Bag),
 removeRepetidos(Bag, ListaFinal),
 imprimeLista(ListaFinal),
 !.
% ------------------------------------------------------------------------%
%
%       todosRealizadores()
%
%       Devolve uma lista sem elementos repetidos contendo todos os
%       nomes dos realizadores da base de dados.
%
% ------------------------------------------------------------------------%

todosRealizadores :-
 findall(Pessoa,realizador(Pessoa),Bag),
 removeRepetidos(Bag, Lista),
 imprimeLista(Lista),
 !.
realizador(Pessoa) :-
 actividade(Id_act, 'realizador'),
 pessoa(Id_pessoa,Pessoa,_,_),
 participa(Id_pessoa,_,Id_act).

% ------------------------------------------------------------------------%
%
%       maisQueNAnos(+Num)
%
%       maisQueNAnos(Num): devolve uma lista sem elementos repetidos
%       com todos os nomes das pessoas que entraram em filmes durante
%       Num ou mais anos (independentemente da actividade);
%
% ------------------------------------------------------------------------%

maisQueNAnos(Num) :-
 findall(Pessoa,participouMaisQue(Pessoa,Num),Bag),
 removeRepetidos(Bag, Lista),
 imprimeLista(Lista),
 !.
participouMaisQue(Pessoa,Num) :-
 pessoa(Id_pessoa,Pessoa,_,_),
 participa(Id_pessoa,Id_filme1,_),
 participa(Id_pessoa,Id_filme2,_),
        filme(Id_filme1,_,Ano1,_),
 filme(Id_filme2,_,Ano2,_),
 Ano2-Ano1 >= Num-1.


%;;;;;;;;;;;;;;;;;;;;;;;;
%; 3) PREDICADOS MEDIOS ;
%;;;;;;;;;;;;;;;;;;;;;;;;

% ------------------------------------------------------------------------%
%
%       maisQueNOscares(+Num, +Actividade)
%
%       Devolve uma lista sem elementos repetidos com o(s) nome(s) da(s)
%       pessoa(s) que ganhou(aram) Num ou mais oscares, tendo como
%       actividade Actividade.
%
% ------------------------------------------------------------------------%
maisQueNOscares(Num, Actividade) :-
 actividade(Id_Act, Actividade),
 findall(Pessoa, ganhouOscar(Pessoa, Actividade), Pessoas),
 removeRepetidos(Pessoas, PessoasClean),
 auxMaisQueNOscares(Num, Id_Act, PessoasClean, Resultado),
 imprimeLista(Resultado),
 !.
auxMaisQueNOscares(_, _, [], []).
auxMaisQueNOscares(Num, Id_Act, [Primeira|Resto], [Primeira|Resultado]) :-
 calculaNOscares(Primeira, Id_Act, N),
 N >= Num,
 auxMaisQueNOscares(Num, Id_Act, Resto, Resultado).
auxMaisQueNOscares(Num, Id_Act, [Primeira|Resto], Resultado) :-
 calculaNOscares(Primeira, Id_Act, N),
 N < Num,
 auxMaisQueNOscares(Num, Id_Act, Resto, Resultado).


% ------------------------------------------------------------------------%
%
%       maisOscares(+Actividade)
%
%       Devolve uma lista sem elementos repetidos com o(s) nome(s) da(s)
%       pessoa(s) que ganhou(aram) mais oscares, tendo como actividade
% Actividade.
%
% ------------------------------------------------------------------------%

maisOscares(Actividade) :-
 actividade(Id_Act, Actividade),
        findall(Pessoa, ganhouOscar(Pessoa, Actividade), Vencedores),
 removeRepetidos(Vencedores, VencedoresClean),
 ganhouMaxOscares(Id_Act, VencedoresClean, 0, [], Resultado),
 imprimeLista(Resultado),
 !.

% ------------------------------------------------------------------------%
%
%       ganhouOscar(+Pessoa, +Actividade)
%
%       E verdadeiro se Pessoa tiver ganho pelo menos um oscar para
%       a Actividade.
%
% ------------------------------------------------------------------------%

ganhouOscar(Pessoa, Actividade) :-
 pessoa(Id_Pessoa, Pessoa, _, _),
 actividade(Id_Act, Actividade),
 nomeada(Id_Pessoa, Id_Filme, Id_Act, 1),
 filme(Id_Filme, _, _, _).

% ------------------------------------------------------------------------%
%
%       calculaNOscares(+Pessoa, +Actividade, -N).
%
% Calcula o numero(N) de oscares ganhos por Pessoa para
% Actividade.
%
% ------------------------------------------------------------------------%

calculaNOscares(Pessoa, Id_Act, N) :-
 pessoa(Id_Pessoa, Pessoa, _, _),
 auxCalculaNOscares(Id_Pessoa, 0, Id_Act, [], N).
auxCalculaNOscares(Id_Pessoa, N_Actual, Id_Actividade, Filmes, Resposta) :-
 nomeada(Id_Pessoa,Id_Filme,Id_Actividade, 1),
 filme(Id_Filme, _, _, _),
 not(member(Id_Filme, Filmes)),
 N_mais_um is N_Actual+1,
 auxCalculaNOscares(Id_Pessoa,N_mais_um, Id_Actividade, [Id_Filme|Filmes], Resposta).
auxCalculaNOscares(_, N, _, _, N).

ganhouMaxOscares(_,[], _, Resultado, Resultado).
ganhouMaxOscares(Id_Act, [Primeiro|Resto], MaxActual, ListaTemp, ResultadoFinal) :-
 calculaNOscares(Primeiro, Id_Act, N),
 N < MaxActual,
        ganhouMaxOscares(Id_Act, Resto, MaxActual, ListaTemp, ResultadoFinal).
ganhouMaxOscares(Id_Act, [Primeiro|Resto], MaxActual, ListaTemp, ResultadoFinal) :-
 calculaNOscares(Primeiro, Id_Act, N),
 N == MaxActual,
 ganhouMaxOscares(Id_Act, Resto, MaxActual, [Primeiro|ListaTemp], ResultadoFinal).
ganhouMaxOscares(Id_Act, [Primeiro|Resto], MaxActual, _, ResultadoFinal) :-
 calculaNOscares(Primeiro, Id_Act, N),
 N > MaxActual,
 ganhouMaxOscares(Id_Act, Resto, N, [Primeiro], ResultadoFinal).

% ------------------------------------------------------------------------%
%
%       maisQueNFilmes(+Num)
%
%       Devolve uma lista sem elementos repetidos com o(s) nome(s) da(s)
% pessoa(s) que entrararam em Num ou mais filmes,
% independentemente do cargo.
%
% ------------------------------------------------------------------------%

maisQueNFilmes(Num) :-
 findall(Pessoa, pessoa(_, Pessoa, _, _), Pessoas),
 removeRepetidos(Pessoas, PessoasClean),
 auxMaisQueNFilmes(PessoasClean, Num, Resultado),
 imprimeLista(Resultado),
 !.
auxMaisQueNFilmes([], _, []).
auxMaisQueNFilmes([Primeira|Resto], Num, [Primeira|Resultado]) :-
 pessoa(Id_Pessoa, Primeira, _, _),
 calculaNParticipacoes(Id_Pessoa, N),
 N >= Num,
 auxMaisQueNFilmes(Resto, Num, Resultado).
auxMaisQueNFilmes([Primeira|Resto], Num, Resultado) :-
 pessoa(Id_Pessoa, Primeira, _, _),
 calculaNParticipacoes(Id_Pessoa, N),
 N < Num,
 auxMaisQueNFilmes(Resto, Num, Resultado).

% ------------------------------------------------------------------------%
%
%       maisQueNFilmes(+Num)
%
%       Devolve uma lista sem elementos repetidos com o(s) nome(s) da(s)
% pessoa(s) que entrararam em mais filmes, independentemente da
% actividade.
%
% ------------------------------------------------------------------------%
maisFilmes :-
 findall(Pessoa, pessoa(_, Pessoa, _, _), Pessoas),
 removeRepetidos(Pessoas, PessoasClean),
 participaMaxFilmes(PessoasClean, 0, [], Resultado),
 imprimeLista(Resultado),
 !.

participaMaxFilmes([], _, Resultado, Resultado).
participaMaxFilmes([Primeira|Resto], MaxActual, ListaTemp, ResultadoFinal) :-
 pessoa(Id_Primeira, Primeira, _, _),
 calculaNParticipacoes(Id_Primeira, N),
 N < MaxActual,
 participaMaxFilmes(Resto, MaxActual, ListaTemp, ResultadoFinal).
participaMaxFilmes([Primeira|Resto], MaxActual, ListaTemp, ResultadoFinal) :-
 pessoa(Id_Primeira, Primeira, _, _),
 calculaNParticipacoes(Id_Primeira, N),
 N == MaxActual,
 participaMaxFilmes(Resto, MaxActual, [Primeira|ListaTemp], ResultadoFinal).
participaMaxFilmes([Primeira|Resto], MaxActual, _, ResultadoFinal) :-
 pessoa(Id_Primeira, Primeira, _, _),
 calculaNParticipacoes(Id_Primeira, N),
 N > MaxActual,
 participaMaxFilmes(Resto, N, [Primeira], ResultadoFinal).

% ------------------------------------------------------------------------%
%
%       calculaNParticipacoes(+Pessoa, -N).
%
% Calcula o numero(N) de participacoes em filmes, isto e, para
% cada filme, conta o numero de participacoes com actividades
% diferentes para a pessoa(Pessoa) e devolve o total de todos os
% filmes em N.
%
% ------------------------------------------------------------------------%

calculaNParticipacoes(Pessoa, N) :-
 findall(Actividade, actividade(Actividade, _), Actividades),
 removeRepetidos(Actividades, ActClean),
 auxCalculaNParticipacoes(Pessoa, ActClean, 0, N).

auxCalculaNParticipacoes(_, [], Ac, Ac).
auxCalculaNParticipacoes(Pessoa, [Act|Resto], Ac, N) :-
 findall(Filme, participa(Pessoa, Filme, Act), Filmes),
 removeRepetidos(Filmes, FilmesFinal),
 auxAuxCalculaNParticipacoes(FilmesFinal, 0, M),
 Ac_Novo is Ac + M,
 auxCalculaNParticipacoes(Pessoa, Resto, Ac_Novo, N).

auxAuxCalculaNParticipacoes([], Acumulador, Acumulador).
auxAuxCalculaNParticipacoes([Filme1|Resto], Acumulador, M) :-
 filme(Filme1, _, _, _),
 Ac_mais_1 is Acumulador + 1,
 auxAuxCalculaNParticipacoes(Resto, Ac_mais_1, M).


%;;;;;;;;;;;;;;;;;;;;;;;;;
%; 3) PREDICADO AVANCADO ;
%;;;;;;;;;;;;;;;;;;;;;;;;;

% ------------------------------------------------------------------------%
%
%       redeSocial(+Nome1, +Nome2).
%
% Devolve uma lista com o nome de pessoas que representam uma
% ligacao possivel entre as pessoas com nome Nome1 e Nome2.
%
% ------------------------------------------------------------------------%

redeSocial(Nome1, Nome2) :-
        breadth_first([[Nome1]],Nome2,Caminho),
 removePrimeiro(Caminho, Temp),
 removeUltimo(Temp, ListaFinal),
 imprimeLista(ListaFinal).

% ------------------------------------------------------------------------%
%
%       edge(+Pessoa1, +Pessoa2).
%
% E verdadeiro caso exista uma ligacao directa entre Pessoa1 e
% Pessoa2, isto e, caso participem num mesmo filme.
%
% ------------------------------------------------------------------------%
edge(Pessoa1, Pessoa2) :-
 pessoa(Id_Pessoa1, Pessoa1, _, _),
 pessoa(Id_Pessoa2, Pessoa2, _, _),
 Pessoa1 \= Pessoa2,
 participamMesmoFilme(Id_Pessoa1,Id_Pessoa2).

participamMesmoFilme(Id_Pessoa1,Id_Pessoa2) :-
 participa(Id_Pessoa1,Id_Filme,_),
 participa(Id_Pessoa2,Id_Filme,_),
 !.

%----------------------------------------------------------------------%
%
%       breadth_first(+[[Start]],+Goal,-Path).
%
% Executa uma procura em largura num grafo. No parametro Start
% deve ser colocado o no inicial, e no parametro Goal o no
% objectivo. Devolve um caminho de Start para Goal em Path.
%
%----------------------------------------------------------------------%

breadth_first([[Goal|Path]|_],Goal,[Goal|Path]).
breadth_first([Path|Queue],Goal,FinalPath) :-
    extend(Path,Queue,NewPaths),
    append(Queue,NewPaths,NewQueue),
    breadth_first(NewQueue,Goal,FinalPath).

%----------------------------------------------------------------------%
%
%       extend(+[Node|Path],+Queue,-Paths).
%
% Extende o caminho a partir de Node, isto e, procura todos os nos
% que obedecem ao criterio fornecido, concatena os nos com o
% caminho ate ali e devolve uma lista de caminhos novos.
%
%----------------------------------------------------------------------%
extend([Node|Path],Queue,NewPaths):-
 findall([NewNode,Node|Path],
  simplestPath(NewNode,[Node|Path], Queue),
  NewPaths).

simplestPath(NewNode, [Node|Path], Queue) :-
 edge(Node,NewNode),
 not(member(NewNode,Path)),
 not(existeEmUmCaminho(NewNode,Queue)).

existeEmUmCaminho(Node,[PrimeiroCaminho|_]):-
 member(Node,PrimeiroCaminho).
existeEmUmCaminho(Node,[_|Resto]):-
 existeEmUmCaminho(Node,Resto).


% ############################# Parte II ############################# %

%--------------------------------------------------------------------%
%
%       questao(+Questao)
%
% Faz o parse da pergunta de forma a ser processavel pelo
%       automato. Caso a frase seja desconhecida, responde com
%       frase desconhecida.
%
%
%
%--------------------------------------------------------------------%
questao(Questao) :-
 concat_atom(Lista , ' ', Questao),
 automato(Lista),
 !.
questao(_) :-
 write('frase desconhecida'),
 nl,
 !.
%--------------------------------------------------------------------%
%
%       automato(+Entrada)
%
% Inicia o funcionamento do automato finito deterministico que ira
% processar a lista de atomos que recebe, de forma a decidir qual
% o predicado a que se refere.
%--------------------------------------------------------------------%
automato(Entrada) :-
 estadoInicial(Estado),
 transita(Estado,Entrada, _).
%--------------------------------------------------------------------%
%
%       transita(+Estado, +Entrada, +EntradaAnterior)
%
% Funcao de transicao. Recebe o estado actual e a entrada, e
% decide qual o novo estado. O parametro EntradaAnterior e
% utilizado de forma a permitir que, quando chegamos ao estado
% final, seja conhecido o parametro recebido anteriormente(Ano ou
% Actividade).
%
%--------------------------------------------------------------------%
transita(Estado, [], EntradaAnterior) :-
 estadoFinal(Estado, EntradaAnterior).
transita(Estado, [Entrada|Resto], _) :-
 estado(Estado, [Entrada,NovoEstado]),
 transita(NovoEstado, Resto, Entrada).

%--------------------------------------------------------------------%
%
%      estado(Nome, Transicao)
%
%      Representa os estados do automato finito deterministico.
%
%--------------------------------------------------------------------%

estado(0, ['filmes', 13]).
estado(0, ['quais', 11]).
estado(0, ['mostre', 8]).
estado(0, ['liste', 8]).
estado(0, ['quem', 1]).

estado(1, ['sao', 7]).
estado(1, ['ganhou', 2]).
estado(2, ['mais', 3]).
estado(3, ['oscares', 4]).
estado(4, ['como', 5]).
estado(5, [_, 6]).
estado(6, []).
estado(7, ['os', 9]).
estado(8, ['todos', 11]).
estado(8, ['os', 9]).
estado(9, ['realizadores', 10]).
estado(10, []).
estado(11, ['os', 12]).
estado(12, ['filmes', 13]).
estado(13, ['de', 14]).
estado(14, [_, 15]).
estado(15, []).

%--------------------------------------------------------------------%
%
%      estadoInicial(-Nome)
%
%      Indica qual e o estado inicial do automato.
%
%      estadoFinal(+Nome, +Entrada)
%
%      Indica os estados finais e, para cada um, chama o predicado
%      associado ao correcto processamento do input.
%
%--------------------------------------------------------------------%
estadoInicial(0).

estadoFinal(6, Actividade) :-
 maisOscares(Actividade).
estadoFinal(10, _) :-
 todosRealizadores.
estadoFinal(15, Entrada) :-
 term_to_atom(Ano, Entrada),
 todosFilmes(Ano).

% Tests for oscares.pl. Run with: swipl -g run_tests -t halt tests/oscares_test.pl

:- use_module(library(plunit)).
:- initialization((
       prolog_load_context(directory, Dir),
       atom_concat(Dir, '/fixtures.pl', Fixtures),
       atom_concat(Dir, '/../oscares.pl', Oscares),
       consult(Fixtures),
       consult(Oscares)
   ), now).

%! prints(:Goal, -Lines) is det.
%  Runs Goal once and returns the lines it printed, without the closing "+".
prints(Goal, Lines) :-
    with_output_to(string(Out), once(Goal)),
    split_string(Out, "\n", "", Parts),
    exclude(==(""), Parts, NonEmpty),
    (   append(Lines0, ["+"], NonEmpty) -> Lines = Lines0 ; Lines = NonEmpty ).

:- begin_tests(listas).

test(remove_primeiro) :- removePrimeiro([a, b, c], [b, c]).
test(remove_primeiro_lista_vazia, [fail]) :- removePrimeiro([], _).
test(remove_ultimo) :- removeUltimo([a, b, c], [a, b]).
test(remove_ultimo_um_elemento) :- removeUltimo([a], []).
test(remove_ultimo_lista_vazia, [fail]) :- removeUltimo([], _).
test(remove_repetidos_mantem_ultima_ocorrencia) :- removeRepetidos([a, b, a, c, b], [a, c, b]).
test(remove_repetidos_vazia) :- removeRepetidos([], []).
test(imprime_lista) :-
    with_output_to(string(S), imprimeLista([a, b])),
    S == "a\nb\n+".

:- end_tests(listas).

:- begin_tests(basicos).

test(todos_filmes_de_um_ano) :- prints(todosFilmes(1995), ["beta", "gama"]).
test(todos_filmes_ano_sem_filmes) :- prints(todosFilmes(1800), []).
test(todos_realizadores) :- prints(todosRealizadores, ["ana", "carla"]).
test(mais_que_n_anos_conta_anos_inclusive) :- prints(maisQueNAnos(11), ["ana"]).
test(mais_que_n_anos) :- prints(maisQueNAnos(6), ["ana", "bruno", "carla"]).
test(mais_que_n_anos_ninguem) :- prints(maisQueNAnos(12), []).

:- end_tests(basicos).

:- begin_tests(medios).

test(ganhou_oscar, [nondet]) :- ganhouOscar(ana, realizador).
test(nomeado_sem_ganhar, [fail]) :- ganhouOscar(carla, actor).
test(calcula_n_oscares, [true(N == 2)]) :- calculaNOscares(ana, 1, N).
test(calcula_n_oscares_e_deterministico, [all(N == [2])]) :- calculaNOscares(ana, 1, N).
test(calcula_n_participacoes, [true(N == 3)]) :- calculaNParticipacoes(3, N).
test(mais_que_n_oscares) :- prints(maisQueNOscares(1, actor), ["bruno", "duarte"]).
test(mais_que_n_oscares_limite) :- prints(maisQueNOscares(2, actor), ["bruno"]).
test(mais_oscares_realizador) :- prints(maisOscares(realizador), ["ana"]).
test(mais_oscares_actor) :- prints(maisOscares(actor), ["bruno"]).
test(mais_que_n_filmes) :- prints(maisQueNFilmes(2), ["ana", "bruno", "carla"]).
test(mais_que_n_filmes_limite) :- prints(maisQueNFilmes(3), ["ana", "carla"]).
test(mais_filmes_com_empate) :-
    prints(maisFilmes, Lines),
    msort(Lines, ["ana", "carla"]).

:- end_tests(medios).

:- begin_tests(rede_social).

test(edge_mesmo_filme) :- edge(bruno, ana).
test(edge_e_simetrico) :- edge(ana, bruno).
test(sem_edge_para_si_proprio, [fail]) :- edge(ana, ana).
test(pessoa_isolada_sem_edges, [fail]) :- edge(eva, _).
test(ligacao_directa_nao_tem_intermediarios) :- prints(redeSocial(ana, bruno), []).
test(ligacao_por_um_intermediario) :- prints(redeSocial(bruno, duarte), ["ana"]).

:- end_tests(rede_social).

:- begin_tests(questoes).

test(quem_ganhou_mais_oscares) :-
    prints(questao('quem ganhou mais oscares como actor'), ["bruno"]).
test(liste_os_realizadores) :-
    prints(questao('liste os realizadores'), ["ana", "carla"]).
test(quem_sao_os_realizadores) :-
    prints(questao('quem sao os realizadores'), ["ana", "carla"]).
test(filmes_de_ano) :-
    prints(questao('filmes de 1995'), ["beta", "gama"]).
test(quais_os_filmes_de_ano) :-
    prints(questao('quais os filmes de 1990'), ["alfa"]).
test(frase_desconhecida) :-
    prints(questao('ola mundo'), ["frase desconhecida"]).

:- end_tests(questoes).

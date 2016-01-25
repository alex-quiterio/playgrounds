; Inteligencia Artificial
; -*- Mode: Lisp; Syntax: Steel Bank Common Lisp; -*-

;------------ Parametros de bonus (Para funcoes heuristicas) ----------------------------------;
(defparameter *value-victory* 1000)
(defparameter *value-defeat* -1000)
(defparameter *value-piece-ring* 10)
(defparameter *value-piece-ring-1* 200)
(defparameter *value-first-piece-ring* 200)
(defparameter *value-path-elem* 5)

;;;; Constantes Numericas
(defconstant infinity most-positive-single-float)
(defconstant minus-infinity most-negative-single-float)

; ----------------- metodos de escrita para stdout ------------------;
; Em sistemas com fluxos de saida como o de SBCL, os writes ficam em buffer ate ao final da
; execucao da funcao ou ate ao limite do buffer, para tal utiliza-se finish-ouput para obrigar o flush
(defun escreve-nl (String)
  (write-line String)
  (finish-output NIL))

(defun escreve (String)
  (write String)
  (finish-output NIL))

(defun printf(String)
  (princ String)
  (finish-output NIL))

(defun print-var(variavel)
  (print variavel)
  (finish-output NIL))


;-------------- Funcoes uteis para listas ---------------------------;
; Retorna o melhor elemento da lista avaliada com a funcao fn
; the-biggest(fn x list) -> elemento
(defun the-biggest (fn l)
  (let ((biggest (first l))
	(best-val (funcall fn (first l))))
    (dolist (x (rest l))
      (let ((val (funcall fn x)))
	(when (> val best-val)
	  (setq best-val val)
	  (setq biggest x))))
    biggest))

; Move o primeiro elemento da lista para a ultima posicao
; left-rotate (list) -> list
(defun left-rotate (list)
  (append (rest list) (list (first list))))

; Move o ultimo elemento da lista para primeiro
; right-rotate (list) -> list
(defun right-rotate (list)
  (append (last list) (butlast list)))

;------------------------------ TAI Para Y ----------------------------------;
;;;; cria-anel: inteiro -> anel
(defun cria-anel (n)
  (make-list (* 3 n) :initial-element '*))

; faz-tabuleiro: inteiro -> tabuleiro
(defun faz-tabuleiro (n)
  (let ((l (make-list n)))
    (loop for i below n
          do (setf (nth i l) (cria-anel (1+ i))))
    l))

; tabuleiro-poe-peca (tab x peca x anel x pos) -> tab
(defun tabuleiro-poe-peca (tab peca anel pos)
  (let ((newTab (make-list (length tab))))
    (loop for i below (length tab)
        do (setf (nth i newTab) (copy-list (nth i tab))))
    (setf (nth pos (nth (1- anel) newTab)) peca)
    newTab))

; tabuleiro-poe-pece (tab x peca x anel x pos) -> tab
(defun tabuleiro-poe-peca! (tab peca anel pos)
  (setf (nth pos (nth (1- anel) tab)) peca))

; tabuleiro-peca (tabuleiro x anel x pos) -> inteiro
(defun tabuleiro-peca (tab anel pos)
  (nth pos (nth (1- anel) tab)))

; tabuleiro-aneis (tabuleiro) -> inteiro
(defun tabuleiro-aneis (tab)
  (length tab))

; tabuleiro-p (objecto) -> true || false
(defun tabuleiro-p (obj)
  (if (and
        (listp obj)
        (not (null obj)))
    (block tabtest
      (let ((aneis (length obj)))
        (loop for i below aneis
          do (if (listp (nth i obj))
               (let* ((anel (nth i obj))
                      (len (length anel)))
                 (if (= len (* 3 (1+ i)))
                   (loop for j below len
                     do (let ((peca (nth j anel)))
                          (if (not (or
                                     (equal peca 'X)
                                     (equal peca 'O)
                                     (equal peca '*)))
                            (return-from tabtest nil))))
                   (return-from tabtest nil)))
               (return-from tabtest nil))))
      (return-from tabtest T))))

; escreve-tabuleiro (tabuleiro) -> nil
(defun escreve-tabuleiro (tab)
  (when (tabuleiro-p tab)
    (let ((n (tabuleiro-aneis tab)))
      (loop for i from 1 below (1+ n)
            do (progn
                 (loop for j below (* 3 i)
                     do (progn
                          (printf (tabuleiro-peca tab i j))
                          (when (= 0 (mod (1+ j) i))
                            (progn
                              (loop for k below (- n i)
                                  do (printf " "))))))
                 (terpri))))))

; nPosicoes (aneis) -> numero de posicoes de um tabuleiro
(defun nPosicoes (aneis)
  (let ((res 0))
    (if (> aneis 0)
      (progn
        (incf res (* aneis 3))
        (incf res (nPosicoes (1- aneis))))
      res)))

; legal-move? (board x level x position) -> true || false
;Checks whether the move is valid.
(defun legal-move? (board level pos)
  (if (eq (tabuleiro-peca board level pos) '*)
    t
    nil))

; le-posicao () -> inteiro
; Retorna um valor inteiro lido do stdin
(defun le-posicao ()
  (let ((buf 0))
     (loop while T
      do
       (escreve '?)
       (setf buf (read))
       (when (integerp buf)
         (return T))
       (escreve-nl "input invalido")
       )
    buf))
;----------------------------- Estrutura Game ------------------------------------;
; A estrutura game e utilizada para recolher informacoes ao longo das duas instancias
(defstruct game
  (players '(X O))  ; jogadores
  (times '(0 0))	; tempos de cada jogador
  (scores '(X 0 O 0))   ; vitorias de cada jogador
  (levels 0)
  )

; Inicializacao da estrutura game
(defun init-game ()
  (make-game))

; Get Player A (READ ONLY)
(defun get-player-a (stats)
  (first (game-players stats)))

; Get Player B (READ ONLY)
(defun get-player-b (stats)
  (second (game-players stats)))

;--------- GETTERS Scores -----;
(defun get-g-scores-a (stats)
  (getf (game-scores stats) 'X))

(defun get-g-scores-b (stats)
  (getf (game-scores stats) 'O))

;--------- SETTERS Scores -----;
(defun set-g-scores-a (value stats)
  (setf (getf (game-scores stats) 'X) value))

(defun set-g-scores-b (value stats)
  (setf (getf (game-scores stats) 'O) value))

;--------- GETTERS Times -----;
(defun get-g-times-a (stats)
  (first (game-times stats)))

(defun get-g-times-b (stats)
  (second (game-times stats)))

;--------- SETTERS Times -----;
(defun set-g-times-a (value stats)
  (setf (first (game-times stats)) value))

(defun set-g-times-b (value stats)
  (setf (second (game-times stats)) value))

;--------- GETTER Levels -----;
(defun get-g-levels (stats)
  (game-levels stats))

;--------- SETTER Levels -----;
(defun set-g-levels(value stats)
  (setf (game-levels stats) value))

;----------------------------- Estrutura Game-State ---------------------------------;
; A estrutura game-state e utilizada dentro do jogador automatico e dentro da instancia
(defstruct game-state
  (board)             ; estado do tabuleiro
  (nAneis 0)          ; numero de aneis
  (scores '(0 0))     ; vitorias
  (players '(X O))    ; jogadores
  (times '(0 0))      ; tempos de cada jogador
  (paths '())		  ; lista de caminhos
  (terminal? nil)     ; o jogo chegou ao fim
  (current-player '(X O)) ; jogador actual
  )
; init-game-state (aneis) -> game-state
; Recebe o numero de aneis do tabuleiro
; inicializa os parametros da estrutura
; Retorna game-state
(defun init-game-state(aneis)
  (let ((a (make-game-state)))
  (setf (game-state-board a) (faz-tabuleiro aneis))
  a))

(defun get-board (state)
  (game-state-board state))

(defun set-board (board state)
  (setf (game-state-board state) board))

(defun get-current-player (state)
  (first (game-state-current-player state)))

(defun get-previous-player (state)
  (second (game-state-current-player state)))

(defun swap-current-player (state)
  (setf (game-state-current-player state) (reverse (game-state-current-player state))))

;; Getters & Setters para players
;; A
(defun get-scores-a (state)
  (first (game-state-scores state)))

(defun set-scores-a (value state)
  (setf (first (game-state-scores state)) value))

;;  B
(defun get-scores-b (state)
  (second (game-state-scores state)))

(defun set-scores-b (value state)
  (setf (second (game-state-scores state)) value))

;; Getters & Setters to times
;; Para A
(defun get-time-a (state)
  (first (game-state-times state)))

(defun set-time-a (value state)
  (setf (first (game-state-times state)) value))

;; Para B
(defun get-time-b (state)
  (second (game-state-times state)))

(defun set-time-b (value state)
  (setf (second (game-state-times state)) value))

;------------------------ Funcoes auxiliares para o metodo adjacentes --------------------;

; max-anel-ocupado? (tabuleiro x peca) -> true || false
; Se tabuleiro tiver no seu ultimo anel pecas do tipo peca retorn true, cc false
(defun max-anel-ocupado? (tabuleiro peca)
	(let ((anel (tabuleiro-aneis tabuleiro)))
	(loop for i below (* anel 3)
		do (when (string-equal peca (tabuleiro-peca tabuleiro (- anel 1) i))
		     T))))

; adjacentesMesmoAnel (anel x pos) -> lista de adjacentes
; Retorna a lista de adjacentes no mesmo anel
(defun adjacentesMesmoAnel (anel pos)
  (let ((res '()))
    (if (= pos 0)
        (setf res (cons (cons anel (1- (* 3 anel))) res))
      (setf res (cons (cons anel (1- pos)) res)))
    (if (= pos (1- (* 3 anel)))
        (setf res (cons (cons anel 0) res))
      (setf res (cons (cons anel (1+ pos)) res)))
    res))

; adjacentesAnelSuperior (anel x pos) -> lista de adjacentes
; Retorna a lista de adjacentes no anel superior
(defun adjacentesAnelSuperior (anel pos)
  (let ((res '())
        (p (mod pos anel))
        (terco (floor pos anel))
        (aSup (1+ anel)))
    (when (= p (1- anel))
      (setf res (cons (cons aSup (mod (* aSup(1+ terco)) (* 3 aSup))) res)))
    (setf res (cons (cons aSup (+ p (* terco aSup))) res))
    (setf res (cons (cons aSup (+ p (* terco aSup) 1)) res))
    res))

; adjacentesAnelInferior (anel x pos) -> lista de adjacentes
; Retorna a lista de adjacentes no anel inferior
(defun adjacentesAnelInferior (anel pos)
  (let ((res '())
        (p (mod pos anel))
        (terco (floor pos anel))
        (aInf (1- anel)))
    (cond
      ((= p 0)
        (setf res (cons (cons aInf (+ (* aInf (mod (1- terco) 3)) (1- aInf))) res))
        (setf res (cons (cons aInf (+ (* aInf terco) p)) res)))
      ((= p (1- anel))
        (setf res (cons (cons aInf (+ (* aInf terco)(1- p))) res)))
      (t
        (setf res (cons (cons aInf (+ (* aInf terco) p)) res))
        (setf res (cons (cons aInf (+ (* aInf terco)(1- p))) res))))
    res))

; adjacentes (anel x pos x n) -> lista de adjacentes
; Retorna a lista de adjacentes
(defun adjacentes (anel pos n)
  (let ((res '()))
    (when (not (= anel 1))
      (setf res (append (adjacentesAnelInferior anel pos) res)))
    (when (not (= anel n))
      (setf res (append (adjacentesAnelSuperior anel pos) res)))
    (setf res (append (adjacentesMesmoAnel anel pos) res))
    res))

;------------------------ Actualiza Caminhos --------------------------------------;

; actualizaCaminhos (listaCaminhos x listaAdjacentes x anel x pos x jogador) -> lista
; Retorna a lista actualizada de caminhos possiveis
(defun actualizaCaminhos (listaCaminhos listaAdjacentes anel pos jogador)
  (let ((res '())
        (novaListaCaminhos '())
        (posAgreg (cons anel pos))
        (flag T))
    (block corpo
      (dolist (caminho listaCaminhos)
        (when (equal (car caminho) jogador)
          (block verificaAdjacencia
            (dolist (elem (cdr caminho))
              (dolist (posicao listaAdjacentes)
                (when (equal posicao elem)
                  (setf res (append (cdr caminho) res))
                  (setf flag NIL)
                  (return-from verificaAdjacencia T))))))
        (when flag
          (push caminho novaListaCaminhos))
        (setf flag T))
      (if res
        (progn
          (push posAgreg res)
          (push jogador res)
          (push res novaListaCaminhos)
          (return-from corpo novaListaCaminhos))
      (return-from corpo (push (list jogador posAgreg) listaCaminhos))))))

;----------------------- Funcoes auxiliares Game-Over -----------------------------------;
; setor ( posicao x anel) -> inteiro
; Retorna o terco da posicao
(defun setor (anel pos)
  (truncate pos anel))

; caminho (board x pos x anel x visited x jogador) -> lista de caminho
(defun caminho (board anel pos visited jogador)
  (let* ((adj (adjacentes anel pos (tabuleiro-aneis board)))
	 (posAct (cons anel pos))
	 (newVisited visited))
    (when
      (dolist (posVis visited T)
	(when (equal posAct posVis)
	  (return NIL)))
      (push posAct newVisited)
      (dolist (pAdj adj)
	(when (equal (tabuleiro-peca board (car pAdj) (cdr pAdj)) jogador)
	  (setf newVisited (caminho board (car pAdj) (cdr pAdj) newVisited jogador)))))
    newVisited))

; pode-ganhar? (board x jogador) -> true || false
(defun pode-ganhar?(board jogador)
  (let ((pecas 0)
	 (res NIL)
	 (anelMax (tabuleiro-aneis board))
	 (terco0 NIL)
	 (terco1 NIL)
	 (terco2 NIL))
    (dolist (pos (nth (1- (tabuleiro-aneis board)) board))
      (when (equal jogador pos)
	(push (cons anelMax pecas) res)
	(let ((terco (setor anelMax pecas)))
	  (cond
	    ((= terco 0)
	      (setf terco0 T))
	    ((= terco 1)
	      (setf terco1 T))
	    ((= terco 2)
	      (setf terco2 T)))))
      (incf pecas))
    (if (and terco0 terco1 terco2)
      res
      NIL)))

; path-eval (path) -> true || false
; Precorre o caminho ate encontrar 3 posicoes num anel exterior
(defun path-eval (path nAneis)
  (let ((terco -1)
	 (terco0 NIL)
	 (terco1 NIL)
	 (terco2 NIL))
    (dolist (pos path NIL)
      (when (equal (car pos) nAneis)
        (setf terco (setor (car pos) (cdr pos)))
        (cond
          ((= terco 0)
            (setf terco0 T))
          ((= terco 1)
            (setf terco1 T))
          ((= terco 2)
            (setf terco2 T)))
        (when (and terco0 terco1 terco2)
          (return T))))))

; game-over? (board x jogador) -> true || false
(defun game-over? (board jogador)
  (let ((pos (pode-ganhar? board jogador))
         (visited '())
         (nAneis (tabuleiro-aneis board))
         (result NIL))
    (dolist (par pos)
      (unless (member par visited)
        (push par visited)
        (when (path-eval (caminho board (car par) (cdr par) '() jogador) nAneis)
          (return (setf result 2)))))
    (unless result
      (block full-board?
        (dolist (anel board)
          (dolist (elem anel)
            (when (equal elem '*)
              (return-from full-board? NIL))))
        (setf result 1)))
    result))

; game-over-auto (state x player) -> true || false
; Internamente actualiza os caminhos do argumento (estrutura game-state)
(defun game-over-auto? (state player)
  (let ((paths (game-state-paths state))
        (anelMax (game-state-nAneis state))
        (terco0 NIL)
        (terco1 NIL)
        (terco2 NIL))
    (block check
      (dolist (path paths)
        (when (equal (car path) player)
          (setf terco0 NIL)
          (setf terco1 NIL)
          (setf terco2 NIL)
	      (dolist (elem (cdr path))
	        (when (equal (car elem) anelMax)
	          (let ((terco (truncate (cdr elem) anelMax)))
	            (cond
	              ((and (= terco 0) (not terco0))
	                (setf terco0 T))
	              ((and (= terco 1) (not terco1))
	                (setf terco1 T))
	              ((and (= terco 2) (not terco2))
	                (setf terco2 T))))
	          (when (and terco0 terco1 terco2)
	            (return-from check T))))))
      NIL)))

; legal-moves (state) -> lista
; Retorna uma lista com todos os movimentos permitidos pelo jogo
(defun legal-moves (state)
  (let ((tab (game-state-board state))
	(anel 1)
	(pos 0)
	(res '()))
    (dolist (path tab)
      (dolist (elem path)
	(when (equal elem '*)
	  (push (cons anel pos) res))
	(incf pos))
      (setf pos 0)
      (incf anel))
    res))

; make-move (state x move) -> null
; Internamente executa o movimento do jogador automatico
(defun make-move (state move)
  (let ((anel (car move))
	(pos (cdr move))
	(player (get-current-player state))
    (newPlayers (reverse (game-state-current-player state))))
    (make-game-state
     :board (tabuleiro-poe-peca (game-state-board state) player anel pos)
     :nAneis (game-state-nAneis state)
     :players newPlayers
     :scores (game-state-scores state)
     :times (game-state-times state)
     :terminal? NIL
     :paths (actualizaCaminhos (game-state-paths state) (adjacentes anel pos (game-state-nAneis state)) anel pos player))))

; legal-move-auto? (move x state) -> true || false
(defun legal-move-auto? (move state)
  (member move (legal-moves state) :test #'equal))

; terminal-values (state) -> state
; Retorna os valores de estado para cada jogador
(defun terminal-values (state)
  (mapcar #'(lambda (player) (getf (game-state-scores state) player))
	  (game-state-players state)))

; game-successors (state) -> list
; Retorna a lista com par (move . state) que pode ser alcancado de cada estado.
(defun game-successors (state)
  (mapcar #'(lambda (move) (cons move (make-move state move)))
	  (legal-moves state)))



;-------------------------- Minimax with Cutoff ---------------------------;
; minimax-cutoff-value (state x eval-fn x limit x startplayer) -> accao
(defun minimax-cutoff-value (state eval-fn limit startplayer)
  (cond
    ((game-over-auto? state (get-current-player state)) (list *value-victory* *value-defeat*))
    ((game-over-auto? state (get-previous-player state)) (list *value-defeat* *value-victory*))
	((<= limit 0) (funcall eval-fn state startplayer))
	(t (right-rotate
      (the-biggest
        #'(lambda (values) (first (right-rotate values)))
        (mapcar
          #'(lambda (a+s)
              (swap-current-player (cdr a+s))
              (minimax-cutoff-value (cdr a+s) eval-fn (- limit 1) startplayer))
          (game-successors state)))))))

; minimax-cutoff-decision (state x eval-fn x limit x startplayer) -> accao
; Retorna a melhor accao de acordo com a avaliacao de os ramos ate ao limite
(defun minimax-cutoff-decision (state eval-fn limit startplayer)
  (swap-current-player state)
  (car (the-biggest
        #'(lambda (a+s)
            (first (right-rotate
                    (minimax-cutoff-value (cdr a+s) eval-fn (- limit 1) startplayer))))
        (game-successors state))))

;---------------------------- Procura Alpha-Beta ---------------------------------------------;
;alpha-beta-decision (state x eval-fn x startplayer x &optional limit) -> melhor estimativa accao
; retorna a estimativa da melhor acao aplicando a EVAL-FN
(defun alpha-beta-decision (state eval-fn startplayer &optional (limit 4))
  (labels ((alpha-value (state alpha beta eval-fn limit startplayer)
             (cond
               ((game-over-auto? state (get-current-player state)) (list *value-victory* *value-defeat*))
               ((game-over-auto? state (get-previous-player state)) (list *value-defeat* *value-victory*))
	           ((<= limit 0) (funcall eval-fn state startplayer))
               (t (dolist (a+s (game-successors state)
                             (list alpha (- alpha)))
                     (setq alpha (max alpha
                                   (first (right-rotate
                                            (beta-value (cdr a+s) alpha beta eval-fn (- limit 1) startplayer)))))
                     (when (>= alpha (- beta))
                       (return (list (- beta) beta)))))))
            (beta-value (state alpha beta eval-fn limit startplayer)
              (cond
                ((game-over-auto? state (get-current-player state)) (list *value-victory* *value-defeat*))
                ((game-over-auto? state (get-previous-player state)) (list *value-defeat* *value-victory*))
	            ((<= limit 0) (funcall eval-fn state startplayer))
                (t (dolist (a+s (game-successors state)
                             (list beta (- beta)))
                     (setq beta (max beta
                                  (first (right-rotate
                                           (alpha-value (cdr a+s) alpha beta eval-fn (- limit 1) startplayer)))))
                     (when (>= beta (- alpha))
                       (return (list (- alpha) alpha))))))))
    (swap-current-player state)
    (car (the-biggest
      #'(lambda (a+s)
          (first (right-rotate
                  (alpha-value (cdr a+s) minus-infinity minus-infinity eval-fn (- limit 1) startplayer))))
        (game-successors state)))))

; --------------------- Funcoes de execucao do Jogo Y ---------------------------------- ;

; instancia (func-a x func-b x status) -> (tempo-a x tempo-b x tabuleiro)
(defun instancia (func-a func-b status pa pb)
  (let ((state (init-game-state (get-g-levels status)))
        (board NIL)
        (over? NIL)
        (time-buffer 0))
    (setf board (get-board state))
    (block jogo
      (loop while T
      do
      (escreve-nl "Jogador A")
      (setf time-buffer (get-universal-time))
      (funcall func-a board)
      (set-time-a (+ (- (get-universal-time) time-buffer) (get-time-a state)) state)
      (setf over? (game-over? board 'O))
      (cond
        ((equal over? 2)
          (setf (getf (game-scores status) pa) (1+ (getf (game-scores status) pa)))
          (return-from jogo T))
        ((equal over? 1)
          (return-from jogo T)))
      (escreve-nl "Jogador B")
      (setf time-buffer (get-universal-time))
      (funcall func-b board)
      (set-time-b (+ (- (get-universal-time) time-buffer) (get-time-b state)) state)
      (setf over? (game-over? board 'X))
      (cond
        ((equal over? 2)
          (setf (getf (game-scores status) pb) (1+ (getf (game-scores status) pb)))
          (return-from jogo T))
        ((equal over? 1)
          (return-from jogo T)))))
    (list (get-time-a state) (get-time-b state) board)))


; executa-jogo (aneis x jogador-a x jogador-b) -> lista (instancia1 x instancia2)
(defun executa-jogo (aneis jogador-a jogador-b tempo)
 (let ((status (init-game))
        (ret-value ())
        (pa nil)
        (pb nil))
   (setf pa (get-player-a status))
   (setf pb (get-player-b status))
   (set-g-levels aneis status)
   (escreve-nl "-----Jogo Y-----")
   (escreve-nl "Joga primeiro o Jogador A")
   (escreve-nl "Jogador a -> X")
   (escreve-nl "Jogador b -> O")
   (push (instancia (funcall jogador-a aneis pb tempo) (funcall jogador-b aneis pa tempo) status pb pa) ret-value)
   (escreve-nl "----Novo Jogo----")
   (escreve-nl "Joga primeiro o Jogador B")
   (escreve-nl "Jogador b -> X")
   (escreve-nl "Jogador a -> O")
   (push (instancia (funcall jogador-b aneis pb tempo) (funcall jogador-a aneis pa tempo) status pa pb) ret-value)
   (setf ret-value (reverse ret-value))
   (setf pa (+ (caar ret-value) (cadadr ret-value)))
   (setf pb (+ (cadar ret-value) (caadr ret-value)))
   (cond
     ((and (eq (get-g-scores-a status) (get-g-scores-b status)) (not (equal tempo 0)))
       (cond
         ((> pa pb)
           (escreve "Jogador B ganhou o jogo, (metrica temporal)"))
         ((> pb pa)
           (escreve "Jogador A ganhou o jogo, (metrica temporal)"))
         (t (escreve "Jogo Empatado!"))))
     ((< (get-g-scores-a status) (get-g-scores-b status))
       (escreve "Jogador B ganhou o jogo!!!"))
     ((> (get-g-scores-a status) (get-g-scores-b status))
       (escreve "Jogador A ganhou o jogo"))
     (t (escreve "Jogo empatado")))
   ret-value))

; faz-jogador-manual (aneis x peca x tempo) -> funcao
(defun faz-jogador-manual (aneis peca tempo)
  #'(lambda(tabuleiro)
      (let ((timeout (get-universal-time))
             (anel 0)
             (pos -1))
	(block jogada
	  (cond
	    ((= (tabuleiro-aneis tabuleiro) aneis)
	      (escreve "Anel")
	      (setf anel (le-posicao))
	      (escreve "Posicao")
       (when (not (equal tempo 0))
	      (when (>= (- (get-universal-time) timeout) tempo)
		  (escreve "Tempo expirado")
		(return-from jogada T)))
		(setf pos (le-posicao))
	      (if (legal-move? tabuleiro anel pos)
		(tabuleiro-poe-peca! tabuleiro peca anel pos)
		(escreve-nl "Jogada invalida"))
	      (escreve-tabuleiro tabuleiro))
	    (t
	      (escreve "Tabuleiro invalido para jogada")))))))

; --------------------------------Funcoes auxiliares para Heuristicas (***) -----------------------------;
; evalPieces (state x startPlayer) -> lista (bonus x anti-bonus)
; Os aneis mais exteriores ao tabuleiro tem bonus de pontuacao
(defun evalPieces (state startplayer)
  (let ((anel 1)
        (count-p1 0)
        (count-p2 0))
    (dolist (ring (get-board state))
      (dolist (elem ring)
        (cond
          ((equal elem startplayer)
            (incf count-p1 (* anel *value-piece-ring*)))
          ((equal elem '*))
          (t
            (incf count-p2 (* anel *value-piece-ring*)))))
      (incf anel))
    (- count-p1 count-p2)))


; evalTPieces (state x startPlayer) -> lista (bonus x anti-bonus)
; O penultimo anel nas pecas com posicao (anel * setor) - 1 ganham bonus de pontuacao
(defun evalTPieces (state startplayer)
  (let ((anel (- (tabuleiro-aneis (get-board state)) 1))
         (el 0)
         (board (get-board state))
         (target1 0)
         (target2 0)
         (target3 0)
         (result 0))
    (setf target1 (- anel 1))
    (setf target2 (- (* anel 2) 1))
    (setf target3 (- (* anel 3) 1))
      (dolist (elem (nth (- anel 1) board))
        (cond
          ((and
             (equal elem startplayer)
             (or (= el target1) (= el target2) (= el target3)))
            (setf result *value-piece-ring-1*)))
        (incf el))
    result))

;Para cada caminho, da um bonus incremental por cada peca favorecendo caminhos mais longos
(defun evalPathLength (state startplayer)
  (let ((result 0)
        (paths (game-state-paths state)))
    (dolist (path paths)
      (let ((temp 0)
              (nEl 1))
        (dolist (elem (cdr path))
          (declare (ignore elem))
          (incf temp (* nEl *value-path-elem*))
          (incf nEl))
        (if (equal (car path) startplayer)
          (incf result temp)
          (decf result temp))))
    result))

; -------------------------------- Heuristicas (***) -----------------------------;
; funcao heuristica - 1
(defun eval-f1 (state startplayer)
  (let ((value 0))
    (incf value (evalPieces state startplayer))
    (if (equal startplayer (get-current-player state))
      (list value (- value))
      (list (- value) value))
    ))

; funcao heuristica - 2
(defun eval-f2 (state startplayer)
  (let ((value 0))
    (incf value (evalPieces state startplayer))
    (incf value (evalTPieces state startplayer))
    (if (equal startplayer (get-current-player state))
      (list value (- value))
      (list (- value) value))
    ))

; funcao heuristica - 3
(defun eval-f3 (state startplayer)
  (let ((value 0))
    (incf value (evalPieces state startplayer))
    (incf value (evalTPieces state startplayer))
    (incf value (evalPathLength state startplayer))
    (if (equal startplayer (get-current-player state))
      (list value (- value))
      (list (- value) value))
    ))

(defun transform-tab-path (board)
  (let ((visitados '())
         (result '())
         (el 0)
         (anel 1)
         (temp '()))
  (dolist (ring board)
    (dolist (elem ring)
      (if (or (equal elem '*) (member (cons anel el) visitados :test #'equal))
        (push (cons anel el) visitados)
        (progn
          (setf temp (caminho board anel el '() elem))
          (push (cons elem temp) result)))
      (setf visitados (append temp visitados))
      (incf el))
    (setf el 0)
    (incf anel))
    result))

;IF Remaining Time (- limit spent) larger than time required for next iteration
;return T else NIL
;
(defun time-available? (limit spent moveN estimateTime)
  (if (>= (/ moveN 2) 10)
    (> (- limit spent) (* 4 estimateTime))
    (> (- limit spent) (* (- 15 (float (/ moveN 2))) estimateTime))))


; jogador automatico
(defun faz-jogador-automatico (aneis peca tempo)
  (let ((moveN 0)
        (maxlimit (nPosicoes aneis)))
    #'(lambda (tabuleiro)
        (let ((state (init-game-state aneis))
               (decision '())
               (limit 1)
               (time1 0)
               (time2 0)
               (iterTime 0)
               (time-out 0))
          (set-board tabuleiro state)
          (setf (game-state-paths state) (transform-tab-path tabuleiro))
          (setf (game-state-nAneis state) (tabuleiro-aneis tabuleiro))
          (cond
            ((equal 0 tempo)
              (setf limit (- maxLimit moveN))
              (setf decision (alpha-beta-decision state #'eval-f3 peca limit)))
            (t
              (loop while (and
                            (< limit (- maxLimit moveN))
                            (time-available? (* tempo internal-time-units-per-second) time-out moveN iterTime))
                do
                (setf time1 (get-internal-real-time))
                (setf decision (alpha-beta-decision state #'eval-f3 peca limit))
                (setf time2 (get-internal-real-time))
                (incf limit)
                (incf time-out (setf iterTime (- time2 time1))))))
                (escreve "Anel =")
              (print-var (car decision))
              (escreve-nl "")
              (escreve "Posicao =")
              (print-var (cdr decision))
              (escreve-nl "")
              (tabuleiro-poe-peca! tabuleiro peca (car decision) (cdr decision))
              (incf moveN 2)
              (escreve-tabuleiro tabuleiro)))))

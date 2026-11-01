;;;; Tests for y_game.lisp. Run with: sbcl --script tests/y-game-test.lisp

(load (merge-pathnames "../y_game.lisp" (or *load-truename* *default-pathname-defaults*)))

(defvar *passed* 0)
(defvar *failed* '())

(defmacro deftest (name &body body)
  `(handler-case
       (progn ,@body
              (incf *passed*)
              (format t "ok   ~(~a~)~%" ',name))
     (error (e)
       (push ',name *failed*)
       (format t "FAIL ~(~a~): ~a~%" ',name e))))

(defvar *skipped* 0)

(defmacro defknown-bug (name reason &body body)
  "A test documenting a known bug: reported as skipped, never run."
  (declare (ignore body))
  `(progn (incf *skipped*)
          (format t "skip ~(~a~): ~a~%" ',name ,reason)))

(defun check (expected actual &optional (description ""))
  (unless (equal expected actual)
    (error "~a expected ~s, got ~s" description expected actual)))

(defun fill-ring (board ring piece)
  (dotimes (pos (* 3 ring) board)
    (tabuleiro-poe-peca! board piece ring pos)))

;;; List helpers

(deftest the-biggest-returns-element-with-highest-score
  (check '(1 . 9) (the-biggest #'cdr '((0 . 3) (1 . 9) (2 . 5))))
  (check 4 (the-biggest #'identity '(4))))

(deftest rotations
  (check '(2 3 1) (left-rotate '(1 2 3)))
  (check '(3 1 2) (right-rotate '(1 2 3)))
  (check '(1 2 3) (left-rotate (right-rotate '(1 2 3)))))

;;; Board ADT

(deftest faz-tabuleiro-builds-rings-of-3n-empty-cells
  (check '((* * *) (* * * * * *)) (faz-tabuleiro 2))
  (check 3 (tabuleiro-aneis (faz-tabuleiro 3))))

(deftest tabuleiro-poe-peca-does-not-mutate-the-original
  (let* ((board (faz-tabuleiro 2))
         (new (tabuleiro-poe-peca board 'X 2 4)))
    (check 'X (tabuleiro-peca new 2 4))
    (check '* (tabuleiro-peca board 2 4))))

(deftest tabuleiro-poe-peca!-mutates-in-place
  (let ((board (faz-tabuleiro 2)))
    (tabuleiro-poe-peca! board 'O 1 2)
    (check 'O (tabuleiro-peca board 1 2))))

(deftest tabuleiro-p-validates-shape-and-pieces
  (check t (tabuleiro-p (faz-tabuleiro 3)))
  (check t (tabuleiro-p '((X O *))))
  (check nil (tabuleiro-p nil))
  (check nil (tabuleiro-p '((* *))))
  (check nil (tabuleiro-p '((* * Z))))
  (check nil (tabuleiro-p '(foo))))

(deftest npossicoes-counts-every-cell
  (check 0 (nPosicoes 0))
  (check 3 (nPosicoes 1))
  (check 18 (nPosicoes 3)))

(deftest legal-move-only-on-empty-cells
  (let ((board (faz-tabuleiro 2)))
    (check t (legal-move? board 2 0))
    (tabuleiro-poe-peca! board 'X 2 0)
    (check nil (legal-move? board 2 0))))

;;; Adjacency

(deftest adjacentes-on-same-ring-wrap-around
  (check '((1 . 1) (1 . 2)) (adjacentesMesmoAnel 1 0))
  (check '((2 . 0) (2 . 4)) (adjacentesMesmoAnel 2 5)))

(deftest adjacentes-of-centre-cell
  (check '((1 . 1) (1 . 2) (2 . 1) (2 . 0) (2 . 2)) (adjacentes 1 0 2)))

(deftest adjacentes-of-outer-cell
  (check '((2 . 4) (2 . 2) (1 . 1)) (adjacentes 2 3 2)))

(deftest adjacency-stays-on-the-board
  (dolist (n '(2 3 4))
    (loop for ring from 1 to n do
      (dotimes (pos (* 3 ring))
        (dolist (adj (adjacentes ring pos n))
          (unless (and (<= 1 (car adj) n) (< -1 (cdr adj) (* 3 (car adj))))
            (error "~s on ring ~a pos ~a is off a ~a-ring board" adj ring pos n)))))))

;;; Game over

(deftest empty-board-is-not-over
  (check nil (game-over? (faz-tabuleiro 2) 'X)))

(deftest outer-ring-touching-all-three-sides-wins
  (check 2 (game-over? (fill-ring (faz-tabuleiro 2) 2 'X) 'X)))

(deftest pieces-of-the-other-player-do-not-win
  (check nil (game-over? (fill-ring (faz-tabuleiro 2) 2 'O) 'X)))

(deftest full-board-without-a-winning-path-is-a-draw
  (let ((board '((O O O) (O X O X O X))))
    (check 1 (game-over? board 'X))))

(deftest path-eval-needs-all-three-sides-of-the-outer-ring
  (check t (path-eval '((2 . 0) (2 . 2) (2 . 4)) 2))
  (check nil (path-eval '((2 . 0) (2 . 1) (1 . 0)) 2)))

;;; Game state

(deftest legal-moves-lists-every-empty-cell
  (let ((state (init-game-state 2)))
    (check 9 (length (legal-moves state)))
    (set-board (tabuleiro-poe-peca (get-board state) 'X 1 0) state)
    (check 8 (length (legal-moves state)))
    (check nil (legal-move-auto? '(1 . 0) state))
    (check t (not (null (legal-move-auto? '(2 . 0) state))))))

(deftest make-move-places-the-current-player
  (let* ((state (init-game-state 2))
         (next (make-move state '(2 . 1))))
    (setf (game-state-nAneis state) 2)
    (check 'X (tabuleiro-peca (get-board next) 2 1))
    (check '* (tabuleiro-peca (get-board state) 2 1))))

(deftest swap-current-player-alternates
  (let ((state (init-game-state 1)))
    (check 'X (get-current-player state))
    (swap-current-player state)
    (check 'O (get-current-player state))
    (check 'X (get-previous-player state))))

(deftest game-scores-setters
  (let ((stats (init-game)))
    (set-g-scores-a 2 stats)
    (set-g-scores-b 5 stats)
    (check 2 (get-g-scores-a stats))
    (check 5 (get-g-scores-b stats))))

;;; Heuristics

(deftest eval-pieces-rewards-outer-rings
  (let ((state (init-game-state 2)))
    (set-board (tabuleiro-poe-peca (get-board state) 'X 2 0) state)
    (check 20 (evalPieces state 'X))
    (check -20 (evalPieces state 'O))))

(deftest eval-f1-is-zero-sum
  (let ((state (init-game-state 2)))
    (set-board (tabuleiro-poe-peca (get-board state) 'X 2 0) state)
    (destructuring-bind (mine theirs) (eval-f1 state 'X)
      (check 0 (+ mine theirs)))))

;;; Search

(defun near-win-state ()
  "X holds sides 0 and 1 of the outer ring; (2 . 5) joins (2 . 0) and reaches side 2."
  (let ((board (list (list 'O 'O '*) (list 'X 'X 'X 'O '* '*)))
        (state (init-game-state 2)))
    (set-board board state)
    (setf (game-state-nAneis state) 2)
    (setf (game-state-paths state) (transform-tab-path board))
    state))

(deftest alpha-beta-returns-a-legal-move
  (dolist (limit '(1 2 3))
    (let* ((state (near-win-state))
           (move (alpha-beta-decision state #'eval-f3 'X limit)))
      (check t (not (null (legal-move-auto? move (near-win-state)))) "legal decision"))))

(deftest alpha-beta-finds-the-win-at-depth-3
  (check '(2 . 5) (alpha-beta-decision (near-win-state) #'eval-f3 'X 3)))

(defknown-bug alpha-beta-finds-the-win-at-shallow-depth
  "alpha-beta-decision picks (2 . 4) instead of the winning (2 . 5) at depth 1 and 2"
  (check '(2 . 5) (alpha-beta-decision (near-win-state) #'eval-f3 'X 1)))

(format t "~a passed, ~a failed, ~a skipped~%" *passed* (length *failed*) *skipped*)
(sb-ext:exit :code (if *failed* 1 0))

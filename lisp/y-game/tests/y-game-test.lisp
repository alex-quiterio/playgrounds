;;;; Tests for the game of Y. Run with: sbcl --script lisp/y-game/tests/y-game-test.lisp

(load (merge-pathnames "../y-game.lisp" (or *load-truename* *default-pathname-defaults*)))

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

(defun check (expected actual &optional (description ""))
  (unless (equal expected actual)
    (error "~a expected ~s, got ~s" description expected actual)))

(defun fill-ring (board ring piece)
  (dotimes (pos (* 3 ring) board)
    (board-place-piece! board piece ring pos)))

(defun quietly (thunk)
  (let ((*standard-output* (make-broadcast-stream)))
    (funcall thunk)))

;;; Board

(deftest the-biggest-returns-the-first-element-with-the-highest-score
  (check '(1 . 9) (the-biggest #'cdr '((0 . 3) (1 . 9) (2 . 5) (3 . 9))))
  (check 4 (the-biggest #'identity '(4))))

(deftest make-board-builds-rings-of-3n-empty-cells
  (check '((* * *) (* * * * * *)) (make-board 2))
  (check 3 (board-rings (make-board 3))))

(deftest board-place-piece-does-not-mutate-the-original
  (let* ((board (make-board 2))
         (new (board-place-piece board 'X 2 4)))
    (check 'X (board-piece new 2 4))
    (check '* (board-piece board 2 4))))

(deftest board-place-piece!-mutates-in-place
  (let ((board (make-board 2)))
    (board-place-piece! board 'O 1 2)
    (check 'O (board-piece board 1 2))))

(deftest board-p-validates-shape-and-pieces
  (check t (board-p (make-board 3)))
  (check t (board-p '((X O *))))
  (check nil (board-p nil))
  (check nil (board-p '((* *))))
  (check nil (board-p '((* * Z))))
  (check nil (board-p '(foo))))

(deftest legal-move-only-on-empty-cells
  (let ((board (make-board 2)))
    (check t (legal-move? board 2 0))
    (board-place-piece! board 'X 2 0)
    (check nil (legal-move? board 2 0))))

;;; Neighbours

(deftest neighbours-on-the-same-ring-wrap-around
  (check '((1 . 1) (1 . 2)) (same-ring-neighbours 1 0))
  (check '((2 . 0) (2 . 4)) (same-ring-neighbours 2 5)))

(deftest neighbours-of-centre-cell
  (check '((1 . 1) (1 . 2) (2 . 1) (2 . 0) (2 . 2)) (neighbours 1 0 2)))

(deftest neighbours-of-outer-cell
  (check '((2 . 4) (2 . 2) (1 . 1)) (neighbours 2 3 2)))

(deftest neighbours-stay-on-the-board
  (dolist (n '(2 3 4))
    (loop for ring from 1 to n do
      (dotimes (pos (* 3 ring))
        (dolist (adj (neighbours ring pos n))
          (unless (and (<= 1 (car adj) n) (< -1 (cdr adj) (* 3 (car adj))))
            (error "~s on ring ~a pos ~a is off a ~a-ring board" adj ring pos n)))))))

(deftest neighbours-are-symmetric
  (dolist (n '(2 3 4))
    (loop for ring from 1 to n do
      (dotimes (pos (* 3 ring))
        (dolist (adj (neighbours ring pos n))
          (unless (member (cons ring pos) (neighbours (car adj) (cdr adj) n) :test #'equal)
            (error "~s lists ~s, but not the other way round" (cons ring pos) adj)))))))

;;; Game over

(deftest empty-board-is-not-over
  (check nil (game-over? (make-board 2) 'X)))

(deftest outer-ring-touching-all-three-sides-wins
  (check 2 (game-over? (fill-ring (make-board 2) 2 'X) 'X)))

(deftest pieces-of-the-other-player-do-not-win
  (check nil (game-over? (fill-ring (make-board 2) 2 'O) 'X)))

(deftest full-board-without-a-winning-path-is-a-draw
  (let ((board '((O O O) (O X O X O X))))
    (check 1 (game-over? board 'X))))

(deftest unconnected-pieces-on-all-three-sides-do-not-win
  ;; X holds one cell on each side of the outer ring, but they are not connected.
  (let ((board (list (list 'O 'O 'O)
                     (list 'X 'O 'X 'O 'X 'O))))
    (check nil (equal 2 (game-over? board 'X)))))

(deftest touches-all-sides-needs-all-three-sides-of-the-outer-ring
  (check t (touches-all-sides? '((2 . 0) (2 . 2) (2 . 4)) 2))
  (check nil (touches-all-sides? '((2 . 0) (2 . 1) (1 . 0)) 2)))

;;; Game state

(defun state-of (board &optional (player 'X))
  (new-state board player))

(defun near-win-state ()
  "X holds sides 0 and 1 of the outer ring; (2 . 5) joins (2 . 0) and reaches side 2."
  (state-of (list (list 'O 'O '*) (list 'X 'X 'X 'O '* '*))))

(defun block-state ()
  "O holds sides 0 and 1 of the outer ring and wins with (2 . 5) unless X takes it."
  (state-of (list (list 'X 'X '*) (list 'O 'O 'O 'X '* '*))))

(deftest new-state-reads-rings-and-groups-from-the-board
  (let ((state (state-of (list (list 'X '* '*) (list 'X '* '* '* '* 'O)))))
    (check 2 (state-ring-count state))
    (check 2 (length (state-paths state)))
    (check '(2 1) (sort (mapcar (lambda (path) (length (cdr path))) (state-paths state)) #'>))))

(deftest legal-moves-lists-every-empty-cell
  (let ((state (state-of (make-board 2))))
    (check 9 (length (legal-moves state)))
    (let ((after (state-of (board-place-piece (state-board state) 'X 1 0))))
      (check 8 (length (legal-moves after)))
      (check nil (member '(1 . 0) (legal-moves after) :test #'equal)))))

(deftest make-move-places-the-player-to-move
  (let* ((state (state-of (make-board 2)))
         (next (make-move state '(2 . 1))))
    (check 'X (board-piece (state-board next) 2 1))
    (check '* (board-piece (state-board state) 2 1))))

(deftest make-move-hands-the-turn-to-the-other-player
  (let* ((state (state-of (make-board 2)))
         (next (make-move state '(2 . 0)))
         (after (make-move next '(2 . 1))))
    (check 'O (state-player next))
    (check 'X (board-piece (state-board after) 2 0))
    (check 'O (board-piece (state-board after) 2 1))
    (check 'X (state-player after))))

(deftest make-move-keeps-the-paths-in-step-with-the-board
  (let ((state (state-of (make-board 3))))
    (dolist (move '((3 . 0) (2 . 0) (3 . 1) (1 . 0) (3 . 8) (3 . 4)))
      (setf state (make-move state move))
      (check (length (board-paths (state-board state))) (length (state-paths state))
             (format nil "after ~s:" move)))))

;;; Heuristics

(deftest eval-pieces-rewards-outer-rings
  (let ((state (state-of (board-place-piece (make-board 2) 'X 2 0))))
    (check 20 (eval-pieces state 'X))
    (check -20 (eval-pieces state 'O))))

(deftest eval-f1-is-zero-sum
  (let ((state (state-of (board-place-piece (make-board 2) 'X 2 0))))
    (check 0 (+ (eval-f1 state 'X) (eval-f1 state 'O)))))

(deftest eval-path-length-grows-with-the-path
  ;; One X path of 3 cells: 5 + 10 + 15.
  (check 30 (eval-path-length (state-of (list (list 'X '* '*) (list 'X 'X '* '* '* '*))) 'X)))

;;; Search

(deftest search-does-not-mutate-the-state
  (let ((state (near-win-state)))
    (alpha-beta-decision state #'eval-f3 'X 3)
    (check 'X (state-player state))
    (check '((O O *) (X X X O * *)) (state-board state))))

(deftest alpha-beta-returns-a-legal-move
  (dolist (limit '(1 2 3 4))
    (let ((move (alpha-beta-decision (state-of (make-board 2)) #'eval-f3 'O limit)))
      (check t (not (null (member move (legal-moves (state-of (make-board 2))) :test #'equal)))
             "legal decision"))))

(deftest alpha-beta-takes-the-winning-move-at-every-depth
  (dolist (limit '(1 2 3 4 5))
    (check '(2 . 5) (alpha-beta-decision (near-win-state) #'eval-f3 'X limit)
           (format nil "depth ~a:" limit))))

(deftest alpha-beta-blocks-the-opponents-winning-move
  (dolist (limit '(2 3 4))
    (check '(2 . 5) (alpha-beta-decision (block-state) #'eval-f3 'X limit)
           (format nil "depth ~a:" limit))))

(deftest alpha-beta-works-for-either-piece
  ;; Same position with the pieces swapped: O must take (2 . 5).
  (check '(2 . 5) (alpha-beta-decision (block-state) #'eval-f3 'O 1)))

(deftest minimax-takes-the-winning-move
  (dolist (limit '(1 2 3))
    (check '(2 . 5) (minimax-cutoff-decision (near-win-state) #'eval-f3 limit 'X)
           (format nil "depth ~a:" limit))))

(deftest alpha-beta-and-minimax-agree-on-the-value
  (dolist (board (list (make-board 2)
                       (list (list 'X '* '*) (list '* 'O '* '* '* '*))
                       (list (list 'X 'X '*) (list 'O 'O 'O 'X '* '*))))
    (dolist (player '(X O))
      (dolist (limit '(1 2 3))
        (let ((root (root-state (state-of board) player)))
          (check (minimax-cutoff-value root #'eval-f3 limit player)
                 (alpha-beta-value root minus-infinity infinity #'eval-f3 limit player)
                 (format nil "~a ~a depth ~a:" board player limit)))))))

;;; Players and matches

;; A player that plays the first cell of its script that is still empty.
(defun scripted-player (script)
  (lambda (rings piece time-limit)
    (declare (ignore rings time-limit))
    (lambda (board)
      (let ((move (or (find-if (lambda (cell) (legal-move? board (car cell) (cdr cell))) script)
                      (first (legal-moves (state-of board))))))
        (board-place-piece! board piece (car move) (cdr move))))))

;; On 2 rings these four cells connect all three sides: (2 . 5) is on side 2 and
;; next to (2 . 0) on side 0, which reaches (2 . 2) on side 1 through (1 . 0).
(defparameter *winner* (scripted-player '((2 . 0) (2 . 5) (1 . 0) (2 . 2))))
(defparameter *loser* (scripted-player '((2 . 1) (2 . 3) (2 . 4) (1 . 1) (1 . 2))))

(deftest automatic-player-moves-on-an-almost-full-board
  ;; Only one cell left: the player must still find a move.
  (let ((board (list (list '* 'X 'O) (list 'O 'X 'X 'X 'O 'O))))
    (quietly (lambda () (funcall (make-automatic-player 2 'O 1) board)))
    (check 'O (board-piece board 1 0))))

(deftest automatic-player-takes-the-win
  (let ((board (list (list 'O 'O '*) (list 'X 'X 'X 'O '* '*))))
    (quietly (lambda () (funcall (make-automatic-player 2 'X 1) board)))
    (check 'X (board-piece board 2 5))
    (check 2 (game-over? board 'X))))

(deftest the-first-player-plays-x
  (multiple-value-bind (round winner)
      (quietly (lambda () (play-round (funcall *winner* 2 'X 0) (funcall *loser* 2 'O 0) 2)))
    (check :first winner)
    (check 2 (game-over? (third round) 'X))))

(deftest the-second-player-can-win-the-round
  (multiple-value-bind (round winner)
      (quietly (lambda () (play-round (funcall *loser* 2 'X 0) (funcall *winner* 2 'O 0) 2)))
    (check :second winner)
    (check 2 (game-over? (third round) 'O))))

(deftest the-match-goes-to-the-player-who-won-more-rounds
  (flet ((verdict (a b)
           (with-output-to-string (*standard-output*)
             (play-match 2 a b 0))))
    (check t (not (null (search "Player A won the match" (verdict *winner* *loser*)))))
    (check t (not (null (search "Player B won the match" (verdict *loser* *winner*)))))))

(deftest automatic-players-finish-a-match
  (dolist (rings '(2 3))
    (let ((result (quietly (lambda ()
                             (play-match rings #'make-automatic-player #'make-automatic-player 1)))))
      (check 2 (length result) (format nil "~a rings:" rings))
      (dolist (round result)
        (check t (board-p (third round)) "final board")))))

(format t "~a passed, ~a failed~%" *passed* (length *failed*))
(sb-ext:exit :code (if *failed* 1 0))

;;;; Specs for players.lisp. Run with: sbcl --script lisp/y-game/tests/players-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defun play-manually (player board typed)
  "Runs the manual player on the board with TYPED as its input, returning what it printed."
  (with-input-from-string (*standard-input* typed)
    (with-output-to-string (*standard-output*)
      (funcall player board))))

;;; Manual player

(deftest manual-player-places-the-typed-move
  (let ((board (make-board 2)))
    (play-manually (make-manual-player 2 'O 0) board "2 3")
    (check 'O (board-piece board 2 3))))

(deftest manual-player-refuses-an-occupied-cell
  (let* ((board (board-place-piece (make-board 2) 'X 2 3))
         (output (play-manually (make-manual-player 2 'O 0) board "2 3")))
    (check 'X (board-piece board 2 3))
    (check-true (search "Invalid move" output))))

(deftest manual-player-refuses-a-board-of-the-wrong-size
  (let* ((board (make-board 2))
         (output (play-manually (make-manual-player 3 'O 0) board "")))
    (check (make-board 2) board)
    (check-true (search "Board does not fit this player" output))))

;;; Time budget

(deftest time-available-keeps-a-bigger-reserve-early-in-the-game
  ;; Before move 20 it wants (15 - moves/2) times the last search's time left.
  (check t (time-available? 100 0 0 5))   ; 100 > 75
  (check nil (time-available? 100 0 0 7)) ; 100 < 105
  (check t (time-available? 100 0 10 6))) ; 100 > 60

(deftest time-available-late-in-the-game-wants-four-searches-left
  (check t (time-available? 100 60 20 9))     ; 40 > 36
  (check nil (time-available? 100 60 20 11))) ; 40 < 44

;;; Automatic player

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

(deftest automatic-player-without-a-time-limit-searches-to-the-end
  (let ((board (list (list 'X 'X '*) (list 'O 'O 'O 'X '* '*))))
    (quietly (lambda () (funcall (make-automatic-player 2 'X 0) board)))
    (check 'X (board-piece board 2 5) "blocks O's winning cell")))

(deftest automatic-player-says-its-move
  (let* ((board (make-board 2))
         (output (with-output-to-string (*standard-output*)
                   (funcall (make-automatic-player 2 'X 1) board))))
    (check-true (search "Ring =" output))
    (check-true (search "Position =" output))
    (check 8 (count '* (apply #'append board)) "exactly one piece placed")))

(end-of-tests)

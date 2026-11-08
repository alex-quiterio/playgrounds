;;;; Specs for match.lisp. Run with: sbcl --script lisp/y-game/tests/match-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defun verdict (player-a player-b)
  "What play-match prints at the end, for a match on 2 rings without a time limit."
  (let ((output (with-output-to-string (*standard-output*)
                  (play-match 2 player-a player-b 0))))
    (subseq output (1+ (position #\Newline output :from-end t)))))

;;; Rounds

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

(deftest a-round-can-end-without-a-winner
  ;; Both players chase the same cells, and neither connects all three sides.
  (multiple-value-bind (round winner)
      (quietly (lambda () (play-round (funcall *winner* 2 'X 0) (funcall *winner* 2 'O 0) 2)))
    (check nil winner)
    (check t (full-board? (third round)))))

(deftest a-round-lists-both-times-and-the-final-board
  (let ((round (quietly (lambda () (play-round (funcall *winner* 2 'X 0) (funcall *loser* 2 'O 0) 2)))))
    (check 3 (length round))
    (check-true (and (integerp (first round)) (integerp (second round))))
    (check t (board-p (third round)))))

;;; Matches

(deftest the-match-goes-to-the-player-who-won-more-rounds
  (check "\"Player A won the match\"" (verdict *winner* *loser*))
  (check "\"Player B won the match\"" (verdict *loser* *winner*)))

(deftest one-round-each-is-a-draw
  ;; *loser* against itself: whoever moves first wins, so each player wins once.
  (check "\"The match is a draw\"" (verdict *loser* *loser*)))

(deftest no-winner-in-either-round-is-a-draw
  (check "\"The match is a draw\"" (verdict *winner* *winner*)))

(deftest automatic-players-finish-a-match
  (dolist (rings '(2 3))
    (let ((result (quietly (lambda ()
                             (play-match rings #'make-automatic-player #'make-automatic-player 1)))))
      (check 2 (length result) (format nil "~a rings:" rings))
      (dolist (round result)
        (check t (board-p (third round)) "final board")))))

(end-of-tests)

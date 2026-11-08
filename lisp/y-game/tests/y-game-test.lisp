;;;; Specs for y-game.lisp, the file that loads the whole game, and for playing a
;;;; game end to end. Run with: sbcl --script lisp/y-game/tests/y-game-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defparameter *y-game-file*
  (truename (merge-pathnames "../y-game.lisp" (or *load-truename* *default-pathname-defaults*))))

(defun load-y-game-from (directory)
  "Loads y-game.lisp with DIRECTORY as the current directory, quietly."
  (let ((*default-pathname-defaults* (pathname directory))
        (*error-output* (make-broadcast-stream)))
    (quietly (lambda () (load *y-game-file*)))))

(deftest loading-y-game-loads-every-part
  ;; One function from each file it loads.
  (dolist (name '(say               ; io.lisp
                  make-board        ; board.lisp
                  new-state         ; state.lisp
                  eval-f3           ; heuristics.lisp
                  alpha-beta-decision ; search.lisp
                  make-automatic-player ; players.lisp
                  play-match))      ; match.lisp
    (check-true (fboundp name) (format nil "~(~a~) defined:" name))))

(deftest y-game-loads-from-any-directory-and-more-than-once
  ;; It finds its files next to itself, not in the current directory.
  (check t (load-y-game-from "/"))
  (check t (load-y-game-from (user-homedir-pathname)))
  (check 2 (game-over? (fill-ring (make-board 2) 2 'X) 'X) "still works after reloading"))

(deftest the-readme-example-plays-a-whole-match
  ;; (play-match rings player-a player-b time-limit), here with two computer players.
  (let* ((output nil)
         (rounds nil))
    (setf output (with-output-to-string (*standard-output*)
                   (setf rounds (play-match 2 #'make-automatic-player #'make-automatic-player 1))))
    (check 2 (length rounds))
    (dolist (round rounds)
      (let ((board (third round)))
        (check-true (or (eql 2 (game-over? board 'X))
                        (eql 2 (game-over? board 'O))
                        (full-board? board))
                    "each round ends with a winner or a full board")))
    (check-true (search "-----Game of Y-----" output))
    (check-true (search "----New game----" output))
    (check-true (or (search "won the match" output) (search "draw" output)) "a verdict")))

(deftest a-computer-beats-a-scripted-loser-on-a-bigger-board
  ;; On 3 rings *loser*'s script is useless, so it plays the first empty cell
  ;; after a few moves; the computer must still win both rounds.
  (let ((output (with-output-to-string (*standard-output*)
                  (play-match 3 #'make-automatic-player *loser* 1))))
    (check-true (search "Player A won the match" output))))

(end-of-tests)

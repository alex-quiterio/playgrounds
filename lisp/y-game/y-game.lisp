;;;; The game of Y on a ring board, with a minimax / alpha-beta computer player.
;;;;
;;;; Load this file to load the whole game:
;;;;   sbcl --load y-game.lisp
;;;;   * (play-match 3 #'make-manual-player #'make-automatic-player 5)

(dolist (file '("io" "board" "state" "heuristics" "search" "players" "match"))
  (load (merge-pathnames (make-pathname :name file :type "lisp")
                         (or *load-truename* *default-pathname-defaults*))))

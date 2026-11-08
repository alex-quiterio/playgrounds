;;;; Specs for search.lisp. Run with: sbcl --script lisp/y-game/tests/search-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(deftest the-biggest-returns-the-first-element-with-the-highest-score
  (check '(1 . 9) (the-biggest #'cdr '((0 . 3) (1 . 9) (2 . 5) (3 . 9))))
  (check 4 (the-biggest #'identity '(4))))

(deftest root-state-sets-the-player-without-changing-the-original
  (let* ((state (state-of (make-board 2) 'X))
         (root (root-state state 'O)))
    (check 'O (state-player root))
    (check 'X (state-player state))))

(deftest search-value-of-a-win-depends-on-who-won
  ;; X has just filled the outer ring, so O is to move and X has won.
  (let ((state (state-of (fill-ring (make-board 2) 2 'X) 'O)))
    (check (+ *value-victory* 3) (search-value state #'eval-f3 3 'X))
    (check (- *value-defeat* 3) (search-value state #'eval-f3 3 'O))))

(deftest search-value-of-a-full-board-without-a-winner-is-zero
  (check 0 (search-value (state-of '((X O X) (O X O X O X)) 'X) #'eval-f3 3 'X)))

(deftest search-value-at-the-depth-limit-is-the-heuristic
  (let ((state (state-of (board-place-piece (make-board 2) 'X 2 0) 'O)))
    (check (eval-f3 state 'X) (search-value state #'eval-f3 0 'X))))

(deftest search-value-is-nil-while-the-search-should-go-on
  (check nil (search-value (state-of (make-board 2)) #'eval-f3 2 'X)))

(deftest quicker-wins-are-worth-more
  (let ((state (state-of (fill-ring (make-board 2) 2 'X) 'O)))
    (check-true (> (search-value state #'eval-f3 3 'X) (search-value state #'eval-f3 1 'X)))))

(deftest search-does-not-mutate-the-state
  (let ((state (near-win-state)))
    (alpha-beta-decision state #'eval-f3 'X 3)
    (minimax-cutoff-decision state #'eval-f3 2 'X)
    (check 'X (state-player state))
    (check '((O O *) (X X X O * *)) (state-board state))))

(deftest alpha-beta-returns-a-legal-move
  (dolist (limit '(1 2 3 4))
    (let ((move (alpha-beta-decision (state-of (make-board 2)) #'eval-f3 'O limit)))
      (check-true (member move (legal-moves (state-of (make-board 2))) :test #'equal)
                  (format nil "depth ~a:" limit)))))

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

(end-of-tests)

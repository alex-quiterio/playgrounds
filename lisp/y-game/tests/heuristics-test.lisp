;;;; Specs for heuristics.lisp. Run with: sbcl --script lisp/y-game/tests/heuristics-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(deftest eval-pieces-rewards-outer-rings
  (let ((state (state-of (board-place-piece (make-board 2) 'X 2 0))))
    (check 20 (eval-pieces state 'X))
    (check -20 (eval-pieces state 'O))))

(deftest eval-pieces-counts-the-opponent-against
  (let ((state (state-of (list (list 'O '* '*) (list 'X 'X '* '* '* '*)))))
    (check 30 (eval-pieces state 'X)) ; 20 + 20 for X, 10 against
    (check -30 (eval-pieces state 'O))))

(deftest eval-corner-pieces-rewards-the-end-of-a-side-one-ring-in
  ;; On 3 rings the second-to-last ring is ring 2; its sides end at positions 1, 3 and 5.
  (dolist (pos '(1 3 5))
    (check 200 (eval-corner-pieces (state-of (board-place-piece (make-board 3) 'X 2 pos)) 'X)
           (format nil "X at (2 . ~a):" pos)))
  (check 0 (eval-corner-pieces (state-of (board-place-piece (make-board 3) 'X 2 0)) 'X))
  (check 0 (eval-corner-pieces (state-of (board-place-piece (make-board 3) 'O 2 1)) 'X)))

(deftest eval-path-length-grows-with-the-path
  ;; One X path of 3 cells: 5 + 10 + 15.
  (let ((state (state-of (list (list 'X '* '*) (list 'X 'X '* '* '* '*)))))
    (check 30 (eval-path-length state 'X))
    (check -30 (eval-path-length state 'O))))

(deftest eval-f1-is-zero-sum
  (let ((state (state-of (board-place-piece (make-board 2) 'X 2 0))))
    (check 0 (+ (eval-f1 state 'X) (eval-f1 state 'O)))))

(deftest eval-f2-and-f3-add-the-other-heuristics
  (let ((state (state-of (list (list '* '* '* ) (list 'X 'X '* '* '* '*) (make-list 9 :initial-element '*)))))
    (check (+ (eval-pieces state 'X) (eval-corner-pieces state 'X)) (eval-f2 state 'X))
    (check (+ (eval-f2 state 'X) (eval-path-length state 'X)) (eval-f3 state 'X))
    (check-true (> (eval-f3 state 'X) (eval-f1 state 'X)) "the corner and path bonuses count")))

(end-of-tests)

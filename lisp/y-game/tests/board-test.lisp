;;;; Specs for board.lisp. Run with: sbcl --script lisp/y-game/tests/board-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defun same-cells (a b)
  (and (subsetp a b :test #'equal) (subsetp b a :test #'equal)))

;;; Cells and pieces

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

(deftest print-board-prints-one-ring-per-line-with-a-gap-after-each-side
  (let ((board (board-place-piece (make-board 2) 'X 2 3)))
    (check (format nil "* * * ~%***X**~%")
           (with-output-to-string (*standard-output*) (print-board board)))))

(deftest print-board-ignores-something-that-is-not-a-board
  (check "" (with-output-to-string (*standard-output*) (print-board '((* *))))))

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

;;; Groups and sides

(deftest sector-says-which-side-of-the-ring-a-cell-is-on
  (check 0 (sector 2 1))
  (check 1 (sector 2 3))
  (check 2 (sector 3 8)))

(deftest connected-cells-finds-the-whole-group
  (let ((board (list (list 'X '* '*) (list 'X 'X '* '* '* 'O))))
    (check-true (same-cells '((1 . 0) (2 . 0) (2 . 1)) (connected-cells board 1 0 '() 'X)))
    (check '((2 . 5)) (connected-cells board 2 5 '() 'O))))

(deftest outer-ring-cells-lists-a-players-cells-on-the-outer-ring
  (let ((board (list (list 'X '* '*) (list 'X '* 'X '* '* 'O))))
    (check '((2 . 0) (2 . 2)) (outer-ring-cells board 'X))
    (check '((2 . 5)) (outer-ring-cells board 'O))))

(deftest touches-all-sides-needs-all-three-sides-of-the-outer-ring
  (check t (touches-all-sides? '((2 . 0) (2 . 2) (2 . 4)) 2))
  (check nil (touches-all-sides? '((2 . 0) (2 . 1) (1 . 0)) 2))
  (check nil (touches-all-sides? '((1 . 0) (1 . 1) (1 . 2)) 2)))

(deftest full-board-only-without-empty-cells
  (check nil (full-board? (make-board 2)))
  (check t (full-board? (fill-ring (fill-ring (make-board 2) 1 'O) 2 'X))))

;;; Game over

(deftest empty-board-is-not-over
  (check nil (game-over? (make-board 2) 'X)))

(deftest outer-ring-touching-all-three-sides-wins
  (check 2 (game-over? (fill-ring (make-board 2) 2 'X) 'X)))

(deftest pieces-of-the-other-player-do-not-win
  (check nil (game-over? (fill-ring (make-board 2) 2 'O) 'X)))

(deftest full-board-without-a-winning-group-is-over-without-a-winner
  (check 1 (game-over? '((O O O) (O X O X O X)) 'X)))

(deftest unconnected-pieces-on-all-three-sides-do-not-win
  ;; X holds one cell on each side of the outer ring, but they are not connected.
  (check nil (equal 2 (game-over? '((O O O) (X O X O X O)) 'X))))

(end-of-tests)

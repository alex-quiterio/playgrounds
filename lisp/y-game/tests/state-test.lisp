;;;; Specs for state.lisp. Run with: sbcl --script lisp/y-game/tests/state-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defun path-cells (paths player)
  (mapcar #'cdr (remove-if-not (lambda (path) (eq (car path) player)) paths)))

(deftest other-player-swaps-x-and-o
  (check 'O (other-player 'X))
  (check 'X (other-player 'O)))

(deftest board-paths-lists-every-connected-group
  (let ((paths (board-paths (list (list 'X '* '*) (list 'X '* '* 'O '* 'X)))))
    ;; (1 . 0) and (2 . 0) touch, and (2 . 5) wraps round to (2 . 0): one X group.
    (check 1 (length (path-cells paths 'X)))
    (check 3 (length (first (path-cells paths 'X))))
    (check '(((2 . 3))) (path-cells paths 'O))))

(deftest board-paths-of-an-empty-board-is-empty
  (check nil (board-paths (make-board 3))))

(deftest new-state-reads-rings-and-groups-from-the-board
  (let ((state (state-of (list (list 'X '* '*) (list 'X '* '* '* '* 'O)) 'O)))
    (check 2 (state-ring-count state))
    (check 'O (state-player state))
    (check '(2 1) (sort (mapcar (lambda (path) (length (cdr path))) (state-paths state)) #'>))))

(deftest update-paths-merges-every-group-the-new-cell-touches
  (let* ((paths '((X (2 . 0)) (X (2 . 2)) (O (2 . 4))))
         (updated (update-paths paths (neighbours 1 0 2) 1 0 'X)))
    (check 1 (length (path-cells updated 'X)))
    (check 3 (length (first (path-cells updated 'X))))
    (check '(((2 . 4))) (path-cells updated 'O))))

(deftest update-paths-starts-a-new-group-for-an-isolated-cell
  (let ((updated (update-paths '((X (2 . 0))) (neighbours 2 3 2) 2 3 'X)))
    (check 2 (length (path-cells updated 'X)))))

(deftest update-paths-ignores-the-other-players-groups
  (let ((updated (update-paths '((O (2 . 0))) (neighbours 1 0 2) 1 0 'X)))
    (check '(((2 . 0))) (path-cells updated 'O))
    (check '(((1 . 0))) (path-cells updated 'X))))

(deftest legal-moves-lists-every-empty-cell-outer-ring-last-cell-first
  (let ((moves (legal-moves (state-of (make-board 2)))))
    (check 9 (length moves))
    (check '(2 . 5) (first moves))
    (check '(1 . 0) (car (last moves))))
  (let ((after (state-of (board-place-piece (make-board 2) 'X 1 0))))
    (check 8 (length (legal-moves after)))
    (check nil (member '(1 . 0) (legal-moves after) :test #'equal))))

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

(deftest game-successors-pairs-each-legal-move-with-its-state
  (let* ((state (state-of (make-board 2)))
         (successors (game-successors state)))
    (check (legal-moves state) (mapcar #'car successors))
    (dolist (pair successors)
      (check 'X (board-piece (state-board (cdr pair)) (car (car pair)) (cdr (car pair)))))))

(end-of-tests)

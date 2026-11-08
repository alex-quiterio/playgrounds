;;;; The game state the computer player searches over.
;;;;
;;;; Besides the board, a state keeps every player's connected groups ("paths"),
;;;; each written (player cell cell ...), so the heuristics don't have to rebuild them.

(defstruct (game-state (:conc-name state-))
  board
  (ring-count 0)
  (paths '())
  (player 'X)) ; the player to move

(defun other-player (player)
  (if (equal player 'X) 'O 'X))

;; Every connected group on the board, as a list of paths.
(defun board-paths (board)
  (let ((visited '())
        (paths '()))
    (loop for cells in board
          for ring from 1 do
      (loop for piece in cells
            for pos from 0
            unless (or (eq piece '*) (member (cons ring pos) visited :test #'equal)) do
              (let ((group (connected-cells board ring pos '() piece)))
                (push (cons piece group) paths)
                (setf visited (append group visited)))))
    paths))

;; A state for the board, with player to move.
(defun new-state (board &optional (player 'X))
  (make-game-state :board board
                   :ring-count (board-rings board)
                   :paths (board-paths board)
                   :player player))

;; The paths after player plays at (ring . pos): every one of player's paths
;; next to that cell merges with it into one.
(defun update-paths (paths neighbour-cells ring pos player)
  (let ((cell (cons ring pos))
        (merged '())
        (kept '()))
    (dolist (path paths)
      (if (and (equal (car path) player)
               (some (lambda (c) (member c neighbour-cells :test #'equal)) (cdr path)))
          (setf merged (append (cdr path) merged))
          (push path kept)))
    (if merged
        (cons (list* player cell merged) kept)
        (cons (list player cell) paths))))

;; Every empty cell, as (ring . pos), outer ring last cell first.
(defun legal-moves (state)
  (let ((moves '()))
    (loop for cells in (state-board state)
          for ring from 1 do
      (loop for piece in cells
            for pos from 0
            when (eq piece '*) do (push (cons ring pos) moves)))
    moves))

;; The state after the player to move plays move. The original state is not changed.
(defun make-move (state move)
  (destructuring-bind (ring . pos) move
    (let ((player (state-player state)))
      (make-game-state
       :board (board-place-piece (state-board state) player ring pos)
       :ring-count (state-ring-count state)
       :player (other-player player)
       :paths (update-paths (state-paths state)
                            (neighbours ring pos (state-ring-count state))
                            ring pos player)))))

;; A (move . state) pair for every move.
(defun game-successors (state)
  (mapcar (lambda (move) (cons move (make-move state move)))
          (legal-moves state)))

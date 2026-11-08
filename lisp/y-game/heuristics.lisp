;;;; Heuristics: how good a state looks for player, as one number.

(defparameter *value-piece-ring* 10)   ; per piece, times its ring number
(defparameter *value-piece-ring-1* 200) ; a piece at the end of a side, one ring in
(defparameter *value-path-elem* 5)     ; per piece in a path, growing with its length

;; Pieces on rings further out are worth more; the opponent's count against.
(defun eval-pieces (state player)
  (loop for cells in (state-board state)
        for ring from 1
        sum (loop for piece in cells
                  sum (cond ((equal piece player) (* ring *value-piece-ring*))
                            ((eq piece '*) 0)
                            (t (- (* ring *value-piece-ring*)))))))

;; A bonus if player holds the last cell of any side of the second-to-last ring.
(defun eval-corner-pieces (state player)
  (let* ((ring (1- (board-rings (state-board state))))
         (corners (list (1- ring) (1- (* 2 ring)) (1- (* 3 ring)))))
    (if (loop for piece in (nth (1- ring) (state-board state))
              for pos from 0
              thereis (and (equal piece player) (member pos corners)))
        *value-piece-ring-1*
        0)))

;; Each path is worth 5 + 10 + 15 + ... for its pieces, favouring longer paths.
(defun eval-path-length (state player)
  (loop for (owner . cells) in (state-paths state)
        for length = (length cells)
        for value = (* *value-path-elem* (/ (* length (1+ length)) 2))
        sum (if (equal owner player) value (- value))))

(defun eval-f1 (state player)
  (eval-pieces state player))

(defun eval-f2 (state player)
  (+ (eval-pieces state player)
     (eval-corner-pieces state player)))

(defun eval-f3 (state player)
  (+ (eval-pieces state player)
     (eval-corner-pieces state player)
     (eval-path-length state player)))

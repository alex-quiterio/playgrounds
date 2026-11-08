;;;; Players. A player is a function that takes the board and makes one move on it.
;;;; make-manual-player and make-automatic-player build one from the number of
;;;; rings, the piece it plays (X or O) and the time limit per move in seconds.

;; Asks for a ring and a position on the terminal.
(defun make-manual-player (rings piece time-limit)
  (lambda (board)
    (if (/= (board-rings board) rings)
        (say "Board does not fit this player")
        (let ((started (get-universal-time)))
          (say "Ring")
          (let ((ring (read-position)))
            (say "Position")
            (if (and (/= time-limit 0)
                     (>= (- (get-universal-time) started) time-limit))
                (say "Time is up")
                (let ((pos (read-position)))
                  (if (legal-move? board ring pos)
                      (board-place-piece! board piece ring pos)
                      (say-line "Invalid move"))
                  (print-board board))))))))

;; Whether the time left is more than the next, deeper search should need.
;; Early in the game it keeps a bigger reserve, as more moves are still to come.
(defun time-available? (limit spent move-number estimate)
  (if (>= (/ move-number 2) 10)
      (> (- limit spent) (* 4 estimate))
      (> (- limit spent) (* (- 15 (float (/ move-number 2))) estimate))))

;; Picks its move with alpha-beta and eval-f3. With a time limit it deepens the
;; search one move at a time while time allows; with 0 it searches to the end.
(defun make-automatic-player (rings piece time-limit)
  (declare (ignore rings)) ; the board itself says how many rings it has
  (let ((move-number 0))
    (lambda (board)
      (let* ((state (new-state board))
             (moves-left (length (legal-moves state)))
             (limit (if (eql time-limit 0) moves-left 1))
             (decision (alpha-beta-decision state #'eval-f3 piece limit)))
        (unless (eql time-limit 0)
          (let ((budget (* time-limit internal-time-units-per-second))
                (spent 0)
                (last-search 0))
            (loop while (and (< limit moves-left)
                             (time-available? budget spent move-number last-search))
                  do (incf limit)
                     (let ((started (get-internal-real-time)))
                       (setf decision (alpha-beta-decision state #'eval-f3 piece limit))
                       (setf last-search (- (get-internal-real-time) started))
                       (incf spent last-search)))))
        (say "Ring =")
        (show-value (car decision))
        (say-line "")
        (say "Position =")
        (show-value (cdr decision))
        (say-line "")
        (board-place-piece! board piece (car decision) (cdr decision))
        (incf move-number 2)
        (print-board board)))))

;;;; The board.
;;;;
;;;; A board is a list of rings. Ring n (counting from 1, the centre) has 3n cells,
;;;; each holding X, O or * for empty. A cell is written (ring . position).
;;;; The outer ring has three sides; a player wins with a connected group that
;;;; touches all three.

(defun make-board (rings)
  (loop for ring from 1 to rings
        collect (make-list (* 3 ring) :initial-element '*)))

(defun board-rings (board)
  (length board))

(defun board-piece (board ring pos)
  (nth pos (nth (1- ring) board)))

;; Places the piece on the board itself.
(defun board-place-piece! (board piece ring pos)
  (setf (nth pos (nth (1- ring) board)) piece))

;; Returns a copy of the board with the piece placed; the original is not changed.
(defun board-place-piece (board piece ring pos)
  (let ((copy (mapcar #'copy-list board)))
    (board-place-piece! copy piece ring pos)
    copy))

(defun legal-move? (board ring pos)
  (eq (board-piece board ring pos) '*))

;; Whether obj is a well-formed board: ring n has 3n cells of X, O or *.
(defun board-p (obj)
  (and (consp obj)
       (loop for ring in obj
             for n from 1
             always (and (listp ring)
                         (= (length ring) (* 3 n))
                         (every (lambda (piece) (member piece '(X O *))) ring)))))

;; Prints one ring per line, with a gap after each of its three sides.
(defun print-board (board)
  (when (board-p board)
    (let ((rings (board-rings board)))
      (loop for ring from 1 to rings do
        (dotimes (pos (* 3 ring))
          (show (board-piece board ring pos))
          (when (zerop (mod (1+ pos) ring))
            (dotimes (gap (- rings ring))
              (show " "))))
        (terpri)))))

;;; Neighbours

(defun same-ring-neighbours (ring pos)
  (let ((last (1- (* 3 ring))))
    (list (cons ring (if (= pos last) 0 (1+ pos)))
          (cons ring (if (= pos 0) last (1- pos))))))

(defun outer-ring-neighbours (ring pos)
  (let* ((offset (mod pos ring))
         (side (floor pos ring))
         (outer (1+ ring))
         (res (list (cons outer (+ offset (* side outer) 1))
                    (cons outer (+ offset (* side outer))))))
    (if (= offset (1- ring))
        (append res (list (cons outer (mod (* outer (1+ side)) (* 3 outer)))))
        res)))

(defun inner-ring-neighbours (ring pos)
  (let ((offset (mod pos ring))
        (side (floor pos ring))
        (inner (1- ring)))
    (cond
      ((= offset 0)
       (list (cons inner (+ (* inner side) offset))
             (cons inner (+ (* inner (mod (1- side) 3)) (1- inner)))))
      ((= offset (1- ring))
       (list (cons inner (+ (* inner side) (1- offset)))))
      (t
       (list (cons inner (+ (* inner side) (1- offset)))
             (cons inner (+ (* inner side) offset)))))))

;; Every neighbour of (ring . pos) on a board with the given number of rings.
(defun neighbours (ring pos rings)
  (append (same-ring-neighbours ring pos)
          (unless (= ring rings) (outer-ring-neighbours ring pos))
          (unless (= ring 1) (inner-ring-neighbours ring pos))))

;;; Winning

;; Which of the three sides of its ring a position is on.
(defun sector (ring pos)
  (truncate pos ring))

;; Returns visited plus every cell of player's connected to (ring . pos).
(defun connected-cells (board ring pos visited player)
  (let ((cell (cons ring pos)))
    (if (member cell visited :test #'equal)
        visited
        (let ((visited (cons cell visited)))
          (dolist (next (neighbours ring pos (board-rings board)) visited)
            (when (equal (board-piece board (car next) (cdr next)) player)
              (setf visited (connected-cells board (car next) (cdr next) visited player))))))))

;; Whether the cells include all three sides of the outer ring.
(defun touches-all-sides? (cells rings)
  (let ((sides (loop for (ring . pos) in cells
                     when (= ring rings) collect (sector ring pos))))
    (and (member 0 sides) (member 1 sides) (member 2 sides) t)))

(defun outer-ring-cells (board player)
  (let ((rings (board-rings board)))
    (loop for piece in (nth (1- rings) board)
          for pos from 0
          when (equal piece player) collect (cons rings pos))))

(defun full-board? (board)
  (notany (lambda (ring) (member '* ring)) board))

;; 2 if player has a winning group, 1 if the board is full, otherwise NIL.
(defun game-over? (board player)
  (let ((rings (board-rings board))
        (outer (outer-ring-cells board player)))
    (cond
      ((and (touches-all-sides? outer rings)
            (some (lambda (cell)
                    (touches-all-sides? (connected-cells board (car cell) (cdr cell) '() player)
                                        rings))
                  outer))
       2)
      ((full-board? board) 1))))

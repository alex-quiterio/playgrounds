;;;; Game-tree search: minimax with a depth cutoff, and alpha-beta.
;;;; Values are always from startplayer's side.

(defparameter *value-victory* 1000)
(defparameter *value-defeat* -1000)

(defconstant infinity most-positive-single-float)
(defconstant minus-infinity most-negative-single-float)

;; The element of the list that scores highest under fn; the first one on a tie.
(defun the-biggest (fn list)
  (let ((biggest (first list))
        (best (funcall fn (first list))))
    (dolist (x (rest list) biggest)
      (let ((value (funcall fn x)))
        (when (> value best)
          (setf best value
                biggest x))))))

;; A copy of the state with player to move.
(defun root-state (state player)
  (let ((root (copy-game-state state)))
    (setf (state-player root) player)
    root))

;; The value of a state that ends the search: a win, a full board, or the depth
;; limit. NIL if the search should go on. Quicker wins (higher limit) are worth
;; more, and quicker losses less.
(defun search-value (state eval-fn limit startplayer)
  (let ((moved (other-player (state-player state))))
    (cond
      ((equal 2 (game-over? (state-board state) moved))
       (if (equal moved startplayer)
           (+ *value-victory* limit)
           (- *value-defeat* limit)))
      ((null (legal-moves state)) 0)
      ((<= limit 0) (funcall eval-fn state startplayer))
      (t nil))))

;; The move whose successor scores highest under value-fn.
(defun best-successor (state value-fn)
  (car (the-biggest (lambda (a+s) (funcall value-fn (cdr a+s)))
                    (game-successors state))))

;;; Minimax with cutoff

(defun minimax-cutoff-value (state eval-fn limit startplayer)
  (or (search-value state eval-fn limit startplayer)
      (let ((values (mapcar (lambda (a+s)
                              (minimax-cutoff-value (cdr a+s) eval-fn (1- limit) startplayer))
                            (game-successors state))))
        (if (equal startplayer (state-player state))
            (reduce #'max values)
            (reduce #'min values)))))

;; The best move for startplayer, searching limit moves ahead.
(defun minimax-cutoff-decision (state eval-fn limit startplayer)
  (best-successor (root-state state startplayer)
                  (lambda (next) (minimax-cutoff-value next eval-fn (1- limit) startplayer))))

;;; Alpha-beta

(defun alpha-beta-value (state alpha beta eval-fn limit startplayer)
  (or (search-value state eval-fn limit startplayer)
      (if (equal startplayer (state-player state))
          (dolist (a+s (game-successors state) alpha)
            (setf alpha (max alpha (alpha-beta-value (cdr a+s) alpha beta eval-fn (1- limit) startplayer)))
            (when (>= alpha beta)
              (return alpha)))
          (dolist (a+s (game-successors state) beta)
            (setf beta (min beta (alpha-beta-value (cdr a+s) alpha beta eval-fn (1- limit) startplayer)))
            (when (<= beta alpha)
              (return beta))))))

;; The best move for startplayer, searching limit moves ahead.
(defun alpha-beta-decision (state eval-fn startplayer &optional (limit 4))
  (let ((best-move nil)
        (alpha minus-infinity))
    (dolist (a+s (game-successors (root-state state startplayer)) best-move)
      (let ((value (alpha-beta-value (cdr a+s) alpha infinity eval-fn (1- limit) startplayer)))
        (when (or (null best-move) (> value alpha))
          (setf alpha value
                best-move (car a+s)))))))

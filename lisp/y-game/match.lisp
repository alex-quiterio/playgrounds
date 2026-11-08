;;;; A match: two rounds, each player moving first once.
;;;; The player who moves first plays X.

;; Plays one round on a fresh board. Returns (time-first time-second board) and,
;; as a second value, :first or :second for the winner, or NIL for a draw.
(defun play-round (first-player second-player rings)
  (let ((board (make-board rings))
        (times (list 0 0)))
    (flet ((turn (player piece index name)
             (say-line name)
             (let ((started (get-universal-time)))
               (funcall player board)
               (incf (nth index times) (- (get-universal-time) started)))
             (game-over? board piece)))
      (loop
        (case (turn first-player 'X 0 "First player")
          (2 (return (values (list (first times) (second times) board) :first)))
          (1 (return (values (list (first times) (second times) board) nil))))
        (case (turn second-player 'O 1 "Second player")
          (2 (return (values (list (first times) (second times) board) :second)))
          (1 (return (values (list (first times) (second times) board) nil))))))))

;; Plays a match between player-a and player-b, built with make-manual-player or
;; make-automatic-player. More rounds won wins the match; on a tie with a time
;; limit, less time used wins. Returns the two rounds as play-round lists them.
(defun play-match (rings player-a player-b time-limit)
  (let ((wins-a 0) (wins-b 0))
    (say-line "-----Game of Y-----")
    (say-line "Player A moves first, as X")
    (multiple-value-bind (round-1 winner)
        (play-round (funcall player-a rings 'X time-limit)
                    (funcall player-b rings 'O time-limit) rings)
      (case winner (:first (incf wins-a)) (:second (incf wins-b)))
      (say-line "----New game----")
      (say-line "Player B moves first, as X")
      (multiple-value-bind (round-2 winner)
          (play-round (funcall player-b rings 'X time-limit)
                      (funcall player-a rings 'O time-limit) rings)
        (case winner (:first (incf wins-b)) (:second (incf wins-a)))
        (let ((time-a (+ (first round-1) (second round-2)))
              (time-b (+ (second round-1) (first round-2))))
          (say (cond
                 ((> wins-a wins-b) "Player A won the match")
                 ((> wins-b wins-a) "Player B won the match")
                 ((eql time-limit 0) "The match is a draw")
                 ((< time-a time-b) "Player A won the match (on time)")
                 ((< time-b time-a) "Player B won the match (on time)")
                 (t "The match is a draw"))))
        (list round-1 round-2)))))

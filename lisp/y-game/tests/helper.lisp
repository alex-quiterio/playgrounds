;;;; Shared by every test file: loads the game once, and defines deftest and check.
;;;; Each *-test.lisp file runs on its own (sbcl --script tests/board-test.lisp), and
;;;; run-all.lisp runs them together.

(unless (fboundp 'make-board)
  (load (merge-pathnames "../y-game.lisp" (or *load-truename* *default-pathname-defaults*))))

(defvar *passed* 0)
(defvar *failed* '())
(defvar *running-all* nil) ; set by run-all.lisp, which reports once at the end

(defmacro deftest (name &body body)
  `(handler-case
       (progn ,@body
              (incf *passed*)
              (format t "ok   ~(~a~)~%" ',name))
     (error (e)
       (push ',name *failed*)
       (format t "FAIL ~(~a~): ~a~%" ',name e))))

(defun check (expected actual &optional (description ""))
  (unless (equal expected actual)
    (error "~a expected ~s, got ~s" description expected actual)))

(defun check-true (value &optional (description ""))
  (check t (not (null value)) description))

;; Prints the totals and exits with status 1 if anything failed.
(defun report-results ()
  (format t "~a passed, ~a failed~%" *passed* (length *failed*))
  (sb-ext:exit :code (if *failed* 1 0)))

;; Called at the end of every test file; only reports when the file runs on its own.
(defun end-of-tests ()
  (unless *running-all* (report-results)))

;;; Helpers for building positions and players

(defun quietly (thunk)
  (let ((*standard-output* (make-broadcast-stream)))
    (funcall thunk)))

(defun fill-ring (board ring piece)
  (dotimes (pos (* 3 ring) board)
    (board-place-piece! board piece ring pos)))

(defun state-of (board &optional (player 'X))
  (new-state board player))

(defun near-win-state ()
  "X holds sides 0 and 1 of the outer ring; (2 . 5) joins (2 . 0) and reaches side 2."
  (state-of (list (list 'O 'O '*) (list 'X 'X 'X 'O '* '*))))

(defun block-state ()
  "O holds sides 0 and 1 of the outer ring and wins with (2 . 5) unless X takes it."
  (state-of (list (list 'X 'X '*) (list 'O 'O 'O 'X '* '*))))

;; A player that plays the first cell of its script that is still empty, then
;; the first legal move once the script runs out.
(defun scripted-player (script)
  (lambda (rings piece time-limit)
    (declare (ignore rings time-limit))
    (lambda (board)
      (let ((move (or (find-if (lambda (cell) (legal-move? board (car cell) (cdr cell))) script)
                      (first (legal-moves (state-of board))))))
        (board-place-piece! board piece (car move) (cdr move))))))

;; On 2 rings these four cells connect all three sides: (2 . 5) is on side 2 and
;; next to (2 . 0) on side 0, which reaches (2 . 2) on side 1 through (1 . 0).
;; *winner* wins against *loser* whoever moves first; *loser* against itself
;; always loses as the second player.
(defparameter *winner* (scripted-player '((2 . 0) (2 . 5) (1 . 0) (2 . 2))))
(defparameter *loser* (scripted-player '((2 . 1) (2 . 3) (2 . 4) (1 . 1) (1 . 2))))

;;;; Day 3: Lobby
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun max-joltage (bank count)
  "Largest number made of COUNT digits of BANK, keeping their order."
  (let ((start 0) (value 0))
    (loop for remaining from count downto 1 do
      ;; Pick the largest digit that still leaves room for the remaining ones.
      (let ((best start))
        (loop for i from start to (- (length bank) remaining)
              when (char> (char bank i) (char bank best)) do (setf best i))
        (setf value (+ (* value 10) (digit-char-p (char bank best)))
              start (1+ best))))
    value))

(let ((banks (remove "" (read-lines (input-path)) :test #'string=)))
  (answer (loop for bank in banks sum (max-joltage bank 2))
          (loop for bank in banks sum (max-joltage bank 12))))

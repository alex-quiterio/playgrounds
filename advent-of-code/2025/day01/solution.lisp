;;;; Day 1: Secret Entrance
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun rotations (lines)
  (loop for line in lines
        when (plusp (length line))
          collect (* (if (char= (char line 0) #\L) -1 1) (parse-integer line :start 1))))

(defun part1 (moves)
  (let ((dial 50) (zeros 0))
    (dolist (move moves zeros)
      (setf dial (mod (+ dial move) 100))
      (when (zerop dial) (incf zeros)))))

(defun clicks-on-zero (dial move)
  "How many clicks of MOVE, starting at DIAL, land on 0."
  (let ((distance (abs move)))
    (cond ((plusp move) (floor (+ dial distance) 100))
          ((zerop dial) (floor distance 100))
          ((>= distance dial) (1+ (floor (- distance dial) 100)))
          (t 0))))

(defun part2 (moves)
  (let ((dial 50) (zeros 0))
    (dolist (move moves zeros)
      (incf zeros (clicks-on-zero dial move))
      (setf dial (mod (+ dial move) 100)))))

(let ((moves (rotations (read-lines (input-path)))))
  (answer (part1 moves) (part2 moves)))

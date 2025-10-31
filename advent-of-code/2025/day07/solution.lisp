;;;; Day 7: Laboratories
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun run-beams (grid)
  "Returns the number of splits and the number of timelines."
  (let* ((cols (grid-cols grid))
         (beams (make-array cols :initial-element 0))
         (splits 0))
    ;; beams[c] = how many timelines have a beam in column c
    (dotimes (c cols)
      (when (char= (aref grid 0 c) #\S) (setf (aref beams c) 1)))
    (loop for r from 1 below (grid-rows grid) do
      (let ((next (make-array cols :initial-element 0)))
        (dotimes (c cols)
          (let ((n (aref beams c)))
            (when (plusp n)
              (if (char= (aref grid r c) #\^)
                  (progn (incf splits)
                         (when (> c 0) (incf (aref next (1- c)) n))
                         (when (< (1+ c) cols) (incf (aref next (1+ c)) n)))
                  (incf (aref next c) n)))))
        (setf beams next)))
    (values splits (reduce #'+ beams))))

(multiple-value-bind (splits timelines) (run-beams (read-grid (input-path)))
  (answer splits timelines))

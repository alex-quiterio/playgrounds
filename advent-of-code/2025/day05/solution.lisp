;;;; Day 5: Cafeteria
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun parse (lines)
  (let ((blank (position "" lines :test #'string=)))
    (values (loop for line in (subseq lines 0 blank)
                  collect (let ((ends (integers (substitute #\Space #\- line))))
                            (cons (first ends) (second ends))))
            (loop for line in (subseq lines (1+ blank))
                  when (plusp (length line)) collect (parse-integer line)))))

(defun fresh-p (id ranges)
  (some (lambda (range) (<= (car range) id (cdr range))) ranges))

(defun union-size (ranges)
  "How many IDs the overlapping RANGES cover."
  (let ((total 0) (reach -1))
    (dolist (range (sort (copy-list ranges) #'< :key #'car) total)
      (let ((from (max (car range) (1+ reach))))
        (when (<= from (cdr range))
          (incf total (1+ (- (cdr range) from))))
        (setf reach (max reach (cdr range)))))))

(multiple-value-bind (ranges ids) (parse (read-lines (input-path)))
  (answer (count-if (lambda (id) (fresh-p id ranges)) ids)
          (union-size ranges)))

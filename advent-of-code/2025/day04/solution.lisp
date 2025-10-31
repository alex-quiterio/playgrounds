;;;; Day 4: Printing Department
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun accessible (grid)
  "Every roll with fewer than four rolls around it."
  (loop for r below (grid-rows grid)
        nconc (loop for c below (grid-cols grid)
                    when (and (char= (aref grid r c) #\@)
                              (< (count-if (lambda (d) (eql (grid-ref grid (+ r (car d)) (+ c (cdr d))) #\@))
                                           +neighbours-8+)
                                 4))
                      collect (cons r c))))

(defun part2 (grid)
  (loop for rolls = (accessible grid)
        while rolls
        sum (length rolls)
        do (loop for (r . c) in rolls do (setf (aref grid r c) #\.))))

(let ((grid (read-grid (input-path))))
  (answer (length (accessible grid)) (part2 grid)))

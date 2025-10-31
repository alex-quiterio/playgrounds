;;;; Day 10: Factory
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun between (line open close)
  "Every substring of LINE enclosed in OPEN ... CLOSE."
  (loop with start = 0
        for from = (position open line :start start)
        while from
        collect (let ((to (position close line :start from)))
                  (setf start to)
                  (subseq line (1+ from) to))))

(defun parse-machine (line)
  (list (map 'list (lambda (c) (if (char= c #\#) 1 0)) (first (between line #\[ #\])))
        (mapcar #'integers (between line #\( #\)))
        (integers (first (between line #\{ #\})))))

(defun button-combinations (buttons counters)
  "Every subset of BUTTONS pressed once: (presses . per-counter increments)."
  (let ((n (length buttons)))
    (loop for mask below (ash 1 n)
          collect (let ((effect (make-list counters :initial-element 0)))
                    (loop for button in buttons for i from 0
                          when (logbitp i mask)
                            do (dolist (k button) (incf (nth k effect))))
                    (cons (logcount mask) effect)))))

(defun fewest-presses-lights (lights buttons)
  (loop for (presses . effect) in (button-combinations buttons (length lights))
        when (equal lights (mapcar (lambda (e) (mod e 2)) effect))
          minimize presses))

(defun fewest-presses-joltage (targets buttons)
  "Every solution presses each button some number of times. Pressing a
subset once fixes the parity of each counter; what is left is even, so it is
twice a smaller instance of the same problem."
  (let ((combos (button-combinations buttons (length targets)))
        (memo (make-hash-table :test #'equal)))
    (labels ((solve (target)
               (cond ((every #'zerop target) 0)
                     ((nth-value 1 (gethash target memo)) (gethash target memo))
                     (t (setf (gethash target memo)
                              ;; NIL when no subset matches: that branch has no solution.
                              (let ((best nil))
                                (loop for (presses . effect) in combos
                                      when (every (lambda (e tg) (and (<= e tg) (evenp (- tg e)))) effect target)
                                        do (let ((half (solve (mapcar (lambda (e tg) (/ (- tg e) 2)) effect target))))
                                             (when half
                                               (let ((total (+ presses (* 2 half))))
                                                 (when (or (null best) (< total best))
                                                   (setf best total))))))
                                best))))))
      (solve targets))))

(let ((machines (loop for line in (read-lines (input-path))
                      when (plusp (length line)) collect (parse-machine line))))
  (answer (loop for (lights buttons) in machines sum (fewest-presses-lights lights buttons))
          (loop for (nil buttons joltage) in machines sum (fewest-presses-joltage joltage buttons))))

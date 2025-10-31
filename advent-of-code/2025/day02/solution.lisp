;;;; Day 2: Gift Shop
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun ranges (text)
  (loop for part in (split (remove #\Newline text) #\,)
        collect (let ((ends (integers (substitute #\Space #\- part))))
                  (cons (first ends) (second ends)))))

(defun digits (n) (length (princ-to-string n)))

(defun repeated-ids (low high allowed-repeats)
  "Every ID in [LOW, HIGH] made of a block of digits repeated k times,
for k accepted by ALLOWED-REPEATS."
  (let ((found (make-hash-table)))
    (loop for size from (digits low) to (digits high) do
      (loop for block from 1 below size
            for repeats = (/ size block)
            when (and (integerp repeats) (funcall allowed-repeats repeats)) do
              ;; block b repeated k times = b * (1 + 10^block + 10^(2 block) + ...)
              (let* ((multiplier (loop for i below repeats sum (expt 10 (* i block))))
                     (from (max (expt 10 (1- block)) (ceiling low multiplier)))
                     (to (min (1- (expt 10 block)) (floor high multiplier))))
                (loop for b from from to to do (setf (gethash (* b multiplier) found) t)))))
    (loop for id being the hash-keys of found collect id)))

(defun total (ranges allowed-repeats)
  (loop for (low . high) in ranges
        sum (reduce #'+ (repeated-ids low high allowed-repeats))))

(let ((ranges (ranges (read-text (input-path)))))
  (answer (total ranges (lambda (k) (= k 2)))
          (total ranges (lambda (k) (>= k 2)))))

;;;; Day 8: Playground
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun boxes (lines)
  (coerce (loop for line in lines when (plusp (length line)) collect (integers line)) 'vector))

(defun closest-pairs (boxes)
  "Every pair (i . j) of boxes, closest first."
  (let ((pairs '()))
    (dotimes (i (length boxes))
      (loop for j from (1+ i) below (length boxes)
            do (push (list (reduce #'+ (mapcar (lambda (a b) (expt (- a b) 2))
                                               (aref boxes i) (aref boxes j)))
                           i j)
                     pairs)))
    (mapcar #'cdr (sort pairs #'< :key #'first))))

(defun find-root (parent i)
  (loop until (= i (aref parent i))
        do (setf (aref parent i) (aref parent (aref parent i))
                 i (aref parent i)))
  i)

(defun solve (boxes connections)
  (let* ((n (length boxes))
         (parent (let ((p (make-array n))) (dotimes (i n p) (setf (aref p i) i))))
         (size (make-array n :initial-element 1))
         (circuits n) (part1 nil) (part2 nil))
    (loop for (i j) in (closest-pairs boxes)
          for made from 1
          do (let ((a (find-root parent i)) (b (find-root parent j)))
               (unless (= a b)
                 (setf (aref parent a) b)
                 (incf (aref size b) (aref size a))
                 (decf circuits)
                 (when (= circuits 1)
                   (setf part2 (* (first (aref boxes i)) (first (aref boxes j)))))))
             (when (= made connections)
               (let ((sizes (loop for k below n when (= k (find-root parent k)) collect (aref size k))))
                 (setf part1 (reduce #'* (subseq (sort sizes #'>) 0 (min 3 (length sizes)))))))
          until (and part1 part2))
    (values part1 part2)))

(let ((boxes (boxes (read-lines (input-path)))))
  ;; The example connects the 10 closest pairs; the real input connects 1000.
  (multiple-value-bind (part1 part2) (solve boxes (if (< (length boxes) 100) 10 1000))
    (answer part1 part2)))

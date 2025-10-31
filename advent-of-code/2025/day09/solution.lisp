;;;; Day 9: Movie Theater
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun tiles (lines)
  (loop for line in lines when (plusp (length line))
        collect (let ((xy (integers line))) (cons (first xy) (second xy)))))

(defun area (a b)
  (* (1+ (abs (- (car a) (car b)))) (1+ (abs (- (cdr a) (cdr b))))))

(defun part1 (tiles)
  (loop for (a . rest) on tiles
        maximize (loop for b in rest maximize (area a b))))

;;; Part 2: the rectangle must lie inside the loop the red tiles draw.
;;; Coordinates are compressed: index 2k is the k-th distinct value and odd
;;; indexes stand for the gaps between them.

(defun compressor (values)
  (let ((sorted (sort (remove-duplicates values) #'<)) (index (make-hash-table)))
    (loop for v in sorted for i from 0 do (setf (gethash v index) (1+ (* 2 i))))
    (values index (+ 3 (* 2 (length sorted))))))

(defun part2 (tiles)
  (multiple-value-bind (xi width) (compressor (mapcar #'car tiles))
    (multiple-value-bind (yi height) (compressor (mapcar #'cdr tiles))
      (let ((wall (make-array (list width height) :initial-element nil))
            (outside (make-array (list width height) :initial-element nil)))
        ;; draw the loop
        (loop for (a b) on (append tiles (list (first tiles)))
              while b
              do (let ((x1 (gethash (car a) xi)) (y1 (gethash (cdr a) yi))
                       (x2 (gethash (car b) xi)) (y2 (gethash (cdr b) yi)))
                   (loop for x from (min x1 x2) to (max x1 x2)
                         do (loop for y from (min y1 y2) to (max y1 y2)
                                  do (setf (aref wall x y) t)))))
        ;; flood the outside from the padded border
        (let ((stack (list (cons 0 0))))
          (setf (aref outside 0 0) t)
          (loop while stack do
            (destructuring-bind (x . y) (pop stack)
              (loop for (dx . dy) in '((1 . 0) (-1 . 0) (0 . 1) (0 . -1))
                    for nx = (+ x dx) for ny = (+ y dy)
                    when (and (< -1 nx width) (< -1 ny height)
                              (not (aref wall nx ny)) (not (aref outside nx ny)))
                      do (setf (aref outside nx ny) t) (push (cons nx ny) stack)))))
        ;; prefix sums of outside cells
        (let ((sums (make-array (list (1+ width) (1+ height)) :initial-element 0)))
          (dotimes (x width)
            (dotimes (y height)
              (setf (aref sums (1+ x) (1+ y))
                    (+ (if (aref outside x y) 1 0)
                       (aref sums x (1+ y)) (aref sums (1+ x) y) (- (aref sums x y))))))
          (flet ((inside-p (a b)
                   (let ((x1 (min (gethash (car a) xi) (gethash (car b) xi)))
                         (x2 (1+ (max (gethash (car a) xi) (gethash (car b) xi))))
                         (y1 (min (gethash (cdr a) yi) (gethash (cdr b) yi)))
                         (y2 (1+ (max (gethash (cdr a) yi) (gethash (cdr b) yi)))))
                     (zerop (- (+ (aref sums x2 y2) (aref sums x1 y1))
                               (aref sums x1 y2) (aref sums x2 y1))))))
            (loop for (a . rest) on tiles
                  maximize (loop for b in rest
                                 when (inside-p a b) maximize (area a b) into best
                                 finally (return (or best 0))))))))))

(let ((tiles (tiles (read-lines (input-path)))))
  (answer (part1 tiles) (part2 tiles)))

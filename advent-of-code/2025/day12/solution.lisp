;;;; Day 12: Christmas Tree Farm
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun parse (lines)
  "Returns the shapes (lists of (row . col) cells) and the regions (width height counts)."
  (let ((shapes '()) (regions '()) (current nil))
    (dolist (line lines)
      (cond ((find #\x line)
             (let ((numbers (integers (substitute #\Space #\x line))))
               (push (list (first numbers) (second numbers) (cddr numbers)) regions)))
            ((and (plusp (length line)) (char= (char line (1- (length line))) #\:))
             (setf current (list '())) (push current shapes))
            ((and current (plusp (length line)))
             (let ((row (length (rest current))))
               (loop for ch across line for c from 0
                     when (char= ch #\#) do (push (cons row c) (first current)))
               (setf (cdr current) (cons line (cdr current)))))))
    (values (mapcar #'first (nreverse shapes)) (nreverse regions))))

(defun normalise (cells)
  (let ((r0 (reduce #'min cells :key #'car)) (c0 (reduce #'min cells :key #'cdr)))
    (sort (mapcar (lambda (p) (cons (- (car p) r0) (- (cdr p) c0))) cells)
          (lambda (a b) (or (< (car a) (car b)) (and (= (car a) (car b)) (< (cdr a) (cdr b))))))))

(defun orientations (cells)
  "The distinct rotations and reflections of a shape."
  (let ((result '()) (shape cells))
    (dotimes (flip 2)
      (dotimes (turn 4)
        (pushnew (normalise shape) result :test #'equal)
        (setf shape (mapcar (lambda (p) (cons (cdr p) (- (car p)))) shape)))
      (setf shape (mapcar (lambda (p) (cons (car p) (- (cdr p)))) shape)))
    result))

(defun placements (orientations width height)
  "Every way to put the shape in the region, as bitmasks of covered cells."
  (let ((masks '()))
    (dolist (cells orientations (remove-duplicates masks))
      (let ((h (1+ (reduce #'max cells :key #'car))) (w (1+ (reduce #'max cells :key #'cdr))))
        (loop for r from 0 to (- height h) do
          (loop for c from 0 to (- width w) do
            (push (loop for (dr . dc) in cells sum (ash 1 (+ (* (+ r dr) width) c dc))) masks)))))))

(defun fits-p (shapes width height counts)
  (let ((pieces (loop for count in counts for shape in shapes nconc (make-list count :initial-element shape)))
        (area (* width height)))
    (cond
      ;; not enough room for every cell
      ((> (reduce #'+ pieces :key #'length) area) nil)
      ;; every present fits in its own 3x3 square
      ((>= (* (floor width 3) (floor height 3)) (length pieces)) t)
      (t (search-fit shapes width height counts)))))

(defun search-fit (shapes width height counts)
  "Exact search: place every present, identical presents in increasing order."
  (let* ((options (mapcar (lambda (s) (coerce (sort (placements (orientations s) width height) #'<) 'vector)) shapes))
         (todo (loop for count in counts for i from 0 nconc (make-list count :initial-element i))))
    (labels ((place (todo board previous-shape previous-index)
               (if (null todo)
                   t
                   (let* ((shape (first todo))
                          (masks (nth shape options))
                          (start (if (eql shape previous-shape) (1+ previous-index) 0)))
                     (loop for i from start below (length masks)
                           for mask = (aref masks i)
                             thereis (and (zerop (logand board mask))
                                          (place (rest todo) (logior board mask) shape i)))))))
      (place todo 0 nil -1))))

(multiple-value-bind (shapes regions) (parse (read-lines (input-path)))
  (answer (count-if (lambda (region) (destructuring-bind (w h counts) region (fits-p shapes w h counts)))
                    regions)))

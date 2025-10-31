;;;; Shared helpers for the 2025 solutions. Each day loads this file with:
;;;;   (load (merge-pathnames "../lib/aoc.lisp" *load-truename*))

(defpackage :aoc
  (:use :common-lisp)
  (:export #:input-path #:read-lines #:read-text #:split #:integers
           #:read-grid #:grid-ref #:grid-rows #:grid-cols #:+neighbours-8+
           #:answer))

(in-package :aoc)

(defun input-path ()
  "The input file given on the command line."
  (or (second sb-ext:*posix-argv*)
      (error "usage: ./run INPUT")))

(defun read-text (path)
  (with-open-file (in path)
    (let ((text (make-string (file-length in))))
      (subseq text 0 (read-sequence text in)))))

(defun read-lines (path)
  "Every line of the file, without the trailing newline."
  (with-open-file (in path)
    (loop for line = (read-line in nil) while line collect line)))

(defun split (string separator &key (keep-empty nil))
  "Splits STRING on the character SEPARATOR."
  (loop with start = 0
        for end = (position separator string :start start)
        for part = (subseq string start end)
        when (or keep-empty (plusp (length part))) collect part
        while end do (setf start (1+ end))))

(defun integers (string)
  "Every integer in STRING, including negative ones."
  (let ((numbers '()) (i 0) (n (length string)))
    (loop while (< i n) do
      (let ((c (char string i)))
        (if (or (digit-char-p c)
                (and (char= c #\-) (< (1+ i) n) (digit-char-p (char string (1+ i)))))
            (multiple-value-bind (value end) (parse-integer string :start i :junk-allowed t)
              (push value numbers)
              (setf i end))
            (incf i))))
    (nreverse numbers)))

(defun read-grid (path)
  "A 2D array of characters, indexed (row column)."
  (let* ((lines (remove "" (read-lines path) :test #'string=))
         (grid (make-array (list (length lines) (length (first lines)))
                           :element-type 'character :initial-element #\Space)))
    (loop for line in lines for r from 0
          do (loop for c across line for col from 0
                   do (setf (aref grid r col) c)))
    grid))

(defun grid-rows (grid) (array-dimension grid 0))
(defun grid-cols (grid) (array-dimension grid 1))

(defun grid-ref (grid r c &optional default)
  "The cell at (R C), or DEFAULT when outside the grid."
  (if (and (< -1 r (grid-rows grid)) (< -1 c (grid-cols grid)))
      (aref grid r c)
      default))

(defparameter +neighbours-8+
  '((-1 . -1) (-1 . 0) (-1 . 1) (0 . -1) (0 . 1) (1 . -1) (1 . 0) (1 . 1)))

(defun answer (&rest parts)
  "Prints each part's answer on its own line."
  (dolist (part parts)
    (format t "~a~%" part)))

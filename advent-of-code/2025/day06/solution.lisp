;;;; Day 6: Trash Compactor
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun worksheet (path)
  "The lines padded to the same width."
  (let* ((lines (remove-if (lambda (l) (zerop (length (string-trim " " l)))) (read-lines path)))
         (width (reduce #'max lines :key #'length)))
    (mapcar (lambda (l) (format nil "~va" width l)) lines)))

(defun blank-column-p (lines c)
  (every (lambda (l) (char= (char l c) #\Space)) lines))

(defun problems (lines)
  "Each problem as (start . end) columns, end exclusive."
  (let ((width (length (first lines))) (result '()) (start nil))
    (dotimes (c (1+ width) (nreverse result))
      (if (or (= c width) (blank-column-p lines c))
          (when start (push (cons start c) result) (setf start nil))
          (unless start (setf start c))))))

(defun solve (numbers operator)
  (if (char= operator #\*) (reduce #'* numbers) (reduce #'+ numbers)))

(defun grand-total (lines read-numbers)
  (let ((rows (butlast lines)) (ops (car (last lines))))
    (loop for (start . end) in (problems lines)
          sum (solve (funcall read-numbers rows start end)
                     (find-if (lambda (ch) (find ch "+*")) (subseq ops start end))))))

(defun row-numbers (rows start end)
  (loop for row in rows
        for text = (string-trim " " (subseq row start end))
        when (plusp (length text)) collect (parse-integer text)))

(defun column-numbers (rows start end)
  "Cephalopod reading: each column, top to bottom, is one number."
  (loop for c from start below end
        for digits = (remove #\Space (map 'string (lambda (row) (char row c)) rows))
        when (plusp (length digits)) collect (parse-integer digits)))

(let ((lines (worksheet (input-path))))
  (answer (grand-total lines #'row-numbers) (grand-total lines #'column-numbers)))

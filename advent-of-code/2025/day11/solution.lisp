;;;; Day 11: Reactor
(load (merge-pathnames "../lib/aoc.lisp" *load-truename*))
(defpackage :day (:use :common-lisp :aoc))
(in-package :day)

(defun devices (lines)
  (let ((graph (make-hash-table :test #'equal)))
    (dolist (line lines graph)
      (let ((parts (split (remove #\: line) #\Space)))
        (when parts (setf (gethash (first parts) graph) (rest parts)))))))

(defun path-counter (graph)
  "A function counting the paths between two devices (the graph has no cycles)."
  (let ((memo (make-hash-table :test #'equal)))
    (labels ((paths (from to)
               (if (string= from to)
                   1
                   (let ((key (cons from to)))
                     (multiple-value-bind (known found) (gethash key memo)
                       (if found
                           known
                           (setf (gethash key memo)
                                 (loop for next in (gethash from graph) sum (paths next to)))))))))
      #'paths)))

(let* ((graph (devices (read-lines (input-path))))
       (paths (path-counter graph)))
  (answer (if (gethash "you" graph) (funcall paths "you" "out") 0)
          (if (gethash "svr" graph)
              ;; visit dac and fft in either order
              (+ (* (funcall paths "svr" "dac") (funcall paths "dac" "fft") (funcall paths "fft" "out"))
                 (* (funcall paths "svr" "fft") (funcall paths "fft" "dac") (funcall paths "dac" "out")))
              0)))

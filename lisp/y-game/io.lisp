;;;; Terminal input and output.
;;;; SBCL buffers output until a function returns or the buffer fills up, so every
;;;; write is followed by finish-output to show it straight away.

(defun say (thing)
  (write thing)
  (finish-output))

(defun say-line (string)
  (write-line string)
  (finish-output))

(defun show (thing)
  (princ thing)
  (finish-output))

(defun show-value (value)
  (print value)
  (finish-output))

;; Keeps asking until an integer is typed.
(defun read-position ()
  (loop
    (say '?)
    (let ((input (read)))
      (when (integerp input)
        (return input)))
    (say-line "invalid input")))

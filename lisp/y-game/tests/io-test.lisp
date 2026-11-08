;;;; Specs for io.lisp. Run with: sbcl --script lisp/y-game/tests/io-test.lisp

(load (merge-pathnames "helper.lisp" (or *load-truename* *default-pathname-defaults*)))

(defmacro output-of (&body body)
  `(with-output-to-string (*standard-output*) ,@body))

(deftest say-writes-a-readable-form
  (check "\"Ring\"" (output-of (say "Ring")))
  (check "?" (output-of (say '?))))

(deftest say-line-writes-the-string-and-a-newline
  (check (format nil "Player A~%") (output-of (say-line "Player A"))))

(deftest show-writes-without-quotes
  (check "X" (output-of (show 'X)))
  (check " " (output-of (show " "))))

(deftest show-value-starts-a-new-line
  (check (format nil "~%3 ") (output-of (show-value 3))))

(deftest read-position-returns-the-integer-typed
  (with-input-from-string (*standard-input* "7")
    (check 7 (quietly #'read-position))))

(defun occurrences (needle haystack)
  (loop with start = 0
        for found = (search needle haystack :start2 start)
        while found
        count t
        do (setf start (1+ found))))

(deftest read-position-asks-again-until-it-gets-an-integer
  (with-input-from-string (*standard-input* "foo (1 2) 4")
    (let* ((position nil)
           (output (output-of (setf position (read-position)))))
      (check 4 position)
      (check 2 (occurrences "invalid input" output) "invalid input messages:")
      (check 3 (occurrences "?" output) "prompts:"))))

(end-of-tests)

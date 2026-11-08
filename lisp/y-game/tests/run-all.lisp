;;;; Runs every test file. Run with: sbcl --script lisp/y-game/tests/run-all.lisp

(defvar *running-all* t)
(let ((here (or *load-truename* *default-pathname-defaults*)))
  (load (merge-pathnames "helper.lisp" here))
  (dolist (file '("io" "board" "state" "heuristics" "search" "players" "match"))
    (format t "== ~a.lisp~%" file)
    (load (merge-pathnames (make-pathname :name (format nil "~a-test" file) :type "lisp") here))))
(report-results)

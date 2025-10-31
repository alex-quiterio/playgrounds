;;;; Day 1: Sonar Sweep
(require '[clojure.string :as str])

(defn increases
  "How many measurements are larger than the one `gap` places before them."
  [depths gap]
  (count (filter true? (map < depths (drop gap depths)))))

(let [depths (->> (slurp (first *command-line-args*))
                  str/split-lines
                  (remove str/blank?)
                  (map parse-long))]
  (println (increases depths 1))
  ;; Comparing sliding windows of three: a+b+c < b+c+d only depends on a < d.
  (println (increases depths 3)))

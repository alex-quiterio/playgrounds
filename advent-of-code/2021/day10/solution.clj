;;;; Day 10: Syntax Scoring
(require '[clojure.string :as str])

(def lines (remove str/blank? (str/split-lines (slurp (first *command-line-args*)))))
(def closer {\( \), \[ \], \{ \}, \< \>})

(defn check
  "Either [:corrupted first-bad-char] or [:incomplete closers-still-expected]."
  [line]
  (loop [[ch & more] line, expected ()]
    (cond
      (nil? ch) [:incomplete expected]
      (closer ch) (recur more (conj expected (closer ch)))
      (= ch (first expected)) (recur more (rest expected))
      :else [:corrupted ch])))

(def results (map check lines))

(println (reduce + (for [[kind ch] results :when (= kind :corrupted)]
                     ({\) 3, \] 57, \} 1197, \> 25137} ch))))
(let [scores (sort (for [[kind expected] results :when (= kind :incomplete)]
                     (reduce #(+ (* 5 %1) ({\) 1, \] 2, \} 3, \> 4} %2)) 0 expected)))]
  (println (nth scores (quot (count scores) 2))))

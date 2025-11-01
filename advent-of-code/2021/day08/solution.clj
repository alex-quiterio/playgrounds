;;;; Day 8: Seven Segment Search
(require '[clojure.string :as str]
         '[clojure.set :as set])

(def entries
  (for [line (str/split-lines (slurp (first *command-line-args*)))
        :when (not (str/blank? line))
        :let [[patterns output] (str/split line #" \| ")]]
    [(map set (str/split patterns #" ")) (map set (str/split output #" "))]))

(defn decode
  "Works out which wire pattern is which digit from how the patterns overlap."
  [patterns]
  (let [sized (fn [n] (filter #(= n (count %)) patterns))
        one (first (sized 2)), four (first (sized 4))
        seven (first (sized 3)), eight (first (sized 7))
        nine (first (filter #(set/subset? four %) (sized 6)))
        zero (first (filter #(and (not= nine %) (set/subset? one %)) (sized 6)))
        six (first (remove #{nine zero} (sized 6)))
        three (first (filter #(set/subset? one %) (sized 5)))
        five (first (filter #(set/subset? % six) (sized 5)))
        two (first (remove #{three five} (sized 5)))]
    (zipmap [zero one two three four five six seven eight nine] (range))))

;; Part 1: 1, 4, 7 and 8 are the only digits with 2, 4, 3 and 7 segments.
(println (count (filter #(#{2 3 4 7} (count %)) (mapcat second entries))))
(println (reduce + (for [[patterns output] entries
                         :let [digit (decode patterns)]]
                     (reduce #(+ (* 10 %1) (digit %2)) 0 output))))

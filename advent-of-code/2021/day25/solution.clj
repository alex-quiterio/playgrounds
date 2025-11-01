;;;; Day 25: Sea Cucumber
(require '[clojure.string :as str])

(def start (mapv vec (remove str/blank? (str/split-lines (slurp (first *command-line-args*))))))
(def rows (count start))
(def cols (count (first start)))

(defn move
  "Move every cucumber of `herd` that faces an empty cell, all at once."
  [grid herd [dr dc]]
  (let [movers (for [r (range rows), c (range cols)
                     :when (= herd (get-in grid [r c]))
                     :let [to [(mod (+ r dr) rows) (mod (+ c dc) cols)]]
                     :when (= \. (get-in grid to))]
                 [[r c] to])]
    (reduce (fn [g [from to]] (-> g (assoc-in from \.) (assoc-in to herd))) grid movers)))

(defn step [grid] (-> grid (move \> [0 1]) (move \v [1 0])))

(println (loop [grid start, n 1]
           (let [next (step grid)]
             (if (= next grid) n (recur next (inc n))))))

;;;; Day 1: Report Repair
(require '[clojure.string :as str])

(defn product-summing-to
  "Product of the first `n` entries that add up to `target`."
  [entries n target]
  (let [present (set entries)]
    (case n
      2 (first (for [a entries
                     :let [b (- target a)]
                     :when (and (present b) (not= a b))]
                 (* a b)))
      3 (first (for [[i a] (map-indexed vector entries)
                     b (drop (inc i) entries)
                     :let [c (- target a b)]
                     :when (and (present c) (not= c a) (not= c b))]
                 (* a b c))))))

(let [entries (->> (slurp (first *command-line-args*))
                   str/split-lines
                   (remove str/blank?)
                   (mapv parse-long))]
  (println (product-summing-to entries 2 2020))
  (println (product-summing-to entries 3 2020)))

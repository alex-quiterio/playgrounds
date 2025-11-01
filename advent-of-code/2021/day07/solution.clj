;;;; Day 7: The Treachery of Whales
(require '[clojure.string :as str])

(def crabs (map parse-long (str/split (str/trim (slurp (first *command-line-args*))) #",")))

(defn cheapest
  "The least fuel to line every crab up, when moving n steps costs (cost n)."
  [cost]
  (apply min (for [p (range (apply min crabs) (inc (apply max crabs)))]
               (reduce + (map #(cost (abs (- % p))) crabs)))))

(println (cheapest identity))
;; Each step costs one more than the last: 1 + 2 + ... + n.
(println (cheapest #(quot (* % (inc %)) 2)))

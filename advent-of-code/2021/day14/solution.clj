;;;; Day 14: Extended Polymerization
(require '[clojure.string :as str])

(def lines (remove str/blank? (str/split-lines (slurp (first *command-line-args*)))))
(def template (first lines))
(def rules (into {} (for [line (rest lines) :let [[[a b] [c]] (str/split line #" -> ")]]
                      [[a b] c])))

;; The polymer doubles every step, so only count pairs: AB with rule AB -> C
;; becomes one AC and one CB.
(defn step [pairs]
  (reduce-kv (fn [m [a b] n]
               (let [c (rules [a b])]
                 (-> m (update [a c] (fnil + 0) n) (update [c b] (fnil + 0) n))))
             {} pairs))

(defn spread
  "Most common minus least common element. Counting each pair's first element
  misses only the polymer's last element, which never changes."
  [pairs]
  (let [counts (reduce-kv (fn [m [a _] n] (update m a (fnil + 0) n))
                          {(last template) 1} pairs)]
    (- (apply max (vals counts)) (apply min (vals counts)))))

(def polymers (iterate step (frequencies (partition 2 1 template))))
(println (spread (nth polymers 10)))
(println (spread (nth polymers 40)))

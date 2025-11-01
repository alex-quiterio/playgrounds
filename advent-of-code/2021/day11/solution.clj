;;;; Day 11: Dumbo Octopus
(require '[clojure.string :as str])

(def start
  (into {} (for [[r line] (map-indexed vector (remove str/blank? (str/split-lines (slurp (first *command-line-args*)))))
                 [c ch] (map-indexed vector line)]
             [[r c] (- (int ch) (int \0))])))

(defn neighbours [[r c]]
  (for [dr [-1 0 1], dc [-1 0 1] :when (not= 0 dr dc)] [(+ r dr) (+ c dc)]))

(defn step
  "One step: every octopus gains one, anything above 9 flashes into its neighbours,
  and the ones that flashed go back to 0."
  [grid]
  (loop [grid (update-vals grid inc)
         flashed #{}]
    (let [ready (remove flashed (filter #(> (grid %) 9) (keys grid)))]
      (if (empty? ready)
        (reduce #(assoc %1 %2 0) grid flashed)
        (recur (reduce (fn [g p] (if (contains? g p) (update g p inc) g))
                       grid (mapcat neighbours ready))
               (into flashed ready))))))

(def steps (iterate step start))
(defn flashes [grid] (count (filter zero? (vals grid))))

(println (reduce + (map flashes (take 100 (rest steps)))))
(println (first (keep-indexed #(when (= (count start) (flashes %2)) %1) steps)))

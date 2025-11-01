;;;; Day 20: Trench Map
(require '[clojure.string :as str])

(def sections (str/split (str/trim (slurp (first *command-line-args*))) #"\n\s*\n"))
(def algorithm (mapv #(= \# %) (first sections)))
(def image (mapv (fn [row] (mapv #(= \# %) row)) (str/split-lines (second sections))))

(defn enhance
  "Grows the image by one pixel on each side. The infinite background is all
  `background`, and it flips too when the algorithm maps 0 to lit."
  [[grid background]]
  (let [h (count grid), w (count (first grid))
        lit? (fn [r c] (get-in grid [r c] background))]
    [(vec (for [r (range -1 (inc h))]
            (vec (for [c (range -1 (inc w))]
                   (algorithm (reduce (fn [n [dr dc]] (+ (* 2 n) (if (lit? (+ r dr) (+ c dc)) 1 0)))
                                      0
                                      (for [dr [-1 0 1], dc [-1 0 1]] [dr dc])))))))
     (algorithm (if background 511 0))]))

(defn lit-after [steps]
  (let [[grid _] (nth (iterate enhance [image false]) steps)]
    (count (filter true? (flatten grid)))))

(println (lit-after 2))
(println (lit-after 50))

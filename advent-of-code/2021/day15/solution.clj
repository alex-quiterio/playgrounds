;;;; Day 15: Chiton
(require '[clojure.string :as str])
(import '[java.util PriorityQueue])

(def tile (vec (for [line (str/split-lines (slurp (first *command-line-args*)))
                     :when (not (str/blank? line))]
                 (mapv #(- (int %) (int \0)) line))))

(defn tiled
  "The full map is the tile repeated 5x5, each copy one riskier (wrapping 9 to 1)."
  [tile]
  (let [h (count tile), w (count (first tile))]
    (vec (for [r (range (* 5 h))]
           (vec (for [c (range (* 5 w))]
                  (inc (mod (+ (get-in tile [(mod r h) (mod c w)]) (quot r h) (quot c w) -1) 9))))))))

(defn lowest-risk
  "Dijkstra from the top left to the bottom right corner."
  [grid]
  (let [h (count grid), w (count (first grid))
        best (long-array (* h w) Long/MAX_VALUE)
        queue (PriorityQueue.)
        goal (dec (* h w))]
    (aset best 0 0)
    (.add queue [0 0])
    (loop []
      (let [[d i] (.poll queue)]
        (cond
          (= i goal) d
          (> d (aget best i)) (recur)
          :else
          (let [r (quot i w), c (mod i w)]
            (doseq [[nr nc] [[(dec r) c] [(inc r) c] [r (dec c)] [r (inc c)]]
                    :when (and (< -1 nr h) (< -1 nc w))
                    :let [j (+ (* nr w) nc), nd (+ d (get-in grid [nr nc]))]
                    :when (< nd (aget best j))]
              (aset best j nd)
              (.add queue [nd j]))
            (recur)))))))

(println (lowest-risk tile))
(println (lowest-risk (tiled tile)))

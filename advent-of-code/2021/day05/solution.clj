;;;; Day 5: Hydrothermal Venture
(require '[clojure.string :as str])

(def lines
  (for [line (str/split-lines (slurp (first *command-line-args*)))
        :when (not (str/blank? line))]
    (map parse-long (re-seq #"\d+" line))))

(defn points
  "Every point on a horizontal, vertical or 45-degree line."
  [[x1 y1 x2 y2]]
  (let [dx (Long/signum (- x2 x1))
        dy (Long/signum (- y2 y1))
        steps (max (abs (- x2 x1)) (abs (- y2 y1)))]
    (for [i (range (inc steps))]
      [(+ x1 (* i dx)) (+ y1 (* i dy))])))

(defn overlaps [lines]
  (count (filter #(>= % 2) (vals (frequencies (mapcat points lines))))))

(defn straight? [[x1 y1 x2 y2]] (or (= x1 x2) (= y1 y2)))

(println (overlaps (filter straight? lines)))
(println (overlaps lines))

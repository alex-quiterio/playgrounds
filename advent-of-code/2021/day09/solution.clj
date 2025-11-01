;;;; Day 9: Smoke Basin
(require '[clojure.string :as str])

(def heights
  (vec (for [line (str/split-lines (slurp (first *command-line-args*)))
             :when (not (str/blank? line))]
         (mapv #(- (int %) (int \0)) line))))

(defn height [[r c]] (get-in heights [r c]))

(defn neighbours [[r c]]
  (filter height [[(dec r) c] [(inc r) c] [r (dec c)] [r (inc c)]]))

(def low-points
  (for [r (range (count heights)), c (range (count (first heights)))
        :let [p [r c]]
        :when (every? #(< (height p) (height %)) (neighbours p))]
    p))

(defn basin
  "Every point that flows down to `low`: flood out until the 9s."
  [low]
  (loop [seen #{low}, todo [low]]
    (if-let [p (peek todo)]
      (let [more (remove #(or (seen %) (= 9 (height %))) (neighbours p))]
        (recur (into seen more) (into (pop todo) more)))
      seen)))

(println (reduce + (map #(inc (height %)) low-points)))
(println (->> low-points (map (comp count basin)) (sort >) (take 3) (reduce *)))

;;;; Day 19: Beacon Scanner
(require '[clojure.string :as str])

(def scanners
  (for [block (str/split (str/trim (slurp (first *command-line-args*))) #"\n\s*\n")]
    (mapv #(mapv parse-long (str/split % #","))
          (rest (str/split-lines block)))))

(def rotations
  "The 24 ways a scanner can face: signed axis permutations with determinant 1."
  (let [det (fn [[[a b c] [d e f] [g h i]]]
              (- (+ (* a e i) (* b f g) (* c d h)) (* c e g) (* b d i) (* a f h)))]
    (for [[x y z] [[0 1 2] [0 2 1] [1 0 2] [1 2 0] [2 0 1] [2 1 0]]
          sx [1 -1] sy [1 -1] sz [1 -1]
          :let [m (mapv (fn [axis sign] (assoc [0 0 0] axis sign)) [x y z] [sx sy sz])]
          :when (= 1 (det m))]
      (fn [p] (mapv #(reduce + (map * % p)) m)))))

(defn v- [a b] (mapv - a b))
(defn v+ [a b] (mapv + a b))

(defn align
  "Places `beacons` relative to an already placed scanner's beacons: a rotation
  and offset that makes at least 12 of them coincide. Returns [offset placed]."
  [known beacons]
  (first
   (for [rotate rotations
         :let [turned (map rotate beacons)
               [offset hits] (apply max-key val (frequencies (for [k known, b turned] (v- k b))))]
         :when (>= hits 12)]
     [offset (mapv #(v+ offset %) turned)])))

(def placed
  "Every scanner as [position beacons], all in scanner 0's coordinates."
  (loop [queue [[[0 0 0] (first scanners)]]
         unplaced (vec (rest scanners))
         done []]
    (if (empty? queue)
      done
      (let [[_ known :as current] (first queue)
            found (keep (fn [s] (when-let [hit (align known s)] [s hit])) unplaced)
            found-set (set (map first found))]
        (recur (into (subvec queue 1) (map second found))
               (vec (remove found-set unplaced))
               (conj done current))))))

(println (count (set (mapcat second placed))))
(println (apply max (for [[a _] placed, [b _] placed]
                      (reduce + (map abs (v- a b))))))

;;;; Day 22: Reactor Reboot
(require '[clojure.string :as str])

(def steps
  (for [line (str/split-lines (slurp (first *command-line-args*)))
        :when (not (str/blank? line))]
    [(str/starts-with? line "on") (mapv parse-long (re-seq #"-?\d+" line))]))

(defn overlap
  "The cuboid two cuboids share, or nil."
  [a b]
  (let [c (vec (mapcat (fn [i] [(max (a i) (b i)) (min (a (inc i)) (b (inc i)))]) [0 2 4]))]
    (when (every? #(<= (c %) (c (inc %))) [0 2 4]) c)))

(defn volume [c]
  (reduce * (map #(inc (- (c (inc %)) (c %))) [0 2 4])))

(defn lit
  "Inclusion-exclusion: keep signed cuboids, cancelling every overlap with a new step."
  [steps]
  (let [signed (reduce (fn [signed [on? cuboid]]
                         (let [cancel (keep (fn [[c sign]] (some-> (overlap c cuboid) (vector (- sign)))) signed)
                               signed (into signed cancel)]
                           (if on? (conj signed [cuboid 1]) signed)))
                       [] steps)]
    (reduce + (map (fn [[c sign]] (* sign (volume c))) signed))))

(defn initialization? [[_ c]] (every? #(<= -50 % 50) c))

(println (lit (filter initialization? steps)))
(println (lit steps))

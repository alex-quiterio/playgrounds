;;;; Day 18: Snailfish
(require '[clojure.string :as str])

;; A snailfish number is kept flat: a vector of [value depth] for each regular
;; number, left to right, where depth counts the pairs around it.

(defn parse [line]
  (loop [[c & more] line, depth 0, out []]
    (cond
      (nil? c) out
      (= c \[) (recur more (inc depth) out)
      (= c \]) (recur more (dec depth) out)
      (Character/isDigit c) (recur more depth (conj out [(Character/digit c 10) depth]))
      :else (recur more depth out))))

(defn explode
  "Explodes the leftmost pair nested inside four pairs, or returns nil."
  [n]
  (when-let [i (first (keep-indexed (fn [i [_ d]] (when (> d 4) i)) n))]
    (let [[a d] (n i), [b _] (n (inc i))
          n (cond-> n
              (pos? i) (update-in [(dec i) 0] + a)
              (< (+ i 2) (count n)) (update-in [(+ i 2) 0] + b))]
      (vec (concat (subvec n 0 i) [[0 (dec d)]] (subvec n (+ i 2)))))))

(defn split
  "Splits the leftmost number of 10 or more into a pair, or returns nil."
  [n]
  (when-let [i (first (keep-indexed (fn [i [v _]] (when (>= v 10) i)) n))]
    (let [[v d] (n i)]
      (vec (concat (subvec n 0 i)
                   [[(quot v 2) (inc d)] [(- v (quot v 2)) (inc d)]]
                   (subvec n (inc i)))))))

(defn reduce-number [n]
  (if-let [n' (or (explode n) (split n))]
    (recur n')
    n))

(defn add [a b]
  (reduce-number (mapv (fn [[v d]] [v (inc d)]) (concat a b))))

(defn magnitude
  "Folds the deepest pair (always two siblings) into 3a + 2b until one number is left."
  [n]
  (if (= 1 (count n))
    (first (first n))
    (let [deepest (apply max (map second n))
          i (first (keep-indexed (fn [i [_ d]] (when (= d deepest) i)) n))
          [[a d] [b _]] [(n i) (n (inc i))]]
      (recur (vec (concat (subvec n 0 i) [[(+ (* 3 a) (* 2 b)) (dec d)]] (subvec n (+ i 2))))))))

(def numbers
  (map parse (remove str/blank? (str/split-lines (slurp (first *command-line-args*))))))

(println (magnitude (reduce add numbers)))
(println (apply max (for [a numbers, b numbers, :when (not= a b)]
                      (magnitude (add a b)))))

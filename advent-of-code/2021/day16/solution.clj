;;;; Day 16: Packet Decoder
(require '[clojure.string :as str])

(def bits
  (apply str (for [ch (str/trim (slurp (first *command-line-args*)))]
               (let [b (Integer/toBinaryString (Character/digit ch 16))]
                 (str (subs "0000" (count b)) b)))))

(defn number [from to] (Long/parseLong (subs bits from to) 2))

(declare packet)

(defn literal
  "Groups of five bits: a continue bit and four bits of the number."
  [at]
  (loop [at at, value 0]
    (let [value (+ (* 16 value) (number (inc at) (+ at 5)))]
      (if (= \1 (nth bits at))
        (recur (+ at 5) value)
        [value (+ at 5)]))))

(defn sub-packets
  "Length type 0: the sub-packets span the next 15-bit count of bits.
  Length type 1: there are the next 11-bit count of them."
  [at]
  (if (= \0 (nth bits at))
    (let [end (+ at 16 (number (inc at) (+ at 16)))]
      (loop [at (+ at 16), found []]
        (if (< at end)
          (let [[p at] (packet at)] (recur at (conj found p)))
          [found at])))
    (let [n (number (inc at) (+ at 12))]
      (loop [at (+ at 12), found []]
        (if (< (count found) n)
          (let [[p at] (packet at)] (recur at (conj found p)))
          [found at])))))

(defn packet
  "Reads the packet starting at bit `at`; returns it and where it ends."
  [at]
  (let [version (number at (+ at 3))
        type (number (+ at 3) (+ at 6))]
    (if (= type 4)
      (let [[value end] (literal (+ at 6))]
        [{:version version :type type :value value} end])
      (let [[children end] (sub-packets (+ at 6))]
        [{:version version :type type :children children} end]))))

(defn version-sum [p] (reduce + (:version p) (map version-sum (:children p))))

(defn evaluate [{:keys [type value children]}]
  (let [args (map evaluate children)
        compare (fn [f] (if (apply f args) 1 0))]
    (case type
      0 (reduce + args)
      1 (reduce * args)
      2 (apply min args)
      3 (apply max args)
      4 value
      5 (compare >)
      6 (compare <)
      7 (compare =))))

(let [[root] (packet 0)]
  (println (version-sum root))
  (println (evaluate root)))

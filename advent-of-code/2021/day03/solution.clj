;;;; Day 3: Binary Diagnostic
(require '[clojure.string :as str])

(def report (remove str/blank? (str/split-lines (slurp (first *command-line-args*)))))

(defn most-common
  "The most common bit at position i; ties go to 1."
  [numbers i]
  (let [ones (count (filter #(= \1 (nth % i)) numbers))]
    (if (>= (* 2 ones) (count numbers)) \1 \0)))

(defn flip [bit] (if (= bit \1) \0 \1))
(defn binary [bits] (Long/parseLong (apply str bits) 2))

(defn rating
  "Keep the numbers whose bit i matches the criterion, one position at a time."
  [criterion]
  (loop [numbers report, i 0]
    (if (= 1 (count numbers))
      (binary (first numbers))
      (let [bit (criterion (most-common numbers i))]
        (recur (filter #(= bit (nth % i)) numbers) (inc i))))))

(let [gamma (map #(most-common report %) (range (count (first report))))]
  (println (* (binary gamma) (binary (map flip gamma)))))
(println (* (rating identity) (rating flip)))

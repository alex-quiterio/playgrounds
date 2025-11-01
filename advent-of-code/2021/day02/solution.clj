;;;; Day 2: Dive!
(require '[clojure.string :as str])

(def commands
  (for [line (str/split-lines (slurp (first *command-line-args*)))
        :when (not (str/blank? line))
        :let [[dir n] (str/split line #" ")]]
    [(keyword dir) (parse-long n)]))

(defn steer
  "Part 1: up and down change the depth directly."
  [[x depth] [dir n]]
  (case dir
    :forward [(+ x n) depth]
    :down [x (+ depth n)]
    :up [x (- depth n)]))

(defn aim
  "Part 2: up and down change the aim; forward moves along it."
  [[x depth aim] [dir n]]
  (case dir
    :forward [(+ x n) (+ depth (* aim n)) aim]
    :down [x depth (+ aim n)]
    :up [x depth (- aim n)]))

(let [[x depth] (reduce steer [0 0] commands)]
  (println (* x depth)))
(let [[x depth] (reduce aim [0 0 0] commands)]
  (println (* x depth)))

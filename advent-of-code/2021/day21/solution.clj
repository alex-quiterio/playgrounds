;;;; Day 21: Dirac Dice

(def starts (map #(parse-long (re-find #"\d+$" %))
                 (re-seq #"(?m)^.*position: \d+" (slurp (first *command-line-args*)))))

(defn move [pos roll] (inc (mod (+ pos roll -1) 10)))

(defn practice
  "Part 1: a deterministic die rolling 1..100; the loser's score times the rolls."
  [[p1 p2]]
  (loop [die (cycle (range 1 101)), rolls 0, [pos score] [p1 0], [other-pos other-score] [p2 0]]
    (let [pos (move pos (reduce + (take 3 die)))
          score (+ score pos)
          rolls (+ rolls 3)]
      (if (>= score 1000)
        (* other-score rolls)
        (recur (drop 3 die) rolls [other-pos other-score] [pos score])))))

(def dirac-rolls
  "How many of the 27 universes give each total of three rolls."
  (frequencies (for [a [1 2 3], b [1 2 3], c [1 2 3]] (+ a b c))))

(def wins
  "[wins for the player about to move, wins for the other] from this state."
  (memoize
   (fn [pos score other-pos other-score]
     (reduce (fn [[mine theirs] [roll universes]]
               (let [pos (move pos roll), score (+ score pos)]
                 (if (>= score 21)
                   [(+ mine universes) theirs]
                   (let [[o m] (wins other-pos other-score pos score)]
                     [(+ mine (* universes m)) (+ theirs (* universes o))]))))
             [0 0]
             dirac-rolls))))

(println (practice starts))
(println (apply max (wins (first starts) 0 (second starts) 0)))

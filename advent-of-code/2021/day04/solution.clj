;;;; Day 4: Giant Squid
(require '[clojure.string :as str])

(def sections (str/split (str/trim (slurp (first *command-line-args*))) #"\n\s*\n"))
(def draws (map parse-long (str/split (first sections) #",")))
(def boards
  (for [board (rest sections)]
    (mapv #(mapv parse-long (str/split (str/trim %) #"\s+")) (str/split-lines board))))

(defn wins?
  "A board wins when a whole row or column has been drawn."
  [drawn board]
  (some #(every? drawn %) (concat board (apply map vector board))))

(defn score [drawn board last-draw]
  (* last-draw (reduce + (remove drawn (flatten board)))))

(def scores
  "Each board's score in the order the boards win."
  (loop [[n & more] draws, drawn #{}, boards boards, scores []]
    (if (or (nil? n) (empty? boards))
      scores
      (let [drawn (conj drawn n)
            {won true playing false} (group-by #(boolean (wins? drawn %)) boards)]
        (recur more drawn playing (into scores (map #(score drawn % n) won)))))))

(println (first scores))
(println (last scores))

;;;; Day 1: The Tyranny of the Rocket Equation
(require '[clojure.string :as str])

(defn fuel [mass] (- (quot mass 3) 2))

(defn total-fuel
  "Fuel for the mass, plus fuel for that fuel, until it needs none."
  [mass]
  (->> (iterate fuel mass)
       rest
       (take-while pos?)
       (reduce +)))

(let [masses (->> (slurp (first *command-line-args*))
                  str/split-lines
                  (remove str/blank?)
                  (map parse-long))]
  (println (reduce + (map fuel masses)))
  (println (reduce + (map total-fuel masses))))

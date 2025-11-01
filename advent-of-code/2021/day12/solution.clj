;;;; Day 12: Passage Pathing
(require '[clojure.string :as str])

(def caves
  (reduce (fn [m [a b]] (-> m (update a conj b) (update b conj a)))
          {}
          (for [line (str/split-lines (slurp (first *command-line-args*)))
                :when (not (str/blank? line))]
            (str/split line #"-"))))

(defn small? [cave] (= cave (str/lower-case cave)))

(defn paths
  "How many paths lead from `cave` to end. `seen` holds the small caves already
  visited; `spare` is whether one of them may still be visited a second time."
  [cave seen spare]
  (if (= cave "end")
    1
    (reduce + (for [next (caves cave)
                    :when (not= next "start")
                    :let [again (seen next)]
                    :when (or (not again) spare)]
                (paths next (if (small? next) (conj seen next) seen) (and spare (not again)))))))

(println (paths "start" #{"start"} false))
(println (paths "start" #{"start"} true))

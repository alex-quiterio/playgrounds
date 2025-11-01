;;;; Day 24: Arithmetic Logic Unit
;;; MONAD is 14 blocks, one per digit, that differ only in three constants:
;;; `div z` (1 pushes a base-26 digit onto z, 26 pops one), `add x A` and
;;; `add y B`. A push of w_j + B_j is popped by a later block i, and z only
;;; ends at 0 if every pop matches, which means w_i = w_j + B_j + A_i.
(require '[clojure.string :as str])

(def blocks
  (for [block (rest (str/split (slurp (first *command-line-args*)) #"inp w\n"))
        :let [lines (str/split-lines block)
              arg #(parse-long (last (str/split (nth lines %) #" ")))]]
    {:pop? (= 26 (arg 3)) :a (arg 4) :b (arg 14)}))

(def pairs
  "[j i offset] for each pushed digit j popped at i, with w_i = w_j + offset."
  (first
   (reduce (fn [[pairs stack] [i {:keys [pop? a b]}]]
             (if pop?
               (let [[j bj] (peek stack)]
                 [(conj pairs [j i (+ bj a)]) (pop stack)])
               [pairs (conj stack [i b])]))
           [[] []] (map-indexed vector blocks))))

(defn model-number
  "Pick each pair's first digit with `choose` among the ones that keep both in 1..9."
  [choose]
  (let [digits (reduce (fn [digits [j i offset]]
                         (let [wj (choose (filter #(<= 1 (+ % offset) 9) (range 1 10)))]
                           (assoc digits j wj i (+ wj offset))))
                       (vec (repeat 14 0)) pairs)]
    (apply str digits)))

(println (model-number last))
(println (model-number first))

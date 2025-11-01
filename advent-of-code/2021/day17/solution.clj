;;;; Day 17: Trick Shot
(def target (map parse-long (re-seq #"-?\d+" (slurp (first *command-line-args*)))))
(def x-min (nth target 0)) (def x-max (nth target 1))
(def y-min (nth target 2)) (def y-max (nth target 3))

(defn hits?
  "Does a probe launched at (vx, vy) ever stop inside the target area?
  Assumes the target lies to the right and below the launcher."
  [vx vy]
  (loop [x 0, y 0, vx vx, vy vy]
    (cond
      (and (<= x-min x x-max) (<= y-min y y-max)) true
      (or (> x x-max) (< y y-min)) false
      :else (recur (+ x vx) (+ y vy) (max 0 (dec vx)) (dec vy)))))

;; Going up at vy, the probe comes back down through y = 0 at speed -(vy + 1),
;; so it can go no faster than |y-min| - 1 upward without overshooting.
(def hits (for [vx (range 0 (inc x-max)), vy (range y-min (- y-min))
                :when (hits? vx vy)]
            vy))

(let [vy (apply max hits)]
  (println (quot (* vy (inc vy)) 2)))
(println (count hits))

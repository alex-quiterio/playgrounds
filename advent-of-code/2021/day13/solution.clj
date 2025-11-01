;;;; Day 13: Transparent Origami
(require '[clojure.string :as str])

(def lines (str/split-lines (slurp (first *command-line-args*))))
(def dots (set (for [line lines :when (re-find #"^\d" line)]
                 (mapv parse-long (str/split line #",")))))
(def folds (for [line lines :when (str/starts-with? line "fold")
                 :let [[_ axis n] (re-find #"([xy])=(\d+)" line)]]
             [(if (= axis "x") 0 1) (parse-long n)]))

(defn fold
  "Folds the paper along a line: dots past it are mirrored back over it."
  [dots [axis n]]
  (set (map #(update % axis (fn [v] (if (> v n) (- (* 2 n) v) v))) dots)))

;; The letters the code is drawn in: 4 columns wide, 6 rows tall, 1 column apart.
(def font
  {".##.#..##..######..##..#" \A, "###.#..####.#..##..####." \B, ".##.#..##...#...#..#.##." \C
   "#####...###.#...#...####" \E, "#####...###.#...#...#..." \F, ".##.#..##...#.###..#.###" \G
   "#..##..######..##..##..#" \H, ".###..#...#...#...#..###" \I, "..##...#...#...##..#.##." \J
   "#..##.#.##..#.#.#.#.#..#" \K, "#...#...#...#...#...####" \L, ".##.#..##..##..##..#.##." \O
   "###.#..##..####.#...#..." \P, "###.#..##..####.#.#.#..#" \R, ".####...#....##....####." \S
   "#..##..##..##..##..#.##." \U, "#...#....#.#..#...#...#." \Y, "####...#..#..#..#...####" \Z})

(defn read-code [dots]
  (let [width (inc (apply max (map first dots)))]
    (apply str (for [x0 (range 0 width 5)]
                 (get font (apply str (for [y (range 6), x (range x0 (+ x0 4))]
                                        (if (dots [x y]) \# \.)))
                      \?)))))

(println (count (fold dots (first folds))))
(println (read-code (reduce fold dots folds)))

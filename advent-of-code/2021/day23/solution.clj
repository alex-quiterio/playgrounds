;;;; Day 23: Amphipod
;;; A burrow is a string: the 11 hallway cells, then each room top to bottom.
(require '[clojure.string :as str])
(import '(java.util PriorityQueue))

(def energy {\A 1 \B 10 \C 100 \D 1000})
(def doors [2 4 6 8])
(def halls (remove (set doors) (range 11)))

(defn slot [depth room d] (+ 11 (* room depth) d))
(defn home [c] (- (int c) (int \A)))

(defn clear?
  "Is the hallway free between cells a and b, both ends included?"
  [burrow a b]
  (every? #(= \. (.charAt ^String burrow %)) (range (min a b) (inc (max a b)))))

(defn move [^String burrow from to]
  (let [sb (StringBuilder. burrow)]
    (.setCharAt sb to (.charAt burrow from))
    (.setCharAt sb from \.)
    (str sb)))

(defn room [^String burrow depth r] (map #(.charAt burrow (slot depth r %)) (range depth)))

(defn moves-home
  "Amphipods in the hallway that can walk straight into a room holding only their kind."
  [^String burrow depth]
  (for [h halls
        :let [c (.charAt burrow h)]
        :when (not= c \.)
        :let [r (home c), door (doors r), cells (room burrow depth r)]
        :when (every? #{\. c} cells)
        :when (clear? burrow (if (< h door) (inc h) (dec h)) door)
        :let [d (dec (count (take-while #{\.} cells)))]]
    [(* (energy c) (+ (abs (- h door)) d 1)) (move burrow h (slot depth r d))]))

(defn moves-out
  "The top amphipod of each unfinished room stepping out to any reachable hallway cell."
  [^String burrow depth]
  (for [r (range 4)
        :let [cells (room burrow depth r)
              d (count (take-while #{\.} cells))]
        :when (< d depth)
        :when (not (every? #(= r (home %)) (drop d cells)))
        :let [c (nth cells d), door (doors r)]
        h halls
        :when (clear? burrow h door)]
    [(* (energy c) (+ (abs (- h door)) d 1)) (move burrow (slot depth r d) h)]))

(defn least-energy
  "Dijkstra over burrows. Going home is never a mistake, so when one is possible it is the only move."
  [start depth]
  (let [goal (str (apply str (repeat 11 \.)) (apply str (mapcat #(repeat depth %) "ABCD")))
        queue (PriorityQueue. 1024 (comparator #(< (first %1) (first %2))))
        best (java.util.HashMap.)]
    (.add queue [0 start])
    (.put best start 0)
    (loop []
      (let [[cost burrow] (.poll queue)]
        (cond
          (= burrow goal) cost
          (> cost (.get best burrow)) (recur)
          :else
          (let [home-moves (moves-home burrow depth)]
            (doseq [[step next] (if (seq home-moves) (take 1 home-moves) (moves-out burrow depth))
                    :let [total (+ cost step), known (.get best next)]
                    :when (or (nil? known) (< total known))]
              (.put best next total)
              (.add queue [total next]))
            (recur)))))))

(defn burrow
  "Hallway plus rooms from the diagram's room rows (one string of four letters per row)."
  [rows]
  (str (apply str (repeat 11 \.))
       (apply str (for [r (range 4), row rows] (nth row r)))))

(def rows
  (->> (str/split-lines (slurp (first *command-line-args*)))
       (map #(apply str (re-seq #"[A-D]" %)))
       (remove str/blank?)))

(println (least-energy (burrow rows) 2))
(println (least-energy (burrow [(first rows) "DCBA" "DBAC" (second rows)]) 4))

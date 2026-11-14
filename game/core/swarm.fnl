; swarm {
;   :size int
;   :x number
;   :y number
;   :target-x number|nil
;   :target-y number|nil
;   :is-selected boolean
;   :shape Shape
;   :update dt
; }

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.swarm))

(local collisions (require-mod! :core.collisions))

(local {: merge} (require :lib.lume))
(local {: pprint : car : cdr} (require :core.utils))

(local {: find} (require-mod! :core.utils))

(fn new [id size x y is-selected]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)
        shape (collisions.new-circle id x y size)]
    {: id : size : x : y : is-selected : shape}))

(fn render [swarm]
  (if swarm.is-selected
      (do
        (love.graphics.setColor 1 0 1)
        (love.graphics.circle :fill swarm.x swarm.y swarm.size)))
  (love.graphics.setColor 1 1 1)
  (love.graphics.circle :line swarm.x swarm.y swarm.size))

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (collisions.move-circle swarm.shape x-delta y-delta)
  (merge swarm {:x (+ swarm.x x-delta) :y (+ swarm.y y-delta)}))

(fn move-to-target [swarm dt]
  "returns a new swarm nearing the target location"
  (if (not dt) (print "move-to-target: argument dt not set"))
  (if (and (not= swarm.target-x nil) (not= swarm.target-y nil))
      (let [speed 50
            source [(. swarm :x) (. swarm :y)]
            target [swarm.target-x swarm.target-y]
            vec [(- (car target) (car source)) (- (cdr target) (cdr source))]
            len-vec (math.sqrt (+ (* (car vec) (car vec))
                                  (* (cdr vec) (cdr vec))))
            norm-vec [(/ (car vec) len-vec) (/ (cdr vec) len-vec)]]
        (pprint source)
        (merge swarm
               {:x (+ swarm.x (* (car norm-vec) dt speed))
                :y (+ swarm.y (* (cdr norm-vec) dt speed))}))
      swarm))

(fn set-target [swarm x y]
  "returns a swarm with the target coordinates set"
  (merge swarm {:target-x x :target-y y}))

(fn tick [swarm dt]
  (move-to-target swarm dt))

(fn check-mouse-in [swarm mouse-x mouse-y]
  (set swarm.is-selected (collisions.in-shape swarm.shape mouse-x mouse-y)))

(fn get-by-id [swarms id]
  (find (fn [sw] (= id sw._id)) swarms))

{: new : render : tick : set-target : check-mouse-in : get-by-id}

; swarm {
;   :size int
;   :x number
;   :y number
;   :target-x number|nil
;   :target-y number|nil
;   :is-selected boolean
; }

(local {: merge} (require :lib.lume))

(fn new [size x y is-selected]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)]
    {: size : x : y : is-selected}))

(fn render [swarm]
  (if swarm.is-selected
    (do (love.graphics.setColor 1 0 1) (love.graphics.circle :fill swarm.x swarm.y swarm.size))
  )
  (love.graphics.setColor 1 1 1) (love.graphics.circle :line swarm.x swarm.y swarm.size)
)

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (new swarm.size (+ swarm.x x-delta) (+ swarm.y y-delta)))

(fn set-target [swarm x y]
  (merge swarm {:target-x x :target-y y}))

(fn check-mouse-in [swarm mouse-x mouse-y]
(print swarm.x mouse-x mouse-y)

(local radius swarm.size)
(local d-x (- mouse-x swarm.x))
(local d-y (- mouse-y swarm.y))

(local radius-2 (* radius radius))
(local d-x-2 (* d-x d-x))
(local d-y-2 (* d-y d-y))

(if (>= radius-2 (+ d-x-2 d-y-2))
(do
(print "INSIDE")
(set swarm.is-selected true)
)
(do
(print "NOT INSIDE")
(set swarm.is-selected false)
))
)

{: new : render : move : set-target : check-mouse-in}

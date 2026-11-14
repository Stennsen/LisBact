(fn new [size x y]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)]
    {: size : x : y}))

(fn render [swarm]
  (love.graphics.circle :line swarm.x swarm.y swarm.size))

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (new swarm.size (+ swarm.x x-delta) (+ swarm.y y-delta)))

(fn check-mouse-in [swarm mouse-x mouse-y]
(print swarm.x mouse-x mouse-y)

(local radius swarm.size)
(local d-x (- mouse-x swarm.x))
(local d-y (- mouse-y swarm.y))

(local radius-2 (* radius radius))
(local d-x-2 (* d-x d-x))
(local d-y-2 (* d-y d-y))

(if (>= radius-2 (+ d-x-2 d-y-2))
(print "INSIDE")
; (print "NOT INSIDE"))
)

{: new : render : move : check-mouse-in}

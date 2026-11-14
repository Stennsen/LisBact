; swarm {
;   :size int
;   :x number
;   :y number
;   :target-x number|nil
;   :target-y number|nil
; }

(local {: merge} (require :lib.lume))

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

(fn set-target [swarm x y]
  (merge swarm {:target-x x :target-y y}))

{: new : render : move : set-target}

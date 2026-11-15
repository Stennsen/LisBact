; swarm {
;   :id int
;   :size int
;   :x number
;   :y number
;   :target-x number|nil
;   :target-y number|nil
;   :is-hovered boolean
;   :is-selected boolean
;   :fixture Fixture
;   :update dt
;   :stats SwarmStats
;   :cells Cells{} 
;   :is-enemy boolean
; }

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.swarm))

(local target-marker (require-mod! :core.target-marker))
(local SwarmStats (require :core.swarm-stats))
(local Cell (require :core.cell))

(local lume (require :lib.lume))

(local {: pprint : car : cdr : map : unset : point-on-circle : random-color} (require :core.utils))

(local {: find} (require-mod! :core.utils))

(local SPEED 2500)

(fn new [physics id size x y is-selected is-enemy]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)
        fixture (physics.new-circle id x y size)
        is-enemy (if (not is-enemy) false is-enemy)
        stats (SwarmStats:new is-enemy)
        cells (fcollect [_ 1 (stats:getUnitCount)]
                (Cell:new size (random-color 1) (random-color)))
        is-hovered false]
    {: id : size : x : y : is-hovered : is-selected : fixture : stats : is-enemy : cells}
  )
)

(fn render [swarm]
  (if (and (and swarm.target-x swarm.target-y (not swarm.is-enemy)))
      (target-marker.render swarm.target-x swarm.target-y))
  (if swarm.is-enemy
    (do
      (do
       (love.graphics.setColor 0 0 0)
        (love.graphics.circle :fill swarm.x swarm.y swarm.size)
      )
      (let [hp-max-bar-width (* (swarm.stats:getMaxHealth) 5)
            hp-curr-bar-width (* (swarm.stats:getHealth) 5)]
        (love.graphics.setColor 1 0 0)
        (love.graphics.rectangle :fill (- swarm.x (/ hp-max-bar-width 2)) (- swarm.y 10) hp-max-bar-width 5)
        (love.graphics.setColor 0 1 0)
        (love.graphics.rectangle :fill (- swarm.x (/ hp-curr-bar-width 2)) (- swarm.y 10) hp-curr-bar-width 5)
      )
    )
    (do
    (if swarm.is-selected
      (do
        (love.graphics.setColor 1 0 1)
        (love.graphics.circle :fill swarm.x swarm.y swarm.size)
        ) swarm.is-hovered
      (do
        (love.graphics.setColor 0 1 0 0.5)
        (love.graphics.circle :fill swarm.x swarm.y swarm.size)
        )
      )
    )
    
  )
  (love.graphics.setColor 1 1 1)
  (love.graphics.circle :line swarm.x swarm.y swarm.size)
  (let [cCount (length swarm.cells)]
    (var anglePerCell (/ (* math.pi 2) cCount))
    (each [key value (pairs swarm.cells)]
      (local angle (* anglePerCell key))
      (local size (* swarm.size (math.cos (love.timer:getTime))))
      (local [xP yP] (point-on-circle swarm.x swarm.y size angle))
      (value:draw xP yP)
    )
  )
)

(fn postrender [swarm]

)

(fn has-reached-target? [swarm] 
  (and swarm.target-x swarm.target-y
    (let [dx (math.abs (- swarm.x swarm.target-x)) dy (math.abs (- swarm.y swarm.target-y))]
      (and (< dx 10) (< dy 10))
    )))

(fn move [_state swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (let [
    fixture swarm.fixture
    body (fixture:getBody)]
    (body:setLinearVelocity x-delta y-delta)
    swarm
  ))

(fn stop-at-target [state swarm] 
  (let [m (unset (lume.merge swarm { :x swarm.target-x :y swarm.target-y }) :target-x :target-y)
        fixture swarm.fixture
        body (fixture:getBody)] 
        (body:setLinearVelocity 0 0)
        m))

(fn move-to-target [state swarm dt]
  "returns a new swarm nearing the target location"
  (if (not dt) (print "move-to-target: argument dt not set"))
  (if (has-reached-target? swarm)
    (stop-at-target state swarm)
    (if (and (not= swarm.target-x nil) (not= swarm.target-y nil))
        (let [speed (* (swarm.stats:getSpeed) SPEED)
            source [(. swarm :x) (. swarm :y)]
            target [swarm.target-x swarm.target-y]
            vec [(- (car target) (car source)) (- (cdr target) (cdr source))]
            len-vec (math.sqrt (+ (* (car vec) (car vec))
                                  (* (cdr vec) (cdr vec))))
            norm-vec [(/ (car vec) len-vec) (/ (cdr vec) len-vec)]
            dx (* (car norm-vec) dt speed)
            dy (* (cdr norm-vec) dt speed)]
          (move state swarm dx dy))
        swarm)))

(fn set-target [swarm x y]
  "returns a swarm with the target coordinates set"
  (lume.merge swarm {:target-x x :target-y y}))

(fn update-position [swarm]
  (let [body (swarm.fixture:getBody)]
    (lume.merge swarm { :x (body:getX) :y (body:getY) })
  ))

(fn tick [state swarm dt]
  (update-position (move-to-target state swarm dt)))

(fn check-mouse-in [state swarm mouse-x mouse-y]
  "takes a swarm and x/y coordinates of a point to be checked against"
  (lume.merge swarm {:is-selected (state.physics.in-fixture swarm.fixture mouse-x mouse-y)}))

(fn is-in [state swarm mouse-x mouse-y] (state.physics.in-fixture swarm.fixture mouse-x mouse-y))

{: new : render : tick : set-target : check-mouse-in : postrender : is-in }

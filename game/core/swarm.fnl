; swarm {
;   :id int
;   :size int
;   :x number
;   :y number
;   :target-x number|nil
;   :target-y number|nil
;   :is-hovered boolean
;   :is-selected boolean
;   :shape Shape
;   :update dt
;   :stats SwarmStats
;   :cells Cells{} 
;   :is-enemy boolean
; }

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.swarm))

(local collisions (require-mod! :core.collisions))
(local target-marker (require-mod! :core.target-marker))
(local SwarmStats (require :core.swarm-stats))
(local Cell (require :core.cell))

(local lume (require :lib.lume))

(local {: pprint : car : cdr : map : unset : point-on-circle : random-color} (require :core.utils))

(local {: find} (require-mod! :core.utils))

(fn new [id size x y is-selected is-enemy]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)
        shape (collisions.new-circle id x y size)
        is-enemy (if (not is-enemy) false is-enemy)
        stats (SwarmStats:new is-enemy)
        cells (fcollect [_ 1 (stats:getUnitCount)]
                (Cell:new size (random-color 1) (random-color)))
        is-hovered false]
    {: id : size : x : y : is-hovered : is-selected : shape : stats : is-enemy : cells}
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
  (if swarm.is-selected (swarm.stats:draw swarm.x swarm.y))
)

(fn has-reached-target? [swarm] 
  (and swarm.target-x swarm.target-y
    (let [dx (math.abs (- swarm.x swarm.target-x)) dy (math.abs (- swarm.y swarm.target-y))]
      (and (< dx 1) (< dy 1))
    )))

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (collisions.move-circle swarm.shape x-delta y-delta)
  (lume.merge swarm {:x (+ swarm.x x-delta) :y (+ swarm.y y-delta)}))

(fn move-to-target [swarm dt]
  "returns a new swarm nearing the target location"
  (if (not dt) (print "move-to-target: argument dt not set"))
  (if (has-reached-target? swarm)
    (let [m (unset (lume.merge swarm { :x swarm.target-x :y swarm.target-y }) :target-x :target-y)] m)
    (if (and (not= swarm.target-x nil) (not= swarm.target-y nil))
        (let [speed (* (swarm.stats:getSpeed) 10)
            source [(. swarm :x) (. swarm :y)]
            target [swarm.target-x swarm.target-y]
            vec [(- (car target) (car source)) (- (cdr target) (cdr source))]
            len-vec (math.sqrt (+ (* (car vec) (car vec))
                                  (* (cdr vec) (cdr vec))))
            norm-vec [(/ (car vec) len-vec) (/ (cdr vec) len-vec)]
            dx (* (car norm-vec) dt speed)
            dy (* (cdr norm-vec) dt speed)]
          (move swarm dx dy))
        swarm)))

(fn get-by-id [swarms id]
  (find (fn [sw] (= id (collisions.get-id sw.shape))) swarms))

(fn set-target [swarm x y]
  "returns a swarm with the target coordinates set"
  (lume.merge swarm {:target-x x :target-y y}))

(fn handle-collisions [swarm swarms _dt]
  (let [colls (collisions.collides-with swarm.shape)]
    (each [k v (pairs colls)] (do ))
    swarm))
  
(fn find-nearest-player [player-swarms enemy dt]
  (local enemyPos [enemy.x enemy.y])
  (each [k v (pairs player-swarms)]
  ; (let [player-distances (map )]
  ; )
  ; (if swarm.is-enemy
    
  ; )
  swarm
)

(fn tick-enemy [player-swarms enemy dt]
  (-> enemy
      (local nearest (find-nearest-player player-swarms enemy dt))
      (move-to-target dt)
      (handle-collisions player-swarms dt)))

(fn tick [swarms swarm dt]
  (-> swarm
      (move-to-target dt)
      (handle-collisions swarms dt)))

;; Returns boolean
(fn is-in [swarm x y] (collisions.in-shape swarm.shape x y))

(fn check-mouse-in [swarm mouse-x mouse-y]
  "takes a swarm and x/y coordinates of a point to be checked against"
  (lume.merge swarm {:is-selected (collisions.in-shape swarm.shape mouse-x mouse-y)})
  )

{: new : render : tick : tick-enemy : set-target : is-in : check-mouse-in : get-by-id : postrender }

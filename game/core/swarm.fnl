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

(local {: find} (require-mod! :core.utils))

(fn new [id size x y is-selected]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)
        shape (collisions.new-circle id x y size)]
    { : id : size : x : y : is-selected : shape}))

(fn render [swarm]
  (if swarm.is-selected
    (do (love.graphics.setColor 1 0 1) (love.graphics.circle :fill swarm.x swarm.y swarm.size))
  )
  (love.graphics.setColor 1 1 1) (love.graphics.circle :line swarm.x swarm.y swarm.size)
)

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (collisions.move-circle swarm.shape x-delta y-delta)
  (merge swarm { :x (+ swarm.x x-delta) :y (+ swarm.y y-delta) }))

(fn set-target [swarm x y]
  (merge swarm {:target-x x :target-y y}))

(fn check-mouse-in [swarm mouse-x mouse-y]
  (set swarm.is-selected (collisions.in-shape swarm.shape mouse-x mouse-y)))

(fn get-by-id [swarms id] (find (fn [sw] (= id sw.id)) swarms))

(fn update [swarm dt] 
  (if 
    (and (not= swarm.target-x nil) (not= swarm.target-y nil)) 
    (let [
      dx (* dt (- swarm.target-x swarm.x)) 
      dy (* dt (- swarm.target-y swarm.y))
      ] 
      (let [new_pos (move swarm dx dy)] 
        (set swarm.x new_pos.x)
        (set swarm.y new_pos.y)
      )
    )
  )
)

{: new : render : move : set-target : check-mouse-in : get-by-id : update}

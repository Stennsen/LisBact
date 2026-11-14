(local Swarm {})
(set Swarm.__index Swarm)
(set Swarm.__name :swarm)

(fn Swarm.new [self size x y]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)]
    (setmetatable {: size : x : y} self)))

(fn Swarm.render [self]
  (love.graphics.circle :line self.x self.y self.size))

(fn Swarm.move [self x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (Swarm:new self.size (+ self.x x-delta) (+ self.y y-delta)))


{: Swarm }

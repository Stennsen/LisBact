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

(fn render [obj]
  "calls an objects render method"
  (obj:render))

(fn new [class ...]
  "calls `Class:new ...` to create instance of an table"
  (class:new ...))

{: Swarm : render : new}

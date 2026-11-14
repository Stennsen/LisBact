(fn new [size x y]
  "creates a new swarm with given parameters"
  (let [x (if (not x) 0 x)
        y (if (not y) 0 y)]
    {: size : x : y}))

(fn render [swarm]
  (love.graphics.print "ASDF" 10 10)
  (love.graphics.circle :line swarm.x swarm.y swarm.size))

(fn move [swarm x-delta y-delta]
  "recieves a delta for x and y and returns a new Swarm with the updated coordinates"
  (new swarm.size (+ swarm.x x-delta) (+ swarm.y y-delta)))

{: new : render : move }

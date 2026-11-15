(local {: merge} (require :lib.lume))

{
    :update (fn [camera dt] (merge camera { :x (+ camera.x (* dt camera.mx)) :y (+ camera.y (* dt camera.my)) }))
    :with-move (fn [camera x y] (merge camera { :mx (+ camera.mx x) :my (+ camera.my y) }))
    :get-transform (fn [camera] 
        (let [tf (love.math.newTransform)]
        (tf:translate camera.x camera.y)
        tf))}
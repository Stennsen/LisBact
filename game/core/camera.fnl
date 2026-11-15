(local { : merge : clamp } (require :lib.lume))

(local SCREENWIDTH 1200)
(local SCREENHEIGHT 800)

(local CAMERA_MARGIN 400)

(fn update [camera mapconf dt]
    (let [max-x (- (+ mapconf.max-x CAMERA_MARGIN) SCREENWIDTH)
          max-y (- (+ mapconf.max-y CAMERA_MARGIN) SCREENHEIGHT)
          min-x (- mapconf.min-x CAMERA_MARGIN)
          min-y (- mapconf.min-y CAMERA_MARGIN)]
        (merge camera { 
            :x (clamp (+ camera.x (* dt camera.mx)) min-x max-x)
            :y (clamp (+ camera.y (* dt camera.my)) min-y max-y) })))

{
    : update
    :with-move (fn [camera x y] (merge camera { :mx (+ camera.mx x) :my (+ camera.my y) }))
    :get-transform (fn [camera]
        (let [tf (love.math.newTransform)]
        (tf:translate (- camera.x) (- camera.y))
        tf))}

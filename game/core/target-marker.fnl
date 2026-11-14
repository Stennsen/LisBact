; target-marker {
;   :x number
;   :y number
; }


(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.target-marker))

(fn new [x y]
    "creates a new target marker with the given position"
    (let [x (if (not x) 0 x)
        y (if (not y) 0 y)]
        {: x : y}
    )
)

(fn render [marker]
    (love.graphics.circle :fill marker.x marker.y 5)
    (print "RENDER TARGET")
)

{: new : render}
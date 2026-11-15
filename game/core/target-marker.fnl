; target-marker {
;   :x number
;   :y number
; }


(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.target-marker))

(local icon (love.graphics.newImage "assets/icons/waypoint.png"))
(icon:setFilter :nearest :nearest)

(local scale 0.5)

(fn render [marker-x marker-y]
    (love.graphics.draw icon marker-x marker-y 0 scale scale (/ (icon:getWidth) 2) (/ (icon:getHeight) 2))
    )

{ : render}
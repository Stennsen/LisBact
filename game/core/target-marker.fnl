; target-marker {
;   :x number
;   :y number
; }


(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.target-marker))

(fn render [marker-x marker-y]
    (love.graphics.setColor 0 0 1)
    (love.graphics.circle :fill marker-x marker-y 5))

{ : render}
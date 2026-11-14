;; example module mode

(import-macros {: incf} :sample-macros)

(local set-mode :set-mode)

(local lume (require :lib.lume))

(local countdown-time 300)

(local big-font (love.graphics.setNewFont 48))
(local small-font (love.graphics.setNewFont 16))

(var title-offset-x 0)

; (fn switch-mode [mode] (love.op mode))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.setFont big-font)
           (love.graphics.print "Klammer Schwarm" (+ 200 title-offset-x) 150)
           (love.graphics.setFont small-font)
           (love.graphics.print "Pressy SPACE to start!" 200 250)))
 :update (fn _update [state dt _set-mode]
           (local new-time (+ state.time dt)) ;  (set title-offset-x (* (* (math.sin (love.timer.getTime) 5) 20)))
           (set title-offset-x (* (math.sin (* (love.timer.getTime) 5)) 20))
           (if (< countdown-time new-time)
               (do
                 (love.event.quit)
                 (lume.merge state {:time 0}))
               (lume.merge state {:time new-time})))
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state key _code _is-repeat set-mode]
               (if (= key :space)
                   (do
                     (print :KEY)
                     (set-mode :mode-game)))
               state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (fn [state _key _scancode _is-repeat _set-mode] state)}

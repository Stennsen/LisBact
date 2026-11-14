;; example module mode

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.mode-game))

(local swarm (require-mod! :core.swarm))

(local collisions (require-mod! :core.collisions))

(local lume (require :lib.lume))

(local countdown-time 300)

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.print "GAME MODE" 10 10)
         )
         (each [_ swarmO (ipairs state.swarms)]
           (swarm.render swarmO))
 )
 :update (fn _update [state dt _set-mode]
           (local new-time (+ state.time dt))
           (if (< countdown-time new-time)
               (do
                 (love.event.quit)
                 (lume.merge state {:time 0}))
               (lume.merge state {:time new-time}))
               )
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state _key _scancode _is-repeat _set-mode] 
(local (x y) (love.mouse.getPosition))
(print x y)

(each [_ swarmO (ipairs state.swarms)]
; (do
; (print swarmO))
(swarm.check-mouse-in swarmO x y)
)
 state)
 :mousereleased (fn [state _key _scancode _is-repeat _set-mode] state)}

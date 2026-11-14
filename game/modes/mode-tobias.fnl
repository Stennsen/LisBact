;; example module mode

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.mode-tobias))

(local swarm (require-mod! :core.swarm))
(local marker (require-mod! :core.target-marker))

(local collisions (require-mod! :core.collisions))

(local lume (require :lib.lume))

(local countdown-time 300)

(var target-marker nil)

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.print "GAME MODE" 10 10))
         (each [_ swarmO (ipairs state.swarms)]
           (swarm.render swarmO))
           (if (~= target-marker nil)
            (marker.render target-marker)
           )
           )
 :update (fn _update [state dt _set-mode]
           (local new-time (+ state.time dt))
           (if (< countdown-time new-time)
               (do
                 (love.event.quit)
                 (lume.merge state {:time 0}))
               (lume.merge state {:time new-time})))
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state x y button is-touch presses _set-mode]
                 (case button
                 ; left
                  1 (do
                    (local (x y) (love.mouse.getPosition))
                    (each [_ swarmO (ipairs state.swarms)]
                    (swarm.check-mouse-in swarmO x y))
                  )
                 ; right
                  2 (do
                     (local (x y) (love.mouse.getPosition))
                     (each [_ swarmO (ipairs state.swarms)]
                        (if swarmO.is-selected
                            (do
                                (swarm.set-target swarmO x y)
                                (print "target select" x y)
                                (set target-marker (marker.new x y))
                            )
                        )
                     )
                  )
                 )
                 state)
 :mousereleased (fn [state x y button is-touch presses _set-mode] state)}

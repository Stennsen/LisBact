(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.map))

(local swarm (require-mod! :core.swarm))

(local {: merge} (require :lib.lume))
(local {: pprint : map} (require :core.utils))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (each [_ sw (ipairs state.swarms)]
           (swarm.render sw)))
 :update (fn _update [state dt _set-mode]
           (merge state
                  {:swarms (icollect [_ sw (ipairs state.swarms)]
                             (swarm.tick state.swarms sw dt))}))
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state x y button is-touch presses _set-mode]
                 (case button
                   1 (merge state
                            {:swarms (map (fn [sw]
                                            (swarm.check-mouse-in sw x y))
                                          state.swarms)})
                   2 (merge state
                            {:swarms (map (fn [sw]
                                            (if sw.is-selected
                                                (swarm.set-target sw x y)
                                                sw))
                                          state.swarms)})
                   _ state))
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state)}

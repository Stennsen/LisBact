(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.map))

(local swarm (require-mod! :core.swarm))

(local {: merge} (require :lib.lume))
(local {: pprint : map : foreach } (require :core.utils))
(local background (require-mod! :core.background))
(local camera (require-mod! :core.camera))

(local bg (background.new))

(local MOVE 60)

(fn keypressed [state key _code _is-repeat _set-mode] 
          (case key
            "down" (merge state { :camera (camera.with-move state.camera 0 (- MOVE)) })
            "up" (merge state { :camera (camera.with-move state.camera 0 MOVE) })
            "left" (merge state { :camera (camera.with-move state.camera MOVE 0) })
            "right" (merge state { :camera (camera.with-move state.camera (- MOVE) 0) })
            _ state))

 (fn keyreleased [state key _code _is-repeat _set-mode]  
          (case key
            "down" (merge state { :camera (camera.with-move state.camera 0 MOVE) })
            "up" (merge state { :camera (camera.with-move state.camera 0 (- MOVE)) })
            "left" (merge state { :camera (camera.with-move state.camera (- MOVE) 0) })
            "right" (merge state { :camera (camera.with-move state.camera MOVE 0) })
            _ state))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (background.draw bg state)
         (love.graphics.push)
         (love.graphics.applyTransform (camera.get-transform state.camera))
         (foreach swarm.render state.swarms)
         (foreach swarm.render state.enemies)
         (foreach swarm.postrender state.swarms)
         (love.graphics.pop))
 :update (fn _update [state dt _set-mode]
           (background.update bg state dt _set-mode)
           (print state.enemy-management.active-enemies)
           (merge state
                  { :camera (camera.update state.camera dt)
                    :swarms (icollect [_ sw (ipairs state.swarms)]
                             (swarm.tick state.swarms sw dt))
                    :enemies state.enemies
                             }))
 : keyreleased 
 : keypressed
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state sx sy button _is-touch _presses _set-mode]
                  (let [tf (camera.get-transform state.camera)
                        (x y) (tf:inverseTransformPoint sx sy)]
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
                      _ state)))
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state)}

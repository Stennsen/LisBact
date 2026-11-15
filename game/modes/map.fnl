(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.map))

(local swarm (require-mod! :core.swarm))
(local enemy-manager (require-mod! :core.enemy-manager))

(local {: merge} (require :lib.lume))
(local {: pprint : map : foreach : unpack} (require :core.utils))
(local background (require-mod! :core.background))
(local camera (require-mod! :core.camera))

(local audioPlayer (require :core/audio-player))
(local backgroundMusic (audioPlayer:newMusicPlayer "assets/audiofiles/background-music.flac"))

(local MOVE 120)

(local MAP_SIZE 2000)

(local MAP {
  :min-x 0
  :min-y 0
  :max-x 2000
  :max-y 2000
})

(local bg (background.new MAP_SIZE MAP_SIZE))
(var tooltip_draw nil) ;{:swarm nil :x 0 :y 0})

(fn keypressed [state key _code _is-repeat _set-mode] 
          (case key
            "down" (merge state { :camera (camera.with-move state.camera 0 MOVE) })
            "up" (merge state { :camera (camera.with-move state.camera 0 (- MOVE)) })
            "left" (merge state { :camera (camera.with-move state.camera (- MOVE) 0) })
            "right" (merge state { :camera (camera.with-move state.camera MOVE 0) })
            _ state))

 (fn keyreleased [state key _code _is-repeat _set-mode]  
          (case key
            "down" (merge state { :camera (camera.with-move state.camera 0 (- MOVE)) })
            "up" (merge state { :camera (camera.with-move state.camera 0 MOVE) })
            "left" (merge state { :camera (camera.with-move state.camera MOVE 0) })
            "right" (merge state { :camera (camera.with-move state.camera (- MOVE) 0) })
            _ state))

(fn mousemoved [state _x _y _dx _dy _set-mode] 
  
  state)
  
{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] (backgroundMusic:play) state)
 :leave (fn _leave [state] (backgroundMusic:stop) state)
 :draw (fn _draw [state]
         (background.predraw bg)
         (love.graphics.push)
         (love.graphics.applyTransform (camera.get-transform state.camera))
         (background.draw bg)
         (state.world-power-up-manager:draw)
         (foreach swarm.render state.swarms)
         (foreach swarm.render state.enemies)
         (foreach swarm.postrender state.swarms)
         (if (not= tooltip_draw nil)
         (tooltip_draw.swarm.stats:draw (+ tooltip_draw.x 20) (+ tooltip_draw.y 20)))
         (love.graphics.pop))
 :update (fn _update [state dt _set-mode]
           (background.update bg MAP_SIZE MAP_SIZE dt)
           (state.physics.update dt)
           (-> state
            (enemy-manager.update dt)
            (merge 
                  { :camera (camera.update state.camera MAP dt)
                    :swarms (map (fn [sw] (swarm.tick state sw dt)) state.swarms)
                    :enemies (map (fn [sw] (swarm.tick state sw dt)) state.enemies)
                             })))
 : keyreleased 
 : keypressed
 :mousemoved (fn [state x y dx dy _] 
            ;(print x y)
            ( merge state {:swarms (map (fn [sw] 
              (set sw.is-hovered (swarm.is-in sw x y))) state.swarms
            )})
            (var hovered-swarm (icollect [_ v (ipairs state.swarms)]
              (if v.is-hovered v nil)))
            (if (= (length hovered-swarm) 1) 
              (do (set hovered-swarm (. hovered-swarm 1))
              (set tooltip_draw {:swarm hovered-swarm :x x :y y}))
              (set tooltip_draw nil))
            
            state
 )
 :mousepressed (fn [state sx sy button _is-touch _presses _set-mode]
                  (let [tf (camera.get-transform state.camera)
                        (x y) (tf:inverseTransformPoint sx sy)]
                    (case button
                      1 (merge state
                            {:swarms (map (fn [sw]
                                            (swarm.check-mouse-in state sw x y))
                                          state.swarms)})
                      2 (merge state
                            {:swarms (map (fn [sw]
                                            (if sw.is-selected
                                                (swarm.set-target sw x y)
                                                sw))
                                          state.swarms)})
                      _ state)))
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state)}

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.map))

(local swarm (require-mod! :core.swarm))
(local enemy-manager (require-mod! :core.enemy-manager))

(local {: merge} (require :lib.lume))
(local {: pprint : map : foreach : unpack : find} (require :core.utils))
(local background (require-mod! :core.background))
(local camera (require-mod! :core.camera))

(local audioPlayer (require :core/audio-player))
(local backgroundMusic
       (audioPlayer:newMusicPlayer :assets/audiofiles/background-music.flac))

(local controls (require :core/controls))
(local c (controls:new))

(local regenerationmanager (require :core/regeneration-manager))
(local regManager (regenerationmanager:new))

(local MOVE 120)

(local MAP_SIZE 2000)

(local MAP {:min-x 0 :min-y 0 :max-x 2000 :max-y 2000})

(local bg (background.new MAP_SIZE MAP_SIZE))
(var tooltip_draw nil)

;{:swarm nil :x 0 :y 0})

(fn keypressed [state key _code _is-repeat _set-mode]
  (case key
    :down (merge state {:camera (camera.with-move state.camera 0 MOVE)})
    :up (merge state {:camera (camera.with-move state.camera 0 (- MOVE))})
    :left (merge state {:camera (camera.with-move state.camera (- MOVE) 0)})
    :right (merge state {:camera (camera.with-move state.camera MOVE 0)})
    _ state))

(fn keyreleased [state key _code _is-repeat _set-mode]
  (case key
    :down (merge state {:camera (camera.with-move state.camera 0 (- MOVE))})
    :up (merge state {:camera (camera.with-move state.camera 0 MOVE)})
    :left (merge state {:camera (camera.with-move state.camera MOVE 0)})
    :right (merge state {:camera (camera.with-move state.camera (- MOVE) 0)})
    _ state))

(fn mousemoved [state _x _y _dx _dy _set-mode]
  state)

(fn filter-contact [contact]
  (let [(fixture1 fixture2) (contact:getFixtures)
        { :type type1 :is-enemy en1 } (fixture1:getUserData)
        { :type type2 :is-enemy en2 } (fixture2:getUserData)]
    (if (and 
      (~= en1 en2)
      (= type1 :swarm)
      (= type2 :swarm)) contact nil)))

(fn get-by-id [state id is-enemy] 
  (if is-enemy 
    (find (fn [sw] (= sw.id id)) state.enemies) 
    (find (fn [sw] (= sw.id id)) state.swarms)))

(fn update-when-id [swarm id updater]
  (if (= swarm.id id) (updater swarm) swarm))

(fn update-own [state id updater] (merge state { 
  :swarms (map (fn [sw] (update-when-id sw id updater)) state.swarms) }))

(fn update-enemy [state id updater] (merge state { 
  :enemies (map (fn [sw] (update-when-id sw id updater)) state.enemies) }))

(fn update-swarm [state id is-enemy updater]
  (if is-enemy (update-enemy state id updater) (update-own state id updater)))

(fn make-combat-updater [opponent dt]
  (fn [sw] 
    (let [atk (opponent.stats:getAttack) 
          oldHealth (sw.stats:getHealth)
          newHealth (- oldHealth (* atk dt))]
    (sw.stats:setHealth newHealth) 
    sw))
)

(fn handle-contact [state contact dt] 
  (let [(fixture1 fixture2) (contact:getFixtures)
        ud1 (fixture1:getUserData)
        ud2 (fixture2:getUserData)
        sw1 (get-by-id state ud1.id ud1.is-enemy)
        sw2 (get-by-id state ud2.id ud2.is-enemy)
        state (update-swarm state ud1.id ud1.is-enemy (make-combat-updater sw2 dt))
        state (update-swarm state ud2.id ud2.is-enemy (make-combat-updater sw1 dt))] 
        state))

(fn handle-contacts [state contacts dt] 
  (let [relevant-contacts (map filter-contact contacts)]
    (accumulate [st state _i contact (ipairs relevant-contacts)] (handle-contact st contact dt))))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state]
          (backgroundMusic:play)
          (state.physics.add-map-colliders MAP)
          state)
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
             (tooltip_draw.swarm.stats:draw (+ tooltip_draw.x 20)
                                            (+ tooltip_draw.y 20)))
         (c.draw)
         (love.graphics.pop))
 :update (fn _update [state dt _set-mode]
           (background.update bg MAP_SIZE MAP_SIZE dt)
           (state.physics.update dt)
           (regManager:tick state.swarms dt)
           (let [contacts (state.physics.get-contacts)
                 state (enemy-manager.update (handle-contacts state contacts dt) dt)]
               (merge state {:camera (camera.update state.camera MAP dt)
                       :swarms (map (fn [sw] (swarm.tick state sw dt))
                                    state.swarms)
                       :enemies (map (fn [sw] (swarm.tick state sw dt))
                                     state.enemies)})))
 : keyreleased
 : keypressed
 :mousemoved (fn [state x y dx dy _]
               ;(print x y)
               (merge state
                      {:swarms (map (fn [sw]
                                      (set sw.is-hovered
                                           (swarm.is-in state sw x y)))
                                    state.swarms)})
               (var hovered-swarm
                    (icollect [_ v (ipairs state.swarms)]
                      (if v.is-hovered v nil)))
               (if (= (length hovered-swarm) 1)
                   (do
                     (set hovered-swarm (. hovered-swarm 1))
                     (set tooltip_draw {:swarm hovered-swarm : x : y}))
                   (set tooltip_draw nil))
               state)
 :mousepressed (fn [state sx sy button _is-touch _presses _set-mode]
                 (let [tf (camera.get-transform state.camera)
                       (x y) (tf:inverseTransformPoint sx sy)]
                   (case button
                     1 (merge state
                              {:swarms (map (fn [sw]
                                              (swarm.check-mouse-in state sw x
                                                                    y))
                                            state.swarms)})
                     2 (merge state
                              {:swarms (map (fn [sw]
                                              (if sw.is-selected
                                                  (swarm.set-target sw x y)
                                                  sw))
                                            state.swarms)})
                     _ state)))
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state)}

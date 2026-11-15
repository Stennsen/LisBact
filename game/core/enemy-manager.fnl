(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.enemy-manager))

(local {: merge : concat} (require :lib.lume))
(local {: pprint : map : foreach } (require :core.utils))
(local swarm (require-mod! :core.swarm))

; (local MAX_ENEMIES 4)
; (local CURRENT_COOLDOWN 0)
; (local TIME_BETWEEN_SPAWNS 5)

(fn get-random-player-swarm [swarms]
    (. swarms (love.math.random (length swarms)))
)

(fn new []
  "creates a new enemy manager with given parameters"
    (print "enemy-manager:new")
)

(fn update [state dt]
    (if (<= state.enemy-management.current-cooldown 0)
        (if (< (length state.enemies) state.enemy-management.max-enemies) 
            (let [random-player-swarm (get-random-player-swarm state.swarms)
                new-enemy (swarm.set-target (swarm.new state.physics 10 10 (love.math.random 10 1200) (love.math.random 10 800) false true) random-player-swarm.x random-player-swarm.y)
                _ (print "Spawned new enemy")]
                (merge state {
                    :enemies (concat state.enemies [new-enemy])
                    :enemy-management (merge state.enemy-management {:current-cooldown state.enemy-management.time-between-spawns })})))
        (let [current-cooldown (- state.enemy-management.current-cooldown dt)]
            (merge state {
                :enemy-management (merge state.enemy-management {
                :current-cooldown current-cooldown })})
        )))

{: new : update }
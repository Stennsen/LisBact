(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.enemy-manager))

(local {: merge : concat} (require :lib.lume))
(local {: pprint : map : foreach } (require :core.utils))
(local swarm (require-mod! :core.swarm))

; (local MAX_ENEMIES 4)
; (local CURRENT_COOLDOWN 0)
; (local TIME_BETWEEN_SPAWNS 5)

(fn new []
  "creates a new enemy manager with given parameters"
    (print "enemy-manager:new")
)

(fn update [state dt]
    ; (print "Update enemy manager " dt)
    (var new-state state)
    (if (<= state.enemy-management.current-cooldown 0)
        (do
            (if (< (length state.enemies) state.enemy-management.max-enemies)
                (do
                    (print "spawn new enemy")
                    (let [new-enemy (swarm.new state.physics 10 10 (love.math.random 10 1200) (love.math.random 10 800) false true) ]
                        (set new-state
                            (merge state {
                                :enemies (concat state.enemies [new-enemy])
                                :enemy-management (merge state.enemy-management
                                    {
                                        :current-cooldown new-state.enemy-management.time-between-spawns
                                    }
                                )
                            })
                        )
                    )
                )
            )
        )
    )

    (let [current-cooldown (- new-state.enemy-management.current-cooldown dt)]
        (merge new-state {
            :enemy-management (merge new-state.enemy-management {
                :current-cooldown current-cooldown })}
        )
    )
)

{: new : update }
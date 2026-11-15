(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local swarm (require-mod! :core.swarm))
(local enemy-manager (require-mod! :core.enemy-manager))
(local collisions (require-mod! :core.collisions))
(local world-power-up-manager (require-mod! :core/world-power-up-manager))

(local physics (collisions))

{:init (fn _init []
        (let [list-enemies []]
         {:time 0
          :swarms [(swarm.set-target (swarm.new physics 1 32 300 300 false) 300 400)
                   (swarm.set-target (swarm.new physics 2 32 400 300 false) 400 400)]
          :camera { :x 0 :y 0 :mx 0 :my 0 }
          : physics
          :enemies list-enemies
        ;   :enemy-management { :active-enemies (length list-enemies)}
          :enemy-management { :max-enemies 20 :current-cooldown 0 :time-between-spawns 0.5}
          :world-power-up-manager (world-power-up-manager:new 6)
          }))}

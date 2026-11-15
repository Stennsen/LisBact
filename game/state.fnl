(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local swarm (require-mod! :core.swarm))
(local enemy-manager (require-mod! :core.enemy-manager))
(local collisions (require-mod! :core.collisions))

(local physics (collisions))

{:init (fn _init []
        (let [list-enemies [(swarm.new physics 3 10 500 500 false true)
                    (swarm.new physics 7 10 200 400 false true)]]
         {:time 0
          :swarms [(swarm.set-target (swarm.new physics 1 42 300 300 false) 10 10)
                   (swarm.set-target (swarm.new physics 2 100 0 0 false) 1000 1000)]
          :camera { :x 0 :y 0 :mx 0 :my 0 }
          : physics
          :enemies list-enemies
        ;   :enemy-management { :active-enemies (length list-enemies)}
          :enemy-management { :max-enemies 20 :current-cooldown 0 :time-between-spawns 0.5}
          }))}

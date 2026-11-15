(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local swarm (require-mod! :core.swarm))

{:init (fn _init []
         {:time 0
          :swarms [(swarm.set-target (swarm.new 1 42 300 300 false) 10 10)
                   (swarm.set-target (swarm.new 2 100 0 0 false) 1000 1000)]
          :camera { :x 0 :y 0 :mx 0 :my 0 }
          :enemies [(swarm.new 3 10 500 500 false true)
                    (swarm.new 4 10 600 700 false true)
                    (swarm.new 5 10 900 700 false true)
                    (swarm.new 6 10 900 50 false true)
                    ]
          }
          )}

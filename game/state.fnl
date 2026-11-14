(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local swarm (require-mod! :core.swarm))

{:init (fn _init []
         {:time 0
          :swarms [(swarm.set-target (swarm.new 1 42 300 300 false) 10 10)
                   (swarm.set-target (swarm.new 2 100 0 0 false) 1000 1000)]})}

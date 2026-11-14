(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local swarm (require-mod! :core.swarm))

{:init (fn _init []
         {:time 0 :swarms [(swarm.new 42 100 100) (swarm.new 100 0 0)]})}

(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :state))

(local {: Swarm} (require-mod! :core.swarm))

{:init (fn _init []
         {:time 0 :swarms [(Swarm:new 42 100 100) (Swarm:new 100 0 0)]})}

(local {: Swarm} (require :core.swarm))
{:init (fn _init []
         {:time 0 :swarms [(Swarm:new 42 20 40) (Swarm:new 100 0 0)]})}

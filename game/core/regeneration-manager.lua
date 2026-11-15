local Regenerationmanager = {}
Regenerationmanager.__index = Regenerationmanager

function Regenerationmanager:new ()
  local manager = setmetatable({}, self)

  manager.cooldownPerSwarm = 10
  manager.swarmCooldownMap = {}

  return manager
end

function Regenerationmanager:tick(playerSwarms, dt)
    for i,swarm in ipairs(playerSwarms) do
        local cd = self.swarmCooldownMap[swarm.id]
        if cd ~= nil then
            if cd >= self.cooldownPerSwarm then
                self.swarmCooldownMap[swarm.id] = 0
                swarm.stats:setHealth(swarm.stats:getHealth() + 1)
            else
                self.swarmCooldownMap[swarm.id] = cd + dt
            end
        else
            self.swarmCooldownMap[swarm.id] = 0
        end
    end

end

return Regenerationmanager

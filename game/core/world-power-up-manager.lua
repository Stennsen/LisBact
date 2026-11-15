local PowerUp = require("core/power-up")

local WorldPowerUpManager = {}
WorldPowerUpManager.__index = WorldPowerUpManager

local statNames = {"attack", "defence", "speed", "unitCount", "health"}

function WorldPowerUpManager:new (spawnedPowerUps)
    local manager = setmetatable({}, self)

    manager.powerUps = {}
    manager.consumedPowerUps = {}
    manager:spawnPowerUps(spawnedPowerUps)

    return manager
end

function WorldPowerUpManager:spawnPowerUps(spawnedPowerUps)
    local width, height = love.graphics.getDimensions()

    for i = 1, spawnedPowerUps do
        local stat = statNames[love.math.random(#statNames)]
        local radius = love.math.random(5, 10)
        local xPos = love.math.random(radius, width - radius)
        local yPos = love.math.random(radius, height - radius)
        local gain = love.math.random(1, 3)

        local p = PowerUp:new(xPos, yPos, stat, gain)
        table.insert(self.powerUps, p)
    end
end

function WorldPowerUpManager:consumeRandomPowerUp(stats)
    if #self.powerUps == 0 then
        return nil
    end

    local powerUp = table.remove(self.powerUps, love.math.random(#self.powerUps))
    powerUp:applyToStats(stats)
    table.insert(self.consumedPowerUps, powerUp)

    return powerUp
end

function WorldPowerUpManager:update(dt)
    for i = #self.consumedPowerUps, 1, -1 do
        local powerUp = self.consumedPowerUps[i]
        if not powerUp:isPlayingSound() then
            powerUp:destroy()
            table.remove(self.consumedPowerUps, i)
        end
    end
end

function WorldPowerUpManager:destroy()
    for _, p in ipairs(self.powerUps) do
        p:destroy()
    end
    for _, p in ipairs(self.consumedPowerUps) do
        p:destroy()
    end
    self.powerUps = {}
    self.consumedPowerUps = {}
end

function WorldPowerUpManager:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1,1,1,1)
    for _, p in ipairs(self.powerUps) do
        p:draw()
    end
    love.graphics.setColor(r, g, b, a)
end

return WorldPowerUpManager

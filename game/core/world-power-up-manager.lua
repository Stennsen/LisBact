local PowerUp = require("core/power-up")

local WorldPowerUpManager = {}
WorldPowerUpManager.__index = WorldPowerUpManager

local statColors = {
    attack    = {1, 0, 0, 1},
    defence   = {0, 0, 1, 1},
    speed     = {0, 1, 0, 1},
    unitCount = {1, 1, 0, 1},
    health    = {1, 0, 0, 1}
}

local statNames = {"attack", "defence", "speed", "unitCount", "health"}

function WorldPowerUpManager:new (spawnedPowerUps)
    local manager = setmetatable({}, self)

    manager.powerUps = {}
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

        local p = PowerUp:new(xPos, yPos, radius, statColors[stat], stat, gain)
        table.insert(self.powerUps, p)
    end
end

function WorldPowerUpManager:draw()
    for _, p in ipairs(self.powerUps) do
        p:draw()
    end
end

return WorldPowerUpManager

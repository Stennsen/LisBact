local SwarmStat = require("core/swarm-stat")

local SwarmStats = {}
SwarmStats.__index = SwarmStats

attack = love.graphics.newImage("assets/icons/attack_r_64.png")
defence = love.graphics.newImage("assets/icons/defence_b_64.png")
count = love.graphics.newImage("assets/icons/count_y_64.png")
speed = love.graphics.newImage("assets/icons/speed_g_64.png")
health = love.graphics.newImage("assets/icons/health_r_64.png")

borderToWindow = 10
gabBetweenIconAndStat = 10
globalDrawPositionOffset = 10

function SwarmStats:new ()
  local swarmStats = setmetatable({}, self)

  swarmStats.attack = SwarmStat:new(math.random(1,2),5,attack)
  swarmStats.defence = SwarmStat:new(math.random(1,2),5,defence)
  swarmStats.speed = SwarmStat:new(math.random(1,2),5,speed)
  swarmStats.unitCount = SwarmStat:new(math.random(1,3),5,count)
  swarmStats.health = SwarmStat:new(5,5,health)

  swarmStats.drawnStats = {
    swarmStats.attack,
    swarmStats.defence,
    swarmStats.speed,
    swarmStats.unitCount,
    swarmStats.health
  }

  return swarmStats
end

function SwarmStats:getUnitCount()
    return self.unitCount:getAmount()
end

function SwarmStats:setUnitCount(newCount)
    self.unitCount:setAmount(newCount)
end

function SwarmStats:getHealth()
    return self.health:getAmount()
end

function SwarmStats:setHealth(newHealth)
    self.health:setAmount(newHealth)
end

function SwarmStats:getAttack()
    return self.attack:getAmount()
end

function SwarmStats:setAttack(newAttack)
    self.attack:setAmount(newAttack)
end

function SwarmStats:getDefence()
    return self.defence:getAmount()
end
    
function SwarmStats:setDefence(newDefence)
    self.defence:setAmount(newDefence)
end

function SwarmStats:getSpeed()
    return self.speed:getAmount()
end
    
function SwarmStats:setSpeed(newSpeed)
    self.speed:setAmount(newSpeed)
end

function SwarmStats:draw(x, y)
    local r, g, b, a = love.graphics.getColor()
    local iconHeights = 0
    for index,stat in ipairs(self.drawnStats) do
        iconHeights = iconHeights + stat.icon:getHeight()
    end

    local backgroundW = self:determineMaxDrawWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 
        x + globalDrawPositionOffset, 
        y + globalDrawPositionOffset, 
        backgroundW,
        iconHeights + (2 * borderToWindow),
        16)

    love.graphics.setColor(1, 1, 1)

    local i = 0
    for index,stat in ipairs(self.drawnStats) do
        local xPos = x + (borderToWindow * 2)
        local yPos = y + (borderToWindow * 2) + (i * stat.icon:getHeight())
        love.graphics.draw(stat.icon, xPos, yPos)
        stat:draw(xPos + stat.icon:getWidth() + gabBetweenIconAndStat, 
                    yPos + (stat.icon:getHeight() / 2))
        i = i + 1
    end


    love.graphics.setColor(r, g, b, a)
end

function SwarmStats:determineMaxDrawWidth()
    local maxFoundWidth = 0
    for index,stat in ipairs(self.drawnStats) do
        local w = stat.icon:getWidth() + gabBetweenIconAndStat + stat:getDrawWidth()
        if w > maxFoundWidth then
            maxFoundWidth = w
        end
    end

    return maxFoundWidth + 2 * borderToWindow
end


return SwarmStats
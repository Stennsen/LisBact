local SwarmStats = {}
SwarmStats.__index = SwarmStats

local statsFont = love.graphics.newFont("assets/fonts/MotionControl-Bold.otf",24)

local function createStatTextString(stat)
    return string.format("--- Stats ---\nUnits: %d\nHealth: %d\nAttack: %d\nDefence: %d\nMovement: %d",
        stat.unitCount, stat.health, stat.attack, stat.defence, stat.movement)
end

function SwarmStats:new ()
  local swarmStats = setmetatable({}, self)

  swarmStats.unitCount = 10
  swarmStats.health = 10
  swarmStats.attack = 10
  swarmStats.defence = 10
  swarmStats.movement = 10
  swarmStats.text = love.graphics.newText(statsFont,createStatTextString(swarmStats))

  return swarmStats
end

function SwarmStats:getUnitCount()
    return self.unitCount
end

function SwarmStats:setUnitCount(newCount)
    if newCount < 0 then self.unitCount = 0 else self.unitCount = newCount end
end

function SwarmStats:getHealth()
    return self.health
end

function SwarmStats:setHealth(newHealth)
    if newHealth < 0 then self.health = 0 else self.health = newHealth end
end

function SwarmStats:getAttack()
    return self.attack
end

function SwarmStats:setAttack(newAttack)
    if newAttack < 0 then self.attack = 0 else self.attack = newAttack end
end

function SwarmStats:getDefence()
    return self.defence
end
    
function SwarmStats:setDefence(newDefence)
    if newDefence < 0 then self.defence = 0 else self.defence = newDefence end
end

function SwarmStats:getMovement()
    return self.movement
end
    
function SwarmStats:setMovement(newMovement)
    if newMovement < 0 then self.movement = 0 else self.movement = newMovement end
end

function SwarmStats:draw(x, y)
    local r, g, b, a = love.graphics.getColor()

    self.text:set(createStatTextString(self))
    local padding = 10

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, 
        self.text:getWidth() + (2 * padding), 
        self.text:getHeight() + (2 * padding), 
        16)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.text, x + padding, y + padding)

    love.graphics.setColor(r, g, b, a)
end

return SwarmStats
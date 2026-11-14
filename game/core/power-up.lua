local PowerUp = {}
PowerUp.__index = PowerUp

function PowerUp:new (xPos, yPos, radius, color, stat, gain)
  local powerup = setmetatable({}, self)

  powerup.xPos = xPos
  powerup.yPos = yPos
  powerup.color = color
  powerup.radius = radius
  powerup.stat = stat
  powerup.gain = gain

  return powerup
end

function PowerUp:applyToStats(stats)
    if stats == nil then
        return
    end

    local target = stats[self.stat]
    if target == nil then
        return
    end

    target:setAmount(target:getAmount() + self.gain)
end

function PowerUp:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.xPos, self.yPos, self.radius)

    love.graphics.setColor(r, g, b, a)
end

return PowerUp
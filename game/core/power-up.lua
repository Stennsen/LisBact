local AudioPlayer = require("core/audio-player")

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
  powerup.sound = AudioPlayer:newSoundPlayer("assets/audiofiles/powerup-" .. stat .. ".wav")
  powerup.destroyed = false

  return powerup
end

function PowerUp:applyToStats(stats)
    if self.destroyed or stats == nil then
        return
    end

    local target = stats[self.stat]
    if target == nil then
        return
    end

    self.sound:playOneShot()
    target:setAmount(target:getAmount() + self.gain)
end

function PowerUp:isPlayingSound()
    return not self.destroyed and self.sound:isPlaying()
end

function PowerUp:destroy()
    if self.destroyed then
        return
    end
    self.destroyed = true
    self.sound:release()
    self.sound = nil
end

function PowerUp:draw()
    if self.destroyed then
        return
    end

    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.xPos, self.yPos, self.radius)

    love.graphics.setColor(r, g, b, a)
end

return PowerUp

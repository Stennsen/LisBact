local AudioPlayer = require("core/audio-player")

local PowerUp = {}
PowerUp.__index = PowerUp

icon = love.graphics.newImage("assets/icons/powerup_64.png")

function PowerUp:new (xPos, yPos, stat, gain)
  local powerup = setmetatable({}, self)

  powerup.xPos = xPos
  powerup.yPos = yPos
  powerup.stat = stat
  powerup.sound = AudioPlayer:newSoundPlayer("assets/audiofiles/powerup-" .. stat .. ".wav")
  powerup.gain = gain
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
    love.graphics.draw(icon,  self.xPos, self.yPos)
end

return PowerUp

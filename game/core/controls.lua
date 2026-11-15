local Controls = {}
Controls.__index = Controls

local font = love.graphics.newFont("assets/fonts/MotionControl-Bold.otf", 36)
local text = love.graphics.newText(font, "Select a bacteria with left mouse click and try to eat smaller bacteria...")

function Controls:new()
  return setmetatable({}, self)
end

function Controls:draw()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.draw(text, 10, love.graphics.getHeight() - text:getHeight())
  love.graphics.pop()
end

return Controls

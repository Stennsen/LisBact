local SwarmStat = {}
SwarmStat.__index = SwarmStat

rectWidth = 25
rectHeight = 10
rectGab = 5

function SwarmStat:new (amount, maxAmount, icon)
  local swarmStat = setmetatable({}, self)

  swarmStat.amount = amount
  swarmStat.maxAmount = maxAmount
  swarmStat.icon = icon

  return swarmStat
end

function SwarmStat:getAmount()
    return self.amount
end

function SwarmStat:setAmount(newAmount)
    if newAmount < 0 then 
        self.amount = 0 
    elseif newAmount > self.maxAmount then
        self.amount = self.maxAmount
    else
        self.amount = newAmount
    end
end

function SwarmStat:draw(x, y)
    local r, g, b, a = love.graphics.getColor()

    local i = 0
    while (i < self.maxAmount) do
        if i < self.amount then
            love.graphics.setColor(1, 0.24, 0.24)
        else
            love.graphics.setColor(0.3, 0, 0)
        end
        
        local gabToUse = 0
        if i >= 1 then
            gabToUse = i * rectGab
        end

        love.graphics.rectangle("fill", 
        x + (rectWidth * i) + gabToUse, 
        y - rectHeight / 2, -- center the row
        rectWidth, 
        rectHeight, 
        8)

        i = i + 1
    end
    
    love.graphics.setColor(r, g, b, a)
end

function SwarmStat:getDrawWidth()
    return (self.maxAmount * rectWidth) +
        ((self.maxAmount - 1) * rectGab)
end

return SwarmStat
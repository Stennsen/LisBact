local Cell = {}
Cell.__index = Cell


local function generate_rect_pol(width, height, angle)
  local tenth_w = (width * 0.1)
  local tenth_h = (height * 0.1)
  local p1 = {tenth_w, tenth_h}
  local p2 = {0.0, (height / 2)}
  local p3 = {tenth_w, (height - tenth_h)}
  local p4 = {(width / 2), height}
  local p5 = {(width - tenth_w), (height - tenth_h)}
  local p6 = {width, (height / 2)}
  local p7 = {(width - tenth_w), tenth_h}
  local p8 = {(width / 2), 0}
  local p = {p1, p2, p3, p4, p5, p6, p7, p8}
  local points = {}
  for _index, value in ipairs(p) do
    for _index0, element in ipairs(value) do
      table.insert(points, element)
    end
  end
  return points
end

local function generate_outline(pol)
  local new_pol = {unpack(pol)}
  table.insert(new_pol, pol[1])
  table.insert(new_pol, pol[2])
  return new_pol
end

local function offset_pol(pol, offset_x, offset_y)
  local new_p = {}
  for i = 1, #pol, 2 do
    table.insert(new_p, (offset_x + pol[i]))
    table.insert(new_p, (offset_y + pol[(i + 1)]))
  end
  return new_p
end

function Cell:new (parentSize, body_color, outline_color)
  local cell = setmetatable({}, self)

  cell.ownSize = (parentSize / 2) * math.random()
  if math.random() <= 0.5 then 
    cell.rotation = math.random() + 2 
  else
    cell.rotation = math.random() + 2 * -1
  end
  cell.base_rect = generate_rect_pol(cell.ownSize,cell.ownSize)
  cell.outline = generate_outline(cell.base_rect)
  cell.body_color = body_color
  cell.outline_color = outline_color

  return cell
end

function Cell:draw(x, y)
    -- We move the point half the size of the cell so it is centered whereever it is supposed to be
    x = x - self.ownSize / 2
    y = y - self.ownSize / 2
    local angle = love.timer.getTime() * 2 * math.pi / self.rotation
    love.graphics.push() -- Create a coordinate system for the cell
    love.graphics.translate(x + self.ownSize / 2, y + self.ownSize / 2) -- Move the origin to the cell's center
    love.graphics.rotate(angle) -- Rotate around that center
    love.graphics.translate(-self.ownSize / 2, -self.ownSize / 2) -- Shift back so the polygon is centered

    love.graphics.setColor(self.body_color)
    love.graphics.polygon("fill", unpack(self.base_rect))
    love.graphics.setLineJoin("bevel")
    love.graphics.setColor(self.outline_color)
    love.graphics.setLineWidth(self.ownSize * 0.25)
    love.graphics.line(unpack(self.outline))
    love.graphics.setColor({0, 0, 0})
    love.graphics.setLineWidth(self.ownSize * 0.1)
    love.graphics.line(unpack(self.outline))
    love.graphics.pop() -- Remove the coordinate system of the cell
end

return Cell
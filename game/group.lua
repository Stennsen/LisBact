groupStats = {
    attack = 1, 
    defense = 2,
    speed = 3
}

function groupStats:create (o)
  o.parent = self
  return o
end

function createGroup()
  group = {}
  group.x = 0
  group.y = 0
  group.rot = 0
  group.speed = 100
  group.speed_rot = 100
  return group
end

function group:draw(o)
  love.graphics.points(x, y)
end


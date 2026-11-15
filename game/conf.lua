json = require "lib.json"

local conf_json = love.filesystem.read("conf.json")
local conf = {}
if conf_json then
   conf = json.decode(conf_json)
else
   error("No conf.json found")
end

love.conf = function(t)
   t.title, t.identity = conf.title, "Minimal"
   t.version = conf.loveVersion
   t.modules.joystick = false
   t.modules.physics = false
   t.window.width = 1200
   t.window.height = 800
   t.window.vsync = false
   t.gammacorrect = true
end

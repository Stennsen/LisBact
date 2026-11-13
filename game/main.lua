-- bootstrap the compiler

local fennel = require("lib.fennel").install({correlate=true,
                                              moduleName="lib.fennel"})

-- replace debug functions with their fennel equivelents
debug.getInfo = fennel.getInfo
debug.traceback = fennel.traceback

-- add a fennel searcher that works for fennel functions in love2d. This
-- is a bit tricky because it has to work in a fused environment
local make_love_searcher = function(env)
   return function(module_name)
      local m_name = "" .. module_name
      local path = m_name:gsub("%.", "/")
      if love.filesystem.getInfo(path .. ".fnl") then
         return function(...)
            local code = love.filesystem.read(path .. ".fnl")
            return fennel.eval(code, {env=env, filename=path .. ".fnl", correlate=true}, ...)
         end, path
      elseif env == "_COMPILER" and love.filesystem.getInfo(path .. ".fnlm") then
         return function(...)
            local code = love.filesystem.read(path .. ".fnlm")
            return fennel.eval(code, {env=env, filename=path .. ".fnl", correlate=true}, ...)
         end, path
      end
   end 
end

table.insert(package.loaders or package.searchers, make_love_searcher(_G))
table.insert(fennel["macro-searchers"], make_love_searcher("_COMPILER"))

math.randomseed( os.time() )

function love.threaderror(thread, errorstr)
   print("Thread error!\n"..errorstr)
   print(thread)
end

require("wrap")

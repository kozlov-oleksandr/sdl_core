local module = {}
module.connectedEvent = { level = 3 }
module.disconnectedEvent = { level = 3 }
module.timeoutEvent = { level = 3 }
local event_mt = { __index = { } }
setmetatable(module.connectedEvent, event_mt)
setmetatable(module.disconnectedEvent, event_mt)
setmetatable(module.timeoutEvent, event_mt)
function event_mt.__index:matches() return false end
function module.Event()
  local ret = { level = 3 }
  setmetatable(ret, event_mt)
  return ret
end
return module

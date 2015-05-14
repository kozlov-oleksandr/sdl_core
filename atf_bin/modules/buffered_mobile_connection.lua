local ph = require("protocol_handler")
local file_mapper = require("file_mapper")
local module = { mt = { __index = {} } }
local protocol_handler = ph.ProtocolHandler()

function module.Connection(connection)
  res = { }
  res.connection = connection
  setmetatable(res, module.mt)
  return res
end
function module.mt.__index:Connect()
  self.connection:Connect()
end
function module.mt.__index:Send(data)
  local binary = protocol_handler:Compose(data)
  self.connection:Send(binary)
end
function module.mt.__index:OnInputData(func)
  local this = self
  local f =
  function(self, binary)
    local msg = protocol_handler:Parse(binary)
    for _, v in ipairs(msg) do
      func(this, v)
    end
  end
  self.connection:OnInputData(f)
end
function module.mt.__index:OnConnected(func)
  self.connection:OnConnected(function() func(self) end)
end
function module.mt.__index:OnDisconnected(func)
  self.connection:OnDisconnected(function() func(self) end)
end
function module.mt.__index:Close()
  self.connection:Close()
end
return module

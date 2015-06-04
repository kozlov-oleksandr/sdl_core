local ph = require("protocol_handler")
local file_connection = require("file_connection")
local module = { mt = { __index = {} } }
local protocol_handler = ph.ProtocolHandler()

function module.MobileConnection(connection)
  res = { }
  res.connection = connection
  setmetatable(res, module.mt)
  return res
end
function module.mt.__index:Connect()
  self.connection:Connect()
end
function module.mt.__index:Send(data)
  local messages = { }
  for _, msg in ipairs(data) do
    local msgs = protocol_handler:Compose(msg)
    for _, m in ipairs(msgs) do
      table.insert(messages, m)
    end
  end
  self.connection:Send(messages)
end
function module.mt.__index:StartStreaming(session, service, filename, bandwidth)
  if getmetatable(self.connection) ~= file_connection.mt then
    error("Data streaming is impossible unless underlying connection is FileConnection")
  end
  self.connection:StartStreaming(session, service, filename, bandwidth)
end
function module.mt.__index:StopStreaming(filename)
  self.connection:StopStreaming(filename)
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

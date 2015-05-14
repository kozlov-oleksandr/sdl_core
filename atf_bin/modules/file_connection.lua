local message_dispatcher = require("message_dispatcher")
local module = { mt = { __index = { } } }
function module.FileConnection(filename, connection)
  local res = {}
  res.filename = filename
  res.connection = connection
  res.fbuf = message_dispatcher.FileStorage(filename)
  res.fmapper = message_dispatcher.MessageDispatcher(connection)
  res.fmapper:MapFile(res.fbuf)
  res.mapped = { }
  setmetatable(res, module.mt)
  return res
end
function module.mt.__index:Connect()
  self.connection:Connect()
end
function module.mt.__index:Send(data)
  for _, chunk in ipairs(data) do
    self.fbuf:WriteMessage(chunk)
  end
  self.fbuf:Flush()
  self.fmapper:Pulse()
end
function module.mt.__index:StartStreaming(session, service, filename, bandwidth)
  local stream = message_dispatcher.FileStream(filename, session, service, bandwidth or 30 * 1024, 1488)
  self.mapped[filename] = stream
  self.fmapper:MapFile(stream)
  self.fmapper:Pulse()
end
function module.mt.__index:StopStreaming(filename)
  if not self.mapped[filename] then
    error("Wrong ATF usage. You are trying to stop stream file \"" .. filename ..  "\" which isn't being streamed right now")
  end
  self.fmapper:UnmapFile(self.mapped[filename])
  self.mapped[filename] = nil
end
function module.mt.__index:OnInputData(func)
  self.connection:OnInputData(func)
end
function module.mt.__index:OnConnected(func)
  self.connection:OnConnected(func)
end
function module.mt.__index:OnDisconnected(func)
  self.connection:OnDisconnected(func)
end
function module.mt.__index:Close()
  self.connection:Close()
  if self.fd then io.close(self.fd) end
end
return module

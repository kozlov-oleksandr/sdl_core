local json = require("json")
local module = { mt = { __index = {} } }

function module.WebSocketConnection(url, port)
  local res =
  {
    url = url,
    port = port
  }
  res.socket = network.WebSocket()
  setmetatable(res, module.mt)
  res.qtproxy = qt.dynamic()
  return res
end

function module.mt.__index:Connect()
  self.socket:open(self.url, self.port)
end
local function checkSelfArg(s)
  if type(s) ~= "table" or
    getmetatable(s) ~= module.mt then
    error("Invalid argument 'self': must be connection (use ':', not '.')")
  end
end
function module.mt.__index:Send(text)
  --print("ws output:", text)
  self.socket:write(text)
end
function module.mt.__index:OnInputData(func)
  local d = qt.dynamic()
  local this = self
  function d:textMessageReceived(text)
    local data = json.decode(text)
    --print("ws input:", text)
    func(this, data)
  end
  qt.connect(self.socket, "textMessageReceived(QString)", d, "textMessageReceived(QString)")
end
function module.mt.__index:OnConnected(func)
  if self.qtproxy.connected then
    error("Websocket connection: connected signal is handled already")
  end
  local this = self
  self.qtproxy.connected = function() func(this) end
  qt.connect(self.socket, "connected()", self.qtproxy, "connected()")
end
function module.mt.__index:OnDisconnected(func)
  if self.qtproxy.disconnected then
    error("Websocket connection: disconnected signal is handled already")
  end
  local this = self
  self.qtproxy.disconnected = function() func(this) end
  qt.connect(self.socket, "disconnected()", self.qtproxy, "disconnected()")
end
function module.mt.__index:Close()
  checkSelfArg(self)
  self.socket:close();
end
return module

local json = require("json")
local module = { mt = { __index = { } } }

function module.mt.__index:Connect()
  self.connection:Connect()
end

local resultCodes =
{
        SUCCESS = 0,
        UNSUPPORTED_REQUEST = 1,
        UNSUPPORTED_RESOURCE = 2,
        DISALLOWED = 3,
        REJECTED = 4,
        ABORTED = 5,
        IGNORED = 6,
        RETRY = 7,
        IN_USE = 8,
        DATA_NOT_AVAILABLE = 9,
        TIMED_OUT = 10,
        INVALID_DATA = 11,
        CHAR_LIMIT_EXCEEDED = 12,
        INVALID_ID = 13,
        DUPLICATE_NAME = 14,
        APPLICATION_NOT_REGISTERED = 15,
        WRONG_LANGUAGE = 16,
        OUT_OF_MEMORY = 17,
        TOO_MANY_PENDING_REQUESTS = 18,
        NO_APPS_REGISTERED = 19,
        NO_DEVICES_CONNECTED = 20,
        WARNINGS = 21,
        GENERIC_ERROR = 22,
        USER_DISALLOWED = 23,
        TRUNCATED_DATA = 24
}

function module.mt.__index:Send(text)
  self.connection:Send(text)
end

function module.mt.__index:SendRequest(methodName, params)
  data = {}
  self.requestId = self.requestId + 1
  data.jsonrpc = "2.0"
  data.id = self.requestId
  data.method = methodName
  data.params = params
  local text = json.encode(data)
  self.connection:Send(text)
  return self.requestId
end

function module.mt.__index:SendRequest(methodName, params)
  local data = {}
  self.requestId = self.requestId + 1
  data.jsonrpc = "2.0"
  data.id = self.requestId
  data.method = methodName
  data.params = params
  local text = json.encode(data)
  self.connection:Send(text)
  return self.requestId
end

function module.mt.__index:SendNotification(methodName, params)
  local data = {}
  data.method = methodName
  data.jsonrpc = "2.0"
  data.params = params
  local text = json.encode(data)
  self.connection:Send(text)
end

function module.mt.__index:SendResponse(id, methodName, code, params)
  local data = {}
  self.requestId = self.requestId + 1
  data.jsonrpc = "2.0"
  data.id = id
  data.result = {
    method =  methodName,
    code = resultCodes[code]
  }
  for k, v in pairs(params) do
    data.result[k] = v
  end
  local text = json.encode(data)
  self.connection:Send(text)
end

function module.mt.__index:SendError(id, methodName, code, errorMessage)
  local data = {}
  data.error = {}
  data.error.data = {}
  data.id = id  
  data.jsonrpc = "2.0"
  data.error.data.method = methodName
  data.error.code = resultCodes[code]
  data.error.message = errorMessage
  local text = json.encode(data)
  self.connection:Send(text)
end

function module.mt.__index:OnInputData(func)
  self.connection:OnInputData(function(_, data) func(self, data) end)
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


function module.Connection(connection)
  local res = { }
  res.connection = connection
  res.requestId = 0
  setmetatable(res, module.mt)
  return res
end

return module

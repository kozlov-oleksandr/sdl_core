expectations = require('expectations')
events = require('events')
local module = {}

local mt = { __index = { } }

function mt.__index:GetHandler(conn, ev)
  res = self._pool3[conn][ev] or
        self._pool2[conn][ev] or
        self._pool1[conn][ev]
  return res
end

function mt.__index:FindHandler(obj, data)
  -- Visit all event pools and find matching event
  local function findInPool(pool, data)
    for e, h in pairs(pool) do
      if e:matches(data) then
        return h
      end
    end
    return nil
  end
  return findInPool(self._pool3[obj], data) or
         findInPool(self._pool2[obj], data) or
         findInPool(self._pool1[obj], data)
end

function mt.__index:OnPreEvent(func)
  self.preEventHandler = func
end

function mt.__index:OnPostEvent(func)
  self.postEventHandler = func
end

function mt.__index:validateAll()
  local function iter(pool)
    for e, exp in pairs(pool) do
      exp:validate()
    end
  end

  for c, pool in pairs(self._pool3) do iter(pool) end
  for c, pool in pairs(self._pool2) do iter(pool) end
  for c, pool in pairs(self._pool1) do iter(pool) end
end

-- Function takes a Connection object and subscribes on its [[OnInputData]] signal
function mt.__index:AddConnection(connection)
  local this = self
  self._pool1[connection] = { }
  self._pool2[connection] = { }
  self._pool3[connection] = { }
  connection:OnConnected(function (self)
                           if this.preEventHandler then
                             this.preEventHandler(events.connectedEvent)
                           end
                           exp = this:GetHandler(self, events.connectedEvent)
                           if exp then
                             exp.occurences = exp.occurences + 1
                             exp:Action()
                             this:validateAll()
                           end
                           if this.postEventHandler then
                             this.postEventHandler(events.connectedEvent)
                           end
                         end)
  connection:OnDisconnected(function (self)
                              if this.preEventHandler then
                                this.preEventHandler(events.disconnectedEvent)
                              end
                              exp = this:GetHandler(self, events.disconnectedEvent)
                              if exp then
                                exp.occurences = exp.occurences + 1
                                exp:Action()
                                this:validateAll()
                              end
                              if this.postEventHandler then
                                this.postEventHandler(events.disconnectedEvent)
                              end
                            end)
  connection:OnInputData(function (self, data)
                           if this.preEventHandler then
                             this.preEventHandler(data)
                           end
                           exp = this:FindHandler(self, data)
                           if exp then
                             exp.occurences = exp.occurences + 1
                             if exp.verifyData then
                               exp:verifyData(data)
                             end
                             exp:Action(data)
                             this:validateAll()
                           end
                           if this.postEventHandler then
                             this.postEventHandler(data)
                           end
                         end)
end
function mt.__index:RaiseEvent(connection, event, data)
  if self.preEventHandler and data then
    self.preEventHandler(data)
  end
  exp = self:FindHandler(connection, data)
  if exp then
    exp.occurences = exp.occurences + 1
  if data then
    if exp.verifyData then
      exp:verifyData(data)
    end
    exp:Action(data)
  end
  self:validateAll()
  end
  if self.postEventHandler then
    self.postEventHandler(data)
  end
end
function mt.__index:AddEvent(connection, event, expectation)
  if event.level == 3 then
    self._pool3[connection][event] = expectation
  elseif event.level == 2 then
    self._pool2[connection][event] = expectation
  elseif event.level == 1 then
    self._pool1[connection][event] = expectation
  end
end
function mt.__index:RemoveEvent(connection, event)
  self._pool3[connection][event] = nil
  self._pool2[connection][event] = nil
  self._pool1[connection][event] = nil
end
function module.EventDispatcher()
  local res =
  {
    _pool1 = { },
    _pool2 = { },
    _pool3 = { },
    preEventHandler = nil,
    postEventHandler = nil
  }
  setmetatable(res, mt)
  return res
end
return module

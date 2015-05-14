local module = { mt = { __index = { } } }
local fbuffer_mt = { __index = { } }
function module.FileBuffer(filename)
  local res = {}
  res.filename = filename
  res.fd = io.open(filename, "r")
  setmetatable(res, fbuffer_mt)
  return res
end
function fbuffer_mt.__index:KeepMessage(msg)
  self.keep = msg
end
function fbuffer_mt.__index:GetMessage()
  if self.keep then
    local res = self.keep
    self.keep = nil
    return res
  end
  local len = self.fd:read(4)
  if len then
    len = bit32.lshift(string.byte(string.sub(len, 4, 4)), 24) +
          bit32.lshift(string.byte(string.sub(len, 3, 3)), 16) +
          bit32.lshift(string.byte(string.sub(len, 2, 2)), 8) +
          string.byte(string.sub(len, 1, 1))
    return self.fd:read(len)
  end
end
function module.FileMapper(connection)
  local res = {}
  res._d = qt.dynamic()
  res.fds = { }
  res.idx = 0
  res.connection = connection
  res.bufferSize = 8192
  res.mapped = { }
  function res._d:bytesWritten(c)
    if #res.fds == 0 then return end
    res.bufferSize = res.bufferSize + c
    for i = 1, #res.fds do
      res.idx = (res.idx + 1) % #res.fds + 1
      local msg = res.fds[res.idx]:GetMessage()
      if msg then
        if res.bufferSize > #msg then
          res.bufferSize = res.bufferSize - #msg
          res.connection:Send({ msg })
          break
        else
          res.fds[res.idx].KeepMessage(msg)
        end
      end
    end
  end
  qt.connect(res.connection.socket, "bytesWritten(qint64)", res._d, "bytesWritten(qint64)")
  setmetatable(res, module.mt)
  return res
end
function module.mt.__index:MapFile(filebuffer)
  self.mapped[filebuffer.filename] = filebuffer
  table.insert(self.fds, filebuffer)
end
function module.mt.__index:UnmapFile(filename)
  local fd = self.mapped[filename]
  table.insert(self.fds, fd)
end
function module.mt.__index:Pulse()
  self._d:bytesWritten(0)
end
return module

local server = network.TcpServer()--{{{
if not server then
  print("TcpServer returns nothing")
  quit()
end
local client = network.TcpClient()
if not client then
  print("TcpClient returns nothing")
  quit()
end

local input = qt.dynamic()
local output = qt.dynamic()

qt.connect(client, "connected()", input, "connected()")
qt.connect(client, "readyRead()", input, "dataReady()")

function input.connected()
  print("Client connected")
  client:write("Hello")
end

function input.dataReady()
  data = client:read(5000)
  print("Client received: ", data)
  client:close()
  quit()
end

if not server:listen("localhost", 5200) then
  print("Listen failed")
  quit(1)
end

qt.connect(server, "newConnection()", output, "newConnection()")

function output.newConnection()
  output.socket = server:get_connection()
  if not output.socket then
    print("server.get_connection returns nil")
    quit(1)
  end
  qt.connect(output.socket, "readyRead()", output, "dataReady()")
end
function output.dataReady()
  data = output.socket:read(5000)
  print("Server received: ", data)
  output:write("Response")
end
function output:write(data)
  output.socket:write(data)
end

client:connect("localhost", 5200);--}}}

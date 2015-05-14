require("base")
local tcp = require("tcp_connection")
function printtable(t)
  for k,v in pairs(t) do
    print(k,v)
  end
end

x = EXPECT_CALL()

local mobile = tcp.Connection("localhost", 80)
c = mobile:Connect()
mobile:OnDataAvailable(function()
  s = mobile:Recv(10000)
  print(#s .. " bytes received successfully")
  mobile:Close()
  quit()
end)
mobile:Send("GET / HTTP/1.0\r\n\r\n")
print("Connection: ", c)

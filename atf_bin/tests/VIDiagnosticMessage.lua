Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

--===============================================================================================================--
--different values of targetID parameters (minimum = 0, maximum = 65535)
--===============================================================================================================--
--minimum targetID value
function Test:Case_minimumTargetIDValue()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 0,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 0,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 12,24,64 } })
end

--===============================================================================================================--
--maximumm targetID value
function Test:Case_maximumTargetIDValue()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 65535,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 65535,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 12, 24, 64 } })
end

--===============================================================================================================--
--outbound values of targetID parameters 
--===============================================================================================================--
--targetID = -1
function Test:Case_outOfLowerTargetIDValue()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = -1,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--targetID = -65356
function Test:Case_outOfUpperTargetIDValue()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 65536,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--different values of messageLength  (minimum = 0, maximum = 65535)
--===============================================================================================================--
--minimum messageLength value
function Test:Case_minimumMessageLengthValue()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 0,
    messageData = { 12, 24, 64 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 0,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 12, 24, 64 } })
end

--maximum messageLength value
function Test:Case_maximumMessageLengthValue()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 65535,
    messageData = { 12, 24, 64 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 65535,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 12, 24, 64 } })
end

--===============================================================================================================--
--outbound values of messageLength parameters 
--===============================================================================================================--
--targetID = -1
function Test:Case_outOfLowerMessageLengthValue()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = -1,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--targetID = -65356
function Test:Case_outOfUpperMessageLengthValue()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = -1,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--different values of messageData parameter  (minimum = 0, maximum = 255)
--===============================================================================================================--
--minimum messageData parameter
function Test:Case_minimumMessageDataParameter()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 0 , 35 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 0, 35 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 0, 35 } })
end

--minimum messageData parameter
function Test:Case_maximumMessageDataParameter()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 255, 35 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData }) 
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 255, 35 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 255, 35 } })
end

--===============================================================================================================--
--outbound values of messageData parameters 
--===============================================================================================================--
--messageData parameter = -1

function Test:Case_outOfLowerMessageDataParameter()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { -1, 35 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--messageData parameter = -1
function Test:Case_outOfUpperMessageDataParameter()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 256, 35 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--different values of messageData size  (minimum = 1, maximum = 65535)
--===============================================================================================================--
--minimum messageData parameter
function Test:Case_minimumDataParameterSize()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 123 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 123 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", messageDataResult = { 123 } })
end

--===============================================================================================================--
--outbound values of messageData size
--===============================================================================================================--
--messageData size = 0
function Test:Case_outOfLowerMessageDataParameterSize()
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = {}
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--messageData size = 655356
function Test:Case_outOfUpperMessageDataParameterSize()
  local messageDataArray = {}
  for i = 1, 65536 do
    messageDataArray[i] = 123;
  end 
  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 256, 35 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
end

--===============================================================================================================--
--send error result code 
--===============================================================================================================--
--resultCode = "OUT_OF_MEMORY"
function Test:Case_errorMessage()
  EXPECT_HMICALL("VehicleInfo.DiagnosticMessage", 
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  :Do(function(_,data) 
        self.hmiConnection:SendResponse(data.id, data.method, "OUT_OF_MEMORY", { messageDataResult = data.params.messageData })
      end)

  local cid = self.mobileSession:SendRPC("DiagnosticMessage",  
  {
    targetID = 100,
    messageLength = 100,
    messageData = { 12, 24, 64 }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "OUT_OF_MEMORY"})
end

return Test

Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

--===============================================================================================================--
--different values of startTime parameters (minimum = {0, 0, 0}, maximum = {59, 59, 59})
--===============================================================================================================--
--minimum startTime value
function Test:Case_minimumStartTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(0, 0, 0),
    updateMode = "COUNTUP"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(0, 0, 0),
    updateMode = "COUNTUP"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--maximum startTime value
function Test:Case_maximumStartTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(59, 59, 59),
    updateMode = "COUNTDOWN"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(59, 59, 59),
    updateMode = "COUNTDOWN"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--mean startTime value
function Test:Case_meanStartTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(30, 1, 58),
    updateMode = "COUNTUP"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(30, 1, 58),
    updateMode = "COUNTUP"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--different values of endTime parameters
--===============================================================================================================--
--minimum endTime value
function Test:Case_minimumEndTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(21, 36, 41),
    endTime = time(0, 0, 0),
    updateMode = "COUNTDOWN"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(21, 36, 41),
    endTime = time(0, 0, 0),
    updateMode = "COUNTDOWN"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--maximum endTime value
function Test:Case_maximumEndTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(8, 29, 23),
    endTime = time(59, 59, 59),
    updateMode = "COUNTUP"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(8, 29, 23),
    endTime = time(59, 59, 59),
    updateMode = "COUNTUP"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--mean endTime value
function Test:Case_meanEndTimeValue()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(4, 8, 15),
    endTime = time(16, 23, 42),
    updateMode = "COUNTUP"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(4, 8, 15),
    endTime = time(16, 23, 42),
    updateMode = "COUNTUP"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--different values of updateMode
--===============================================================================================================--
--PAUSE updateMode
function Test:Case_PAUSEUpdateMode()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(31, 12, 14),
    endTime = time(34, 34, 49),
    updateMode = "PAUSE"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(31, 12, 14),
    endTime = time(34, 34, 49),
    updateMode = "PAUSE"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--RESUME updateMode
function Test:Case_RESUMEUpdateMode()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(31, 22, 44),
    updateMode = "RESUME"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(31, 22, 44),
    updateMode = "RESUME"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--CLEAR updateMode
function Test:Case_CLEARUpdateMode()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(31, 22, 14),
    endTime = time(17, 27, 47),
    updateMode = "CLEAR"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(31, 22, 14),
    endTime = time(17, 27, 47),
    updateMode = "CLEAR"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--===============================================================================================================--
--send error result code 
--===============================================================================================================--
--resultCode = "GENERIC_ERROR"
function Test:Case_errorResultCode()
  EXPECT_HMICALL("UI.SetMediaClockTimer", 
  {
    startTime = time(41, 22, 14),
    updateMode = "COUNTUP"
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "GENERIC_ERROR", {})
      end)

  local cid = self.mobileSession:SendRPC("SetMediaClockTimer", 
  {
    startTime = time(41, 22, 14),
    updateMode = "COUNTUP"
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR" })
end

return Test

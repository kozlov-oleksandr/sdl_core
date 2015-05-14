Test = require('connecttest')
require('cardinalities')

function Test:waitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  EXPECT_HMIRESPONSE(12309)
  self.hmiConnection:Send({
    jsonrpc = "2.0",
    id = 12309,
    method = "SDL.ActivateApp",
    params = { appID = self.appId }
  })
end

local function SendOnSystemContext(self, ctx)
  self.hmiConnection:Send(
  {
    jsonrpc = "2.0",
    method  = "UI.OnSystemContext",
    params  = { appID = self.appId, systemContext = ctx }
  })
end

function Test:Case_TTSSpeakTest()
  local AlertRequestId
  EXPECT_HMICALL("UI.Alert", 
  {
    softButtons = 
    {
      {
        text = "Button",
        isHighlighted = false,
        softButtonID = 1122,
        systemAction = "DEFAULT_ACTION"
      }
    }
  })
  :Do(function(_,data)
        AlertRequestId = data.id
        SendOnSystemContext(self, "ALERT")
      end)

  local TTSSpeakRequestId
  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "ALERT",
      ttsChunks = { { text = "ttsChunks", type = "TEXT" } }
    })
    :Do(function(_, data)
          TTSSpeakRequestId = data.id
        end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"    },
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "ATTENUATED" },
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"    },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE"    })
    :Times(4)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:Send({
                                      jsonrpc = "2.0",
                                      method = "TTS.Started",
                                      params = { }
                                    })
          elseif exp.occurences == 2 then
            self.hmiConnection:Send({
                                      id = TTSSpeakRequestId,
                                      jsonrpc = "2.0",
                                      result = { method = "TTS.Speak", code = 0 }
                                    })
            self.hmiConnection:Send({
                                      jsonrpc = "2.0",
                                      method = "TTS.Stopped",
                                      params = { }
                                    })
          elseif exp.occurences == 3 then
            self.hmiConnection:Send({
                                      id = AlertRequestId,
                                      jsonrpc = "2.0",
                                      result = { method = "UI.Alert", code = 0 }
                                    })
          end
        end)
  local cid = self.mobileSession:SendRPC("Alert",
  {
    ttsChunks = { { text = "ttsChunks", type = "TEXT"} },
    softButtons =
    {
      {
         type = "TEXT",
         text = "Button",
         isHighlighted = false,
         softButtonID = 1122,
         systemAction = "DEFAULT_ACTION"
      }
    }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
    :Do(function()
          SendOnSystemContext(self, "MAIN")
        end)
end

function Test:Case_alertStringsUpperBoundSize()
  local AlertRequestId
  EXPECT_HMICALL("UI.Alert", 
  {
    alertStrings = 
    {
      { fieldName = "alertText1", fieldText = "alertText1" },
      { fieldName = "alertText2", fieldText = "alertText2" },
      { fieldName = "alertText3", fieldText = "alertText3" }
    }
  })
  :Do(function(_,data)
        AlertRequestId = data.id
        SendOnSystemContext(self, "ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:Send({
                                      id = AlertRequestId,
                                      jsonrpc = "2.0",
                                      result = { method = "UI.Alert", code = 0 }
                                    })
          end
        end)

  local cid = self.mobileSession:SendRPC("Alert",
  {
    alertText1 = "alertText1",
    alertText2 = "alertText2",
    alertText3 = "alertText3"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
    :Do(function()
          SendOnSystemContext(self, "MAIN")
        end)
end

function Test:Case_minimumValuesOfDurationParameter()
  local AlertRequestId
  EXPECT_HMICALL("UI.Alert", 
  {
    alertStrings = 
    {
      { fieldName = "alertText1", fieldText = "alertText1" },
      { fieldName = "alertText2", fieldText = "alertText2" },
      { fieldName = "alertText3", fieldText = "alertText3" }
    },
    duration = 3000,
    progressIndicator = true
  })
  :Do(function(_,data)
        AlertRequestId = data.id
        SendOnSystemContext(self, "ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:Send({
                                      id = AlertRequestId,
                                      jsonrpc = "2.0",
                                      result = { method = "UI.Alert", code = 0 }
                                    })
          end
        end)

  local cid = self.mobileSession:SendRPC("Alert",
  {
    alertText1 = "alertText1",
    alertText2 = "alertText2",
    alertText3 = "alertText3",
  duration = 3000,
  progressIndicator = true
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
    :Do(function()
          SendOnSystemContext(self, "MAIN")
        end)
end

function Test:Case_softButtonsTest()
  local AlertRequestId
  EXPECT_HMICALL("UI.Alert", 
  {
    softButtons = 
    {
      { softButtonID = 3000, systemAction = "DEFAULT_ACTION" },
      { softButtonID = 3001, systemAction = "DEFAULT_ACTION" },
      { softButtonID = 3002, systemAction = "DEFAULT_ACTION" },
      { softButtonID = 3003, systemAction = "DEFAULT_ACTION" },
    }
  })
  :Do(function(_,data)
        AlertRequestId = data.id
        SendOnSystemContext(self, "ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:Send({
                                      id = AlertRequestId,
                                      jsonrpc = "2.0",
                                      result = { method = "UI.Alert", code = 0 }
                                    })
          end
        end)

  local function softBtn(title, id)
    return {
      type = "TEXT",
      text = title,
      isHighlighted = false,
      softButtonID = id,
      systemAction = "DEFAULT_ACTION"
    }
  end
  local cid = self.mobileSession:SendRPC("Alert",
  {
    alertText1 = "alertText1",
    softButtons = 
    {
      softBtn("ButtonTitle1", 3000),
      softBtn("ButtonTitle2", 3001),
      softBtn("ButtonTitle3", 3002),
      softBtn("ButtonTitle4", 3003)
    }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
    :Do(function()
          SendOnSystemContext(self, "MAIN")
        end)
end

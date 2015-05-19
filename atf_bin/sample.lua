Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local config = require('config')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(rid)
  self.mobileSession:ExpectEvent(events.disconnectedEvent, "Connection started")
    :Pin()
    :Times(AnyNumber())
    :Do(function()
          print("Disconnected!!!")
          quit()
        end)
end

function Test:DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 2000)
end

function Test:Case_GetVehicleDataTest()
  local CorIdSubscribeVD= self.mobileSession:SendRPC("GetVehicleData",
  {
    gps = true,
    speed = true
  })

  EXPECT_HMICALL("VehicleInfo.GetVehicleData", 
  {
    gps = true,
    speed = true
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, "VehicleInfo.GetVehicleData", "SUCCESS",{gps = {longitudeDegrees = 20.1, latitudeDegrees = -11.9, dimension = "2D"}, speed = 120.10})
      end)

  self.mobileSession:ExpectResponse(CorIdSubscribeVD, { success = true, resultCode = "SUCCESS",gps = {longitudeDegrees = 20.1, latitudeDegrees = -11.9, dimension = "2D"}, speed = 120.1})
  :Timeout(5000)
end

function Test:GetVehicleData()
  EXPECT_HMICALL("VehicleInfo.GetVehicleData")
    :Do(function(_, data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { method = "VehicleInfo.GetVehicleData", speed = 1.2 })
        end)
  local cid = self.mobileSession:SendRPC("GetVehicleData", { speed = true })
  EXPECT_RESPONSE("GetVehicleData", { success = true, speed = 1.2 })
end

function Test:PutFile()
  local cid = self.mobileSession:SendRPC("PutFile",
  {
    syncFileName = "icon.png",
    fileType = "GRAPHIC_PNG"
  }, "icon.png")
  EXPECT_RESPONSE(cid, { success = true })
end

--[[ Disabled until APPLINK-12709 is fixed

function Test:Case_StartAudioStreaming()
  self.mobileSession:StartService(10)
   :Do(function()
         self.mobileSession:StartStreaming(10, "video.mpg", 30 * 1024)
       end)
end

function Test:StopAudioStreaming()
 local function to_be_run()
         self.mobileSession:StopStreaming("video.mpg")
         self.mobileSession:Send(
           {
             frameType   = 0,
             serviceType = 10,
             frameInfo   = 4,
             sessionId   = self.mobileSession.sessionId
           })
       end
 RUN_AFTER(to_be_run, 12000)
 local event = events.Event()
 event.matches = function(_, data)
                   return data.frameType   == 0 and
                          data.serviceType == 10 and
                          data.sessionId   == self.mobileSession.sessionId and
                         (data.frameInfo   == 5 or -- End Service ACK
                          data.frameInfo   == 6)   -- End Service NACK
                 end
 self.mobileSession:ExpectEvent(event, "EndService ACK")
    :Timeout(15000)
    :ValidIf(function(s, data)
               if data.frameInfo == 5 then return true
               else return false, "EndService NACK received" end
             end)

end
]]

function Test:Case_PerformAudioPassThruTest()
 local CorIdPAPT = self.mobileSession:SendRPC("PerformAudioPassThru",
  {
   audioPassThruDisplayText1 = "audioPassThruDisplayText1",
   samplingRate = "16KHZ",
   maxDuration = 10000,
   bitsPerSample = "16_BIT",
   audioType = "PCM"
  })

 local UIPAPTid
  EXPECT_HMICALL("UI.PerformAudioPassThru")
    :Do(function(_,data)
          UIPAPTid = data.id
          local function to_be_run()
                  self.hmiConnection:SendResponse(UIPAPTid, "UI.PerformAudioPassThru", "SUCCESS", { })
                end
          RUN_AFTER(to_be_run, 2000)
        end)

  EXPECT_NOTIFICATION("OnAudioPassThru")
     :Times(AnyNumber())
     -- :Do(function(exp, data)
     --     if exp.occurences == 5 then
     --         self.hmiConnection:Send({
     --                                   id = UIPAPTid,
     --                                   jsonrpc = "2.0",
     --                                   result = { method = "UI.PerformInteraction", code = 0 }
     --                                 })
     --       end
     --     end)

 EXPECT_RESPONSE(CorIdPAPT, { success = true, resultCode = "SUCCESS" })
   :Timeout(15000)

end

function Test:sendOnSystemContext(ctx)
  self.hmiConnection:SendNotification("UI.OnSystemContext", { appID = self.applications["Test Application"], systemContext = ctx })
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
        self:sendOnSystemContext("ALERT")
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
            self.hmiConnection:SendNotification("TTS.Started")
          elseif exp.occurences == 2 then
            self.hmiConnection:SendResponse(TTSSpeakRequestId, "TTS.Speak", "SUCCESS", { })
            self.hmiConnection:SendNotification("TTS.Stopped")
          elseif exp.occurences == 3 then
            RUN_AFTER(function()
                        self.hmiConnection:SendResponse(AlertRequestId, "UI.Alert", "SUCCESS", { })
                      end, 3000)
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
          self:sendOnSystemContext("MAIN")
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
        self:sendOnSystemContext("ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:SendResponse(AlertRequestId, "UI.Alert", "SUCCESS", { })
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
          self:sendOnSystemContext("MAIN")
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
        self:sendOnSystemContext("ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:SendResponse(AlertRequestId, "UI.Alert", "SUCCESS", {})
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
          self:sendOnSystemContext("MAIN")
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
        self:sendOnSystemContext("ALERT")
      end)

  EXPECT_NOTIFICATION("OnHMIStatus",
    { systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
    { systemContext = "MAIN",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE" })
    :Times(2)
    :Do(function(exp, data)
          if exp.occurences == 1 then
            self.hmiConnection:SendResponse(AlertRequestId, "UI.Alert", "SUCCESS", { })
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
          self:sendOnSystemContext("MAIN")
        end)
end

function Test:CorrectHmiRawJSON()
  self.hmiConnection:Send('{"jsonrpc":"2.0", "method":"Buttons.OnButtonPress", "params":{"name": "PRESET_2", "mode": "SHORT"}}')
end

function Test:IncorrectMobileJSON()
  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

  local msg =
  {
    serviceType      = 7,
    frameInfo        = 0,
    rpcType          = 0,
    rpcFunctionId    = 12,
    rpcCorrelationId = self.mobileSession.correlationId,
    payload          = "{A}"
  }
  self.mobileSession:Send(msg)
  EXPECT_RESPONSE(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
end

function Test:Stop()
  self.mobileSession:StopService(7)
end

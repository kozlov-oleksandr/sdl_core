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

function Test:Stop()
  self.mobileSession:StopService(7)
end

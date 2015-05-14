Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
--local config = require('config')

--function Test:WaitActivation()
  --EXPECT_NOTIFICATION("OnHMIStatus")
  --local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  --EXPECT_HMIRESPONSE(rid)
--end

-- function Test:ActivationApp()
--     --hmi side: send request SDL.ActivateApp
--     local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})

--     --hmi side: expect SDL.ActivateApp response from SDL
--  EXPECT_HMIRESPONSE(RequestId)
--  :Do(function(_,data)
--      if
--          data.result.isSDLAllowed ~= true then
--                 --hmi side: send request SDL.GetUserFriendlyMessage
--              local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
--                   --hmi side: send request SDL.GetUserFriendlyMessage
--          EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
--                :Do(function(_,data)
--             --hmi side: send notification SDL.OnAllowSDLFunctionality
--             self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = 1, name = "127.0.0.1"}})
--                end)

--                 --hmi side: expect BasicCommunication.ActivateApp request from SDL
--                 EXPECT_HMICALL("BasicCommunication.ActivateApp")
--                 :Do(function(_,data)
--                     --hmi side: sending BasicCommunication.ActivateApp response from HMI
--                     self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
--           end)
--         elseif data.result.code ~= 0 then
--             --In case when activation is not successfull script execution is finish
--      quit()
--   end
--       end)

--     --mobile side: receiving OnHMIStatus notification
--    EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL"}) 

-- end

-- The current application should be unregistered before next test. 
  function Test:UnregisterAppInterface_Success()
    --request from mobile side
        local CorIdUnregisterAppInterface = self.mobileSession:SendRPC("UnregisterAppInterface",{})

    --response on mobile side
    EXPECT_RESPONSE(CorIdUnregisterAppInterface, { success = true, resultCode = "SUCCESS"})
    :Timeout(2000)
    end

  -- Register the app again 
  function Test:RegisterAppInterface_Success()
    --request from mobile side
        local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

        --response on mobile side
        EXPECT_RESPONSE(correlationId, { success = true, resultCode = "SUCCESS" })

        --Notification on mobile side
   -- EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE"}) 

  end

 
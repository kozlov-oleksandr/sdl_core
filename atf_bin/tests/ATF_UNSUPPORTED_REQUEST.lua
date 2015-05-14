Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_AlertManeuverPositive()
  EXPECT_HMICALL("Navigation.AlertManeuver")
  :Do(function(_,data)
        AlertRequestId = data.id
      end)

  EXPECT_HMICALL("TTS.Speak",
  { 
    ttsChunks = 
    { 
      { text = "FirstAlert", type = "TEXT"},
      { text = "SecondAlert", type = "TEXT"} 
    }
  })
  :Do(function(exp, data)
  	  self.hmiConnection:SendResponse(data.id, "TTS.Speak", "SUCCESS", {})
      self.hmiConnection:SendResponse(AlertRequestId, "Navigation.AlertManeuver", "UNSUPPORTED_REQUEST", {})
      self.hmiConnection:SendResponse(AlertRequestId, "TTS.Speak", "ABORTED", {})
    end)
  local cid = self.mobileSession:SendRPC("AlertManeuver",
  {
    ttsChunks = 
    { 
      { text = "FirstAlert", type = "TEXT"},
      { text = "SecondAlert", type = "TEXT"} 
    }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_REQUEST" })
end

function Test:Case_ShowConstantTBTPositive()
  EXPECT_HMICALL("Navigation.ShowConstantTBT",
  { 
    navigationTexts =
    {
      { fieldName = "navigationText1", fieldText = "navigationText1" },
      { fieldName = "navigationText2", fieldText = "navigationText2" },
      { fieldName = "ETA", fieldText = "12:34" },
      { fieldName = "totalDistance", fieldText = "100miles" }
    },		
    distanceToManeuver = 50.5,
    distanceToManeuverScale = 100.1,
    maneuverComplete = false
  })
  :Do(function(exp, data)
        self.hmiConnection:SendResponse(data.id, "Navigation.ShowConstantTBT", "UNSUPPORTED_REQUEST", {})
      end)
  local cid = self.mobileSession:SendRPC("ShowConstantTBT",
  {
    navigationText1 = "navigationText1",
    navigationText2 = "navigationText2",
    eta = "12:34",
    totalDistance = "100miles",		
    distanceToManeuver = 50.5,
    distanceToManeuverScale = 100.1,
    maneuverComplete = false
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_REQUEST" })
end

function Test:Case_UpdateTurnListPositive()
  EXPECT_HMICALL("Navigation.UpdateTurnList",
  { 
    turnList = 
    { 
      { navigationText = { fieldText = "Text1" } }, 
      { navigationText = { fieldText = "Text2" } } 
    }
  })
  :Do(function(exp, data)
        self.hmiConnection:SendResponse(data.id, "Navigation.UpdateTurnList", "UNSUPPORTED_REQUEST", {})
      end)
  local cid = self.mobileSession:SendRPC("UpdateTurnList",
  {
    turnList = 
    { 
      { navigationText ="Text1" }, 
      { navigationText ="Text2" } 
    }
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_REQUEST" })
end

function Test:Case_ShowConstantTBTPositive()
  EXPECT_HMICALL("UI.SetDisplayLayout",
  { 
    displayLayout = "displayLayout"
  })
  :Do(function(exp, data)
        self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_REQUEST", {})
      end)
  local cid = self.mobileSession:SendRPC("SetDisplayLayout",
  {
    displayLayout = "displayLayout"
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_REQUEST" })
end

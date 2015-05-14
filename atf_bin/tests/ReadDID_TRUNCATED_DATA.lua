Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_ReadDIDPositive()
  EXPECT_HMICALL("VehicleInfo.ReadDID", { ecuName = 2000, didLocation = { 56832 } })
  :Do(function(_, data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", 
      	  { 
      	    didResult =
      	    {
      	      { resultCode="TRUNCATED_DATA",  didLocation = 56832 }
      	    }
      	  })
      end)

  local cid = self.mobileSession:SendRPC("ReadDID",  
  {
    ecuName = 2000,
    didLocation = { 56832 }
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" }) 
end

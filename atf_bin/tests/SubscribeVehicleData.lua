Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_SubscribeVehicleDataSuccess(_) 
	EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { prndl = true })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("SubscribeVehicleData", { prndl = true	})
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_SubscribeVehicleData_DATA_ALREADY_SUBSCRIBED(_)
	local cid = self.mobileSession:SendRPC("SubscribeVehicleData", { prndl = true })
  EXPECT_RESPONSE(cid, 
    { success = false, 
  		resultCode = "IGNORED", 
  		prndl = {
    				    dataType   = "VEHICLEDATA_PRNDL",
    						resultCode = "DATA_ALREADY_SUBSCRIBED"
  				    }, 
  		info = "Already subscribed on provided VehicleData."
  	})
end 

function Test:Case_UnsubscribeVehicleDataSuccess(_) 
	EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData", { prndl = true })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("UnsubscribeVehicleData", 
	{
	  prndl = true	
	})
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

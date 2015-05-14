Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_SubscribeVehicleDataSuccess(_) 
	EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { prndl = true	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})        
      end)
	local cid = self.mobileSession:SendRPC("SubscribeVehicleData", { prndl = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end 

function Test:Case_UnsubscribeVehicleDataSuccess(_)
	EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData", { prndl = true	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})  
      end)

	local cid = self.mobileSession:SendRPC("UnsubscribeVehicleData", { prndl = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end

function Test:Case_UnsubscribeVehicleData_DATA_NOT_SUBSCRIBED(_)
	local cid = self.mobileSession:SendRPC("UnsubscribeVehicleData", { prndl = true })
  EXPECT_RESPONSE(cid, 
    { 
	    success = false, 
			resultCode = "IGNORED",
			info = "Was not subscribed on any VehicleData.",
			prndl = {
				dataType = "VEHICLEDATA_PRNDL",
				resultCode = "DATA_NOT_SUBSCRIBED"
			}
		})
end 

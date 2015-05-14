Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_Precondition_Subscribe_GPS_and_SPEED(_)
	EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { gps = true	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("SubscribeVehicleData", { gps = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end 

function Test:Case_SubscribeSpeed(_)
	EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { speed = true	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("SubscribeVehicleData", { speed = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end 

function Test:Case_UnsubscribeGPS(_)
	EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData", { gps = true	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("UnsubscribeVehicleData", { gps = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end 

function Test:Case_UnsubscribeGPSandSpeed(_)
	EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData",{ gps = true,	speed = true,	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	local cid = self.mobileSession:SendRPC("UnsubscribeVehicleData", { gps = true, speed = true })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
end 


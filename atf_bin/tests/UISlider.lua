Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

function Test:Case_showStringsLowerBoun()
	EXPECT_HMICALL("UI.Slider", 
	{ 		
	  numTicks = 2,
  	position = 2,
  	sliderHeader = "Slider Header",
  	timeout = 5000,
  	sliderFooter = { "Slider Footer" }
  })
	:Do(function(_,data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)
	  local cid = self.mobileSession:SendRPC("Slider", 
	  {
      numTicks = 2,
      position = 2,
      sliderHeader = "Slider Header",
      timeout = 5000,
      sliderFooter = { "Slider Footer" }
	  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_numTicksUpperBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 		
    numTicks = 26,
    position = 5,
    sliderHeader = "Slide Header",
    timeout = 5000,
    sliderFooter = { "Slider Footer" }
	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
	  local cid = self.mobileSession:SendRPC("Slider", 
	  {
      numTicks = 26,
      position = 5,
      sliderHeader = "Slide Header",
      timeout = 5000,
      sliderFooter = { "Slider Footer" }
	  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_positionUpperBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 		
    numTicks = 26,
    position = 26,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = { "Footer" }
  })
	:Do(function(_,data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {
    numTicks = 26,
    position = 26,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = {"Footer"}
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_sliderHeaderLowerBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 		
    numTicks = 25,
    position = 5,
    sliderHeader = "H",
    timeout = 5000,
    sliderFooter = { "Footer" }
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {
    numTicks = 25,
    position = 5,
    sliderHeader = "H",
    timeout = 5000,
    sliderFooter = { "Footer" }
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_sliderHeaderUpperBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 		
    numTicks = 15,
    position = 3,
    sliderHeader = "qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^    _+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcv",
    timeout = 5000,
    sliderFooter = { "Footer" }
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {		   		
  	numTicks = 15,
  	position = 3,
  	sliderHeader = "qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^    _+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcv",
  	timeout = 5000,
  	sliderFooter = { "Footer" }
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_sliderFooterLowerBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{
    numTicks = 25,
    position = 5,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = { "F" }
	})
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
 local cid = self.mobileSession:SendRPC("Slider", 
  {	   		
  	numTicks = 25,
  	position = 5,
  	sliderHeader = "Header",
  	timeout = 5000,
  	sliderFooter = { "F" }
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
	end 

function Test:Case_sliderFooterUpperBound(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 
    numTicks = 15,
    position = 3,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = { "qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^    _+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcv"} 
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {	   		
    numTicks = 15,
    position = 3,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = {"qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^    _+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=QWERTYUIOPASDFGHJKLZXCVBNM{}|?>:<qwertyuiopasdfghjklzxcvbnm1234567890[]'.!@#$%^&*()_+-=qwertyuiopasdfghjklzxcv"}    
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_sliderFooterUpperBoundSize(_)
	EXPECT_HMICALL("UI.Slider", 
	{
    numTicks = 26,
    position = 5,
    sliderHeader = "Header",
    timeout = 5000,
    sliderFooter = { "Footer1", "Footer2", "Footer3", "Footer4", "Footer5", "Footer6", "Footer7", "Footer8", "Footer9", "Footer10", "Footer11", "Footer12", "Footer13", "Footer14", "Footer15", "Footer16", "Footer17","Footer18", "Footer19", "Footer20", "Footer21", "Footer22", "Footer23", "Footer24", "Footer25", "Footer26" }
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
    {       		
      numTicks = 26,
      position = 5,
      sliderHeader = "Header",
      timeout = 5000,
      sliderFooter = {"Footer1", "Footer2", "Footer3", "Footer4", "Footer5", "Footer6", "Footer7", "Footer8", "Footer9", "Footer10", "Footer11", "Footer12", "Footer13", "Footer14", "Footer15", "Footer16", "Footer17","Footer18", "Footer19", "Footer20", "Footer21", "Footer22", "Footer23", "Footer24", "Footer25", "Footer26" }   	        
    })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_timeoutLowerBoundSize(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 	
    numTicks = 17,
    position = 10,
    sliderHeader = "Header",
    timeout = 1000,
    sliderFooter = { "Footer" }
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {		   		
  	numTicks = 17,
  	position = 10,
  	sliderHeader = "Header",
  	timeout = 1000,
  	sliderFooter = {"Footer"}
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end 

function Test:Case_timeoutUpperBoundSize(_)
	EXPECT_HMICALL("UI.Slider", 
	{ 		
    numTicks = 16,
    position = 3,
    sliderHeader = "Header",
    timeout = 65535,
    sliderFooter = { "Footer" }
  })
	:Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
  local cid = self.mobileSession:SendRPC("Slider", 
  {	   		
  	numTicks = 16,
  	position = 3,
  	sliderHeader = "Header",
  	timeout = 65535,
  	sliderFooter = { "Footer" }
  })
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
	end 

return Test

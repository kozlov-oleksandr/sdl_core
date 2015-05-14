Test = require('connecttest')
require('cardinalities')

function Test:WaitActivation()
  EXPECT_NOTIFICATION("OnHMIStatus")
  local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(rid)
end

--===============================================================================================================--
--different values of menuID parameters (minimum = 0, maximum = 2000000000)
--===============================================================================================================--
--minimum menuID value
function Test:Case_SubMenuMinMenuID()
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 1,
    menuParams = { menuName = "SubMenu1" }
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 1,
    menuName = "SubMenu1"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--===============================================================================================================--
--maximum menuID value
function Test:Case_SubMenuMaxMenuID()
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 2000000000,
    menuParams = { menuName = "SubMenu2000000000" }
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 2000000000,
    menuName = "SubMenu2000000000"
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end


--===============================================================================================================--
--different values of position parameters (minimum = 0, maximum = 1000)
--===============================================================================================================--
--minimum position value
function Test:Case_SubMenuMinPosition()
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 3,
    menuParams = { menuName = "SubMenu3", position = 0 }
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 3,
    menuName = "SubMenu3",
    position = 0
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--===============================================================================================================--
--maximum position value
function Test:Case_SubMenuMinPosition()
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 4,
    menuParams = { menuName = "SubMenu4", position = 1000 }
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)

  local cid = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 4,
    menuName = "SubMenu4",
    position = 1000
  })
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--===============================================================================================================--
--send error result code 
--===============================================================================================================--
--resultCode = "GENERIC_ERROR"
function Test:Case_errorResultCode()
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 5,
    menuParams = { menuName = "SubMenu5"}
  })
  :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "GENERIC_ERROR", {}) -- send resultCode = "GENERIC_ERROR", code = 22
      end)

  local cid = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 5,
    menuName = "SubMenu5"
  })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR" })
  EXPECT_NOTIFICATION("OnHashChange")
end

return Test

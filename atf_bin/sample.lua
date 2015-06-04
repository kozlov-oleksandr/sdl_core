Test = require('connecttest')
require('cardinalities')
local hmi_connection = require('hmi_connection')
local websocket      = require('websocket_connection')
local module         = require('testbase')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')

--//////////////////////////////////////////////////////////////////////////////////--
--Script checks 
---- main expectation function of ATF: EXPECT_RESPONSE, EXPECT_NOTIFICATION, EXPECT_ANY,
-- EXPECT_ANY_SESSION_NOTIFICATION, EXPECT_HMIRESPONSE, EXPECT_HMINOTIFICATION;
---- sending, receiving requests, responces, notifications from HMI and mobile side;
---- processing RPC throught different interfaces;
---- creation new sessions, connestions, openning, closing services;
---- RPC with bulk data, with float data, empty;
---- sending invalid JSON from HMI, mobile side;


--//////////////////////////////////////////////////////////////////////////////////--
-- 2.Check processing messages on UI interface
function Test:Case_ShowTest()
 local CorIdShow = self.mobileSession:SendRPC("Show",
  {
    mainField1 = "Show mÜin Field 1",
    mainField2 = "Show main Field 2",
    mainField3 = "Show main Field 3",
    mediaClock = "12:04"
  })

  EXPECT_HMICALL("UI.Show", 
  {
    showStrings = 
    {
     { fieldName = "mainField1",  fieldText = "Show mÜin Field 1"},
     { fieldName = "mainField2",  fieldText = "Show main Field 2"},
     { fieldName = "mainField3",  fieldText = "Show mÄin Field 3"},
     { fieldName = "mediaClock",  fieldText = "12:04"}
 },

  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id,"UI.Show", "SUCCESS", {})
      end)

  EXPECT_RESPONSE(CorIdShow, { success = true, resultCode = "SUCCESS", info = nil })
  :Timeout(2000)

end
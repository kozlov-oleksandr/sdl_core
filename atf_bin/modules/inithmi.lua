require('atf.util')
local base      = require('testbase')
local websocket = require('websocket_connection')
local config    = require('config')
local events         = require("events")
local expectations   = require('expectations')

local Event = events.Event
local Expectation = expectations.Expectation

local module = Test()
hmiConnection = websocket.WebSocketConnection(config.hmiUrl, config.hmiPort)
event_dispatcher:AddConnection(hmiConnection)

function EXPECT_HMIEVENT(event, name)
  local ret = Expectation(name, hmiConnection)
  ret.event = event
  event_dispatcher:AddEvent(hmiConnection, event, ret)
  module:AddExpectation(ret)
  return ret
end

function EXPECT_HMIRESPONSE(id)
  local event = events.Event()
  event.matches = function(self, data) return data.id == id end
  local ret = Expectation("HMI response " .. id, self)
  ret.event = event
  event_dispatcher:AddEvent(hmiConnection, event, ret)
  module:AddExpectation(ret)
  return ret
end

function EXPECT_HMICALL(methodName, ...)
  local args = table.pack(...)
  local event = events.Event()
  event.matches =
    function(self, data) return data.method == methodName end
  local ret = Expectation("HMI call " .. methodName, hmiConnection)
  if #args > 0 then
    ret:ValidIf(function(self, data)
                   local arguments
                   if self.occurences > #args then
                     arguments = args[#args]
                   else
                     arguments = args[self.occurences]
                   end
                   return compareValues(arguments, data.params, "params")
                end)
  end
  ret.event = event
  event_dispatcher:AddEvent(hmiConnection, event, ret)
  module:AddExpectation(ret)
  return ret
end

function module:InitHMI()
  local idCounter = 100
  local function registerComponent(name, subscriptions)
    local expId = idCounter
    idCounter = idCounter + 1
    local exp = EXPECT_HMIRESPONSE(expId)
    if subscriptions then
      local subscriptionIdCounter = idCounter
      for _, s in ipairs(subscriptions) do
        EXPECT_HMIRESPONSE(idCounter)
        local id = idCounter
        idCounter = idCounter + 1
        exp:Do(function()
                 hmiConnection:Send({
                 {
                   jsonrpc = "2.0",
                   id      = id,
                   method  = "MB.subscribeTo",
                   params  = { propertyName = s }
                 }})
               end)
      end
    end
    hmiConnection:Send({
    {
      jsonrpc = "2.0",
      id      = expId,
      method  = "MB.registerComponent",
      params = { componentName = name }
    }})
  end

  EXPECT_HMIEVENT(events.connectedEvent, "Connected websocket")
    :Do(function()
          registerComponent("Buttons")
          registerComponent("TTS")
          registerComponent("VR")
          registerComponent("BasicCommunication",
          {
            "BasicCommunication.OnPutFile",
            "SDL.OnStatusUpdate",
            "SDL.OnAppPermissionChanged",
            "BasicCommunication.OnSDLPersistenceComplete",
            "BasicCommunication.OnFileRemoved",
            "BasicCommunication.OnAppRegistered",
            "BasicCommunication.OnAppUnregistered",
            "BasicCommunication.PlayTone",
            "BasicCommunication.OnSDLClose",
            "SDL.OnSDLConsentNeeded",
            "BasicCommunication.OnResumeAudioSource"
          })
          registerComponent("UI",
          {
            "UI.OnRecordStart"
          })
          registerComponent("VehicleInfo")
          registerComponent("Navigation")
        end)
  hmiConnection:Connect()
end

function module:OnReady()
  local function ExpectRequest(name, mandatory, response)
    local event = events.Event()
    event.level = 1
    event.matches = function(self, data) return data.method == name end
    response.code = 0
    response.method = name
    return
    EXPECT_HMIEVENT(event, name)
      :Times(mandatory and 1 or AnyNumber())
      :Do(function(_, data)
            hmiConnection:Send({
            {
              id = data.id,
              jsonrpc = "2.0",
              result = response
            }})
          end)
  end

  ExpectRequest("BasicCommunication.MixingAudioSupported",
                true,
                { attenuatedSupported = true }) 
  ExpectRequest("BasicCommunication.GetSystemInfo", false,
  {
    ccpu_version = "ccpu_version",
    language = "EN-US",
    wersCountryCode = "wersCountryCode"
  })
  ExpectRequest("UI.GetLanguage", false, { language = "EN-US" })
  ExpectRequest("UI.ChangeRegistration", false, { }):Pin()
  ExpectRequest("TTS.SetGlobalProperties", false, { }):Pin()
  ExpectRequest("BasicCommunication.UpdateDeviceList", false, { }):Pin()
  ExpectRequest("VR.ChangeRegistration", false, { }):Pin()
  ExpectRequest("TTS.ChangeRegistration", false, { }):Pin()
  ExpectRequest("VR.GetSupportedLanguages", false, {
    languages =
    {
      "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
      "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
      "PT-BR","CS-CZ","DA-DK","NO-NO"
    }
  }):Pin()
  ExpectRequest("TTS.GetSupportedLanguages", false, {
    languages =
    {
      "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
      "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
      "PT-BR","CS-CZ","DA-DK","NO-NO"
    }
  }):Pin()
  ExpectRequest("TTS.GetSupportedLanguages", false, {
    languages =
    {
      "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
      "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
      "PT-BR","CS-CZ","DA-DK","NO-NO"
    }
  }):Pin()
  ExpectRequest("VehicleInfo.GetVehicleType", false, {
    vehicleType =
    {
      make = "Ford",
      model = "Fiesta",
      modelYear = "2013",
      trim = "SE"
    }
  }):Pin()
  ExpectRequest("VehicleInfo.GetVehicleData", false, { vin = "52-452-52-752" }):Pin()

  local function button_capability(name, shortPressAvailable, longPressAvailable, upDownAvailable)
    return
    {
      name = name,
      shortPressAvailable = shortPressAvailable == nil and true or shortPressAvailable,
      longPressAvailable = longPressAvailable == nil and true or longPressAvailable,
      upDownAvailable = upDownAvailable == nil and true or upDownAvailable
    }
  end
  local buttons_capabilities =
  {
    capabilities =
    {
      button_capability("PRESET_0"),
      button_capability("PRESET_1"),
      button_capability("PRESET_2"),
      button_capability("PRESET_3"),
      button_capability("PRESET_4"),
      button_capability("PRESET_5"),
      button_capability("PRESET_6"),
      button_capability("PRESET_7"),
      button_capability("PRESET_8"),
      button_capability("PRESET_9"),
      button_capability("OK", true, false, true),
      button_capability("SEEKLEFT"),
      button_capability("SEEKRIGHT"),
      button_capability("TUNEUP"),
      button_capability("TUNEDOWN")
    },
    presetBankCapabilities = { onScreenPresetsAvailable = true }
  }
  ExpectRequest("Buttons.GetCapabilities", true, buttons_capabilities):Pin()
  ExpectRequest("VR.GetCapabilities", false, { vrCapabilities = { "TEXT" } }):Pin()
  ExpectRequest("TTS.GetCapabilities", false, {
    speechCapabilities = { "TEXT", "PRE_RECORDED" },
    prerecordedSpeechCapabilities =
    {
        "HELP_JINGLE",
        "INITIAL_JINGLE",
        "LISTEN_JINGLE",
        "POSITIVE_JINGLE",
        "NEGATIVE_JINGLE"
    }
  }):Pin()

  local function text_field(name, characterSet, width, rows)
    return
    {
      name = name,
      characterSet = characterSet or "TYPE2SET",
      width = width or 500,
      rows = rows or 1
    }
  end
  local function image_field(name, width, heigth)
    return
    {
      name = name,
      imageTypeSupported =
      {
        "GRAPHIC_BMP",
        "GRAPHIC_JPEG",
        "GRAPHIC_PNG"
      },
      imageResolution =
      {
        resolutionWidth = width or 64,
        resolutionHeight = height or 64
      }
    }

  end

  ExpectRequest("UI.GetCapabilities", false, {
    displayCapabilities =
    {
      displayType = "GEN2_8_DMA",
      textFields =
      {
          text_field("mainField1"),
          text_field("mainField2"),
          text_field("mainField3"),
          text_field("mainField4"),
          text_field("statusBar"),
          text_field("mediaClock"),
          text_field("mediaTrack"),
          text_field("alertText1"),
          text_field("alerText2"),
          text_field("alertText3"),
          text_field("scrollableMessageBody"),
          text_field("initialInteractionText"),
          text_field("navigationText1"),
          text_field("navigationText2"),
          text_field("ETA"),
          text_field("totalDistance"),
          text_field("navigationText"),
          text_field("audioPassThruDisplayText1"),
          text_field("audioPassThruDisplayText2"),
          text_field("sliderHeader"),
          text_field("sliderFooter"),
          text_field("notificationText"),
          text_field("menuName"),
          text_field("secondaryText"),
          text_field("tetriaryText"),
          text_field("timeToDestination"),
          text_field("turnText"),
          text_field("menuTitle")
      },
      imageFields =
      {
        image_field("softButtonImage"),
        image_field("choiceImage"),
        image_field("choiceSecondaryImage"),
        image_field("vrHelpItem"),
        image_field("turnIcon"),
        image_field("menuIcon"),
        image_field("cmdIcon"),
        image_field("imageTypeSupported"),
        image_field("showConstantTBTIcon"),
        image_field("showConstantTBTNextTurnIcon")
      },
      mediaClockFormats =
      {
          "CLOCK1",
          "CLOCK2",
          "CLOCK3",
          "CLOCKTEXT1",
          "CLOCKTEXT2",
          "CLOCKTEXT3",
          "CLOCKTEXT4"
      },
      graphicSupported = true,
      imageCapabilities = { "DYNAMIC", "STATIC" },
      templatesAvailable = { "TEMPLATE" },
      screenParams =
      {
        resolution = { resolutionWidth = 800, resolutionHeight = 480 },
        touchEventAvailable =
        {
          pressAvailable = true,
          multiTouchAvailable = true,
          doublePressAvailable = false
        }
      },
      numCustomPresetsAvailable = 10
    },
    audioPassThruCapabilities =
    {
      samplingRate = "44KHZ",
      bitsPerSample = "8_BIT",
      audioType = "PCM"
    },
    hmiZoneCapabilities = "FRONT",
    softButtonCapabilities =
    {
      shortPressAvailable = true,
      longPressAvailable = true,
      upDownAvailable = true,
      imageSupported = true
    }
  }):Pin()

  ExpectRequest("VR.IsReady", true, { available = true })
  ExpectRequest("TTS.IsReady", true, { available = true })
  ExpectRequest("UI.IsReady", true, { available = true })
  ExpectRequest("Navigation.IsReady", true, { available = true })
  ExpectRequest("VehicleInfo.IsReady", true, { available = true })

  hmiConnection:Send({ { jsonrpc = "2.0", method = "BasicCommunication.OnReady" } })
end

return module

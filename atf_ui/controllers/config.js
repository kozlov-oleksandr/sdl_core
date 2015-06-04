var fs = require("fs");

function Config() {
  this.sdlFilePath = '';
  this.testRecordPath = '';
  this.hearBeatTimeout = '';
  this.mobileConnectionStr = '127.0.0.1:12345';
  this.hmiConnectionStr = '127.0.0.1:8087';
  this.perfLogConnectionStr = '';
  this.launchTime = '';
  this.terminalName = '';
  this.sdlStoragePath = '';
};

var connectionStringProc = function(data, userStr, configAddrStr, configPortStr) {
  var temp = userStr.lastIndexOf(':');
  var address = [userStr.substring(0, temp), userStr.substring(temp + 1)];
  if (address.length !== 2) {
    console.log("Failed to parse " + configAddrStr + " connection string.");
    return null;
  } else {
    var updatedData = data;
    var ip = address[0].trim();
    var port = address[1].trim();
    if (-1 === updatedData.indexOf(configAddrStr)) {
        updatedData = updatedData.replace(/local config = \{ \}/,
            "local config = { }\nconfig." + configAddrStr + " = \"" + ip+"\"");
    } else {
      var regExp = new RegExp("config\\." + configAddrStr + ".*");
        updatedData = updatedData.replace(regExp,
            "config." + configAddrStr + " = \"" + ip+"\"");
    }
    if (-1 === updatedData.indexOf(configPortStr)) {
      updatedData = updatedData.replace(/local config = \{ \}/,
            "local config = { }\nconfig." + configPortStr + " = " + port);
    } else {
      var regExp = new RegExp("config\\." + configPortStr + ".*");
      updatedData = updatedData.replace(regExp,
            "config." + configPortStr + " = " + port);
    }
    return updatedData;
  }
};

var CONFIG_FILE_PATH = '/tmp/config.json';
var ATF_CONFIG_FILE_PATH = __dirname + "/../../atf_bin" + "/modules/config.lua";

function updateATFConfig(config) {
  fs.readFile(ATF_CONFIG_FILE_PATH, 'utf8',
    function(err, data) {
      if (err) {
        console.log("Failed to read ATF config file. " + err);
        return;
      }
      var updatedData = data;
      if (config.sdlStoragePath !== '') {
        if (-1 === data.indexOf('SDLStoragePath')) {
            updatedData = data.replace(/local config = \{ \}/,
                "local config = { }\nconfig.SDLStoragePath = \"" + config.sdlStoragePath+"\"");
        } else {
            updatedData = data.replace(/config\.SDLStoragePath.*/,
                "config.SDLStoragePath = \"" + config.sdlStoragePath+"\"");
        }
      }
      if (config.mobileConnectionStr !== "") {
        var res = connectionStringProc(updatedData, config.mobileConnectionStr,
                                       "mobileHost","mobilePort");
        if (res) updatedData = res;
      }
      if (config.hmiConnectionStr !== "") {
        var res = connectionStringProc(updatedData, "ws://" + config.hmiConnectionStr,
                                       "hmiUrl", "hmiPort");
        if (res) updatedData = res;
      }
      fs.writeFileSync(ATF_CONFIG_FILE_PATH, updatedData, 'utf8');
  });
};

module.exports = {
  Config: Config,
  updateATFConfig: updateATFConfig
};

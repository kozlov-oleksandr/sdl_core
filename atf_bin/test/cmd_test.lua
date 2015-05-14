local utils  = require ("atf.cmdutils")
config = require('config')
arguments = {}
local script_file = ''

utils.declare_opt("-c", "--config-file", utils.RequiredArgument, "Config file")
utils.declare_long_opt("--mobile-connection", utils.RequiredArgument, "Mobile connection IP")
utils.declare_long_opt("--mobile-connection-port", utils.RequiredArgument, "Mobile connection port")
utils.declare_long_opt("--hmi-connection", utils.RequiredArgument, "HMI connection IP")
utils.declare_long_opt("--hmi-connection-port", utils.RequiredArgument, "HMI connection port")
utils.declare_long_opt("--perflog-connection", utils.RequiredArgument, "PerfLog connection IP")
utils.declare_long_opt("--perflog-connection-port", utils.RequiredArgument, "Perflog connection port")
utils.declare_long_opt("--report-path", utils.RequiredArgument, "Path for a report collecting.")
utils.declare_long_opt("--report-mark", utils.RequiredArgument, "Specify label of string for marking test report.")

d = qt.dynamic()

function config_file(config_file)

    if (type(config_file) == 'string') then
	config_file = config_file:gsub('%.', " ")
	config_file = config_file:gsub("/", ".")
	config_file = config_file:gsub("[%s]lua$", "")
--	print(string.format("Use new config file:%s \n", config_file))
	config = require(tostring(config_file))
    else
	print("Incorrect config file type")
	d.quit()
    end
end
function mobile_connection(str)
      config.mobileHost = str
--      print("Mobile Connection String: ".. config.mobileHost)
end
function mobile_connection_port(src)
    config.mobilePort= src
--    print("Mobile Connection port: ".. src)
end
function hmi_connection(str)
    config.hmiUrl = str
--    print("HMI connection string: ".. str)
end
function hmi_connection_port(src)
      config.hmiPort = src
--    print("HMI Connection port: ".. src)
end
function perflog_connection(str)
    print("PerfLog connection string: ".. str)
end
function perflog_connection_port(str)
    print("PerfLog connection port: ".. str)
end
function report_path(src)
    print("Report Path: ".. src)
end
function report_mark(src)
    print("Report mark: ".. src)
end
function test_keys(src)
--    print("Test file: ".. src)
    script_file = src
end


function d.cmd_test()
    arguments = utils.getopt(argv, opts)
    if (arguments) then
	config_file(arguments['config-file'])
        for k,v in pairs(arguments) do
    	    if (type(k) ~= 'number') then
		if ( k ~= 'config-file') then
		    k = (k):match ("^%-*(.*)$"):gsub ("%W", "_")
		    _G[k](v)
		end
	    else
		if k >= 2 and v ~= "test/cmd_test.lua" then
    		    test_keys(v)
		end
	    end 
	end
    end
-- utils.PrintUsage()

    dofile(script_file)
end


d:cmd_test()

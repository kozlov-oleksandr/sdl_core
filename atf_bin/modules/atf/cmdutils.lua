local stdutils = require("atf.stdlib.argument_parser")

local _G = _G

local _ENV = nil

local stdlib = {
    _VERSION = "stdlib 41.2.0",
    _DESCRIPTION = "Standard Lua libraries",
    parser = stdutils
}

_G.stdlib = stdlib.parser

return stdlib.parser

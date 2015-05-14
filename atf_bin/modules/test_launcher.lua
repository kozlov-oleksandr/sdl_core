os.setlocale("C")
local ed = require("event_dispatcher")

event_dispatcher = ed.EventDispatcher()

function InitHMI()
  LaunchTest("modules/inithmi.lua", true)
end

function Run()
  if #tests == 0 then quit() return end
  current = 1
  LaunchTest(tests[current])
end

_d = qt.dynamic()
function _d:next()
  print("DEBUG: Launcher._d:next")
  if not current then return end
  current = current + 1
  if current > #tests then
    print("DEBUG: Launcher._d:next quit")
    quit()
    return
  end
  LaunchTest(tests[current], false)
end

function LaunchTest(filename, global)
  local context
  if global then
    context = _G
  else
    context = { }
    setmetatable(context, { __index = _G })
  end
  local testchunk, errorMessage = loadfile(filename, "tb", context)
  if testchunk then
    local test = testchunk()
    qt.connect(test._d, "finished()", _d, "next()")
    test._Context = context
    test:Start()
  else
    error(errorMessage)
  end
end

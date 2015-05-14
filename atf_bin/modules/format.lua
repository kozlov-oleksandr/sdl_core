local module = { }
console = require('console')
function module.PrintCaseResult(caseName, success, errorMessage, timespan)
  caseName = tostring(caseName)
  if #caseName > 35 then
    caseName = string.sub(caseName, 1, 32) .. "..."
  else
    caseName = caseName .. string.rep(' ', 35 - #caseName)
  end
  str = string.format("%s    %s (%d ms)", caseName, console.setattr(
     success and "[SUCCESS]" or "[FAIL]",
     success and "green"     or "red",
     2, false),
     timespan)
  print(str)
  if not success and errorMessage then
    for k, v in pairs(errorMessage) do
      print(console.setattr("  " .. k .. ": " .. v, "cyan", 1))
    end
  end
  return module
end
return module

function compareValues(a, b, name)
  local function iter(a, b, name, msg)
    if type(a) == 'table' and type(b) == 'table' then
      local res = true
      for k, v in pairs(a) do
        res = res and iter(v, b[k], name .. "." .. k, msg)
      end
      return res
    else
      if a == b then
        return true
      else
        table.insert(msg, string.format("%s: expected: %s, actual value: %s", name, a, b))
        return false
      end
    end
  end
  local message = { }
  local res = iter(a, b, name, message)
  return res, table.concat(message, '\n')
end

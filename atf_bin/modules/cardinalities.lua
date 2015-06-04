local module = { }
module.mt = { __index = { } }
function module.Cardinality(lower, upper)
  local c = { }
  c.lower = lower
  c.upper = upper
  setmetatable(c, module.mt)
  return c
end

function AnyNumber(num)
  return module.Cardinality(0, nil)
end

function AtLeast(num)
  if num <= 0 then
    error("AtLeast: number must be greater than 0")
  end
  return module.Cardinality(num, nil)
end

function AtMost(num)
  if num <= 0 then
    error("AtMost: number must be greater than 0")
  end
  return module.Cardinality(0, num)
end

function Between(a, b)
  if (a > b) then
    error("Between: `from' must be less than `to'")
  end
  return module.Cardinality(a, b)
end
function Exactly(num)
  return module.Cardinality(num, num)
end
return module

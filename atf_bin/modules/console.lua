local module = { }
function module.setattr(string, color, bold, underline)
  if     color == "black"   then c = '30'
  elseif color == "red"     then c = '31'
  elseif color == "green"   then c = '32'
  elseif color == "brown"   then c = '33'
  elseif color == "blue"    then c = '34'
  elseif color == "magenta" then c = '35'
  elseif color == "cyan"    then c = '36'
  elseif color == "white"   then c = '37'
  end
  if bold == 1 then b = '2' end
  if bold == 2 then b = '22' end
  if bold == 3 then b = '1' end
  if underline then u = '4' else u = '24' end
  local prefix = nil
  if c then
    prefix = c
  end
  if b then
    if prefix then prefix = prefix .. ';' end
    prefix = prefix .. b
  end
  if u then
    if prefix then prefix = prefix .. ';' end
    prefix = prefix .. u
  end
  if prefix then
    prefix = '\27[' .. prefix .. 'm'
    suffix = '\27[0m'
  else
    prefix = ''
    suffix= ''
  end
  return prefix .. string .. suffix
end
return module

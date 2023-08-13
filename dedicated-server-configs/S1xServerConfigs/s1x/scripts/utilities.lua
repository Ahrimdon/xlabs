--[[ Utilities ]]--

function entity:setPoints( points )
    if points < 0 then
        points = 0
    end
    self.extrascore0 = points
    self.pers.extrascore0 = points
    self.score = points
    self.pers.score = points
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function vector3ToString( v, numDecimalPlaces)
	if v[0] ~= nil and v[1] ~= nil and v[2] ~= nil then
		return ("(".. round(v[0],numDecimalPlaces) ..",".. round(v[1],numDecimalPlaces) ..",".. round(v[2],numDecimalPlaces) ..")");
	elseif v.x ~= nil and v.y ~= nil and v.z ~= nil then
		return ("(".. round(v.x, numDecimalPlaces) ..",".. round(v.y,numDecimalPlaces) ..",".. round(v.z,numDecimalPlaces) ..")");
	else
		return "Not valid vector";
	end
end

function split(pString, pPattern)
    Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    fpat = "(.-)" .. pPattern
    last_end = 1
    s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
 end

 function indexof(t, value)
	for i = 1, #t do
		if (value == t[i]) then
			return i
		end
	end

	return -1
end

function size(T)
    count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
function deep_clone(obj, seen)
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
  
    -- New table; mark it as seen and copy recursively.
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[deep_clone(k, s)] = deep_clone(v, s) end
    return setmetatable(res, getmetatable(obj))
end

function alive(unit)
    return unit and unit:alive()
end

mvector3 = {
    _mockDis = 0
}

mvector3.distance = function(pos_a, pos_b)
    return mvector3._mockDis
end

mvector3._mockDistance = function(self, dist)
    self._mockDis = dist
end

LuaU = {}

function LuaU:assert(comparison)
    if comparison == true then
        print("TEST PASS: " .. debug.getinfo(2).name)
    else
        print("TEST FAIL: " .. debug.getinfo(2).name)
    end
end

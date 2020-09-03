LuaU = {}
LuaU.failedAssertions = 0
LuaU.failedTests = 0

function LuaU:assert(comparison)
    if not (comparison == true) then
        LuaU.failedAssertions = LuaU.failedAssertions + 1
        error("Assertion Fail!")
    end
end

function LuaU:runTest(func, name)
    local result, message = pcall(func)
    if result then
        print("Test pass: " .. name)
    else
        print("Test FAIL: " .. name)
        print(message)
        LuaU.failedTests = LuaU.failedTests + 1
    end
end

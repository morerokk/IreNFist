-- Fix package paths
package.path = package.path .. ";../?.lua"

require("lib/luau/luau")
require("mocks/PAYDAY/Helpers")
require("mocks/BLT/Hooks")
require("mocks/BLT/Globals")

BLT:mockSetModPath("../IRE AND FIST REBORN/")

local tests = {
    "tests/copdamage.lua"
}

local function runTests()
    for _, test in pairs(tests) do
        dofile(test)
    end
end

runTests()

if LuaU.failedTests > 0 then
    print("LUAU_UNIT_TEST_FAIL")
    print("One or more tests failed. Check the logs for details.")
    os.exit(1)
else
    print("LUAU_UNIT_TEST_PASS")
    print("All unit tests have passed.")
end

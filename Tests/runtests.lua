require("lib/luau/luau")
require("mocks/PAYDAY/Helpers")
require("mocks/BLT/Hooks")
require("mocks/BLT/Globals")

local tests = {
    "tests/copdamage.lua"
}

local function runTests()
    for _, test in pairs(tests) do
        dofile(test)
    end
end

runTests()

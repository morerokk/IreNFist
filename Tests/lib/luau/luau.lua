LuaU = {}
LuaU.failedAssertions = 0
LuaU.failedTests = 0
LuaU.beforeEachTest = {}
LuaU.afterEachTest = {}

-- Assert that it is explicitly true, not just truthy
function LuaU:assert(comparison)
    if not (comparison == true) then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert comparison to be true!")
    end
end

-- Alias for assert
function LuaU:assertTrue(comparison)
    return self:assert(comparison)
end

-- Assert explicitly false, not just falsy
function LuaU:assertFalse(comparison)
    if not (comparison == false) then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert comparison to be false!")
    end
end

-- Assert nil
function LuaU:assertNil(value)
    if not (value == nil) then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert value to be nil!")
    end
end

-- Assert truthy
function LuaU:assertTruthy(value)
    if not value then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert comparison to be truthy!")
    end
end

-- Assert falsy
function LuaU:assertFalsy(value)
    if value then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert comparison to be falsy!")
    end
end

-- Assert equal
function LuaU:assertEqual(expected, actual)
    if expected ~= actual then
        self.failedAssertions = self.failedAssertions + 1
        error("Expected assert value to be " .. tostring(expected) .. ", was " .. tostring(actual))
    end
end

function LuaU:runTest(func, name)
    if #self.beforeEachTest > 0 then
        for _, beforeFunc in pairs(self.beforeEachTest) do
            beforeFunc()
        end
    end

    local result, message = pcall(func)
    if result then
        print("Test pass: " .. name)
    else
        print("Test FAIL: " .. name)
        print(message)
        self.failedTests = self.failedTests + 1
    end

    if #self.afterEachTest > 0 then
        for _, afterFunc in pairs(self.afterEachTest) do
            afterFunc()
        end
    end
end

function LuaU:beforeEach(func)
    table.insert(self.beforeEachTest, func)
end

function LuaU:_clearBeforeEach()
    self.beforeEachTest = {}
end

function LuaU:afterEach(func)
    table.insert(self.afterEachTest, func)
end

function LuaU:_clearAfterEach()
    self.afterEachTest = {}
end

require("tests/mocks/copunit")
require("tests/mocks/playermanager")

InFmenu = {true}
IREnFIST = {
    peersWithMod = {}
}

dofile("../IRE AND FIST REBORN/utils/coputils.lua")

-- Clear all player upgrades before each test
LuaU:beforeEach(function()
    managers.player:_mockSetUpgrades({})
end)

-- Arrest on non-local players should fail
local function coputils_testunsuccessfularrest_notlocalplayer()
    local player_unit = {"some random dude"}

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit)

    LuaU:assertNil(result)
    LuaU:assertEqual("not local player unit", reason)
end

-- Arrest on non-interacting player should fail
local function coputils_testunsuccessfularrest_nointeracting()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(false)

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit)

    LuaU:assertFalse(result)
    LuaU:assertEqual("not interacting", reason)
end

-- Arrest on player who has only been interacting for 0.1 seconds should fail
local function coputils_testunsuccessfularrest_interactiontooshort()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 4.9)

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit)

    LuaU:assertFalse(result)
    LuaU:assertEqual("interaction too short", reason)
end

-- Arrest on player from a cop who is too far away should fail.
local function coputils_testunsuccessfularrest_coptoofaraway()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 2)
    mvector3:_mockDistance(999999)

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit, copMockUnit, false)

    LuaU:assertFalse(result)
    LuaU:assertEqual("too far away for non-melee arrest", reason)
end

-- Arrest on a close-by player should succeed.
local function coputils_testsuccessfularrest_copcloseby()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 2)
    mvector3:_mockDistance(10)

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit, copMockUnit, false)

    LuaU:assertEqual("arrested", result)
    LuaU:assertNil(reason)
end

-- Arrest on a melee'ing cop should succeed, regardless of distance.
local function coputils_testsuccessfularrest_meleealwaysworks()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 2)
    mvector3:_mockDistance(999999999)

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit, copMockUnit, true)

    LuaU:assertEqual("arrested", result)
    LuaU:assertNil(reason)
end

-- Arrest on a counter-strike aced player should fail and be countered with an arrest.
local function coputils_testunsuccessfularrest_counterstrike_counterarrest()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 2)
    mvector3:_mockDistance(100)
    managers.player:_mockSetUpgrades({
        player = {
            counter_arrest = true,
            arrest_knockdown = true
        }
    })

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit, copMockUnit, true)

    LuaU:assertEqual("counterarrest", result)
    LuaU:assertNil(reason)
end

-- On a counter-strike basic player, arrest should fail and be countered with a knockdown.
local function coputils_testunsuccessfularrest_counterstrike_knockdown()
    local player_unit = managers.player:player_unit()
    player_unit:_mockSetInteracting(true, 5, 2)
    mvector3:_mockDistance(100)
    managers.player:_mockSetUpgrades({
        player = {
            arrest_knockdown = true
        }
    })

    local result, reason = IREnFIST.CopUtils:CheckLocalMeleeDamageArrest(player_unit, copMockUnit, true)

    LuaU:assertEqual("countered", result)
    LuaU:assertNil(reason)
end

-- Run the tests
LuaU:runTest(coputils_testunsuccessfularrest_notlocalplayer, "coputils_testunsuccessfularrest_notlocalplayer")
LuaU:runTest(coputils_testunsuccessfularrest_nointeracting, "coputils_testunsuccessfularrest_nointeracting")
LuaU:runTest(coputils_testunsuccessfularrest_interactiontooshort, "coputils_testunsuccessfularrest_interactiontooshort")
LuaU:runTest(coputils_testunsuccessfularrest_coptoofaraway, "coputils_testunsuccessfularrest_coptoofaraway")

LuaU:runTest(coputils_testsuccessfularrest_copcloseby, "coputils_testsuccessfularrest_copcloseby")
LuaU:runTest(coputils_testsuccessfularrest_meleealwaysworks, "coputils_testsuccessfularrest_meleealwaysworks")
LuaU:runTest(coputils_testunsuccessfularrest_counterstrike_counterarrest, "coputils_testunsuccessfularrest_counterstrike_counterarrest")
LuaU:runTest(coputils_testunsuccessfularrest_counterstrike_knockdown, "coputils_testunsuccessfularrest_counterstrike_knockdown")

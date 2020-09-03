require("tests/mocks/copdamage")

InFmenu = {true}
IreNFist = {true}

dofile("../IRE AND FIST REBORN/lua/copdamage.lua")

local function copdamage_test_if_melee_doesnt_crash()
    CopDamage:mock_make_movable()
    CopDamage:damage_melee()
    LuaU:assert(true)
end

local function copdamage_test_if_stationary_objects_dont_crash()
    CopDamage:mock_make_stationary()
    CopDamage:damage_melee()
    LuaU:assert(true)
end

LuaU:runTest(copdamage_test_if_melee_doesnt_crash, "copdamage_test_if_melee_doesnt_crash")
LuaU:runTest(copdamage_test_if_stationary_objects_dont_crash, "copdamage_test_if_stationary_objects_dont_crash")

dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.enablenewassaults then
	return
end

-- The . instead of a : is not a typo, this really is how they put it into the base game.
-- And yes, this really is yet another "cops spawn with no team" crash.
local coplogictravel_enter_orig = CopLogicTravel.enter
function CopLogicTravel.enter(data, new_logic_name, enter_params)
    if not data.team then
        -- Calling movement:team() will also force-initialize the team if it doesn't exist yet
        data.team = unit:movement():team()
    end

    return coplogictravel_enter_orig(data, new_logic_name, enter_params)
end

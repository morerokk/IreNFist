dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.beta then
    return
end

-- Fix dozer always sprinting
local chk_request_actionwalktochasepos_orig = TankCopLogicAttack._chk_request_action_walk_to_chase_pos
function TankCopLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, speed, end_rot)

    -- This is the same check that's done in TankCopLogicAttack.update
    -- The "walk" variable is a result of this check but the value is unused because Jules is dumb
    -- So we should re-run this check here, that way we don't have to override the whole function
	local focus_enemy = data.attention_obj
	if focus_enemy then
		local dist = focus_enemy.verified_dis
		local run_dist = focus_enemy.verified and 1500 or 800
		if dist < run_dist then
			speed = "walk"
		end
    end

	return chk_request_actionwalktochasepos_orig(data, my_data, speed, end_rot)
end

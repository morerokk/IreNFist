-- displayed reload time accounts for InF stats
-- does not include mag size changes for shotguns OFC >:(
-- not used if using weaponlib
function BlackMarketManager:get_reload_time(weapon_id)
	local function failure(err)
		Application:error("[BlackMarketManager:get_reload_time] " .. tostring(err) .. "\nReturning 1 to avoid crashing.")

		return 1, 1
	end

	if not weapon_id then
		return failure("no weapon id given")
	end

	local tweak = tweak_data.weapon[weapon_id]

	if not tweak then
		return failure("invalid weapon id: " .. tostring(weapon_id))
	end

	-- apply base reload speed mults
	local mult = 1
	mult = mult / (tweak.reload_speed_mult or 1)
	mult = mult / (tweak.empty_reload_speed_mult or 1)

	if tweak.timers.reload_empty then
		return (tweak.timers.reload_empty + (tweak.timers.reload_empty_end or 0)) * mult, (tweak.timers.reload_not_empty + (tweak.timers.reload_empty_end or 0)) * mult
	elseif tweak.timers.shotgun_reload_shell or tweak.timers.shell_reload_early then -- more surefire way of catching supported shotguns than using a value that some shotguns don't even set just so they can use the defaults
--[[
		local empty = 0
		local tactical = 0
		empty = tweak.timers.shotgun_reload_shell * tweak.CLIP_AMMO_MAX
		empty = empty + tweak.timers.shotgun_reload_first_shell_offset + tweak.timers.shotgun_reload_enter
		empty = empty + (tweak.timers.shotgun_reload_exit_empty / (tweak.timers.shotgun_reload_exit_empty_mult or 1))
		tactical = tweak.timers.shotgun_reload_shell
		tactical = tactical + tweak.timers.shotgun_reload_first_shell_offset + tweak.timers.shotgun_reload_enter
		tactical = tactical + (tweak.timers.shotgun_reload_exit_not_empty / (tweak.timers.shotgun_reload_exit_not_empty_mult or 1))
--]]
-- unused?
		local empty = 0
		local tactical = 0
		local enter_mult = tweak.timers.shotgun_reload_enter_mult or 1
		local exit_not_empty_mult = tweak.timers.shotgun_reload_exit_not_empty_mult or 1
		local exit_empty_mult = tweak.timers.shotgun_reload_exit_empty_mult or 1

		local shotgun_reload_shell = tweak.timers.shotgun_reload_shell or 0.5666666666666667
		local shotgun_reload_enter = tweak.timers.shotgun_reload_enter or 0.30
		local shotgun_reload_first_shell_offset = tweak.timers.shotgun_reload_first_shell_offset or 0.33
		local shotgun_reload_exit_empty = tweak.timers.shotgun_reload_exit_empty or 0.70
		local shotgun_reload_exit_not_empty = tweak.timers.shotgun_reload_exit_not_empty or 0.30

		empty = shotgun_reload_shell * tweak.CLIP_AMMO_MAX
		empty = empty + ((shotgun_reload_first_shell_offset + shotgun_reload_enter) / enter_mult)
		empty = empty + (shotgun_reload_exit_empty / exit_empty_mult)
		tactical = shotgun_reload_shell
		tactical = tactical + ((shotgun_reload_first_shell_offset + shotgun_reload_enter) / enter_mult)
		tactical = tactical + (shotgun_reload_exit_not_empty / exit_not_empty_mult)

		return empty * mult, tactical * mult
	else
		return self:get_reload_animation_time(weapon_id) * mult, self:get_reload_animation_time(weapon_id) * mult
	end

	return failure("no reload time found!")
end


-- straight from DMCWO
--[[
function BlackMarketManager:fire_rate_multiplier(name, categories, silencer, detection_risk, current_state, blueprint)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local tweak_data = tweak_data.weapon
	local weapon = tweak_data[name]
	local factory = tweak_data.factory[factory_id]
	if factory then
		local default_blueprint = factory.default_blueprint
		local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(factory_id, blueprint or default_blueprint)
		local rof_multiplier = 1
		local multiplier = 1
		multiplier = multiplier + 1 - managers.player:upgrade_value(name, "fire_rate_multiplier", 1)
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "fire_rate_multiplier", 1)

		for _, category in ipairs(categories) do
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "fire_rate_multiplier", 1)
		end

		for part_id, stats in pairs(custom_stats) do
			if stats.rof_mult then
				if stats.rof_mult > 1 then
					multiplier = multiplier + 1 - rof_multiplier * stats.rof_mult
				elseif stats.rof_mult < 1 then
					multiplier = multiplier / stats.rof_mult
				else
					multiplier = multiplier
				end
			end
		end

		return self:_convert_add_to_mul(multiplier)
	end
end
--]]

-- used in inventorydesc to avoid showing RoF modifier as +RoF from skill
function BlackMarketManager:fire_rate_multiplier_old(name, categories, silencer, detection_risk, current_state, blueprint)
	local multiplier = 1
	multiplier = multiplier + 1 - managers.player:upgrade_value(name, "fire_rate_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "fire_rate_multiplier", 1)

	-- why does my old_getskillstats shit need this but the full function doesn't
	if categories then
		for _, category in ipairs(categories) do
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "fire_rate_multiplier", 1)
		end
	end

	return self:_convert_add_to_mul(multiplier)
end

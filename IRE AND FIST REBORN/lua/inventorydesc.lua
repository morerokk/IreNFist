-- make weapon mods display RoF change when selected
if not BeardLib.Utils:ModLoaded("WeaponLib") then
	function WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
		local tweak_stats = tweak_data.weapon.stats
		local tweak_factory = tweak_data.weapon.factory.parts
		local modifier_stats = tweak_data.weapon[weapon_name].stats_modifiers
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		local part_data = nil
		local mod_stats = {
			chosen = {},
			equip = {}
		}

		for _, stat in pairs(WeaponDescription._stats_shown) do
			mod_stats.chosen[stat.name] = 0
			mod_stats.equip[stat.name] = 0
		end

		mod_stats.chosen.name = mod_name


		if equipped_mods then
			for _, mod in ipairs(equipped_mods) do
				if tweak_factory[mod] and tweak_factory[mod_name].type == tweak_factory[mod].type then
					mod_stats.equip.name = mod

					break
				end
			end
		end

		local curr_stats = base_stats
		local index, wanted_index = nil

		for _, mod in pairs(mod_stats) do
			part_data = nil

			if mod.name then
				if tweak_data.blackmarket.weapon_skins[mod.name] and tweak_data.blackmarket.weapon_skins[mod.name].bonus and tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus] then
					part_data = {
						stats = tweak_data.economy.bonuses[tweak_data.blackmarket.weapon_skins[mod.name].bonus].stats
					}
				else
					part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod.name, factory_id, default_blueprint)
				end
			end

			-- rof mult shit
			if tweak_factory[mod.name] and tweak_factory[mod.name].custom_stats and tweak_factory[mod.name].custom_stats.rof_mult then
				mod.fire_rate = (base_stats.fire_rate.value * tweak_factory[mod.name].custom_stats.rof_mult) - base_stats.fire_rate.value
			end
			if tweak_factory[mod.name] and tweak_factory[mod.name].custom_stats and tweak_factory[mod.name].custom_stats.inf_rof_mult then
				mod.fire_rate = (base_stats.fire_rate.value * tweak_factory[mod.name].custom_stats.inf_rof_mult) - base_stats.fire_rate.value
			end

			for _, stat in pairs(WeaponDescription._stats_shown) do
				if part_data and part_data.stats then
					if stat.name == "magazine" then
						local ammo = part_data.stats.extra_ammo
						ammo = ammo and ammo + (tweak_data.weapon[weapon_name].stats.extra_ammo or 0)
						mod[stat.name] = ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0
					elseif stat.name == "totalammo" then
						local chosen_index = part_data.stats.total_ammo_mod or 0
						chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats.total_ammo_mod)
						mod[stat.name] = base_stats[stat.name].value * tweak_stats.total_ammo_mod[chosen_index]
					elseif stat.name == "reload" then
						local chosen_index = part_data.stats.reload or 0
						chosen_index = math.clamp(base_stats[stat.name].index + chosen_index, 1, #tweak_stats[stat.name])
						local mult = 1 / tweak_data.weapon.stats[stat.name][chosen_index]
						mod[stat.name] = base_stats[stat.name].value * mult - base_stats[stat.name].value
					else
						local chosen_index = part_data.stats[stat.name] or 0

						if tweak_stats[stat.name] then
							wanted_index = curr_stats[stat.name].index + chosen_index
							index = math.clamp(wanted_index, 1, #tweak_stats[stat.name])
							mod[stat.name] = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier

							if wanted_index ~= index then
								print("[WeaponDescription._get_weapon_mod_stats] index went out of bound, estimating value", "mod_name", mod_name, "stat.name", stat.name, "wanted_index", wanted_index, "index", index)

								if stat.index then
									index = wanted_index
									mod[stat.name] = index
								elseif index ~= curr_stats[stat.name].index then
									local diff_value = tweak_stats[stat.name][index] - tweak_stats[stat.name][curr_stats[stat.name].index]
									local diff_index = index - curr_stats[stat.name].index
									local diff_ratio = diff_value / diff_index
									diff_index = wanted_index - index
									diff_value = diff_index * diff_ratio
									mod[stat.name] = mod[stat.name] + diff_value * tweak_data.gui.stats_present_multiplier
								end
							end

							local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

							if stat.offset then
								mod[stat.name] = mod[stat.name] - offset
							end

							if stat.revert then
								local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

								if stat.revert then
									max_stat = max_stat - offset
								end

								mod[stat.name] = max_stat - mod[stat.name]
							end

							if modifier_stats and modifier_stats[stat.name] then
								local mod_stat = modifier_stats[stat.name]

								if stat.revert and not stat.index then
									local real_base_value = tweak_stats[stat.name][index]
									local modded_value = real_base_value * mod_stat
									local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

									if stat.offset then
										modded_value = modded_value - offset
									end

									local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

									if stat.offset then
										max_stat = max_stat - offset
									end

									local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

									if mod_stat ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
										new_value = (new_value + mod[stat.name] / mod_stat) / 2
									end

									mod[stat.name] = new_value
								else
									mod[stat.name] = mod[stat.name] * mod_stat
								end
							end

							if stat.percent then
								local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

								if stat.offset then
									max_stat = max_stat - offset
								end

								local ratio = mod[stat.name] / max_stat
								mod[stat.name] = ratio * 100
							end

							mod[stat.name] = mod[stat.name] - curr_stats[stat.name].value
						end
					end
				end
			end
		end

		return mod_stats
	end
end




-- reload timers don't become weirdbadwrong with weaponlib on
if BeardLib.Utils:FindMod("WeaponLib") then
	local function get_reload_time( weapon_id, tweak_data )
		if tweak_data.timers.reload_empty then
			-- now accounts for InF-specific reload values
			local reload_speed_mult = tweak_data.reload_speed_mult or 1
			local reload_empty_speed_mult = tweak_data.empty_reload_speed_mult or 1
			local reload_not_empty_speed_mult = tweak_data.not_empty_reload_speed_mult or 1
			local reload_empty_end = tweak_data.timers.reload_empty_end or 0
			local reload_not_empty_end = tweak_data.timers.reload_not_empty_end or 0
			return (tweak_data.timers.reload_empty + reload_empty_end)/(reload_speed_mult*reload_empty_speed_mult), (tweak_data.timers.reload_not_empty + reload_not_empty_end)/(reload_speed_mult*reload_not_empty_speed_mult)
		elseif tweak_data.timers.shotgun_reload_shell or tweak_data.timers.shell_reload_early then -- more surefire way of catching supported shotguns than using a value that some shotguns don't even set just so they can use the defaults
--[[
			local empty = 0
			local tactical = 0
			empty = tweak_data.timers.shotgun_reload_shell * tweak_data.CLIP_AMMO_MAX
			empty = empty + tweak_data.timers.shotgun_reload_first_shell_offset + tweak_data.timers.shotgun_reload_enter
			empty = empty + tweak_data.timers.shotgun_reload_exit_empty
			tactical = tweak_data.timers.shotgun_reload_shell
			tactical = tactical + tweak_data.timers.shotgun_reload_first_shell_offset + tweak_data.timers.shotgun_reload_enter
			tactical = tactical + tweak_data.timers.shotgun_reload_exit_not_empty

			return empty, tactical
--]]
			local empty = 0
			local tactical = 0
			local reload_speed_mult = tweak_data.reload_speed_mult or 1
			local enter_mult = tweak_data.timers.shotgun_reload_enter_mult or 1
			local exit_not_empty_mult = tweak_data.timers.shotgun_reload_exit_not_empty_mult or 1
			local exit_empty_mult = tweak_data.timers.shotgun_reload_exit_empty_mult or 1

			local shotgun_reload_shell = tweak_data.timers.shotgun_reload_shell or 0.5666666666666667
			local shotgun_reload_enter = tweak_data.timers.shotgun_reload_enter or 0.30
			local shotgun_reload_first_shell_offset = tweak_data.timers.shotgun_reload_first_shell_offset or 0.33
			local shotgun_reload_exit_empty = tweak_data.timers.shotgun_reload_exit_empty or 0.70
			local shotgun_reload_exit_not_empty = tweak_data.timers.shotgun_reload_exit_not_empty or 0.30

			empty = shotgun_reload_shell * tweak_data.CLIP_AMMO_MAX
			empty = empty + ((shotgun_reload_first_shell_offset + shotgun_reload_enter) / enter_mult)
			empty = empty + (shotgun_reload_exit_empty / exit_empty_mult)
			tactical = shotgun_reload_shell
			tactical = tactical + ((shotgun_reload_first_shell_offset + shotgun_reload_enter) / enter_mult)
			tactical = tactical + (shotgun_reload_exit_not_empty / exit_not_empty_mult)

			return empty / reload_speed_mult, tactical / reload_speed_mult
		else
			return managers.blackmarket:get_reload_animation_time(weapon_id), managers.blackmarket:get_reload_animation_time(weapon_id)
		end
	end

	-- why does copying this over verbatim from weaponlib make weapon mods not show -0 in the reload time fields
	function WeaponDescription._get_modded_base_stats(name, factory_id, blueprint)
		local modded_base_stats = {}
		local index = nil
		local tweak_stats = tweak_data.weapon.stats

		local base_stats = WeaponDescription._get_base_stats(name)
		local modded_tweak_data = managers.weapon_factory:get_modded_weapon_tweak_data(name, factory_id, blueprint)
		local modifier_stats = modded_tweak_data.stats_modifiers

		for _, stat in pairs(WeaponDescription._stats_shown) do
			modded_base_stats[stat.name] = {}

			if stat.name == "magazine" then
				modded_base_stats[stat.name].index = 0
				modded_base_stats[stat.name].value = modded_tweak_data.CLIP_AMMO_MAX
			elseif stat.name == "totalammo" then
				index = math.clamp(modded_tweak_data.stats.total_ammo_mod, 1, #tweak_stats.total_ammo_mod)
				modded_base_stats[stat.name].index = modded_tweak_data.stats.total_ammo_mod
				modded_base_stats[stat.name].value = modded_tweak_data.AMMO_MAX
			elseif stat.name == "fire_rate" then
				local fire_rate = 60 / modded_tweak_data.fire_mode_data.fire_rate
				modded_base_stats[stat.name].value = fire_rate / 10 * 10
			elseif stat.name == "reload" then
				index = math.clamp(modded_tweak_data.stats[stat.name], 1, #tweak_stats[stat.name])
				modded_base_stats[stat.name].index = modded_tweak_data.stats[stat.name]
				local reload_time = get_reload_time(name, modded_tweak_data)
				local mult = 1 / tweak_data.weapon.stats[stat.name][index]
				modded_base_stats[stat.name].value = reload_time * mult
			elseif tweak_stats[stat.name] then
				index = math.clamp(modded_tweak_data.stats[stat.name], 1, #tweak_stats[stat.name])
				modded_base_stats[stat.name].index = index
				modded_base_stats[stat.name].value = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier
				local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					modded_base_stats[stat.name].value = modded_base_stats[stat.name].value - offset
				end

				if stat.revert then
					local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end

					modded_base_stats[stat.name].value = max_stat - modded_base_stats[stat.name].value
				end

				if modifier_stats and modifier_stats[stat.name] then
					local mod = modifier_stats[stat.name]

					if stat.revert and not stat.index then
						local real_base_value = tweak_stats[stat.name][index]
						local modded_value = real_base_value * mod
						local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

						if stat.offset then
							modded_value = modded_value - offset
						end

						local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

						if stat.offset then
							max_stat = max_stat - offset
						end

						local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

						if mod ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
							new_value = (new_value + base_stats[stat.name].value / mod) / 2
						end

						modded_base_stats[stat.name].value = new_value
					else
						modded_base_stats[stat.name].value = modded_base_stats[stat.name].value * mod
					end
				end

				if stat.percent then
					local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end

					local ratio = modded_base_stats[stat.name].value / max_stat
					modded_base_stats[stat.name].value = ratio * 100
				end
			end

			if base_stats[stat.name] then
				if base_stats[stat.name].value then
					modded_base_stats[stat.name].value = modded_base_stats[stat.name].value - base_stats[stat.name].value
				end
				if base_stats[stat.name].index then
					modded_base_stats[stat.name].index = modded_base_stats[stat.name].index - base_stats[stat.name].index
				end
			end
		end



		-- might as well make UI support for InF's rof_mult while i'm here though
		for index, part_id in ipairs(blueprint) do
			local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon( part_id, factory_id, blueprint )
			if part_data.custom_stats and part_data.custom_stats.inf_rof_mult then
				modded_base_stats.fire_rate.value = ((base_stats.fire_rate.value + modded_base_stats.fire_rate.value) * part_data.custom_stats.inf_rof_mult) - base_stats.fire_rate.value
			end
		end


		return modded_base_stats
	end
end













local function is_weapon_category(weapon_tweak, ...)
	local arg = {
		...
	}
	local categories = weapon_tweak.categories

	for i = 1, #arg, 1 do
		if table.contains(categories, arg[i]) then
			return true
		end
	end

	return false
end

--[[ only changed this section
				elseif stat.name == "fire_rate" then
					multiplier = managers.blackmarket:fire_rate_multiplier_old(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint)
				end
--]]
-- hopefully i never get the funny idea to have an always-active skill-based rate of fire increase because this will break it
--[[
local old_getskillstats = WeaponDescription._get_skill_stats
function WeaponDescription:_get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local old_skill_stats = old_getskillstats(self, name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)

	if old_skill_stats.fire_rate then
		old_skill_stats.fire_rate.skill_in_effect = false
	end

	return old_skill_stats
end
--]]



-- rip
--[[
local old_getmodstats = WeaponDescription._get_mods_stats
function WeaponDescription:_get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local old_mod_stats = old_getmodstats(self, name, base_stats, equipped_mods, bonus_stats)

	if equipped_mods and old_mod_stats.fire_rate then
		local part_data = nil
		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data then
				if part_data.custom_stats and part_data.custom_stats.rof_mult then
					old_mod_stats.fire_rate.value = 42 --((base_stats.fire_rate.value + old_mod_stats.fire_rate.value) * part_data.custom_stats.rof_mult) - base_stats.fire_rate.value
				end
			end
		end
	end

	return old_mod_stats
end
--]]



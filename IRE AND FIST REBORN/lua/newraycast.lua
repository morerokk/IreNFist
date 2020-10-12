-- allow different weapon_hold (mostly for SPAS pump action shenanigans)
function NewRaycastWeaponBase:weapon_hold()
	return (self._burst_override_hold and self:in_burst_mode()) or self._override_hold or self:weapon_tweak_data().weapon_hold
end

--[[
Hooks:PostHook(NewRaycastWeaponBase, "_update_stats_values", "hollowtest", function(self, params)
	self._headshot_dmg_mult = 1
	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
	for part_id, stats in pairs(custom_stats) do
		if stats.headshot_dmg_mult then
			self._headshot_dmg_mult = self._headshot_dmg_mult * stats.headshot_dmg_mult
		end
	end
end)
--]]

-- from custom anim fix
function NewRaycastWeaponBase:started_reload_empty()
	local ignore_fullreload = self:weapon_tweak_data().animations.ignore_fullreload
	if self._use_shotgun_reload and not ignore_fullreload then
		return self._started_reload_empty
	end

	return nil
end

Hooks:PostHook(NewRaycastWeaponBase, "_update_stats_values", "infnewstats", function(self, params)
	self._recoil_table = self:weapon_tweak_data().recoil_table or nil
	self._recoil_loop_point = self:weapon_tweak_data().recoil_loop_point or nil
	self._rstance = nil
	self._recoil_vertical_mult = 1
	self._recoil_horizontal_mult = 1
	self._ads_recoil_vertical_mult = 1
	self._ads_recoil_horizontal_mult = 1
	self._bipod_recoil_vertical_mult = 1
	self._bipod_recoil_horizontal_mult = 1
	self._bipod_ads_recoil_vertical_mult = 1
	self._bipod_ads_recoil_horizontal_mult = 1
	self._no_auto_anim = self:weapon_tweak_data().no_auto_anim or false

	self._base_reload_speed_mult = self:weapon_tweak_data().reload_speed_mult or 1
	self._not_empty_reload_speed_mult = self:weapon_tweak_data().not_empty_reload_speed_mult or 1
	self._empty_reload_speed_mult = self:weapon_tweak_data().empty_reload_speed_mult or 1
	self._inf_rof_mult = 1 -- 
	self._mod_reload_speed_mult = 1
	self._mod_not_empty_reload_speed_mult = 1
	self._mod_empty_reload_speed_mult = 1

	self._reload_empty_2 = nil
	self._reload_empty_end_2 = nil
	self._reload_not_empty_2 = nil
	self._reload_not_empty_end_2 = nil

	self._falloff_min_dmg = self:weapon_tweak_data().falloff_min_dmg or nil
	self._falloff_min_dmg_penalty = 0
	self._falloff_begin = self:weapon_tweak_data().falloff_begin or 2000 -- 20m
	self._falloff_end = self:weapon_tweak_data().falloff_end or 4000 -- 40m

	self._pen_wall_dist_mult = self:weapon_tweak_data().pen_wall_dist_mult or 1
	self._pen_wall_dmg_mult = self:weapon_tweak_data().pen_wall_dmg_mult or 0.50
	self._pen_shield_dmg_mult = self:weapon_tweak_data().pen_shield_dmg_mult or 0.25
	self._taser_hole = self:weapon_tweak_data().taser_hole or false
--[[
	self._can_breach = false
	self._breach_power_mult = 1
--]]

	self._anim_speed_mult = self:weapon_tweak_data().anim_speed_mult or nil
	self._ads_anim_speed_mult = self:weapon_tweak_data().ads_anim_speed_mult or nil
	self._hipfire_anim_speed_mult = self:weapon_tweak_data().hipfire_anim_speed_mult or nil
	--self._ads_uses_hipfire_anim = self:weapon_tweak_data().ads_uses_hipfire_anim or nil
	--self._hipfire_uses_ads_anim = self:weapon_tweak_data().hipfire_uses_ads_anim or nil

	self._recoil_recover_delay = self:weapon_tweak_data().recoil_recover_delay or nil
	self._recoil_apply_delay = self:weapon_tweak_data().recoil_apply_delay or nil

	self._ads_movespeed_mult = self:weapon_tweak_data().ads_movespeed_mult or 1
	self._switchspeed_mult = self:weapon_tweak_data().switchspeed_mult or 1


	-- from seven's burst fire
	self._has_auto = --[[not self._locked_fire_mode and--]] (self:can_toggle_firemode() or self:weapon_tweak_data().FIRE_MODE == "auto")
	self._has_burst_fire = self:weapon_tweak_data().BURST_FIRE -- don't give select-fire weapons inherent burst functionality
	--self._has_burst_fire = (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false
	--self._has_burst_fire = (not self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) or (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false -- originally commented out
	--self._locked_fire_mode = self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) and Idstring("burst") -- originally commented out
	self._burst_size = self:weapon_tweak_data().BURST_FIRE or NewRaycastWeaponBase.DEFAULT_BURST_SIZE
	self._adaptive_burst_size = self:weapon_tweak_data().ADAPTIVE_BURST_SIZE ~= false
	self._burst_fire_rate_multiplier = self:weapon_tweak_data().BURST_FIRE_RATE_MULTIPLIER or 1
	self._delayed_burst_recoil = self:weapon_tweak_data().DELAYED_BURST_RECOIL
	self._burst_recoil_mult = self:weapon_tweak_data().BURST_RECOIL_MULT or nil
	--self._burst_fire_rate_multiplier_shots = self:weapon_tweak_data().burst_fire_rate_multiplier_shots or 0
	--self._burst_recoil_multiplier_shots = self:weapon_tweak_data().burst_recoil_multiplier_shots or 0
	self._min_adaptive_burst_length = self:weapon_tweak_data().min_adaptive_burst_length or 0
	if self:weapon_tweak_data().burst_fire_rate_table then
		self._burst_fire_rate_table = deep_clone(self:weapon_tweak_data().burst_fire_rate_table) or nil
	end
	if self:weapon_tweak_data().burst_recoil_table then
		self._burst_recoil_table = deep_clone(self:weapon_tweak_data().burst_recoil_table) or nil
	end

	self._override_hold = nil
	self._burst_override_hold = nil
	self._burst_spread_mult = self:weapon_tweak_data().BURST_SPREAD_MULT or 1

	self._akimbo_fires_single = self:weapon_tweak_data().akimbo_fires_single or false

	self._deploy_anim_override = self:weapon_tweak_data().deploy_anim_override or nil
	self._deploy_ads_stance_mod = self:weapon_tweak_data().deploy_ads_stance_mod or {translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0)}

	self._disallow_ads_while_reloading = self:weapon_tweak_data().disallow_ads_while_reloading or false

	self._spin_up_time = self:weapon_tweak_data().spin_up_time or nil
	self._spin_down_speed_mult = self:weapon_tweak_data().spin_down_speed_mult or nil

	self._alternating_reload = nil
	self._alternating_reload_state = true
	self._underbarrel_alternating_reload = nil
	self._underbarrel_alternating_reload_state = true

	self._is_dp12 = self:weapon_tweak_data().is_dp12 or nil
	self._dp12_needs_pump = false -- needs pump on next shot
	self._dp12_no_pump_rof_mult = self:weapon_tweak_data().dp12_no_pump_rof_mult or 5 -- ROF mult currently only implemented for shotguns

	if not self:is_npc() then
		self._burst_rounds_remaining = 0
		self._burst_rounds_fired = 0
	end

	self._chamber = self:weapon_tweak_data().chamber

	-- af2011 magic
	self._instant_multishot = self:weapon_tweak_data().instant_multishot
	self._instant_multishot_per_1ammo = self:weapon_tweak_data().instant_multishot_per_1ammo
	self._instant_multishot_dmg_mul = self:weapon_tweak_data().instant_multishot_dmg_mul

	self._bipod_rof_mult = self:weapon_tweak_data().bipod_rof_mult

	self._saw_ene_dmg_mult = self:weapon_tweak_data().saw_ene_dmg_mult


	if self:weapon_tweak_data().reload_stance_mod then
		self._reload_stance_mod = deep_clone(self:weapon_tweak_data().reload_stance_mod)
	end
	if self:weapon_tweak_data().reload_timed_stance_mod then
		self._reload_timed_stance_mod = deep_clone(self:weapon_tweak_data().reload_timed_stance_mod)
	end
	if self:weapon_tweak_data().equip_stance_mod then
		self._equip_stance_mod = deep_clone(self:weapon_tweak_data().equip_stance_mod)
	end
	if self:weapon_tweak_data().fire_timed_stance_mod then
		self._fire_timed_stance_mod = deep_clone(self:weapon_tweak_data().fire_timed_stance_mod)
	end
	if self:weapon_tweak_data().shotgun_ammo_stance_mod then
		self._shotgun_ammo_stance_mod = deep_clone(self:weapon_tweak_data().shotgun_ammo_stance_mod)
	end
	self._use_goldeneye_reload = self:weapon_tweak_data().use_goldeneye_reload

	-- how much of an HE round's damage is done as bullet-type instead of explosive-type
	-- defaults to 50/50
	self._bullet_damage_fraction = nil

	-- dmg mult when hitting bulldozer visor
	self._visor_dmg_mult = self:weapon_tweak_data().visor_dmg_mult or nil




	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
	for part_id, stats in pairs(custom_stats) do
		if stats.rstance then
			self._rstance = stats.rstance
		end
		if stats.recoil_table then
			self._recoil_table = stats.recoil_table
		end
		if stats.recoil_loop_point then
			self._recoil_loop_point = stats.recoil_loop_point
		end
		if stats.recoil_vertical_mult then
			self._recoil_vertical_mult = stats.recoil_vertical_mult
		end
		if stats.recoil_horizontal_mult then
			self._recoil_horizontal_mult = stats.recoil_horizontal_mult
		end
		if stats.ads_recoil_vertical_mult then
			self._ads_recoil_vertical_mult = stats.ads_recoil_vertical_mult
		end
		if stats.ads_recoil_horizontal_mult then
			self._ads_recoil_horizontal_mult = stats.ads_recoil_horizontal_mult
		end
		if stats.bipod_recoil_vertical_mult then
			self._bipod_recoil_vertical_mult = stats.bipod_recoil_vertical_mult
		end
		if stats.bipod_recoil_horizontal_mult then
			self._bipod_recoil_horizontal_mult = stats.bipod_recoil_horizontal_mult
		end
		if stats.bipod_ads_recoil_vertical_mult then
			self._bipod_ads_recoil_vertical_mult = stats.bipod_ads_recoil_vertical_mult
		end
		if stats.bipod_ads_recoil_horizontal_mult then
			self._bipod_ads_recoil_horizontal_mult = stats.bipod_ads_recoil_horizontal_mult
		end
		if stats.ads_movespeed_mult then
			self._ads_movespeed_mult = stats.ads_movespeed_mult
		end
		if stats.switchspeed_mult then
			self._switchspeed_mult = stats.switchspeed_mult
		end

		if stats.pen_wall_dist_mult then
			self._pen_wall_dist_mult = self._pen_wall_dist_mult * stats.pen_wall_dist_mult
		end
		if stats.pen_wall_dmg_mult then
			self._pen_wall_dmg_mult = self._pen_wall_dmg_mult * stats.pen_wall_dmg_mult
		end
		if stats.pen_shield_dmg_mult then
			self._pen_shield_dmg_mult = self._pen_shield_dmg_mult * stats.pen_shield_dmg_mult
		end
		if stats.taser_hole then
			self._taser_hole = stats.taser_hole
		end
		if stats.inf_rof_mult then
			self._inf_rof_mult = self._inf_rof_mult * stats.inf_rof_mult
		end

		if stats.anim_speed_mult then
			self._anim_speed_mult = stats.anim_speed_mult
		end
		if stats.ads_anim_speed_mult then
			self._ads_anim_speed_mult = stats.ads_anim_speed_mult
		end
		if stats.hipfire_anim_speed_mult then
			self._hipfire_anim_speed_mult = stats.hipfire_anim_speed_mult
		end

		if stats.armor_piercing_sub then
			self._armor_piercing_chance = math.clamp(self._armor_piercing_chance - stats.armor_piercing_sub, 0, 1)
		end
--[[
		if stats.can_breach then
			self._can_breach = stats.can_breach
		end
		if stats.breach_power_mult then
			self._breach_power_mult = self._breach_power_mult * stats.breach_power_mult
		end
--]]

		if stats.falloff_begin_mult then
			self._falloff_begin = math.clamp(self._falloff_begin * stats.falloff_begin_mult, 0, 200000)
		end
		if stats.falloff_end_mult then
			self._falloff_end = math.clamp(self._falloff_end * stats.falloff_begin_mult, 0, 200000)
		end
		if stats.falloff_min_dmg_penalty then
			self._falloff_min_dmg_penalty = self._falloff_min_dmg_penalty + stats.falloff_min_dmg_penalty
		end

		if stats.has_burst_fire then
			self._has_burst_fire = stats.has_burst_fire
		end
		if stats.has_burst_fire == false then
			self._has_burst_fire = false
		end
		if stats.burst_size then
			self._burst_size = stats.burst_size
		end
		if stats.adaptive_burst_size then
			self._adaptive_burst_size = self._adaptive_burst_size
		end
		if stats.adaptive_burst_size == false then
			self._adaptive_burst_size = false
		end
		if stats.burst_fire_rate_multiplier then
			self._burst_fire_rate_multiplier = stats.burst_fire_rate_multiplier
		end
		if stats.burst_spread_mult then
			self._burst_spread_mult = stats.burst_spread_mult
		end
		if stats.delayed_burst_recoil then
			self._delayed_burst_recoil = stats.delayed_burst_recoil
		end
		if stats.burst_recoil_mult then
			self._burst_recoil_mult = stats.burst_recoil_mult
		end
		if stats.override_hold then
			self._override_hold = stats.override_hold
		end
		if stats.burst_override_hold then
			self._burst_override_hold = stats.burst_override_hold
		end
		if stats.burst_fire_rate_table then
			self._burst_fire_rate_table = deep_clone(stats.burst_fire_rate_table) or nil
		end
		if stats.burst_recoil_table then
			self._burst_recoil_table = deep_clone(stats.burst_recoil_table) or nil
		end
		if stats.deploy_ads_stance_mod then
			if stats.deploy_ads_stance_mod.translation then
				self._deploy_ads_stance_mod.translation = self._deploy_ads_stance_mod.translation + stats.deploy_ads_stance_mod.translation
			end
			if stats.deploy_ads_stance_mod.rotation then
				self._deploy_ads_stance_mod.rotation = self._deploy_ads_stance_mod.rotation * stats.deploy_ads_stance_mod.rotation
			end
		end
		if stats.disallow_ads_while_reloading then
			self._disallow_ads_while_reloading = stats.disallow_ads_while_reloading
		end
		if stats.spin_up_time_mult and not self:is_npc() == true then -- prevent multiplayer crashes
			self._spin_up_time = self._spin_up_time * stats.spin_up_time_mult
		end
		if stats.spin_down_speed_mult and not self:is_npc() == true then
			self._spin_down_speed_mult = self._spin_down_speed_mult * stats.spin_down_speed_mult
		end

		if stats.alternating_reload then
			self._alternating_reload = stats.alternating_reload
		end

		if stats.chamber then
			self._chamber = stats.chamber
		end

		if stats.saw_ene_dmg_mult then
			self._saw_ene_dmg_mult = stats.saw_ene_dmg_mult
		end

		if stats.instant_multishot then
			self._instant_multishot = stats.instant_multishot
		end
		if stats.instant_multishot_per_1ammo then
			self._instant_multishot_per_1ammo = stats.instant_multishot_per_1ammo
		end
		if stats.instant_multishot_dmg_mul then
			self._instant_multishot_dmg_mul = stats.instant_multishot_dmg_mul
		end

		if stats.set_reload_stance_mod then
			self._reload_stance_mod = deep_clone(stats.set_reload_stance_mod)
		end
		if stats.set_equip_stance_mod then
			self._equip_stance_mod = deep_clone(stats.set_equip_stance_mod)
		end
		if stats.set_reload_timed_stance_mod then
			self._reload_timed_stance_mod = deep_clone(stats.set_reload_timed_stance_mod)
		end
		if stats.set_equip_stance_mod then
			self._equip_stance_mod = deep_clone(stats.set_equip_stance_mod)
		end
		if stats.set_fire_timed_stance_mod then
			self._fire_timed_stance_mod = deep_clone(stats.set_fire_timed_stance_mod)
		end
		if stats.set_shotgun_ammo_stance_mod then
			self._set_shotgun_ammo_stance_mod = deep_clone(stats.set_shotgun_ammo_stance_mod)
		end
		if stats.use_goldeneye_reload then
			self._use_goldeneye_reload = stats.use_goldeneye_reload
		end
		if stats.use_goldeneye_reload == false then
			self._use_goldeneye_reload = nil
		end

		if stats.mod_reload_speed_mult then
			self._mod_reload_speed_mult = self._mod_reload_speed_mult * stats.mod_reload_speed_mult
		end
		if stats.mod_not_empty_reload_speed_mult then
			self._mod_not_empty_reload_speed_mult = self._mod_not_empty_reload_speed_mult * stats.mod_not_empty_reload_speed_mult
		end
		if stats.mod_empty_reload_speed_mult then
			self._mod_empty_reload_speed_mult = self._mod_empty_reload_speed_mult * stats.mod_empty_reload_speed_mult
		end

		if stats.use_reload_2 then
			self._base_reload_speed_mult = self:weapon_tweak_data().reload_speed_mult_2 or self._base_reload_speed_mult
			self._not_empty_reload_speed_mult = self:weapon_tweak_data().not_empty_reload_speed_mult_2 or self._not_empty_reload_speed_mult
			self._empty_reload_speed_mult = self:weapon_tweak_data().empty_reload_speed_mult_2 or self._empty_reload_speed_mult
			self._reload_empty_2 = self:weapon_tweak_data().timers.reload_empty_2
			self._reload_empty_end_2 = self:weapon_tweak_data().timers.reload_empty_end_2
			self._reload_not_empty_2 = self:weapon_tweak_data().timers.reload_not_empty_2
			self._reload_not_empty_end_2 = self:weapon_tweak_data().timers.reload_not_empty_end_2
		end

		if stats.bullet_damage_fraction then
			self._bullet_damage_fraction = stats.bullet_damage_fraction
		end
		if stats.visor_dmg_mult then
			self._visor_dmg_mult = stats.visor_dmg_mult
		end
	end

	-- Tan body armor damage penalty multiplier
	local body_armor_dmg_penalty_mul = self:weapon_tweak_data().body_armor_dmg_penalty_mul
	if body_armor_dmg_penalty_mul then
		self._body_armor_dmg_penalty_mul = body_armor_dmg_penalty_mul
	else
		self._body_armor_dmg_penalty_mul = 1
	end

	-- LMG Sweep and Clear skill
	if managers.player and managers.player:has_category_upgrade("weapon", "lmg_pierce_enemies") and (self:is_category("lmg") or self:is_category("minigun")) then
		self._can_shoot_through_enemy = true
		self._body_armor_dmg_penalty_mul = self._body_armor_dmg_penalty_mul * 0.75 -- Improve armor piercing a little further for this skill
	end

	-- Rogue piercing perk
	if managers.player and managers.player:has_category_upgrade("weapon", "all_pierce_enemies") and not self:is_category("bow") and not self:is_category("crossbow") then
		self._can_shoot_through_enemy = true
		self._body_armor_dmg_penalty_mul = self._body_armor_dmg_penalty_mul * 0.75
	end
end)


local old_reload_speed_func = NewRaycastWeaponBase.reload_speed_multiplier
function NewRaycastWeaponBase:reload_speed_multiplier(...)
	local mult = old_reload_speed_func(self,...)
	-- don't apply reload multiplier twice to a shotgun-type reload
	if not self._current_reload_speed_multiplier then
		mult = mult * self._base_reload_speed_mult * self._mod_reload_speed_mult

		local locknload_check = self:is_category("smg") or self:is_category("assault_rifle") or self:is_category("snp") or self:is_category("lmg") or self:is_category("minigun") or self:is_category("shotgun")

		if self:clip_empty() then
			mult = mult * self._empty_reload_speed_mult * self._mod_empty_reload_speed_mult
			if self:is_category("akimbo") then
				mult = mult * managers.player:upgrade_value("player", "empty_akimbo_reload", 1)
			end
			-- lock 'n load reload speed
			if managers.player:upgrade_value("player", "locknload_reload", 0) > 0 and locknload_check then
				mult = mult * managers.player:upgrade_value("player", "locknload_reload", 1)
			end
		else
			-- lock 'n load progressive reload speed
			if managers.player:upgrade_value("player", "locknload_reload_partial", 0) > 0 and locknload_check and not SystemFS:exists("mods/More Weapon Stats/mod.txt") then
				local maglerp = math.clamp(1 - (self:get_ammo_remaining_in_clip()/self:get_ammo_max_per_clip()), 0, 1)
				--log("reload mult: " .. (1 + (maglerp * (managers.player:upgrade_value("player", "locknload_reload_partial", 1)-1))))
				mult = mult * (1 + (maglerp * (managers.player:upgrade_value("player", "locknload_reload_partial", 1)-1)))
			end
			mult = mult * self._not_empty_reload_speed_mult * self._mod_not_empty_reload_speed_mult
		end

		-- mastermind sharpshooter reload speed bonus
		mult = mult * managers.player:upgrade_value("player", "ugh_its_a_reload_bonus", 1)
	end

	-- alternating reload
	if not self:gadget_overrides_weapon_functions() == true and self._alternating_reload and self._alternating_reload_state == true then
		mult = mult * self._alternating_reload
	elseif self._underbarrel_alternating_reload and self._underbarrel_alternating_reload_state == true then
		mult = mult * self._underbarrel_alternating_reload
	end
	return mult
end

-- no temporary bonuses, skills, etc
function NewRaycastWeaponBase:standard_reload_speed_multiplier()
	local mult = 1

	--
	mult = mult * self._base_reload_speed_mult * self._mod_reload_speed_mult

	if self:clip_empty() then
		mult = mult * self._empty_reload_speed_mult * self._mod_empty_reload_speed_mult
	else
		mult = mult * self._not_empty_reload_speed_mult * self._mod_not_empty_reload_speed_mult
	end

	-- alternating reload
	if not self:gadget_overrides_weapon_functions() == true and self._alternating_reload and self._alternating_reload_state == true then
		mult = mult * self._alternating_reload
	elseif self._underbarrel_alternating_reload and self._underbarrel_alternating_reload_state == true then
		mult = mult * self._underbarrel_alternating_reload
	end

	return mult
end

-- apparently i can't just do a = not a
function NewRaycastWeaponBase:toggle_alternating_reload(underbarrel)
	if underbarrel then
		if self._underbarrel_alternating_reload_state == true then
			self._underbarrel_alternating_reload_state = false
		else
			self._underbarrel_alternating_reload_state = true
		end
	else
		if self._alternating_reload_state == true then
			self._alternating_reload_state = false
		else
			self._alternating_reload_state = true
		end
	end
end

function NewRaycastWeaponBase:toggle_dp12_needs_pump()
	if self._dp12_needs_pump == true then
		self._dp12_needs_pump = false
	else
		self._dp12_needs_pump = true
	end
end

function NewRaycastWeaponBase:set_dp12_needs_pump(value)
	self._dp12_needs_pump = value
end




-- WHY DID THE VANILLA SPREAD CODE MAKE THE PERFECT ADS SPREAD VALUE 2?
-- FUCK THAT SHIT
function NewRaycastWeaponBase:_get_spread(user_unit)
	local current_state = user_unit:movement()._current_state

	if not current_state then
		return 0, 0
	end

	local spread_values = self:weapon_tweak_data().spread

	if not spread_values then
		return 0, 0
	end

	local current_spread_value = spread_values[current_state:get_movement_state()]
	local spread_x, spread_y = nil

	-- get base spread
	if type(current_spread_value) == "number" then
		spread_x = self:_get_spread_from_number(user_unit, current_state, current_spread_value)
		spread_y = spread_x
	else
		spread_x, spread_y = self:_get_spread_from_table(user_unit, current_state, current_spread_value)
	end

	-- ADS/bipod multiplier
	--if current_state:in_steelsight() or current_state:_is_using_bipod() then
	-- checks for state name before running bipod check so it should no longer crash MWS
	-- Note: if the player is in VR, ADS spread is always used. It's hard enough to aim as it is.
	if _G.IS_VR or (current_state:in_steelsight() or (user_unit:movement()._current_state_name and current_state:_is_using_bipod())) then
		local ads_spread
		if current_state._moving then
			ads_spread = spread_values.moving_steelsight
		else
			ads_spread = spread_values.steelsight
		end
		if type(ads_spread) == "number" then
			spread_x = self:_get_spread_from_number(user_unit, current_state, ads_spread)
			spread_y = spread_x
		else
			spread_x = self:_get_spread_from_number(user_unit, current_state, ads_spread[1])
			spread_y = spread_y * self:_get_spread_from_number(user_unit, current_state, ads_spread[2])
		end
		if self:weapon_tweak_data().spreadadd then
			spread_x = spread_x + self:weapon_tweak_data().spreadadd.steelsight
			spread_y = spread_x
		end
	else
		if self:weapon_tweak_data().spreadadd then
			spread_x = spread_x + self:weapon_tweak_data().spreadadd[current_state:get_movement_state()]
			spread_y = spread_x
		end
	end

	if self:in_burst_mode() and self._burst_spread_mult then
		spread_x = spread_x * self._burst_spread_mult
		spread_y = spread_y * self._burst_spread_mult
	end

	-- extra multiplier
	if self._spread_multiplier then
		spread_x = spread_x * self._spread_multiplier[1]
		spread_y = spread_y * self._spread_multiplier[2]
	end


--[[
	-- get base spread values
	-- ADS values (also used if bipodded)
	if current_state:in_steelsight() or current_state:_is_using_bipod() then
		local ads_spread = spread_values.steelsight
		if type(ads_spread) == "number" then
			spread_x = ads_spread
			spread_y = spread_x
		else
			spread_x = ads_spread[1]
			spread_y = ads_spread[2]
		end
	-- standing/hipfire values
	else
		local hipfire_spread = spread_values[current_state:get_movement_state()]
		if type(hipfire_spread) == "number" then
			spread_x = hipfire_spread
			spread_y = spread_x
		else
			spread_x = hipfire_spread[1]
			spread_y = hipfire_spread[2]
		end
	end

	-- apply modifier based on spread indices
	spread_x, spread_y = self:_get_spread_from_table(user_unit, current_state, {spread_x, spread_y})

	-- apply base game multipliers
	if self._spread_multiplier then
		spread_x = spread_x * self._spread_multiplier[1]
		spread_y = spread_y * self._spread_multiplier[2]
	end
--]]

	return spread_x, spread_y
end

-- ONE-IN-THE-CHAMBER SHIT
local updateReloadingOrig = NewRaycastWeaponBase.update_reloading
function NewRaycastWeaponBase:update_reloading(t, dt, time_left)

	if _G.IS_VR then
		return updateReloadingOrig(self, t, dt, time_left)
	end

	local speed_multiplier = self:reload_speed_multiplier()
	local shell_early_update = (self:weapon_tweak_data().timers.shell_reload_early or 0) / speed_multiplier

	-- update ammo before shell insertion animation loops again, most noticeable on china lake launcher/m32
	if self._use_shotgun_reload and self._next_shell_reloded_t and self._next_shell_reloded_t - shell_early_update < t and self._queued_shell_loaded == nil then
		if self:get_ammo_remaining_in_clip() > 0 and self._chamber and self._chamber > 0 then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip() + self._chamber, self:get_ammo_remaining_in_clip() + 1))
		else
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + 1))
		end
		self._queued_shell_loaded = true
		managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
	end
	-- update reload timers as usual
	if self._use_shotgun_reload and self._next_shell_reloded_t and self._next_shell_reloded_t < t then
		self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t() / speed_multiplier

		managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

		self._queued_shell_loaded = nil

		return true
	end
end

function NewRaycastWeaponBase:reload_expire_t()
	local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()
	if self:get_ammo_remaining_in_clip() > 0 and self._chamber then
		return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() - ammo_remaining_in_clip + self._chamber) * self:reload_shell_expire_t()
	else
		return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() - ammo_remaining_in_clip) * self:reload_shell_expire_t()
	end
end

--[[
function NewRaycastWeaponBase:reload_shell_expire_t()
	if self._use_shotgun_reload then
		return (self:weapon_tweak_data().timers.shotgun_reload_shell - (self:weapon_tweak_data().timers.shotgun_reload_shell_early or 0)) or 0.5666666666666667
	end

	return nil
end
--]]

-- damage falloff
function NewRaycastWeaponBase:get_damage_falloff(damage, col_ray, user_unit, distance)
	local range = col_ray.distance or mvector3.distance(col_ray.unit:position(), user_unit:position())
	local dmg_penalty_max = math.clamp(damage - (self._falloff_min_dmg or damage) + (self._falloff_min_dmg_penalty * 0.1), 0, damage)-- * 0.1
	local dmg_penalty = 0

	if (range > self._falloff_begin) and (range < self._falloff_end) then
		dmg_penalty = dmg_penalty_max * (range - self._falloff_begin)/(self._falloff_end - self._falloff_begin)
	elseif range > self._falloff_end then
		dmg_penalty = dmg_penalty_max
	end

	return damage - dmg_penalty
end



local old_reload_exit_expire = NewRaycastWeaponBase.reload_exit_expire_t
function NewRaycastWeaponBase:reload_exit_expire_t(...)
	local timer = old_reload_exit_expire(self,...)
	if self._use_shotgun_reload then
		timer = timer / (self:weapon_tweak_data().timers.shotgun_reload_exit_empty_mult or 1)
	end
	return timer
end

local old_reload_exit_ne_expire = NewRaycastWeaponBase.reload_not_empty_exit_expire_t
function NewRaycastWeaponBase:reload_not_empty_exit_expire_t(...)
	local timer = old_reload_exit_ne_expire(self,...)
	if self._use_shotgun_reload then
		timer = timer / (self:weapon_tweak_data().timers.shotgun_reload_exit_not_empty_mult or 1)
	end
	return timer
end

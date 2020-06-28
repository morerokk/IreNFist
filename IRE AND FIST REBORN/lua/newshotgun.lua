--[[
function ShotgunBase:setup_default()
	self._damage_near = tweak_data.weapon[self._name_id].damage_near
	self._damage_far = tweak_data.weapon[self._name_id].damage_far
	self._rays = tweak_data.weapon[self._name_id].rays or self._ammo_data.rays or 10 -- more pellets
	self._range = self._damage_far


	if tweak_data.weapon[self._name_id].use_shotgun_reload == nil then
		self._use_shotgun_reload = self._use_shotgun_reload or self._use_shotgun_reload == nil
	else
		self._use_shotgun_reload = tweak_data.weapon[self._name_id].use_shotgun_reload
	end

	if not self:weapon_tweak_data().has_magazine then
		self._hip_fire_rate_inc = managers.player:upgrade_value("shotgun", "hip_rate_of_fire", 0)
	end
end
--]]

Hooks:PostHook(ShotgunBase, "_update_stats_values", "infshotgunnewstats", function(self, params)
	--self._rays = self._ammo_data.rays or tweak_data.weapon[self._name_id].rays or 10 -- more pellets
	self._can_breach = self._can_breach or false
	self._breach_power_mult = self._breach_power_mult or 1

	if self._ammo_data then
		if self._ammo_data.can_breach then
			self._can_breach = self._ammo_data.can_breach
		end
		if self._ammo_data.breach_power_mult then
			self._breach_power_mult = self._ammo_data.breach_power_mult
		end
	end
end)



-- adjust damage via counting pellet hits
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()
local mvec_temp = Vector3()
function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = nil
	local hit_enemies = {}
	local hit_enemies_pellet_count = {}
	local hit_visors = {}
	local hit_visors_pellet_count = {}
	local hit_headshots = {}
	local hit_objects = {}
	local hit_something, col_rays = nil

	if self._alert_events then
		col_rays = {}
	end

	local damage = self:_get_current_damage(dmg_mul)
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
	local weight = 0.1
	local enemy_died = false

	-- filtering function
	local function hit_enemy(col_ray)
		-- if hit enemy
		if col_ray.unit:character_damage() then
			-- gets unit key
			local enemy_key = col_ray.unit:key()

			-- determines if headshot/visorshot
			local buck_headshot = col_ray.unit:character_damage().is_head and col_ray.unit:character_damage():is_head(col_ray.body)
			local buck_visorshot = col_ray.body:name() == Idstring("body_helmet_plate") or col_ray.body:name() == Idstring("body_helmet_glass")

			-- if enemy hasn't been hit, create a table entry for it
			if not hit_enemies_pellet_count[enemy_key] then
				hit_enemies_pellet_count[enemy_key] = 0
			end

			-- if pellet hits visor, add a pellet hit for both target and its visor, and prioritize this ray for this target
			if buck_visorshot then
				hit_enemies[enemy_key] = col_ray
				hit_enemies_pellet_count[enemy_key] = hit_enemies_pellet_count[enemy_key] + 1
				hit_visors[enemy_key] = true
				if not hit_visors_pellet_count[enemy_key] then
					hit_visors_pellet_count[enemy_key] = 0
				end
				hit_visors_pellet_count[enemy_key] = hit_visors_pellet_count[enemy_key] + 1
			-- if headshot, add a pellet hit and prioritize this ray
			elseif buck_headshot then
				hit_enemies[enemy_key] = col_ray
				hit_enemies_pellet_count[enemy_key] = hit_enemies_pellet_count[enemy_key] + 1
				if not hit_headshots[enemy_key] then
					hit_headshots[enemy_key] = 0
				end
				hit_headshots[enemy_key] = hit_headshots[enemy_key] + 1
			-- if target hasn't been hit, add a pellet hit and prioritize this ray
			elseif not hit_enemies[enemy_key] then
				hit_enemies[enemy_key] = col_ray
				hit_enemies_pellet_count[enemy_key] = hit_enemies_pellet_count[enemy_key] + 1
			-- if target has been hit already, just add another pellet hit
			else
				hit_enemies_pellet_count[enemy_key] = hit_enemies_pellet_count[enemy_key] + 1
			end

			-- i don't know why it checks for head for this nor do i care to find out right now
			if not col_ray.unit:character_damage().is_head then
				self._bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
			end
		-- hit an object
		else
			local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_wall

			if add_shoot_through_bullet then
				hit_objects[col_ray.unit:key()] = hit_objects[col_ray.unit:key()] or {}

				table.insert(hit_objects[col_ray.unit:key()], col_ray)
			else
				self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			end
		end
	end

	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvector3.set(mvec_direction, direction)

	for i = 1, shoot_through_data and 1 or self._rays, 1 do

		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		if col_rays then
			if col_ray then
				table.insert(col_rays, col_ray)
			else
				local ray_to = mvector3.copy(mvec_to)
				local spread_direction = mvector3.copy(mvec_spread_direction)

				table.insert(col_rays, {
					position = ray_to,
					ray = spread_direction
				})
			end
		end
		if self._autoaim and autoaim then
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				hit_enemy(col_ray)

				autoaim = false
			else
				autoaim = false
				local autohit = self:check_autoaim(from_pos, direction, self._range)

				if autohit then
					local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

					if math.random() < autohit_chance then
						self._autohit_current = (self._autohit_current + weight) / (1 + weight)
						hit_something = true

						hit_enemy(autohit)
					else
						self._autohit_current = self._autohit_current / (1 + weight)
					end
				elseif col_ray then
					hit_something = true

					hit_enemy(col_ray)
				end
			end
		elseif col_ray then
			hit_something = true

			hit_enemy(col_ray)
		end
	end

	-- object-hitting shit
	for _, col_rays in pairs(hit_objects) do
		local center_ray = col_rays[1]

		if #col_rays > 1 then
			mvector3.set_static(mvec_temp, center_ray)

			for _, col_ray in ipairs(col_rays) do
				mvector3.add(mvec_temp, col_ray.position)
			end

			mvector3.divide(mvec_temp, #col_rays)

			local closest_dist_sq = mvector3.distance_sq(mvec_temp, center_ray.position)
			local dist_sq = nil

			for _, col_ray in ipairs(col_rays) do
				dist_sq = mvector3.distance_sq(mvec_temp, col_ray.position)

				if dist_sq < closest_dist_sq then
					closest_dist_sq = dist_sq
					center_ray = col_ray
				end
			end
		end

		ShotgunBase.super._fire_raycast(self, user_unit, from_pos, center_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
	end

	-- make non-saws break locks
	local lockbreak = nil
	if self._can_breach == true then
		lockbreak = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")
		if lockbreak and lockbreak.unit and lockbreak.unit:damage() and lockbreak.body:extension() and lockbreak.body:extension().damage then
			damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 2 * self._breach_power_mult, 0, 200)

			lockbreak.body:extension().damage:damage_lock(user_unit, lockbreak.normal, lockbreak.position, lockbreak.direction, damage)

			if lockbreak.unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", lockbreak.body, damage)
			end
		end
	end


	-- time to iterate through and hit enemies now
	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}

	for _, col_ray in pairs(hit_enemies) do
		local pellets_factor = 1
		local hit_distance = col_ray.distance
		-- if not a slug, adjust damage down
		if self._rays > 1 then
			if hit_visors[_] == true then
				pellets_factor = ((self._rays) + (hit_visors_pellet_count[_] * 5))/(self._rays * 6)
			else
				pellets_factor = ((self._rays) + (hit_enemies_pellet_count[_] * 5))/(self._rays * 6)
			end
			pellets_factor = pellets_factor + ((1 - pellets_factor) * managers.player:upgrade_value("player", "pellet_penalty_reduction", 0))
		end

		local damage = self:get_damage_falloff(damage, col_ray, user_unit) * pellets_factor

		if damage > 0 then
			local my_result = nil
			local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_enemy or self._can_shoot_through_wall
			my_result = add_shoot_through_bullet and ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data) or self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
			if my_result and my_result.type == "death" then
				managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)

				kill_data.kills = kill_data.kills + 1

				if col_ray.body and col_ray.body:name() == Idstring("head") then
					kill_data.headshots = kill_data.headshots + 1
				end

				if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
					kill_data.civilian_kills = kill_data.civilian_kills + 1
				end
			end
		end
	end

	if dodge_enemies and self._suppression then
		for enemy_data, dis_error in pairs(dodge_enemies) do
			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
		end
	end

--[[
	if not result then
		local result = {hit_enemy = next(hit_enemies) and true or false}

		if self._alert_events then
			result.rays = #col_rays > 0 and col_rays
		end
	end
--]]
-- this is incidentally why DMCWO's shit works and mine crashed the game for the longest time
-- result = {}
	if not result then
		result = {}
		result.hit_enemy = next(hit_enemies) and true or false
		if self._alert_events then
			result.rays = #col_rays > 0 and col_rays
		end
	end

	if not shoot_through_data then
		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = self._unit
		})
	end

	for _, d in pairs(hit_enemies) do
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	for key, data in pairs(tweak_data.achievement.shotgun_single_shot_kills) do
		if data.headshot and data.count <= kill_data.headshots - kill_data.civilian_kills or data.count <= kill_data.kills - kill_data.civilian_kills then
			local should_award = true
			if data.blueprint then
				local missing_parts = false
				for _, part_or_parts in ipairs(data.blueprint) do
					if type(part_or_parts) == "string" then
						if not table.contains(self._blueprint or {}, part_or_parts) then
							missing_parts = true

							break
						end
					else
						local found_part = false

						for _, part in ipairs(part_or_parts) do
							if table.contains(self._blueprint or {}, part) then
								found_part = true

								break
							end
						end
						if not found_part then
							missing_parts = true

							break
						end
					end
				end
				if missing_parts then
					should_award = false
				end
			end
			if should_award then
				managers.achievment:_award_achievement(data, key)
			end
		end
	end

	return result
end











-- trying to implement burst on shotguns
	local _update_stats_values_original = ShotgunBase._update_stats_values
	local fire_rate_multiplier_original = ShotgunBase.fire_rate_multiplier
	local recoil_multiplier_original = ShotgunBase.recoil_multiplier
	local on_enabled_original = ShotgunBase.on_enabled
	local on_disabled_original = ShotgunBase.on_disabled
	local start_reload_original = ShotgunBase.start_reload
	local fire_original = ShotgunBase.fire
	local fire_original2 = ShotgunBase.fire2
	local toggle_firemode_original = ShotgunBase.toggle_firemode
	
	ShotgunBase.DEFAULT_BURST_SIZE = 3
	ShotgunBase.IDSTRING_SINGLE = Idstring("single")
	ShotgunBase.IDSTRING_AUTO = Idstring("auto")
	
	function ShotgunBase:_update_stats_values(...)
		_update_stats_values_original(self, ...)
		
		if not self:is_npc() then
			self._burst_rounds_remaining = 0
			self._has_auto = not self._locked_fire_mode and (self:can_toggle_firemode() or self:weapon_tweak_data().FIRE_MODE == "auto")
			self._has_burst_fire = (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false
			--self._has_burst_fire = (not self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) or (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false
			--self._locked_fire_mode = self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) and Idstring("burst")
			self._burst_size = self:weapon_tweak_data().BURST_FIRE or ShotgunBase.DEFAULT_BURST_SIZE
			self._adaptive_burst_size = self:weapon_tweak_data().ADAPTIVE_BURST_SIZE ~= false
			self._burst_fire_rate_multiplier = self:weapon_tweak_data().BURST_FIRE_RATE_MULTIPLIER or 1
			self._delayed_burst_recoil = self:weapon_tweak_data().DELAYED_BURST_RECOIL
			
			self._burst_rounds_fired = 0

			local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
			for part_id, stats in pairs(custom_stats) do
				if stats.has_burst_fire then
					self._has_burst_fire = stats.has_burst_fire
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
				if stats.delayed_burst_recoil then
					self._delayed_burst_recoil = stats.delayed_burst_recoil
				end
			end

		end
	end
	
	function ShotgunBase:fire_rate_multiplier(...)
		local mult = 1
		if managers.player:current_state() == "bipod" then
			mult = mult * (self._bipod_rof_mult or 1)
		end

		mult = mult * self._inf_rof_mult

		if self:in_burst_mode() then --and (self._burst_rounds_fired <= self._burst_fire_rate_multiplier_shots) then
			local table_mult = 1
			-- read from table
			if self._burst_fire_rate_table then
				table_mult = self._burst_fire_rate_table[math.clamp(self._last_burst_rounds_fired, 1, #self._burst_fire_rate_table)]
			end
			mult = mult * table_mult * (self._burst_fire_rate_multiplier or 1)
		end
		if self._is_dp12 and self._dp12_needs_pump == false then
			mult = mult * self._dp12_no_pump_rof_mult or 5
		end
	
		return fire_rate_multiplier_original(self, ...) * mult
	end

--[[
	function ShotgunBase:recoil_multiplier(...)
		local multiplier = 1

		for _, category in ipairs(self:weapon_tweak_data().categories) do
			multiplier = multiplier * managers.player:upgrade_value(category, "recoil_multiplier", 1)

			if managers.player:has_team_category_upgrade(category, "recoil_multiplier") then
				multiplier = multiplier * managers.player:team_upgrade_value(category, "recoil_multiplier", 1)
			elseif managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
				multiplier = multiplier * managers.player:team_upgrade_value(category, "suppression_recoil_multiplier", 1)
			end
		end

		multiplier = multiplier * managers.player:upgrade_value(self._name_id, "recoil_multiplier", 1)

		local mult = 1
		if self._delayed_burst_recoil and self:in_burst_mode() and self:burst_rounds_remaining() then
			mult = 0
		end
		
		return multiplier * mult
	end
--]]
	
	function ShotgunBase:on_enabled(...)
		self:cancel_burst()
		return on_enabled_original(self, ...)
	end
	
	function ShotgunBase:on_disabled(...)
		self:cancel_burst()
		return on_disabled_original(self, ...)
	end
	
	function ShotgunBase:start_reload(...)
		self:cancel_burst()
		return start_reload_original(self, ...)
	end
	
	function ShotgunBase:fire(...)
		local result = fire_original2(self, ...)
		
		if result and not self.AKIMBO and self:in_burst_mode() then
			if self:clip_empty() then
				self._last_burst_rounds_fired = self._last_burst_rounds_fired + 1
				self:cancel_burst()
			else
				self._burst_rounds_fired = self._burst_rounds_fired + 1
				self._last_burst_rounds_fired = self._burst_rounds_fired
				self._burst_rounds_remaining = (self._burst_rounds_remaining <= 0 and self._burst_size or self._burst_rounds_remaining) - 1
-- moved end-burst to recoil mult so widowmaker doesn't zero out _burst_rounds_fired before the second shot determines which burst recoil table index it needs to read
--
				if self._burst_rounds_remaining <= 0 then
					self:cancel_burst()
				end
--
			end
		end
		
		return result
	end
	
	--Semi-override
	function ShotgunBase:toggle_firemode(...)
		return self._has_burst_fire and --[[not self._locked_fire_mode and--]] not self:gadget_overrides_weapon_functions() and self:_check_toggle_burst() or toggle_firemode_original(self, ...)
	end
	
	
	
	function ShotgunBase:_check_toggle_burst()
		if self:in_burst_mode() then
			self:_set_burst_mode(false, self.AKIMBO and not self._has_auto)
			return true
		elseif ((self._fire_mode == ShotgunBase.IDSTRING_SINGLE) or (self._fire_mode == ShotgunBase.IDSTRING_AUTO and not self:can_toggle_firemode())) and not self._has_burst_fire == false then
			self:_set_burst_mode(true, self.AKIMBO)
			return true
		end
	end

	function ShotgunBase:_set_burst_mode(status, skip_sound)
		self._in_burst_mode = status
		self._fire_mode = ShotgunBase["IDSTRING_" .. (status and "SINGLE" or self._has_auto and "AUTO" or "SINGLE")]
		
		if not skip_sound then
			self._sound_fire:post_event(status and "wp_auto_switch_on" or self._has_auto and "wp_auto_switch_on" or "wp_auto_switch_off")
		end
		
		self:cancel_burst()
	end
	
	function ShotgunBase:can_use_burst_mode()
		return self._has_burst_fire
	end
	
	function ShotgunBase:in_burst_mode()
		return self._fire_mode == ShotgunBase.IDSTRING_SINGLE and self._in_burst_mode and not self:gadget_overrides_weapon_functions()
	end
	
	function ShotgunBase:burst_rounds_remaining()
		return self._burst_rounds_remaining > 0 and self._burst_rounds_remaining or false
	end
	
	function ShotgunBase:cancel_burst(soft_cancel)
		if self._adaptive_burst_size or not soft_cancel then
			self._burst_rounds_remaining = 0
			
			if self._delayed_burst_recoil and self._burst_rounds_fired > 0 and not self._burst_canceling_from_zero_shots then
				self._setup.user_unit:movement():current_state():force_recoil_kick(self, self._burst_rounds_fired)
			end
			self._burst_rounds_fired = 0
			self._burst_canceling_from_zero_shots = nil
		end
	end
local mvec_spread_direction = Vector3()
local mvec_to = Vector3()


--[[
-- Unless this weapon should follow standard logic...
function RaycastWeaponBase:_soundfix_should_play_normal()
	local name_id = self:get_name_id()
	--conditions for firesounds to play in normal method:
	--1.lacking a singlefire sound
	--2.currently in gadget override such as underbarrel mode
	--3.minigun and mg42 will have a silent fire sound if not blacklisted
	--4. is NPC. Not sure why this started crashing now though, since that was fixed in v1 of AFSF2

	--Using the saiga is a special case for unique auto-fire method using looped "start_shooting" sound function
	if not self._setup.user_unit == managers.player:player_unit() or (tweak_data.weapon[name_id].sounds.fire_single == nil and not (name_id == "saiga" or name_id == "basset")) or self:gadget_overrides_weapon_functions() or name_id == "flamethrower_mk2" or name_id == "m134" or name_id == "mg42" or name_id == "saw" or name_id == "saw_secondary" or tweak_data.weapon[name_id].no_sound_fix == true then
		return true
	end
	return false
end


-- ...don't play a sound conventionally...
local original_fire_sound = RaycastWeaponBase._fire_sound
function RaycastWeaponBase:_fire_sound()
	if self:_soundfix_should_play_normal() then
		original_fire_sound(self)
	end
end

-- ...and instead play the single fire noise here
local original_fire = RaycastWeaponBase.fire
function RaycastWeaponBase:fire(...)
	local result = original_fire(self, ...)
	if not self:_soundfix_should_play_normal() and result then
		self:play_tweak_data_sound("fire_single", "fire")
	end

	-- af2011
	if self._double_fire then
		original_fire(self, ...)
	end
 
	return result
end



--overkill's next_fire_allowed calculations cause duplicated fire noises for autofire-capable shotguns like the saiga and the grimm (basset)
--so we bypass it, sort of
function RaycastWeaponBase:start_shooting()
	if self:_soundfix_should_play_normal() then 
		self:_fire_sound() --so fixed weapons don't play the fire sound here
	end
	self._next_fire_allowed = math.max(self._next_fire_allowed, self._unit:timer():time())
	self._shooting = true
end


function RaycastWeaponBase:trigger_pressed(...)
	local fired = nil

	if self:start_shooting_allowed() then
		fired = self:fire(...)

		if fired then
			if not self:_soundfix_should_play_normal() then
--				log("AFSF: firing weapon " .. tostring(self:get_name_id()))
				self:_fire_sound() -- play looping fire sound here instead of in RaycastWeaponBase:start_shooting()
			end
			self:update_next_shooting_time()
		end
	end

	return fired
end

function RaycastWeaponBase:trigger_held(...)
	local fired = nil

	if self:start_shooting_allowed() then
		fired = self:fire(...)
		if fired then
			self:update_next_shooting_time()
			if not self:_soundfix_should_play_normal() then 
				self:_fire_sound() --play looping fire sound here instead of in RaycastWeaponBase:start_shooting()
			end
		end
	elseif not self:_soundfix_should_play_normal() then
		local name_id = self:get_name_id()
		if name_id ~= "g36" then -- InF addition: g36 sound is better without this
			self:play_tweak_data_sound("stop_fire") --don't play another sound if you're not actually FIRING. Note: This plays the fade-out sound instead of just stopping sounds. You may notice the difference.
		end
	end

	return fired
end
--]]

-- Disable autoaim
-- Note: uncommenting this will also glitch out the game's accuracy stat counter, making it always 0% or always 100%.
-- Note 2: this isn't even necessary because InF already handles the lack of autoaim
--[[
Hooks:PostHook(RaycastWeaponBase, "setup", "inf_removeautoaim", function(self, setup_data, damage_multiplier)
	self._autoaim = false
end)
]]

-- don't ignore shields
function FlameBulletBase:bullet_slotmask()
	return managers.slot:get_mask("bullet_impact_targets")
end

Hooks:PreHook(FlameBulletBase, "on_collision", "bumpovershieldsplz", function(self, col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())
	-- values set in raycastweaponbase
	local MIN_KNOCK_BACK = 200 
	local KNOCK_BACK_CHANCE = 0.8

	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
				local damage_info = {
					damage = 0,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
		end
	end

-- the real effects just magically manifest on the wall behind them anyways
-- and they don't even play consistently seriously wtf
--[[
	managers.game_play_central:play_impact_flesh({
		no_sound = true,
		col_ray = col_ray
	})
	self:play_impact_sound_and_effects(weapon_unit, col_ray)
--]]
end)

-- Autofire soundfix
-- Now updated for U200
-- First, a weapon blacklist that it should still play the original sounds for
local autofirefix_blacklist = {
	["saw"] = true,
	["saw_secondary"] = true,
	["flamethrower_mk2"] = true,
	["m134"] = true,
	["mg42"] = true,
	["shuno"] = true,
	["system"] = true,
	["xm214a"] = true
}

-- Check if the normal fire sound should be played
-- i.e. if the player is using a minigun or if this weapon isn't used by the local player
function RaycastWeaponBase:_soundfix_should_play_normal()
	local name_id = self:get_name_id()
	if not name_id then
		return true
	end

	if not self._setup.user_unit == managers.player:player_unit() then
		return true
	elseif autofirefix_blacklist[name_id] then
		return true
	elseif not tweak_data.weapon[name_id].sounds.fire_single then
		return true
	end
	
	return false
end

function RaycastWeaponBase:start_shooting()
	if self:_soundfix_should_play_normal() then
		self:_fire_sound()
	end

	self._next_fire_allowed = math.max(self._next_fire_allowed, self._unit:timer():time())
	self._shooting = true
	self._bullets_fired = 0
end

function RaycastWeaponBase:stop_shooting()
	if self:_soundfix_should_play_normal() then
		self:play_tweak_data_sound("stop_fire")
	end

	self._shooting = nil
	self._kills_without_releasing_trigger = nil
	self._bullets_fired = nil
end

-- I really don't like this, but we have to override the whole raycastweaponbase fire function to make bulletstorm still consume the mag but not the max ammo
-- It's a gun rebalance anyway so whatever
function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		managers.player:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if managers.player:has_category_upgrade("temporary", "no_ammo_cost") then
			managers.player:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end

	if self._bullets_fired then
		if self._bullets_fired == 1 and self:weapon_tweak_data().sounds.fire_single and self:_soundfix_should_play_normal() then
			self:play_tweak_data_sound("stop_fire")
			self:play_tweak_data_sound("fire_auto", "fire")
		end

		self._bullets_fired = self._bullets_fired + 1
	end

	local is_player = self._setup.user_unit == managers.player:player_unit()
	-- Added InF bulletstorm check
	local consume_ammo = not IreNFist.bulletstorm_active and not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player

	-- Always consume mag ammo, the consume_ammo check was moved down
	--if consume_ammo and (is_player or Network:is_server()) then
	if is_player or Network:is_server() then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local ammo_usage = 1

		if is_player then
			for _, category in ipairs(self:weapon_tweak_data().categories) do
				if managers.player:has_category_upgrade(category, "consume_no_ammo_chance") then
					local roll = math.rand(1)
					local chance = managers.player:upgrade_value(category, "consume_no_ammo_chance", 0)

					if roll < chance then
						ammo_usage = 0
					end
				end
			end
		end

		local mag = base:get_ammo_remaining_in_clip()
		local remaining_ammo = mag - ammo_usage

		if mag > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			local w_td = self:weapon_tweak_data()

			if w_td.animations and w_td.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if w_td.sounds and w_td.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if w_td.effects and w_td.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
			end

			self:set_magazine_empty(true)
		end

		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() - ammo_usage)

		-- consume_ammo check moved down here to ensure that the mag is used up, but the max ammo isn't
		-- No bulletstorm RPG spam or magical 120 bullets Deagle magazines for you
		if consume_ammo then
			self:use_ammo(base, ammo_usage)
		end
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	if ray_res and ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end

	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	-- Play a fire sound if ray_res is successful and we are the local player
	if ray_res and self._setup.user_unit == managers.player:player_unit() and not self:_soundfix_should_play_normal() then
		self:play_tweak_data_sound("fire_single", "fire")
		self:play_tweak_data_sound("stop_fire")
	end

	return ray_res
end

-- fire, but twice
local original_fire = RaycastWeaponBase.fire
function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = original_fire(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	-- af2011/hx25
	if self._instant_multishot and self._instant_multishot > 1 then
		local instant_multishot_dmg_mul = self._instant_multishot_dmg_mul or 1
		for i = 2, self._instant_multishot, 1 do
			original_fire(self, from_pos, direction, dmg_mul * instant_multishot_dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
		end
	elseif self._instant_multishot_per_1ammo and self._instant_multishot_per_1ammo > 1 then
		local instant_multishot_dmg_mul = self._instant_multishot_dmg_mul or 1
		local user_unit = self._setup.user_unit
		for i = 2, self._instant_multishot_per_1ammo, 1 do
			--self:fire_use_no_ammo(self, ...)

			--self:_check_ammo_total(user_unit)

--[[
			if alive(self._obj_fire) then
				self:_spawn_muzzle_effect(from_pos, direction)
			end

			self:_spawn_shell_eject_effect()
--]]

			local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul * instant_multishot_dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

			if self._alert_events and ray_res.rays then
				self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
			end

			if ray_res.enemies_in_cone then
				for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
					if not enemy_data.unit:movement():cool() then
						enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
					end
				end
			end

			managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)
		end
	end
 
	return result
end

function RaycastWeaponBase:fire_use_no_ammo(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local user_unit = self._setup.user_unit

	--self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	if ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end

	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end



-- reimplements reduced damage on shield/wall penetrations
function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end

	local result = {}
	local spread_x, spread_y = self:_get_spread(user_unit)
	local ray_distance = self:weapon_range()
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()
	local theta = math.random() * 360
	local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
	local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

	mvector3.set(mvec_spread_direction, direction)
	mvector3.add(mvec_spread_direction, right * math.rad(ax))
	mvector3.add(mvec_spread_direction, up * math.rad(ay))
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
	local hit_anyone = false
	local auto_hit_candidate, suppression_enemies = self:check_autoaim(from_pos, direction)

	if suppression_enemies and self._suppression then
		result.enemies_in_cone = suppression_enemies
	end

	if self._autoaim then
		local weight = 0.1

		if auto_hit_candidate and not hit_enemy then
			local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

			if autohit_mul then
				autohit_chance = autohit_chance * autohit_mul
			end

			if math.random() < autohit_chance then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				mvector3.set(mvec_to, from_pos)
				mvector3.add_scaled(mvec_to, auto_hit_candidate.ray, ray_distance)

				ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
			end
		end

		if hit_enemy then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
		elseif auto_hit_candidate then
			self._autohit_current = self._autohit_current / (1 + weight)
		end
	end

--[[
	-- make non-saws break locks
	local lockbreak = nil
	-- add check for breacher ammo type here
	if self._can_breach == true then
		log("BREACHING")
		lockbreak = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")
		if lockbreak.unit:damage() and lockbreak.body:extension() and lockbreak.body:extension().damage then
			damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

			lockbreak.body:extension().damage:damage_lock(user_unit, lockbreak.normal, lockbreak.position, lockbreak.direction, damage)

			if lockbreak.unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", lockbreak.body, damage)
			end
		end
	end
--]]


	local hit_count = 0
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
	local hit_result = nil

	for _, hit in ipairs(ray_hits) do
		damage = self:get_damage_falloff(damage, hit, user_unit)
		-- need to apply damage reductions before the hit
		if hit.unit:in_slot(managers.slot:get_mask("world_geometry")) then
			hit_through_wall = true
			-- wall penetrations
			damage = damage * self._pen_wall_dmg_mult
		elseif hit.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
			hit_through_shield = hit_through_shield or alive(hit.unit:parent())
			-- shield penetrations
			damage = damage * self._pen_shield_dmg_mult
		end

		hit_result = self._bullet_class:on_collision(hit, self._unit, user_unit, damage)

		if hit_result and hit_result.type == "death" then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local is_civilian = unit_type and CopDamage.is_civilian(unit_type)

			if not is_civilian then
				cop_kill_count = cop_kill_count + 1
			end

			if self:is_category(tweak_data.achievement.easy_as_breathing.weapon_type) and not is_civilian then
				self._kills_without_releasing_trigger = (self._kills_without_releasing_trigger or 0) + 1

				if tweak_data.achievement.easy_as_breathing.count <= self._kills_without_releasing_trigger then
					managers.achievment:award(tweak_data.achievement.easy_as_breathing.award)
				end
			end
		end

		if hit_result then
			hit.damage_result = hit_result
			hit_anyone = true
			hit_count = hit_count + 1
		end

		if hit_result and hit_result.type == "death" and cop_kill_count > 0 then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local multi_kill, enemy_pass, obstacle_pass, weapon_pass, weapons_pass, weapon_type_pass = nil

			for achievement, achievement_data in pairs(tweak_data.achievement.sniper_kill_achievements) do
				multi_kill = not achievement_data.multi_kill or cop_kill_count == achievement_data.multi_kill
				enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
				obstacle_pass = not achievement_data.obstacle or achievement_data.obstacle == "wall" and hit_through_wall or achievement_data.obstacle == "shield" and hit_through_shield
				weapon_pass = not achievement_data.weapon or self._name_id == achievement_data.weapon
				weapons_pass = not achievement_data.weapons or table.contains(achievement_data.weapons, self._name_id)
				weapon_type_pass = not achievement_data.weapon_type or self:is_category(achievement_data.weapon_type)

				if multi_kill and enemy_pass and obstacle_pass and weapon_pass and weapons_pass and weapon_type_pass then
					if achievement_data.stat then
						managers.achievment:award_progress(achievement_data.stat)
					elseif achievement_data.award then
						managers.achievment:award(achievement_data.award)
					elseif achievement_data.challenge_stat then
						managers.challenge:award_progress(achievement_data.challenge_stat)
					elseif achievement_data.trophy_stat then
						managers.custom_safehouse:award(achievement_data.trophy_stat)
					elseif achievement_data.challenge_award then
						managers.challenge:award(achievement_data.challenge_award)
					end
				end
			end
		end
	end

	if not tweak_data.achievement.tango_4.difficulty or table.contains(tweak_data.achievement.tango_4.difficulty, Global.game_settings.difficulty) then
		if self._gadgets and table.contains(self._gadgets, "wpn_fps_upg_o_45rds") and cop_kill_count > 0 and managers.player:player_unit():movement():current_state():in_steelsight() then
			if self._tango_4_data then
				if self._gadget_on == self._tango_4_data.last_gadget_state then
					self._tango_4_data = nil
				else
					self._tango_4_data.last_gadget_state = self._gadget_on
					self._tango_4_data.count = self._tango_4_data.count + 1
				end

				if self._tango_4_data and tweak_data.achievement.tango_4.count <= self._tango_4_data.count then
					managers.achievment:_award_achievement(tweak_data.achievement.tango_4, "tango_4")
				end
			else
				self._tango_4_data = {
					count = 1,
					last_gadget_state = self._gadget_on
				}
			end
		elseif self._tango_4_data then
			self._tango_4_data = nil
		end
	end

	result.hit_enemy = hit_anyone

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if (not self._ammo_data or not self._ammo_data.ignore_statistic) and not self._rays then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	local furthest_hit = ray_hits[#ray_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mvec_spread_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		end
	end

	if self._alert_events then
		result.rays = ray_hits
	end

	if result == nil then
		log("CRY A LOT")
	end

	return result
end

local function print_vector3(vector)
	log(vector.x .. " " .. vector.y .. " " .. vector.z)
end

-- base pen distance for snipers, anyways
local base_penetration_distance = 100
function RaycastWeaponBase:_collect_hits(from, to)
--log("--------------------------------")
	local can_shoot_through = self._can_shoot_through_wall or self._can_shoot_through_shield or self._can_shoot_through_enemy
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	local ray_dir = nil
	local last_wall_hit = nil
	local last_wall_hit_position = nil
	local wall_thickness = 0
	local pen_penalty = 0

	for i, hit in ipairs(ray_hits) do
--log("--")
--log(i)
		if hit.unit:in_slot(wall_mask) and not last_wall_hit and not (#ray_hits == 1) then
			-- bullet enters a wall
			last_wall_hit = i
			last_wall_hit_position = hit.position
			if not ray_dir then
				ray_dir = hit.ray
			end
--log("setting wall hit")
		elseif last_wall_hit then
--log("performing backtrace")
			-- check distance between wall entry point and wall exit point
			-- backtrace from impact point to bullet wall entry point to get bullet wall exit point
			-- shots that penetrate and end at the skybox don't backtrace but that's fine since you hit the fucking skybox anyways
			local distvector = mvector3.copy(last_wall_hit_position)
			--local backtrace = Utils:GetCrosshairRay(hit.position, last_wall_hit_position, self._bullet_slotmask)

			local target_position = hit.position

			if hit.unit:in_slot(enemy_mask) then
				target_position = hit.unit:position()
			end
			-- sometimes 
			local backtrace = World:raycast_all("ray", target_position, last_wall_hit_position, "slot_mask", managers.slot:get_mask("world_geometry"), "ignore_unit", self._setup.ignore_units) -- slotmask wasn't working with getcrosshairray
			if backtrace and backtrace[1] then
				mvector3.subtract(distvector, target_position)
				wall_thickness = mvector3.length(distvector) - backtrace[1].distance
				--log("dist: " .. mvector3.length(distvector) .. " - " .. backtrace[1].distance)
				--log((wall_thickness + pen_penalty) .. " vs " .. (base_penetration_distance * self._pen_wall_dist_mult))
				if (wall_thickness + pen_penalty) > (base_penetration_distance * self._pen_wall_dist_mult) then
					-- 2THICC
					--log("NO PENETRATION")
					break
				end
				pen_penalty = pen_penalty + wall_thickness
			end
			last_wall_hit = nil
		end

		-- multiple penetration leftovers
		-- i'm fucking sick of just making penetration damage work right
--[[
		if hit.unit:in_slot(wall_mask) and last_wall_hit then
			if #ray_hits == i and hit then
				log("attempting to add new ray")
				local new_ray_vector = mvector3.copy(hit.position)
				mvector3.multiply(ray_dir, 10000)
				mvector3.add(new_ray_vector, ray_dir)
				local new_ray = Utils:GetCrosshairRay(hit.position, last_wall_hit_position)
				if new_ray then
					table.insert(ray_hits, i+1, new_ray)
				end
				mvector3.set(last_wall_hit_position, hit.position)
			end
		end
--]]

		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			-- could add penetration penalty here but too lazy
			if not self._can_shoot_through_enemy and hit_enemy then
				break
			elseif not self._can_shoot_through_wall and hit.unit:in_slot(wall_mask) and weak_body then
				break
			elseif not self._can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	return unique_hits, hit_enemy
end


-- ONE-IN-THE-CHAMBER SHIT
local clipFullOrig = RaycastWeaponBase.clip_full
function RaycastWeaponBase:clip_full()

	if _G.IS_VR then
		return clipFullOrig(self)
	end

	-- check if underbarrel attachment
	local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("underbarrel", self._factory_id, self._blueprint)
	for i, id in ipairs(gadgets) do
		gadget = self._parts[id]
		--log(id)
		if gadget then
			local gadget_base = gadget.unit and gadget.unit:base() or gadget.base and gadget:base()
			if gadget_base and gadget_base:is_on() and gadget_base:overrides_weapon_firing() then
				-- underbarrel uses different one-in-the-chamber check
				return self:ammo_base():get_ammo_remaining_in_clip() == self:ammo_base():get_ammo_max_per_clip() + (tweak_data.weapon.factory.parts[id].chamber or 0)
			end
		end
	end

	return self:ammo_base():get_ammo_remaining_in_clip() == self:ammo_base():get_ammo_max_per_clip() + (self._chamber or 0)
end

local onReloadOrig = RaycastWeaponBase.on_reload
function RaycastWeaponBase:on_reload(amount, emptyreload, taser_reload_amount)

	if _G.IS_VR then
		return onReloadOrig(self, amount, emptyreload, taser_reload_amount)
	end

	local ammo_base = self._reload_ammo_base or self:ammo_base()
	amount = amount or ammo_base:get_ammo_max_per_clip()
	local fromempty = false
	if emptyreload == true then
		fromempty = true
	end
	local tased_amount = 9999
	if taser_reload_amount then
		tased_amount = math.max(ammo_base:get_ammo_remaining_in_clip(), taser_reload_amount)
	end


	if self._setup.expend_ammo then
		local chamber_reload = 0
		-- if is not empty reload, add chamber mechanics
		if ammo_base:get_ammo_remaining_in_clip() ~= 0 and fromempty == false then -- account for half-loading from empty
			chamber_reload = (self._chamber or 0)
			if tweak_data.weapon[self._name_id].abakanload and ammo_base:get_ammo_remaining_in_clip() < (self._chamber or 0) then
				chamber_reload = ammo_base:get_ammo_remaining_in_clip()
			end
		end
		-- if clip-loader, add clip amount
		-- otherwise, load to full + chamber
		if tweak_data.weapon[self._name_id].clipload then
			--ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_total(), math.min(amount + chamber_reload, ammo_base:get_ammo_remaining_in_clip() + tweak_data.weapon[self._name_id].clipload)))
			ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_total(), amount + chamber_reload, ammo_base:get_ammo_remaining_in_clip() + tweak_data.weapon[self._name_id].clipload, tased_amount))
		else
			ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_total(), amount + chamber_reload, tased_amount))
		end
	else
		-- haven't bothered to look up what this is for yet
		ammo_base:set_ammo_remaining_in_clip(amount)
		ammo_base:set_ammo_total(amount)
	end

	managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

	self._reload_ammo_base = nil
end

-- reloads half of the mag
function RaycastWeaponBase:on_reload_half(amount)
	local ammo_base = self._reload_ammo_base or self:ammo_base()
	amount = amount or ammo_base:get_ammo_max_per_clip()

	if self._setup.expend_ammo then
		local chamber_reload = 0
		-- if is not empty reload, add chamber mechanics
		if ammo_base:get_ammo_remaining_in_clip() ~= 0 then
			chamber_reload = (self._chamber or 0)
		end
		-- if clip-loader, add clip amount
		-- otherwise, load to full + chamber
		local fullreload = nil
		if tweak_data.weapon[self._name_id].clipload then
			--ammo_base:set_ammo_remaining_in_clip(math.floor(math.min(ammo_base:get_ammo_total(), amount + chamber_reload/2, ammo_base:get_ammo_remaining_in_clip() + tweak_data.weapon[self._name_id].clipload + chamber_reload/2)))
			ammo_base:set_ammo_remaining_in_clip(math.floor(math.min(ammo_base:get_ammo_total(), amount + chamber_reload/2, ammo_base:get_ammo_remaining_in_clip() + tweak_data.weapon[self._name_id].clipload + chamber_reload/2, amount - ((amount - ammo_base:get_ammo_remaining_in_clip())/2) )))
		else
			ammo_base:set_ammo_remaining_in_clip(math.floor(math.min(ammo_base:get_ammo_total(), ammo_base:get_ammo_remaining_in_clip()/2 + amount/2 + chamber_reload/2)))
		end
	else
		-- haven't bothered to figure out what this is for yet
		ammo_base:set_ammo_remaining_in_clip(amount)
		ammo_base:set_ammo_total(amount)
	end

	managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

	self._reload_ammo_base = nil
end






-- holdover from looking at DMCWO code
-- tactical reloading seems to work without this?

function RaycastWeaponBase:reload_expire_t()
	if self._use_shotgun_reload then
		local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()

		if self:get_ammo_remaining_in_clip() > 0 and self._chamber then
			return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() - ammo_remaining_in_clip + self._chamber) * self:reload_shell_expire_t()
		else
			return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() - ammo_remaining_in_clip) * self:reload_shell_expire_t()
		end
	end

	return nil
end


-- ammo pickup
function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier_min = 1
		local multiplier_max = 1

		-- ammo mults no longer override bonuses
		multiplier_min = multiplier_min * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
		multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
			multiplier_min = multiplier_min * ammo_base._ammo_data.ammo_pickup_min_mul
		end

		multiplier_max = multiplier_max * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
		multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
			multiplier_max = multiplier_max * ammo_base._ammo_data.ammo_pickup_max_mul
		end

		local add_amount = add_amount_override
		local picked_up = true

		-- guaranteed accumulative pickups
		if not add_amount and ammo_base._ammo_pickup[1] == 1337 then
			ammo_base.accumulate_ammo = (ammo_base.accumulate_ammo or 0) + (ammo_base._ammo_pickup[2] * multiplier_max)
			if ammo_base.accumulate_ammo >= 100 then
				add_amount = 1
				ammo_base.accumulate_ammo = ammo_base.accumulate_ammo - 100
			else
				add_amount = 0
			end
		elseif not add_amount and ammo_base._ammo_pickup[1] == 1338 then
			ammo_base.accumulate_ammo = (ammo_base.accumulate_ammo or 0) + (ammo_base._ammo_pickup[2] * multiplier_max)
			if ammo_base.accumulate_ammo >= 100 then
				add_amount = 1
				ammo_base.accumulate_ammo = 0 -- resets to 0 instead of allowing rollover
			else
				add_amount = 0
			end
		elseif not add_amount then
			local rng_ammo = math.lerp(ammo_base._ammo_pickup[1] * multiplier_min, ammo_base._ammo_pickup[2] * multiplier_max, math.random())
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end

	local picked_up, add_amount = nil
	picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

	if self.AKIMBO then
		local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

		if akimbo_rounding > 0 then
			_add_ammo(self, nil, akimbo_rounding)
		end
	end

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
			picked_up = p or picked_up
			add_amount = add_amount + a
		end
	end

	return picked_up, add_amount
end



-- allow applying bullet and fire damage on explosive hit
Hooks:PreHook(InstantExplosiveBulletBase, "on_collision", "inf_facetank", function(self, col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit

	local bullet_damage_fraction = 0.5
	if weapon_unit.base and weapon_unit:base() and weapon_unit:base()._bullet_damage_fraction then
		bullet_damage_fraction = weapon_unit:base()._bullet_damage_fraction
	end

	-- visor mult
	local visor_mult = 1
	if col_ray.body and (col_ray.body:name() == Idstring("body_helmet_plate") or col_ray.body:name() == Idstring("body_helmet_glass")) then
		if weapon_unit.base and weapon_unit:base() and weapon_unit:base()._visor_dmg_mult then
			visor_mult = weapon_unit:base() and weapon_unit:base()._visor_dmg_mult
		end
	end

	-- apply fire damage
	local has_fire_dot = alive(weapon_unit) and weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.fire_dot_data
	if has_fire_dot and hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		local result = self:give_fire_damage(col_ray, weapon_unit, user_unit, 0)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	-- apply bullet damage
	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		local result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage * bullet_damage_fraction * visor_mult, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	damage = damage * (1 - bullet_damage_fraction) * visor_mult
end)

--[[
local old_hefrag_collision = InstantExplosiveBulletBase.on_collision
function InstantExplosiveBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit

	local bullet_damage_fraction = 0.5
	if weapon_unit.base and weapon_unit:base() and weapon_unit:base()._bullet_damage_fraction then
		bullet_damage_fraction = weapon_unit:base()._bullet_damage_fraction
	end

	-- visor mult
	local visor_mult = 1
	if col_ray.body and (col_ray.body:name() == Idstring("body_helmet_plate") or col_ray.body:name() == Idstring("body_helmet_glass")) then
		if weapon_unit.base and weapon_unit:base() and weapon_unit:base()._visor_dmg_mult then
			visor_mult = weapon_unit:base() and weapon_unit:base()._visor_dmg_mult
		end
	end

	-- apply fire damage
	local has_fire_dot = alive(weapon_unit) and weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.fire_dot_data
	if has_fire_dot and hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		local result = self:give_fire_damage(col_ray, weapon_unit, user_unit, 0)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	-- apply bullet damage
	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		local result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage * bullet_damage_fraction * visor_mult, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	return old_hefrag_collision(self, col_ray, weapon_unit, user_unit, damage * (1 - bullet_damage_fraction) * visor_mult, blank)
end
--]]

function InstantExplosiveBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	local action_data = {
		variant = variant or "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end


function InstantExplosiveBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data then --
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

-- Bringing back Skill Overhaul features that are neat
-- If you are tased with Shockproof Ace, your bullets will tase cops hit by them
local instantbullet_give_impact_dmg_orig = InstantBulletBase.give_impact_damage
function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)

	-- This shouldn't do anything on bows and crossbows due to crashes
	if weapon_unit:base():is_category("bow") or weapon_unit:base():is_category("crossbow") then
		return instantbullet_give_impact_dmg_orig(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	end

	if managers.player:has_category_upgrade("player", "electric_bullets_while_tased") and user_unit == managers.player:player_unit() and managers.player:current_state() == "tased" then
		local hit_unit = col_ray.unit
		local action_data = {}
		action_data.weapon_unit = weapon_unit
		action_data.attacker_unit = user_unit
		action_data.col_ray = col_ray
		action_data.armor_piercing = armor_piercing
		action_data.attacker_unit = user_unit
		action_data.attack_dir = col_ray.ray
		
		action_data.variant = "taser_tased"
		action_data.damage = damage
		action_data.damage_effect = 1
		action_data.name_id = "taser"
		action_data.charge_lerp_value = 0	
		
		defense_data = hit_unit and hit_unit:character_damage().damage_tase and hit_unit:character_damage().damage_melee and hit_unit:character_damage():damage_melee(action_data)
		if defense_data and hit_unit and hit_unit:character_damage().damage_tase then
			action_data.damage = 0
			action_data.damage_effect = nil
			hit_unit:character_damage():damage_tase(action_data)
			return defense_data
		else
			return instantbullet_give_impact_dmg_orig(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
		end
	else
		return instantbullet_give_impact_dmg_orig(self, col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	end
end

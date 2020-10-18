dofile(ModPath .. "infcore.lua")

Hooks:PostHook(PlayerManager, "on_headshot_dealt", "sniperarmor", function(self, params)
	local player_unit = self:player_unit()
	if player_unit then
		local damage_ext = player_unit:character_damage()
		local regen_armor_bonus = managers.player:upgrade_value("player", "snp_headshot_armor", 0)

		local primary_is_sniper = Utils:IsCurrentPrimaryOfCategory("snp") and Utils:IsCurrentWeaponPrimary()
		local secondary_is_sniper = Utils:IsCurrentSecondaryOfCategory("snp") and Utils:IsCurrentWeaponSecondary()

		-- Utils:IsCurrentWeapon("snp") doesn't want to work i guess
		if damage_ext and regen_armor_bonus > 0 and (primary_is_sniper or secondary_is_sniper) then
			damage_ext:restore_armor(regen_armor_bonus)
		end
	end
end)

Hooks:PreHook(PlayerManager, "on_killshot", "stamonkill", function(self, killed_unit, variant, headshot, weapon_id)
	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	if self:get_current_state() and self:get_current_state():_is_doing_advanced_movement() then
		local value = managers.player:upgrade_value("player", "advmov_stamina_on_kill", 0)
		self:get_current_state()._unit:movement():_change_stamina(value)
	end
end)

-- Holdout perk deck, gives you dropped ammo pickups from enemies provided you stand still
-- And gives armor for distant kills
if InFmenu.settings.beta then	

	-- Copied function from playerstandard, find pickups around a dead cop's corpse
	local pickup_area = 50
	local function pickupPickupsAtDeadUnitPos(self, killed_unit_pos)
		local pickup_slotmask = managers.slot:get_mask("pickups")

		local pickups = World:find_units_quick("sphere", killed_unit_pos, pickup_area, pickup_slotmask)
		local grenade_tweak = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()]
		local may_find_grenade = not grenade_tweak.base_cooldown and self:has_category_upgrade("player", "regain_throwable_from_ammo")
	
		for _, pickup in ipairs(pickups) do
			if pickup:pickup() and pickup:pickup():pickup(self:player_unit()) then
				if may_find_grenade then
					local data = self:upgrade_value("player", "regain_throwable_from_ammo", nil)
	
					if data then
						self:add_coroutine("regain_throwable_from_ammo", PlayerAction.FullyLoaded, self, data.chance, data.chance_inc)
					end
				end
	
				for id, weapon in pairs(self:player_unit():inventory():available_selections()) do
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	end

	-- Holds killed units as a client, so we can check their positions for ammo later.
	local killed_units = {}
	local killed_ammo_wait_delay = 1

	local holdout_pos = nil
	local max_dist = 200
	local holdout_active = false
	local kills_made_in_zone = 0
	local last_health_regen_t = 0
	local last_armor_regen_t = 0

	local waypoint_data = {
		position = Vector3(0,0,0),
		icon = "pd2_defend",
		distance = true,
		no_sync = false,
		present_timer = 0,
		state = "present",
		radius = 50,
		color = Color(0.1, 1, 0.1),
		blend_mode = "add"
	}

	-- Executed when the player kills someone
	Hooks:PostHook(PlayerManager, "on_killshot", "stationary_kill_ammo", function(self, killed_unit, variant, headshot, weapon_id)
		local player_unit = self:player_unit()

		if not player_unit then
			return
		end

		if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
			return
		end

		-- Check for the perk deck
		if not self:has_category_upgrade("player", "holdout_consecutive_kills") then
			return
		end

		-- First kill outside of zone sets a new zone position
		local pos = player_unit:position()
		if not holdout_pos or mvector3.distance(pos, holdout_pos) > max_dist then
			holdout_pos = pos
			holdout_active = false
			kills_made_in_zone = 0
			self:update_holdout_waypoint()
			return
		end

		local required_kills_in_zone = self:upgrade_value("player", "holdout_killcount", 3)
		kills_made_in_zone = kills_made_in_zone + 1

		-- If the amount of kills made is at the threshold, then activate the zone
		if not holdout_active then
			if kills_made_in_zone >= required_kills_in_zone then
				holdout_active = true
			end
			return
		end

		-- From here on out, killing enemies will give you their dropped ammo box
		-- Sadly this function runs after the cop spawned the pickup, so the best way forward here is to simply have the player remotely vacuum the pickup

		-- Much like the Enforcer skill, spawn extra ammo at the feet of the killed enemy by piggybacking off of that skill.
		local consecutive_kills_required_for_ammo_bonus = self:upgrade_value("player", "holdout_consecutive_kill_ammo", 0)
		if consecutive_kills_required_for_ammo_bonus > 0 then
			-- Check if this is the nth kill
			if required_kills_in_zone % consecutive_kills_required_for_ammo_bonus == 0 then
				-- Award extra ammo
				log("[InF] Extra ammo awarded for nth kill in zone")
				if Network:is_client() then
					managers.network:session():send_to_host("sync_spawn_extra_ammo", killed_unit)
				else
					self:spawn_extra_ammo(killed_unit)
				end
			end
		end

		-- Vacuum up the enemy drops
		pickupPickupsAtDeadUnitPos(self, killed_unit:movement():m_pos())

		-- Clients don't see the extra ammo straight away.
		-- Schedule a delayed ammo pickup check for the client.
		if Network and Network:is_client() then
			killed_units[killed_unit:id()] = { unit_pos = killed_unit:movement():m_pos(), kill_t = Application:time() }
		end

		-- Check if we are past the cooldown for the health/armor restore
		local regen_cooldown = self:upgrade_value("player", "holdout_regen_cooldown", 5)
		local t = Application:time()

		-- Perform the health/armor restore
		local health_restore_amount = self:upgrade_value("player", "holdout_distant_kill_health_regen", 0)
		local armor_restore_amount = self:upgrade_value("player", "holdout_close_kill_armor_regen", 0)
		if health_restore_amount <= 0 or armor_restore_amount <= 0 then
			return
		end

		local damage_ext = player_unit:character_damage()
		if not damage_ext then
			return
		end

		local healthrestore_min_dist = tweak_data.upgrades.holdout_distant_kill_min_distance
		local armorrestore_max_dist = tweak_data.upgrades.holdout_close_kill_max_distance

		local distance_to_killed_unit = mvector3.distance(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
		if distance_to_killed_unit > healthrestore_min_dist and (t - last_health_regen_t > regen_cooldown) then
			-- Restore health
			damage_ext:restore_health(health_restore_amount, true)
			last_health_regen_t = Application:time()
		elseif distance_to_killed_unit <= armorrestore_max_dist and (t - last_armor_regen_t > regen_cooldown) then
			-- Restore armor
			damage_ext:restore_armor(armor_restore_amount)
			last_armor_regen_t = Application:time()
		end
	end)

	Hooks:PostHook(PlayerManager, "update", "inf_playermanager_update_updateholdouthudandammo", function(self, t, dt)
		local player_unit = self:player_unit()

		if not player_unit then
			-- Do nothing at all
			return
		end

		-- As client, check for ammo drops around earlier killed enemies
		if Network and Network:is_client() then
			for unit_id, data in pairs(killed_units) do
				if data.kill_t + killed_ammo_wait_delay > Application:time() then
					pickupPickupsAtDeadUnitPos(self, data.unit_pos)
					killed_units[unit_id] = nil
				end
			end
		end

		if not holdout_active or not holdout_pos then
			-- Set hud false
			managers.hud:set_holdout_indicator_enabled(false)
			return
		end

		local dist = mvector3.distance(player_unit:position(), holdout_pos)
		if dist <= max_dist then
			-- Set hud true
			managers.hud:set_holdout_indicator_enabled(true)
		else
			-- Set hud false
			managers.hud:set_holdout_indicator_enabled(false)
		end
	end)

	-- Update the Guardian waypoint marker
	function PlayerManager:update_holdout_waypoint()
		if not managers or not managers.hud then
			return
		end

		if InFmenu.settings.holdout_waypoint then
			if holdout_pos and holdout_active then
				waypoint_data.position = holdout_pos
				managers.hud:remove_waypoint("inf_guardian_waypoint")
				managers.hud:add_waypoint("inf_guardian_waypoint", waypoint_data)
			else
				managers.hud:remove_waypoint("inf_guardian_waypoint")
			end
		else
			managers.hud:remove_waypoint("inf_guardian_waypoint")
		end
	end

	-- Add Guardian damage reduction while in the zone
	local playerman_dmg_reduction_skill_mul_orig = PlayerManager.damage_reduction_skill_multiplier
	function PlayerManager:damage_reduction_skill_multiplier(...)
		local multiplier = playerman_dmg_reduction_skill_mul_orig(self, ...)

		local player_unit = self:player_unit()
		if not player_unit then
			return multiplier
		end

		local pos = self:player_unit():position()

		if pos and holdout_active and holdout_pos and mvector3.distance(pos, holdout_pos) <= max_dist then
			multiplier = multiplier * self:upgrade_value("player", "holdout_dmg_reduction", 1)
		end

		return multiplier
	end
end

local old_sdc = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(...)
	local chance = old_sdc(self, ...)
	if self:get_current_state() and self:get_current_state():_is_doing_advanced_movement() then
		chance = chance + self:get_current_state():_advanced_movement_dodge_bonus() --managers.player:upgrade_value("player", "slide_dodge_addend", 0)
	end
	return chance
end

-- Moving Target movement speed bonus
if not IreNFist.mod_compatibility.sso then
	local player_movement_speed_multiplier_orig = PlayerManager.movement_speed_multiplier
	function PlayerManager:movement_speed_multiplier(...)
		local multiplier = player_movement_speed_multiplier_orig(self, ...)
		
		if self:has_category_upgrade("player", "detection_risk_add_movement_speed") then
			--Apply Moving Target movement speed bonus (additively)
			multiplier = multiplier + self:detection_risk_movement_speed_bonus()
		end
		
		return multiplier
	end

	function PlayerManager:detection_risk_movement_speed_bonus()
		local added_speed = 0
		local detection_risk_add_movement_speed = managers.player:upgrade_value("player", "detection_risk_add_movement_speed")
		added_speed = added_speed + self:get_value_from_risk_upgrade(detection_risk_add_movement_speed)
		return added_speed
	end
end

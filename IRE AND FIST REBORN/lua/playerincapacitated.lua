dofile(ModPath .. "infcore.lua")

-- This file is identical to playerbleedout except it also extends to when you are totally down and cannot fire your gun

-- Allow converted civvies to revive you
-- Identical to the regular function, except this removes the "available for assignment" check from civilians
-- So that tied civilians can stand up and come revive you.
function PlayerIncapacitated:call_civilian(line, t, no_gesture, skip_alert, revive_SO_data)
	if not managers.player:has_category_upgrade("player", "civilian_reviver") or revive_SO_data and revive_SO_data.sympathy_civ then
		return
	end
	local detect_only = false
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action(false, true, false, false, false, 0, true, detect_only)
	if prime_target then
		if detect_only then
			if not prime_target.unit:sound():speaking(t) then
				prime_target.unit:sound():say("_a01x_any", true)
			end
		else
			if not prime_target.unit:sound():speaking(t) then
				prime_target.unit:sound():say("stockholm_syndrome", true)
			end
			local queue_name = line .. "e_plu"
			self:_do_action_intimidate(t, not no_gesture and "cmd_come" or nil, queue_name, skip_alert)
			if Network:is_server() then
				if prime_target.unit:brain():is_available_for_assignment({type = "revive"}) or true then
					-- Reason for the "or true" is that is_available_for_assignment seems to return a boolean, but it *also* has side-effects.
					local followup_objective = {
						type = "free",
						interrupt_dis = -1,
						interrupt_health = 1,
						action = {
							type = "idle",
							body_part = 1,
							sync = true
						}
					}
					local objective = {
						type = "act",
						haste = "run",
						destroy_clbk_key = false,
						nav_seg = self._unit:movement():nav_tracker():nav_segment(),
						pos = self._unit:movement():nav_tracker():field_position(),
						fail_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_failed", revive_SO_data),
						complete_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_completed", revive_SO_data),
						action_start_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_civ_revive_started", revive_SO_data),
						action = {
							type = "act",
							variant = "revive",
							body_part = 1,
							blocks = {
								action = -1,
								walk = -1,
								light_hurt = -1,
								hurt = -1,
								heavy_hurt = -1,
								aim = -1
							},
							align_sync = true
						},
						action_duration = tweak_data.interaction.revive.timer,
						followup_objective = followup_objective
					}
					revive_SO_data.sympathy_civ = prime_target.unit
					prime_target.unit:brain():set_objective(objective)
				end
			end
		end
	end
end

-- Copied from PlayerStandard, therefore overrides the bleedout intimidation action
-- Allows converted cops to come and help you up
function PlayerIncapacitated:_get_unit_intimidation_action(intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
	local char_table = {}
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local cam_fwd = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()

	if _G.IS_VR then
		local hand_unit = self._unit:hand():hand_unit(self._interact_hand)

		if hand_unit:raycast("ray", hand_unit:position(), my_head_pos, "slot_mask", 1) then
			return
		end

		cam_fwd = hand_unit:rotation():y()
		my_head_pos = hand_unit:position()
	end

	local spotting_mul = managers.player:upgrade_value("player", "marked_distance_mul", 1)
	local range_mul = managers.player:upgrade_value("player", "intimidate_range_mul", 1) * managers.player:upgrade_value("player", "passive_intimidate_range_mul", 1)
	local intimidate_range_civ = tweak_data.player.long_dis_interaction.intimidate_range_civilians * range_mul
	local intimidate_range_ene = tweak_data.player.long_dis_interaction.intimidate_range_enemies * range_mul
	local highlight_range = tweak_data.player.long_dis_interaction.highlight_range * range_mul * spotting_mul
	local intimidate_range_teammates = tweak_data.player.long_dis_interaction.intimidate_range_teammates

	if intimidate_enemies then
		local enemies = managers.enemy:all_enemies()

		for u_key, u_data in pairs(enemies) do
			if self._unit:movement():team().foes[u_data.unit:movement():team().id] and not u_data.unit:anim_data().hands_tied and not u_data.unit:anim_data().long_dis_interact_disabled and (not u_data.unit:character_damage() or not u_data.unit:character_damage():dead()) and (u_data.char_tweak.priority_shout or not only_special_enemies) then
				if managers.groupai:state():whisper_mode() then
					if u_data.char_tweak.silent_priority_shout and u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
					elseif not u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd, nil, "ai_vision mover")
					end
				elseif u_data.char_tweak.priority_shout then
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
				else
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd, nil, "ai_vision mover")
				end
			end
		end
	end

	if intimidate_civilians then
		local civilians = managers.enemy:all_civilians()
		for u_key, u_data in pairs(civilians) do
			local dist = intimidate_range_civ
			local prio = 100
			self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_civilian, dist, false, false, prio, my_head_pos, cam_fwd)
		end
		
		if IreNFist._converts then
			for u_key, u_data in pairs(IreNFist._converts) do
				-- Argh, more crash checks
				if u_data and u_data.alive and u_data:alive() and u_data.movement and u_data:movement() then
					if not u_data:movement():cool() and not u_data:anim_data().long_dis_interact_disabled then
						self:_add_unit_to_char_table(char_table, u_data, unit_type_enemy, highlight_range, true, false, 100, my_head_pos, cam_fwd)
					end
				end
			end
		end 
	end

	if intimidate_teammates and not managers.groupai:state():whisper_mode() then
		local criminals = managers.groupai:state():all_char_criminals()

		for u_key, u_data in pairs(criminals) do
			local added = nil

			if u_key ~= self._unit:key() then
				local rally_skill_data = self._ext_movement:rally_skill_data()

				if rally_skill_data and rally_skill_data.long_dis_revive and mvector3.distance_sq(self._pos, u_data.m_pos) < rally_skill_data.range_sq then
					local needs_revive = nil

					if u_data.unit:base().is_husk_player then
						needs_revive = u_data.unit:interaction():active() and u_data.unit:movement():need_revive() and u_data.unit:movement():current_state_name() ~= "arrested"
					else
						needs_revive = u_data.unit:character_damage():need_revive()
					end

					if needs_revive then
						added = true

						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, intimidate_range_teammates, true, true, 5000, my_head_pos, cam_fwd)
					end
				end
			end

			if not added and not u_data.is_deployable and not u_data.unit:movement():downed() and not u_data.unit:base().is_local_player and not u_data.unit:anim_data().long_dis_interact_disabled then
				self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, intimidate_range_teammates, true, not secondary, 0.01, my_head_pos, cam_fwd)
			end
		end
	end

	if intimidate_enemies and intimidate_teammates then
		local enemies = managers.enemy:all_enemies()

		for u_key, u_data in pairs(enemies) do
			if u_data.unit:movement():team() and u_data.unit:movement():team().id == "criminal1" and not u_data.unit:movement():cool() and not u_data.unit:anim_data().long_dis_interact_disabled then
				local is_escort = u_data.char_tweak.is_escort

				if not is_escort or intimidate_escorts then
					local dist = is_escort and 300 or intimidate_range_civ
					local prio = is_escort and 100000 or 0.001

					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_civilian, dist, false, false, prio, my_head_pos, cam_fwd)
				end
			end
		end
	end

	if intimidate_enemies then
		if managers.groupai:state():whisper_mode() then
			for _, unit in ipairs(SecurityCamera.cameras) do
				if alive(unit) and unit:enabled() and not unit:base():destroyed() then
					local dist = 2000
					local prio = 0.001

					self:_add_unit_to_char_table(char_table, unit, unit_type_camera, dist, false, false, prio, my_head_pos, cam_fwd, {
						unit
					})
				end
			end
		end

		local turret_units = managers.groupai:state():turrets()

		if turret_units then
			for _, unit in pairs(turret_units) do
				if alive(unit) and unit:movement():team().foes[self._ext_movement:team().id] then
					self:_add_unit_to_char_table(char_table, unit, unit_type_turret, 2000, false, false, 0.01, my_head_pos, cam_fwd, {
						unit
					})
				end
			end
		end
	end

	local prime_target = self:_get_interaction_target(char_table, my_head_pos, cam_fwd)

	return self:_get_intimidation_action(prime_target, char_table, intimidation_amount, primary_only, detect_only, secondary)
end

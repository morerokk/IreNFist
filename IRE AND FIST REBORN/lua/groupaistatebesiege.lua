dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.enablenewassaults then
	return
end

-- Copypasted from vanilla with an extra crash guard check
-- Just in case my spawning code still spawns enemies without objectives
-- At the time of writing, it *still* crashes sometimes, therefore still making this code necessary.
function GroupAIStateBesiege:_perform_group_spawning(spawn_task, force, use_last)
	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts

	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned and not force then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()

		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]

			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() then
				hopeless = false

				if sp_data.delay_t < self._t then
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
					
						-- They cant do anything without an objective, I dunno why theyre spawning this way
						-- Temp fix is to just nuke it for now
						-- TODO: Test if this was fixed and remove this whole function override
						if not spawn_task or not spawn_task.group or not spawn_task.group.objective or not spawn_task.group.objective.element then
							log("[COPSPAWNDEBUG] Fatal error: a cop spawned without an objective set!")
							spawned_unit:set_slot(0)

							if managers and managers.chat and InFmenu.settings.debug then
								managers.chat:feed_system_message(1, "[InFDEBUG] A cop spawned without an objective set.")
								managers.chat:feed_system_message(1, "Please report this on Github with your BLT log attached (PAYDAY 2/mods/logs).")

								log("Start nil checks:")
								if not spawn_task then
									log("spawn_task is nil")
								end
								if not spawn_task or not spawn_task.group then
									log("spawn_task.group is nil")
								end
								if not spawn_task or not spawn_task.group or not spawn_task.group.objective then
									log("spawn_task.group.objective is nil")
								end
								if not spawn_task or not spawn_task.group or not spawn_task.group.objective or not spawn_task.group.objective.element then
									-- This one is it!
									log("spawn_task.group.objective.element is nil")
									log(debug.traceback())
								end
								log("End nil checks.")
							end

							return true
						end
					
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

						if not objective then
							spawned_unit:set_slot(0)

							return true
						end

						objective.grp_objective = spawn_task.group.objective
					end

					local u_data = self._police[u_key]

					-- Override weapon
					if category.primary_weapon_override or category.secondary_weapon_override then
						u_data.unit:movement():_override_weapons(category.primary_weapon_override, category.secondary_weapon_override)
					end

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end

					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
						spawned_unit:brain()._logic_data.spawned_in_phase = spawn_task.ai_task.phase
					end

					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true

		table.remove(self._spawning_groups, use_last and #self._spawning_groups or 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end

-- Debug lack of team and objective
-- Probably fixed by now thanks to Hoppip
if InFmenu.settings.debug then
	function GroupAIStateBesiege:set_char_team(unit, team_id)
		local u_key = unit:key()
		local team = self._teams[team_id]
		local u_data = self._police[u_key]
		
		if not u_data then
			log("[COPSPAWNDEBUG] Cop u_data was nil!")
		elseif not u_data.group then
			log("[COPSPAWNDEBUG] Cop u_data.group was nil!")
		end

		if u_data and u_data.group then
			u_data.group.team = team

			for _, other_u_data in pairs(u_data.group.units) do
				other_u_data.unit:movement():set_team(team)
			end

			return
		end

		unit:movement():set_team(team)
	end
end

if InFmenu.settings.assaulttweakstype == 3 then
	-- Fix difficulty value starting at max instead of at 0
	function GroupAIStateBesiege:_upd_assault_task()
		local task_data = self._task_data.assault

		if not task_data.active then
			return
		end

		local t = self._t

		self:_assign_recon_groups_to_retire()

		local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
		local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)

		if task_data.phase == "anticipation" then
			if task_spawn_allowance <= 0 then
				print("spawn_pool empty: -----------FADE-------------")

				task_data.phase = "fade"
				task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			elseif task_data.phase_end_t < t or self._drama_data.zone == "high" then
				self._assault_number = self._assault_number + 1

				managers.mission:call_global_event("start_assault")
				managers.hud:start_assault(self._assault_number)
				managers.groupai:dispatch_event("start_assault", self._assault_number)
				self:_set_rescue_state(false)

				task_data.phase = "build"
				task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
				task_data.is_hesitating = nil

				self:set_assault_mode(true)
				managers.trade:set_trade_countdown(false)
			else
				managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
				managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)

				if task_data.is_hesitating and task_data.voice_delay < self._t then
					if self._hostage_headcount > 0 then
						local best_group = nil

						for _, group in pairs(self._groups) do
							if not best_group or group.objective.type == "reenforce_area" then
								best_group = group
							elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
								best_group = group
							end
						end

						if best_group and self:_voice_delay_assault(best_group) then
							task_data.is_hesitating = nil
						end
					else
						task_data.is_hesitating = nil
					end
				end
			end
		elseif task_data.phase == "build" then
			if task_spawn_allowance <= 0 then
				task_data.phase = "fade"
				task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			elseif task_data.phase_end_t < t or self._drama_data.zone == "high" then
				local sustain_duration = math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)

				managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)

				task_data.phase = "sustain"
				task_data.phase_end_t = t + sustain_duration
			end
		elseif task_data.phase == "sustain" then
			local end_t = self:assault_phase_end_time()
			task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

			if task_spawn_allowance <= 0 then
				task_data.phase = "fade"
				task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			elseif end_t < t and not self._hunt_mode then
				task_data.phase = "fade"
				task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			end
		else
			local end_assault = false
			local enemies_left = self:_count_police_force("assault")

			if not self._hunt_mode then
				local enemies_defeated_time_limit = 30
				local drama_engagement_time_limit = 60

				if managers.skirmish:is_skirmish() then
					enemies_defeated_time_limit = 0
					drama_engagement_time_limit = 0
				end

				local min_enemies_left = 50
				local enemies_defeated = enemies_left < min_enemies_left
				local taking_too_long = t > task_data.phase_end_t + enemies_defeated_time_limit

				if enemies_defeated or taking_too_long then
					if not task_data.said_retreat then
						task_data.said_retreat = true

						self:_police_announce_retreat()
					elseif task_data.phase_end_t < t then
						local drama_pass = self._drama_data.amount < tweak_data.drama.assault_fade_end
						local engagement_pass = self:_count_criminals_engaged_force(11) <= 10
						local taking_too_long = t > task_data.phase_end_t + drama_engagement_time_limit

						if drama_pass and engagement_pass or taking_too_long then
							end_assault = true
						end
					end
				end

				if task_data.force_end or end_assault then
					print("assault task clear")

					task_data.active = nil
					task_data.phase = nil
					task_data.said_retreat = nil
					task_data.force_end = nil
					local force_regroup = task_data.force_regroup
					task_data.force_regroup = nil

					if self._draw_drama then
						self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
					end

					managers.mission:call_global_event("end_assault")
					self:_begin_regroup_task(force_regroup)
					-- Increase diff value by 0.25 after each assault
					self:set_difficulty(nil, 0.25)

					return
				end
			end
		end

		if self._drama_data.amount <= tweak_data.drama.low then
			for criminal_key, criminal_data in pairs(self._player_criminals) do
				self:criminal_spotted(criminal_data.unit)

				for group_id, group in pairs(self._groups) do
					if group.objective.charge then
						for u_key, u_data in pairs(group.units) do
							u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
						end
					end
				end
			end
		end

		local primary_target_area = task_data.target_areas[1]

		if self:is_area_safe_assault(primary_target_area) then
			local target_pos = primary_target_area.pos
			local nearest_area, nearest_dis = nil

			for criminal_key, criminal_data in pairs(self._player_criminals) do
				if not criminal_data.status then
					local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)

					if not nearest_dis or dis < nearest_dis then
						nearest_dis = dis
						nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
					end
				end
			end

			if nearest_area then
				primary_target_area = nearest_area
				task_data.target_areas[1] = nearest_area
			end
		end

		local nr_wanted = task_data.force - self:_count_police_force("assault")

		if task_data.phase == "anticipation" then
			nr_wanted = nr_wanted - 5
		end

		if nr_wanted > 0 and task_data.phase ~= "fade" then
			local used_event = nil

			if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
				task_data.use_spawn_event = false

				if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
					used_event = true
				end
			end

			if not used_event then
				if next(self._spawning_groups) then
					-- Nothing
				else
					local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)

					if spawn_group then
						local grp_objective = {
							attitude = "avoid",
							stance = "hos",
							pose = task_data.phase == "anticipation" and "crouch" or "stand",
							type = "assault_area",
							area = primary_target_area
						}

						self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
					end
				end
			end
		end

		if task_data.phase ~= "anticipation" then
			if task_data.use_smoke_timer < t then
				task_data.use_smoke = true
			end

			self:detonate_queued_smoke_grenades()
		end

		self:_assign_enemy_groups_to_assault(task_data.phase)
	end
end

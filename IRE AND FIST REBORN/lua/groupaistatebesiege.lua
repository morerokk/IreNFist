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

function GroupAIStateBesiege:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks

	while i > 0 do
		local task_data = reenforce_tasks[i]
		local force_settings = task_data.target_area.factors.force
		local force_required = force_settings and force_settings.force

		if force_required then
			local force_occupied = 0

			for group_id, group in pairs(self._groups) do
				if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					force_occupied = force_occupied + (group.has_spawned and group.size or group.initial_size)
				end
			end

			local undershot = force_required - force_occupied

			if undershot > 0 and not self._task_data.regroup.active and self._task_data.assault.phase ~= "fade" and self._task_data.reenforce.next_dispatch_t < t and self:is_area_safe(task_data.target_area) then
				local used_event = nil

				if task_data.use_spawn_event then
					task_data.use_spawn_event = false

					if self:_try_use_task_spawn_event(t, task_data.target_area, "reenforce") then
						used_event = true
					end
				end

				local used_group, spawning_groups = nil

				if not used_event then
					if next(self._spawning_groups) then
						spawning_groups = true
					else
						local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.reenforce.groups, nil, nil, nil)

						if spawn_group then
							local grp_objective = {
								attitude = "avoid",
								scan = true,
								pose = "stand",
								type = "reenforce_area",
								stance = "hos",
								area = spawn_group.area,
								target_area = task_data.target_area
							}

							self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

							used_group = true
						end
					end
				end

				if used_event or used_group then
					self._task_data.reenforce.next_dispatch_t = t + self:_get_difficulty_dependent_value(self._tweak_data.reenforce.interval)
				end
			elseif undershot < 0 then
				local force_defending = 0

				for group_id, group in pairs(self._groups) do
					if group.objective.area == task_data.target_area and group.objective.type == "reenforce_area" then
						force_defending = force_defending + (group.has_spawned and group.size or group.initial_size)
					end
				end

				local overshot = force_defending - force_required

				if overshot > 0 then
					local closest_group, closest_group_size = nil

					for group_id, group in pairs(self._groups) do
						if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" and (not closest_group_size or closest_group_size < group.size) and group.size <= overshot then
							closest_group = group
							closest_group_size = group.size
						end
					end

					if closest_group then
						self:_assign_group_to_retire(closest_group)
					end
				end
			end
		else
			for group_id, group in pairs(self._groups) do
				if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					self:_assign_group_to_retire(group)
				end
			end

			reenforce_tasks[i] = reenforce_tasks[#reenforce_tasks]

			table.remove(reenforce_tasks)
		end

		i = i - 1
	end

	self:_assign_enemy_groups_to_reenforce()
end
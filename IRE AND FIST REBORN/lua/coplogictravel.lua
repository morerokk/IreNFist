dofile(ModPath .. "infcore.lua")

-- The . instead of a : is not a typo, this really is how they put it into the base game.
-- And yes, this really is yet another "cops spawn with no team" crash.
local coplogictravel_enter_orig = CopLogicTravel.enter
function CopLogicTravel.enter(data, new_logic_name, enter_params)
	if not data.team then
		-- Calling movement:team() will also force-initialize the team if it doesn't exist yet
		data.team = data.unit:movement():team()
	end

	return coplogictravel_enter_orig(data, new_logic_name, enter_params)
end

if InFmenu and InFmenu.settings.beta then

	-- Same as vanilla, except I removed the check that makes cops *not* wait at each checkpoint if players are too far away.
	-- Thanks RedFlame!
	function CopLogicTravel.action_complete_clbk(data, action)
		local my_data = data.internal_data
		local action_type = action:type()

		if action_type == "walk" then
			if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and my_data.advancing then
				my_data.coarse_path_index = my_data.coarse_path_index + 1

				if my_data.coarse_path_index > #my_data.coarse_path then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

					my_data.coarse_path_index = my_data.coarse_path_index - 1
				end
			end

			my_data.advancing = nil

			if my_data.moving_to_cover then
				if action:expired() then
					if my_data.best_cover then
						managers.navigation:release_cover(my_data.best_cover[1])
					end

					my_data.best_cover = my_data.moving_to_cover

					CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

					local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
					my_data.best_cover[4] = high_ray
					my_data.in_cover = true
					local cover_wait_time = my_data.coarse_path_index == #my_data.coarse_path - 1 and 0.3 or 0.6 + 0.4 * math.random()

					my_data.cover_leave_t = data.t + cover_wait_time
				else
					managers.navigation:release_cover(my_data.moving_to_cover[1])

					if my_data.best_cover then
						local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())

						if dis > 100 then
							managers.navigation:release_cover(my_data.best_cover[1])

							my_data.best_cover = nil
						end
					end
				end

				my_data.moving_to_cover = nil
			elseif my_data.best_cover then
				local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())

				if dis > 100 then
					managers.navigation:release_cover(my_data.best_cover[1])

					my_data.best_cover = nil
				end
			end

			if not action:expired() then
				if my_data.processing_advance_path then
					local pathing_results = data.pathing_results

					if pathing_results and pathing_results[my_data.advance_path_search_id] then
						data.pathing_results[my_data.advance_path_search_id] = nil
						my_data.processing_advance_path = nil
					end
				elseif my_data.advance_path then
					my_data.advance_path = nil
				end

				data.unit:brain():abort_detailed_pathing(my_data.advance_path_search_id)
			end
		elseif action_type == "turn" then
			data.internal_data.turning = nil
		elseif action_type == "shoot" then
			data.internal_data.shooting = nil
		elseif action_type == "dodge" then
			local objective = data.objective
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

			if allow_trans then
				local wanted_state = data.logic._get_logic_state_from_reaction(data)

				if wanted_state and wanted_state ~= data.name and obj_failed then
					if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
						data.objective_failed_clbk(data.unit, data.objective)
					elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
						managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
					end

					if my_data == data.internal_data then
						debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
						CopLogicBase._exit(data.unit, wanted_state)
					end
				end
			end
		end
	end

	-- Make cops wait for the rest of their squad before moving up.
	-- Again, same thing, removed the "too far away from players check".
	-- And again, thanks RedFlame!
	function CopLogicTravel.chk_group_ready_to_move(data, my_data)
		local my_objective = data.objective

		if not my_objective.grp_objective then
			return true
		end

		local my_dis = mvector3.distance_sq(my_objective.area.pos, data.m_pos)

		if my_dis > 4000000 then
			return true
		end

		my_dis = my_dis * 1.15 * 1.15

		for u_key, u_data in pairs(data.group.units) do
			if u_key ~= data.key then
				local his_objective = u_data.unit:brain():objective()

				if his_objective and his_objective.grp_objective == my_objective.grp_objective and not his_objective.in_place then
					local his_dis = mvector3.distance_sq(his_objective.area.pos, u_data.m_pos)

					if my_dis < his_dis then
						return false
					end
				end
			end
		end

		return true
	end

end
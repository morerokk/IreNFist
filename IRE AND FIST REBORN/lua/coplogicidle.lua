dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.enablenewcopbehavior then
	return
end

-- Undid a change introduced in Update 173, where cops would stop defending areas if criminals aren't in them.
-- This makes cops less braindead rush-heavy and makes them actually defend an area, even if players aren't nearby yet.
-- Thanks RedFlame for pointing this out!
-- EDIT: The changes that Overkill made were actually worse than thought. Apparently, almost every objective has the "defend_area" type, which means that
-- cops will happily ignore special objectives and will even stop fleeing the scene if players aren't close to the edges of the map when an assault ends.
-- Thankfully, simply restoring this function to pre-Update 173 makes all of this work again. Thanks again RedFlame!
function CopLogicIdle._chk_relocate(data)
	if data.objective and data.objective.type == "follow" then
		if data.is_converted then
			if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective) then
				data.objective.in_place = nil

				data.logic._exit(data.unit, "travel")

				return true
			end

			return
		end

		if data.is_tied and data.objective.lose_track_dis and data.objective.lose_track_dis * data.objective.lose_track_dis < mvector3.distance_sq(data.m_pos, data.objective.follow_unit:movement():m_pos()) then
			data.brain:set_objective(nil)

			return true
		end

		local relocate = nil
		local follow_unit = data.objective.follow_unit
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()

		if data.objective.relocated_to and mvector3.equal(data.objective.relocated_to, follow_unit_pos) then
			return
		end

		if data.objective.distance and data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos) then
			relocate = true
		end

		if not relocate then
			local ray_params = {
				tracker_from = data.unit:movement():nav_tracker(),
				pos_to = follow_unit_pos
			}
			local ray_res = managers.navigation:raycast(ray_params)

			if ray_res then
				relocate = true
			end
		end

		if relocate then
			data.objective.in_place = nil
			data.objective.nav_seg = follow_unit:movement():nav_tracker():nav_segment()
			data.objective.relocated_to = mvector3.copy(follow_unit_pos)

			data.logic._exit(data.unit, "travel")

			return true
		end
	end
end
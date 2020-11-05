dofile(ModPath .. "infcore.lua")

-- Debug only
-- Debugging a weird crash
if not InFmenu.settings.beta then
    return
end

function CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	if data.char_tweak.flee_type ~= "hide" then
		if data.unit:unit_data() and data.unit:unit_data().not_rescued then
			-- Nothing
		elseif my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
			managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 10)
		else
			if my_data.rescuer then
				local objective = my_data.rescuer:brain():objective()
				local rescuer = my_data.rescuer
				my_data.rescuer = nil

				managers.groupai:state():on_objective_failed(rescuer, objective)
			elseif my_data.rescue_SO_id then
				managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

				my_data.rescue_SO_id = nil
			end

			my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_rescue_SO_id, callback(CopLogicIntimidated, CopLogicIntimidated, "register_rescue_SO", data), TimerManager:game():time() + 10)
		end
	end
end

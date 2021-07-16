dofile(ModPath .. "infcore.lua")

-- Sprint with any bag skill
if not IREnFIST.mod_compatibility.sso then
	function PlayerCarry:_check_action_run(...)
		if tweak_data.carry.types[self._tweak_data_name].can_run or managers.player:has_category_upgrade("player", "sprint_any_bag") or managers.player:has_category_upgrade("carry", "movement_penalty_nullifier") then
			PlayerCarry.super._check_action_run(self, ...)
		end
	end
end

-- Disallow sliding with heavier bags even if the skill allows us to sprint
function PlayerCarry:_check_slide(...)
	if tweak_data.carry.types[self._tweak_data_name].can_run then
		return PlayerCarry.super._check_slide(self, ...)
	else
		self:_cancel_slide()
		return false
	end
end

-- Disallow wallkicking/running with heavier bags too
function PlayerCarry:_check_wallkick(...)
	if tweak_data.carry.types[self._tweak_data_name].can_run then
		return PlayerCarry.super._check_wallkick(self, ...)
	else
		return false
	end
end

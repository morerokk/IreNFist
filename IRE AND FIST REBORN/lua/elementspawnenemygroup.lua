-- Add every spawn group to the list, not just predefined ones.
-- Allows this mod to add custom squads and spawn groups.
--[[
function ElementSpawnEnemyGroup:spawn_groups()
	local opt = {}
	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		table.insert(opt, cat_name)
	end
	return opt
end
]]

-- Improved version of the above, takes the currently known "default" spawn list and adds *all* groups into the list if it matches.
-- This means that added squads will only spawn from "standard" spawns and not from, say, cloaker vents or other uniques.

local groupsOLD = {
	"tac_shield_wall_charge",
	"FBI_spoocs",
	"tac_tazer_charge",
	"tac_tazer_flanking",
	"tac_shield_wall",
	"tac_swat_rifle_flank",
	"tac_shield_wall_ranged",
	"tac_bull_rush"
}

local old_finalize_values = ElementSpawnEnemyGroup._finalize_values
function ElementSpawnEnemyGroup:_finalize_values()
	old_finalize_values(self)
			
	local groups = self._values.preferred_spawn_groups
	-- If we have an ordinary spawn with exactly the old group elements, add all defined groups.
	if groups and #groups == #groupsOLD and table.contains_all(groups, groupsOLD) then
		for name,_ in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if not table.contains(groups, name) then
				table.insert(groups, name)
			end
		end
	end
end

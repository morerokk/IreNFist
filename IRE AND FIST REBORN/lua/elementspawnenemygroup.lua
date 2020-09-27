-- Add every spawn group to the list, not just predefined ones.
-- Allows this mod to add custom squads and spawn groups.

-- If a spawngroup matches this list exactly, it's a "default" one and we can add our own spawngroups to it
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

-- Make the captain not spawn in weird places
local disallowed_groups = {
	Phalanx = true
}

Hooks:PostHook(ElementSpawnEnemyGroup, "_finalize_values", "inf_elementspawnenemygroup_addspawngroups", function(self)	
	local groups = self._values.preferred_spawn_groups
	-- If we have an ordinary spawn with exactly the old group elements, add all defined groups.
	if groups and #groups == #groupsOLD and table.contains_all(groups, groupsOLD) then
		for name,_ in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if not table.contains(groups, name) and not disallowed_groups[name] then
				table.insert(groups, name)
			end
		end
	end
end)

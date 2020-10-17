dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.beta then
    return
end

-- Spoof perk deck as armorer to prevent crashes (and to prevent malicious mods like Full Speed Swarm from kicking us)
local skilltreemanager_pack_string_orig = SkillTreeManager.pack_to_string
function SkillTreeManager:pack_to_string()
    if not IreNFist.holdout_deck_index then
        return skilltreemanager_pack_string_orig(self)
    end

    local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
    if current_specialization ~= IreNFist.holdout_deck_index then
        return skilltreemanager_pack_string_orig(self)
    end

    current_specialization = 3

	local packed_string = ""

	for tree, data in ipairs(tweak_data.skilltree.trees) do
		local points, num_skills = managers.skilltree:get_tree_progress_new(tree)
		packed_string = packed_string .. tostring(points)

		if tree ~= #tweak_data.skilltree.trees then
			packed_string = packed_string .. "_"
		end
	end

	local tree_data = self._global.specializations[current_specialization]

	if tree_data then
		local tier_data = tree_data.tiers

		if tier_data then
			local current_tier = self:digest_value(tier_data.current_tier, false)
			packed_string = packed_string .. "-" .. tostring(current_specialization) .. "_" .. tostring(current_tier)
		end
	end

	return packed_string
end

Hooks:PostHook(GuiTweakData, "init", "infwpncategories", function(self, params)
	-- add weapon categories
	self.buy_weapon_categories = {
		primaries = {
			--{"smg"},
			{"smg_h"},
			{"assault_rifle"},
			{"rifle_m"},
			{"rifle_h"},
			{"dmr"},
			{"shotgun"},
			{"lmg"},
			{"snp"},
			{"akimbo", "pistol"},
			{"akimbo", "pistol_m"},
			{"akimbo", "pistol_h"},
			{"akimbo", "smg"},
			{"akimbo", "smg_h"},
			{"akimbo", "carbine"},
			{"akimbo", "shotgun"},
			{"wpn_special"}
		},
		secondaries = {
			{"pistol"},
			{"pistol_m"},
			{"pistol_h"},
			{"smg"},
			{"smg_h"},
			{"carbine"},
			{"shotgun"}, -- reordered to go before wpn_special
			{"wpn_special"}
		}
	}

	-- add weapon category only if a weapon will actually be placed in it
	if InFmenu.has_secondary_dmr then
		table.insert(self.buy_weapon_categories.secondaries, 8, {"dmr"})
	end
	if InFmenu.has_secondary_sniper then
		table.insert(self.buy_weapon_categories.secondaries, 9, {"snp"})
	end


	-- add codex
	local infcodex = {
		{
			{desc_id = "infcodex_scavenge_desc"},
			{desc_id = "infcodex_scavenge2_desc"},
			{desc_id = "infcodex_scavenge3_desc"},
			{desc_id = "infcodex_scavenge4_desc"},
			{desc_id = "infcodex_scavenge5_desc"},
			name_id = "infcodex_scavenge", id = "infcodex_scavenge"
		},
		{
			{desc_id = "infcodex_recoil_desc"},
			{desc_id = "infcodex_recoil2_desc"},
			{desc_id = "infcodex_recoil3_desc"},
			name_id = "infcodex_recoil", id = "infcodex_recoil"
		},
		{
			{desc_id = "infcodex_ap_desc"},
			{desc_id = "infcodex_ap2_desc"},
			name_id = "infcodex_ap", id = "infcodex_ap"
		},
		{
			{desc_id = "infcodex_shotgun_desc"},
			{desc_id = "infcodex_shotgun2_desc"},
			name_id = "infcodex_shotgun", id = "infcodex_shotgun"
		},
		{
			{desc_id = "infcodex_enehp_desc"},
			{desc_id = "infcodex_enehp2_desc"},
			{desc_id = "infcodex_enehp3_desc"},
			{desc_id = "infcodex_enehp4_desc"},
			{desc_id = "infcodex_enehp5_desc"},
			{desc_id = "infcodex_enehp6_desc"},
			{desc_id = "infcodex_enehp7_desc"},
			name_id = "infcodex_enehp", id = "infcodex_enehp"
		},
		{
			{desc_id = "infcodex_categories_desc"},
			name_id = "infcodex_categories", id = "infcodex_categories"
		},
		{
			{desc_id = "infcodex_movement_desc"},
			{desc_id = "infcodex_movement2_desc"},
			{desc_id = "infcodex_movement3_desc"},
			{desc_id = "infcodex_movement4_desc"},
			{desc_id = "infcodex_movement5_desc"},
			{desc_id = "infcodex_movement6_desc"},
			name_id = "infcodex_movement", id = "infcodex_movement"
		},
		{
			{desc_id = "infcodex_flace_desc"},
			name_id = "infcodex_flace", id = "infcodex_flace"
		},
		-- table name
		name_id = "menu_infcodex", id = "menu_infcodex"
	}

	table.insert(self.crime_net.codex, 1, infcodex)

end)



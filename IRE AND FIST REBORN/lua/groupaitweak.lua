--[[
GRAY JP36: units/payday2/characters/ene_city_swat_1/ene_city_swat_1

GRAY M1014: units/payday2/characters/ene_city_swat_2/ene_city_swat_2
GRAY UMP: units/payday2/characters/ene_city_swat_3/ene_city_swat_3

BLUE MP5: units/payday2/characters/ene_swat_1/ene_swat_1

BLUE R870: units/payday2/characters/ene_swat_2/ene_swat_2

WHITEHEAD: units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1

GREEN M4: units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1
BLUE PISTOL FBI: units/payday2/characters/ene_fbi_1/ene_fbi_1
BLACK GUYS: units/payday2/characters/ene_fbi_2/ene_fbi_2
HOSTAGE RESCUE TEAM: units/payday2/characters/ene_fbi_3/ene_fbi_3

BRONCO COP: units/payday2/characters/ene_cop_2/ene_cop_2

TAN: units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1

5 = OVK
6 = MH
7 = DW
8 = DS
--]]

--[[
Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "givecoolenemies", function(self, params)

	-- gray table: greens, UMP grays
	table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"))
	table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"))

	-- gray heavy table: whiteheads
	table.insert(self.unit_categories.FBI_heavy_G36.unit_types.america, Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"))

	-- skulldozer spawns on all difficulties because i couldn't be bothered to make per-difficulty checks work
	table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"))
end)
--]]

local old_inituc = GroupAITweakData._init_unit_categories
function GroupAITweakData:_init_unit_categories(difficulty_index)
	old_inituc(self, difficulty_index)

	if InFmenu.settings.rainbowassault and InFmenu.settings.rainbowassault == true and difficulty_index >= 5 then
		if difficulty_index > 5 then
			-- greens
			table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"))
		end
		-- UMP grays
		table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"))
		-- blues
		table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"))

		-- whiteheads
		table.insert(self.unit_categories.FBI_heavy_G36.unit_types.america, Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"))
	end

	if InFmenu.settings.skulldozersahoy and InFmenu.settings.skulldozersahoy > 1 then
		if (InFmenu.settings.skulldozersahoy == 2 and difficulty_index == 5 or difficulty_index == 6) or InFmenu.settings.skulldozersahoy == 3 then
			table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"))
		end
	end
end


Hooks:PostHook(GroupAITweakData, "_init_task_data", "fuckyouraurawinters", function(self, params)
	self.phalanx.vip.damage_reduction = {
		max = 0.25,
		start = 0.15,
		increase_intervall = 3000,
		increase = 0.02
	}
end)

--[[
Hooks:PostHook(GroupAITweakData, "_init_task_data", "reducespawnrate", function(self, params)
	-- max # of simultaneous cops
	self.besiege.assault.force = {10, 12, 14} -- 14, 16, 18
	self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

	-- max # of cops in an entire assault wave
	self.besiege.assault.force_pool = {40, 45, 50} -- 150, 175, 225
	self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

end)
--]]
dofile(ModPath .. "infcore.lua")

local function string_startswith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end
	 

-- Check for holdout, if so don't make any changes here at all
local level = Global.level_data and Global.level_data.level_id
if level and string_startswith(level, "skm_") then
	return
end

if InFmenu.settings.assaulttweakstype ~= 2 then
	return
end

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

if not InFmenu.settings.enablenewassaults then
	return
end

-- Expand rushing taser squads. Add calm state hostage rescue squads (which can also have tasers).
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "inf_groupai_hostagerescueandtasersquads", function(self, difficulty_index)
	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				5,
				6
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 1,
					unit = "CS_cop_C45_R870",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_cop_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_suit_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_cop_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				6,
				7
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_suit_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 1,
					unit = "CS_cop_C45_R870",
					tactics = self._tactics.tazer_flanking
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				7,
				7
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 4,
					freq = 1,
					amount_max = 4,
					rank = 2,
					unit = "FBI_suit_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				7,
				7
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 4,
					freq = 1,
					amount_max = 4,
					rank = 2,
					unit = "FBI_suit_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_hostagerescue_flanking = {
			amount = {
				7,
				8
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					amount_min = 4,
					freq = 1,
					amount_max = 4,
					rank = 2,
					unit = "FBI_suit_stealth_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 1,
					unit = "FBI_suit_C45_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 1,
					freq = 3,
					amount_max = 1,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 1,
					freq = 3,
					amount_max = 1,
					rank = 2,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 2,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 2,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 1,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	end
end)

-- Re-add the mistakenly removed shotgunners
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "inf_groupai_shotgunsquads", function(self, difficulty_index)

	-- Shotgun rushers
	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					amount_max = 5,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 5,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	end
	
	-- Shotgun flankers
	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 4,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	end
	
	-- Tactical riflemen
	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	end

end)

-- "Combined Arms" squads, these are squads that carry both shotgunners and riflemen. Used to break up the monotony of getting just shotgunners/just riflemen.
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "inf_groupai_combinedarmssquads", function(self, difficulty_index)
	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 3,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_combined_arms = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 3,
					freq = 3,
					amount_max = 4,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	end
end)

-- Remove tan shotgunners from various vanilla groups (currently only the shield wall charge has them anyway)
-- Replace them with SWAT shotgunners
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "inf_groupai_removetanshotgunners", function(self, difficulty_index)

	-- Tan shotgunners only start at difficulty 5 in this squad, we don't have to touch the lower ones
	if difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				}
			}
		}
		-- Difficulty 6 intentionally left out, has no tan shotgunners in vanilla
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				}
			}
		}
	elseif difficulty_index >= 8 then -- Used to be the "else" condition, but we're leaving out some difficulties so this condition has to explicitly check for DS or higher
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				}
			}
		}
	end
end)

Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "irenfist_groupaitweak_initunitcategors", function(self, difficulty_index)
	if InFmenu.settings.rainbowassault and difficulty_index >= 5 then
		if difficulty_index > 5 then
			-- greens
			table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"))
		else
			-- UMP grays, only on overkill because they're already re-added on Mayhem/DW
			table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"))
		end

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
	
	-- Rokks tweaks start here

	-- No taser shotgunners since they crash unmodded clients :/

	-- I forgot why this was necessary
	table.insert(self.unit_categories.CS_cop_C45_R870.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"))

	-- Overkill made yet another typo which crashes the game on Federales heists, fixing it by setting the Federales FBI groups to be identical to America
	self.unit_categories.FBI_suit_C45_M4.unit_types.federales = self.unit_categories.FBI_suit_C45_M4.unit_types.america
	self.unit_categories.FBI_suit_M4_MP5.unit_types.federales = self.unit_categories.FBI_suit_M4_MP5.unit_types.america
	-- Same with murkywater
	self.unit_categories.FBI_suit_C45_M4.unit_types.murkywater = self.unit_categories.FBI_suit_C45_M4.unit_types.america
	self.unit_categories.FBI_suit_M4_MP5.unit_types.murkywater = self.unit_categories.FBI_suit_M4_MP5.unit_types.america

	-- Add UMP/Benelli Gensec guys to Mayhem/DW
	if difficulty_index == 6 or difficulty_index == 7 then
		-- Add UMP guys to M4 units
		table.insert(self.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"))
		-- Add Benelli guys to R870 units
		table.insert(self.unit_categories.FBI_swat_R870.unit_types.america, Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"))
	end

	-- Remove tan shotgunners (yes, really).
	-- Before hoxton's housewarming, tan shotgunners didn't actually exist.
	-- the shotguns were unique to the lighter units which gave units more variety.
	-- The "downside" is that you'll see a bit less tans overall. This could possibly be tweaked manually by making the tans more likely.
	-- I'm unsure how this will affect other factions. Technically this removes a bit of unit variety, but they were copypasted weaponswaps anyway.

	-- UPDATE: Tests show that this makes tans too uncommon.
	-- The next best possible course of action is to tweak every spawngroup that has tan shotgunners and just remove them from the group (which I did further up).
	-- This means that instead of 75% of the shotgunner cops being light units, 66% are.
	-- self.unit_categories.FBI_heavy_R870 = deep_clone(self.unit_categories.FBI_swat_R870)

	-- Give ZEAL shotgunners their deserved R870's
	if difficulty_index >= 8 then
		self.unit_categories.FBI_heavy_R870.primary_weapon_override = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
		self.unit_categories.FBI_swat_R870.primary_weapon_override = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
	end
end)


Hooks:PostHook(GroupAITweakData, "_init_task_data", "inf_assault_tweaks", function(self, difficulty_index, difficulty)

	-- Nerf Winters damage reduction
	self.phalanx.vip.damage_reduction = {
		max = 0.25,
		start = 0.15,
		increase_intervall = 3000,
		increase = 0.02
	}
	
	-- Make fades last longer
	self.besiege.regroup.duration = {
		30,
		30,
		30
	}
	
	-- Add more/longer assault breaks
	if difficulty_index <= 2 then
		self.besiege.assault.delay = {
			105,
			85,
			70
		}
	elseif difficulty_index == 3 then
		self.besiege.assault.delay = {
			85,
			75,
			65
		}
	elseif difficulty_index == 4 then
		self.besiege.assault.delay = {
			80,
			70,
			60
		}
	elseif difficulty_index == 5 then
		self.besiege.assault.delay = {
			70,
			60,
			50
		}
	else
		self.besiege.assault.delay = {
			60,
			55,
			50
		}
	end

	-- Make the assault breaks substantially longer if players have hostages
	if difficulty_index <= 5 then
		self.besiege.assault.hostage_hesitation_delay = {
			50,
			45,
			40
		}
	else
		self.besiege.assault.hostage_hesitation_delay = {
			45,
			40,
			35
		}
	end
	
	-- Taser squads part 2, actually add them to the recon teams
	-- Wipe the other cops from the recon groups, ONLY add hostage rescues
	-- HOWEVER, need to add cloakers and phalanxes because otherwise the game can crash
	-- Thank you so much for pinpointing this issue Hoppip
	self.besiege.recon.groups = {
		tac_hostagerescue_flanking = {
			0.1,
			0.1,
			0.1
		},
		single_spooc = {
			0,
			0,
			0
		},
		Phalanx = {
			0,
			0,
			0
		}
	}	
	
	-- Remove the HRT flanking group from the assault, but still define it.
	self.besiege.assault.groups.tac_hostagerescue_flanking = {
		0,
		0,
		0
	}

	-- Add spawn chances for combined arms squad
	self.besiege.assault.groups.tac_swat_combined_arms = deep_clone(self.besiege.assault.groups.tac_swat_rifle)
	-- Make them less likely to spawn compared to other groups
	-- This is a little dirty but this saves me having to write the same thing 7 times, once for every difficulty
	self.besiege.assault.groups.tac_swat_combined_arms[1] = self.besiege.assault.groups.tac_swat_combined_arms[1] * 0.3
	self.besiege.assault.groups.tac_swat_combined_arms[2] = self.besiege.assault.groups.tac_swat_combined_arms[2] * 0.3
	self.besiege.assault.groups.tac_swat_combined_arms[3] = self.besiege.assault.groups.tac_swat_combined_arms[3] * 0.3

	-- Make shotgunner squads just slightly less likely to spawn
	self.besiege.assault.groups.tac_swat_shotgun_rush[1] = self.besiege.assault.groups.tac_swat_shotgun_rush[1] * 0.7
	self.besiege.assault.groups.tac_swat_shotgun_rush[2] = self.besiege.assault.groups.tac_swat_shotgun_rush[2] * 0.7
	self.besiege.assault.groups.tac_swat_shotgun_rush[3] = self.besiege.assault.groups.tac_swat_shotgun_rush[3] * 0.7

	self.besiege.assault.groups.tac_swat_shotgun_flank[1] = self.besiege.assault.groups.tac_swat_shotgun_flank[1] * 0.7
	self.besiege.assault.groups.tac_swat_shotgun_flank[2] = self.besiege.assault.groups.tac_swat_shotgun_flank[2] * 0.7
	self.besiege.assault.groups.tac_swat_shotgun_flank[3] = self.besiege.assault.groups.tac_swat_shotgun_flank[3] * 0.7
	
	-- Reduce spawn rates a little
	-- max # of simultaneous cops
	self.besiege.assault.force = {14, 15, 16} -- 14, 16, 18
	self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

	-- max # of cops in an entire assault wave
	-- I'm pretty happy with these values on Overkill/Mayhem/DW
	self.besiege.assault.force_pool = {40, 45, 50} -- 150, 175, 225
	self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

	-- Check and apply heist-specific overrides for the above values
	local job = Global.level_data and Global.level_data.level_id
	if job and IreNFist.bad_heist_overrides[job] then
		self.besiege.assault.force = IreNFist.bad_heist_overrides[job].force
		self.besiege.assault.force_balance_mul = IreNFist.bad_heist_overrides[job].force_balance_mul

		self.besiege.assault.force_pool = IreNFist.bad_heist_overrides[job].force_pool
		self.besiege.assault.force_pool_balance_mul = IreNFist.bad_heist_overrides[job].force_pool_balance_mul

		log("[IREnFIST] Bad heist " .. job .. " found, applying relevant assault overrides")
	end
	
end)

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
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
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
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_heavy_R870",
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
	
	-- Rokks tweaks start here
	
	
	-- Add mysteriously missing ene_cop_2 to basic cops list
	table.insert(self.unit_categories.CS_cop_C45_R870.unit_types.america, Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"))

	table.insert(self.unit_categories.CS_cop_C45_R870.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"))
	
	-- Change the hostage rescue units for murkywater to all light FBIs
	self.unit_categories.FBI_suit_C45_M4.unit_types.murkywater = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi")
	}
	
	self.unit_categories.FBI_suit_M4_MP5.unit_types.murkywater = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi")
	}
	
	self.unit_categories.FBI_suit_stealth_MP5.unit_types.murkywater = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi")
	}	
end


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
			60,
			55,
			50
		}
	else
		self.besiege.assault.hostage_hesitation_delay = {
			55,
			50,
			50
		}
	end
	
	-- Taser squads part 2, actually add them to the recon teams
	-- Wipe the other cops from the recon groups, ONLY add hostage rescues
	self.besiege.recon.groups = {
		tac_hostagerescue_flanking = {
			0.1,
			0.1,
			0.1
		}
	}
	
	-- Remove the HRT flanking group from the assault, but still define it.
	self.besiege.assault.groups.tac_hostagerescue_flanking = {
		0,
		0,
		0
	}
	
	-- Reduce spawn rates a little
	-- max # of simultaneous cops
	self.besiege.assault.force = {14, 15, 16} -- 14, 16, 18
	self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

	-- max # of cops in an entire assault wave
	-- I'm pretty happy with these values on Overkill
	self.besiege.assault.force_pool = {40, 45, 50} -- 150, 175, 225
	self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4

end)

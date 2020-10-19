dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.beta then
    return
end

-- The spawngroup variety in vanilla is even worse than I thought, 
-- before Jules came along there were many more different varied groups.
-- They weren't just "rifleman group" or "shotgun group", they were varied groups
-- that were split by tactic and force.
-- I'm throwing away all the old assault tweaks I did and starting anew,
-- using the old spawngroups as a base.
-- I basically just have to adjust the cop amount to fit how strong players currently are,
-- and I have to add medics. Easy.

--[[
2 = N
3 = H
4 = VH
5 = OVK
6 = MH
7 = DW
8 = DS
]]

-- Thanks for the local variable, dickwad
local access_type_walk_only = {
	walk = true
}
local access_type_all = {
	acrobatic = true,
	walk = true
}

-- ENEMY CHATTER
-- Why was this changed to begin with? Most max_nr for specials is now 0. Did they really cut the incoming specials chatter and most other ones too?
-- Jesus christ, no wonder enemies spam the same three lines 50 times in a row
Hooks:PostHook(GroupAITweakData, "_init_chatter_data", "inf_groupaitweak_init_chatter_beta", function(self)
	self.enemy_chatter.aggressive = {
		radius = 1000,
		max_nr = 5,
		duration = {1, 3},
		interval = {2, 5},
		group_min = 3,
		queue = "g90"
	}
	self.enemy_chatter.retreat = {
		radius = 900,
		max_nr = 4,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 3,
		queue = "m01"
	}
	self.enemy_chatter.follow_me = {
		radius = 700,
		max_nr = 2,
		duration = {5, 10},
		interval = {0.75, 1.5},
		group_min = 2,
		queue = "mov"
	}
	self.enemy_chatter.clear = {
		radius = 700,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.75, 1.5},
		group_min = 3,
		queue = "clr"
	}
	self.enemy_chatter.go_go = {
		radius = 700,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.75, 1.2},
		group_min = 0,
		queue = "mov"
	}
	self.enemy_chatter.ready = {
		radius = 700,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.75, 1.2},
		group_min = 3,
		queue = "rdy"
	}
	self.enemy_chatter.smoke = {
		radius = 0,
		max_nr = 2,
		duration = {0, 0},
		interval = {0, 0},
		group_min = 2,
		queue = "d01"
	}
	self.enemy_chatter.flash_grenade = {
		radius = 0,
		max_nr = 2,
		duration = {0, 0},
		interval = {0, 0},
		group_min = 2,
		queue = "d02"
	}
	self.enemy_chatter.incomming_tank = {
		radius = 1500,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.5, 1},
		group_min = 0,
		queue = "bdz"
	}
	self.enemy_chatter.incomming_spooc = {
		radius = 1200,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.5, 1},
		group_min = 0,
		queue = "clk"
	}
	self.enemy_chatter.incomming_shield = {
		radius = 1500,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.5, 1},
		group_min = 0,
		queue = "shd"
	}
	self.enemy_chatter.incomming_taser = {
		radius = 1500,
		max_nr = 2,
		duration = {60, 60},
		interval = {0.5, 1},
		group_min = 0,
		queue = "tsr"
	}
end)

-- UNIT CATEGORIES
-- Fix all kinds of different messes Overkill made, including mis-spelled unit names or wrong crashy unit paths.
-- Also add more enemy variety such as blue SWATs and whiteheads on higher difficulties
-- New difficulties should supplement forces and not replace them in a sea of grey
-- Also the Blue SWAT shotgunners just look sick and it would be a waste to restrict them to lower difficulties
Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "inf_groupaitweak_initunitcategories_beta", function(self, difficulty_index)
    -- Forgot why this was necessary, random missing halloween cop
	table.insert(self.unit_categories.CS_cop_C45_R870.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"))

	-- Overkill made yet another typo which crashes the game on Federales heists, fixing it by setting the Federales FBI groups to be identical to America
	self.unit_categories.FBI_suit_C45_M4.unit_types.federales = self.unit_categories.FBI_suit_C45_M4.unit_types.america
	self.unit_categories.FBI_suit_M4_MP5.unit_types.federales = self.unit_categories.FBI_suit_M4_MP5.unit_types.america
	-- Same with murkywater
	self.unit_categories.FBI_suit_C45_M4.unit_types.murkywater = self.unit_categories.FBI_suit_C45_M4.unit_types.america
	self.unit_categories.FBI_suit_M4_MP5.unit_types.murkywater = self.unit_categories.FBI_suit_M4_MP5.unit_types.america

	-- Re-add Benelli and UMP GenSec greys on Mayhem/DW/DS
	if difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.FBI_swat_M4.unit_types.america = {
			Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
			Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
		}

		self.unit_categories.FBI_swat_R870.unit_types.america = {
			Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
			Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
		}
	elseif difficulty_index >= 8 then
		self.unit_categories.FBI_swat_M4.unit_types.america = {
			Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
			Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
			Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat")
		}

		self.unit_categories.FBI_swat_R870.unit_types.america = {
			Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
			Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
			Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat")
		}
	end

	-- Add skulldozers to Overkill if that's enabled
	if difficulty_index == 5 and InFmenu.settings.skulldozersahoy then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249")
				}
			},
			access = access_type_all
		}
	end

	-- Get rid of the retarded minigun meme dozers on DW and DS, thanks
	if difficulty_index >= 6 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249")
				}
			},
			access = access_type_all
		}
	end

    -- Give ZEAL shotgunners their deserved R870's
	if difficulty_index >= 8 then
		self.unit_categories.FBI_heavy_R870.primary_weapon_override = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
		self.unit_categories.FBI_swat_R870.primary_weapon_override = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
	end
end)





-- SPAWNGROUPS
-- The big one
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "inf_groupaitweak_initenemyspawngroups_beta", function(self, difficulty_index)
    -- First of all, fuck off
    self.enemy_spawn_groups = {}
	
	-- Huge list of tactics, blabla
	self._tactics = {
		Phalanx_minion = {
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield",
			"deathguard"
		},
		Phalanx_vip = {
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield",
			"deathguard"
		},
		CS_cop = {
			"provide_coverfire",
			"provide_support",
			"ranged_fire"
		},
		CS_cop_stealth = {
			"flank",
			"provide_coverfire",
			"provide_support"
		},
		CS_swat_rifle = {
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"ranged_fire",
			"deathguard"
		},
		CS_swat_shotgun = {
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield_cover"
		},
		CS_swat_heavy = {
			"smoke_grenade",
			"charge",
			"flash_grenade",
			"provide_coverfire",
			"provide_support"
		},
		CS_shield = {
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield",
			"deathguard"
		},
		CS_swat_rifle_flank = {
			"flank",
			"flash_grenade",
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support"
		},
		CS_swat_shotgun_flank = {
			"flank",
			"flash_grenade",
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support"
		},
		CS_swat_heavy_flank = {
			"flank",
			"flash_grenade",
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield_cover"
		},
		CS_shield_flank = {
			"flank",
			"charge",
			"flash_grenade",
			"provide_coverfire",
			"provide_support",
			"shield"
		},
		CS_tazer = {
			"flank",
			"charge",
			"flash_grenade",
			"shield_cover",
			"murder"
		},
		CS_sniper = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		FBI_suit = {
			"flank",
			"ranged_fire",
			"flash_grenade"
		},
		FBI_suit_stealth = {
			"provide_coverfire",
			"provide_support",
			"flash_grenade",
			"flank"
		},
		FBI_swat_rifle = {
			"smoke_grenade",
			"flash_grenade",
			"provide_coverfire",
			"charge",
			"provide_support",
			"ranged_fire"
		},
		FBI_swat_shotgun = {
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support"
		},
		FBI_heavy = {
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield_cover",
			"deathguard"
		},
		FBI_shield = {
			"smoke_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield",
			"deathguard"
		},
		FBI_swat_rifle_flank = {
			"flank",
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support"
		},
		FBI_swat_shotgun_flank = {
			"flank",
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support"
		},
		FBI_heavy_flank = {
			"flank",
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield_cover"
		},
		FBI_shield_flank = {
			"flank",
			"smoke_grenade",
			"flash_grenade",
			"charge",
			"provide_coverfire",
			"provide_support",
			"shield"
		},
		FBI_tank = {
			"charge",
			"deathguard",
			"shield_cover",
			"smoke_grenade"
		},
		spooc = {
			"charge",
			"shield_cover",
			"smoke_grenade",
			"flash_grenade"
		}
	}

    -- Mostly copied from U87 but it works
	self.enemy_spawn_groups.CS_defend_a = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 1,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.CS_defend_b = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.CS_defend_c = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.CS_cops = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.CS_stealth_a = {
		amount = {2, 3},
		spawn = {
			{
				unit = "CS_cop_stealth_MP5",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.CS_swats = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 1,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_swat_R870",
				freq = 0.5,
				amount_max = 2,
				tactics = self._tactics.CS_swat_shotgun,
				rank = 1
			},
			{
				unit = "CS_swat_MP5",
				freq = 0.33,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			},
			{
				unit = "medic_M4",
				freq = 0.1,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}
	self.enemy_spawn_groups.CS_heavys = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 1,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_heavy_M4",
				freq = 0.35,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			},
			{
				unit = "medic_R870",
				freq = 0.1,
				tactics = self._tactics.CS_swat_shotgun,
				rank = 3
			}
		}
	}
	self.enemy_spawn_groups.CS_shields = {
		amount = {3, 4},
		spawn = {
			{
				unit = "CS_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 2,
				tactics = self._tactics.CS_shield,
				rank = 3
			},
			{
				unit = "CS_cop_stealth_MP5",
				freq = 0.5,
				amount_max = 1,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			},
			{
				unit = "CS_heavy_M4_w",
				freq = 0.75,
				amount_max = 1,
				tactics = self._tactics.CS_swat_heavy,
				rank = 2
			}
		}
	}
	if difficulty_index < 6 then
		self.enemy_spawn_groups.CS_tazers = {
			amount = {1, 3},
			spawn = {
				{
					unit = "CS_tazer",
					freq = 1,
					amount_min = 1,
					amount_max = 1,
					tactics = self._tactics.CS_tazer,
					rank = 2
				},
				{
					unit = "CS_swat_MP5",
					freq = 1,
					amount_max = 2,
					tactics = self._tactics.CS_cop_stealth,
					rank = 1
				}
			}
		}
	else
		self.enemy_spawn_groups.CS_tazers = {
			amount = {4, 4},
			spawn = {
				{
					unit = "CS_tazer",
					freq = 1,
					amount_min = 3,
					tactics_ = self._tactics.CS_tazer,
					rank = 1
				},
				{
					unit = "FBI_shield",
					freq = 1,
					amount_min = 2,
					amount_max = 3,
					tactics = self._tactics.FBI_shield,
					rank = 3
				},
				{
					unit = "FBI_heavy_G36",
					freq = 1,
					amount_max = 2,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 1
				}
			}
		}
	end
	self.enemy_spawn_groups.CS_tanks = {
		amount = {1, 2},
		spawn = {
			{
				unit = "FBI_tank",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.FBI_tank,
				rank = 2
			},
			{
				unit = "CS_tazer",
				freq = 0.5,
				amount_max = 1,
				tactics = self._tactics.CS_tazer,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_defend_a = {
		amount = {3, 3},
		spawn = {
			{
				unit = "FBI_suit_C45_M4",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "CS_cop_C45_R870",
				freq = 1,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_defend_b = {
		amount = {3, 3},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "FBI_swat_M4",
				freq = 1,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_defend_c = {
		amount = {3, 3},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 1,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_defend_d = {
		amount = {2, 3},
		spawn = {
			{
				unit = "FBI_heavy_G36",
				freq = 1,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_stealth_a = {
			amount = {2, 3},
			spawn = {
				{
					unit = "FBI_suit_stealth_MP5",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 1
				},
				{
					unit = "CS_tazer",
					freq = 1,
					amount_max = 2,
					tactics = self._tactics.CS_tazer,
					rank = 2
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_stealth_a = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_suit_stealth_MP5",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 2
				},
				{
					unit = "CS_tazer",
					freq = 1,
					amount_max = 2,
					tactics = self._tactics.CS_tazer,
					rank = 1
				}
			}
		}
	end
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_stealth_b = {
			amount = {2, 3},
			spawn = {
				{
					unit = "FBI_suit_stealth_MP5",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 1
				},
				{
					unit = "FBI_suit_M4_MP5",
					freq = 0.75,
					tactics = self._tactics.FBI_suit,
					rank = 2
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_stealth_b = {
			amount = {4, 4},
			spawn = {
				{
					unit = "FBI_suit_stealth_MP5",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 1
				},
				{
					unit = "FBI_suit_M4_MP5",
					freq = 0.75,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 2
				}
			}
		}
	end
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_swats = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_swat_M4",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 2
				},
				{
					unit = "FBI_swat_M4",
					freq = 0.75,
					tactics = self._tactics.FBI_swat_rifle_flank,
					rank = 3
				},
				{
					unit = "FBI_swat_R870",
					freq = 0.5,
					amount_max = 2,
					tactics = self._tactics.FBI_swat_shotgun,
					rank = 1
				},
				{
					unit = "spooc",
					freq = 0.15,
					amount_max = 2,
					tactics = self._tactics.spooc,
					rank = 1
				},
				{
					unit = "medic_M4",
					freq = 0.2,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 3
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_swats = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_swat_M4",
					freq = 1,
					amount_min = 3,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 1
				},
				{
					unit = "FBI_suit_M4_MP5",
					freq = 1,
					tactics = self._tactics.FBI_swat_rifle_flank,
					rank = 2
				},
				{
					unit = "FBI_swat_R870",
					amount_min = 2,
					freq = 1,
					tactics = self._tactics.FBI_swat_shotgun,
					rank = 3
				},
				{
					unit = "spooc",
					freq = 0.1,
					amount_max = 2,
					tactics = self._tactics.spooc,
					rank = 1
				},
				{
					unit = "medic_M4",
					freq = 0.2,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 3
				}
			}
		}
	end
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_heavys = {
			amount = {2, 3},
			spawn = {
				{
					unit = "FBI_heavy_G36",
					freq = 1,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 1
				},
				{
					unit = "FBI_heavy_G36",
					freq = 0.75,
					tactics = self._tactics.FBI_swat_rifle_flank,
					rank = 2
				},
				{
					unit = "CS_tazer",
					freq = 0.25,
					amount_max = 1,
					tactics = self._tactics.CS_tazer,
					rank = 3
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_heavys = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_heavy_G36_w",
					freq = 1,
					amount_min = 4,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 1
				},
				{
					unit = "FBI_swat_M4",
					freq = 1,
					amount_min = 3,
					tactics = self._tactics.FBI_heavy_flank,
					rank = 2
				}
			}
		}
	end
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_shields = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_shield",
					freq = 1,
					amount_min = 1,
					amount_max = 2,
					tactics = self._tactics.FBI_shield_flank,
					rank = 3
				},
				{
					unit = "CS_tazer",
					freq = 0.75,
					amount_max = 1,
					tactics = self._tactics.CS_tazer,
					rank = 2
				},
				{
					unit = "FBI_heavy_G36",
					freq = 0.5,
					amount_max = 1,
					tactics = self._tactics.FBI_swat_rifle_flank,
					rank = 1
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_shields = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_shield",
					freq = 1,
					amount_min = 3,
					amount_max = 4,
					tactics = self._tactics.FBI_shield,
					rank = 3
				},
				{
					unit = "FBI_suit_stealth_MP5",
					freq = 1,
					amount_min = 1,
					tactics = self._tactics.FBI_suit_stealth,
					rank = 1
				},
				{
					unit = "spooc",
					freq = 0.15,
					amount_max = 2,
					tactics = self._tactics.spooc,
					rank = 1
				},
				{
					unit = "CS_tazer",
					freq = 0.75,
					amount_min = 2,
					tactics = self._tactics.CS_swat_heavy,
					rank = 2
				}
			}
		}
	end
	if difficulty_index < 6 then
		self.enemy_spawn_groups.FBI_tanks = {
			amount = {3, 4},
			spawn = {
				{
					unit = "FBI_tank",
					freq = 1,
					amount_max = 1,
					tactics = self._tactics.FBI_tank,
					rank = 1
				},
				{
					unit = "FBI_shield",
					freq = 0.5,
					amount_min = 1,
					amount_max = 2,
					tactics = self._tactics.FBI_shield_flank,
					rank = 3
				},
				{
					unit = "FBI_heavy_G36_w",
					freq = 0.75,
					amount_min = 1,
					tactics = self._tactics.FBI_heavy_flank,
					rank = 1
				},
				{
					unit = "medic_R870",
					freq = 0.2,
					tactics = self._tactics.FBI_swat_shotgun_flank,
					rank = 3
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_tanks = {
			amount = {4, 4},
			spawn = {
				{
					unit = "FBI_tank",
					freq = 1,
					amount_min = 2,
					tactics = self._tactics.FBI_tank,
					rank = 3
				},
				{
					unit = "FBI_shield",
					freq = 1,
					amount_min = 1,
					amount_max = 2,
					tactics = self._tactics.FBI_shield,
					rank = 3
				},
				{
					unit = "CS_tazer",
					freq = 0.75,
					amount_min = 1,
					tactics = self._tactics.FBI_swat_rifle,
					rank = 2
				},
				{
					unit = "medic_R870",
					freq = 0.2,
					tactics = self._tactics.FBI_swat_shotgun,
					rank = 3
				}
			}
		}
	end
	self.enemy_spawn_groups.single_spooc = {
		amount = {1, 1},
		spawn = {
			{
				unit = "spooc",
				freq = 1,
				amount_min = 1,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_spoocs = self.enemy_spawn_groups.single_spooc

	-- Required Winters bullshit
	self.enemy_spawn_groups.Phalanx = {
		amount = {
			self.phalanx.minions.amount + 1,
			self.phalanx.minions.amount + 1
		},
		spawn = {
			{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 2,
				unit = "Phalanx_vip",
				tactics = self._tactics.Phalanx_vip
			},
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "Phalanx_minion",
				tactics = self._tactics.Phalanx_minion
			}
		}
	}

end)


-- TASK DATA
-- Defines which group actually spawns when. It also defines assault delays etc.
-- This one has a ton of difficulty-specific code so let's split that up into functions
Hooks:PostHook(GroupAITweakData, "_init_task_data", "inf_groupaitweak_inittaskdata_beta", function(self, difficulty_index, difficulty)
	if difficulty_index <= 2 then
		self:inf_init_taskdata_normal()
	elseif difficulty_index == 3 then
		self:inf_init_taskdata_hard()
	elseif difficulty_index == 4 then
		self:inf_init_taskdata_veryhard()
	elseif difficulty_index == 5 then
		self:inf_init_taskdata_overkill()
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self:inf_init_taskdata_mayhem_deathwish()
	else
		self:inf_init_taskdata_deathsentence()
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

	-- Base assault values, how many cops are allowed on the map and how big is the spawnpool
	-- Increases for each assault
	self.besiege.assault.force = {
		10,
		13,
		16
	}
	-- Total max cop spawns per assault
	self.besiege.assault.force_pool = {
		10,
		30,
		50
	}

	-- Cloaker-specific spawns
	self.besiege.cloaker.groups = {
		single_spooc = {
			1,
			1,
			1
		}
	}
	-- Wtf is this?
	self.street = deep_clone(self.besiege)
end)

function GroupAITweakData:inf_init_taskdata_normal()
	self.besiege.assault.groups = {
		CS_swats = {
			0,
			1,
			0.85
		},
		CS_shields = {
			0,
			0,
			0.15
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.reenforce.groups = {
		CS_defend_a = {
			1,
			0.2,
			0
		},
		CS_defend_b = {
			0,
			1,
			1
		}
	}

	self.besiege.recon.groups = {
		CS_stealth_a = {
			1,
			1,
			0
		},
		CS_swats = {
			0,
			1,
			1
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.assault.delay = {
		90,
		80,
		70
	}

	self.besiege.assault.force_balance_mul = {
		0.9,
		1.5,
		2,
		2.25
	}
	self.besiege.assault.force_pool_balance_mul = {
		1,
		1.5,
		2,
		3
	}
end

function GroupAITweakData:inf_init_taskdata_hard()
	self.besiege.assault.groups = {
		CS_swats = {
			0,
			1,
			0
		},
		CS_heavys = {
			0,
			0.2,
			0.7
		},
		CS_shields = {
			0,
			0.02,
			0.2
		},
		CS_tazers = {
			0,
			0.05,
			0.15
		},
		CS_tanks = {
			0,
			0.01,
			0.05
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.reenforce.groups = {
		CS_defend_a = {
			1,
			0,
			0
		},
		CS_defend_b = {
			2,
			1,
			0
		},
		CS_defend_c = {
			0,
			0,
			1
		}
	}

	self.besiege.recon.groups = {
		CS_stealth_a = {
			1,
			0,
			0
		},
		CS_swats = {
			0,
			1,
			1
		},
		CS_tazers = {
			0,
			0.1,
			0.15
		},
		FBI_stealth_b = {
			0,
			0,
			0.1
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.assault.delay = {
		85,
		75,
		65
	}

	self.besiege.assault.force_balance_mul = {
		1,
		1.4,
		1.6,
		1.9
	}
	self.besiege.assault.force_pool_balance_mul = {
		1.2,
		1.5,
		2,
		3
	}
end

function GroupAITweakData:inf_init_taskdata_veryhard()
	self.besiege.assault.groups = {
		CS_swats = {
			0.1,
			0.1,
			0.1
		},
		CS_heavys = {
			0.1,
			0.2,
			0.4
		},
		CS_shields = {
			0.0,
			0.02,
			0.1
		},
		FBI_swats = {
			0.1,
			1,
			1
		},
		FBI_heavys = {
			0.05,
			0.25,
			0.5
		},
		FBI_shields = {
			0.1,
			0.2,
			0.2
		},
		FBI_tanks = {
			0,
			0.1,
			0.15
		},
		FBI_spoocs = {
			0,
			0.1,
			0.2
		},
		CS_tazers = {
			0.05,
			0.15,
			0.2
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.reenforce.groups = {
		CS_defend_a = {
			1,
			0,
			0
		},
		CS_defend_b = {
			1.5,
			1,
			0
		},
		CS_defend_c = {
			0,
			0,
			1
		},
		FBI_defend_a = {
			0,
			1,
			0
		},
		FBI_defend_b = {
			0,
			0,
			1
		}
	}

	self.besiege.recon.groups = {
		FBI_stealth_a = {
			1,
			0.5,
			0
		},
		FBI_stealth_b = {
			0,
			0,
			1
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.assault.delay = {
		80,
		70,
		60
	}

	self.besiege.assault.force_balance_mul = {
		1.4,
		1.8,
		2,
		2.4
	}
	self.besiege.assault.force_pool_balance_mul = {
		1.7,
		2,
		2.5,
		3
	}
end

function GroupAITweakData:inf_init_taskdata_overkill()
	self.besiege.assault.groups = {
		CS_swats = {
			0.1,
			0.1,
			0.1
		},
		CS_heavys = {
			0.1,
			0.1,
			0.25
		},
		CS_shields = {
			0.02,
			0.02,
			0.01
		},
		FBI_swats = {
			0.2,
			1,
			1
		},
		FBI_heavys = {
			0.1,
			0.5,
			0.75
		},
		FBI_shields = {
			0.1,
			0.3,
			0.4
		},
		FBI_tanks = {
			0,
			0.25,
			0.3
		},
		CS_tazers = {
			0.1,
			0.25,
			0.25
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.reenforce.groups = {
		CS_defend_a = {
			0.1,
			0,
			0
		},
		FBI_defend_b = {
			1,
			1,
			0
		},
		FBI_defend_c = {
			0,
			1,
			0
		},
		FBI_defend_d = {
			0,
			0,
			1
		}
	}

	self.besiege.recon.groups = {
		FBI_stealth_a = {
			0.5,
			1,
			1
		},
		FBI_stealth_b = {
			0.25,
			0.5,
			1
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.assault.delay = {
		65,
		55,
		50
	}

	self.besiege.assault.force_balance_mul = {
		2,
		2.5,
		2.9,
		3.2
	}
	self.besiege.assault.force_pool_balance_mul = {
		2,
		2.5,
		3,
		3.5
	}
end

function GroupAITweakData:inf_init_taskdata_mayhem_deathwish()
	self.besiege.assault.groups = {
		CS_swats = {
			0.15,
			0.1,
			0.08
		},
		CS_heavys = {
			0.1,
			0.1,
			0.1
		},
		CS_shields = {
			0.05,
			0.02,
			0.01
		},
		FBI_swats = {
			0.2,
			0.8,
			0.8
		},
		FBI_heavys = {
			0.1,
			0.3,
			0.4
		},
		FBI_shields = {
			0.1,
			0.5,
			0.4
		},
		FBI_tanks = {
			0.1,
			0.5,
			0.5
		},
		CS_tazers = {
			0.1,
			0.5,
			0.45
		},
		FBI_spoocs = {
			0,
			0.45,
			0.45
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.reenforce.groups = {
		CS_defend_a = {
			0.25,
			0.2,
			0
		},
		FBI_defend_b = {
			1,
			1,
			0
		},
		FBI_defend_c = {
			0,
			1,
			0
		},
		FBI_defend_d = {
			0,
			0,
			1
		}
	}

	self.besiege.recon.groups = {
		FBI_stealth_a = {
			0.5,
			1,
			1
		},
		FBI_stealth_b = {
			0.25,
			0.5,
			1
		},
		single_spooc = {
			0,
			0,
			0
		}
	}

	self.besiege.assault.delay = {
		50,
		45,
		40
	}

	self.besiege.assault.force_balance_mul = {
		4.2,
		4.5,
		4.9,
		5.4
	}
	self.besiege.assault.force_pool_balance_mul = {
		2.2,
		2.8,
		3.3,
		3.8
	}
end

function GroupAITweakData:inf_init_taskdata_deathsentence()
	self:inf_init_taskdata_mayhem_deathwish()

	self.besiege.assault.delay = {
		40,
		35,
		30
	}
end

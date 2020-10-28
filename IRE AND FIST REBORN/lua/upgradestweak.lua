dofile(ModPath .. "infcore.lua")

-- If sydch's skill overhaul is enabled then don't touch a lot of the skills and decks
if IreNFist.mod_compatibility.sso then

else
	-- These values are only for if SSO is explicitly *not* enabled. For values that apply to both cases, they're further down
	Hooks:PostHook(UpgradesTweakData, "init", "inf_fuckyourskills", function(self, params)
		--self.skill_descs.shotgun_cqb.multibasic2 = "10%"
		--self.skill_descs.shotgun_cqb.multipro = "20%"

		-- overkill
		self.skill_descs.overkill.multibasic = "20%"
		self.skill_descs.overkill.multibasic2 = "10"

		-- trigger happy
		self.skill_descs.trigger_happy.multibasic4 = "20%" -- damage bonus
		self.skill_descs.trigger_happy.multibasic2 = "2" -- lasts x seconds
		self.skill_descs.trigger_happy.multibasic3 = "2" -- stacks x times
		self.skill_descs.trigger_happy.multipro2 = "15" -- lasts x seconds

		-- pumping iron
		self.values.player.non_special_melee_multiplier = {1.50}
		self.values.player.melee_damage_multiplier = {1.50}

		-- martial artist
		--self.values.player.melee_knockdown_mul = {1.5}

		-- berserker
		self.skill_descs.wolverine.multipro2 = "50%"

		-- Rogue dodge bonus #4
		-- Definition made it into the game but the value didn't, time to fix that for rogue
		self.values.player.passive_dodge_chance[4] = 0.55

		-- Rogue general weapon penetration bonus
		self.values.weapon.all_pierce_enemies = {true}

		-- Counter-Strike counter arrest
		self.values.player.counter_arrest = {true}

		-- Sprint with any bag
		self.values.player.sprint_any_bag = {true}

		-- Advanced movement (walljump, run, cling) breaks fall
		self.values.player.adv_movement_breaks_fall = {true}

		-- Pager snatching
		self.values.player.inf_snatch_pager = {true}
	end)

	Hooks:PostHook(UpgradesTweakData, "_init_pd2_values", "inf_fuckyourskills2", function(self, params)
		-- STOP JUMPING MY SCREEN AROUND
		if not IreNFist.mod_compatibility.armor_overhaul then
			self.values.player.body_armor.damage_shake = {0.40, 0.35, 0.30, 0.25, 0.20, 0.15, 0.10}
		end

		-- walk slower with coolguy weapons
		self.weapon_movement_penalty.minigun = 0.70
		self.weapon_movement_penalty.lmg = 0.85

		-- fully loaded aced
		self.values.player.regain_throwable_from_ammo = {{
			chance = 0.05,
			chance_inc = 0.01 -- now additive
		}}

		-- overkill
		self.values.temporary.overkill_damage_multiplier = {{1.20,10}}

		-- gunslinger
		--self.values.pistol.damage_addend = {0.5, 1.0}

		-- trigger happy
		self.values.pistol.stacking_hit_damage_multiplier = {
			{max_stacks = 2, max_time = 2, damage_bonus = 1.20},
			{max_stacks = 2, max_time = 15, damage_bonus = 1.20}
		}

		-- akimbo ammo
		--self.values.akimbo.extra_ammo_multiplier = {1.25, 1.50}

		-- sociopath/infiltrator OVERDOG
		self.values.melee.stacking_hit_damage_multiplier = {2, 2}
		--self.values.melee.stacking_hit_expire_t = {5}

		-- bloodthirst
		self.values.player.melee_damage_stacking = {{max_multiplier = 3, melee_multiplier = 0.25}}
		self.values.player.melee_kill_increase_reload_speed = {{1.25, 5}}

		-- marksman acc bonus
		self.values.weapon.single_spread_index_addend = {10}

		-- headshot bonus damage
		self.values.weapon.passive_headshot_damage_multiplier = {1.175}

		-- steady grip
		self.values.player.stability_increase_bonus_1 = {2}
		self.values.player.stability_increase_bonus_2 = {2}

		-- saw shit
		self.values.saw.enemy_slicer = {1}

		-- berserker
		--self.values.player.melee_damage_health_ratio_multiplier = {2.5}
		self.values.player.damage_health_ratio_multiplier = {0.50} -- 150%

		-- Moving Target
		self.values.player.detection_risk_add_movement_speed = {
			{
				0.02,
				3,
				"below",
				35,
				0.2
			},
			{
				0.02,
				1,
				"below",
				35,
				0.2
			}
		}


		-- AI crew bonuses
		self.values.team.crew_faster_reload = {1.25}
		self.values.team.crew_faster_swap = {1.25}
		self.values.team.crew_add_stamina = {25}
		self.values.team.crew_reduce_speed_penalty = {0.75}
		--self.values.team.crew_interact = {{0.75,0.5,0.25}}


		-- InF skills
		self.values.player.imma_chargin_mah_melee = {2}


		self.values.player.ugh_its_a_reload_bonus = {1.05, 1.10}

		
		self.values.player.pistol_base_switchspeed_add = {0.05, 0.10}
		self.values.player.slide_dodge_addend = {0.10}

		

		self.values.shotgun.damage_addend = {1.5, 2.5}

		

		-- Add extra ammo to the flak jacket *only*
		-- Has overlap with armor overhaul and with SSO, and is therefore disabled if either are present
		if not IreNFist.mod_compatibility.armor_overhaul then
			self.values.player.body_armor.skill_ammo_mul = {
				1,
				1,
				1,
				1,
				1.5,
				1,
				1
			}
		end

		-- Remove ammo pickup bonus from walk in closet
		-- Also nerf fully loaded aced from 1.75x to 1.5x
		self.values.player.pick_up_ammo_multiplier = {
			1,
			1.5
		}

		-- Inspire now has a 60sec cooldown instead of 20
		-- TODO: make the skill work from bleedout. Would that be fun? Maybe.
		self.values.cooldown.long_dis_revive = {
			{
				1,
				60
			}
		}
	end)

	Hooks:PostHook(UpgradesTweakData, "_player_definitions", "gonnamakemyownskills", function(self, params)	
		self.definitions.imma_chargin_mah_melee = {
			category = "feature",
			name_id = "imma_chargin_mah_melee",
			upgrade = {
				category = "player",
				upgrade = "imma_chargin_mah_melee",
				value = 1
			}
		}

		self.definitions.weapon_all_pierce_enemies = {
			name_id = "menu_weapon_all_pierce_enemies",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "all_pierce_enemies",
				category = "weapon"
			}
		}	
	
		self.definitions.ugh_its_a_reload_bonus = {
			category = "feature",
			name_id = "ugh_its_a_reload_bonus",
			upgrade = {
				category = "player",
				upgrade = "ugh_its_a_reload_bonus",
				value = 1
			}
		}
		self.definitions.ugh_its_a_reload_bonus_2 = {
			category = "feature",
			name_id = "ugh_its_a_reload_bonus",
			upgrade = {
				category = "player",
				upgrade = "ugh_its_a_reload_bonus",
				value = 2
			}
		}	
	
		self.definitions.shotgun_damage_addend = {
			name_id = "shotgun_damage_addend",
			category = "feature",
			upgrade = {
				value = 1,
				category = "shotgun",
				upgrade = "damage_addend"
			}
		}
		self.definitions.shotgun_damage_addend_2 = {
			name_id = "shotgun_damage_addend",
			category = "feature",
			upgrade = {
				value = 2,
				category = "shotgun",
				upgrade = "damage_addend"
			}
		}
	
	
		self.definitions.pistol_base_switchspeed_add = {
			category = "feature",
			name_id = "pistol_base_switchspeed_add",
			upgrade = {
				category = "player",
				upgrade = "pistol_base_switchspeed_add",
				value = 1
			}
		}
		self.definitions.pistol_base_switchspeed_add_2 = {
			category = "feature",
			name_id = "pistol_base_switchspeed_add",
			upgrade = {
				category = "player",
				upgrade = "pistol_base_switchspeed_add",
				value = 2
			}
		}
	
		self.definitions.slide_dodge_chance = {
			name_id = "slide_dodge_chance",
			category = "feature",
			upgrade = {
				category = "player",
				upgrade = "slide_dodge_addend",
				value = 1
			}
		}
	
		self.definitions.player_detection_risk_add_movement_speed_1 = {
			category = "feature",
			name_id = "menu_player_detection_risk_add_movement_speed",
			upgrade = {
				category = "player",
				upgrade = "detection_risk_add_movement_speed",
				value = 1
			}
		}
	
		self.definitions.player_detection_risk_add_movement_speed_2 = {
			category = "feature",
			name_id = "menu_player_detection_risk_add_movement_speed",
			upgrade = {
				category = "player",
				upgrade = "detection_risk_add_movement_speed",
				value = 2
			}
		}

		self.definitions.player_counter_arrest = {
			category = "feature",
			name_id = "menu_player_counter_arrest",
			upgrade = {
				category = "player",
				upgrade = "counter_arrest",
				value = 1
			}
		}

		-- Transporter, sprint with any bag
		self.definitions.player_sprint_any_bag = {
			category = "feature",
			name_id = "menu_player_sprint_any_bag",
			upgrade = {
				category = "player",
				upgrade = "sprint_any_bag",
				value = 1
			}
		}

		-- Advanced movement breaks your fall
		self.definitions.player_adv_movement_breaks_fall = {
			category = "feature",
			name_id = "menu_player_adv_movement_breaks_fall",
			upgrade = {
				category = "player",
				upgrade = "adv_movement_breaks_fall",
				value = 1
			}
		}

		-- Snatch pagers on melee kill
		self.definitions.player_inf_snatch_pager = {
			category = "feature",
			name_id = "menu_player_inf_snatch_pager",
			upgrade = {
				category = "player",
				upgrade = "inf_snatch_pager",
				value = 1
			}
		}

	end)
end

-- Upgrade values that should always exist regardless of mod compatibility
Hooks:PostHook(UpgradesTweakData, "init", "inf_upgradestweak_upgradevalues_always", function(self)
	
	-- Remove all akimbo stability bonuses
	self.values.akimbo.recoil_index_addend = {0, 0, 0, 0, 0}

	-- pistol reload
	self.values.pistol.reload_speed_multiplier = {1.20}

	-- shotgun reload
	self.values.shotgun.reload_speed_multiplier = {1.10, 1.20}

	-- Sniper headshot armor regain
	self.values.player.snp_headshot_armor = {0.5, 5.0}

	-- Sniper headshot ammo regain
	self.values.player.head_shot_ammo_return = {
		{
			headshots = 3,
			ammo = 1,
			time = 6
		},
		{
			headshots = 2,
			ammo = 1,
			time = 12
		}
	}

	self.values.player.advmov_stamina_on_kill = {2, 4}
	self.values.player.pellet_penalty_reduction = {0.25, 0.50}
	self.values.player.shotgun_switchspeed_buff = {1.30}
	self.values.player.shotgun_last_shell_amount = {1, 2}
	self.values.player.shotgun_last_shell_dmg_mult = {2}

	self.values.player.bipod_deploy_speed_mult = {2}
	self.values.player.bipod_dmg_taken_mult = {0.50}
	self.values.player.locknload_reload = {1.25}
	self.values.player.locknload_reload_partial = {1.25}
	self.values.player.recoil_h_mult = {0.90, 0.70}

	self.values.player.pistol_switchspeed_buff = {1.15, 1.30}
	self.values.player.empty_akimbo_switch = {1.20}
	self.values.player.empty_akimbo_reload = {1.15}
	self.values.pistol.enter_steelsight_speed_multiplier = {2}
	self.values.player.offhand_reload_time_mult = {4.0, 3.0}
	self.values.player.pistol_gives_offhand_reload = {true}
	self.values.player.ar_gives_offhand_reload = {true}
	self.values.player.smg_gives_offhand_reload = {true}
	self.values.player.shotgun_gives_offhand_reload = {true}
	self.values.player.xbow_gives_offhand_reload = {true}

	-- Taser bullets
	self.values.player.electric_bullets_while_tased = {true}

	-- Enabling holdout/bunker
	self.values.player.holdout_consecutive_kills = {true}

	self.values.weapon.lmg_pierce_enemies = {true}
end)

-- Same as above but for init PD2 values
Hooks:PostHook(UpgradesTweakData, "_init_pd2_values", "inf_upgradestweak_pd2values_always", function(self, params)
	-- Bunker/Holdout minimum distance for activating the health regen
	-- For reference, self.close_combat_distance = 1800
	self.holdout_distant_kill_min_distance = 1200
	-- Maximum distance for the close-range version of the regen instead, which regenerates armor
	self.holdout_close_kill_max_distance = 1200

	-- Displayed health and armor ingame is x10 its actual value, so this is 10 and 20
	self.values.player.holdout_distant_kill_health_regen = {
		1,
		2
	}
	-- Close-by armor regen
	self.values.player.holdout_close_kill_armor_regen = {
		1,
		2
	}

	-- How many kills are required inside a newly dropped zone to activate it
	self.values.player.holdout_killcount = {
		3,
		2
	}

	-- Every X kills, you get an extra ammo drop from a kill inside a zone, where X is the upgrade value
	self.values.player.holdout_consecutive_kill_ammo = {
		10
	}

	-- Defines the cooldown for the health/armor regen effect
	self.values.player.holdout_regen_cooldown = {
		5,
		3
	}

	-- Damage reduction when inside your zone
	self.values.player.holdout_dmg_reduction = {
		0.88
	}
end)

-- Player upgrade definitions that should always exist regardless of mod compatibility
Hooks:PostHook(UpgradesTweakData, "_player_definitions", "inf_upgradestweak_playerdefs_always", function(self)
	self.definitions.snp_headshot_armor = {
		category = "feature",
		name_id = "snp_headshot_armor",
		upgrade = {
			category = "player",
			upgrade = "snp_headshot_armor",
			value = 1
		}
	}
	self.definitions.snp_headshot_armor_2 = {
		category = "feature",
		name_id = "snp_headshot_armor",
		upgrade = {
			category = "player",
			upgrade = "snp_headshot_armor",
			value = 2
		}
	}

	self.definitions.head_shot_ammo_return_1 = {
		incremental = true,
		name_id = "menu_head_shot_ammo_return_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "head_shot_ammo_return",
			category = "player"
		}
	}
	self.definitions.head_shot_ammo_return_2 = {
		incremental = true,
		name_id = "menu_head_shot_ammo_return_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "head_shot_ammo_return",
			category = "player"
		}
	}

	self.definitions.advmov_stamina_on_kill = {
		category = "feature",
		name_id = "advmov_stamina_on_kill",
		upgrade = {
			category = "player",
			upgrade = "advmov_stamina_on_kill",
			value = 1
		}
	}
	self.definitions.advmov_stamina_on_kill_2 = {
		category = "feature",
		name_id = "advmov_stamina_on_kill",
		upgrade = {
			category = "player",
			upgrade = "advmov_stamina_on_kill",
			value = 2
		}
	}

	self.definitions.player_electric_bullets_while_tased = {
		category = "feature",
		name_id = "menu_player_electric_bullets_while_tased",
		upgrade = {
			category = "player",
			upgrade = "electric_bullets_while_tased",
			value = 1
		}
	}

	self.definitions.pellet_penalty_reduction = {
		category = "feature",
		name_id = "pellet_penalty_reduction",
		upgrade = {
			category = "player",
			upgrade = "pellet_penalty_reduction",
			value = 1
		}
	}
	self.definitions.pellet_penalty_reduction_2 = {
		category = "feature",
		name_id = "pellet_penalty_reduction",
		upgrade = {
			category = "player",
			upgrade = "pellet_penalty_reduction",
			value = 2
		}
	}

	self.definitions.shotgun_switchspeed_buff = {
		category = "feature",
		name_id = "shotgun_switchspeed_buff",
		upgrade = {
			category = "player",
			upgrade = "shotgun_switchspeed_buff",
			value = 1
		}
	}

	self.definitions.shotgun_last_shell_amount = {
		category = "feature",
		name_id = "shotgun_last_shell_amount",
		upgrade = {
			category = "player",
			upgrade = "shotgun_last_shell_amount",
			value = 1
		}
	}
	self.definitions.shotgun_last_shell_amount_2 = {
		category = "feature",
		name_id = "shotgun_last_shell_amount",
		upgrade = {
			category = "player",
			upgrade = "shotgun_last_shell_amount",
			value = 2
		}
	}
	self.definitions.shotgun_last_shell_dmg_mult = {
		category = "feature",
		name_id = "shotgun_last_shell_dmg_mult",
		upgrade = {
			category = "player",
			upgrade = "shotgun_last_shell_dmg_mult",
			value = 1
		}
	}


	self.definitions.bipod_deploy_speed_mult = {
		category = "feature",
		name_id = "bipod_deploy_speed_mult",
		upgrade = {
			category = "player",
			upgrade = "bipod_deploy_speed_mult",
			value = 1
		}
	}
	self.definitions.bipod_dmg_taken_mult = {
		category = "feature",
		name_id = "bipod_dmg_taken_mult",
		upgrade = {
			category = "player",
			upgrade = "bipod_dmg_taken_mult",
			value = 1
		}
	}

	self.definitions.locknload_reload = {
		category = "feature",
		name_id = "locknload_reload",
		upgrade = {
			category = "player",
			upgrade = "locknload_reload",
			value = 1
		}
	}
	self.definitions.locknload_reload_partial = {
		category = "feature",
		name_id = "locknload_reload_partial",
		upgrade = {
			category = "player",
			upgrade = "locknload_reload_partial",
			value = 1
		}
	}

	self.definitions.recoil_h_mult = {
		category = "feature",
		name_id = "recoil_h_mult",
		upgrade = {
			category = "player",
			upgrade = "recoil_h_mult",
			value = 1
		}
	}
	self.definitions.recoil_h_mult_2 = {
		category = "feature",
		name_id = "recoil_h_mult",
		upgrade = {
			category = "player",
			upgrade = "recoil_h_mult",
			value = 2
		}
	}


	self.definitions.pistol_switchspeed_buff = {
		category = "feature",
		name_id = "pistol_switchspeed_buff",
		upgrade = {
			category = "player",
			upgrade = "pistol_switchspeed_buff",
			value = 1
		}
	}
	self.definitions.pistol_switchspeed_buff_2 = {
		category = "feature",
		name_id = "pistol_switchspeed_buff",
		upgrade = {
			category = "player",
			upgrade = "pistol_switchspeed_buff",
			value = 2
		}
	}

	self.definitions.empty_akimbo_switch = {
		category = "feature",
		name_id = "empty_akimbo_switch",
		upgrade = {
			category = "player",
			upgrade = "empty_akimbo_switch",
			value = 1
		}
	}
	self.definitions.empty_akimbo_reload = {
		category = "feature",
		name_id = "empty_akimbo_reload",
		upgrade = {
			category = "player",
			upgrade = "empty_akimbo_reload",
			value = 1
		}
	}

	self.definitions.offhand_reload_time_mult = {
		category = "feature",
		name_id = "offhand_reload_time_mult",
		upgrade = {
			category = "player",
			upgrade = "offhand_reload_time_mult",
			value = 1
		}
	}
	self.definitions.offhand_reload_time_mult_2 = {
		category = "feature",
		name_id = "offhand_reload_time_mult",
		upgrade = {
			category = "player",
			upgrade = "offhand_reload_time_mult",
			value = 2
		}
	}
	self.definitions.pistol_gives_offhand_reload = {
		category = "feature",
		name_id = "pistol_gives_offhand_reload",
		upgrade = {
			category = "player",
			upgrade = "pistol_gives_offhand_reload",
			value = 1
		}
	}
	self.definitions.ar_gives_offhand_reload = {
		category = "feature",
		name_id = "smg_gives_offhand_reload",
		upgrade = {
			category = "player",
			upgrade = "ar_gives_offhand_reload",
			value = 1
		}
	}
	self.definitions.smg_gives_offhand_reload = {
		category = "feature",
		name_id = "smg_gives_offhand_reload",
		upgrade = {
			category = "player",
			upgrade = "smg_gives_offhand_reload",
			value = 1
		}
	}
	self.definitions.shotgun_gives_offhand_reload = {
		category = "feature",
		name_id = "shotgun_gives_offhand_reload",
		upgrade = {
			category = "player",
			upgrade = "shotgun_gives_offhand_reload",
			value = 1
		}
	}
	self.definitions.xbow_gives_offhand_reload = {
		category = "feature",
		name_id = "xbow_gives_offhand_reload",
		upgrade = {
			category = "player",
			upgrade = "xbow_gives_offhand_reload",
			value = 1
		}
	}

	self.definitions.weapon_lmg_pierce_enemies = {
		name_id = "menu_weapon_lmg_pierce_enemies",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lmg_pierce_enemies",
			category = "weapon"
		}
	}

	-- Bunker/Holdout stuff
	self.definitions.player_holdout_consecutive_kills = {
		category = "feature",
		name_id = "menu_player_holdout_consecutive_kills",
		upgrade = {
			category = "player",
			upgrade = "holdout_consecutive_kills",
			value = 1
		}
	}

	self.definitions.player_holdout_killcount_1 = {
		category = "feature",
		name_id = "menu_player_holdout_killcount_1",
		upgrade = {
			category = "player",
			upgrade = "holdout_killcount",
			value = 1
		}
	}
	self.definitions.player_holdout_killcount_2 = {
		category = "feature",
		name_id = "menu_player_holdout_killcount_2",
		upgrade = {
			category = "player",
			upgrade = "holdout_killcount",
			value = 2
		}
	}

	-- Distant kill health regen
	self.definitions.player_holdout_distant_kill_health_regen_1 = {
		category = "feature",
		name_id = "menu_player_holdout_distant_kill_health_regen_1",
		upgrade = {
			category = "player",
			upgrade = "holdout_distant_kill_health_regen",
			value = 1
		}
	}
	self.definitions.player_holdout_distant_kill_health_regen_2 = {
		category = "feature",
		name_id = "menu_player_holdout_distant_kill_health_regen_2",
		upgrade = {
			category = "player",
			upgrade = "holdout_distant_kill_health_regen",
			value = 2
		}
	}
	-- Close-by armor regen
	self.definitions.player_holdout_close_kill_armor_regen_1 = {
		category = "feature",
		name_id = "menu_player_holdout_close_kill_armor_regen_1",
		upgrade = {
			category = "player",
			upgrade = "holdout_close_kill_armor_regen",
			value = 1
		}
	}
	self.definitions.player_holdout_close_kill_armor_regen_2 = {
		category = "feature",
		name_id = "menu_player_holdout_close_kill_armor_regen_2",
		upgrade = {
			category = "player",
			upgrade = "holdout_close_kill_armor_regen",
			value = 2
		}
	}

	-- Cooldowns for the regen
	self.definitions.player_holdout_regen_cooldown_1 = {
		category = "feature",
		name_id = "menu_player_holdout_regen_cooldown_1",
		upgrade = {
			category = "player",
			upgrade = "holdout_regen_cooldown",
			value = 1
		}
	}
	self.definitions.player_holdout_regen_cooldown_2 = {
		category = "feature",
		name_id = "menu_player_holdout_regen_cooldown_2",
		upgrade = {
			category = "player",
			upgrade = "holdout_regen_cooldown",
			value = 2
		}
	}

	-- Every nth kill drops extra ammo
	self.definitions.player_holdout_consecutive_kill_ammo = {
		category = "feature",
		name_id = "menu_player_holdout_consecutive_kill_ammo",
		upgrade = {
			category = "player",
			upgrade = "holdout_consecutive_kill_ammo",
			value = 1
		}
	}
	-- Holdout damage reduction
	self.definitions.player_holdout_dmg_reduction_1 = {
		category = "feature",
		name_id = "menu_player_holdout_dmg_reduction_1",
		upgrade = {
			category = "player",
			upgrade = "holdout_dmg_reduction",
			value = 1
		}	
	}
end)

Hooks:PostHook(UpgradesTweakData, "_pistol_definitions", "gonnamakemyownpistolskills", function(self, params)
	self.definitions.pistol_enter_steelsight_speed_multiplier = {
		name_id = "menu_pistol_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "pistol"
		}
	}
end)

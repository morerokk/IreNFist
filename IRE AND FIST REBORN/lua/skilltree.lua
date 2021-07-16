dofile(ModPath .. "infcore.lua")

-- If sydch's skill overhaul is enabled then touch the trees differently
if IREnFIST.mod_compatibility.sso then

	-- I checked the BLT source and registering the same hook twice isn't a big deal, the second call is ignored.
	-- What *is* a big deal is trying to add a hook before it's registered, so let's not do that!
	Hooks:RegisterHook("sso_skilltweak_init_complete")

	-- Listen for SSO having completed its work
	-- Thanks to Sydch helpfully providing a Hook, we can ensure our code always runs after theirs.
	Hooks:AddHook("sso_skilltweak_init_complete", "inf_skilltweakinit_after_sso", function(self)
		-- Rifleman
		self.skills.rifleman[1].upgrades = {"weapon_enter_steelsight_speed_multiplier", "snp_reload_speed_multiplier"}
		self.skills.rifleman[2].upgrades = {"smg_reload_speed_multiplier", "assault_rifle_reload_speed_multiplier"}

		-- Ammo Efficiency
		self.skills.spotter_teamwork[1].upgrades = { "head_shot_ammo_return_1" }
		self.skills.spotter_teamwork[2].upgrades = { "head_shot_ammo_return_2" }

		-- Aggressive Reload
		self.skills.speedy_reload[1].upgrades = {"snp_headshot_armor"}
		self.skills.speedy_reload[2].upgrades = {"snp_headshot_armor_2"}

		-- Shotgun Impact/Solid Impact
		self.skills.shotgun_impact[1].upgrades = {"advmov_stamina_on_kill"}
		self.skills.shotgun_impact[2].upgrades = {"advmov_stamina_on_kill_2"}

		-- Shotgun CQB
		self.skills.shotgun_cqb[1].upgrades = {"shotgun_reload_speed_multiplier_1"}
		self.skills.shotgun_cqb[2].upgrades = {"shotgun_reload_speed_multiplier_2"}

		-- Far Away/Surgical Shot
		self.skills.far_away[1].upgrades = {"pellet_penalty_reduction"}
		self.skills.far_away[2].upgrades = {"pellet_penalty_reduction_2"}

		-- Close By (no shotgun mag plus pls)
		self.skills.close_by[2].upgrades = {"shotgun_switchspeed_buff"}

		-- Overkill/Last Word
		-- These damage bonuses are a bit OP in InF
		self.skills.overkill[1].upgrades = {"shotgun_last_shell_amount", "shotgun_last_shell_dmg_mult"}
		self.skills.overkill[2].upgrades = {"shotgun_last_shell_amount_2"}

		-- Technician
		-- Bunker/Fire Control instead of Mag Plus and reload bonuses
		self.skills.fire_control[1].upgrades = {"bipod_deploy_speed_mult"}
		self.skills.fire_control[2].upgrades = {"bipod_dmg_taken_mult"}
		-- Lock and load, add low magazine reload bonus to the new hipfire skill rather than to Surefire
		table.insert(self.skills.shock_and_awe[2].upgrades, "locknload_reload")
		table.insert(self.skills.shock_and_awe[2].upgrades, "locknload_reload_partial")
		-- Fire control horizontal recoil
		-- Confusingly, some skills were swapped
		self.skills.fast_fire[1].upgrades = {"recoil_h_mult"}
		self.skills.fast_fire[2].upgrades = {"recoil_h_mult_2"}

		-- Shockproof, add taser bullets
		table.insert(self.skills.hitman[2].upgrades, "player_electric_bullets_while_tased")

		-- body expertise
		self.skills.body_expertise[1].upgrades = {
			"weapon_automatic_head_shot_add_1",
			"weapon_automatic_head_shot_add_2"
		}
		self.skills.body_expertise[2].upgrades = {"weapon_lmg_pierce_enemies"}

		-- Specialized Killing, remove the silencer damage bonus and spread the other bonuses out over the 2 tiers
		self.skills.unseen_strike[1].upgrades = {
			"weapon_silencer_recoil_index_addend"
		}
		self.skills.unseen_strike[2].upgrades = {
			"weapon_silencer_enter_steelsight_speed_multiplier",
			"weapon_silencer_spread_index_addend"
		}

		-- Fugitive
		-- Pistol/Dexterous tree
		-- Itchy Finger, remove reload speed bonus and mag size increase
		self.skills.dance_instructor[1].upgrades = {"pistol_switchspeed_buff"}
		self.skills.dance_instructor[2].upgrades = {"pistol_switchspeed_buff_2"}
		-- Akimbo/Two-Hands/Dual Wielder skill, replace stability and ammo bonuses with switch speed and reload bonuses instead
		self.skills.akimbo[1].upgrades = {"empty_akimbo_switch"}
		self.skills.akimbo[2].upgrades = {"empty_akimbo_reload"}

		self.skills.expert_handling[1].upgrades = {"pistol_enter_steelsight_speed_multiplier"}
		self.skills.expert_handling[2].upgrades = {"pistol_reload_speed_multiplier"}

		-- one handed talent/off-handed reload
		self.skills.gun_fighter[1].upgrades = {"offhand_reload_time_mult", "pistol_gives_offhand_reload"}
		self.skills.gun_fighter[2].upgrades = {"offhand_reload_time_mult_2", "ar_gives_offhand_reload", "smg_gives_offhand_reload", "shotgun_gives_offhand_reload", "xbow_gives_offhand_reload"}

		-- Trigger Happy/Coordination
		self.skills.trigger_happy[1].upgrades = {"pistol_stacking_hit_damage_multiplier_1"}
		self.skills.trigger_happy[2].upgrades = {"pistol_stacking_hit_damage_multiplier_2"}

		-- Add guardian perk deck
		-- Re-use common perks from SSO
		
		-- Get the default perks from crew chief
		-- Except perk 2. I like SSO, but vanilla PD2's take on headshot damage is bad
		--local deck2 = deep_clone(self.specializations[1][2])
		local deck2 = {
			cost = 300,
			desc_id = "menu_deckall_2_desc",
			name_id = "menu_deckall_2",
			upgrades = {
				"passive_player_xp_multiplier"
			},
			icon_xy = {
				1,
				0
			}
		}
		local deck4 = deep_clone(self.specializations[1][4])
		local deck6 = deep_clone(self.specializations[1][6])
		local deck8 = deep_clone(self.specializations[1][8])

		-- Define the deck
		local holdout_deck = {
			{
				cost = 200,
				desc_id = "menu_deck_holdout1_desc",
				name_id = "menu_deck_holdout1",
				upgrades = {
					"player_holdout_consecutive_kills", -- Enables the holdout feature to begin with
					"player_holdout_killcount_1" -- Required kills in zone is 3
				},
				icon_xy = {
					0,
					5
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck_holdout3_desc",
				name_id = "menu_deck_holdout3",
				texture_bundle_folder = "opera",
				upgrades = {
					"player_holdout_distant_kill_health_regen_1", -- Far away kills regenerate 10 health
					"player_holdout_close_kill_armor_regen_1", -- Close-by kills regenerate 10 armor instead
					"player_holdout_regen_cooldown_1" -- Cooldown is 5 seconds
				},
				icon_xy = {
					0,
					1
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck_holdout5_desc",
				name_id = "menu_deck_holdout5",
				texture_bundle_folder = "opera",
				upgrades = {
					"player_holdout_killcount_2", -- Lower required kills to 2
					"player_holdout_dmg_reduction_1" -- Add 12% damage reduction while inside your zone
				},
				icon_xy = {
					0,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck_holdout7_desc",
				name_id = "menu_deck_holdout7",
				upgrades = {
					"player_holdout_distant_kill_health_regen_2", -- Far away kills regenerate 20 health instead of 10
					"player_holdout_close_kill_armor_regen_2" -- Close-by kills regenerate 20 armor instead of 10
				},
				icon_xy = {
					0,
					3
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck_holdout9_desc",
				name_id = "menu_deck_holdout9",
				upgrades = {
					"player_holdout_consecutive_kill_ammo", -- Every 10th consecutive zone kill drops 1 extra ammo
					"player_holdout_regen_cooldown_2", -- Cooldown of Bunker reduced to 4 seconds
					"player_passive_loot_drop_multiplier" -- Should always be in any perk deck, is infamous chance
				},
				icon_xy = {
					4,
					5
				}
			},
			desc_id = "menu_deck_holdout_desc",
			name_id = "menu_deck_holdout",
			custom = true,
			custom_id = "inf_holdout_perkdeck",
		}

		-- Insert the new perk deck and remember its ID
		-- This is better compatible with other perkdeck-adding mods and also future-proof
		local i = #self.specializations + 1
		self.specializations[i] = holdout_deck
		IREnFIST.holdout_deck_index = i
	end)
else
	Hooks:PostHook(SkillTreeTweakData, "init", "remove_denbts", function(self, params)

		local digest = function(value)
			return Application:digest_value(value, true)
		end
		self.tier_unlocks = {
			digest(0),
			digest(1),
			digest(3),
			digest(16)
		}

		-- Common decks

		-- Remove headshot dmg multiplier, replace with XP
		-- Also add the former Parkour movement speed bonus to it
		local deck2 = {
			cost = 300,
			desc_id = "menu_deckall_2_desc",
			name_id = "menu_deckall_2",
			upgrades = {
				"passive_player_xp_multiplier",
				"player_movement_speed_multiplier"
			},
			icon_xy = {
				1,
				0
			}
		}
		-- Remove XP and detection buffs, add instant cash pickup value
		local deck4 = {
			cost = 600,
			desc_id = "menu_deckall_4_desc",
			name_id = "menu_deckall_4",
			upgrades = {
				"player_passive_armor_movement_penalty_multiplier",
				"player_small_loot_multiplier_1"
			},
			icon_xy = {
				3,
				0
			}
		}
		-- No ammo pickup multiplier, add further bag throwing
		local deck6 = {
			cost = 1600,
			desc_id = "menu_deckall_6_desc",
			name_id = "menu_deckall_6",
			upgrades = {
				"armor_kit",
				"carry_throw_distance_multiplier"
			},
			icon_xy = {
				5,
				0
			}
		}
		-- No random damage multiplier, add sprint speed from Sprinter skillf
		-- Also add insider assets because limiting expert driver to a skill is kinda gay
		-- And you never need them outside of stealth anyway
		-- Dumb goldfarb era holdover that doesn't really work well anymore
		local deck8 = {
			cost = 3200,
			desc_id = "menu_deckall_8_desc",
			name_id = "menu_deckall_8",
			upgrades = {
				"passive_doctor_bag_interaction_speed_multiplier",
				"player_run_speed_multiplier",
				"player_buy_bodybags_asset",
				"player_additional_assets",
				"player_cleaner_cost_multiplier",
				"player_buy_spotter_asset"
			},
			icon_xy = {
				7,
				0
			}
		}

		-- Change common perks in each deck
		for a = 1, #self.specializations, 1 do
			self.specializations[a][2] = deck2
			self.specializations[a][4] = deck4
			self.specializations[a][6] = deck6
			self.specializations[a][8] = deck8
		end

		-- Add brand-new Bunker/Holdout/Defender perk deck
		local holdout_deck = {
			{
				cost = 200,
				desc_id = "menu_deck_holdout1_desc",
				name_id = "menu_deck_holdout1",
				upgrades = {
					"player_holdout_consecutive_kills", -- Enables the holdout feature to begin with
					"player_holdout_killcount_1" -- Required kills in zone is 3
				},
				icon_xy = {
					0,
					5
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck_holdout3_desc",
				name_id = "menu_deck_holdout3",
				texture_bundle_folder = "opera",
				upgrades = {
					"player_holdout_distant_kill_health_regen_1", -- Far away kills regenerate 10 health
					"player_holdout_close_kill_armor_regen_1", -- Close-by kills regenerate 10 armor instead
					"player_holdout_regen_cooldown_1" -- Cooldown is 5 seconds
				},
				icon_xy = {
					0,
					1
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck_holdout5_desc",
				name_id = "menu_deck_holdout5",
				texture_bundle_folder = "opera",
				upgrades = {
					"player_holdout_killcount_2", -- Lower required kills to 2
					"player_holdout_dmg_reduction_1" -- Add 12% damage reduction while inside your zone
				},
				icon_xy = {
					0,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck_holdout7_desc",
				name_id = "menu_deck_holdout7",
				upgrades = {
					"player_holdout_distant_kill_health_regen_2", -- Far away kills regenerate 20 health instead of 10
					"player_holdout_close_kill_armor_regen_2" -- Close-by kills regenerate 20 armor instead of 10
				},
				icon_xy = {
					0,
					3
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck_holdout9_desc",
				name_id = "menu_deck_holdout9",
				upgrades = {
					"player_holdout_consecutive_kill_ammo", -- Every 10th consecutive zone kill drops 1 extra ammo
					"player_holdout_regen_cooldown_2", -- Cooldown of Bunker reduced to 4 seconds
					"player_passive_loot_drop_multiplier" -- Should always be in any perk deck, is infamous chance
				},
				icon_xy = {
					4,
					5
				}
			},
			desc_id = "menu_deck_holdout_desc",
			name_id = "menu_deck_holdout",
			custom = true,
			custom_id = "inf_holdout_perkdeck",
		}

		-- Insert the new perk deck and remember its ID
		-- This is better compatible with other perkdeck-adding mods and also future-proof
		local i = #self.specializations + 1
		self.specializations[i] = holdout_deck
		IREnFIST.holdout_deck_index = i

		-- Rogue
		-- Give yet more dodge to the final perk, replace "pierce body armor" with "pierce enemies" since piercing body armor is redundant
		self.specializations[4][9].upgrades = {
			"player_passive_loot_drop_multiplier",
			"weapon_all_pierce_enemies",
			"weapon_passive_swap_speed_multiplier_1",
			"player_passive_dodge_chance_4"
		}

		-- MASTERMIND
		-- tier 1 cool under pressure
		self.skills.stable_shot[1].upgrades = {"ugh_its_a_reload_bonus"}
		self.skills.stable_shot[2].upgrades = {"ugh_its_a_reload_bonus_2"}
		-- marksman
		self.skills.sharpshooter[2].upgrades = {"weapon_passive_headshot_damage_multiplier"}
		-- rifleman
		self.skills.rifleman[1].upgrades = {"weapon_enter_steelsight_speed_multiplier", "snp_reload_speed_multiplier"}
		self.skills.rifleman[2].upgrades = {"smg_reload_speed_multiplier", "assault_rifle_reload_speed_multiplier"}
		-- aggressive reload
		self.skills.speedy_reload[1].upgrades = {"snp_headshot_armor"}
		self.skills.speedy_reload[2].upgrades = {"snp_headshot_armor_2"}

		-- Re-add old stockholm syndrome to stockholm syndrome skill
		table.insert(self.skills.stockholm_syndrome[1].upgrades, "player_civilian_reviver")

		-- GHOST
		-- Duck and cover
		-- Extra sprint speed moved to perk
		self.skills.sprinter[1].upgrades = {
			"player_stamina_regen_timer_multiplier",
			"player_stamina_regen_multiplier"
		}

		-- Chameleon, make extra loot value innate to a shared perk instead of some random skill
		self.skills.jail_workout[2].upgrades = {
			"player_mask_off_pickup"
		}
		-- Sixth Sense, replace insider assets with pager snatch
		-- Pager snatch auto-answers pagers if you kill an unalerted ("cool") guard with melee
		self.skills.chameleon[2].upgrades = {
			"player_cleaner_cost_multiplier",
			"player_inf_snatch_pager" -- Inf prefix added because I vaguely remember other mods or even PD2 itself using this
		}

		self.skills.sprinter[2].upgrades = {"player_run_dodge_chance", "slide_dodge_chance"}
		-- replace dire need with moving target
		self.skills.dire_need[1].upgrades = {"player_detection_risk_add_movement_speed_1"}
		self.skills.dire_need[2].upgrades = {"player_detection_risk_add_movement_speed_2"}
		self.skills.dire_need.name_id = "menu_moving_target"
		self.skills.dire_need.desc_id = "menu_moving_target_desc"
		self.skills.dire_need.icon_xy = {2, 4} -- Moving Target icon
		-- Shockproof Ace: taser bullets (lol)
		table.insert(self.skills.insulation[2].upgrades, "player_electric_bullets_while_tased")

		-- Parkour skill: replace movement speed bonus with the ability to break your fall with advanced movement
		self.skills.awareness[1].upgrades = {
			"player_climb_speed_multiplier_1",
			"player_adv_movement_breaks_fall"
		}


		-- FUGITIVE
		-- gun nut
		-- fuck your mag capacity
		-- fuck your stryk magic too
		-- basically just eat a bag of dicks for managing to trigger what precious little gun autism i have
		self.skills.dance_instructor[1].upgrades = {"pistol_switchspeed_buff"}
		self.skills.dance_instructor[2].upgrades = {"pistol_switchspeed_buff_2"}
		-- akimbo
		self.skills.akimbo[1].upgrades = {"empty_akimbo_switch"}
		self.skills.akimbo[2].upgrades = {"empty_akimbo_reload"}
		-- pumping iron
		self.skills.steroids[1].upgrades = {"player_non_special_melee_multiplier", "player_melee_damage_multiplier"}
		self.skills.steroids[2].upgrades = {"imma_chargin_mah_melee"}
		-- desperado
		self.skills.expert_handling[1].upgrades = {"pistol_enter_steelsight_speed_multiplier"}
		-- one handed talent/off-handed reload
		self.skills.gun_fighter[1].upgrades = {"offhand_reload_time_mult", "pistol_gives_offhand_reload"}
		self.skills.gun_fighter[2].upgrades = {"offhand_reload_time_mult_2", "ar_gives_offhand_reload", "smg_gives_offhand_reload", "shotgun_gives_offhand_reload", "xbow_gives_offhand_reload"}
		-- equilibrium
		self.skills.equilibrium[1].upgrades = {"pistol_base_switchspeed_add"}
		self.skills.equilibrium[2].upgrades = {"pistol_base_switchspeed_add_2"}

		-- Counter-Strike
		table.insert(self.skills.drop_soap[1].upgrades, "player_arrest_knockdown")
		table.insert(self.skills.drop_soap[2].upgrades, "player_counter_arrest")


		-- ENFORCER
		-- Transporter
		self.skills.pack_mule[1].upgrades = { "player_sprint_any_bag" }
		-- overkill
		self.skills.overkill[1].upgrades = {"shotgun_last_shell_amount", "shotgun_last_shell_dmg_mult"}
		self.skills.overkill[2].upgrades = {"shotgun_last_shell_amount_2"}
		-- far away
		self.skills.far_away[1].upgrades = {"pellet_penalty_reduction"}
		self.skills.far_away[2].upgrades = {"pellet_penalty_reduction_2"}
		-- close by
		self.skills.close_by[2].upgrades = {"shotgun_switchspeed_buff"}
		-- shotgun cqb
		self.skills.shotgun_cqb[2].upgrades = {"shotgun_reload_speed_multiplier_2"}
		-- shotgun impact
		--self.skills.shotgun_impact[1].upgrades = {"shotgun_damage_addend"}
		--self.skills.shotgun_impact[2].upgrades = {"shotgun_damage_addend_2"}
		self.skills.shotgun_impact[1].upgrades = {"advmov_stamina_on_kill"}
		self.skills.shotgun_impact[2].upgrades = {"advmov_stamina_on_kill_2"}

		-- Carbon Blade replaced, saw skills merged down into Portable Saw skill
		self.skills.portable_saw[1].upgrades = {
			"saw_secondary",
			"saw_enemy_slicer"
		}
		self.skills.portable_saw[2].upgrades = {
			"saw_extra_ammo_multiplier",
			"player_saw_speed_multiplier_2",
			"saw_lock_damage_multiplier_2",
			"saw_ignore_shields_1",
			"saw_panic_when_kill_1"
		}

		-- Weird discount "bulletstorm" mechanic
		-- Pick up ammo boxes and you'll charge up a bar
		-- Press a keybind to gain temporary bulletstorm during that time
		-- NOTE: Bulletstorm no longer gives you a bottomless mag, it only prevents ammo consumption.
		-- You still have to reload but your reserve ammo temporarily doesn't run out.
		self.skills.carbon_blade[1].upgrades = {
			"player_inf_charge_bulletstorm",
			"player_inf_bulletstorm_second_gain_1"
		}

		-- Use your own ammo to refill an ammo bag
		self.skills.carbon_blade[2].upgrades = {
			"player_inf_refill_ammobag",
			"player_inf_bulletstorm_second_gain_2"
		}
		-- Change icon to a pack mule originally used for Transporter pre-U100
		self.skills.carbon_blade.icon_xy = { 6, 0 }

		-- Fully loaded
		-- Basic now contains a 25% ammo pickup bonus
		-- Aced now gives an additional 25% ammo pickup (so 150% scavenge rate total, aced is same as before but basic feels less useless)
		self.skills.bandoliers[1].upgrades = {
			"extra_ammo_multiplier1",
			"player_pick_up_ammo_multiplier",
		}
		self.skills.bandoliers[2].upgrades = {
			"player_pick_up_ammo_multiplier_2",
			"player_regain_throwable_from_ammo_1"
		}


		-- TECHNICIAN
		-- surefire/bunker
		self.skills.fast_fire[1].upgrades = {"bipod_deploy_speed_mult"}
		self.skills.fast_fire[2].upgrades = {"bipod_dmg_taken_mult"}
		-- steady grip
		self.skills.steady_grip[1].upgrades = {"player_stability_increase_bonus_1"}
		self.skills.steady_grip[2].upgrades = {"player_stability_increase_bonus_2"}
		-- fire control
		self.skills.fire_control[1].upgrades = {"recoil_h_mult"}
		self.skills.fire_control[2].upgrades = {"recoil_h_mult_2"}
		-- body expertise
		self.skills.body_expertise[1].upgrades = {
			"weapon_automatic_head_shot_add_1",
			"weapon_automatic_head_shot_add_2"
		}
		self.skills.body_expertise[2].upgrades = {"weapon_lmg_pierce_enemies"}

		-- lock 'n load
		--self.skills.shock_and_awe[1].upgrades = {}
		self.skills.shock_and_awe[2].upgrades = {"locknload_reload", "locknload_reload_partial"}

		-- Add armor ammo multiplier to default upgrades
		if not table.contains(self.default_upgrades, "player_add_armor_stat_skill_ammo_mul") then
			table.insert(self.default_upgrades, "player_add_armor_stat_skill_ammo_mul")
		end

	end)
end


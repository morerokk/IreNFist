dofile(ModPath .. "infcore.lua")

-- If sydch's skill overhaul is enabled then touch the trees differently
if IreNFist.mod_compatibility.sso then

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

		for a = 1, 21, 1 do
			-- remove 25% headshot bonus, add xp multiplier
			self.specializations[a][2].upgrades = {"passive_player_xp_multiplier"}
			-- remove xp multiplier and concealment modifier
			self.specializations[a][4].upgrades = {"player_passive_armor_movement_penalty_multiplier"}
			-- remove 5% damage bonus
			self.specializations[a][8].upgrades = {"passive_doctor_bag_interaction_speed_multiplier"}
		end

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
		-- duck and cover
		self.skills.sprinter[2].upgrades = {"player_run_dodge_chance", "slide_dodge_chance"}
		-- replace dire need with moving target
		self.skills.dire_need[1].upgrades = {"player_detection_risk_add_movement_speed_1"}
		self.skills.dire_need[2].upgrades = {"player_detection_risk_add_movement_speed_2"}
		self.skills.dire_need.name_id = "menu_moving_target"
		self.skills.dire_need.desc_id = "menu_moving_target_desc"
		self.skills.dire_need.icon_xy = {2, 4} -- Moving Target icon
		-- Shockproof Ace: taser bullets (lol)
		table.insert(self.skills.insulation[2].upgrades, "player_electric_bullets_while_tased")


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
		table.insert(self.skills.drop_soap[2].upgrades, "player_counter_arrest")


		-- ENFORCER
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


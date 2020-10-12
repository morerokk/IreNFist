dofile(ModPath .. "infcore.lua")

--[[
normal
hard
VH: overkill
OVK: overkill_145
MH: easy_wish
DW: overkill_290
DS: sm_wish
--]]
local city_swat_hurts = {
	tase = true,
	bullet = {
		health_reference = 1,
		zones = {{light = 1}}
	},
	explosion = {
		health_reference = 1,
		zones = {{explode = 1}}
	},
	melee = {
		health_reference = "current",
		zones = {
			{heavy = 0, health_limit = 0.3, light = 0.7, moderate = 0, none = 0.3},
			{heavy = 0, light = 1, moderate = 0, health_limit = 0.8},
			{heavy = 0.2, light = 0.6, moderate = 0.2, health_limit = 0.9},
			{light = 0, moderate = 0, heavy = 9}}
		},
	fire = {
		health_reference = 1,
		zones = {{fire = 1}}
	},
	poison = {
		health_reference = 1,
		zones = {{poison = 1}}
	}
}

local heavy_swat_hurts = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					heavy = 0.0,
					health_limit = 0.3,
					light = 0.8,
					moderate = 0.0,
					none = 0.2
				},
				{
					heavy = 0.0,
					light = 0.5,
					moderate = 0.5,
					health_limit = 0.6
				},
				{
					heavy = 0.4,
					light = 0.0,
					moderate = 0.6,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
					heavy = 1
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					none = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					heavy = 0,
					health_limit = 0.3,
					light = 0.7,
					moderate = 0,
					none = 0.3
				},
				{
					heavy = 0,
					light = 1,
					moderate = 0,
					health_limit = 0.8
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
					heavy = 9
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					poison = 1,
					none = 0
				}
			}
		}
	}






local function apply_acc(unitweapon, acctype)
	if InFmenu.settings.copmiss == true then
		if acctype == "standard" then
			unitweapon.FALLOFF[1].acc = {0.90, 0.95} -- 0-1m
			unitweapon.FALLOFF[2].acc = {0.70, 0.90} -- 1-5m
			unitweapon.FALLOFF[3].acc = {0.60, 0.70} -- 5-10m
			unitweapon.FALLOFF[4].acc = {0.35, 0.50} -- 10-20m
			unitweapon.FALLOFF[5].acc = {0.15, 0.35} -- 20-30m
			if not unitweapon.FALLOFF[6] then
				unitweapon.FALLOFF[6] = deep_clone(unitweapon.FALLOFF[5])
				unitweapon.FALLOFF[6].r = 6000
			end
			unitweapon.FALLOFF[6].acc = {0.05, 0.20} -- 30-60m
		elseif acctype == "dozer" then
			unitweapon.FALLOFF[1].acc = {0.60, 0.80} -- 0-1m
			unitweapon.FALLOFF[2].acc = {0.50, 0.70} -- 1-5m
			unitweapon.FALLOFF[3].acc = {0.40, 0.60} -- 5-10m
			unitweapon.FALLOFF[4].acc = {0.30, 0.50} -- 10-20m
			unitweapon.FALLOFF[5].acc = {0.20, 0.40} -- 20-30m
			if not unitweapon.FALLOFF[6] then
				unitweapon.FALLOFF[6] = deep_clone(unitweapon.FALLOFF[5])
				unitweapon.FALLOFF[6].r = 6000
			end
			unitweapon.FALLOFF[6].acc = {0.05, 0.20} -- 30-60m
		elseif acctype == "shield" then
			unitweapon.FALLOFF[1].acc = {0.80, 0.80} -- 0m
			unitweapon.FALLOFF[2].acc = {0.70, 0.75} -- 0-7m
			unitweapon.FALLOFF[3].acc = {0.40, 0.65} -- 7-10m
			unitweapon.FALLOFF[4].acc = {0.25, 0.50} -- 10-20m
			unitweapon.FALLOFF[5].acc = {0.10, 0.25} -- 20-30m
			if not unitweapon.FALLOFF[6] then
				unitweapon.FALLOFF[6] = deep_clone(unitweapon.FALLOFF[5])
				unitweapon.FALLOFF[6].r = 6000
			end
			unitweapon.FALLOFF[6].acc = {0.05, 0.15} -- 30-60m
		end
	end
end


Hooks:PostHook(CharacterTweakData, "_init_phalanx_minion", "wintersminionexploder", function(self)
	-- i'm convinced this shit don't work
	--self.phalanx_minion.damage.explosion_damage_mul = 0.2
end)
Hooks:PostHook(CharacterTweakData, "_init_phalanx_vip", "wintersexploder", function(self)
	--self.phalanx_vip.damage.explosion_damage_mul = 0.2
end)

-- who the fuck is even gonna play these difficulties
Hooks:PostHook(CharacterTweakData, "_set_normal", "sethealthnormal", function(self)
	if InFmenu.settings.copfalloff == true then
			-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		self.tank.weapon.is_rifle.focus_delay = 5
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 0.3 -- 6, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 0.3 -- 6, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 0.2 -- 4, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 0.15 -- 3, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 0.1 -- 2, 20-30m
	end
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)
Hooks:PostHook(CharacterTweakData, "_set_hard", "sethealthhard", function(self)
	if InFmenu.settings.copfalloff == true then
			-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		self.tank.weapon.is_rifle.focus_delay = 4
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 0.75 -- 15, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 0.75 -- 15, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 0.5 -- 10, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 0.35 -- 7, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 0.25 -- 5, 20-30m
	end
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)
Hooks:PostHook(CharacterTweakData, "_set_overkill", "sethealthvhard", function(self)
	if InFmenu.settings.copfalloff == true then
		-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		self.tank.weapon.is_rifle.focus_delay = 3
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 1.5 -- 30, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 1.5 -- 30, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 1.0 -- 20, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 0.75 -- 15, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 0.5 -- 10, 20-30m
	end
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)










Hooks:PostHook(CharacterTweakData, "_set_overkill_145", "sethealthovk", function(self)
	self.flashbang_multiplier = 1.25 -- 1.75

	if InFmenu.settings.sanehp == true then
		-- crooks
		self.gangster.HEALTH_INIT = 10.0
		self.gangster.headshot_dmg_mul = 2
		self.biker.HEALTH_INIT = 10.0
		self.biker.headshot_dmg_mul = 2
		self.captain.HEALTH_INIT = 10.0
		self.captain.headshot_dmg_mul = 2
		self.biker_escape.HEALTH_INIT = 10.0
		self.biker_escape.headshot_dmg_mul = 2
		self.mobster.HEALTH_INIT = 10.0
		self.mobster.headshot_dmg_mul = 2
		self.bolivian.HEALTH_INIT = 10.0
		self.bolivian.headshot_dmg_mul = 2
		self.bolivian_indoors.HEALTH_INIT = 10.0
		self.bolivian_indoors.headshot_dmg_mul = 2
		-- security guards
		self.security.HEALTH_INIT = 10.0
		self.security.headshot_dmg_mul = 2
		self.security_undominatable.HEALTH_INIT = 10.0
		self.security_undominatable.headshot_dmg_mul = 2
		self.mute_security_undominatable.HEALTH_INIT = 10.0
		self.mute_security_undominatable.headshot_dmg_mul = 2
		self.gensec.HEALTH_INIT = 11.0
		self.gensec.headshot_dmg_mul = 2
		-- the boys in blue
		self.cop.HEALTH_INIT = 10.0
		self.cop.headshot_dmg_mul = 2
		self.cop_scared.HEALTH_INIT = 10.0
		self.cop_scared.headshot_dmg_mul = 2
		self.cop_female.HEALTH_INIT = 10.0
		self.cop_female.headshot_dmg_mul = 2
		-- FBIs, whiteshirtblackguy
		self.fbi.HEALTH_INIT = 11.0
		self.fbi.headshot_dmg_mul = 2
		-- blues, HRTs
		self.swat.HEALTH_INIT = 13.5
		self.swat.headshot_dmg_mul = 3
		-- greens
		self.fbi_swat.HEALTH_INIT = 15.0
		self.fbi_swat.headshot_dmg_mul = 3.0
		-- grays
		self.city_swat.HEALTH_INIT = 16.5
		self.city_swat.headshot_dmg_mul = 3.0
		-- whiteheads
		self.heavy_swat.HEALTH_INIT = 17.5
		self.heavy_swat.headshot_dmg_mul = 2.5
		-- tans
		self.fbi_heavy_swat.HEALTH_INIT = 20.0
		self.fbi_heavy_swat.headshot_dmg_mul = 2.0
		self.fbi_heavy_swat.damage.hurt_severity = heavy_swat_hurts

		-- SHIELD
		self.shield.HEALTH_INIT = 10.0
		self.shield.headshot_dmg_mul = 2
		-- SNIPER
		self.sniper.HEALTH_INIT = 5.0
		self.sniper.headshot_dmg_mul = 2
		-- TASER
		self.taser.HEALTH_INIT = 31.0
		self.taser.headshot_dmg_mul = 2
		-- MEDIC
		self.medic.HEALTH_INIT = 31.0
		self.medic.headshot_dmg_mul = 2
		-- CLOAKER
		self.spooc.HEALTH_INIT = 36.0
		self.spooc.headshot_dmg_mul = 4
		-- BULLDOZER
		self.tank.HEALTH_INIT = 900.0
		self.tank.headshot_dmg_mul = 25
		self.tank.critical_hits = {damage_mul = 3}
		self.tank_medic.HEALTH_INIT = 900.0
		self.tank_medic.headshot_dmg_mul = 25
		self.tank_medic.critical_hits = {damage_mul = 3}
		self.tank_mini.HEALTH_INIT = 900.0 * 1.25
		self.tank_mini.headshot_dmg_mul = 25
		self.tank_mini.critical_hits = {damage_mul = 3}

		-- THE WINTERS BRIGADE
		self.phalanx_minion.HEALTH_INIT = 40.0
		self.phalanx_minion.headshot_dmg_mul = 2
		self.phalanx_minion.DAMAGE_CLAMP_BULLET = 100.0
		self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = 100.0
		self.phalanx_vip.HEALTH_INIT = 120.0
		self.phalanx_vip.headshot_dmg_mul = 2
		self.phalanx_vip.DAMAGE_CLAMP_BULLET = 200.0
		self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = 200.0

		-- THE COMMISSAR
		self.mobster_boss.HEALTH_INIT = 400.0
		self.mobster_boss.headshot_dmg_mul = 2
		-- LIEUTENANT WHO?
		self.biker_boss.HEALTH_INIT = 400.0
		self.biker_boss.headshot_dmg_mul = 2
		-- CHAVEZ
		self.chavez_boss.HEALTH_INIT = 400.0
		self.chavez_boss.headshot_dmg_mul = 2
		-- HECTOR
		self.hector_boss.HEALTH_INIT = 400.0
		self.hector_boss.headshot_dmg_mul = 2
		-- ERNESTO SOSA
		self.drug_lord_boss.HEALTH_INIT = 400.0
		self.drug_lord_boss.headshot_dmg_mul = 2
	end

	if InFmenu.settings.copfalloff == true then
		self.swat.weapon.is_smg.FALLOFF[1].dmg_mul = 2.5 -- 25, 1m
		self.swat.weapon.is_smg.FALLOFF[2].dmg_mul = 2.5 -- 25, 5m
		self.swat.weapon.is_smg.FALLOFF[3].dmg_mul = 2.0 -- 10m
		self.swat.weapon.is_smg.FALLOFF[4].dmg_mul = 1.5 -- 20m
		self.swat.weapon.is_smg.FALLOFF[5].dmg_mul = 1.0 -- 30m

		-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		-- default dmg: ??/80/70/60/60
		-- default acc: ??/70/60/50/35
		self.tank.weapon.is_rifle.focus_delay = 2
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 2.0 -- 40, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 2.0 -- 40, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 1.5 -- 30, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 1.0 -- 20, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 0.5 -- 10, 20-30m
	end

	apply_acc(self.shield.weapon.is_smg, "shield")
	apply_acc(self.shield.weapon.is_pistol, "shield")
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)

Hooks:PostHook(CharacterTweakData, "_set_easy_wish", "sethealthmayhem", function(self)
	self.flashbang_multiplier = 1.5 -- 2

	if InFmenu.settings.sanehp == true then
		-- crooks
		self.gangster.HEALTH_INIT = 10.0
		self.gangster.headshot_dmg_mul = 2
		self.biker.HEALTH_INIT = 10.0
		self.biker.headshot_dmg_mul = 2
		self.captain.HEALTH_INIT = 10.0
		self.captain.headshot_dmg_mul = 2
		self.biker_escape.HEALTH_INIT = 10.0
		self.biker_escape.headshot_dmg_mul = 2
		self.mobster.HEALTH_INIT = 10.0
		self.mobster.headshot_dmg_mul = 2
		self.bolivian.HEALTH_INIT = 10.0
		self.bolivian.headshot_dmg_mul = 2
		self.bolivian_indoors.HEALTH_INIT = 10.0
		self.bolivian_indoors.headshot_dmg_mul = 2
		-- security guards
		self.security.HEALTH_INIT = 10.0
		self.security.headshot_dmg_mul = 2
		self.security_undominatable.HEALTH_INIT = 10.0
		self.security_undominatable.headshot_dmg_mul = 2
		self.mute_security_undominatable.HEALTH_INIT = 10.0
		self.mute_security_undominatable.headshot_dmg_mul = 2
		self.gensec.HEALTH_INIT = 11.0
		self.gensec.headshot_dmg_mul = 2
		-- the boys in blue
		self.cop.HEALTH_INIT = 10.0
		self.cop.headshot_dmg_mul = 2
		self.cop_scared.HEALTH_INIT = 10.0
		self.cop_scared.headshot_dmg_mul = 2
		self.cop_female.HEALTH_INIT = 10.0
		self.cop_female.headshot_dmg_mul = 2
		-- FBIs, whiteshirtblackguy
		self.fbi.HEALTH_INIT = 11.0
		self.fbi.headshot_dmg_mul = 2
		-- blues, HRTs
		self.swat.HEALTH_INIT = 15.0
		self.swat.headshot_dmg_mul = 2
		-- greens
		self.fbi_swat.HEALTH_INIT = 16.0
		self.fbi_swat.headshot_dmg_mul = 2
		-- grays
		self.city_swat.HEALTH_INIT = 20.0
		self.city_swat.headshot_dmg_mul = 2.5
		-- city swats can be knocked down by melee
		self.city_swat.damage.hurt_severity = city_swat_hurts
		-- whiteheads
		self.heavy_swat.HEALTH_INIT = 24.0
		self.heavy_swat.headshot_dmg_mul = 2
		-- tans
		self.fbi_heavy_swat.HEALTH_INIT = 27.0
		self.fbi_heavy_swat.headshot_dmg_mul = 1.8
		self.fbi_heavy_swat.damage.hurt_severity = heavy_swat_hurts
		-- SHIELD
		self.shield.HEALTH_INIT = 11.0
		self.shield.headshot_dmg_mul = 2
		-- SNIPER
		self.sniper.HEALTH_INIT = 7.0
		self.sniper.headshot_dmg_mul = 2
		-- TASER
		self.taser.HEALTH_INIT = 38.5
		self.taser.headshot_dmg_mul = 1.75
		-- MEDIC
		self.medic.HEALTH_INIT = 38.5
		self.medic.headshot_dmg_mul = 1.75
		-- CLOAKER
		self.spooc.HEALTH_INIT = 56.0
		self.spooc.headshot_dmg_mul = 4
		-- BULLDOZER
		self.tank.HEALTH_INIT = 1000.0
		self.tank.headshot_dmg_mul = 20
		self.tank.critical_hits = {damage_mul = 3}
		self.tank_medic.HEALTH_INIT = 1000.0
		self.tank_medic.headshot_dmg_mul = 20
		self.tank_medic.critical_hits = {damage_mul = 3}
		self.tank_mini.HEALTH_INIT = 1000.0 * 1.25
		self.tank_mini.headshot_dmg_mul = 20
		self.tank_mini.critical_hits = {damage_mul = 3}

		-- THE WINTERS BRIGADE
		self.phalanx_minion.HEALTH_INIT = 50.0
		self.phalanx_minion.headshot_dmg_mul = 2
		self.phalanx_minion.damage.explosion_damage_mul = 0.2
		self.phalanx_minion.DAMAGE_CLAMP_BULLET = 100.0
		self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = 100.0
		self.phalanx_vip.HEALTH_INIT = 150.0
		self.phalanx_vip.headshot_dmg_mul = 2
		self.phalanx_vip.damage.explosion_damage_mul = 0.2
		self.phalanx_vip.DAMAGE_CLAMP_BULLET = 200.0
		self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = 200.0

		-- THE COMMISSAR
		self.mobster_boss.HEALTH_INIT = 500.0
		self.mobster_boss.headshot_dmg_mul = 2
		-- LIEUTENANT WHO?
		self.biker_boss.HEALTH_INIT = 500.0
		self.biker_boss.headshot_dmg_mul = 2
		-- CHAVEZ
		self.chavez_boss.HEALTH_INIT = 500.0
		self.chavez_boss.headshot_dmg_mul = 2
		-- HECTOR
		self.hector_boss.HEALTH_INIT = 500.0
		self.hector_boss.headshot_dmg_mul = 2
		-- ERNESTO SOSA
		self.drug_lord_boss.HEALTH_INIT = 500.0
		self.drug_lord_boss.headshot_dmg_mul = 2
	end

	if InFmenu.settings.copfalloff == true then
		self.swat.weapon.is_smg.FALLOFF[1].dmg_mul = 2.5 -- 25, 1m
		self.swat.weapon.is_smg.FALLOFF[2].dmg_mul = 2.5 -- 25, 5m
		self.swat.weapon.is_smg.FALLOFF[3].dmg_mul = 2.0 -- 10m
		self.swat.weapon.is_smg.FALLOFF[4].dmg_mul = 1.5 -- 20m
		self.swat.weapon.is_smg.FALLOFF[5].dmg_mul = 1.0 -- 30m

		-- saigadozers
		-- saiga_npc.DAMAGE = 3.0
		-- default dmg: ??/52.5/45/37.5/30
		-- default acc: ??/90/85/65/50
		self.tank.weapon.is_shotgun_mag.focus_delay = 2
		self.tank.weapon.is_shotgun_mag.FALLOFF[1].dmg_mul = 3.0 -- 90, 0-1m
		self.tank.weapon.is_shotgun_mag.FALLOFF[2].dmg_mul = 3.0 -- 90, 1-5m
		self.tank.weapon.is_shotgun_mag.FALLOFF[3].dmg_mul = 2.5 -- 75, 5-10m
		self.tank.weapon.is_shotgun_mag.FALLOFF[4].dmg_mul = 2.0 -- 60, 10-20m
		self.tank.weapon.is_shotgun_mag.FALLOFF[5].dmg_mul = 1.5 -- 45, 20-30m
		self.tank.weapon.is_shotgun_mag.FALLOFF[6] = deep_clone(self.tank.weapon.is_shotgun_mag.FALLOFF[5])
		self.tank.weapon.is_shotgun_mag.FALLOFF[6].dmg_mul = 1.0 -- 30, 30-60m
		self.tank.weapon.is_shotgun_mag.FALLOFF[6].r = 6000
		-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		-- default dmg: ??/80/70/60/60
		-- default acc: ??/70/60/50/35
		self.tank.weapon.is_rifle.focus_delay = 2
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 2.5 -- 50, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 2.5 -- 50, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 2.0 -- 40, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 1.5 -- 30, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 1.0 -- 20, 20-30m
	end

	apply_acc(self.shield.weapon.is_smg, "shield")
	apply_acc(self.shield.weapon.is_pistol, "shield")
	apply_acc(self.tank.weapon.is_shotgun_mag, "dozer")
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)


Hooks:PostHook(CharacterTweakData, "_set_overkill_290", "sethealthdw", function(self)
	self.flashbang_multiplier = 1.5 -- 2

	if InFmenu.settings.sanehp == true then
		-- crooks
		self.gangster.HEALTH_INIT = 10.0
		self.gangster.headshot_dmg_mul = 2
		self.biker.HEALTH_INIT = 10.0
		self.biker.headshot_dmg_mul = 2
		self.captain.HEALTH_INIT = 10.0
		self.captain.headshot_dmg_mul = 2
		self.biker_escape.HEALTH_INIT = 10.0
		self.biker_escape.headshot_dmg_mul = 2
		self.mobster.HEALTH_INIT = 10.0
		self.mobster.headshot_dmg_mul = 2
		self.bolivian.HEALTH_INIT = 10.0
		self.bolivian.headshot_dmg_mul = 2
		self.bolivian_indoors.HEALTH_INIT = 10.0
		self.bolivian_indoors.headshot_dmg_mul = 2
		-- security guards
		self.security.HEALTH_INIT = 10.0
		self.security.headshot_dmg_mul = 2
		self.security_undominatable.HEALTH_INIT = 10.0
		self.security_undominatable.headshot_dmg_mul = 2
		self.mute_security_undominatable.HEALTH_INIT = 10.0
		self.mute_security_undominatable.headshot_dmg_mul = 2
		self.gensec.HEALTH_INIT = 11.0
		self.gensec.headshot_dmg_mul = 2
		-- the boys in blue
		self.cop.HEALTH_INIT = 10.0
		self.cop.headshot_dmg_mul = 2
		self.cop_scared.HEALTH_INIT = 10.0
		self.cop_scared.headshot_dmg_mul = 2
		self.cop_female.HEALTH_INIT = 10.0
		self.cop_female.headshot_dmg_mul = 2
		-- FBIs, whiteshirtblackguy
		self.fbi.HEALTH_INIT = 11.0
		self.fbi.headshot_dmg_mul = 2
		-- blues, HRTs
		self.swat.HEALTH_INIT = 20.0
		self.swat.headshot_dmg_mul = 2
		-- greens
		self.fbi_swat.HEALTH_INIT = 21.0
		self.fbi_swat.headshot_dmg_mul = 2
		-- grays
		self.city_swat.HEALTH_INIT = 22.0
		self.city_swat.headshot_dmg_mul = 2
		-- can be knocked down by melee
		self.city_swat.damage.hurt_severity = city_swat_hurts
		-- whiteheads
		self.heavy_swat.HEALTH_INIT = 27.0
		self.heavy_swat.headshot_dmg_mul = 1.80
		-- tans
		self.fbi_heavy_swat.HEALTH_INIT = 39.0
		self.fbi_heavy_swat.headshot_dmg_mul = 2.00
		self.fbi_heavy_swat.damage.hurt_severity = heavy_swat_hurts

		-- SHIELD
		self.shield.HEALTH_INIT = 14.0
		self.shield.headshot_dmg_mul = 1.75
		-- SNIPER
		self.sniper.HEALTH_INIT = 10.0
		self.sniper.headshot_dmg_mul = 2
		-- TASER
		self.taser.HEALTH_INIT = 45.5
		self.taser.headshot_dmg_mul = 1.75
		-- MEDIC
		self.medic.HEALTH_INIT = 45.0
		self.medic.headshot_dmg_mul = 1.75
		-- CLOAKER
		self.spooc.HEALTH_INIT = 60.0
		self.spooc.headshot_dmg_mul = 4
		-- BULLDOZER
		self.tank.HEALTH_INIT = 1125.0
		self.tank.headshot_dmg_mul = 15
		self.tank.critical_hits = {damage_mul = 3}
		self.tank_medic.HEALTH_INIT = 1125.0
		self.tank_medic.headshot_dmg_mul = 15
		self.tank_medic.critical_hits = {damage_mul = 3}
		self.tank_mini.HEALTH_INIT = 1125.0 * 1.25
		self.tank_mini.headshot_dmg_mul = 15
		self.tank_mini.critical_hits = {damage_mul = 3}

		-- THE WINTERS BRIGADE
		self.phalanx_minion.HEALTH_INIT = 70.0
		self.phalanx_minion.headshot_dmg_mul = 2
		self.phalanx_minion.damage.explosion_damage_mul = 0.2
		self.phalanx_minion.DAMAGE_CLAMP_BULLET = 100.0
		self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = 100.0
		self.phalanx_vip.HEALTH_INIT = 225.0
		self.phalanx_vip.headshot_dmg_mul = 2
		self.phalanx_vip.damage.explosion_damage_mul = 0.2
		self.phalanx_vip.DAMAGE_CLAMP_BULLET = 200.0
		self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = 200.0

		-- THE COMMISSAR
		self.mobster_boss.HEALTH_INIT = 700.0
		self.mobster_boss.headshot_dmg_mul = 2
		-- LIEUTENANT WHO?
		self.biker_boss.HEALTH_INIT = 700.0
		self.biker_boss.headshot_dmg_mul = 2
		-- CHAVEZ
		self.chavez_boss.HEALTH_INIT = 700.0
		self.chavez_boss.headshot_dmg_mul = 2
		-- HECTOR
		self.hector_boss.HEALTH_INIT = 700.0
		self.hector_boss.headshot_dmg_mul = 2
		-- ERNESTO SOSA
		self.drug_lord_boss.HEALTH_INIT = 700.0
		self.drug_lord_boss.headshot_dmg_mul = 2
	end

	if InFmenu.settings.copfalloff == true then
		-- blues/hrt
		-- default dmg: 67.5/67.5/67.5/67.5/67.5
		-- default acc: 95/75/65/70/60
		self.swat.weapon.is_smg.FALLOFF[1].dmg_mul = 4.0 -- 40, 0-1m
		self.swat.weapon.is_smg.FALLOFF[2].dmg_mul = 4.0 -- 40, 1-5m
		self.swat.weapon.is_smg.FALLOFF[3].dmg_mul = 3.0 -- 30, 5-10m
		self.swat.weapon.is_smg.FALLOFF[4].dmg_mul = 2.0 -- 20, 10-20m
		self.swat.weapon.is_smg.FALLOFF[5].dmg_mul = 1.0 -- 10, 20-30m
		-- greens
		self.fbi_swat.weapon.is_rifle = deep_clone(self.city_swat.weapon.is_rifle)
		-- grays with UMPs
		self.city_swat.weapon.is_smg = deep_clone(self.swat.weapon.is_smg)
		-- whiteheads
		-- m4_npc.DAMAGE = 1.0
		-- default dmg: 75/75/75/75/75/75
		-- default acc: 98/95/90/85/75/70
		self.heavy_swat.weapon.is_rifle.focus_delay = 2
		self.heavy_swat.weapon.is_rifle.FALLOFF[1].dmg_mul = 6.0 -- 60, 0-1m
		self.heavy_swat.weapon.is_rifle.FALLOFF[2].dmg_mul = 6.0 -- 60, 1-5m
		self.heavy_swat.weapon.is_rifle.FALLOFF[3].dmg_mul = 5.5 -- 55, 5-10m
		self.heavy_swat.weapon.is_rifle.FALLOFF[4].dmg_mul = 5.0 -- 50, 10-20m
		self.heavy_swat.weapon.is_rifle.FALLOFF[5].dmg_mul = 4.0 -- 40, 20-30m
		self.heavy_swat.weapon.is_rifle.FALLOFF[6].dmg_mul = 3.0 -- 30, 30-60m
		-- tans
		-- changed g36/ak47_ass npc dmg to 1.0
		-- default dmg: ??/60/45/37.5/30
		-- default acc: ??/90/80/50/35
		self.fbi_heavy_swat.weapon.is_rifle.focus_delay = 2
		self.fbi_heavy_swat.weapon.is_rifle.FALLOFF[1].dmg_mul = 6.0 -- 60, 0-1m
		self.fbi_heavy_swat.weapon.is_rifle.FALLOFF[2].dmg_mul = 6.0 -- 60, 1-5m
		self.fbi_heavy_swat.weapon.is_rifle.FALLOFF[3].dmg_mul = 5.0 -- 50, 5-10m
		self.fbi_heavy_swat.weapon.is_rifle.FALLOFF[4].dmg_mul = 4.0 -- 40, 10-20m
		self.fbi_heavy_swat.weapon.is_rifle.FALLOFF[5].dmg_mul = 3.0 -- 30, 20-30m


		-- reduced damage and accuracy at range
		-- mp9_npc.DAMAGE = 1.0
		-- default dmg: 70/70/70/70/70
		-- default acc: ??/80/65/70/50
		self.shield.weapon.is_smg.focus_delay = 2
		self.shield.weapon.is_smg.FALLOFF[1].dmg_mul = 5.0 -- 50, 0m
		self.shield.weapon.is_smg.FALLOFF[2].dmg_mul = 5.0 -- 50, 0-7m
		self.shield.weapon.is_smg.FALLOFF[3].dmg_mul = 4.0 -- 40, 7-10m
		self.shield.weapon.is_smg.FALLOFF[4].dmg_mul = 3.0 -- 30, 10-20m
		self.shield.weapon.is_smg.FALLOFF[5].dmg_mul = 1.5 -- 15, 20-30m
		-- c45_npc.DAMAGE = 1.0
		-- default dmg: 75/75/75/75/75
		-- default acc: ??/80/75/75/60
		self.shield.weapon.is_pistol.focus_delay = 2
		self.shield.weapon.is_pistol.FALLOFF[1].dmg_mul = 5.0 -- 50, 0m
		self.shield.weapon.is_pistol.FALLOFF[2].dmg_mul = 5.0 -- 50, 0-7m
		self.shield.weapon.is_pistol.FALLOFF[3].dmg_mul = 4.0 -- 40, 7-10m
		self.shield.weapon.is_pistol.FALLOFF[4].dmg_mul = 3.0 -- 30, 10-20m
		self.shield.weapon.is_pistol.FALLOFF[5].dmg_mul = 1.5 -- 15, 20-30m
		-- taser
		-- default dmg: 70/70/70/70/70
		-- default acc: 95/95/90/80/75
		self.taser.weapon.is_rifle.focus_delay = 2
		self.taser.weapon.is_rifle.FALLOFF[1].dmg_mul = 7.0 -- 70, 0-1m
		self.taser.weapon.is_rifle.FALLOFF[2].dmg_mul = 7.0 -- 70, 1-5m
		self.taser.weapon.is_rifle.FALLOFF[3].dmg_mul = 6.0 -- 60, 5-10m
		self.taser.weapon.is_rifle.FALLOFF[4].dmg_mul = 5.0 -- 50, 10-20m
		self.taser.weapon.is_rifle.FALLOFF[5].dmg_mul = 4.0 -- 40, 20-30m
		-- saigadozers
		-- saiga_npc.DAMAGE = 3.0
		-- default dmg: 240/225/210/150/90
		-- default acc: 90/90/85/65/50
		self.tank.weapon.is_shotgun_mag.focus_delay = 2
		self.tank.weapon.is_shotgun_mag.FALLOFF[1].dmg_mul = 5.0 -- 150, 0-1m
		self.tank.weapon.is_shotgun_mag.FALLOFF[2].dmg_mul = 5.0 -- 150, 1-5m
		self.tank.weapon.is_shotgun_mag.FALLOFF[3].dmg_mul = 4.5 -- 135, 5-10m
		self.tank.weapon.is_shotgun_mag.FALLOFF[4].dmg_mul = 4.0 -- 120, 10-20m
		self.tank.weapon.is_shotgun_mag.FALLOFF[5].dmg_mul = 2.5 -- 75, 20-30m
		self.tank.weapon.is_shotgun_mag.FALLOFF[6] = deep_clone(self.tank.weapon.is_shotgun_mag.FALLOFF[5])
		self.tank.weapon.is_shotgun_mag.FALLOFF[6].dmg_mul = 1.5 -- 45, 30-60m
		self.tank.weapon.is_shotgun_mag.FALLOFF[6].r = 6000
		-- LMG dozer
		-- m249_npc.DAMAGE = 2
		-- rpk_lmg_npc.DAMAGE = 2
		-- default dmg: 100/100/100/100/100
		-- default acc: 90/75/60/55/50
		self.tank.weapon.is_rifle.focus_delay = 2
		self.tank.weapon.is_rifle.FALLOFF[1].dmg_mul = 5.0 -- 100, 0-1m
		self.tank.weapon.is_rifle.FALLOFF[2].dmg_mul = 5.0 -- 100, 1-5m
		self.tank.weapon.is_rifle.FALLOFF[3].dmg_mul = 4.0 -- 80, 5-10m
		self.tank.weapon.is_rifle.FALLOFF[4].dmg_mul = 3.0 -- 60, 10-20m
		self.tank.weapon.is_rifle.FALLOFF[5].dmg_mul = 1.5 -- 30, 20-30m
		-- minigun dozer
		-- default dmg: 100/80/70/60/60
		self.tank_mini.weapon.mini.FALLOFF[1].dmg_mul = 5.0 -- 100, 0-1m
		self.tank_mini.weapon.mini.FALLOFF[2].dmg_mul = 5.0 -- 100, 1-5m
		self.tank_mini.weapon.mini.FALLOFF[3].dmg_mul = 4.0 -- 80, 5-10m
		self.tank_mini.weapon.mini.FALLOFF[4].dmg_mul = 3.0 -- 60, 10-20m
		self.tank_mini.weapon.mini.FALLOFF[5].dmg_mul = 1.5 -- 30, 20-30m
	end

	apply_acc(self.swat.weapon.is_smg, "standard")
	apply_acc(self.heavy_swat.weapon.is_rifle, "standard")
	apply_acc(self.fbi_heavy_swat.weapon.is_rifle, "standard")
	apply_acc(self.shield.weapon.is_smg, "shield")
	apply_acc(self.shield.weapon.is_pistol, "shield")
	apply_acc(self.taser.weapon.is_rifle, "standard")
	apply_acc(self.tank.weapon.is_shotgun_mag, "dozer")
	apply_acc(self.tank.weapon.is_rifle, "dozer")
end)

Hooks:PostHook(CharacterTweakData, "_set_sm_wish", "sethealthbraincancer", function(self)
	if InFmenu.settings.copfalloff == true then
		-- undo DS mults first
		self:_multiply_all_speeds(1/4.05, 1/4.1)
		self:_multiply_weapon_delay(self.presets.weapon.sniper, 1/3)
		-- then set DW values
		self:_set_overkill_290()
	end


	self.flashbang_multiplier = 1.5 -- 2

	if InFmenu.settings.sanehp == true then
	-- tentative 
--[[
		-- crooks
		self.gangster.HEALTH_INIT = 10.0
		self.gangster.headshot_dmg_mul = 2
		self.biker.HEALTH_INIT = 10.0
		self.biker.headshot_dmg_mul = 2
		self.captain.HEALTH_INIT = 10.0
		self.captain.headshot_dmg_mul = 2
		self.biker_escape.HEALTH_INIT = 10.0
		self.biker_escape.headshot_dmg_mul = 2
		self.mobster.HEALTH_INIT = 10.0
		self.mobster.headshot_dmg_mul = 2
		self.bolivian.HEALTH_INIT = 10.0
		self.bolivian.headshot_dmg_mul = 2
		self.bolivian_indoors.HEALTH_INIT = 10.0
		self.bolivian_indoors.headshot_dmg_mul = 2
		-- security guards
		self.security.HEALTH_INIT = 10.0
		self.security.headshot_dmg_mul = 2
		self.security_undominatable.HEALTH_INIT = 10.0
		self.security_undominatable.headshot_dmg_mul = 2
		self.mute_security_undominatable.HEALTH_INIT = 10.0
		self.mute_security_undominatable.headshot_dmg_mul = 2
		self.gensec.HEALTH_INIT = 11.0
		self.gensec.headshot_dmg_mul = 2
		-- the boys in blue
		self.cop.HEALTH_INIT = 10.0
		self.cop.headshot_dmg_mul = 2
		self.cop_scared.HEALTH_INIT = 10.0
		self.cop_scared.headshot_dmg_mul = 2
		self.cop_female.HEALTH_INIT = 10.0
		self.cop_female.headshot_dmg_mul = 2
		-- FBIs, whiteshirtblackguy
		self.fbi.HEALTH_INIT = 11.0
		self.fbi.headshot_dmg_mul = 2
		-- blues, HRTs
		self.swat.HEALTH_INIT = 22.0
		self.swat.headshot_dmg_mul = 2
		-- greens
		self.fbi_swat.HEALTH_INIT = 26.0
		self.fbi_swat.headshot_dmg_mul = 2
		-- grays
		self.city_swat.HEALTH_INIT = 30.0
		self.city_swat.headshot_dmg_mul = 2
		-- can be knocked down by melee
		self.city_swat.damage.hurt_severity = city_swat_hurts
		-- whiteheads
		self.heavy_swat.HEALTH_INIT = 34.0
		self.heavy_swat.headshot_dmg_mul = 2
		-- tans
		self.fbi_heavy_swat.HEALTH_INIT = 44.0
		self.fbi_heavy_swat.headshot_dmg_mul = 2.00
		self.fbi_heavy_swat.damage.hurt_severity = heavy_swat_hurts

		-- SHIELD
		self.shield.HEALTH_INIT = 20.0
		self.shield.headshot_dmg_mul = 2
		-- SNIPER
		self.sniper.HEALTH_INIT = 10.0
		self.sniper.headshot_dmg_mul = 2
		-- TASER
		self.taser.HEALTH_INIT = 52.0
		self.taser.headshot_dmg_mul = 1.6
		-- MEDIC
		self.medic.HEALTH_INIT = 52.0
		self.medic.headshot_dmg_mul = 1.6
		-- CLOAKER
		self.spooc.HEALTH_INIT = 63.0
		self.spooc.headshot_dmg_mul = 3.5
		-- BULLDOZER
		self.tank.HEALTH_INIT = 1200.0
		self.tank.headshot_dmg_mul = 12.5
		self.tank.critical_hits = {damage_mul = 3}
		self.tank_medic.HEALTH_INIT = 1200.0
		self.tank_medic.headshot_dmg_mul = 12.5
		self.tank_medic.critical_hits = {damage_mul = 3}
		self.tank_mini.HEALTH_INIT = 1200.0 * 1.25
		self.tank_mini.headshot_dmg_mul = 12.5
		self.tank_mini.critical_hits = {damage_mul = 3}

		-- THE WINTERS BRIGADE
		self.phalanx_minion.HEALTH_INIT = 70.0
		self.phalanx_minion.headshot_dmg_mul = 2
		self.phalanx_minion.damage.explosion_damage_mul = 0.2
		self.phalanx_minion.DAMAGE_CLAMP_BULLET = 100.0
		self.phalanx_minion.DAMAGE_CLAMP_EXPLOSION = 100.0
		self.phalanx_vip.HEALTH_INIT = 225.0
		self.phalanx_vip.headshot_dmg_mul = 2
		self.phalanx_vip.damage.explosion_damage_mul = 0.2
		self.phalanx_vip.DAMAGE_CLAMP_BULLET = 200.0
		self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = 200.0

		-- THE COMMISSAR
		self.mobster_boss.HEALTH_INIT = 700.0
		self.mobster_boss.headshot_dmg_mul = 2
		-- LIEUTENANT WHO?
		self.biker_boss.HEALTH_INIT = 700.0
		self.biker_boss.headshot_dmg_mul = 2
		-- CHAVEZ
		self.chavez_boss.HEALTH_INIT = 700.0
		self.chavez_boss.headshot_dmg_mul = 2
		-- HECTOR
		self.hector_boss.HEALTH_INIT = 700.0
		self.hector_boss.headshot_dmg_mul = 2
		-- ERNESTO SOSA
		self.drug_lord_boss.HEALTH_INIT = 700.0
		self.drug_lord_boss.headshot_dmg_mul = 2
--]]
	end

--[[
	apply_acc(self.swat.weapon.is_smg, "standard")
	apply_acc(self.heavy_swat.weapon.is_rifle, "standard")
	apply_acc(self.fbi_heavy_swat.weapon.is_rifle, "standard")
	apply_acc(self.shield.weapon.is_smg, "shield")
	apply_acc(self.shield.weapon.is_pistol, "shield")
	apply_acc(self.taser.weapon.is_rifle, "standard")
	apply_acc(self.tank.weapon.is_shotgun_mag, "dozer")
	apply_acc(self.tank.weapon.is_rifle, "dozer")
--]]
end)

-- Make winters no longer invincible, should be a guaranteed fix for him refusing to leave
Hooks:PostHook(CharacterTweakData, "_init_phalanx_vip", "inf_chartweak_wintersdieswhenheiskilled", function(self, presets)
	-- People die when you shoot at them
	self.phalanx_vip.LOWER_HEALTH_PERCENTAGE_LIMIT = nil
	self.phalanx_vip.FINAL_LOWER_HEALTH_PERCENTAGE_LIMIT = nil
end)

-- Change the surrender preset to a harder one
-- Thanks, Kuziz
if InFmenu and InFmenu.settings.enablenewcopdomination then
	Hooks:PostHook(CharacterTweakData, "init", "InF_chartweakinit_setsurrenderchances", function(self)
		-- Easy surrender preset, used for guards and easier cops
		local surrender_preset_easy = {
			base_chance = 0.75,
			significant_chance = 0.1,
			violence_timeout = 2,
			reasons = {
				health = {
					[1] = 0.2,
					[0.3] = 1
				},
				weapon_down = 0.8,
				pants_down = 1,
				isolated = 0.1
			},
			factors = {
				flanked = 0.07,
				unaware_of_aggressor = 0.08,
				enemy_weap_cold = 0.15,
				aggressor_dis = {
					[1000] = 0.02,
					[300] = 0.15
				}
			}
		}
		
		-- Normal preset, really just used for HRT's and first responders
		local surrender_preset_normal = {
			base_chance = 0.5,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				health = {
					[1] = 0,
					[0.4] = 0.5
				},
				weapon_down = 0.2,
				pants_down = 0.8
			},
			factors = {
				isolated = 0.1,
				flanked = 0.04,
				unaware_of_aggressor = 0.1,
				enemy_weap_cold = 0.05,
				aggressor_dis = {
					[1000] = 0,
					[300] = 0.1
				}
			}
		}

		-- Harder preset, used for nearly every cop
		local surrender_preset_hard = {
			base_chance = 0.35,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				health = {
					[1] = 0,
					[0.35] = 0.5
				},
				weapon_down = 0.2,
				pants_down = 0.8
			},
			factors = {
				isolated = 0.1,
				flanked = 0.04,
				unaware_of_aggressor = 0.1,
				enemy_weap_cold = 0.05,
				aggressor_dis = {
					[1000] = 0,
					[300] = 0.1
				}
			}
		}
		
		-- Give most non-special assault units the "hard" preset
		self.fbi_swat.surrender = surrender_preset_hard
		self.swat.surrender = surrender_preset_hard
		self.heavy_swat.surrender = surrender_preset_hard
		self.fbi_heavy_swat.surrender = surrender_preset_hard
		self.fbi_swat.surrender = surrender_preset_hard
		self.city_swat.surrender = surrender_preset_hard

		-- Give the guards an easy preset
		self.security.surrender = surrender_preset_easy

		-- And override the HRT's and first responder presets with "normal" ones
		self.cop.surrender = surrender_preset_normal
		self.fbi.surrender = surrender_preset_normal
	end)
end

if InFmenu and InFmenu.settings.enablenewcopvoices then
	local is_america = false
	local is_murky = false
	Hooks:PreHook(CharacterTweakData, "init", "inf_chartweak_copvoicefilters_determineregion", function(self)
		is_america = false
		is_murky = false
	end)

	-- Add voice filter to US cops
	Hooks:PostHook(CharacterTweakData, "_init_region_america", "inf_chartweak_copvoicefilters_america", function(self)
		is_america = true
	end)

	-- Not working somehow, guess murkies will just have to have their new voices
	Hooks:PostHook(CharacterTweakData, "_init_region_murkywater", "inf_chartweak_copvoicefilters_murky", function(self)
		is_murky = true
	end)

	Hooks:PostHook(CharacterTweakData, "_init_fbi_heavy_swat", "inf_chartweak_fbi_heavy_swat_init", function(self)
		if is_america then
			self.fbi_heavy_swat.speech_prefix_p1 = "l"
			self.fbi_heavy_swat.speech_prefix_count = 5
			self.fbi_heavy_swat.speech_prefix_p2 = "d"
		end
	end)

	Hooks:PostHook(CharacterTweakData, "_init_fbi_swat", "inf_chartweak_fbi_swat_init", function(self)
		if is_america and not is_murky then
			self.fbi_swat.speech_prefix_p1 = "l"
			self.fbi_swat.speech_prefix_p2 = "d"
		end
	end)

	Hooks:PostHook(CharacterTweakData, "_init_city_swat", "inf_chartweak_city_swat_init", function(self)
		if is_america then
			self.city_swat.speech_prefix_p1 = "l"
			self.city_swat.speech_prefix_p2 = "d"
		end
	end)

	Hooks:PostHook(CharacterTweakData, "_init_gangster", "inf_chartweak_gangster_init", function(self, presets)
		local job_speech_prefixes = {
			russian = { -- Russian gangsters that Vlad doesn't like
				p1 = "rt",
				p2 = nil,
				count = 2
			},
			ovkmc = { -- Overkill MC (Big Oil)
				p1 = "ict",
				p2 = nil,
				count = 2
			},
			taxman_dealer = { -- Sturr's deal in Undercover, gangsters are actually Undercover cops. TODO: Change their team to cop
				p1 = "l",
				p2 = "n",
				count = 4,
				gangster_is_cop = true
			},
			default = { -- Default gangster chatter (Rats etc.)
				p1 = "lt",
				p2 = nil,
				count = 2
			}
		}

		local jobs_speech = {
			nightclub = job_speech_prefixes.russian,
			short2_stage1 = job_speech_prefixes.russian,
			jolly = job_speech_prefixes.russian,
			spa = job_speech_prefixes.russian,
			alex_2 = job_speech_prefixes.ovkmc,
			welcome_to_the_jungle_1 = job_speech_prefixes.ovkmc,
			man = job_speech_prefixes.taxman_dealer
		}

		local job = Global.level_data and Global.level_data.level_id
		if job and jobs_speech[job] then
			-- Use the provided gangster speech type for this job
			self.gangster.speech_prefix_p1 = jobs_speech[job].p1
			self.gangster.speech_prefix_count = jobs_speech[job].count
			self.gangster.speech_prefix_p2 = jobs_speech[job].p2

			if jobs_speech[job].gangster_is_cop then
				-- If the gangsters are undercover cops, give them the same attributes as cops (rescue hostages, arrest players)
				self.gangster.no_arrest = false
				self.gangster.rescue_hostages = true
				self.gangster.use_radio = self._default_chatter	
			end
		else
			-- Job is either nil or there's no special gangster speech override defined for this job.
			-- In that case, use the default speech.
			self.gangster.speech_prefix_p1 = job_speech_prefixes.default.p1
			self.gangster.speech_prefix_count = job_speech_prefixes.default.count
			self.gangster.speech_prefix_p2 = job_speech_prefixes.default.p2
		end

		-- Make the gangsters actually use their voicelines (thanks Zdann)
		self.gangster.chatter = {
			aggressive = true,
			retreat = true,
			contact = true,
			go_go = true,
			suppress = true
		}
	end)
end

-- Buff tans a little by giving their body armor an incoming damage penalty
-- Penalty depends on weapon
if InFmenu.settings.sanehp == true then
	Hooks:PostHook(CharacterTweakData, "_init_fbi_heavy_swat", "inf_chartweak_init_tan_bodyarmor", function(self)
		-- This penalty will be reduced for heavier weapons only, depending on the weapon type
		-- In the end, the damage multiplier is (1 - penalty)
		self.fbi_heavy_swat.body_armor_dmg_penalty = 0.9

		-- Headshot damage penalty for if they still have their helmets
		self.fbi_heavy_swat.headgear_dmg_penalty = 0.75

		-- The chance for their helmet to fly off on a non-lethal shot
		-- Value between 0-1, higher is more chance
		self.fbi_heavy_swat.headgear_flyoff_chance = 0.5
	end)
end

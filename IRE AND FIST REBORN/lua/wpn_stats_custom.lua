local function checkfolders(subfolder, file)
	local filename = file or "main.xml"
	if SystemFS:exists("mods/" .. subfolder .. "/" .. filename) or SystemFS:exists("assets/mod_overrides/" .. subfolder .. "/" .. filename) then
		return true
	end
	return false
end

local function kick_mult(array, sv, sh, cv, ch, adsv, adsh)
	if not array.standing then
		log("OH SHIT WHAT YOU ARE DOING WHY DID YOU PASS A NON-KICK TO KICK_MULT")
	else
		local newarray = {}
		newarray.standing = {array.standing[1] * sv, array.standing[2] * sv, array.standing[3] * sh, array.standing[4] * sh}
		newarray.crouching = {array.crouching[1] * cv, array.crouching[2] * cv, array.crouching[3] * ch, array.crouching[4] * ch}
		newarray.steelsight = {array.steelsight[1] * adsv, array.steelsight[2] * adsv, array.steelsight[3] * adsh, array.steelsight[4] * adsh}
		return newarray
	end
end

local function rtable_mult(array, vert, horiz)
	local newarray = {}
	for a = 1, #array do
		newarray[a] = {}
		newarray[a][1] = array[a][1] * vert
		newarray[a][2] = array[a][2] * vert
		newarray[a][3] = array[a][3] * horiz
		newarray[a][4] = array[a][4] * horiz
	end
	return newarray
end

local pivot_shoulder_translation = nil
local pivot_shoulder_rotation = nil
local pivot_head_translation = nil
local pivot_head_rotation = nil

function WeaponTweakData:_inf_init_custom_weapons(lmglist)
    -- STUFF FOR CUSTOM WEAPONs GOES HERE
    -- This stuff is all wrapped in a pcall if debug is disabled, if anything goes wrong it won't crash your whole game.
    -- NOTE THAT THIS MEANS ERRORS ARE BASICALLY EATEN unless "debug" mode is turned off in the InF options.
    -- When adding your own support, ALWAYS have debug enabled so it crashes early and crashes hard.
    -- Any errors in this file means that custom weapons won't have proper stats,
    -- and this might very rarely cause you to lose some custom weapons you have in your inventory 
    -- if something would be "wrong with them".
	-- You can just rebuy them of course, but still.

	-- Vikhr/SR Einheri
	if BeardLib.Utils:ModLoaded("SR-3M Vikhr") then
		self:inf_init("sr3m", "ar", {"medium"})
		self.sr3m.sdesc1 = "caliber_r9x39"
		self.sr3m.sdesc2 = "action_gas"
		self.sr3m.fire_mode_data.fire_rate = 60/900
		self.sr3m.auto.fire_rate = 60/900
		self.sr3m.stats.spread = self.sr3m.stats.spread - 10
		self.sr3m.stats.concealment = 24
		self:copy_timers("sr3m", "asval")
		self.sr3m.reload_speed_mult = self.sr3m.reload_speed_mult * self:convert_reload_to_mult("mag_150")
	end

	-- CZ-75 Shadow
	if BeardLib.Utils:ModLoaded("cz") then
		Hooks:RemovePostHook("czModInit")
		self:inf_init("cz", "pistol", nil)
		self.cz.sdesc1 = "caliber_p9x19"
		self.cz.sdesc2 = "action_shortrecoil"
		self:copy_timers("cz", "b92fs")
		self.cz.stats.concealment = 30
		self.cz.AMMO_MAX = 144
		self.cz.AMMO_PICKUP = self:_pickup_chance(144, 1)

		self:inf_init("x_cz", "pistol", nil)
		self:copy_sdescs("x_cz", "cz", true)
		self.x_cz.stats.concealment = 30
		self.x_cz.AMMO_MAX = 180
		self.x_cz.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self:copy_timers("x_cz", "x_b92fs")
	end

	-- MA DEUCE
	if BeardLib.Utils:ModLoaded("M2HB_HMG") then
		self:inf_init("m2hb", "lmg", nil)
		self.m2hb.categories = {"lmg"}
		self.m2hb.sdesc1 = "caliber_r50bmg"
		self.m2hb.sdesc2 = "action_shortrecoil"
		self.m2hb.fire_mode_data.fire_rate = 60/500
		self.m2hb.stats.damage = 110
		self.m2hb.stats.spread = 81
		self.m2hb.stats.recoil = self.m2hb.stats.recoil - 35
		self.m2hb.stats.concealment = 10
		self.m2hb.stats_modifiers = {} -- clear the 2x mult
		self.m2hb.CLIP_AMMO_MAX = 50
		self.m2hb.AMMO_MAX = 150
		self.m2hb.AMMO_PICKUP = self:_pickup_chance(125, 1)
		self.m2hb.not_empty_reload_speed_mult = 1.10
		self.m2hb.timers.reload_not_empty = 4.40
		self.m2hb.timers.reload_not_empty_end = 1.50 -- 5.36
		self.m2hb.empty_reload_speed_mult = 1.10
		self.m2hb.timers.reload_empty = self.m2hb.timers.reload_not_empty
		self.m2hb.timers.reload_empty_end = self.m2hb.timers.reload_not_empty_end
		self.m2hb.deploy_anim_override = "hk21"
		self.m2hb.deploy_ads_stance_mod = {translation = Vector3(0, 4, 0.5)}
		table.insert(lmglist, "m2hb")
	end

	-- MATEBA 6 UNICA
	if BeardLib.Utils:ModLoaded("Mateba Model 6 Unica") then
		self:inf_init("unica6", "pistol", "heavy")
		self.unica6.sdesc1 = "caliber_p357"
		self.unica6.sdesc2 = "action_mateba"
		self.unica6.chamber = 0
		self.unica6.stats.concealment = 28
		self:copy_timers("unica6", "new_raging_bull")
	end


	if BeardLib.Utils:ModLoaded("Contender Special") then
		self:inf_init("contender", "pistol", "heavy")
		self.contender.sdesc1 = "caliber_r68"
		self.contender.sdesc2 = "action_breakopen"
		InFmenu.has_secondary_sniper = true
		self.contender.recategorize = "snp"
		self.contender.categories = {"snp"}
		self.contender.use_shotgun_reload = false -- defaulted to true, fucks with reload timers
		self.contender.damage_near = 12000
		self.contender.damage_far = 13000
		self.contender.chamber = 0
		self.contender.stats.concealment = 25
		-- don't suddenly increase spread when hipfiring shotgun ammo
		self.contender.spread.standing = 0.15
		self.contender.spread.crouching = self.contender.spread.standing
		self.contender.spread.steelsight = self.contender.spread.standing
		self.contender.spread.moving_standing = self.contender.spread.standing
		self.contender.spread.moving_crouching = self.contender.spread.standing
		self.contender.spread.moving_steelsight = self.contender.spread.standing
		self.contender.spreadadd.standing = 0
		self.contender.spreadadd.crouching = 0
		self.contender.spreadadd.steelsight = 0
		self.contender.spreadadd.moving_standing = 0
		self.contender.spreadadd.moving_crouching = 0
		self.contender.spreadadd.moving_steelsight = 0
		self.contender.kick = InFmenu.rstance.shotgun
		self.contender.AMMO_MAX = 20
		self.contender.AMMO_PICKUP = self:_pickup_chance(20, 1)
		self.contender.fire_mode_data.fire_rate = 60/60
		self.contender.stats.damage = 80 -- 400
		self.contender.stats.spread = 81
		self.contender.stats.recoil = self.contender.stats.recoil - 15
		self.contender.stats_modifiers = {damage = 5}
		self:copy_timers("contender", "gre_m79")
		self.contender.reload_speed_mult = 2.00
		self.contender.can_shoot_through_shield = true
		self.contender.can_shoot_through_wall = true
		self.contender.can_shoot_through_enemy = true
	end

	if BeardLib.Utils:ModLoaded("m1c") then
		self:inf_init("m1c", "ar", {"ldmr"})
		self.m1c.sdesc1 = "caliber_r30carbine"
		self.m1c.sdesc2 = "action_gasshort"
		self.m1c.AMMO_MAX = 90
		self.m1c.AMMO_PICKUP = self:_pickup_chance(90, 1)
		self:copy_timers("m1c", "new_m14")
		self.m1c.reload_speed_mult = self.m1c.reload_speed_mult * self:convert_reload_to_mult("mag_75")
		self.m1c.stats.concealment = 23
	end


	if BeardLib.Utils:ModLoaded("Tokarev SVT-40") then
		self:inf_init("svt40", "ar", {"dmr"})
		self.svt40.sdesc1 = "caliber_r762x54r"
		self.svt40.sdesc2 = "action_gasshort"
		self:copy_timers("svt40", "siltstone")
		self.svt40.stats.concealment = 23
	end

	if BeardLib.Utils:ModLoaded("AN-94 AR") then
		self:inf_init("akrocket", "ar", nil)
		self.akrocket.categories = {"assault_rifle"}
		self.akrocket.sdesc1 = "caliber_r545x39"
		self.akrocket.sdesc2 = "action_an94"
		self.akrocket.FIRE_MODE = "single"
		self.akrocket.CAN_TOGGLE_FIREMODE = false
		self.akrocket.BURST_FIRE = 999
		self.akrocket.BURST_FIRE_RATE_MULTIPLIER = 1
		self.akrocket.BURST_RECOIL_MULT = 1
		self.akrocket.burst_fire_rate_table = {3, 1}
		self.akrocket.burst_recoil_table = {0, 2, 1}
		self.akrocket.min_adaptive_burst_length = 2 -- doesn't even require adaptive burst to be active
		self.akrocket.chamber = 2
		self.akrocket.stats.concealment = 20
		self.akrocket.abakanload = true
		--self.akrocket.burst_fire_rate_multiplier_shots = 2
		--self.akrocket.burst_recoil_multiplier_shots = 2
		self:copy_timers("akrocket", "akmsu")
	end

	if BeardLib.Utils:ModLoaded("tilt") then
		Hooks:RemovePostHook("tiltModInit")
		self:inf_init("tilt", "ar", nil)
		self.tilt.sdesc1 = "caliber_r545x39"
		self.tilt.sdesc2 = "action_an94"
		self.tilt.FIRE_MODE = "single"
		self.tilt.CAN_TOGGLE_FIREMODE = false
		self.tilt.BURST_FIRE = 999
		self.tilt.BURST_FIRE_RATE_MULTIPLIER = 1
		self.tilt.BURST_RECOIL_MULT = 1
		self.tilt.burst_fire_rate_table = {3, 1}
		self.tilt.burst_recoil_table = {0, 2, 1}
		self.tilt.min_adaptive_burst_length = 2 -- doesn't even require adaptive burst to be active
		self.tilt.chamber = 2
		self.tilt.stats.concealment = 21
		self.tilt.abakanload = true
		--self.tilt.burst_fire_rate_multiplier_shots = 2
		--self.tilt.burst_recoil_multiplier_shots = 2
		self:copy_timers("tilt", "flint")
	end

	if BeardLib.Utils:ModLoaded("Makarov Pistol") then
		self:inf_init("pm", "pistol", "medium")
		self.pm.sdesc1 = "caliber_p9x18"
		self.pm.sdesc2 = "action_blowbackstraight"
		self:copy_timers("pm", "b92fs")
		self.pm.reload_speed_mult = self.pm.reload_speed_mult * self:convert_reload_to_mult("mag_50")
		--self.pm.stats.concealment = 30

		self:inf_init("x_pm", "pistol", "medium")
		self:copy_sdescs("x_pm", "pm", true)
		self.x_pm.CLIP_AMMO_MAX = self.pm.CLIP_AMMO_MAX * 2
		self.x_pm.stats.recoil = self.x_pm.stats.recoil + 5
		--self.x_pm.stats.concealment = 30
		self.x_pm.AMMO_MAX = 96
		self.x_pm.AMMO_PICKUP = self:_pickup_chance(96, 1)
		--self.x_pm.price = self.pm.price * 1.5
		self:copy_timers("x_pm", "x_b92fs")
		self.x_pm.reload_speed_mult = self.x_pm.reload_speed_mult * self:convert_reload_to_mult("mag_50")

		self.xs_pm.categories = {"pistol", "akimbo"}
		self:inf_init("xs_pm", "pistol", "medium")
		self.xs_pm.recategorize = "pistol_m"
		self.xs_pm.no_akimbo_autocategorize = true
		self:copy_sdescs("xs_pm", "pm", true)
		self.xs_pm.CLIP_AMMO_MAX = self.pm.CLIP_AMMO_MAX * 2
		--self.xs_pm.price = self.pm.price * 1.5
		self:copy_timers("xs_pm", "x_b92fs")
		self.xs_pm.reload_speed_mult = self.xs_pm.reload_speed_mult * self:convert_reload_to_mult("mag_50")
		self.xs_pm.stats.concealment = 26
	end

	if BeardLib.Utils:ModLoaded("Remington Various Attachment") then
		-- removed the stat fix (bitch i got my own stats)
		Hooks:RemovePostHook("R870AttachModInit")
		
		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("r870", {
				name = "a_o_mcs",
				base_a_obj = "a_o",
				position = Vector3(0, 5, -0.35),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("r870", {
				name = "a_ns_heat",
				base_a_obj = "a_ns",
				position = Vector3(0, 5, 0),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("r870", {
				name = "a_fl_mcs",
				base_a_obj = "a_fl",
				position = Vector3(2.9, -5.8, 3.9),
				rotation = Rotation(0, 0, -90)
			})

			self:SetupAttachmentPoint("serbu", {
				name = "a_fl_mcs",
				base_a_obj = "a_fl",
				position = Vector3(2.9, -5.8, 3.9),
				rotation = Rotation(0, 0, -90)
			})
			self:SetupAttachmentPoint("serbu", {
				name = "a_o_mcs",
				base_a_obj = "a_o",
				position = Vector3(0, 5, -0.35),
				rotation = Rotation(0, 0, 0)
			})
		end
	end


	if BeardLib.Utils:ModLoaded("Winchester Model 1912") then
		self:inf_init("m1912", "shotgun", {"rof_slow", "range_slowpump"})
		self.m1912.sdesc1 = "caliber_s12g"
		self.m1912.sdesc2 = "action_pump"
		self.m1912.AMMO_MAX = 40
		self.m1912.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self.m1912.stats.spread = self.m1912.stats.spread + 20
		self:copy_timers("m1912", "m37")
		self.m1912.stats.concealment = 19
	end


	if BeardLib.Utils:ModLoaded("KS-23") then
		self:inf_init("ks23", "shotgun", {"dmg_heavy"})
		self.ks23.sdesc1 = "caliber_s23mm"
		self.ks23.sdesc2 = "action_pump"
		self.ks23.stats.damage = 100 -- 500 --80 -- 400
		self.ks23.AMMO_MAX = 6
		self.ks23.AMMO_PICKUP = {1338, 100}
		self.ks23.damage_near = 1500
		self.ks23.damage_far = 3000
		self.ks23.armor_piercing_chance = 1
		self.ks23.equip_speed_mult = 1.25
		self.ks23.timers.equip = self.ks23.timers.equip/self.ks23.equip_speed_mult
		self:copy_timers("ks23", "china")
		self.ks23.anim_speed_mult = 1.50
		self.ks23.fire_mode_data.fire_rate = 1.5/self.ks23.anim_speed_mult
		self.ks23.reload_speed_mult = self.ks23.reload_speed_mult
		self.ks23.equip_stance_mod = {ads = {translation = Vector3(0, 0, -4), rotation = Rotation(0, 0, 0)}}
		self.ks23.stats.concealment = 19
	end

	if BeardLib.Utils:ModLoaded("Marlin Model 1894 Custom") then
		InFmenu.has_secondary_sniper = true
		self:inf_init("m1894", "snp", nil)
		self.m1894.recategorize = "snp"
		self.m1894.sdesc1 = "caliber_p44"
		self.m1894.sdesc2 = "action_lever"
		self:copy_timers("m1894", "winchester1874")
		self.m1894.stats.damage = 56 -- 280
		self.m1894.stats.spread = self.m1894.stats.spread - 10
		self.m1894.stats.recoil = self.m1894.stats.recoil - 5
		self.m1894.stats.concealment = 26
		--self.m1894.stats.concealment = 23
		--self.m1894.anim_speed_mult = 1.20
		--self.m1894.hipfire_uses_ads_anim = true
		self.m1894.AMMO_MAX = 24
		self.m1894.AMMO_PICKUP = self:_pickup_chance(24, 1)
	end

	-- primary SVU/SVU-T
	if BeardLib.Utils:ModLoaded("svudragunov") then
		self:inf_init("svudragunov", "ar", {"dmr"})
		self.svudragunov.sdesc1 = "caliber_r762x54r"
		self.svudragunov.sdesc2 = "action_gas"
		self.svudragunov.stats.spread = self.svudragunov.stats.spread
		self.svudragunov.stats.recoil = self.svudragunov.stats.recoil + 6
		self.svudragunov.stats.concealment = 20
		self.svudragunov.stats.alert_size = 19
		self.svudragunov.stats.suppression = 22
		self.svudragunov.shake.fire_multiplier = 1.75
		self.svudragunov.shake.fire_steelsight_multiplier = 1.50
		self.svudragunov.CLIP_AMMO_MAX = 10
		self:copy_timers("svudragunov", "desertfox")
		self.svudragunov.anim_speed_mult = 0.00001 -- basically no anim
	end

	-- secondary SVU
	if BeardLib.Utils:ModLoaded("SVU") then
		InFmenu.has_secondary_dmr = true
		self:inf_init("svu", "ar", {"dmr"})
		self.svu.sdesc1 = "caliber_r762x54r"
		self.svu.sdesc2 = "action_gas"
		self.svu.sdesc3_is_range = false
		self.svu.display_fulldesc_range = false
		self.svu.stats.concealment = 18
		self.svu.AMMO_MAX = 20
		self.svu.AMMO_PICKUP = self:_pickup_chance(20, 1)
		self:copy_timers("svu", "basset")
		-- base timers+end: 2.60/3.10
		self.svu.not_empty_reload_speed_mult = 1.15 -- 2.26
		--self.svu.empty_reload_speed_mult = 1
	end

	if BeardLib.Utils:ModLoaded("Gewehr 43") then
		self:inf_init("g43", "ar", {"dmr"})
		self.g43.sdesc1 = "caliber_r792mauser"
		self.g43.sdesc2 = "action_gasshort"
		-- base 2.88/3.61
		self:copy_timers("g43", "fal")
		self.g43.reload_speed_mult = self.g43.reload_speed_mult * 0.90
		self.g43.stats.concealment = 20
	end

	if BeardLib.Utils:ModLoaded("Mosin Nagant M9130 Obrez") then
		InFmenu.has_secondary_sniper = true
		self:inf_init("obrez", "snp", "heavy")
		self.obrez.sdesc1 = "caliber_r762x54r"
		self.obrez.sdesc2 = "action_bolt"
		self.obrez.recategorize = "snp"
		self.obrez.chamber = 0
		self:copy_timers("obrez", "mosin")
		self.obrez.muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath"
		self.obrez.stats.spread = self.mosin.stats.spread - 30
		self.obrez.stats.recoil = self.mosin.stats.recoil - 10
		self.obrez.stats.concealment = 23
		self.obrez.AMMO_MAX = 15
		self.obrez.AMMO_PICKUP = self:_pickup_chance(15, 1)
	end

	if BeardLib.Utils:ModLoaded("BAR LMG") then
		self:inf_init("bar", "ar", {"heavy"})
		self.bar.categories = {"assault_rifle"}
		self.bar.can_shoot_through_enemy = false
		self.bar.sdesc1 = "caliber_r3006"
		self.bar.sdesc2 = "action_gas"
		self:copy_timers("bar", "fal")
		self.bar.stats.recoil = self.bar.stats.recoil + 5
		self.bar.stats.concealment = 19
		self.bar.reload_speed_mult = 0.90
		table.insert(lmglist, "bar")
		self:apply_standard_bipod_stats("bar")
		self.bar.custom_bipod = true
		--self.bar.use_bipod_anywhere = true
		self.bar.bipod_weapon_translation = Vector3(-5, -6, 0)
		pivot_shoulder_translation = Vector3(10.6138, 20, -4.8)
		pivot_shoulder_rotation = Rotation(0.106543, -0.0842801, 0.628575)
		pivot_head_translation = Vector3(-0.02, 14, -0.40)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.bar.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.bar.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.bar.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		--self.bar.use_custom_anim_state = true
	end

	if BeardLib.Utils:ModLoaded("QBZ-97B") then
		self:inf_init("qbz97b", "smg", {"range_carbine"})
		self.qbz97b.sdesc1 = "caliber_r556x45"
		self.qbz97b.sdesc2 = "action_pistonshort"
		self.qbz97b.fire_mode_data.fire_rate = 60/800
		self:copy_timers("qbz97b", "famas")
		self.qbz97b.stats.concealment = 25
	end

	if BeardLib.Utils:ModLoaded("Seburo M5") then
		Hooks:RemovePostHook("seburoM5Init")

		self:inf_init("seburo", "pistol", nil)
		self.seburo.sdesc1 = "caliber_p545x18"
		self.seburo.sdesc2 = "action_shortrecoil"
		self.seburo.stats.concealment = 30
		self.seburo.AMMO_MAX = 140
		self.seburo.AMMO_PICKUP = self:_pickup_chance(140, 1)
		self:copy_timers("seburo", "packrat")

		self.x_seburo.categories = {"akimbo", "pistol"}
		self.x_seburo.stats.concealment = 30
		self:inf_init("x_seburo", "pistol", nil)
		self:copy_sdescs("x_seburo", "seburo", true)
		self.x_seburo.AMMO_MAX = 160
		self.x_seburo.AMMO_PICKUP = self:_pickup_chance(160, 1)
		self:copy_timers("x_seburo", "x_packrat")

		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5fl",
				base_a_obj = "a_fl",
				position = Vector3( 0, -1, -2.5 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5ns",
				base_a_obj = "a_ns", 
				position = Vector3( 0.1, -2, 0.1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5rds",
				base_a_obj = "a_rds", 
				position = Vector3( 0, 0, -1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5re_body",
				base_a_obj = "a_body", 
				position = Vector3( 0, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5re_sl",
				base_a_obj = "a_sl", 
				position = Vector3( 0, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5re_m",
				base_a_obj = "a_m", 
				position = Vector3( -0.35, 0, 0.35 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5ext_m",
				base_a_obj = "a_m", 
				position = Vector3( 0, -0.2, 0 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("seburo", {
				name = "a_seburo5re_bolt",
				base_a_obj = "a_bolt", 
				position = Vector3( 0.1, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})

			-- Same but for akimbo seburo
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5fl",
				base_a_obj = "a_fl",
				position = Vector3( 0, -1, -2.5 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5ns",
				base_a_obj = "a_ns", 
				position = Vector3( 0.1, -2, 0.1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5rds",
				base_a_obj = "a_rds", 
				position = Vector3( 0, 0, -1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5re_body",
				base_a_obj = "a_body", 
				position = Vector3( 0, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5re_sl",
				base_a_obj = "a_sl", 
				position = Vector3( 0, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5re_m",
				base_a_obj = "a_m", 
				position = Vector3( -0.35, 0, 0.35 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5ext_m",
				base_a_obj = "a_m", 
				position = Vector3( 0, -0.2, 0 ), 
				rotation = Rotation( 0, 0, 0 )
			})
			self:SetupAttachmentPoint("x_seburo", {
				name = "a_seburo5re_bolt",
				base_a_obj = "a_bolt", 
				position = Vector3( 0.1, 0, 1 ), 
				rotation = Rotation( 0, 0, 0 )
			})
		end
	end

	if BeardLib.Utils:ModLoaded("HKG11") then
		self:inf_init("temple", "ar", nil)
		self.temple.sdesc1 = "caliber_r473x33"
		self.temple.sdesc2 = "action_gas"
		self.temple.stats.concealment = 21
		self.temple.BURST_FIRE = 3
		self.temple.ADAPTIVE_BURST_SIZE = false
		self.temple.BURST_FIRE_RATE_MULTIPLIER = 2100/460
		self.temple.DELAYED_BURST_RECOIL = false
		self.temple.burst_recoil_table = {0.25, 1.75}
		self.temple.AMMO_MAX = 150
		self.temple.AMMO_PICKUP = self:_pickup_chance(150, 1)
		self:copy_timers("temple", "rpg7")
		self.temple.not_empty_reload_speed_mult = 2.45 * self:convert_reload_to_mult("mag_150")
		self.temple.empty_reload_speed_mult = 1.95 * 0.80 * self:convert_reload_to_mult("mag_150")
		self.temple.timers.unequip = 0.7
	end

	if BeardLib.Utils:ModLoaded("Beretta 93R") then
		self:inf_init("b93r", "pistol", nil)
		self.b93r.sdesc1 = "caliber_p9x19"
		self.b93r.sdesc2 = "action_shortrecoil"
		--self.b93r.stats.concealment = 29
		self.b93r.AMMO_MAX = 140
		self.b93r.AMMO_PICKUP = self:_pickup_chance(140, 1)
		self.b93r.BURST_FIRE = 3
		self.b93r.ADAPTIVE_BURST_SIZE = false
		self.b93r.BURST_FIRE_RATE_MULTIPLIER = 1100/600
		self.b93r.DELAYED_BURST_RECOIL = false
		self.b93r.stats.spread = self.b93r.stats.spread - 15
		self:copy_timers("b93r", "b92fs")
	end

	-- Yoink, the B93R is now actually in the game
	self:inf_init("beer", "pistol", nil)
	self.beer.sdesc1 = "caliber_p9x19"
	self.beer.sdesc2 = "action_shortrecoil"
	--self.beer.stats.concealment = 29
	self.beer.AMMO_MAX = 140
	self.beer.AMMO_PICKUP = self:_pickup_chance(140, 1)
	--self.beer.BURST_FIRE = 3
	--self.beer.ADAPTIVE_BURST_SIZE = false
	--self.beer.BURST_FIRE_RATE_MULTIPLIER = 1100/600
	--self.beer.DELAYED_BURST_RECOIL = false
	self.beer.stats.spread = self.beer.stats.spread - 15
	self.beer.fire_mode_data.fire_rate = 60/1100
	-- Hawk please save me from these awful sounds
	self.beer.sounds.fire = "beretta_fire"
	self.beer.sounds.fire_single = "beretta_fire"
	self.beer.sounds.fire_auto = "beretta_fire"

	self:copy_timers("beer", "b92fs")
	
	self:inf_init("x_beer", "pistol", nil)
	self.x_beer.sdesc1 = "caliber_p9x19"
	self.x_beer.sdesc2 = "action_shortrecoil"
	--self.x_beer.stats.concealment = 29
	self.x_beer.AMMO_MAX = 140
	self.x_beer.AMMO_PICKUP = self:_pickup_chance(140, 1)
	--self.x_beer.BURST_FIRE = 3
	--self.x_beer.ADAPTIVE_BURST_SIZE = false
	--self.x_beer.BURST_FIRE_RATE_MULTIPLIER = 1100/600
	--self.x_beer.DELAYED_BURST_RECOIL = false
	self.x_beer.stats.spread = self.x_beer.stats.spread - 15
	self.x_beer.fire_mode_data.fire_rate = 60/1100
	self.x_beer.sounds.fire = "beretta_fire"
	self.x_beer.sounds.fire_single = "beretta_fire"
	self.x_beer.sounds.fire_auto = "beretta_fire"
	self:copy_timers("x_beer", "x_b92fs")

	if BeardLib.Utils:ModLoaded("TOZ-34") then
		self:inf_init("toz34", "shotgun", {"dmg_heavy", "range_long", "rof_db"})
		self.toz34.sdesc1 = "caliber_s12g"
		self.toz34.sdesc2 = "action_breakou"
		self.toz34.stats.spread = self.toz34.stats.spread + 15
		self.toz34.stats.concealment = 21
		self.toz34.shake.fire_steelsight_multiplier = 0.25 -- fucking grip puts the hand in the way
		self:copy_timers("toz34", "b682")
		self.toz34.reload_speed_mult = self.toz34.reload_speed_mult * 0.95
	end

	if BeardLib.Utils:ModLoaded("TOZ-66") then
		self:inf_init("toz66", "shotgun", {"dmg_heavy", "rof_db"})
		self.toz66.sdesc1 = "caliber_s12g"
		self.toz66.sdesc2 = "action_breaksxs"
		self.toz66.stats.spread = self.toz66.stats.spread - 25
		self.toz66.stats.recoil = self.toz66.stats.recoil - 7
		--self.toz66.stats.concealment = 27
		self.toz66.AMMO_MAX = 22
		self.toz66.AMMO_PICKUP = self:_pickup_chance(22, 1)
		self:copy_timers("toz66", "huntsman")
		self.toz66.reload_speed_mult = self.toz66.reload_speed_mult * 1.4
	end

	if BeardLib.Utils:ModLoaded("Akimbo TOZ-66") then
		self:inf_init("x_toz66", "shotgun", {"dmg_heavy", "rof_db"})
		self.x_toz66.stats.concealment = 27
		self.x_toz66.chamber = 0
		self.x_toz66.sdesc1 = "caliber_s12g"
		self.x_toz66.sdesc2 = "action_breaksxs"
		self.x_toz66.stats.spread = self.x_toz66.stats.spread - 25
		self.x_toz66.stats.recoil = self.x_toz66.stats.recoil - 7
		self.x_toz66.AMMO_MAX = 30
		self.x_toz66.AMMO_PICKUP = self:_pickup_chance(30, 1)
		self:copy_timers("x_toz66", "x_judge")
	end

	if BeardLib.Utils:ModLoaded("pdr") then
		Hooks:RemovePostHook("pdrModInit")
		self:inf_init("pdr", "smg", {"range_carbine"})
		self.pdr.sdesc1 = "caliber_r556x45"
		self.pdr.sdesc2 = "action_gasshort"
		self:copy_timers("pdr", "aug")
		self.pdr.stats.concealment = 23
	end

	if BeardLib.Utils:ModLoaded("Steyr AUG A3 9mm XS") then
		self:inf_init("aug9mm", "smg", {"range_long"})
		self.aug9mm.sdesc1 = "caliber_p9x19"
		self.aug9mm.sdesc2 = "action_blowback"
		--self.aug9mm.stats.spread = self.aug9mm.stats.spread + 5
		--self.aug9mm.stats.recoil = self.aug9mm.stats.recoil + 5
		--self.aug9mm.CLIP_AMMO_MAX = 32
		self.aug9mm.AMMO_MAX = 128
		self.aug9mm.AMMO_PICKUP = self:_pickup_chance(128, 1)
		self:copy_timers("aug9mm", "aug")
		self.aug9mm.reload_speed_mult = self.aug9mm.reload_speed_mult * 1.1
		self.aug9mm.stats.concealment = 24
	end

	if BeardLib.Utils:ModLoaded("L115") then
		self:inf_init("l115", "snp", "heavy")
		self.l115.sdesc1 = "caliber_r338"
		self.l115.sdesc2 = "action_bolt"
		self.l115.stats.concealment = 18
		self:copy_timers("l115", "msr")
		self.l115.anim_speed_mult = 1.25
		self.l115.reload_speed_mult = self.l115.reload_speed_mult * 1.35
		self:apply_standard_bipod_stats("l115")
		self.l115.custom_bipod = true
		self.l115.bipod_weapon_translation = Vector3(0, -6, -4)
		pivot_shoulder_translation = Vector3(20.11, 42.8, -8.14)
		pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
		pivot_head_translation = Vector3(11.5, 37, -4)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.l115.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.l115.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.l115.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.l115.use_custom_anim_state = true
		self.l115.bipod_rof_mult = 1.25
		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("l115", {
				name = "a_bp",
				base_a_obj = "a_body",
				position = Vector3(0, 53, 4),
				rotation = Rotation(0, 0, 0)
			})
		end
	end

	if BeardLib.Utils:ModLoaded("Montana 5.56") then
		self:inf_init("yayo", "ar", {"has_gl"})
		self.yayo.sdesc1 = "caliber_r556x45"
		self.yayo.sdesc2 = "action_di"
		self.yayo.sdesc3 = "misc_gl40x46mm"
		self.yayo.stats.concealment = 14
		--self.yayo.FIRE_MODE = "auto"
		--self.yayo.AMMO_MAX = 120
		--self.yayo.AMMO_PICKUP = self:_pickup_chance(120, 1)
		self:copy_timers("yayo", "contraband")
		self.yayo_m203gl.AMMO_MAX = 2
		self.yayo_m203gl.AMMO_PICKUP = {1338, 15}
		self:copy_timers("yayo_m203gl", "contraband_m203")
	end

	if BeardLib.Utils:ModLoaded("Bren Ten") then
		self:inf_init("sonny", "pistol", "supermedium")
		self.sonny.sdesc1 = "caliber_p10"
		self.sonny.sdesc2 = "action_shortrecoil"
		--self.sonny.stats.concealment = 28
		--self.sonny.stats.damage = InFmenu.wpnvalues.supermediumpis.damage
		--self.sonny.stats.recoil = InFmenu.wpnvalues.supermediumpis.recoil
		--self.sonny.AMMO_MAX = 60
		--self.sonny.AMMO_PICKUP = self:_pickup_chance(60, 1)
		--self.sonny.recoil_table = InFmenu.rtable.heavypis
		--self.sonny.recoil_loop_point = 3
		self:copy_timers("sonny", "packrat")
		self.sonny.reload_speed_mult = self.sonny.reload_speed_mult * self:convert_reload_to_mult("mag_75")

		self:inf_init("x_sonny", "pistol", "supermedium")
		self:copy_sdescs("x_sonny", "sonny", true)
		self:copy_stats("x_sonny", "sonny", true)
		self.x_sonny.stats.concealment = 28
		self.x_sonny.AMMO_MAX = 80
		self.x_sonny.AMMO_PICKUP = self:_pickup_chance(80, 1)
		--self.x_sonny.recoil_table = InFmenu.rtable.heavypis
		--self.x_sonny.recoil_loop_point = 3
		self:copy_timers("x_sonny", "x_packrat")
	end

	if BeardLib.Utils:ModLoaded("STG 44") then
		self:inf_init("stg44", "ar", nil)
		self.stg44.sdesc1 = "caliber_r792x33"
		self.stg44.sdesc2 = "action_gas"
		self.stg44.reload_speed_mult = self.stg44.reload_speed_mult * 0.90
		self.stg44.stats.concealment = 20
		self.stg44.no_auto_anim = true
		self.stg44.fire_mode_data.fire_rate = 60/500

		-- fuck your reload timers, i'm using mine
		--Hooks:RemovePostHook("stg44Init")
		DelayedCalls:Add("stg44reloaddelay", 0.50, function(self, params)
			tweak_data.weapon:copy_timers("stg44", "g3")
		end)
	end

	if BeardLib.Utils:ModLoaded("HK G3A3 M203") then
		self:inf_init("g3m203", "ar", {"heavy", "has_gl"})
		self.g3m203.sdesc1 = "caliber_r762x51"
		self.g3m203.sdesc2 = "action_blowbackroller"
		self.g3m203.sdesc3 = "misc_gl40x46mm"
		self.g3m203.stats.concealment = 15
		--self.g3m203.AMMO_MAX = 80
		--self.g3m203.AMMO_PICKUP = self:_pickup_chance(80, 1)
		self:copy_timers("g3m203", "contraband")

		self.g3_m203gl.AMMO_MAX = 2
		self.g3_m203gl.AMMO_PICKUP = {1338, 15}
		self:copy_timers("g3_m203gl", "contraband_m203")

		self:inf_init("g3_m203buckshot", "shotgun", {"dmg_heavy"})
		self.g3_m203buckshot.stats.damage = 100 -- 500
		self.g3_m203buckshot.stats_modifiers = {damage = 5}
		self.g3_m203buckshot.rays = 20
		self.g3_m203buckshot.damage_near = 1000
		self.g3_m203buckshot.damage_far = 1500
		self.g3_m203buckshot.armor_piercing_chance = 1
		self.g3_m203buckshot.stats.spread = 20
		self.g3_m203buckshot.AMMO_MAX = 4
		self.g3_m203buckshot.AMMO_PICKUP = {1338, 50}
		self:copy_timers("g3_m203buckshot", "contraband_m203")
		self.g3_m203buckshot.reload_speed_mult = 1.20

		self:inf_init("g3_m203flechette", "shotgun", {"dmg_heavy"})
		self.g3_m203flechette.stats.damage = 75 -- 375
		self.g3_m203flechette.stats_modifiers = {damage = 5}
		self.g3_m203flechette.rays = 28
		self.g3_m203flechette.damage_near = 1000 * 1.25
		self.g3_m203flechette.damage_far = 1500 * 1.25
		self.g3_m203flechette.armor_piercing_chance = 1
		self.g3_m203flechette.stats.spread = 40
		self.g3_m203flechette.AMMO_MAX = 4
		self.g3_m203flechette.AMMO_PICKUP = {1338, 50}
		self:copy_timers("g3_m203flechette", "contraband_m203")
		self.g3_m203flechette.reload_speed_mult = 1.20

		--[[
		self:inf_init("g3_m203slug", "snp", "heavy")
		self.g3_m203slug.stats.damage = 90 -- 450
		self.g3_m203slug.stats_modifiers = {damage = 5}
		self.g3_m203slug.damage_near = 1000 * 100
		self.g3_m203slug.damage_far = 2500 * 100
		self.g3_m203slug.stats.spread = 50
		self.g3_m203slug.AMMO_MAX = 4
		self.g3_m203slug.AMMO_PICKUP = {1338, 100}
		self:copy_timers("g3_m203slug", "contraband_m203")
		self.g3_m203slug.reload_speed_mult = 1.20
		--]]
	end

	if BeardLib.Utils:ModLoaded("AAC Honey Badger") then
		self:inf_init("bajur", "ar", {"medium"})
		self.bajur.sdesc1 = "caliber_r300blackout"
		self.bajur.sdesc2 = "action_di"
		self.bajur.sdesc4 = "misc_alwayssilent"
		self.bajur.stats.spread = self.bajur.stats.spread - 15 + 5
		self.bajur.stats.recoil = self.bajur.stats.recoil + 0 + 6
		self.bajur.stats.suppression = self.bajur.stats.suppression + 12
		self.bajur.stats.concealment = 23
		self:copy_timers("bajur", "new_m4")
		-- 2.38/+30% 1.83
		-- 3.02/2.32
	end

	if BeardLib.Utils:ModLoaded("af2011") then
		Hooks:RemovePostHook("af2011")
		self:inf_init("af2011", "pistol", "medium")
		self.af2011.sdesc1 = "caliber_p45acp"
		self.af2011.sdesc2 = "action_shortrecoil"
		self.af2011.stats.damage = InFmenu.wpnvalues.mediumpis.damage
		self.af2011.stats.spread = InFmenu.wpnvalues.mediumpis.spread - 25
		self.af2011.stats.recoil = InFmenu.wpnvalues.mediumpis.recoil - 5
		self.af2011.stats.concealment = 27
		self.af2011.chamber = 2
		self.af2011.CLIP_AMMO_MAX = 16
		self.af2011.AMMO_MAX = 96
		self.af2011.AMMO_PICKUP = self:_pickup_chance(96, 1)
		self.af2011.rays = 1 -- shit's broken in InF anyways
		self.af2011.instant_multishot = 2
		self.af2011.kick = kick_mult(self.af2011.kick, 2, 2, 2, 2, 2, 2)
		self.af2011.recoil_table = InFmenu.rtable.heavypis
		self.af2011.recoil_loop_point = InFmenu.wpnvalues.heavypis.recoil_loop_point
		self:copy_timers("af2011", "b92fs")
		self.af2011.reload_speed_mult = self.af2011.reload_speed_mult * 0.90

		self:inf_init("x_af2011", "pistol", "medium")
		self:copy_sdescs("x_af2011", "af2011", true)
		self:copy_stats("x_af2011", "af2011", true)
		self.x_af2011.stats.concealment = 27
		self.x_af2011.CLIP_AMMO_MAX = self.af2011.CLIP_AMMO_MAX * 2
		self.x_af2011.AMMO_MAX = 128
		self.x_af2011.AMMO_PICKUP = self:_pickup_chance(128, 1)
		self.x_af2011.rays = 1
		self.x_af2011.instant_multishot = 2
		self.x_af2011.kick = kick_mult(self.x_af2011.kick, 2, 2, 2, 2, 2, 2)
		self.x_af2011.recoil_table = InFmenu.rtable.heavypis
		self.x_af2011.recoil_loop_point = InFmenu.wpnvalues.heavypis.recoil_loop_point
		self:copy_timers("x_af2011", "x_b92fs")
		self.x_af2011.reload_speed_mult = self.x_af2011.reload_speed_mult * 0.90
	end

	if BeardLib.Utils:ModLoaded("STF-12") then
		self:inf_init("stf12", "shotgun", {"dmg_mid"})
		self.stf12.sdesc1 = "caliber_s12g"
		self.stf12.sdesc2 = "action_pump"
		self.stf12.stats.spread = self.stf12.stats.spread - 10
		self.stf12.stats.concealment = 23
		self:copy_timers("stf12", "r870")
	end

	if BeardLib.Utils:ModLoaded("CheyTac M200") then
		self:inf_init("m200", "snp", "heavy")
		self.m200.sdesc1 = "caliber_r408cheytac"
		self.m200.sdesc2 = "action_bolt"
		self:copy_timers("m200", "msr")
		self.m200.anim_speed_mult = 1.25 -- lower rof
		self.m200.stats.spread = self.m200.stats.spread + 5
		self.m200.stats.concealment = 16
		self.m200.AMMO_MAX = 28
		self.m200.AMMO_PICKUP = self:_pickup_chance(28, 1)
		self.m200.reload_speed_mult = self.m200.reload_speed_mult * 1.2

		self:apply_standard_bipod_stats("m200")
		self.m200.custom_bipod = true
		--self.m200.use_bipod_anywhere = true
		self.m200.bipod_weapon_translation = Vector3(0, -6, -2)
		pivot_shoulder_translation = Vector3(10.6138, 20, -4.8)
		pivot_shoulder_rotation = Rotation(0.106543, -0.0842801, 0.628575)
		pivot_head_translation = Vector3(1.93, 14, -1.54)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.m200.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.m200.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.m200.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.m200.use_custom_anim_state = true
		self.m200.bipod_rof_mult = 1.25
	end

	if BeardLib.Utils:ModLoaded("Minebea SMG") then
		self:inf_init("minebea", "smg", nil)
		self.minebea.sdesc1 = "caliber_p9x19"
		self.minebea.sdesc2 = "action_blowback"
		self.minebea.chamber = 0
		--self.minebea.stats.concealment = 27
		self:copy_timers("minebea", "cobray")
		self.minebea.reload_speed_mult = self.minebea.reload_speed_mult * 1.15
		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("minebea", {
				name = "a_o_notugly",
				base_a_obj = "a_o",
				position = Vector3(0, -22, -0.75),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("minebea", {
				name = "a_o_notugly_aimpoint",
				base_a_obj = "a_o",
				position = Vector3(0, -18, -0.75),
				rotation = Rotation(0, 0, 0)
			})
		end

		self:inf_init("x_minebea", "smg", nil)
		self:copy_sdescs("x_minebea", "minebea", true)
		self:copy_stats("x_minebea", "minebea", true)
		self:copy_timers("x_minebea", "x_sr2")
		self.x_minebea.stats.concealment = 27
		self.x_minebea.AMMO_MAX = 200
		self.x_minebea.AMMO_PICKUP = self:_pickup_chance(200, 1)
		self.x_minebea.reload_speed_mult = self.x_minebea.reload_speed_mult * 1.15
	end

	if BeardLib.Utils:ModLoaded("HX25 Handheld Grenade Launcher") then
		self.hx25.categories = {"shotgun"}
		self.hx25.recategorize = nil
		self.hx25.ignore_damage_upgrades = false
		self:inf_init("hx25", "shotgun", nil)
		self.hx25.sdesc1 = "caliber_ghx25"
		self.hx25.sdesc2 = "action_breakopen"
		self.hx25.rays = 1
		self.hx25.chamber = 0
		--self.hx25.stats.spread = self.hx25.stats.spread - 20
		--self.hx25.stats.concealment = 27
		self:copy_timers("hx25", "new_raging_bull")
		-- does shotgun damage addend work like this?
		self.hx25.stats.damage = 100 -- 500
		self.hx25.AMMO_MAX = 9
		self.hx25.AMMO_PICKUP = {1338, 50}
		self.hx25.damage_near = 1500
		self.hx25.damage_far = 3000
		self.hx25.armor_piercing_chance = 1
		-- instant_multishot set in ammo type
		-- inf does something that breaks multiple-ray explosive rounds, but i couldn't be bothered to figure out what
	end

	-- automag
	if BeardLib.Utils:ModLoaded("amt") then
		self:inf_init("amt", "pistol", "heavy")
		self.amt.sdesc1 = "caliber_p44amp"
		self.amt.sdesc2 = "action_shortrecoil"
		self:copy_timers("amt", "deagle")
		self.amt.stats.concealment = 28
	end

	if BeardLib.Utils:ModLoaded("Zenith 10mm") then
		self:inf_init("zenith", "pistol", "supermedium")
		self.zenith.sdesc1 = "caliber_p10"
		self.zenith.sdesc2 = "action_shortrecoil"
		self:copy_timers("zenith", "lemming")
		self.zenith.reload_speed_mult = self.zenith.reload_speed_mult * self:convert_reload_to_mult("mag_66")
		--self.zenith.stats.concealment = 28
	end

	if BeardLib.Utils:ModLoaded("Widowmaker TX") then
		self:inf_init("wmtx", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
		self.wmtx.sdesc1 = "caliber_s12g"
		self.wmtx.sdesc2 = "action_gas"
		self.wmtx.chamber = 0
		self.wmtx.recategorize = "shotgun"
		self.wmtx.stats.spread = self.wmtx.stats.spread - 10
		self.wmtx.stats.concealment = 25
		self.wmtx.AMMO_MAX = 40
		self.wmtx.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self.wmtx.BURST_FIRE = nil
		self.wmtx.BURST_FIRE_RATE_MULTIPLIER = 1.6
		self.wmtx.burst_recoil_table = {0.5, 1.5}
		self.wmtx.ADAPTIVE_BURST_SIZE = false
		self:copy_timers("wmtx", "coal")
		self.wmtx.reload_speed_mult = self.wmtx.reload_speed_mult * 1.60
	end

	if BeardLib.Utils:ModLoaded("DP12 Shotgun") then
		self:inf_init("dp12", "shotgun", {"dmg_light"})
		self.dp12.is_dp12 = true
		self.dp12.dp12_no_pump_rof_mult = 5
		self.dp12.sdesc1 = "caliber_s12g"
		self.dp12.sdesc2 = "action_pump"
		self.dp12.chamber = 2
		self.dp12.CLIP_AMMO_MAX = 14
		self.dp12.AMMO_MAX = 42
		self.dp12.AMMO_PICKUP = self:_pickup_chance(42, 1)
		self:copy_timers("dp12", "ksg")
		self.dp12.fire_mode_data.fire_rate = 60/105
		self.dp12.stats.concealment = 21
		self.dp12.anim_speed_mult = 0.80
		self.dp12.timers.shotgun_reload_enter = 0.3
		self.dp12.timers.shotgun_reload_shell = 0.5666666666666667
		self.dp12.timers.shotgun_reload_first_shell_offset = self.dp12.timers.shotgun_reload_shell - 0.33
		self.dp12.timers.shotgun_reload_exit_not_empty = 0.3
		self.dp12.timers.shotgun_reload_exit_empty = 0.7
		self.dp12.timers.shell_reload_early = 0.10
	end

	if BeardLib.Utils:ModLoaded("Lahti L-35") then
		self:inf_init("l35", "pistol", "medium")
		self.l35.sdesc1 = "caliber_p9x19"
		self.l35.sdesc2 = "action_recoil"
		self:copy_timers("l35", "breech")
		--self.l35.stats.concealment = 29
	end

	if BeardLib.Utils:ModLoaded("OTs-14-4A Groza") then
		self:inf_init("ots_14_4a", "ar", {"medium"})
		self.ots_14_4a.sdesc1 = "caliber_r9x39"
		self.ots_14_4a.sdesc2 = "action_gas"
		self:copy_timers("ots_14_4a", "l85a2")
		self.ots_14_4a.stats.spread = self.ots_14_4a.stats.spread - 10
		self.ots_14_4a.stats.concealment = 25
		self.ots_14_4a.reload_speed_mult = self.ots_14_4a.reload_speed_mult * self:convert_reload_to_mult("mag_66")

		if self.SetupAttachmentPoint then

			local y1 = -13.75
			local y2 = y1 + 2.25

			self:SetupAttachmentPoint("ots_14_4a", {
				name = "a_m_ak",
				base_a_obj = "a_m",
				position = Vector3(0, y1, -5),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("ots_14_4a", {
				name = "a_m_m4",
				base_a_obj = "a_m",
				position = Vector3(0, y2, -5),
				rotation = Rotation(0, 0, 0)
			})
		end
	end

	if BeardLib.Utils:ModLoaded("MK18 Specialist") then
		self:inf_init("mk18s", "ar", nil)
		self.mk18s.sdesc1 = "caliber_r556x45"
		self.mk18s.sdesc2 = "action_di"
		self:copy_timers("mk18s", "shepheard")
		self.mk18s.stats.spread = self.mk18s.stats.spread - 10
		self.mk18s.stats.concealment = 23
		self.mk18s.reload_speed_mult = self.mk18s.reload_speed_mult * self:convert_reload_to_mult("mag_200")
		self.mk18s.fire_mode_data.fire_rate = 60/800
		self.mk18s.BURST_FIRE = 3
		self.mk18s.ADAPTIVE_BURST_SIZE = false
		self.mk18s.BURST_FIRE_RATE_MULTIPLIER = 2
	end

	if BeardLib.Utils:ModLoaded("Lewis Gun") then
		self:inf_init("lewis", "lmg", "heavy")
		self.lewis.sdesc1 = "caliber_r303"
		self.lewis.sdesc2 = "action_gaslong"
		self.lewis.AMMO_MAX = 188
		self.lewis.stats.spread = self.lewis.stats.spread + 10
		self.lewis.stats.concealment = 11
		self:copy_timers("lewis", "ecp")
		self.lewis.reload_speed_mult = self.lewis.reload_speed_mult * 0.80
		self:apply_standard_bipod_stats("lewis")
		self.lewis.reload_stance_mod = {ads = {translation = Vector3(5, 0, -5), rotation = Rotation(0, 0, 0)}}
		self.lewis.custom_bipod = true
		self.lewis.bipod_weapon_translation = Vector3(-5, 15, -10)
		self.lewis.deploy_ads_stance_mod = {translation = Vector3(7.3, 13, -6.7), rotation = Rotation(-0.1, -1.2, -5)}
		self.lewis.bipod_deploy_multiplier = self.lewis.bipod_deploy_multiplier * 1.3
		table.insert(lmglist, "lewis")
	end

	if BeardLib.Utils:ModLoaded("HK416") then
		self:inf_init("hk416", "ar", nil)
		self.hk416.sdesc1 = "caliber_r556x45"
		self.hk416.sdesc2 = "action_pistonshort"
		self:copy_timers("hk416", "new_m4")
		self.hk416.stats.concealment = 18
		-- shift 3 left to actually visually confirm instead of just tilting for the sake of it
		--self.hk416.reload_timed_stance_mod.empty.hip[1].translation = Vector3(-25, 0, -5)
		--self.hk416.reload_timed_stance_mod.empty.ads[2].translation = Vector3(-13, -3, -15)
	end

	if BeardLib.Utils:ModLoaded("HK416C Standalone") then
		self:inf_init("drongo", "ar", nil)
		self.drongo.sdesc1 = "caliber_r556x45"
		self.drongo.sdesc2 = "action_pistonshort"
		self:copy_timers("drongo", "new_m4")
		self.drongo.stats.spread = self.drongo.stats.spread - 10
		self.drongo.stats.concealment = 21
		self.drongo.fire_mode_data.fire_rate = 60/800
	end

	if BeardLib.Utils:ModLoaded("HK417 Standalone") then
		self:inf_init("recce", "ar", {"heavy"})
		self.recce.sdesc1 = "caliber_r762x51"
		self.recce.sdesc2 = "action_pistonshort"
		self:copy_timers("recce", "contraband")
		self.recce.stats.concealment = 20
		self.recce.fire_mode_data.fire_rate = 60/600
		self.recce.FIRE_MODE = "auto"
	end

	if BeardLib.Utils:ModLoaded("SAI GRY") then
		self:inf_init("saigry", "ar", {"medium"})
		self.saigry.sdesc1 = "caliber_r300blackout"
		self.saigry.sdesc2 = "action_di"
		self.saigry.stats.concealment = 20
		self.saigry.fire_mode_data.fire_rate = 60/750
		self:copy_timers("saigry", "m16")
		self.saigry.reload_speed_mult = self.saigry.reload_speed_mult * self:convert_reload_to_mult("mag_133") * 0.85
	end

	if BeardLib.Utils:ModLoaded("Owen Gun") then
		self:inf_init("owen", "smg", {"range_long"})
		self.owen.sdesc1 = "caliber_p9x19"
		self.owen.sdesc2 = "action_blowback"
		self.owen.chamber = 0
		self.owen.stats.spread = self.owen.stats.spread - 5
		self.owen.stats.concealment = 23
		self.owen.AMMO_MAX = 132
		self.owen.AMMO_PICKUP = self:_pickup_chance(132, 1)
		self:copy_timers("owen", "ecp")
		self.owen.reload_speed_mult = self.owen.reload_speed_mult * 0.95
		self.owen.not_empty_reload_speed_mult = self.owen.not_empty_reload_speed_mult * 1.25
	end

	if BeardLib.Utils:ModLoaded("PP-19-01 Vityaz") then
		self:inf_init("vityaz", "smg", {"range_long"})
		self.vityaz.sdesc1 = "caliber_p9x19"
		self.vityaz.sdesc2 = "action_blowback"
		self:copy_timers("vityaz", "ak5")
		self.vityaz.stats.concealment = 24
	end

	if BeardLib.Utils:ModLoaded("l1a1") then
		Hooks:RemovePostHook("l1a1ModInit")
		self:inf_init("l1a1", "ar", {"ldmr"})
		self:copy_sdescs("l1a1", "fal")
		self:copy_timers("l1a1", "fal")
		self.l1a1.reload_speed_mult = self.l1a1.reload_speed_mult * 0.90
		self.l1a1.stats.concealment = 19
	end

	if BeardLib.Utils:ModLoaded("Mk14") then
		self:inf_init("wargoddess", "ar", {"ldmr"})
		self:copy_sdescs("wargoddess", "new_m14")
		self:copy_timers("wargoddess", "new_m14")
		self.wargoddess.stats.concealment = 18
	end

	if BeardLib.Utils:ModLoaded("sg552") then
		Hooks:RemovePostHook("sg552ModInit")
		self:inf_init("sg552", "ar", nil)
		self:copy_sdescs("sg552", "s552")
		self:copy_stats("sg552", "s552")
		self:copy_timers("sg552", "s552")
		self.sg552.stats.concealment = 24
	end

	if BeardLib.Utils:ModLoaded("Beretta Px4 Storm") and self.px4 then
		self:inf_init("px4", "pistol", "medium")
		self.px4.sdesc1 = "caliber_p40sw"
		self.px4.sdesc2 = "action_shortrecoil"
		self:copy_timers("px4", "sparrow")
		self.px4.AMMO_MAX = 84
		self.px4.AMMO_PICKUP = self:_pickup_chance(84, 1)
		self.px4.stats.concealment = 28
	end

	if BeardLib.Utils:ModLoaded("Walther P99 AS") then
		self:inf_init("p99", "pistol", nil)
		self.p99.sdesc1 = "caliber_p9x19"
		self.p99.sdesc2 = "action_shortrecoil"
		self:copy_timers("p99", "packrat")
		--self.p99.stats.concealment = 30
	end

	if BeardLib.Utils:ModLoaded("M45A1 CQBP") then
		self:inf_init("m45a1", "pistol", "medium")
		self:copy_sdescs("m45a1", "colt_1911")
		self:copy_timers("m45a1", "colt_1911")
		self.m45a1.AMMO_MAX = 77
		self.m45a1.AMMO_PICKUP = self:_pickup_chance(77, 1)
		self.m45a1.stats.concealment = 29
	end

	if BeardLib.Utils:ModLoaded("Mossberg 590") then
		self:inf_init("m590", "shotgun", {"rof_slow", "range_slowpump"})
		self.m590.sdesc1 = "caliber_s12g"
		self.m590.sdesc2 = "action_pump"
		self.m590.stats.spread = self.m590.stats.spread + 10
		self.m590.AMMO_MAX = 40
		self.m590.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self:copy_timers("m590", "m37")
		self.m590.stats.concealment = 21
	end

	if BeardLib.Utils:ModLoaded("Vepr-12") then
		self:inf_init("vepr12", "shotgun", {"dmg_vlight", "rof_mag"})
		self:copy_sdescs("vepr12", "saiga")
		self:copy_timers("vepr12", "flint")
		self.vepr12.FIRE_MODE = "single"
		self.vepr12.stats.spread = self.vepr12.stats.spread - 5
		self.vepr12.stats.concealment = 23
	end

	if BeardLib.Utils:ModLoaded("M3 Grease Gun") then
		Hooks:RemovePostHook("m3ModInit")

		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("x_m3", {
				name = "a_o",
				base_a_obj = "a_o",
				position = Vector3(0, -17, 0),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("x_m3", {
				name = "a_fl",
				base_a_obj = "a_fl",
				position = Vector3(0.4, -21, 0),
				rotation = Rotation(0, 0, 0)
			})

			self:SetupAttachmentPoint("m3", {
				name = "a_o",
				base_a_obj = "a_o",
				position = Vector3(0, -17, 0),
				rotation = Rotation(0, 0, 0)
			})
			self:SetupAttachmentPoint("m3", {
				name = "a_fl",
				base_a_obj = "a_fl",
				position = Vector3(0.4, -21, 0),
				rotation = Rotation(0, 0, 0)
			})
		end

		self:inf_init("m3", "smg", {"dmg_50"})
		self.m3.chamber = 0
		self.m3.sdesc1 = "caliber_p45acp"
		self.m3.sdesc2 = "action_blowback"
		self:copy_timers("m3", "m45")
		self.m3.stats.spread = self.m3.stats.spread + 5
		self.m3.stats.concealment = 25

		self:inf_init("x_m3", "smg", {"dmg_50"})
		self.x_m3.recategorize = "x_smg"
		self.x_m3.AMMO_MAX = 180
		self.x_m3.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self.x_m3.stats.concealment = 25
		self:copy_sdescs("x_m3", "m3", true)
		self:copy_stats("x_m3", "m3", true)
		self:copy_timers("x_m3", "x_akmsu")
	end

	if BeardLib.Utils:ModLoaded("Howa AR") then
		self:inf_init("howa", "ar", nil)
		self.howa.sdesc1 = "caliber_r556x45jp"
		self.howa.sdesc2 = "action_gas"
		self:copy_timers("howa", "ak5")
		self:copy_timers_to_reload2("howa", "galil")
		self.howa.stats.concealment = 20
	end

	if BeardLib.Utils:ModLoaded("vp70") then
		self:inf_init("vp70", "pistol", nil)
		self.vp70.sdesc1 = "caliber_p9x19"
		self.vp70.sdesc2 = "action_blowback"
		self.vp70.stats.concealment = 30
		self.vp70.AMMO_MAX = 144
		self.vp70.AMMO_PICKUP = self:_pickup_chance(144, 1)
		self:copy_timers("vp70", "ppk")
		self.vp70.reload_speed_mult = self.vp70.reload_speed_mult * self:convert_reload_to_mult("mag_200")
		self.vp70.BURST_FIRE_RATE_MULTIPLIER = 1 -- ROF mult is set by stock mod

		self:inf_init("x_vp70", "pistol", nil)
		self.x_vp70.stats.concealment = 30
		self.x_vp70.AMMO_MAX = 180
		self.x_vp70.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self:copy_sdescs("x_vp70", "vp70", true)
		self:copy_stats("x_vp70", "vp70", true)
		self:copy_timers("x_vp70", "x_ppk")
		self.x_vp70.reload_speed_mult = self.x_vp70.reload_speed_mult * self:convert_reload_to_mult("mag_200")
	end

	if BeardLib.Utils:ModLoaded("lapd") then
		self:inf_init("lapd", "pistol", "heavy")
		self.lapd.sdesc1 = "caliber_p357"
		self.lapd.sdesc2 = "action_dasa"
		self.lapd.stats.concealment = 28
		self.lapd.chamber = 0
		self.lapd.AMMO_MAX = 40
		self.lapd.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self:copy_timers("lapd", "new_raging_bull")
		self.lapd.reload_speed_mult = self.lapd.reload_speed_mult * 1.15

		self:inf_init("x_lapd", "pistol", "heavy")
		self.x_lapd.stats.concealment = 28
		self.x_lapd.AMMO_MAX = 50
		self.x_lapd.AMMO_PICKUP = self:_pickup_chance(50, 1)
		self:copy_sdescs("x_lapd", "lapd", true)
		self:copy_stats("x_lapd", "lapd", true)
		self:copy_timers("x_lapd", "x_rage")
		self.x_lapd.reload_speed_mult = self.lapd.reload_speed_mult * 1.15
	end

	if BeardLib.Utils:ModLoaded("Remington R5 RGP") then
		self:inf_init("mikon", "ar", nil)
		self.mikon.sdesc1 = "caliber_r556x45"
		self.mikon.sdesc2 = "action_piston"
		self.mikon.stats.concealment = 20
		--self:copy_timers("mikon", "new_m4")
	DelayedCalls:Add("r5rgptimers", 0.50, function(self, params)
		-- gotta copy over the InF flipturn
		-- i have a little thing called 'you still cannot fire for fractions of a second after the mag has updated' that InF flipturns count as part of the reload time
		tweak_data.weapon:copy_timers("mikon", "new_m4")
	end)
	end

	-- IDW
	if BeardLib.Utils:ModLoaded("Parker-Hale PDW") then
		self:inf_init("nya", "smg", nil)
		self.nya.sdesc1 = "caliber_p9x19"
		self.nya.sdesc2 = "action_blowback"
		self:copy_timers("nya", "tec9")
		self.nya.stats.spread = self.nya.stats.spread - 15
		self.nya.stats.concealment = 26
		self.nya.fire_mode_data.fire_rate = 60/1400
		self.nya.reload_speed_mult = self.nya.reload_speed_mult * self:convert_reload_to_mult("mag_50")
		self.nya.AMMO_MAX = 160
		self.nya.AMMO_PICKUP = self:_pickup_chance(160, 1)
		self.nya.BURST_FIRE = 999
		self.nya.ADAPTIVE_BURST_SIZE = true
		self.nya.BURST_FIRE_RATE_MULTIPLIER = 400/1400

		self:inf_init("x_nya", "smg", nil)
		self:copy_sdescs("x_nya", "nya", true)
		self:copy_stats("x_nya", "nya", true)
		self:copy_timers("x_nya", "x_tec9")
		--self.x_nya.stats.concealment = 28
		self.x_nya.AMMO_MAX = 192
		self.x_nya.AMMO_PICKUP = self:_pickup_chance(192, 1)
		self.x_nya.BURST_FIRE = 999
		self.x_nya.ADAPTIVE_BURST_SIZE = true
		self.x_nya.BURST_FIRE_RATE_MULTIPLIER = 400/1400
		self.x_nya.reload_speed_mult = self.x_nya.reload_speed_mult * self:convert_reload_to_mult("mag_50")
	end

	if BeardLib.Utils:ModLoaded("ARX-160 REBORN") then
		-- redundancy
		self:inf_init("lazy", "ar", nil)
		self.lazy.sdesc1 = "caliber_r556x45"
		self.lazy.sdesc2 = "action_gas"
		-- copies over the reload timer adjustments, flipturn, and InF-specific timers and other data
		self:copy_timers("lazy", "new_m4")
		self.lazy.fire_mode_data.fire_rate = 60/700
		self.lazy.stats.concealment = 21
	end

	if BeardLib.Utils:ModLoaded("DP28") then
		self:inf_init("dp28", "lmg", "heavy")
		self.dp28.sdesc1 = "caliber_r762x54r"
		self.dp28.sdesc2 = "action_gas"
		self.dp28.AMMO_MAX = 188
		self:copy_timers("dp28", "ecp")
		self.dp28.stats.concealment = 11
		DelayedCalls:Add("dp28pgtimers", 0.50, function(self, params)
			tweak_data.weapon:apply_standard_bipod_stats("dp28")
			tweak_data.weapon.dp28.bipod_weapon_translation = Vector3(-5, 15, -10)
			local pivot_shoulder_translation = Vector3(0, 0, 0)
			local pivot_shoulder_rotation = Rotation(0, 0, 0)
			local pivot_head_translation = Vector3(0, 0, 0)
			local pivot_head_rotation = Rotation(0, 0, 0)
			tweak_data.weapon.dp28.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
			tweak_data.weapon.dp28.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
			tweak_data.weapon.dp28.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		end)
		self.dp28.reload_speed_mult = self.dp28.reload_speed_mult * 0.80
		self.dp28.reload_stance_mod = {ads = {translation = Vector3(5, 0, -5), rotation = Rotation(0, 0, 0)}}
		self.dp28.custom_bipod = true
		--self.dp28.bipod_weapon_translation = Vector3(-5, 15, -10)
		self.dp28.deploy_ads_stance_mod = {translation = Vector3(-10.73, 5.1, 1.65), rotation = Rotation(0, 0, 0)}
		self.dp28.bipod_deploy_multiplier = self.dp28.bipod_deploy_multiplier * 1.3
		table.insert(lmglist, "dp28")
	end

	-- Actually in the game now
	--[[
	if BeardLib.Utils:ModLoaded("M60") then
		self:inf_init("m60", "lmg", "heavy")
		self.m60.sdesc1 = "caliber_r762x51"
		self.m60.sdesc2 = "action_gasshort"
		self:copy_timers("m60", "m249")
		self.m60.stats.concealment = 11
		self.m60.chamber = 0
		self.m60.reload_speed_mult = self.m60.reload_speed_mult * 1.15
		self:apply_standard_bipod_stats("m60")
		self.m60.deploy_ads_stance_mod = {translation = Vector3(9.5, 0, -3), rotation = Rotation(0, 0, -5.5)}
		self.m60.deploy_anim_override = "m249"
		table.insert(lmglist, "m60")
	end
	]]

	if BeardLib.Utils:ModLoaded("RPD") then
		self:inf_init("rpd", "lmg", "medium")
		self.rpd.sdesc1 = "caliber_r762x39"
		self.rpd.sdesc2 = "action_gas"
		self:copy_timers("rpd", "par")
		self.rpd.stats.concealment = 13
		self.rpd.chamber = 0
		self:apply_standard_bipod_stats("rpd")
		self.rpd.deploy_ads_stance_mod = {translation = Vector3(-0.05, 10, 1.45), rotation = Rotation(-0.05, -1.1, 0)}
		self.rpd.deploy_anim_override = "par"
		table.insert(lmglist, "rpd")
	end

	if BeardLib.Utils:ModLoaded("LSAT") then
		self:inf_init("lsat", "lmg", nil)
		self.lsat.sdesc1 = "caliber_r556x45ct"
		self.lsat.sdesc2 = "action_gaslsat"
		self:copy_timers("lsat", "m249")
		self.lsat.reload_speed_mult = self.lsat.reload_speed_mult * 1.15
		self.lsat.stats.concealment = 13
		self.lsat.chamber = 0
		self:apply_standard_bipod_stats("lsat")
		self.lsat.deploy_ads_stance_mod = {translation = Vector3(9.5, 0, -2.8), rotation = Rotation(0, 0, -5)}
		self.lsat.deploy_anim_override = "m249"
		table.insert(lmglist, "lsat")
	end

	if BeardLib.Utils:ModLoaded("gtt33") then
		Hooks:RemovePostHook("gtt33Init")
		self:inf_init("gtt33", "pistol", "medium")
		self.gtt33.sdesc1 = "caliber_p762x25"
		self.gtt33.sdesc2 = "action_shortrecoil"
		self:copy_timers("gtt33", "lemming")
		self.gtt33.reload_speed_mult = self.gtt33.reload_speed_mult * self:convert_reload_to_mult("mag_50")
		self.gtt33.CLIP_AMMO_MAX = 8
		--self.gtt33.stats.concealment = 29
	end

	if BeardLib.Utils:ModLoaded("Fang-45") then
		self:inf_init("fang45", "smg", {"range_long", "dmg_50"})
		self.fang45.sdesc1 = "caliber_p45acp"
		self.fang45.sdesc2 = "action_blowback"
		self.fang45.FIRE_MODE = "single"
		self.fang45.CAN_TOGGLE_FIREMODE = false
		self.fang45.BURST_FIRE = 999
		self.fang45.BURST_FIRE_RATE_MULTIPLIER = 1
		self.fang45.BURST_RECOIL_MULT = 1
		self.fang45.ADAPTIVE_BURST_SIZE = true
		self.fang45.burst_fire_rate_table = {1.15, 1.15, 1.15, 1.15, 1}
		self.fang45.burst_recoil_table = {2, 1.5, 1}
		self.fang45.fire_mode_data.fire_rate = 60/800
		self:copy_timers("fang45", "new_m4")
		self.fang45.reload_timed_stance_mod = nil -- no bolt to look at
		self.fang45.stats.concealment = 23
	end

	if BeardLib.Utils:ModLoaded("CZ 75 B") then
		self:inf_init("cz75b", "pistol", nil)
		self.cz75b.sdesc1 = "caliber_p9x19"
		self.cz75b.sdesc2 = "action_shortrecoil"
		self.cz75b.stats.concealment = 30
		self.cz75b.AMMO_MAX = 144
		self.cz75b.AMMO_PICKUP = self:_pickup_chance(144, 1)
		self:copy_timers("cz75b", "p226")

		self:inf_init("x_cz75b", "pistol", nil)
		self.x_cz75b.stats.concealment = 30
		self.x_cz75b.AMMO_MAX = 192
		self.x_cz75b.AMMO_PICKUP = self:_pickup_chance(192, 1)
		self:copy_sdescs("x_cz75b", "cz75b")
		self:copy_stats("x_cz75b", "cz75b", true)
		self:copy_timers("x_cz75b", "x_p226")
	end

	if BeardLib.Utils:ModLoaded("CZ 75 Short Rail") then
		self:inf_init("rally", "pistol", nil)
		self.rally.sdesc1 = "caliber_p9x19"
		self.rally.sdesc2 = "action_shortrecoil"
		self.rally.stats.concealment = 30
		self.rally.AMMO_MAX = 144
		self.rally.AMMO_PICKUP = self:_pickup_chance(144, 1)
		self:copy_timers("rally", "lemming")

		self:inf_init("x_rally", "pistol", nil)
		self.x_rally.stats.concealment = 30
		self.x_rally.AMMO_MAX = 192
		self.x_rally.AMMO_PICKUP = self:_pickup_chance(192, 1)
		self:copy_sdescs("x_rally", "rally", true)
		self:copy_stats("x_rally", "rally", true)
		self:copy_timers("x_rally", "x_packrat")
	end

	if BeardLib.Utils:ModLoaded("CZ Auto Pistol") then
		self:inf_init("czauto", "pistol", nil)
		self.czauto.sdesc1 = "caliber_p9x19"
		self.czauto.sdesc2 = "action_shortrecoil"
		self.czauto.stats.damage = self.czauto.stats.damage - 5
		self.czauto.stats.spread = self.czauto.stats.spread - 25
		self.czauto.stats.concealment = 29
		self.czauto.AMMO_MAX = 144
		self.czauto.AMMO_PICKUP = self:_pickup_chance(144, 1)
		self:copy_timers("czauto", "b92fs")
		self.czauto.fire_mode_data.fire_rate = 60/1000
	end

	if BeardLib.Utils:ModLoaded("Chiappa Rhino 60DS") then
		self:inf_init("rhino", "pistol", "heavy")
		self.rhino.sdesc1 = "caliber_p357"
		self.rhino.sdesc2 = "action_dasa"
		self.rhino.chamber = 0
		self.rhino.stats.concealment = 28
		self:copy_timers("rhino", "chinchilla")
	end

	if BeardLib.Utils:ModLoaded("Trench Shotgun") and self.trench then
		self:inf_init("trench", "shotgun", {"rof_slow", "range_slowpump"})
		self.trench.sdesc1 = "caliber_s12g"
		self.trench.sdesc2 = "action_pump"
		self.trench.CLIP_AMMO_MAX = 5
		self.trench.AMMO_MAX = 40
		self.trench.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self.trench.stats.spread = self.trench.stats.spread + 10
		self.trench.stats.concealment = 24
		self:copy_timers("trench", "m37")
	end

	if BeardLib.Utils:ModLoaded("Sjögren Inertia") then
		self:inf_init("sjogren", "shotgun", {"rof_semi", "range_slowpump", "dmg_light"})
		self.sjogren.sdesc1 = "caliber_s12g"
		self.sjogren.sdesc2 = "action_recoil"
		self.sjogren.AMMO_MAX = 40
		self.sjogren.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self.sjogren.stats.spread = self.sjogren.stats.spread + 20
		self.sjogren.stats.concealment = 21
		self:copy_timers("sjogren", "benelli")
		self.sjogren.animations.ignore_fullreload = true
		self.sjogren.reload_speed_mult = self.sjogren.reload_speed_mult * 0.90
	end

	if BeardLib.Utils:ModLoaded("ThompsonM1a1") then
		Hooks:RemovePostHook("ThompsonM1A1modInit")
		self:inf_init("tm1a1", "smg", {"range_long", "dmg_50"})
		self:copy_sdescs("tm1a1", "m1928")
		self:copy_timers("tm1a1", "tec9")
		self.tm1a1.AMMO_MAX = 180
		self.tm1a1.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self.tm1a1.fire_mode_data.fire_rate = 60/700
		self.tm1a1.stats.concealment = 25

		self:inf_init("x_tm1a1", "smg", {"range_long", "dmg_50"})
		self:copy_stats("x_tm1a1", "tm1a1", true)
		self:copy_sdescs("x_tm1a1", "tm1a1")
		self:copy_timers("x_tm1a1", "x_akmsu")
		self.x_tm1a1.reload_speed_mult = self.x_tm1a1.reload_speed_mult * 1.20
		self.x_tm1a1.AMMO_MAX = 180 -- fuck it maybe i'll make akimbo SMGs have a single standard ammo pickup rate later
		self.x_tm1a1.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self.x_tm1a1.stats.concealment = 25
		--self.x_tm1a1.recategorize = "x_smg"
	end

	if BeardLib.Utils:ModLoaded("M6G Magnum") then
		self:inf_init("m6g", "pistol", "heavy")
		self.m6g.sdesc1 = "caliber_p117saphp"
		self.m6g.sdesc2 = "action_shortrecoil"
		self.m6g.stats.concealment = 26
		self.m6g.chamber = 0
		self.m6g.AMMO_MAX = 40
		self.m6g.AMMO_PICKUP = self:_pickup_chance(40, 1)
		self:copy_timers("m6g", "usp")

		self:inf_init("x_m6g", "pistol", "heavy")
		self:copy_stats("x_m6g", "m6g", true)
		self:copy_sdescs("x_m6g", "m6g")
		self:copy_timers("x_m6g", "jowi")
		self.x_m6g.stats.concealment = 28
		self.x_m6g.AMMO_MAX = 48
		self.x_m6g.AMMO_PICKUP = self:_pickup_chance(48, 1)
	end

	if BeardLib.Utils:ModLoaded("AK-9") then
		self:inf_init("heffy_939", "smg", {"range_mcarbine"})
		self.heffy_939.sdesc1 = "caliber_r9x39"
		self.heffy_939.sdesc2 = "action_gaslong"
		self:copy_timers("heffy_939", "flint")
		self.heffy_939.stats.concealment = 24
		--self.heffy_939.reload_speed_mult = self.heffy_939.reload_speed_mult * 1.2 -- sound desync gets even worse
		self.heffy_939.AMMO_MAX = 100 -- secondary
		self.heffy_939.AMMO_PICKUP = self:_pickup_chance(100, 1)

		self:inf_init("x_heffy_939", "smg", {"range_mcarbine"})
		self:copy_stats("x_heffy_939", "heffy_939", true)
		self:copy_sdescs("x_heffy_939", "heffy_939")
		self:copy_timers("x_heffy_939", "x_akmsu")
		--self.x_heffy_939.stats.concealment = 23
		self.x_heffy_939.reload_speed_mult = self.x_heffy_939.reload_speed_mult * 1.15
		self.x_heffy_939.AMMO_MAX = 120
		self.x_heffy_939.AMMO_PICKUP = self:_pickup_chance(120, 1)
	end

	if BeardLib.Utils:ModLoaded("AK-47") then
		self:inf_init("heffy_762", "ar", {"medium"})
		self.heffy_762.sdesc1 = "caliber_r762x39"
		self.heffy_762.sdesc2 = "action_gaslong"
		self:copy_timers("heffy_762", "flint")
		self.heffy_762.stats.concealment = 18

		self:apply_standard_bipod_stats("heffy_762")
		self.heffy_762.custom_bipod = true
		pivot_shoulder_translation = Vector3(0, 0, 0)
		pivot_shoulder_rotation = Rotation(0, 0, 0)
		pivot_head_translation = Vector3(-10.25, -4.35, 4.95)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.heffy_762.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.heffy_762.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.heffy_762.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.heffy_762.use_custom_anim_state = true
		DelayedCalls:Add("akpack47delay", 0.50, function(self, params)
			tweak_data.weapon.heffy_762.bipod_weapon_translation = Vector3(-2, 5, -4)
		end)
	end

	-- heffy_545 AK74
	if BeardLib.Utils:ModLoaded("AK-74") and self.heffy_545 then
		self:inf_init("heffy_545", "ar", nil)
		self.heffy_545.sdesc1 = "caliber_r545x39"
		self.heffy_545.sdesc2 = "action_gaslong"
		self:copy_timers("heffy_545", "flint")
		self.heffy_545.stats.concealment = 20

		self:apply_standard_bipod_stats("heffy_545")
		self.heffy_545.custom_bipod = true
		pivot_shoulder_translation = Vector3(0, 0, 0)
		pivot_shoulder_rotation = Rotation(0, 0, 0)
		pivot_head_translation = Vector3(-10.25, -5.2, 4.90)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.heffy_545.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.heffy_545.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.heffy_545.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.heffy_545.use_custom_anim_state = true
		DelayedCalls:Add("akpack47delay", 0.50, function(self, params)
			tweak_data.weapon.heffy_545.bipod_weapon_translation = Vector3(-2, 5, -4)
		end)
	end

	-- AK Pack 2.0 AK-74
	if BeardLib.Utils:ModLoaded("AK-74") and self.ak_stamp_545 then
		self:inf_init("ak_stamp_545", "ar", nil)
		self.ak_stamp_545.sdesc1 = "caliber_r545x39"
		self.ak_stamp_545.sdesc2 = "action_gaslong"
		self:copy_timers("ak_stamp_545", "flint")
		self.ak_stamp_545.stats.concealment = 20

		self:apply_standard_bipod_stats("ak_stamp_545")
		self.ak_stamp_545.custom_bipod = true
		pivot_shoulder_translation = Vector3(0, 0, 0)
		pivot_shoulder_rotation = Rotation(0, 0, 0)
		pivot_head_translation = Vector3(-10.25, -5.2, 4.90)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.ak_stamp_545.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.ak_stamp_545.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.ak_stamp_545.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.ak_stamp_545.use_custom_anim_state = true
		DelayedCalls:Add("akpack74_akpack20_delay", 0.50, function(self, params)
			tweak_data.weapon.ak_stamp_545.bipod_weapon_translation = Vector3(-2, 5, -4)
		end)
	end

	-- heffy_556 AK-101
	if BeardLib.Utils:ModLoaded("AK-101") and self.heffy_556 then
		self:inf_init("heffy_556", "ar", nil)
		self.heffy_556.sdesc1 = "caliber_r545x39"
		self.heffy_556.sdesc2 = "action_gaslong"
		self:copy_timers("heffy_556", "flint")
	end

	-- AK Pack 2.0 AK-101
	if BeardLib.Utils:ModLoaded("AK-101") and self.ak_stamp_556 then
		self:inf_init("ak_stamp_556", "ar", nil)
		self.ak_stamp_556.sdesc1 = "caliber_r545x39"
		self.ak_stamp_556.sdesc2 = "action_gaslong"
		self:copy_timers("ak_stamp_556", "flint")
	end

	-- Golden AKMS heffy
	if BeardLib.Utils:ModLoaded("Golden-AKMS") and self.heffy_gold then
		self:inf_init("heffy_gold", "ar", {"medium"})
		self.heffy_gold.sdesc1 = "caliber_r762x39"
		self.heffy_gold.sdesc2 = "action_gaslong"
		self:copy_timers("heffy_gold", "flint")
		self.heffy_gold.price = 5*1000000
	end

	-- Golden AKMS AK Pack 2.0
	if BeardLib.Utils:ModLoaded("Golden AKMS") and self.ak_stamp_gold then
		self:inf_init("ak_stamp_gold", "ar", {"medium"})
		self.ak_stamp_gold.sdesc1 = "caliber_r762x39"
		self.ak_stamp_gold.sdesc2 = "action_gaslong"
		self:copy_timers("ak_stamp_gold", "flint")
		self.ak_stamp_gold.price = 5*1000000
	end

	-- AKM AK Pack 2.0
	if BeardLib.Utils:ModLoaded("AKM") and self.ak_stamp_762 then
		self:inf_init("ak_stamp_762", "ar", {"medium"})
		self.ak_stamp_762.sdesc1 = "caliber_r762x39"
		self.ak_stamp_762.sdesc2 = "action_gaslong"
		self:copy_timers("ak_stamp_762", "flint")
	end

	if BeardLib.Utils:ModLoaded("Saiga-12") then
		self:inf_init("heffy_12g", "shotgun", {"dmg_vlight", "rof_mag"})
		self:copy_sdescs("heffy_12g", "saiga")
		self:copy_timers("heffy_12g", "flint")
		self.heffy_12g.FIRE_MODE = "single"
		self.heffy_12g.reload_speed_mult = self.heffy_12g.reload_speed_mult * self:convert_reload_to_mult("mag_75")
	end

	if BeardLib.Utils:ModLoaded("AK Extra Attachments") then
		self:copy_timers("lpo70_flamethrower", "contraband_m203")
		self.lpo70_flamethrower.stats.damage = 25
		self.lpo70_flamethrower.timers.reload_empty_end = 1.50
		self.lpo70_flamethrower.CLIP_AMMO_MAX = 50
		self.lpo70_flamethrower.AMMO_MAX = 150
		self.lpo70_flamethrower.AMMO_PICKUP = self:_pickup_chance(150, 1)
		self.lpo70_flamethrower.fire_mode_data.fire_rate = 60/1200
		self.lpo70_flamethrower.auto.fire_rate = 60/1200
		self.lpo70_flamethrower.fire_dot_data = self.flamethrower_mk2.fire_dot_data
		--self.lpo70_flamethrower.animations.only_fullreload = true -- don't feel like unfucking underbarrel reloads right now
	end

	if BeardLib.Utils:ModLoaded("Nagant M1895") then
		self:inf_init("m1895", "pistol", "heavy")
		self.m1895.sdesc1 = "caliber_p762x38r"
		self.m1895.sdesc2 = "action_dasa"
		self.m1895.chamber = 0
		--self.m1895.stats.concealment = 28
		self:copy_timers("m1895", "peacemaker")
		self.m1895.anim_speed_mult = 1.50
		self.m1895.reload_speed_mult = self.m1895.reload_speed_mult * 1.35
		self.m1895.stats.damage = 220
	end

	if BeardLib.Utils:ModLoaded("VHS Various Attachment") then
		self:inf_init("vhs_m203", "grenade_launcher")
		self.vhs_m203.AMMO_MAX = 2
		self.vhs_m203.AMMO_PICKUP = {1338, 15}
		self:copy_timers("vhs_m203", "contraband_m203")
	--[[
		self.vhs_m203.timers.reload_not_empty = 2.35
		self.vhs_m203.timers.reload_not_empty_end = 0.40
		self.vhs_m203.timers.reload_empty = 2.35
		self.vhs_m203.timers.reload_empty_end = 0.40
	--]]

	end

	if BeardLib.Utils:ModLoaded("Kolibri") then
		self:inf_init("kolibri", "pistol")
		self.kolibri.sdesc1 = "caliber_p2mmkolibri"
		self.kolibri.sdesc2 = "action_gas"
		self.kolibri.sdesc3_type = "range"
		self.kolibri.fulldesc_show_range = true
		self:copy_timers("kolibri", "breech")
		--self.kolibri.stats.concealment = durrrrrrr
		self.kolibri.reload_speed_mult = self.kolibri.reload_speed_mult * 1.5
		self.kolibri.stats.damage = 100
		self.kolibri.stats.spread = 1
		self.kolibri.stats.recoil = self.kolibri.stats.recoil + 50
		self.kolibri.falloff_min_dmg = 0
		self.kolibri.falloff_begin = 300
		self.kolibri.falloff_end = 500
		self.kolibri.AMMO_MAX = 154
		self.kolibri.AMMO_PICKUP = self:_pickup_chance(154, 1)
		self.kolibri.fire_mode_data.fire_rate = 60/1000
	end

	if BeardLib.Utils:ModLoaded("Gepard GM6 Lynx") then
		self:inf_init("lynx", "snp", "superheavy")
		self.lynx.sdesc1 = "caliber_r50bmg"
		self.lynx.sdesc2 = "action_gas"
		self:copy_timers("lynx", "m95")
		self.lynx.stats.concealment = 10
		self.lynx.reload_speed_mult = self.lynx.reload_speed_mult * self:convert_reload_to_mult("mag_150")
		self.lynx.anim_speed_mult = 0.00001
		self.lynx.fire_mode_data.fire_rate = 60/120
		self.lynx.stats.damage = 30 -- 1500
		self.lynx.AMMO_MAX = 20
		self.lynx.AMMO_PICKUP = {1338, 75}
		self.lynx.animations.ignore_fullreload = nil
	end

	if BeardLib.Utils:ModLoaded("PPSh-41") then
		self:inf_init("ppsh", "smg", {"range_long"})
		self.ppsh.sdesc1 = "caliber_p762x25"
		self.ppsh.sdesc2 = "action_blowback"
		self:copy_timers("ppsh", "m45")
		self.ppsh.stats.concealment = 23
		self.ppsh.AMMO_MAX = 140
		self.ppsh.AMMO_PICKUP = self:_pickup_chance(140, 1)
		self.ppsh.chamber = 0
		self.ppsh.fire_mode_data.fire_rate = 60/900
		self:copy_timers_to_reload2("ppsh", "m1928")
	end

	if BeardLib.Utils:ModLoaded("PPS-43") then
		self:inf_init("pps43", "smg", {"range_long"})
		self.pps43.sdesc1 = "caliber_p762x25"
		self.pps43.sdesc2 = "action_blowback"
		self:copy_timers("pps43", "m45")
		self.pps43.stats.concealment = 24
		self.pps43.AMMO_MAX = 140
		self.pps43.AMMO_PICKUP = self:_pickup_chance(140, 1)
		self.pps43.chamber = 0
		self.pps43.fire_mode_data.fire_rate = 60/700
	end

	if BeardLib.Utils:ModLoaded("Kel-Tec RFB") then
		self:inf_init("leet", "ar", {"ldmr"})
		self.leet.sdesc1 = "caliber_r762x51"
		self.leet.sdesc2 = "action_gasshort"
		self:copy_timers("leet", "komodo")
		self.leet.CLIP_AMMO_MAX = 20
		DelayedCalls:Add("rfbflipturn", 0.50, function()
			-- i'm particular about seeing the reload animation wonkiness
			-- the misaligned mag/hand isn't as apparent in ADS, no adjustment needed
			self.leet.reload_timed_stance_mod = {
				not_empty = {
					hip = {
						{t = 2.8, translation = Vector3(6, 0, -40), rotation = Rotation(20, 50, 0), speed = 0.5}, -- rotate upwards
						{t = 0.5, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 0.5} -- return to default position
					}
				}, 
				empty = {
					hip = {
						{t = 3.4, translation = Vector3(6, 0, -40), rotation = Rotation(20, 50, 0), speed = 0.5}, -- rotate upwards
						{t = 1.0, translation = Vector3(6, 0, 0), rotation = Rotation(10, 25, 0), speed = 0.5}, -- rotate down and raise to cock
						{t = 0.5, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 0.5} -- return to default position
					}
				}
			}
		end)
	end

	if BeardLib.Utils:ModLoaded("Silent Killer High Standard HDM") then
		self:inf_init("hshdm", "pistol", "medium")
		self.hshdm.sdesc1 = "caliber_p22lr"
		self.hshdm.sdesc2 = "action_blowback"
		self.hshdm.sdesc4 = "misc_alwayssilent"
		--self.hshdm.stats.concealment = 29
		self:copy_timers("hshdm", "breech")
		self.hshdm.reload_speed_mult = self.hshdm.reload_speed_mult * self:convert_reload_to_mult("mag_125")

		self:inf_init("x_hshdm", "pistol", "medium")
		self:copy_stats("x_hshdm", "hshdm", true)
		self:copy_sdescs("x_hshdm", "hshdm")
		self:copy_timers("x_hshdm", "x_breech")
		--self.x_hshdm.stats.concealment = 29
		self.x_hshdm.AMMO_MAX = 100
		self.x_hshdm.AMMO_PICKUP = self:_pickup_chance(100, 1)
		self.x_hshdm.reload_speed_mult = self.x_hshdm.reload_speed_mult * self:convert_reload_to_mult("mag_125")
	end

	if BeardLib.Utils:ModLoaded("Silent Killer Maxim 9") then
		self:inf_init("max9", "pistol", nil)
		self.max9.sdesc1 = "caliber_p9x19"
		self.max9.sdesc2 = "action_blowback"
		self.max9.sdesc4 = "misc_alwayssilent"
		self.max9.AMMO_MAX = 153
		self.max9.AMMO_PICKUP = self:_pickup_chance(153, 1)
		--self.max9.stats.concealment = 28
		self:copy_timers("max9", "hs2000")
	end

	if BeardLib.Utils:ModLoaded("Silent Killer Welrod") then
		self:inf_init("welrod", "pistol", "heavy")
		self.welrod.sdesc1 = "caliber_p32acp"
		self.welrod.sdesc2 = "action_bolt"
		self.welrod.sdesc4 = "misc_alwayssilent"
		self.welrod.fire_mode_data = {fire_rate = 60/60}
		self.welrod.stats.damage = 240
		self.welrod.stats.concealment = 30
		self:copy_timers("welrod", "ppk")
		self.welrod.reload_speed_mult = self.welrod.reload_speed_mult * self:convert_reload_to_mult("mag_200")
		self.welrod.timers.reload_empty_end = 0.75 -- reload time w/reload_end should be 2.80
	-- all this should already be in the welrod
	--[[
		self.welrod.timers.reload_empty = 2.80
		self.welrod.reload_timed_stance_mod = {
			empty = {
				hip = {
					{t = 2.80, translation = Vector3(0, 0, -10), rotation = Rotation(0, 0, 0), speed = 1},
					{t = 0.90, translation = Vector3(-5, -5, -20), rotation = Rotation(0, -10, -50), speed = 2},
					{t = 0.80, translation = Vector3(-5, -5, -20), rotation = Rotation(0, -10, -50), speed = 2, sound = "welrod_twist_open"},
					{t = 0.65, translation = Vector3(-5, -10, -20), rotation = Rotation(0, -10, -50), speed = 2, sound = "welrod_boltback"},
					{t = 0.40, translation = Vector3(-5, -10, -20), rotation = Rotation(0, 0, -25), speed = 2, sound = "welrod_boltrelease"},
					{t = 0.25, translation = Vector3(-5, -5, -10), rotation = Rotation(0, 0, -15), speed = 3, sound = "welrod_twist_close"},
					{t = 0.00, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1}
				},
				ads = {
					{t = 2.80, translation = Vector3(0, 0, -10), rotation = Rotation(0, 0, 0), speed = 1},
					{t = 0.90, translation = Vector3(-5, -5, -25), rotation = Rotation(0, -10, -50), speed = 2},
					{t = 0.80, translation = Vector3(-5, -5, -30), rotation = Rotation(0, -10, -50), speed = 2, sound = "welrod_twist_open"},
					{t = 0.65, translation = Vector3(-5, -10, -30), rotation = Rotation(0, -10, -50), speed = 2, sound = "welrod_boltback"},
					{t = 0.40, translation = Vector3(-5, -10, -25), rotation = Rotation(0, 0, -25), speed = 2, sound = "welrod_boltrelease"},
					{t = 0.25, translation = Vector3(-5, -5, -10), rotation = Rotation(0, 0, -15), speed = 3, sound = "welrod_twist_close"},
					{t = 0.00, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1}
				}
			}
		}
		self.welrod.fire_timed_stance_mod = {
			ads = {
				{t = 0, translation = Vector3(0, -10, -5), rotation = Rotation(0, 10, 0), speed = 2},
				{t = 0.15, translation = Vector3(0, -5, -40), rotation = Rotation(0, 30, 20), speed = 2, sound = "welrod_twist_open"},
				{t = 0.30, translation = Vector3(0, -10, -40), rotation = Rotation(0, 32, 20), speed = 2, sound = "welrod_boltback"},
				{t = 0.60, translation = Vector3(0, -5, -40), rotation = Rotation(0, 30, 20), speed = 2, sound = "welrod_boltrelease"},
				{t = 0.80, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1, sound = "welrod_twist_close"}
			},
			hip = {
				{t = 0, translation = Vector3(0, -10, -5), rotation = Rotation(0, 10, 0), speed = 2},
				{t = 0.15, translation = Vector3(0, -5, -30), rotation = Rotation(10, -10, -70), speed = 2, sound = "welrod_twist_open"},
				{t = 0.30, translation = Vector3(0, -10, -30), rotation = Rotation(10, -8, -70), speed = 2, sound = "welrod_boltback"},
				{t = 0.60, translation = Vector3(0, -5, -30), rotation = Rotation(10, -10, -70), speed = 2, sound = "welrod_boltrelease"},
				{t = 0.80, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1, sound = "welrod_twist_close"}
			}
		}
	--]]
	end

	if BeardLib.Utils:ModLoaded("PB") then
		self:inf_init("pb", "pistol", "medium")
		self.pb.sdesc1 = "caliber_p9x18"
		self.pb.sdesc2 = "action_blowbackstraight"
		self:copy_timers("pb", "lemming")
		self.pb.reload_speed_mult = self.pb.reload_speed_mult * self:convert_reload_to_mult("mag_50")
		self.pb.stats.recoil = self.pb.stats.recoil - 3
		self.pb.stats.concealment = 30
	end

	if BeardLib.Utils:ModLoaded("Browning Auto Shotgun") then
		self:inf_init("auto5", "shotgun", {"dmg_light", "rof_semi"})
		self.auto5.sdesc1 = "caliber_s12g"
		self.auto5.sdesc2 = "action_longrecoil"
		self.auto5.AMMO_MAX = 24
		self.auto5.AMMO_PICKUP = self:_pickup_chance(24, 1)
		self.auto5.stats.spread = self.auto5.stats.spread + 20
		--self.auto5.stats.concealment = 20
		self:copy_timers("auto5", "benelli")
	end

	if BeardLib.Utils:ModLoaded("M40A5") then
		self:inf_init("m40a5", "snp", nil)
		self.m40a5.sdesc1 = "caliber_r762x51"
		self.m40a5.sdesc2 = "action_bolt"
		self:copy_timers("m40a5", "model70")
		self.m40a5.stats.concealment = 19

		self:apply_standard_bipod_stats("m40a5")
		self.m40a5.custom_bipod = true
		self.m40a5.bipod_weapon_translation = Vector3(0, 6, -4)
		pivot_shoulder_translation = Vector3(19.47, 29, -7.77)
		pivot_shoulder_rotation = Rotation(0, 0, 0)
		pivot_head_translation = Vector3(11.5, 37, -4.75)
		pivot_head_rotation = Rotation(0, 0, 0)
		self.m40a5.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
		self.m40a5.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		self.m40a5.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
		self.m40a5.use_custom_anim_state = true
		self.m40a5.bipod_rof_mult = 1.25
		if self.SetupAttachmentPoint then
			self:SetupAttachmentPoint("m40a5", {
				name = "a_bp",
				base_a_obj = "a_body",
				position = Vector3(0, 68, 4),
				rotation = Rotation(0, 0, 0)
			})
		end
	end

	if BeardLib.Utils:ModLoaded("Desert Tech MDR") then
		self:inf_init("mdr", "ar", {"heavy"})
		self.mdr.sdesc1 = "caliber_r762x51"
		self.mdr.sdesc2 = "action_gas"
		self.mdr.stats.spread = self.mdr.stats.spread - 10
		--self.mdr.stats.concealment = 24
		self:copy_timers("mdr", "aug")
	end

	if BeardLib.Utils:ModLoaded("FN SCAR-L") then
		self:inf_init("scarl", "ar", nil)
		self.scarl.sdesc1 = "caliber_r556x45"
		self.scarl.sdesc2 = "action_pistonshort"
		self.scarl.stats.concealment = 21
		self:copy_timers("scarl", "new_m4")
	end

	if BeardLib.Utils:ModLoaded("FN SCAR-L M203") then
		self:inf_init("scar_m203", "ar", {"has_gl"})
		self.scar_m203.sdesc1 = "caliber_r556x45"
		self.scar_m203.sdesc2 = "action_pistonshort"
		self.scar_m203.stats.concealment = 16
		self:copy_timers("scar_m203", "contraband")

		self.scar_m203gl.AMMO_MAX = 2
		self.scar_m203gl.AMMO_PICKUP = {1338, 15}
		self:copy_timers("scar_m203gl", "contraband_m203")

		self:inf_init("scar_m203buckshot", "shotgun", {"dmg_heavy"})
		self.scar_m203buckshot.stats.damage = 100 -- 500
		self.scar_m203buckshot.stats_modifiers = {damage = 5}
		self.scar_m203buckshot.rays = 20
		self.scar_m203buckshot.damage_near = 1000
		self.scar_m203buckshot.damage_far = 1500
		self.scar_m203buckshot.armor_piercing_chance = 1
		self.scar_m203buckshot.stats.spread = 20
		self.scar_m203buckshot.AMMO_MAX = 4
		self.scar_m203buckshot.AMMO_PICKUP = {1338, 50}
		self:copy_timers("scar_m203buckshot", "contraband_m203")
		self.scar_m203buckshot.reload_speed_mult = 1.20

		--[[
		self:inf_init("scar_m203flechette", "shotgun", {"dmg_heavy"})
		self.scar_m203flechette.stats.damage = 75 -- 375
		self.scar_m203flechette.stats_modifiers = {damage = 5}
		self.scar_m203flechette.rays = 28
		self.scar_m203flechette.damage_near = 1000 * 1.25
		self.scar_m203flechette.damage_far = 1500 * 1.25
		self.scar_m203flechette.armor_piercing_chance = 1
		self.scar_m203flechette.stats.spread = 40
		self.scar_m203flechette.AMMO_MAX = 4
		self.scar_m203flechette.AMMO_PICKUP = {1338, 50}
		self:copy_timers("scar_m203flechette", "contraband_m203")
		self.scar_m203flechette.reload_speed_mult = 1.20
		]]
	end

	--[[
	if BeardLib.Utils:ModLoaded("Kar98k") then
		Hooks:RemovePostHook("kar98kInit")
		self:inf_init("kar98k", "snp", "heavy")
		self.kar98k.sdesc1 = "caliber_r792mauser"
		self.kar98k.sdesc2 = "action_bolt"
		self:copy_timers("kar98k", "mosin")
		self.kar98k.chamber = 0
		self.kar98k.stats.concealment = 21
		self.kar98k.damage_near = 10000
		self.kar98k.damage_far = 10000
	end
	--]]

	-- kar98k
	if self.kar98k then
		-- This fucks up the reload times immensely, let's not. Sorry!
		Hooks:RemovePostHook("kar98kInit")

		self:inf_init("kar98k", "snp", "heavy")
		self.kar98k.sdesc1 = "caliber_r792mauser"
		self.kar98k.sdesc2 = "action_bolt"
		self:copy_timers("kar98k", "mosin")
		self.kar98k.chamber = 0
		self.kar98k.stats.concealment = 21
		self.kar98k.damage_near = 10000
		self.kar98k.damage_far = 10000
		self.kar98k.rays = 1
	end

	if BeardLib.Utils:ModLoaded("Golden Gun") then
		self:inf_init("goldgun", "pistol", "heavy")
		self.goldgun.categories = {"pistol"}
		self.goldgun.sdesc1 = "caliber_pscaramanga"
		self.goldgun.sdesc2 = "action_breech"
		self.goldgun.fire_mode_data = {fire_rate = 60/60}
		self.goldgun.AMMO_MAX = 12
		self.goldgun.AMMO_PICKUP = {1338, 50}
		self.goldgun.chamber = 0
		self.goldgun.stats.damage = 120 -- 600
		self.goldgun.stats.concealment = 30
		self:copy_timers("goldgun", "ppk")
		self.goldgun.stats_modifiers.damage = 5
		DelayedCalls:Add("goldgunflipturn", 0.50, function(self, params)
			tweak_data.weapon.goldgun.reload_timed_stance_mod = {
				empty = {
					hip = {
						{t = 1, translation = Vector3(0, 0, -50), rotation = Rotation(0, 0, 0), speed = 1, sound = "goldgun_reload"},
						{t = 0.5, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1.2}
					},
					ads = {
						{t = 1, translation = Vector3(0, 0, -50), rotation = Rotation(0, 0, 0), speed = 1, sound = "goldgun_reload"},
						{t = 0.5, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1.2}
					}
				}
			}
		end)
	end

	if BeardLib.Utils:ModLoaded("SKS") then
		self:inf_init("sks", "ar", {"ldmr"})
		self.sks.sdesc1 = "caliber_r762x39"
		self.sks.sdesc2 = "action_gasshort"
		self:copy_timers("sks", "siltstone")
		self.sks.stats.concealment = 22
	end

	if BeardLib.Utils:ModLoaded("MAS-49") then
		self:inf_init("mas49", "ar", {"dmr"})
		self.mas49.sdesc1 = "caliber_r75x54"
		self.mas49.sdesc2 = "action_di"
		self:copy_timers("mas49", "siltstone")
		self.mas49.stats.concealment = 18
	end

	if BeardLib.Utils:ModLoaded("AK-12") then
		self:inf_init("ak12", "ar", nil)
		self.ak12.desc_id = "bm_w_ak12_200_desc"
		self.ak12.sdesc1 = "caliber_r545x39"
		self.ak12.sdesc2 = "action_gaslong"
		self.ak12.stats.concealment = 20
		self:copy_timers("ak12", "flint")
	end

	if BeardLib.Utils:ModLoaded("AK-12/76") then
		self:inf_init("ak12_76", "shotgun", {"dmg_vlight", "rof_mag"})
		self.ak12_76.sdesc1 = "caliber_s12g"
		self.ak12_76.sdesc2 = "action_gaslong"
		self:copy_timers("ak12_76", "flint")
		self.ak12_76.FIRE_MODE = "single"
	end

	-- Oh boy this is a big one
	if BeardLib.Utils:ModLoaded("Vanilla Styled Weapon Mods") and self.amr12 then

		-- AMR12 shotgun
		self:inf_init("amr12", "shotgun", {"dmg_vlight", "rof_mag"})
		self.amr12.sdesc1 = "caliber_s12g" -- The AMR12 is not real and it cant hurt you
		self.amr12.sdesc2 = "action_di"
		self.amr12.recategorize = "shotgun"
		self:copy_timers("amr12", "olympic")

		-- SG 416 (HK416)
		self:inf_init("sg416", "ar", nil)
		self.sg416.sdesc1 = "caliber_r556x45"
		self.sg416.sdesc2 = "action_pistonshort"
		self:copy_timers("sg416", "amcar")
		self.sg416.stats.concealment = 18

		-- Mamba 5.56
		self:inf_init("aknato", "ar", nil)
		self.aknato.sdesc1 = "caliber_r556x45"
		self.aknato.sdesc2 = "action_gaslong"
		self:copy_timers("aknato", "new_m4")
		self.aknato.stats.concealment = 19

		-- An AK turned into a shotgun with the SAIGA, turned into a bullpup with the Grimm
		-- And now you turn it into an AR again
		-- RIFLE IS FINE

		-- based_on should be used for sync purposes and such, not which weapon most closely resembles it visually
		-- This weapon oughta be based_on the AKM instead
		-- Now I have to unshotgun-ify it
		self.spike.sdesc3_type = nil
		self.spike.fulldesc_show_range = nil
		self.spike.damage_near = nil
		self.spike.damage_far = nil
		self.spike.rays = nil
		self.spike.categories = {"assault_rifle"}
		self:inf_init("spike", "ar", {"medium"})
		self.spike.sdesc1 = "caliber_r762x39"
		self.spike.sdesc2 = "action_gaslong"
		self:copy_timers("spike", "basset")
		self.spike.stats.damage = 15 -- 75 damage. Somehow this isnt working in inf_init despite initializing the weapon properly
		-- UPDATE: This is probably because the Spiker is based on the GRIMM and is internally still a shotgun using the ShotgunBase class

		-- Commando/SG552 DMR
		self:inf_init("sgs", "ar", {"ldmr"})
		self.sgs.sdesc1 = "caliber_r308"
		self.sgs.sdesc2 = "action_gas"
		self.sgs.stats.concealment = 20
		self.sgs.CLIP_AMMO_MAX = 20
		self:copy_timers("sgs", "shepheard")

		-- Full auto crosskill lebman
		-- These fire .38 super which is comparable in terms of both velocity and energy, so the damage is still the same.
		-- Hella recoil though
		self:inf_init("lebman", "pistol", "medium")
		self.lebman.sdesc1 = "caliber_p38sup"
		self.lebman.sdesc2 = "action_shortrecoil"
		self.lebman.CLIP_AMMO_MAX = 7
		self.lebman.AMMO_MAX = 77
		self.lebman.AMMO_PICKUP = self:_pickup_chance(77, 1)
		self.lebman.stats.concealment = 26
		self:copy_timers("lebman", "beer")
		-- The sounds are currently the B93R's which is inconsistent. Change it to the crosskill sounds since we use an autofire sound fix anyway
		self.lebman.sounds.fire = "c45_fire"
		self.lebman.sounds.fire_single = "c45_fire"

		self:inf_init("x_lebman", "pistol", "medium")
		self.x_lebman.sdesc1 = "caliber_p38sup"
		self.x_lebman.sdesc2 = "action_shortrecoil"
		self:copy_timers("x_lebman", "x_beer")
		self.x_lebman.stats.concealment = 26
		self.x_lebman.stats.recoil = self.lebman.stats.recoil - 4
		self.x_lebman.CLIP_AMMO_MAX = self.lebman.CLIP_AMMO_MAX * 2
		self.x_lebman.AMMO_MAX = 98
		self.x_lebman.AMMO_PICKUP = self:_pickup_chance(98, 1)
		self.x_lebman.sounds.fire = "c45_fire"
		self.x_lebman.sounds.fire_single = "c45_fire"

		-- Classic Crosskill
		self:inf_init("cold", "pistol", "medium")
		self.cold.sdesc1 = "caliber_p45acp"
		self.cold.sdesc2 = "action_shortrecoil"
		self:copy_timers("cold", "colt_1911")
		self.cold.CLIP_AMMO_MAX = 7
		self.cold.AMMO_MAX = 77
		self.cold.AMMO_PICKUP = self:_pickup_chance(77, 1)

		self:inf_init("x_cold", "pistol", "medium")
		self.x_cold.sdesc1 = "caliber_p45acp"
		self.x_cold.sdesc2 = "action_shortrecoil"
		self:copy_timers("x_cold", "x_1911")
		self.x_cold.CLIP_AMMO_MAX = self.cold.CLIP_AMMO_MAX * 2
		self.x_cold.AMMO_MAX = 98
		self.x_cold.AMMO_PICKUP = self:_pickup_chance(98, 1)
		self.x_cold.stats.recoil = self.cold.stats.recoil - 4

		-- ACAR-9 SMG
		self:inf_init("car9", "smg", {"range_carbine"})
		self.car9.sdesc1 = "caliber_r556x45"
		self.car9.sdesc2 = "action_di"
		self.car9.stats.concealment = 26
		self.car9.CLIP_AMMO_MAX = 25
		self.car9.AMMO_MAX = 120
		self.car9.AMMO_PICKUP = self:_pickup_chance(120, 1)
		self:copy_timers("car9", "olympic")

		self:inf_init("x_car9", "smg", {"range_carbine"})
		self.x_car9.sdesc1 = "caliber_r556x45"
		self.x_car9.sdesc2 = "action_di"
		self.x_car9.stats.concealment = 26
		self.x_car9.CLIP_AMMO_MAX = self.car9.CLIP_AMMO_MAX * 2
		self.x_car9.AMMO_MAX = 180
		self.x_car9.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self:copy_timers("x_car9", "x_olympic")

		-- Automat-5 SMG (Swedish AK5 in SMG form)
		self:inf_init("ak5s", "smg", {"range_carbine"})
		self.ak5s.sdesc1 = "caliber_r556x45"
		self.ak5s.sdesc2 = "action_gas"
		self:copy_timers("ak5s", "akmsu")

		self:inf_init("x_ak5s", "smg", {"range_carbine"})
		self.x_ak5s.sdesc1 = "caliber_r556x45"
		self.x_ak5s.sdesc2 = "action_gas"
		self:copy_timers("x_ak5s", "x_akmsu")

		-- Dragon 5.45 pistol (AK pistol??? What in fuck)
		self:inf_init("smolak", "pistol", "heavy")
		self.smolak.sdesc1 = "caliber_r545x39"
		self.smolak.sdesc2 = "action_gaslongaks74"
		self.smolak.CLIP_AMMO_MAX = 10
		self:copy_timers("smolak", "deagle")

		self:inf_init("x_smolak", "pistol", "heavy")
		self.x_smolak.sdesc1 = "caliber_r545x39"
		self.x_smolak.sdesc2 = "action_gaslongaks74"
		self.x_smolak.CLIP_AMMO_MAX = self.smolak.CLIP_AMMO_MAX * 2
		self:copy_timers("x_smolak", "x_deagle")

		-- Classic reinbeck shotgun
		self:inf_init("beck", "shotgun", {"rof_slow", "range_slowpump"})
		self.beck.sdesc1 = "caliber_s12g"
		self.beck.sdesc2 = "action_pump"
		self.beck.stats.concealment = 20
		self:copy_timers("beck", "r870")
	end

	-- M4 SOPMOD II
	if self.soppo then
		self:inf_init("soppo", "ar", {"has_gl"})
		self:copy_sdescs("soppo", "new_m4")
		self:copy_timers("soppo", "new_m4")
		self.soppo.fire_mode_data.fire_rate = 60/700
		self.soppo.stats.concealment = 15
	end

	-- Lo Wang Sidekick Uzi
	if self.uzi_lowang then
		self:copy_stats("uzi_lowang", "uzi", false)
		self:copy_sdescs("uzi_lowang", "uzi", false)
	end

	if self.x_uzi_lowang then
		-- These are actually Akimbos, but false is passed into copy_stats and sdescs because an already akimbo weapon is being copied from
		self:copy_stats("x_uzi_lowang", "x_uzi", false)
		self:copy_sdescs("x_uzi_lowang", "x_uzi", false)
	end

	-- Deck-ARD pistol
	if self.deckard then
		self:inf_init("deckard", "pistol", "heavy")
		self.deckard.sdesc1 = "caliber_p40sw"
		self.deckard.sdesc2 = "action_wang"
		self:copy_timers("deckard", "new_raging_bull")
	end

	if self.x_deckard then
		self:inf_init("x_deckard", "pistol", "heavy")
		self.x_deckard.sdesc1 = "caliber_p40sw"
		self.x_deckard.sdesc2 = "action_wang"
		self:copy_timers("deckard", "new_raging_bull")
	end

	-- Vanilla styled mod pack vol. 2, Hornet .300 Rifle
	if self.bdgr then
		self:inf_init("bdgr", "ar", nil)
		self.bdgr.categories = {"assault_rifle"}
		self.bdgr.sdesc1 = "caliber_r300blackout"
		self.bdgr.sdesc2 = "action_di"
		self:copy_stats("bdgr", "olympic")
		self.bdgr.stats.concealment = 26
		self.bdgr.CLIP_AMMO_MAX = 20
		self.bdgr.AMMO_MAX = 180
		self.bdgr.AMMO_PICKUP = self:_pickup_chance(180, 1)
		self:copy_timers("bdgr", "olympic")
	end

	-- Mini reinbeck, Secondary Locomotive shotgun ("Reinbeck Auto Shotgun")
	if self.minibeck then
		self:inf_init("minibeck", "shotgun", {"range_short", "rof_semi"})
		self.minibeck.sdesc1 = "caliber_s12g"
		self.minibeck.sdesc2 = "action_pump"
		self:copy_timers("minibeck", "serbu")
	end

	-- McMillan CS5
	if self.cs5 then
		self:inf_init("cs5", "snp", nil)
		self.cs5.sdesc1 = "caliber_r308"
		self.cs5.sdesc2 = "action_bolt"
		self.cs5.stats.concealment = 17
		self:copy_timers("cs5", "msr")
	end

	-- Mars Automatic Pistol
	if self.mars then
		self:inf_init("mars", "pistol", "heavy")
		self.mars.sdesc1 = "caliber_p45mars"
		self.mars.sdesc2 = "action_longrecoilrotating"
		self:copy_timers("mars", "deagle")
	end

	-- FN MK17 MOD 0 (Eagle Tactical Rifle)
	if self.mk17 then
		self:inf_init("mk17", "ar", {"heavy"})
		self.mk17.concealment = 18
		self.mk17.sdesc1 = "caliber_r762x51"
		self.mk17.sdesc2 = "action_pistonshort"
		self:copy_timers("mk17", "scar")
	end
	
	-- CARL WAS HERE
	
	--my own guns
	if self.hoxy then
		self:inf_init("hoxy", "pistol", nil)
		-- self.hoxy.concealment = 69
		self.hoxy.sdesc1 = "caliber_p57"
		self.hoxy.sdesc2 = "action_blowbackdelayed"
		self:copy_timers("hoxy", "packrat")
	end

	-- ST AR-15
	if self.flat then
		self:inf_init("flat", "ar", {"ldmr"})
		self.flat.sdesc1 = "caliber_r762x51"
		self.flat.sdesc2 = "action_di"
		self.flat.stats.concealment = 21
		self:copy_timers("flat", "new_m14")
	end

	-- Desert Eagle Duet
	-- Desert Eagle XIX
	if self.deltaoneniner then
		self:inf_init("deltaoneniner", "pistol", "heavy")
		self.deltaoneniner.sdesc1 = "caliber_p50ae"
		self.deltaoneniner.sdesc2 = "action_gas"
		self.deltaoneniner.CLIP_AMMO_MAX = 7
		self.deltaoneniner.stats.concealment = 28
		self:copy_timers("deltaoneniner", "deagle")
	end

	-- Desert Eagle L5
	if self.limafive then
		self:inf_init("limafive", "pistol", "heavy")
		self.limafive.sdesc1 = "caliber_p50ae"
		self.limafive.sdesc2 = "action_gas"
		self.limafive.stats.concealment = 28
		self.limafive.CLIP_AMMO_MAX = 7
		self:copy_timers("limafive", "deagle")
	end

	-- Half-Life 9mm pistol
	if self.hl1g then
		self:inf_init("hl1g", "pistol", nil)
		self.hl1g.sdesc1 = "caliber_p9x19"
		self.hl1g.sdesc2 = "action_shortrecoil"
		self.hl1g.CLIP_AMMO_MAX = 17
		self.hl1g.AMMO_MAX = 152
		self.hl1g.AMMO_PICKUP = self:_pickup_chance(152, 1)
		self.hl1g.recategorize = nil
		self:copy_timers("hl1g", "b92fs")

		-- Same but Akimbo
		if self.x_hl1g then
			self:inf_init("x_hl1g", "pistol", nil)
			self:copy_sdescs("x_hl1g", "hl1g", true)
			self.x_hl1g.CLIP_AMMO_MAX = 34
			self.x_hl1g.AMMO_MAX = 170
			self.x_hl1g.AMMO_PICKUP = self:_pickup_chance(170, 1)
			self.x_hl1g.recategorize = nil
			self:copy_timers("x_hl1g", "x_b92fs")
		end
	end

	-- Glock 17 Gen 3
	if self.glawk then
		self:inf_init("glawk", "pistol", nil)
		self.glawk.sdesc1 = "caliber_p9x19"
		self.glawk.sdesc2 = "action_shortrecoil"
		self.glawk.CLIP_AMMO_MAX = 15
		self.glawk.AMMO_MAX = 150
		self.glawk.AMMO_PICKUP = self:_pickup_chance(150, 1)
		self.glawk.recategorize = nil
		self:copy_timers("glawk", "b92fs")
	end

	-- S&W M&P40
	if self.swmp40 then
		self:inf_init("swmp40", "pistol", nil)
		self.swmp40.sdesc1 = "caliber_p40sw"
		self.swmp40.sdesc2 = "action_shortrecoil"
		self:copy_timers("swmp40", "sparrow")
	end

	-- Glock 19
	if self.g19 then
		self:inf_init("g19", "pistol", nil)
		self.g19.sdesc1 = "caliber_p9x19"
		self.g19.sdesc2 = "action_shortrecoil"
		self:copy_timers("g19", "glock_17")
	end

	-- USP Tactical
	if self.usptac then
		self:inf_init("usptac", "pistol", "medium")
		self.usptac.sdesc1 = "caliber_p40sw"
		self.usptac.sdesc2 = "action_shortrecoil"
		self.usptac.stats.concealment = 28
		self:copy_timers("usptac", "usp")
	end

	-- TTI TR-1 Ultralight (Wholesome but also gay)
	if self.hugsforleon then
		self:inf_init("hugsforleon", "ar", nil)
		self.hugsforleon.sdesc1 = "caliber_r556x45"
		self.hugsforleon.sdesc2 = "action_di"
		self.hugsforleon.FIRE_MODE = "single"
		self.hugsforleon.CAN_TOGGLE_FIREMODE = false
		self:copy_timers("hugsforleon", "new_m4")
	end

	-- Remington ACR
	-- With grenade launcher
	if self.acwr then
		Hooks:RemovePostHook("acwrModInit")
		self:inf_init("acwr", "ar", {"has_gl"})
		self.acwr.sdesc1 = "caliber_r556x45"
		self.acwr.sdesc2 = "action_gas"
		self.acwr.fire_mode_data.fire_rate = 60/650
		self:copy_timers("acwr", "contraband")
	end
	-- Without GL
	if self.acwr2 then
		self:inf_init("acwr2", "ar", nil)
		self.acwr2.sdesc1 = "caliber_r556x45"
		self.acwr2.sdesc2 = "action_gas"
		self.acwr2.fire_mode_data.fire_rate = 60/650
		self:copy_timers("acwr2", "new_m4")
	end

	-- Dokkaebi SMG-12
	if self.master then
		self:inf_init("master", "smg", {"dmg_50"})
		self.master.sdesc1 = "caliber_r380acp"
		self.master.sdesc2 = "action_shortrecoil"
		self.master.recategorize = "smg"
		self:copy_timers("master", "mac10")
	end

	-- Triton TR-15
	if self.hometown then
		self:inf_init("hometown", "ar", {"medium"})
		self:copy_sdescs("hometown", "m16")
		self:copy_timers("hometown", "m16")
		self.hometown.concealment = 20
	end

	-- No weapon
	-- Am I really adding support for this
	-- Secondary (based on glock)
	if self.nothing then
		self.nothing.sdesc3_type = nil
		self.nothing.sdesc1 = "caliber_nothing"
	end

	-- Primary (based on amcar)
	if self.nothing2 then
		self.nothing2.stats.damage = 0
		self.nothing2.sdesc1 = "caliber_nothing"
	end

	-- Serious Sam Minigun
	if self.xm214a then
		self:inf_init("xm214a", "minigun")
		self:copy_sdescs("xm214a", "m134")
		self:copy_stats("xm214a", "m134")
		self:copy_timers("xm214a", "m134")
	end

	-- M45 MEUSOC
	if self.meusoc then
		self:inf_init("meusoc", "pistol", "medium")
		self:copy_sdescs("meusoc", "colt_1911")
		self:copy_stats("meusoc", "colt_1911")
		self:copy_timers("meusoc", "pl14")
	end
	-- Akimbo version
	if self.x_meusoc then
		self:inf_init("x_meusoc", "pistol", "medium")
		self:copy_sdescs("x_meusoc", "x_1911")
		self:copy_stats("x_meusoc", "x_1911")
		self:copy_timers("x_meusoc", "x_pl14")
    end
    
	-- HOW TO ADD CUSTOM WEAPON SUPPORT:
	-- Open the custom weapon's main.xml file and find out its id (<weapon id="glawk"> for instance)
	-- Then do something like this for pistols:

	--[[
	-- You first check if the weapon's ID exists. This is the most reliable method.
	if self.g19 then
		-- Init the weapon as a pistol and give it the pistol stats completely automatically. The third argument decides how heavy the pistol is.
		-- There's nil (light), medium, supermedium, and heavy. Supermedium isn't used in vanilla.
		self:inf_init("g19", "pistol", nil)

		-- These two are short descriptions shown in the inventory. The first one is the weapon's default caliber, second is its action.
		-- You need to set at least one of these two for the description to work nicely, but preferably set both.
		-- You can find these in renames.lua. If you can't find the one you need, add a new one there.
		self.g19.sdesc1 = "caliber_p9x19"
		self.g19.sdesc2 = "action_shortrecoil"

		-- Copy the reload timers and the stance mods. First argument is destination, second is source.
		-- In many cases, the second argument should be whatever the weapon's based_on is (which weapon it'll appear as for others).
		-- If not, take whatever weapon matches best.
		-- Some reload timer tweaking may be necessary if you're copying them from a weapon that isn't the based_on (or if the animation was changed)
		self:copy_timers("g19", "glock_17")
	end
	]]

	-- For AR's, you need to do pretty much the same thing as pistols.
	-- For the init there's this:
	-- self:inf_init("m16", "ar", {"medium"})
	-- The third argument is a table. Once again, nil means light rifle, medium is medium rifle, heavy is heavy rifle.
	-- There's also ldmr, dmr and hdmr. hdmr isn't used in vanilla but it does exist.
	-- If the weapon has an underbarrel, add "has_gl" to the table. If the weapon is a light AR, you don't have to specify "nil". Example:
	-- self:inf_init("soppo", "ar", {"has_gl"})

	-- SMG's are similar to AR's, but you have to specify a range for them.
	-- self:inf_init("car9", "smg", {"range_carbine"})
	-- There's range_carbine, range_mcarbine, range_short and range_long.
	-- There's also dmg_50, check the default weapons up top

	-- Shotguns are a little different. You can specify all sorts of ranges, damage and rates of fire for these.
	--[[
		self:inf_init("coach", "shotgun", {"dmg_heavy", "rof_db"})

		self:inf_init("r870", "shotgun", {"rof_slow", "range_slowpump"})

		self:inf_init("ksg", "shotgun", {"dmg_mid"})
		self:inf_init("benelli", "shotgun", {"dmg_light", "rof_semi"})
	]]
	-- Ranges: dmg_vlight, dmg_light, dmg_mid, dmg_heavy, dmg_aa12
	-- Rates of fire: rof_semi, rof_mag, rof_db
	-- Ranges: range_short, range_slowpump, range_long
	-- Not all of these have to be specified. Pump shotguns don't need rate of fire.

	-- Snipers have nil (regular), heavy, superheavy.
	-- self:inf_init("cs5", "snp", nil)

	-- LMG's only have medium and heavy.
	-- self:inf_init("m249", "lmg", "medium")

	-- GL's can be initialized but it hardly does anything (is just for the blackmarket stats screen), just copy the M79, MGL or China Lake or something
	-- Actual grenade damage is probably defined elsewhere in projectiletweakdata
	-- self.my_gl.stats.damage = self.gre_m79.stats.damage

	-- Miniguns and bows/xbows can be initialized too. But it won't do much for bows.
	-- self:inf_init("myminigun", "minigun")
	-- self:inf_init("mybow", "bow")
	-- self:inf_init("mycrossbow", "crossbow")

	-- After calling init on any weapon, feel free to tweak its stats further. Concealment nearly always needs some more tweaks,
	-- but maybe your custom weapon needs a few more tweaks than that.

	-- If you want to add a custom attachment point to a weapon, do it as follows, the standard WeaponLib/CAP way:
	--[[
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("ak74", {
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		})
	end
	]]
	-- Don't directly check for WeaponLib or CAP's existence. There might be other mods which will supersede WeaponLib/CAP, but still offer the same function.
	-- RotationCAP should probably be fine to use instead of Rotation, if you even need it.
    -- Don't push elements to the attachment_points table, the SetupAttachmentPoint function might do something extra either now or in the future
    
    -- Finally, please use a code editor that can spot and highlight syntax errors for you. Test it out and make sure it catches errors.
    -- Visual Studio Code has a few addons that merely highlight Lua syntax, but there are others that also highlight syntax errors. Get one of those.
end

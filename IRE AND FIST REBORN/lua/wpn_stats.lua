dofile(ModPath .. "infcore.lua")
-- If the config file is corrupt, this function WILL fail, and it will fail very loudly and obviously.
dofile(ModPath .. "lua/assert_config_should_not_crash.lua")
If_This_Appears_In_Your_Crashlog_Delete_Your_InF_Save_Txt()

-- Obtain function for custom weapon support
dofile(ModPath .. "lua/wpn_stats_custom.lua")

Hooks:RegisterHook("inf_weapontweak_initcomplete")

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

function WeaponTweakData:copy_timers(to, from, dont_copy_base_reload_mult)
	if not dont_copy_base_reload_mult == true then
		self[to].reload_speed_mult = self[from].reload_speed_mult
	end

	self[to].not_empty_reload_speed_mult = self[from].not_empty_reload_speed_mult
	self[to].timers.reload_not_empty = self[from].timers.reload_not_empty
	self[to].timers.reload_not_empty_half = self[from].timers.reload_not_empty_half
	self[to].timers.reload_not_empty_end = self[from].timers.reload_not_empty_end

	self[to].empty_reload_speed_mult = self[from].empty_reload_speed_mult
	self[to].timers.reload_empty = self[from].timers.reload_empty
	self[to].timers.reload_empty_half = self[from].timers.reload_empty_half
	self[to].timers.reload_empty_end = self[from].timers.reload_empty_end

	self[to].timers.shotgun_reload_enter = self[from].timers.shotgun_reload_enter
	self[to].timers.shotgun_reload_enter_mult = self[from].timers.shotgun_reload_enter_mult
	self[to].timers.shotgun_reload_first_shell_offset = self[from].timers.shotgun_reload_first_shell_offset
	self[to].timers.shotgun_reload_shell = self[from].timers.shotgun_reload_shell
	self[to].timers.shotgun_reload_exit_not_empty = self[from].timers.shotgun_reload_exit_not_empty
	self[to].timers.shotgun_reload_exit_not_empty_mult = self[from].timers.shotgun_reload_exit_not_empty_mult
	self[to].timers.shotgun_reload_exit_empty = self[from].timers.shotgun_reload_exit_empty
	self[to].timers.shotgun_reload_exit_empty_mult = self[from].timers.shotgun_reload_exit_empty_mult
	self[to].timers.shell_reload_early = self[from].timers.shell_reload_early

	self[to].anim_speed_mult = self[from].anim_speed_mult
	self[to].ads_anim_speed_mult = self[from].ads_anim_speed_mult
	self[to].hipfire_uses_ads_anim = self[from].hipfire_uses_ads_anim

	self[to].timers.equip = self[from].timers.equip
	self[to].timers.unequip = self[from].timers.unequip
	self[to].equip_speed_mult = self[from].equip_speed_mult

	if self[from].equip_stance_mod then
		self[to].equip_stance_mod = deep_clone(self[from].equip_stance_mod)
	end
	if self[from].reload_stance_mod then
		self[to].reload_stance_mod = deep_clone(self[from].reload_stance_mod)
	end
	if self[from].reload_timed_stance_mod then
		self[to].reload_timed_stance_mod = deep_clone(self[from].reload_timed_stance_mod)
	end
end
function WeaponTweakData:copy_timers_to_reload2(to, from)
	self[to].not_empty_reload_speed_mult_2 = self[from].not_empty_reload_speed_mult
	self[to].timers.reload_not_empty_2 = self[from].timers.reload_not_empty
	self[to].timers.reload_not_empty_half_2 = self[from].timers.reload_not_empty_half
	self[to].timers.reload_not_empty_end_2 = self[from].timers.reload_not_empty_end

	self[to].empty_reload_speed_mult_2 = self[from].empty_reload_speed_mult
	self[to].timers.reload_empty_2 = self[from].timers.reload_empty
	self[to].timers.reload_empty_half_2 = self[from].timers.reload_empty_half
	self[to].timers.reload_empty_end_2 = self[from].timers.reload_empty_end
end

function WeaponTweakData:copy_sdescs(to, from, is_akimbo)
	self[to].sdesc1 = self[from].sdesc1
	self[to].sdesc2 = self[from].sdesc2
	self[to].sdesc3 = self[from].sdesc3
	if not is_akimbo then
		self[to].sdesc3_type = self[from].sdesc3_type
	end
end

function WeaponTweakData:copy_stats(to, from, is_akimbo)
	local mult = is_akimbo and 2 or 1
	self[to].chamber = self[from].chamber * mult
	self[to].CLIP_AMMO_MAX = self[from].CLIP_AMMO_MAX * mult
	self[to].fire_mode_data.fire_rate = self[from].fire_mode_data.fire_rate
	self[to].stats.damage = self[from].stats.damage
	self[to].stats.spread = self[from].stats.spread
	self[to].stats.recoil = self[from].stats.recoil
end

function WeaponTweakData:apply_standard_bipod_stats(wpn)
	self[wpn].timers.deploy_bipod = 1.0
	self[wpn].bipod_deploy_multiplier = self[wpn].bipod_deploy_multiplier or 4/3
	self[wpn].bipod_camera_spin_limit = 60
	self[wpn].bipod_camera_pitch_limit = 30
	self[wpn].stances = self[wpn].stances or {}
	self[wpn].stances.bipod = self[wpn].stances.bipod or {shoulders = {}, vel_overshot = {}}
	self[wpn].stances.bipod.FOV = 60
	self[wpn].stances.bipod.vel_overshot.yaw_neg = 0
	self[wpn].stances.bipod.vel_overshot.yaw_pos = 0
	self[wpn].stances.bipod.vel_overshot.pitch_neg = 0
	self[wpn].stances.bipod.vel_overshot.pitch_pos = 0
	self[wpn].stances.bipod.shakers = {breathing = {amplitude = 0}}
end

function WeaponTweakData:_pickup_chance(max_ammo, selection_index)
	local low, high

	low = max_ammo * 0.020
	high = max_ammo * 0.060

	return { low, high }
end

--[[
function WeaponTweakData:has_category(wpnid, category)
	local hascat = false
	for u, v in ipairs (self[wpnid].categories) do
		if v == category then
			hascat = true
		end
	end
	return hascat
end
--]]
function WeaponTweakData:has_category(wpnid, category)
	for u, v in ipairs (self[wpnid].categories) do
		if v == category then
			return true
		end
	end
	return false
end

function WeaponTweakData:has_in_table(values, val)
	for u, v in ipairs (values) do
		if v == val then
			return true
		end
	end
	return false
end


Hooks:PostHook(WeaponTweakData, "_init_new_weapons", "initstatset", function(self, params)
	self:inf_init_all_default()
	self.trip_mines = {
		delay = 0.3,
		damage = 1000,
		player_damage = 6,
		damage_size = 300,
		alert_radius = 5000
	}
end)

-- sets default values per weapon type
function WeaponTweakData:inf_init(wpn, wpntype, subtypearg)
	self:inf_init_stats(wpn)

	-- if no subtype specified, default to "none"
	local subtype = subtypearg or "none"

	if wpntype == "ar" then
		self:inf_init_ar(wpn, subtype)
	elseif wpntype == "pistol" then
		self:inf_init_pistol(wpn, subtype)
	elseif wpntype == "shotgun" then
		self:inf_init_shotgun(wpn, subtype)
	elseif wpntype == "smg" then
		self:inf_init_smg(wpn, subtype)
	elseif wpntype == "lmg" then
		self:inf_init_lmg(wpn, subtype)
	elseif wpntype == "snp" then
		self:inf_init_snp(wpn, subtype)
	elseif wpntype == "grenade_launcher" then
		self:inf_init_gl(wpn, subtype)
	elseif wpntype == "akimbo" then
		self:inf_init_akimbo(wpn, subtype, nil)
	elseif wpntype == "minigun" then
		self:inf_init_minigun(wpn, subtype)
	elseif wpntype == "bow" or wpntype == "crossbow" then
		self:inf_init_bow(wpn, subtype)
	end
end

-- initial universal stats
function WeaponTweakData:inf_init_stats(wpn)
	self[wpn].stats.extra_ammo = 501
	self[wpn].stats.total_ammo_mod = 1001
	if not self[wpn].infstatted == true then
		self[wpn].stats.spread = self[wpn].stats.spread * 4
		self[wpn].stats.recoil = self[wpn].stats.recoil * 5
		--self[wpn].stats.zoom = self[wpn].stats.zoom * 2
		self[wpn].infstatted = true
	end
	self[wpn].stats.reload = 100
	--self[wpn].stats.value = 1
	self[wpn].spread.standing = 0.35 --0.60
	self[wpn].spread.crouching = 0.30 --0.45
	self[wpn].spread.steelsight = 0.20
	self[wpn].spread.moving_standing = 0.35 --0.80
	self[wpn].spread.moving_crouching = 0.30 --0.60
	self[wpn].spread.moving_steelsight = 0.20
	self[wpn].spreadadd = {}
	self[wpn].spreadadd.standing = 1.50
	self[wpn].spreadadd.crouching = 1.00
	self[wpn].spreadadd.steelsight = 0
	self[wpn].spreadadd.moving_standing = 2.25
	self[wpn].spreadadd.moving_crouching = 1.50
	self[wpn].spreadadd.moving_steelsight = 0
	self[wpn].reload_speed_mult = 1
	self[wpn].desc_id_short = self[wpn].desc_id .. "_short"
	if InFmenu and InFmenu.settings.changeitemprices then
		self[wpn].price = 0
	end
	self[wpn].BURST_FIRE = false
	self[wpn].autohit.MIN_RATIO = 0
	self[wpn].autohit.MAX_RATIO = 0
	self[wpn].autohit.INIT_RATIO = 0
	-- If an enemy has body armor damage penalties, multiply the penalty by this number.
	-- Should be 1 for lighter weapons, up to 0 for the heaviest guns
	self[wpn].body_armor_dmg_penalty_mul = 1
	
	-- Fuck off with your new damage falloff Overkill, it's dumb and broken in every way
	if self[wpn].damage_falloff then
		self[wpn].damage_falloff.near_multiplier = 1
		self[wpn].damage_falloff.far_multiplier = 1
	end
end

-- sets base stats for all non-custom weapons
function WeaponTweakData:inf_init_all_default()
	for wpn in pairs(self) do
		if self[wpn].stats then
			self:inf_init_stats(wpn)

			if self:has_category(wpn, "assault_rifle") then
				self:inf_init(wpn, "ar")
			end
			if self:has_category(wpn, "pistol") then
				self:inf_init(wpn, "pistol")
			end
			if self:has_category(wpn, "shotgun") then
				self:inf_init(wpn, "shotgun")
			end
			if self:has_category(wpn, "smg") then
				self:inf_init(wpn, "smg")
			end
			if self:has_category(wpn, "lmg") then
				self:inf_init(wpn, "lmg")
			end
			if self:has_category(wpn, "snp") then
				self:inf_init(wpn, "snp")
			end
			if self:has_category(wpn, "grenade_launcher") then
				self:inf_init(wpn, "grenade_launcher")
			end
			if self:has_category(wpn, "minigun") then
				self:inf_init(wpn, "minigun")
			end
			if self:has_category(wpn, "bow") then
				self:inf_init(wpn, "bow")
			end
			if self:has_category(wpn, "crossbow") then
				self:inf_init(wpn, "crossbow")
			end
		end
	end

	self:inf_init("m16", "ar", {"medium"})
	self:inf_init("asval", "ar", {"medium"})
	self:inf_init("akm", "ar", {"medium"})
	self:inf_init("akm_gold", "ar", {"medium"})

	self:inf_init("scar", "ar", {"heavy"})
	self:inf_init("galil", "ar", {"heavy"})
	self:inf_init("contraband", "ar", {"heavy", "has_gl"})
	self:inf_init("fal", "ar", {"heavy"})
	self:inf_init("g3", "ar", {"heavy"})
	self:inf_init("sub2000", "ar", {"heavy"})

	self:inf_init("tti", "ar", {"ldmr"}) -- contractor
	self:inf_init("new_m14", "ar", {"ldmr"})
	self:inf_init("ching", "ar", {"dmr"}) -- garand
	self:inf_init("siltstone", "ar", {"dmr"}) -- SVD

	self:inf_init("colt_1911", "pistol", "medium")
	self:inf_init("x_1911", "pistol", "medium")
	self:inf_init("usp", "pistol", "medium")
	self:inf_init("x_usp", "pistol", "medium")
	self:inf_init("p226", "pistol", "medium")
	self:inf_init("x_p226", "pistol", "medium")
	self:inf_init("g22c", "pistol", "medium")
	self:inf_init("x_g22c", "pistol", "medium")
	--self:inf_init("g26", "pistol", "medium")
	--self:inf_init("jowi", "pistol", "medium")
	self:inf_init("c96", "pistol", "medium")
	self:inf_init("x_c96", "pistol", "medium")
	self:inf_init("hs2000", "pistol", "medium")
	self:inf_init("x_hs2000", "pistol", "medium")
	self:inf_init("ppk", "pistol", "medium")
	self:inf_init("x_ppk", "pistol", "medium")
	self:inf_init("breech", "pistol", "medium") -- luger
	self:inf_init("x_breech", "pistol", "medium")
	self:inf_init("shrew", "pistol", "medium") -- crosskill guard
	self:inf_init("x_shrew", "pistol", "medium")

	self:inf_init("new_raging_bull", "pistol", "heavy")
	self:inf_init("x_rage", "pistol", "heavy")
	self:inf_init("deagle", "pistol", "heavy")
	self:inf_init("x_deagle", "pistol", "heavy")
	self:inf_init("peacemaker", "pistol", "heavy")
	self:inf_init("mateba", "pistol", "heavy")
	self:inf_init("x_2006m", "pistol", "heavy")
	self:inf_init("chinchilla", "pistol", "heavy") -- castigo
	self:inf_init("x_chinchilla", "pistol", "heavy")

	self:inf_init("mac10", "smg", {"dmg_50"})
	self:inf_init("x_mac10", "smg", {"dmg_50"})
	self:inf_init("polymer", "smg", {"dmg_50"})
	self:inf_init("x_polymer", "smg", {"dmg_50"})

	self:inf_init("new_mp5", "smg", {"range_long"})
	self:inf_init("x_mp5", "smg", {"range_long"})
	self:inf_init("shepheard", "smg", {"range_long"})
	self:inf_init("x_shepheard", "smg", {"range_long"})
	self:inf_init("sterling", "smg", {"range_long"})
	self:inf_init("x_sterling", "smg", {"range_long"})
	self:inf_init("coal", "smg", {"range_long"})
	self:inf_init("x_coal", "smg", {"range_long"})
	self:inf_init("erma", "smg", {"range_long"})
	self:inf_init("x_erma", "smg", {"range_long"})
	self:inf_init("m45", "smg", {"range_long"})
	self:inf_init("x_m45", "smg", {"range_long"})
	self:inf_init("m1928", "smg", {"range_long", "dmg_50"})
	self:inf_init("x_m1928", "smg", {"range_long", "dmg_50"})
	self:inf_init("schakal", "smg", {"range_long", "dmg_50"})
	self:inf_init("x_schakal", "smg", {"range_long", "dmg_50"})

	self:inf_init("olympic", "smg", {"range_carbine"})
	self:inf_init("x_olympic", "smg", {"range_carbine"})
	self:inf_init("akmsu", "smg", {"range_carbine"})
	self:inf_init("x_akmsu", "smg", {"range_carbine"})
	self:inf_init("hajk", "smg", {"range_carbine"})
	self:inf_init("x_hajk", "smg", {"range_carbine"})

	self:inf_init("b682", "shotgun", {"dmg_heavy", "range_long", "rof_db"})
	self:inf_init("huntsman", "shotgun", {"dmg_heavy", "range_long", "rof_db"})
	self:inf_init("coach", "shotgun", {"dmg_heavy", "rof_db"})

	self:inf_init("r870", "shotgun", {"rof_slow", "range_slowpump"})

	self:inf_init("ksg", "shotgun", {"dmg_mid"})
	self:inf_init("benelli", "shotgun", {"dmg_light", "rof_semi"})
	self:inf_init("spas12", "shotgun", {"dmg_light", "rof_semi"})
	self:inf_init("saiga", "shotgun", {"dmg_vlight", "rof_mag"})
	self:inf_init("aa12", "shotgun", {"dmg_aa12", "rof_mag"})

	self:inf_init("serbu", "shotgun", {"range_short"})
	self:inf_init("m37", "shotgun", {"rof_slow", "range_slowpump"})
	self:inf_init("striker", "shotgun", {"range_short", "dmg_light", "rof_mag"})
	self:inf_init("rota", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
	self:inf_init("x_rota", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
	self:inf_init("basset", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
	self:inf_init("x_basset", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
	self:inf_init("judge", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})
	self:inf_init("x_judge", "shotgun", {"range_short", "dmg_vlight", "rof_mag"})

	self:inf_init("rpk", "lmg", "medium")
	self:inf_init("hk21", "lmg", "heavy")
	self:inf_init("mg42", "lmg", "heavy")
	self:inf_init("par", "lmg", "heavy")
	self:inf_init("m60", "lmg", "heavy")
	--self:inf_init("tecci", "lmg")

	self:inf_init("r93", "snp", "heavy")
	self:inf_init("mosin", "snp", "heavy")
	self:inf_init("desertfox", "snp", "heavy")
	self:inf_init("r700", "snp", "heavy")

	self:inf_init("m95", "snp", "superheavy")
end

-- used for shotgun subtypes and checking for existing akimbo recategorize
local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function WeaponTweakData:convert_reload_to_mult(mag)
	local test = 1 + (InFmenu.wpnvalues.reload[mag].reload/100) or 0
	return test
end

function WeaponTweakData:inf_init_ar(wpn, subtype)
	if InFmenu.settings.allpenwalls == true then
		self[wpn].can_shoot_through_wall = true
	end
	self[wpn].recategorize = nil
	self[wpn].pen_wall_dist_mult = 0.50
	self[wpn].chamber = 1
	self[wpn].recoil_table = InFmenu.rtable.lrifle
	self[wpn].recoil_loop_point = InFmenu.wpnvalues.lrifle.recoil_loop_point
	self[wpn].stats.damage = InFmenu.wpnvalues.lrifle.damage
	self[wpn].stats.spread = InFmenu.wpnvalues.lrifle.spread
	self[wpn].stats.recoil = InFmenu.wpnvalues.lrifle.recoil
	self[wpn].kick = InFmenu.rstance.lrifle
	self[wpn].AMMO_MAX = InFmenu.wpnvalues.lrifle.ammo
	self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.lrifle.ammo, 1)
	self[wpn].armor_piercing_chance = InFmenu.wpnvalues.lrifle.armor_piercing_chance -- 40dmg
	self[wpn].shake.fire_multiplier = 0.50
	self[wpn].shake.fire_steelsight_multiplier = 0.15
	self[wpn].body_armor_dmg_penalty_mul = 1
	if type(subtype) == "table" then
		if self:has_in_table(subtype, "has_gl") then
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.lrifle_gl.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.lrifle_gl.ammo, 1)
		end
		if self:has_in_table(subtype, "medium") then
			self[wpn].pen_wall_dist_mult = 0.50
			self[wpn].recoil_table = InFmenu.rtable.mrifle
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.mrifle.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.mrifle.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.mrifle.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.mrifle.recoil
			self[wpn].kick = InFmenu.rstance.mrifle
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.mrifle.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.mrifle.ammo, 1)
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.mrifle.armor_piercing_chance -- 50dmg
			self[wpn].recategorize = "rifle_m"
			self[wpn].shake.fire_multiplier = 1.00
			self[wpn].shake.fire_steelsight_multiplier = 0.20
			self[wpn].body_armor_dmg_penalty_mul = 0.95
			if self:has_in_table(subtype, "has_gl") then
				self[wpn].AMMO_MAX = InFmenu.wpnvalues.mrifle_gl.ammo
				self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.mrifle_gl.ammo, 1)
			end
		end
		if self:has_in_table(subtype, "heavy") then
			self[wpn].pen_wall_dist_mult = 0.66
			self[wpn].recoil_table = InFmenu.rtable.hrifle
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.hrifle.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.hrifle.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.hrifle.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.hrifle.recoil
			self[wpn].kick = InFmenu.rstance.hrifle
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.hrifle.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.hrifle.ammo, 1)
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.hrifle.armor_piercing_chance -- 60dmg
			self[wpn].recategorize = "rifle_h"
			self[wpn].shake.fire_multiplier = 1.00
			self[wpn].shake.fire_steelsight_multiplier = 0.20
			self[wpn].body_armor_dmg_penalty_mul = 0.8
			if self:has_in_table(subtype, "has_gl") then
				self[wpn].AMMO_MAX = InFmenu.wpnvalues.hrifle_gl.ammo
				self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.hrifle_gl.ammo, 1)
			end
		end
		if self:has_in_table(subtype, "ldmr") then
			self[wpn].pen_wall_dist_mult = 0.75
			self[wpn].categories = {"assault_rifle"}
			self[wpn].recategorize = "dmr"
			self[wpn].recoil_table = InFmenu.rtable.ldmr
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.ldmr.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.ldmr.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.ldmr.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.ldmr.recoil
			self[wpn].stats.zoom = 3
			self[wpn].kick = InFmenu.rstance.ldmr
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.ldmr.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.ldmr.ammo, 1)
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.ldmr.armor_piercing_chance
			self[wpn].can_shoot_through_enemy = false
			self[wpn].can_shoot_through_shield = true
			self[wpn].can_shoot_through_wall = true
			self[wpn].taser_hole = true
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 0.20
			self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.ldmr.rof}
			self[wpn].body_armor_dmg_penalty_mul = 0.7
			if not self[wpn].stats_modifiers then
				self[wpn].stats_modifiers = {}
			end
			self[wpn].stats_modifiers.damage = 1
		end
		if self:has_in_table(subtype, "dmr") then
			self[wpn].pen_wall_dist_mult = 0.75
			self[wpn].categories = {"assault_rifle"}
			self[wpn].recategorize = "dmr"
			self[wpn].recoil_table = InFmenu.rtable.dmr
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.dmr.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.dmr.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.dmr.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.dmr.recoil
			self[wpn].stats.zoom = 3
			self[wpn].kick = InFmenu.rstance.dmr
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.dmr.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.dmr.ammo, 1)
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.dmr.armor_piercing_chance
			self[wpn].can_shoot_through_enemy = false
			self[wpn].can_shoot_through_shield = true
			self[wpn].can_shoot_through_wall = true
			self[wpn].taser_hole = true
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 0.20
			self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.dmr.rof}
			self[wpn].body_armor_dmg_penalty_mul = 0.5
			if not self[wpn].stats_modifiers then
				self[wpn].stats_modifiers = {}
			end
			self[wpn].stats_modifiers.damage = 1
		end
		if self:has_in_table(subtype, "hdmr") then
			self[wpn].pen_wall_dist_mult = 0.75
			self[wpn].categories = {"assault_rifle"}
			self[wpn].recategorize = "dmr"
			self[wpn].recoil_table = InFmenu.rtable.hdmr
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.hdmr.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.hdmr.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.hdmr.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.hdmr.recoil
			self[wpn].stats.zoom = 3
			self[wpn].kick = InFmenu.rstance.hdmr
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.hdmr.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.hdmr.ammo, 1)
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.hdmr.armor_piercing_chance
			self[wpn].can_shoot_through_enemy = false
			self[wpn].can_shoot_through_shield = true
			self[wpn].can_shoot_through_wall = true
			self[wpn].taser_hole = true
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 0.20
			self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.hdmr.rof}
			self[wpn].body_armor_dmg_penalty_mul = 0.2
			if not self[wpn].stats_modifiers then
				self[wpn].stats_modifiers = {}
			end
			self[wpn].stats_modifiers.damage = 1
		end
	end

--[[
	if subtype == "medium" then
		self[wpn].pen_wall_dist_mult = 0.50
		self[wpn].recoil_table = InFmenu.rtable.mrifle
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.mrifle.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.mrifle.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.mrifle.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.mrifle.recoil
		self[wpn].kick = InFmenu.rstance.mrifle
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.mrifle.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.mrifle.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.mrifle.armor_piercing_chance -- 50dmg
		self[wpn].recategorize = "rifle_m"
		self[wpn].shake.fire_multiplier = 1.00
		self[wpn].shake.fire_steelsight_multiplier = 0.20
	elseif subtype == "heavy" then
		self[wpn].pen_wall_dist_mult = 0.66
		self[wpn].recoil_table = InFmenu.rtable.hrifle
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.hrifle.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.hrifle.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.hrifle.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.hrifle.recoil
		self[wpn].kick = InFmenu.rstance.hrifle
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.hrifle.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.hrifle.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.hrifle.armor_piercing_chance -- 60dmg
		self[wpn].recategorize = "rifle_h"
		self[wpn].shake.fire_multiplier = 1.00
		self[wpn].shake.fire_steelsight_multiplier = 0.20
	elseif subtype == "ldmr" then
		self[wpn].pen_wall_dist_mult = 0.75
		self[wpn].categories = {"assault_rifle"}
		self[wpn].recategorize = "dmr"
		self[wpn].recoil_table = InFmenu.rtable.ldmr
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.ldmr.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.ldmr.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.ldmr.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.ldmr.recoil
		self[wpn].stats.zoom = 3
		self[wpn].kick = InFmenu.rstance.ldmr
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.ldmr.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.ldmr.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.ldmr.armor_piercing_chance
		self[wpn].can_shoot_through_enemy = false
		self[wpn].can_shoot_through_shield = true
		self[wpn].can_shoot_through_wall = true
		self[wpn].taser_hole = true
		self[wpn].shake.fire_multiplier = 1.25
		self[wpn].shake.fire_steelsight_multiplier = 0.20
		self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.ldmr.rof}
		if not self[wpn].stats_modifiers then
			self[wpn].stats_modifiers = {}
		end
		self[wpn].stats_modifiers.damage = 1
	elseif subtype == "dmr" then
		self[wpn].pen_wall_dist_mult = 0.75
		self[wpn].categories = {"assault_rifle"}
		self[wpn].recategorize = "dmr"
		self[wpn].recoil_table = InFmenu.rtable.dmr
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.dmr.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.dmr.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.dmr.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.dmr.recoil
		self[wpn].stats.zoom = 3
		self[wpn].kick = InFmenu.rstance.dmr
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.dmr.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.dmr.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.dmr.armor_piercing_chance
		self[wpn].can_shoot_through_enemy = false
		self[wpn].can_shoot_through_shield = true
		self[wpn].can_shoot_through_wall = true
		self[wpn].taser_hole = true
		self[wpn].shake.fire_multiplier = 1.25
		self[wpn].shake.fire_steelsight_multiplier = 0.20
		self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.dmr.rof}
		if not self[wpn].stats_modifiers then
			self[wpn].stats_modifiers = {}
		end
		self[wpn].stats_modifiers.damage = 1
	end
--]]
end

function WeaponTweakData:inf_init_pistol(wpn, subtype)
	self[wpn].ads_movespeed_mult = 2
	if InFmenu.settings.allpenwalls == true then
		self[wpn].can_shoot_through_wall = true
	end
	self[wpn].recategorize = nil
	self[wpn].pen_wall_dist_mult = 0.25
	self[wpn].chamber = 1
	self[wpn].recoil_table = InFmenu.rtable.lightpis
	self[wpn].recoil_loop_point = InFmenu.wpnvalues.lightpis.recoil_loop_point
	self[wpn].stats.damage = InFmenu.wpnvalues.lightpis.damage
	self[wpn].stats.spread = InFmenu.wpnvalues.lightpis.spread
	self[wpn].stats.recoil = InFmenu.wpnvalues.lightpis.recoil
	self[wpn].kick = InFmenu.rstance.lightpis
	self[wpn].AMMO_MAX = InFmenu.wpnvalues.lightpis.ammo
	self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.lightpis.ammo, 1)
	self[wpn].armor_piercing_chance = InFmenu.wpnvalues.lightpis.armor_piercing_chance -- 35dmg
	self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.lightpis.rof}
	self[wpn].reload_speed_mult = 1.20
	self[wpn].shake.fire_multiplier = 0.50
	self[wpn].shake.fire_steelsight_multiplier = 0.20
	self[wpn].body_armor_dmg_penalty_mul = 1
	if subtype == "medium" then
		self[wpn].pen_wall_dist_mult = 0.25
		self[wpn].recoil_table = InFmenu.rtable.mediumpis
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.mediumpis.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.mediumpis.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.mediumpis.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.mediumpis.recoil
		self[wpn].kick = InFmenu.rstance.mediumpis
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.mediumpis.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.mediumpis.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.mediumpis.armor_piercing_chance -- 60dmg
		self[wpn].recategorize = "pistol_m"
		self[wpn].shake.fire_multiplier = 1.00
		self[wpn].shake.fire_steelsight_multiplier = 0.50
		self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.mediumpis.rof}
		self[wpn].body_armor_dmg_penalty_mul = 0.85
	elseif subtype == "supermedium" then
		self[wpn].pen_wall_dist_mult = 0.33
		self[wpn].recoil_table = InFmenu.rtable.supermediumpis
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.supermediumpis.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.supermediumpis.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.supermediumpis.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.supermediumpis.recoil
		self[wpn].kick = InFmenu.rstance.supermediumpis
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.supermediumpis.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.supermediumpis.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.supermediumpis.armor_piercing_chance -- 60dmg
		self[wpn].recategorize = "pistol_m"
		self[wpn].shake.fire_multiplier = 1.00
		self[wpn].shake.fire_steelsight_multiplier = 0.50
		self[wpn].fire_mode_data = {fire_rate = 60/InFmenu.wpnvalues.supermediumpis.rof}
		self[wpn].body_armor_dmg_penalty_mul = 0.75
	elseif subtype == "heavy" then
		self[wpn].pen_wall_dist_mult = 0.50
		self[wpn].recoil_table = InFmenu.rtable.heavypis
		self[wpn].recoil_loop_point = InFmenu.wpnvalues.heavypis.recoil_loop_point
		self[wpn].stats.damage = InFmenu.wpnvalues.heavypis.damage
		self[wpn].stats.spread = InFmenu.wpnvalues.heavypis.spread
		self[wpn].stats.recoil = InFmenu.wpnvalues.heavypis.recoil
		self[wpn].kick = InFmenu.rstance.heavypis
		self[wpn].AMMO_MAX = InFmenu.wpnvalues.heavypis.ammo
		self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.heavypis.ammo, 1)
		self[wpn].armor_piercing_chance = InFmenu.wpnvalues.heavypis.armor_piercing_chance
		self[wpn].taser_hole = true
		self[wpn].fire_mode_data.fire_rate = 60/InFmenu.wpnvalues.heavypis.rof
		self[wpn].recategorize = "pistol_h"
		self[wpn].shake.fire_multiplier = 1.50
		self[wpn].shake.fire_steelsight_multiplier = 1.00
		--self[wpn].falloff_min_dmg = 13.0
		self[wpn].body_armor_dmg_penalty_mul = 0.5
	elseif not self:has_category(wpn, "akimbo") then
		-- non-akimbo lights get faster reload
		self[wpn].reload_speed_mult = 1.40
	end
	if self:has_category(wpn, "akimbo") then
		self:inf_init_akimbo(wpn, "pistol", 0)
	else
		-- non-akimbos get quickdraw
		--self[wpn].sdesc3 = "misc_quickdraw"
		self[wpn].sdesc3_type = "quickdraw"
	end
end

-- SHOTGUNS
function WeaponTweakData:inf_init_shotgun(wpn, subtype)
	self[wpn].chamber = 1
	self[wpn].spread.standing = 0.50
	self[wpn].spread.crouching = self[wpn].spread.standing
	self[wpn].spread.steelsight = self[wpn].spread.standing
	self[wpn].spread.moving_standing = self[wpn].spread.standing
	self[wpn].spread.moving_crouching = self[wpn].spread.standing
	self[wpn].spread.moving_steelsight = self[wpn].spread.standing
	self[wpn].spreadadd.standing = 0
	self[wpn].spreadadd.crouching = 0
	self[wpn].spreadadd.steelsight = 0
	self[wpn].spreadadd.moving_standing = 0
	self[wpn].spreadadd.moving_crouching = 0
	self[wpn].spreadadd.moving_steelsight = 0
	self[wpn].recoil_table = InFmenu.rtable.shotgun
	self[wpn].stats.damage = 48 -- 240 --44 -- 220
	self[wpn].stats.spread = 51
	self[wpn].stats.recoil = 31
	self[wpn].kick = InFmenu.rstance.shotgun
	self[wpn].AMMO_MAX = 42
	self[wpn].AMMO_PICKUP = self:_pickup_chance(42, 1)
	self[wpn].armor_piercing_chance = 0.50
	self[wpn].body_armor_dmg_penalty_mul = 0.75
	if not self[wpn].stats_modifiers then
		self[wpn].stats_modifiers = {}
	end
	self[wpn].stats_modifiers.damage = 5
	self[wpn].reload_speed_mult = 1.40 -- 1.15
	self[wpn].fire_mode_data = {fire_rate = 60/120}
	self[wpn].single = {fire_rate = 60/120}
	self[wpn].shake.fire_multiplier = 1.50
	self[wpn].shake.fire_steelsight_multiplier = 1.50
	self[wpn].rays = 10
	--self[wpn].sdesc3 = "range_shot"
	self[wpn].sdesc3_type = "range"
	self[wpn].fulldesc_show_range = true

	self[wpn].damage_near = 1000
	self[wpn].damage_far = 2000
	if type(subtype) == "table" then
		if self:has_in_table(subtype, "range_long") then
			self[wpn].damage_near = 1500
			self[wpn].damage_far = 3000
			--self[wpn].sdesc3 = "range_shotlong"
		end
		if self:has_in_table(subtype, "range_slowpump") then
			self[wpn].damage_near = 1000
			self[wpn].damage_far = 3000
		end
		if self:has_in_table(subtype, "range_short") then
			self[wpn].damage_near = 1000
			self[wpn].damage_far = 1500
			--self[wpn].sdesc3 = "range_shotshort"
		end
		if self:has_in_table(subtype, "range_verylong") then
			self[wpn].damage_near = 2000
			self[wpn].damage_far = 4500
		end

		if self:has_in_table(subtype, "dmg_mid") then
			self[wpn].stats.damage = 43 -- 215 --38 -- 190
			self[wpn].stats.recoil = 41
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 1.25
			self[wpn].body_armor_dmg_penalty_mul = 0.7
		end
		if self:has_in_table(subtype, "dmg_light") then
			self[wpn].stats.damage = 38 -- 190
			self[wpn].stats.recoil = 56
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 1.25
			self[wpn].body_armor_dmg_penalty_mul = 0.8
		end
		if self:has_in_table(subtype, "dmg_vlight") then
			self[wpn].stats.damage = 36 -- 180
			self[wpn].stats.recoil = 51
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.00
			self[wpn].shake.fire_steelsight_multiplier = 1.00
			self[wpn].body_armor_dmg_penalty_mul = 0.85
		end
		if self:has_in_table(subtype, "dmg_aa12") then
			self[wpn].stats.damage = 26 -- 130
			self[wpn].stats.recoil = 61
			self[wpn].AMMO_MAX = 60
			self[wpn].AMMO_PICKUP = self:_pickup_chance(60, 1)
			self[wpn].shake.fire_multiplier = 0.80
			self[wpn].shake.fire_steelsight_multiplier = 0.80
		end
		if self:has_in_table(subtype, "dmg_heavy") then
			self[wpn].stats.damage = 65 -- 325
			self[wpn].stats.recoil = 21
			self[wpn].AMMO_MAX = 24
			self[wpn].AMMO_PICKUP = self:_pickup_chance(24, 1)
			self[wpn].shake.fire_multiplier = 2.00
			self[wpn].shake.fire_steelsight_multiplier = 2.00
			self[wpn].body_armor_dmg_penalty_mul = 0.65
		end

		if self:has_in_table(subtype, "rof_semi") then
			self[wpn].fire_mode_data = {fire_rate = 60/360}
			self[wpn].single = {fire_rate = 60/360}
		end
		if self:has_in_table(subtype, "rof_mag") then
			self[wpn].fire_mode_data = {fire_rate = 60/360}
			self[wpn].single = {fire_rate = 60/360}
			self[wpn].reload_speed_mult = self[wpn].reload_speed_mult / 1.15
		end
		if self:has_in_table(subtype, "rof_db") then
			self[wpn].chamber = 0
			self[wpn].fire_mode_data = {fire_rate = 60/360}
			self[wpn].single = {fire_rate = 60/360}
			self[wpn].BURST_FIRE = 2
			self[wpn].ADAPTIVE_BURST_SIZE = false
			self[wpn].BURST_FIRE_RATE_MULTIPLIER = 5
			self[wpn].DELAYED_BURST_RECOIL = true
		end
		if self:has_in_table(subtype, "rof_slow") then
			self[wpn].fire_mode_data = {fire_rate = 60/90}
			self[wpn].single = {fire_rate = 60/90}
		end
		if self:has_in_table(subtype, "rof_veryslow") then
			self[wpn].fire_mode_data = {fire_rate = 60/45}
			self[wpn].single = {fire_rate = 60/45}
		end
		if self:has_in_table(subtype, "is_underbarrel") then
			self[wpn].AMMO_MAX = 8
			self[wpn].AMMO_PICKUP = self:_pickup_chance(16, 1)
		end
	end
	if self:has_category(wpn, "akimbo") then
		self:inf_init_akimbo(wpn, "shotgun", 0)
	end
end

function WeaponTweakData:inf_init_smg(wpn, subtype)
	if InFmenu.settings.allpenwalls == true then
		self[wpn].can_shoot_through_wall = true
	end
	self[wpn].recategorize = nil
	self[wpn].pen_wall_dist_mult = 0.25
	self[wpn].chamber = 1
	self[wpn].recoil_table = InFmenu.rtable.shortsmg
	self[wpn].recoil_loop_point = InFmenu.wpnvalues.shortsmg.recoil_loop_point
	self[wpn].stats.damage = InFmenu.wpnvalues.shortsmg.damage
	self[wpn].stats.spread = InFmenu.wpnvalues.shortsmg.spread
	self[wpn].stats.recoil = InFmenu.wpnvalues.shortsmg.recoil
	self[wpn].kick = InFmenu.rstance.shortsmg
	self[wpn].AMMO_MAX = InFmenu.wpnvalues.shortsmg.ammo
	self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.shortsmg.ammo, 1)
	self[wpn].armor_piercing_chance = InFmenu.wpnvalues.shortsmg.armor_piercing_chance -- 27-30dmg
	self[wpn].shake.fire_multiplier = 0.30
	self[wpn].shake.fire_steelsight_multiplier = 0.10
	self[wpn].body_armor_dmg_penalty_mul = 1

	if type(subtype) == "table" then
		-- don't use carbine with other modifiers
		if self:has_in_table(subtype, "range_carbine") then
			self[wpn].pen_wall_dist_mult = 0.50
			if self:has_category(wpn, "akimbo") then
				self[wpn].categories = {"akimbo", "assault_rifle"}
			else
				self[wpn].categories = {"assault_rifle"}
			end
			self[wpn].recoil_table = InFmenu.rtable.carbine
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.carbine.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.carbine.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.carbine.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.carbine.recoil
			self[wpn].kick = InFmenu.rstance.carbine
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.carbine.armor_piercing_chance -- 40dmg
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.carbine.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.carbine.ammo, 1)
			self[wpn].recategorize = "carbine"
			self[wpn].shake.fire_multiplier = 0.50
			self[wpn].shake.fire_steelsight_multiplier = 0.15
			self[wpn].body_armor_dmg_penalty_mul = 0.95
		end
		if self:has_in_table(subtype, "range_mcarbine") then
			self[wpn].pen_wall_dist_mult = 0.50
			if self:has_category(wpn, "akimbo") then
				self[wpn].categories = {"akimbo", "assault_rifle"}
			else
				self[wpn].categories = {"assault_rifle"}
			end
			self[wpn].recoil_table = InFmenu.rtable.mcarbine
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.mcarbine.recoil_loop_point
			self[wpn].stats.damage = InFmenu.wpnvalues.mcarbine.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.mcarbine.spread
			self[wpn].stats.recoil = InFmenu.wpnvalues.mcarbine.recoil
			self[wpn].kick = InFmenu.rstance.mcarbine
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.mcarbine.armor_piercing_chance -- 
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.mcarbine.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.mcarbine.ammo, 1)
			self[wpn].recategorize = "carbine"
			self[wpn].shake.fire_multiplier = 0.50
			self[wpn].shake.fire_steelsight_multiplier = 0.15
			self[wpn].body_armor_dmg_penalty_mul = 0.9
		end

		if self:has_in_table(subtype, "range_long") then
			self[wpn].recoil_table = InFmenu.rtable.longsmg
			self[wpn].recoil_loop_point = InFmenu.wpnvalues.longsmg.recoil_loop_point
			--self[wpn].stats.damage = InFmenu.wpnvalues.longsmg.damage
			self[wpn].stats.spread = InFmenu.wpnvalues.longsmg.spread
			--self[wpn].stats.recoil = InFmenu.wpnvalues.longsmg.recoil
			self[wpn].kick = InFmenu.rstance.longsmg
			self[wpn].AMMO_MAX = InFmenu.wpnvalues.longsmg.ammo
			self[wpn].AMMO_PICKUP = self:_pickup_chance(InFmenu.wpnvalues.longsmg.ammo, 1)
			self[wpn].recategorize = "smg_h"
			self[wpn].armor_piercing_chance = InFmenu.wpnvalues.longsmg.armor_piercing_chance -- 27-30dmg
			self[wpn].shake.fire_multiplier = 0.50
			self[wpn].shake.fire_steelsight_multiplier = 0.15
		end
		if self:has_in_table(subtype, "dmg_50") then
			self[wpn].stats.damage = InFmenu.wpnvalues.longsmg.damage
			self[wpn].stats.recoil = InFmenu.wpnvalues.longsmg.recoil
		end

	end

	if self:has_category(wpn, "akimbo") then
		self:inf_init_akimbo(wpn, "smg", 0)
	end
end

-- MACHINE GUNS
function WeaponTweakData:inf_init_lmg(wpn, subtype)
	if InFmenu.settings.allpenwalls == true then
		self[wpn].can_shoot_through_wall = true
	end
	self[wpn].pen_wall_dist_mult = 0.50

	self[wpn].taser_reload_amount = math.max(50, math.ceil(self[wpn].CLIP_AMMO_MAX/2))
	--self[wpn].spread.standing = 0.35
	--self[wpn].spread.crouching = 0.30
	--self[wpn].spread.steelsight = 0.20
	self[wpn].spread.moving_standing = self[wpn].spread.standing
	self[wpn].spread.moving_crouching = self[wpn].spread.crouching
	self[wpn].spread.moving_steelsight = self[wpn].spread.steelsight
	self[wpn].spread.bipod = self[wpn].spread.steelsight -- doesn't even do anything
	self[wpn].spreadadd.moving_standing = self[wpn].spreadadd.standing
	self[wpn].spreadadd.moving_crouching = self[wpn].spreadadd.crouching
	self[wpn].spreadadd.moving_steelsight = self[wpn].spreadadd.steelsight
	self[wpn].recoil_table = InFmenu.rtable.lmg
	self[wpn].recoil_loop_point = 12
	self[wpn].stats.damage = 50
	self[wpn].stats.spread = 46
	self[wpn].stats.recoil = 61
	self[wpn].kick = InFmenu.rstance.lmg
	self[wpn].AMMO_MAX = 300
	self[wpn].AMMO_PICKUP = self:_pickup_chance(250, 1)
	self[wpn].armor_piercing_chance = 0.60
	self[wpn].timers.deploy_bipod = 1.0
	self[wpn].bipod_deploy_multiplier = 4/3
	self[wpn].bipod_camera_spin_limit = 60
	self[wpn].bipod_camera_pitch_limit = 30 -- 24
	self[wpn].shake.fire_multiplier = 0.50
	self[wpn].shake.fire_steelsight_multiplier = 0.20
	self[wpn].allow_ads_while_reloading = false
	self[wpn].body_armor_dmg_penalty_mul = 1
	if subtype == "medium" then
		self[wpn].pen_wall_dist_mult = 0.50
		self[wpn].stats.damage = 65
		self[wpn].stats.recoil = 56
		self[wpn].armor_piercing_chance = 0.80
		self[wpn].AMMO_MAX = 300
		self[wpn].AMMO_PICKUP = self:_pickup_chance(250, 1)
		self[wpn].body_armor_dmg_penalty_mul = 0.95
	elseif subtype == "heavy" then
		self[wpn].pen_wall_dist_mult = 0.66
		self[wpn].stats.damage = 75
		self[wpn].stats.recoil = 46
		self[wpn].armor_piercing_chance = 0.80
		self[wpn].AMMO_MAX = 200
		self[wpn].AMMO_PICKUP = self:_pickup_chance(167, 1)
		self[wpn].body_armor_dmg_penalty_mul = 0.75
	end
end

-- SNIPER RIFLES
function WeaponTweakData:inf_init_snp(wpn, subtype)
	self[wpn].chamber = 1
	self[wpn].pen_wall_dist_mult = 1
	self[wpn].recoil_table = InFmenu.rtable.snp
	self[wpn].stats.damage = 68 -- 340
	self[wpn].stats.spread = 96
	self[wpn].stats.recoil = 31
	self[wpn].kick = InFmenu.rstance.snp
	self[wpn].AMMO_MAX = 40
	self[wpn].AMMO_PICKUP = self:_pickup_chance(40, 1)
	self[wpn].armor_piercing_chance = 1
	self[wpn].taser_hole = true
	self[wpn].can_shoot_through_shield = true
	self[wpn].can_shoot_through_wall = true
	self[wpn].zoom = 3
	self[wpn].fire_mode_data.fire_rate = 60/80
	self[wpn].single.fire_rate = 60/80
	self[wpn].shake.fire_multiplier = 1.25
	self[wpn].shake.fire_steelsight_multiplier = 1.00
	self[wpn].body_armor_dmg_penalty_mul = 0.25
	if not self[wpn].stats_modifiers then
		self[wpn].stats_modifiers = {}
	end
	self[wpn].stats_modifiers.damage = 5
	if subtype == "heavy" then
		self[wpn].pen_wall_dist_mult = 1.25
		self[wpn].stats.damage = 80 -- 400
		self[wpn].stats.spread = 101
		self[wpn].stats.recoil = 21
		self[wpn].AMMO_MAX = 30
		self[wpn].AMMO_PICKUP = self:_pickup_chance(30, 1)
		self[wpn].fire_mode_data.fire_rate = 60/60
		self[wpn].single.fire_rate = 60/60
		self[wpn].body_armor_dmg_penalty_mul = 0
	end
	if subtype == "superheavy" then
		self[wpn].pen_wall_dist_mult = 4
		self[wpn].stats.damage = 70 -- 3500
		self[wpn].stats.spread = 101
		self[wpn].stats.recoil = 11
		self[wpn].AMMO_MAX = 10
		self[wpn].AMMO_PICKUP = {1338, 50}
		self[wpn].fire_mode_data.fire_rate = 60/60
		self[wpn].single.fire_rate = 60/60
		self[wpn].stats_modifiers.damage = 50
		self[wpn].body_armor_dmg_penalty_mul = 0
	end
end

-- GRENADE LAUNCHERS
function WeaponTweakData:inf_init_gl(wpn, subtype)
	self[wpn].recoil_table = InFmenu.rtable.shotgun
	self[wpn].kick = InFmenu.rstance.shotgun
	self[wpn].spread.steelsight = 0.20
	self[wpn].spread.moving_steelsight = 0.20
	self[wpn].body_armor_dmg_penalty_mul = 1
end

-- AKIMBO
function WeaponTweakData:inf_init_akimbo(wpn, subtype, delaytime)
	self[wpn].chamber = 2
	self[wpn].zoom = 3
	--self[wpn].recoil_table = InFmenu.rtable.akimbo
	--self[wpn].recoil_loop_point = 7
	self[wpn].empty_reload_threshold = 1
	if self[wpn].recategorize and not starts_with(self[wpn].recategorize, "x") then
		self[wpn].recategorize = "x_" .. self[wpn].recategorize
	end
	if subtype == "shotgun" then
		-- do nothing
	else
		self[wpn].spread.standing = 0.55
		self[wpn].spread.crouching = 0.50
		self[wpn].spread.steelsight = 0.30
		self[wpn].spread.moving_standing = 0.55
		self[wpn].spread.moving_crouching = 0.50
		self[wpn].spread.moving_steelsight = 0.30
		self[wpn].spreadadd.standing = 1.00
		self[wpn].spreadadd.crouching = 0.75
		self[wpn].spreadadd.steelsight = 0.50
		self[wpn].spreadadd.moving_standing = 1.50
		self[wpn].spreadadd.moving_crouching = 1.00
		self[wpn].spreadadd.moving_steelsight = 0.75
	end
	-- allows single-firing akimbos to toggle vanilla double-shoot
	--[[
	if not self:has_category(wpn, "smg") then
		self[wpn].BURST_FIRE = 2
	end
	]]

	if delaytime then
		self[wpn].recoil_apply_delay = delaytime or 0 --0.07
	end

	--self[wpn]
end

-- MISTAKES
function WeaponTweakData:inf_init_minigun(wpn, subtype)
	if InFmenu.settings.allpenwalls == true then
		self[wpn].can_shoot_through_wall = true
	end
	self[wpn].taser_reload_amount = math.max(50, math.ceil(self[wpn].CLIP_AMMO_MAX/2))
	self[wpn].pen_wall_dist_mult = 0.50
	self[wpn].spread.standing = 0.40
	self[wpn].spread.crouching = 0.35
	self[wpn].spread.steelsight = 0.30
	self[wpn].spread.moving_standing = 0.40
	self[wpn].spread.moving_crouching = 0.35
	self[wpn].spread.moving_steelsight = 0.30
	self[wpn].chamber = 0
	self[wpn].recoil_table = InFmenu.rtable.minigun
	self[wpn].recoil_loop_point = 56
	self[wpn].kick = InFmenu.rstance.minigun
	self[wpn].stats.damage = 40
	self[wpn].stats.spread = 41
	self[wpn].stats.recoil = 31
	self[wpn].stats.suppression = 0
	self[wpn].armor_piercing_chance = 0.50
	self[wpn].upgrade_blocks = { weapon = { "clip_ammo_increase" } }
	self[wpn].sdesc3_type = "spinup"
	self[wpn].spin_up_time = 0.50
	self[wpn].spin_down_speed_mult = self[wpn].spin_up_time/0.35 -- (+0.15)
	self[wpn].body_armor_dmg_penalty_mul = 1
end

-- lmao
function WeaponTweakData:inf_init_bow(wpn, subtype)
	self[wpn].spread.standing = 0
	self[wpn].spread.crouching = 0
	self[wpn].spread.steelsight = 0
	self[wpn].spread.moving_standing = 0
	self[wpn].spread.moving_crouching = 0
	self[wpn].spread.moving_steelsight = 0
	self[wpn].chamber = 0
	self[wpn].recoil_table = InFmenu.rtable.lrifle
	self[wpn].kick = InFmenu.rstance.norecoil
	self[wpn].not_allowed_in_bleedout = false
	self[wpn].armor_piercing_chance = 1
	self[wpn].body_armor_dmg_penalty_mul = 0.5
end

-- For some ungodly reason, turning this function override into a proper PostHook crashes the game.
-- With this old_init method, BeardLib adds the InF custom weapons *before* this function runs, ensuring that the primary SMG's get the right stats.
-- With PostHook, the hook actually runs before BeardLib somehow, which causes a crash.
--Hooks:PostHook(WeaponTweakData, "_init_new_weapons", "inf_weapontweak_initnewweapons_wpnstats", function(self)
local old_wep_tweak_init = WeaponTweakData._init_new_weapons
function WeaponTweakData:_init_new_weapons(...)
	old_wep_tweak_init(self, ...)

	-- Check if BeardLib is installed, THIS IS NECESSARY for InF to work. Apparently this isn't clear enough for some people,
	-- so I'll let the crashlogs speak for themselves.
	-- I'm not going to hardcode a check for BeardLib's existence, instead I am simply going to check if the primary SMG's are loaded.
	-- Just in case another mod comes around to replace BeardLib
	if not self.coalprimary then
		error("Could not initialize IREnFIST weapons (weapontweakdata self.coalprimary)! Is BeardLib installed?")
	end

	self.stats.total_ammo_mod = {}
	for i = -1000, 10000, 1 do
		table.insert(self.stats.total_ammo_mod, i / 1000)
	end

	self.stats.extra_ammo = {}
	for i = -500, 500, 1 do
		table.insert( self.stats.extra_ammo, i )
	end

	self.stats.reload = {}
	for i = 1, 300, 1 do
		table.insert(self.stats.reload, i / 100)
	end

	-- fill out dmg table up to 300
	for i = 21.5, 30, 0.5 do
		table.insert(self.stats.damage, i)
	end


	self.stats.spread = {
		10, 9.9,9.8,9.7,9.6,9.5,9.4,9.3,9.2,9.1, -- 1-10   1 = 0acc
		9.0,8.9,8.8,8.7,8.6,8.5,8.4,8.3,8.2,8.1, -- 11-20  11 = 2acc
		8.0,7.9,7.8,7.7,7.6,7.5,7.4,7.3,7.2,7.1, -- 21-30  21 = 4acc
		7.0,6.9,6.8,6.7,6.6,6.5,6.4,6.3,6.2,6.1, -- 31-40  31 = 6acc
		6.0,5.9,5.8,5.7,5.6,5.5,5.4,5.3,5.2,5.1, -- 41-50  41 = 8acc
		5.0,4.9,4.8,4.7,4.6,4.5,4.4,4.3,4.2,4.1, -- 51-60  51 = 10acc
		4.0,3.9,3.8,3.7,3.6,3.5,3.4,3.3,3.2,3.1, -- 61-70  61 = 12acc
		3.0,2.9,2.8,2.7,2.6,2.5,2.4,2.3,2.2,2.1, -- 71-80  71 = 14acc
		2.0,1.9,1.8,1.7,1.6,1.5,1.4,1.3,1.2,1.1, -- 81-90  81 = 16acc
		1.0,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1, -- 91-100 91 = 18acc
		.09,.08,.07,.06,.05,.04,.03,.02,.01,0 -- 100-110
	}

	self.stats.zoom = {
		65,
		60,
		55,
		50,
		45,
		40,
		35,
		30,
		25,
		20
	}

	--[[
	self.stats.zoom = {
		67.5,
		65, --
		62.5,
		60, --
		57.5,
		55, --
		52.5,
		50, --
		47.5,
		45, --
		42.5,
		40, --
		37.5,
		35, --
		32.5,
		30, --
		27.5,
		25, --
		22.5,
		20 --
	}
	--]]


	self.stats.spread_moving = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}


	self.stats.recoil = {}
	for i = 1, 200, 1 do
		table.insert(self.stats.recoil, (0.1 * (1.025^(200-i))))
	end
	-- !!
	--[[
	10:42:49 PM Lua: 0.33532767997108
	10:42:49 PM Lua: 0.32714895606934
	10:42:49 PM Lua: 0.31916971323838
	10:42:49 PM Lua: 0.31138508608623
	10:42:49 PM Lua: 0.303790327889
	10:42:49 PM Lua: 0.29638080769659
	10:42:49 PM Lua: 0.28915200750887
	10:42:49 PM Lua: 0.28209951952085
	10:42:49 PM Lua: 0.27521904343497
	10:42:49 PM Lua: 0.268506383839
	10:42:49 PM Lua: 0.2619574476478
	10:42:49 PM Lua: 0.25556824160761
	10:42:49 PM Lua: 0.24933486986108
	10:42:49 PM Lua: 0.24325353157179
	10:42:49 PM Lua: 0.23732051860662
	10:42:49 PM Lua: 0.23153221327475
	10:42:49 PM Lua: 0.22588508612171
	10:42:49 PM Lua: 0.22037569377728
	10:42:49 PM Lua: 0.21500067685588
	10:42:49 PM Lua: 0.20975675790818 -- +30 indices ~= -50% recoil
	10:42:49 PM Lua: 0.20464073942261
	10:42:49 PM Lua: 0.19964950187572
	10:42:49 PM Lua: 0.19478000182997
	10:42:49 PM Lua: 0.19002927007802
	10:42:49 PM Lua: 0.18539440983222
	10:42:49 PM Lua: 0.18087259495826
	10:42:49 PM Lua: 0.17646106825196
	10:42:49 PM Lua: 0.17215713975801
	10:42:49 PM Lua: 0.16795818512977
	10:42:49 PM Lua: 0.16386164402904 -- +20 indices ~= -40% recoil
	10:42:49 PM Lua: 0.15986501856492
	10:42:49 PM Lua: 0.15596587177065
	10:42:49 PM Lua: 0.15216182611771
	10:42:49 PM Lua: 0.14845056206606
	10:42:49 PM Lua: 0.14482981664981 -- +15 indices ~= -30% recoil
	10:42:49 PM Lua: 0.14129738209738
	10:42:49 PM Lua: 0.13785110448525
	10:42:49 PM Lua: 0.13448888242463
	10:42:49 PM Lua: 0.13120866578013
	10:42:49 PM Lua: 0.12800845441964
	10:42:49 PM Lua: 0.12488629699477 -- +9 indices ~= -20% recoil
	10:42:49 PM Lua: 0.12184028975099
	10:42:49 PM Lua: 0.11886857536682 -- +7 indices ~= -15% recoil
	10:42:49 PM Lua: 0.11596934182129
	10:42:49 PM Lua: 0.11314082128906
	10:42:49 PM Lua: 0.1103812890625 -- +4 indices ~= -10% recoil
	10:42:49 PM Lua: 0.1076890625
	10:42:49 PM Lua: 0.1050625
	10:42:49 PM Lua: 0.1025
	10:42:49 PM Lua: 0.1
	--]]

	local lmglist = {"rpk", "m249", "hk21", "mg42", "par", "m60"}
	local pivot_shoulder_translation = nil
	local pivot_shoulder_rotation = nil
	local pivot_head_translation = nil
	local pivot_head_rotation = nil




	self.amcar.sdesc1 = "caliber_r556x45"
	self.amcar.sdesc2 = "action_di"
	self.amcar.fire_mode_data.fire_rate = 60/750
	self.amcar.stats.concealment = 23
	self.amcar.not_empty_reload_speed_mult = 1.10 * self:convert_reload_to_mult("mag_66")
	self.amcar.timers.reload_not_empty = 2.10
	self.amcar.timers.reload_not_empty_end = 0.50 -- 2.36
	self.amcar.empty_reload_speed_mult = 1.05 * self:convert_reload_to_mult("mag_66")
	self.amcar.timers.reload_empty = 2.75
	self.amcar.timers.reload_empty_end = 0.40 -- 3
	self.amcar.reload_stance_mod = {ads = {translation = Vector3(3, 0, -5), rotation = Rotation(0, 5, 0)}}
	--self.amcar.price = 50*1000


	self.new_m4.sdesc1 = "caliber_r556x45"
	self.new_m4.sdesc2 = "action_di"
	self.new_m4.fire_mode_data.fire_rate = 60/700
	--self.new_m4.stats.concealment = 20
	self.new_m4.not_empty_reload_speed_mult = 1.30
	self.new_m4.timers.reload_not_empty = 2.60
	self.new_m4.timers.reload_not_empty_end = 0.50 -- 2.38/-25% 3.17
	self.new_m4.empty_reload_speed_mult = 1.30
	--self.new_m4.timers.reload_empty = 3.43
	self.new_m4.timers.reload_empty_end = 0.50 -- 3.02/4.03
	--self.new_m4.price = 100*1000
	self.new_m4.reload_stance_mod = {ads = {translation = Vector3(0, 5, 0), rotation = Rotation(0, 0, 0)}}
	self.new_m4.reload_timed_stance_mod = {
		not_empty = {
			ads = {
				{t = 3, translation = Vector3(-5, 3, -5), rotation = Rotation(-10, 0, 0), speed = 1} -- hold straighter and lower
			}
		},
		empty = {
			hip = {
				{t = 0.8, translation = Vector3(-22, 0, -5), rotation = Rotation(-20, 0, -30), speed = 1}, -- check that bolt has released
				{t = 0.1, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1}
			},
			ads = {
				{t = 3, translation = Vector3(-10, 3, -5), rotation = Rotation(-20, 0, 0), speed = 1}, -- hold straighter and lower
				{t = 0.8, translation = Vector3(-10, -3, -15), rotation = Rotation(-10, 15, -30), speed = 1}, -- check that bolt has released
				{t = 0.1, translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0), speed = 1}
			}
		}
	}


	self.ak74.sdesc1 = "caliber_r545x39"
	self.ak74.sdesc2 = "action_gaslong"
	self.ak74.auto.fire_rate = 60/650
	self.ak74.fire_mode_data.fire_rate = 60/650
	self.ak74.stats.concealment = 19
	self.ak74.not_empty_reload_speed_mult = 1.40
	--self.ak74.timers.reload_not_empty = 2.8
	self.ak74.timers.reload_not_empty_end = 0.40 -- 2.29
	self.ak74.empty_reload_speed_mult = 1.30
	self.ak74.timers.reload_empty = 3.80
	self.ak74.timers.reload_empty_end = 0.40 -- 3.23
	self.ak74.reload_stance_mod = {ads = {translation = Vector3(0, 0, -4), rotation = Rotation(0, 5, 0)}}
	--self.ak74.price = 50*1000
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("ak74", {
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.ak5.sdesc1 = "caliber_r556x45"
	self.ak5.sdesc2 = "action_gas"
	self.ak5.fire_mode_data.fire_rate = 60/650
	self.ak5.stats.concealment = 19
	self.ak5.not_empty_reload_speed_mult = 1.15
	--self.ak5.timers.reload_not_empty = 2.05
	self.ak5.timers.reload_not_empty_end = 0.60 -- 2.30
	self.ak5.empty_reload_speed_mult = 1.15
	--self.ak5.timers.reload_empty = 3.08
	self.ak5.timers.reload_empty_end = 0.70 -- 3.29
	self.ak5.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.ak5.reload_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	--self.ak5.price = 3050*1000


	self.aug.sdesc1 = "caliber_r556x45"
	self.aug.sdesc2 = "action_gas"
	self.aug.fire_mode_data.fire_rate = 60/700
	self.aug.stats.concealment = 22
	self.aug.not_empty_reload_speed_mult = 1.50
	self.aug.timers.reload_not_empty = 2.95
	self.aug.timers.reload_not_empty_end = 0.60 -- 2.37
	self.aug.empty_reload_speed_mult = 1.25
	self.aug.timers.reload_empty = 3.20
	self.aug.timers.reload_empty_end = 0.60 -- 3.04
	self.aug.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.aug.reload_stance_mod = {ads = {translation = Vector3(0, 0, -4), rotation = Rotation(0, 0, 0)}}
	--self.aug.price = 150*1000

	self.famas.sdesc1 = "caliber_r556x45"
	self.famas.sdesc2 = "action_blowbacklever"
	self.famas.fire_mode_data.fire_rate = 60/1000
	self.famas.auto.fire_rate = 60/1000
	self.famas.CLIP_AMMO_MAX = 25
	self.famas.AMMO_MAX = 175
	self.famas.AMMO_PICKUP = self:_pickup_chance(175, 1)
	self.famas.stats.concealment = 25
	self.famas.not_empty_reload_speed_mult = 1.40
	self.famas.timers.reload_not_empty = 2.60
	self.famas.timers.reload_not_empty_end = 0.50 -- 2.21
	self.famas.empty_reload_speed_mult = 1.45
	self.famas.timers.reload_empty = 3.50
	self.famas.timers.reload_empty_end = 0.60 -- 2.82
	--self.famas.price = 300*1000


	self.s552.sdesc1 = "caliber_r56gp90"
	self.s552.sdesc2 = "action_gas"
	self.s552.fire_mode_data.fire_rate = 60/700
	self.s552.stats.spread = self.s552.stats.spread - 15
	self.s552.stats.concealment = 25
	self.s552.not_empty_reload_speed_mult = 1.00
	--self.s552.timers.reload_not_empty = 1.65
	self.s552.timers.reload_not_empty_end = 0.50 -- 2.15
	self.s552.empty_reload_speed_mult = 1.00
	self.s552.timers.reload_empty = 2.25
	self.s552.timers.reload_empty_end = 0.40 -- 2.65
	--self.s552.price = 150*1000


	self.g36.sdesc1 = "caliber_r556x45"
	self.g36.sdesc2 = "action_pistonshort"
	self.g36.stats.spread = self.g36.stats.spread - 10
	self.g36.stats.recoil = self.g36.stats.recoil + 3
	self.g36.stats.concealment = 24
	self.g36.fire_mode_data.fire_rate = 60/750
	self.g36.not_empty_reload_speed_mult = 1.30
	self.g36.timers.reload_not_empty = 2.75
	self.g36.timers.reload_not_empty_end = 0.40 -- 2.42
	self.g36.empty_reload_speed_mult = 1.35
	self.g36.timers.reload_empty = 3.45
	self.g36.timers.reload_empty_end = 0.60 -- 3.00
	--self.g36.price = 150*1000
	self:apply_standard_bipod_stats("g36")
	self.g36.custom_bipod = true
	self.g36.bipod_weapon_translation = Vector3(-3, -5, -4)
	pivot_shoulder_translation = Vector3(18.5, 23, -3.4)
	pivot_shoulder_rotation = Rotation(0.15, 0, 0)
	pivot_head_translation = Vector3(8, 15, -2.25)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.g36.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.g36.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.g36.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.g36.use_custom_anim_state = true


	self.vhs.sdesc1 = "caliber_r556x45"
	self.vhs.sdesc2 = "action_gas"
	self.vhs.fire_mode_data.fire_rate = 60/850
	self.vhs.stats.recoil = self.vhs.stats.recoil + 4
	self.vhs.stats.concealment = 23
	self.vhs.not_empty_reload_speed_mult = 1.40
	self.vhs.timers.reload_not_empty = 3.20
	self.vhs.timers.reload_not_empty_end = 0.80 -- 2.86
	self.vhs.empty_reload_speed_mult = 1.45
	self.vhs.timers.reload_empty = 4.20
	self.vhs.timers.reload_empty_end = 1.00 -- 3.59
	--self.vhs.price = 300*1000


	self.l85a2.sdesc1 = "caliber_r556x45"
	self.l85a2.sdesc2 = "action_gas"
	self.l85a2.fire_mode_data.fire_rate = 60/675
	self.l85a2.auto.fire_rate = 60/675
	self.l85a2.stats.concealment = 23
	self.l85a2.not_empty_reload_speed_mult = 1.55
	self.l85a2.timers.reload_not_empty = 3.15
	self.l85a2.timers.reload_not_empty_end = 0.60 -- 2.42
	self.l85a2.empty_reload_speed_mult = 1.40
	self.l85a2.timers.reload_empty = 3.40
	self.l85a2.timers.reload_empty_end = 1.20 -- 3.29
	self.l85a2.reload_stance_mod = {ads = {translation = Vector3(0, 2, 0), rotation = Rotation(0, 0, 0)}}
	--self.l85a2.price = 250*1000


	self.sub2000.sdesc1 = "caliber_p40sw"
	self.sub2000.sdesc2 = "action_blowback"
	self.sub2000.CLIP_AMMO_MAX = 31
	self.sub2000.AMMO_MAX = 124
	self.sub2000.AMMO_PICKUP = self:_pickup_chance(124, 1)
	--self.sub2000.stats.concealment = 27
	self.sub2000.fire_mode_data.fire_rate = 60/600
	self.sub2000.single.fire_rate = 60/600
	self.sub2000.not_empty_reload_speed_mult = 1.25
	--self.sub2000.timers.reload_not_empty = 2.3
	self.sub2000.timers.reload_not_empty_end = 0.80 -- 2.48
	self.sub2000.empty_reload_speed_mult = 1.35
	self.sub2000.timers.reload_empty = 3.10
	self.sub2000.timers.reload_empty_end = 1.00 -- 3.04
	--self.sub2000.price = 50*1000


	-- MTAR 21
	self.komodo.sdesc1 = "caliber_r556x45"
	self.komodo.sdesc2 = "action_gaslong"
	self.komodo.stats.concealment = 24
	self.komodo.fire_mode_data.fire_rate = 60/800
	self.komodo.auto.fire_rate = 60/800
	self.komodo.not_empty_reload_speed_mult = 1.10
	self.komodo.timers.reload_not_empty = 2.05
	self.komodo.timers.reload_not_empty_end = 0.60 -- 2.40
	self.komodo.empty_reload_speed_mult = 1.15
	self.komodo.timers.reload_empty = 2.60
	self.komodo.timers.reload_empty_end = 0.80 -- 2.96
	--self.komodo.price = 200*1000


	-- AK17/AK12
	self.flint.sdesc1 = "caliber_r545x39"
	self.flint.sdesc2 = "action_gaslong"
	self.flint.stats.concealment = 22
	self.flint.auto.fire_rate = 60/650
	self.flint.fire_mode_data.fire_rate = 60/650
	self.flint.CLIP_AMMO_MAX = 30
	self.flint.not_empty_reload_speed_mult = 1.15
	self.flint.timers.reload_not_empty = 2.10
	self.flint.timers.reload_not_empty_end = 0.70 -- 2.43
	self.flint.empty_reload_speed_mult = 1.25
	self.flint.timers.reload_empty = 3.00
	self.flint.timers.reload_empty_end = 0.80 -- 3.04
	--self.flint.price = 300*1000


	-- union/F2000
	self.corgi.sdesc1 = "caliber_r556x45"
	self.corgi.sdesc2 = "action_gas"
	self.corgi.stats.concealment = 22
	self.corgi.fire_mode_data.fire_rate = 60/850
	self.corgi.auto.fire_rate = 60/850
	self.corgi.not_empty_reload_speed_mult = 1.15
	self.corgi.timers.reload_not_empty = 2.10
	self.corgi.timers.reload_not_empty_end = 0.60 -- 2.43
	self.corgi.empty_reload_speed_mult = 1.10
	self.corgi.timers.reload_empty = 2.70
	self.corgi.timers.reload_empty_end = 0.60 -- 3.00
	self.corgi.reload_stance_mod = {ads = {translation = Vector3(2, 0, 0), rotation = Rotation(0, 0, 0)}}
	--self.corgi.price = 250*1000


	self.m16.sdesc1 = "caliber_r556x45"
	self.m16.sdesc2 = "action_di"
	self.m16.stats.concealment = 22
	self.m16.fire_mode_data.fire_rate = 60/800
	self.m16.CLIP_AMMO_MAX = 20
	self.m16.not_empty_reload_speed_mult = 1.60
	--self.m16.timers.reload_not_empty = 2.75
	self.m16.timers.reload_not_empty_end = 0.60 -- 2.09, -20% 2.61, -35% 3.22
	self.m16.empty_reload_speed_mult = 1.65
	self.m16.timers.reload_empty = 3.55
	self.m16.timers.reload_empty_end = 0.60 -- 2.52, 3.15, 3.88
	self.m16.reload_stance_mod = {ads = {translation = Vector3(0, 0, -6), rotation = Rotation(0, 5, 0)}}
	--self.m16.price = 100*1000
	self:apply_standard_bipod_stats("m16")
	self.m16.custom_bipod = true
	self.m16.bipod_weapon_translation = Vector3(-3, -7, -3)
	pivot_shoulder_translation = Vector3(17.15, 24.5, -3.55)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(6.5, 15.5, -2)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.m16.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.m16.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.m16.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.m16.use_custom_anim_state = true


	self.akm.sdesc1 = "caliber_r762x39"
	self.akm.sdesc2 = "action_gaslong"
	self.akm.stats.concealment = 18
	self.akm.fire_mode_data.fire_rate = 60/600
	self.akm.not_empty_reload_speed_mult = 1.20
	self.akm.timers.reload_not_empty = 2.20
	self.akm.timers.reload_not_empty_end = 0.70 -- 2.42
	self.akm.empty_reload_speed_mult = 1.40
	self.akm.timers.reload_empty = 3.60
	self.akm.timers.reload_empty_end = 1.00 -- 3.29
	self.akm.reload_stance_mod = {ads = {translation = Vector3(0, 0, -4), rotation = Rotation(0, 5, 0)}}
	--self.akm.price = 50*1000
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("akm", {
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		})
	end


	self:copy_sdescs("akm_gold", "akm")
	self:copy_stats("akm_gold", "akm")
	self.akm_gold.stats.concealment = self.akm.stats.concealment - 2
	self:copy_timers("akm_gold", "akm")
	self.akm_gold.price = 5*1000000
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("akm_gold", {
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.scar.sdesc1 = "caliber_r762x51"
	self.scar.sdesc2 = "action_pistonshort"
	self.scar.stats.concealment = 20
	self.scar.fire_mode_data.fire_rate = 60/600
	self.scar.not_empty_reload_speed_mult = 1.25
	self.scar.timers.reload_not_empty = 2.30
	self.scar.timers.reload_not_empty_end = 0.40 -- 2.16
	self.scar.empty_reload_speed_mult = 1.30
	self.scar.timers.reload_empty = 2.75
	self.scar.timers.reload_empty_end = 0.80 -- 2.73
	self.scar.reload_stance_mod = {ads = {translation = Vector3(0, 0, -3), rotation = Rotation(0, 0, 0)}}
	--self.scar.price = 200*1000


	self.fal.sdesc1 = "caliber_r762x51"
	self.fal.sdesc2 = "action_gas"
	self.fal.stats.concealment = 20
	self.fal.shake.fire_steelsight_multiplier = 0.20 -- stop clipping through my eyes
	self.fal.fire_mode_data.fire_rate = 60/700
	self.fal.not_empty_reload_speed_mult = 1.25
	--self.fal.timers.reload_not_empty = 2.20
	self.fal.timers.reload_not_empty_end = 0.50 -- 2.16/-25% 2.88
	self.fal.empty_reload_speed_mult = 1.40
	self.fal.timers.reload_empty = 3.00
	self.fal.timers.reload_empty_end = 0.80 -- 2.71/3.61
	self.fal.reload_stance_mod = {ads = {translation = Vector3(5, 0, -3), rotation = Rotation(0, 0, 0)}}
	--self.fal.price = 100*1000


	self.g3.sdesc1 = "caliber_r762x51"
	self.g3.sdesc2 = "action_blowbackroller"
	self.g3.stats.concealment = 19
	self.g3.fire_mode_data.fire_rate = 60/600
	-- who sold us this animation, the cops?
	self.g3.not_empty_reload_speed_mult = 1.1
	self.g3.timers.reload_not_empty = 1.4
	self.g3.timers.reload_not_empty_end = 0.6 -- 2.22
	self.g3.empty_reload_speed_mult = 1.2
	self.g3.timers.reload_empty = 1.9
	self.g3.timers.reload_empty_end = 1.1 -- 3.00
	-- NOTE: changed G3 magazine size to 20 to match IRL. Improved reload speed as a result. Has 30rnd mag weaponmod that makes it like before.
	self.g3.CLIP_AMMO_MAX = 20
	self:apply_standard_bipod_stats("g3")
	self.g3.custom_bipod = true
	self.g3.bipod_weapon_translation = Vector3(-3, -5, -4)
	pivot_shoulder_translation = Vector3(18.15, 18.5, -6)
	pivot_shoulder_rotation = Rotation(0.1, -0.07, 0.7)
	pivot_head_translation = Vector3(7.5, 14, -4)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.g3.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.g3.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.g3.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.g3.use_custom_anim_state = true
	if checkfolders("old g3 animation") then
		Hooks:RemovePostHook("g3animsrevertinit")
		self.g3.not_empty_reload_speed_mult = 1.80
		self.g3.timers.reload_not_empty = 2.5
		self.g3.timers.reload_not_empty_end = 1.0 -- 2.19
		self.g3.empty_reload_speed_mult = 1.75
		self.g3.timers.reload_empty = 3.4
		self.g3.timers.reload_empty_end = 1.1 -- 2.90
	end
	--self.g3.price = 100*1000


	self.asval.sdesc1 = "caliber_r9x39"
	self.asval.sdesc2 = "action_gas"
	self.asval.sdesc4 = "misc_alwayssilent"
	self.asval.stats.spread = self.asval.stats.spread + 5
	self.asval.stats.recoil = self.asval.stats.recoil + 6
	self.asval.stats.concealment = 23
	self.asval.fire_mode_data.fire_rate = 60/900
	self.asval.auto.fire_rate = 60/900
	self.asval.not_empty_reload_speed_mult = 1.6
	self.asval.timers.reload_not_empty = 2.5
	self.asval.timers.reload_not_empty_end = 0.50 -- 2.14
	self.asval.empty_reload_speed_mult = 1.75
	self.asval.timers.reload_empty = 3.2
	self.asval.timers.reload_empty_end = 0.70 -- 2.52
	-- NOTE: lowered the magazine size on the AS val but increased the reload speed mults by about an additive 0.2x
	self.asval.CLIP_AMMO_MAX = 20
	--self.asval.price = 500*1000
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("asval", {
			name = "a_o_notugly",
			base_a_obj = "a_o",
			position = Vector3(0, 2, -3),
			rotation = Rotation(0, 0, 0)
		})
		self:SetupAttachmentPoint("asval", {
			name = "a_infrail",
			base_a_obj = "a_o",
			position = Vector3(0, 2, -2.75),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.contraband.sdesc1 = "caliber_r762x51"
	self.contraband.sdesc2 = "action_pistonshort"
	self.contraband.sdesc3 = "misc_gl40x46mm"
	self.contraband.stats.concealment = 14
	self.contraband.FIRE_MODE = "auto"
	--self.contraband.AMMO_MAX = 80
	--self.contraband.AMMO_PICKUP = self:_pickup_chance(80, 1)
	self.contraband.fire_mode_data.fire_rate = 60/600
	self.contraband.auto.fire_rate = 60/600
	self.contraband.not_empty_reload_speed_mult = 1.3
	self.contraband.timers.reload_not_empty = 2.45
	self.contraband.timers.reload_not_empty_end = 0.70 -- 2.42
	self.contraband.empty_reload_speed_mult = 1.25
	--self.contraband.timers.reload_empty = 3.2
	self.contraband.timers.reload_empty_end = 0.60 -- 3.04
	self.contraband.equip_stance_mod = {ads = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 5, 0)}}
	--self.contraband_m203.chamber = 0 -- DOES NOT WORK
	self.contraband_m203.AMMO_MAX = 2
	self.contraband_m203.AMMO_PICKUP = {1338, 15}
	self.contraband_m203.timers.reload_not_empty = 2.35
	self.contraband_m203.timers.reload_not_empty_end = 0.40
	self.contraband_m203.timers.reload_empty = 2.35
	self.contraband_m203.timers.reload_empty_end = 0.40
	--self.contraband.price = 200*1000

	-- KETCHNOV Byk-1 (Groza)
	self:inf_init("groza", "ar", {"medium", "has_gl"})
	self.groza.sdesc1 = "caliber_r9x39"
	self.groza.sdesc2 = "action_gas"
	self:copy_timers("groza", "l85a2")
	-- Groza underbarrel
	self.groza_underbarrel.AMMO_MAX = 2
	self.groza_underbarrel.AMMO_PICKUP = {1338, 15}
	self.groza_underbarrel.timers.reload_not_empty = 2.35
	self.groza_underbarrel.timers.reload_not_empty_end = 0.40
	self.groza_underbarrel.timers.reload_empty = 2.35
	self.groza_underbarrel.timers.reload_empty_end = 0.40

	-- KS12 Urban Rifle (SHAK-12)
	self:inf_init("shak12", "ar", {"heavy"})
	self.shak12.sdesc1 = "caliber_r127x55sts130"
	self.shak12.sdesc2 = "action_shortrecoil"
	self.shak12.fire_mode_data.fire_rate = 60/500
	self:copy_timers("shak12", "flint")
	

	-- Galil
	self.galil.sdesc1 = "caliber_r762x51"
	self.galil.sdesc2 = "action_gas"
	self.galil.stats.concealment = 20
	self.galil.fire_mode_data.fire_rate = 60/700
	self.galil.auto.fire_rate = 60/700
	self.galil.CLIP_AMMO_MAX = 25
	self.galil.not_empty_reload_speed_mult = 1.30
	self.galil.timers.reload_not_empty = 2.65
	self.galil.timers.reload_not_empty_end = 0.50 -- 2.42
	self.galil.empty_reload_speed_mult = 1.30
	self.galil.timers.reload_empty = 3.65
	self.galil.timers.reload_empty_end = 0.50 -- 3.20
	--self.galil.price = 100*1000
	self:apply_standard_bipod_stats("galil")
	self.galil.custom_bipod = true
	self.galil.bipod_weapon_translation = Vector3(-2, -2, 0)
	pivot_shoulder_translation = Vector3(17.15, 29.2, -4.83)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.5)
	pivot_head_translation = Vector3(6.5, 15, -1)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.galil.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.galil.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.galil.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.galil.use_custom_anim_state = true


	self.new_m14.sdesc1 = "caliber_r762x51"
	self.new_m14.sdesc2 = "action_gas"
	self.new_m14.CAN_TOGGLE_FIREMODE = false
	self.new_m14.CLIP_AMMO_MAX = 20
	self.new_m14.stats.concealment = 20
	self.new_m14.not_empty_reload_speed_mult = 1.50
	self.new_m14.timers.reload_not_empty = 2.55
	self.new_m14.timers.reload_not_empty_end = 1.0 -- 2.40
	self.new_m14.empty_reload_speed_mult = 1.35
	self.new_m14.timers.reload_empty = 3.00
	self.new_m14.timers.reload_empty_end = 1.0 -- 2.96
	self.new_m14.reload_stance_mod = {ads = {translation = Vector3(0, 2, 0), rotation = Rotation(0, 0, 0)}}
	--self.new_m14.price = 100*1000
	self:apply_standard_bipod_stats("new_m14")
	self.new_m14.custom_bipod = true
	self.new_m14.bipod_weapon_translation = Vector3(-3, -7, -4)
	pivot_shoulder_translation = Vector3(21.96, 24, -10.06)
	pivot_shoulder_rotation = Rotation(0, 0, 0)
	pivot_head_translation = Vector3(11, 11, -6)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.new_m14.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.new_m14.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.new_m14.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.new_m14.use_custom_anim_state = true


	-- contractor 308
	self.tti.sdesc1 = "caliber_r762x51"
	self.tti.sdesc2 = "action_di"
	self.tti.CLIP_AMMO_MAX = 20
	self.tti.stats.concealment = 18
	self.tti.not_empty_reload_speed_mult = 1.25
	self.tti.timers.reload_not_empty = 2.20
	self.tti.timers.reload_not_empty_end = 0.60 -- 2.24
	self.tti.empty_reload_speed_mult = 1.25
	self.tti.timers.reload_empty = 3.00
	self.tti.timers.reload_empty_end = 0.80 -- 3.00
	self.tti.timers.equip = 0.60
	self.tti.timers.unequip = 0.60
	--self.tti.price = 200*1000


	-- m1 garand
	self.ching.sdesc1 = "caliber_r3006"
	self.ching.sdesc2 = "action_gas"
	self.ching.chamber = 0
	self.ching.AMMO_MAX = 56
	self.ching.AMMO_PICKUP = self:_pickup_chance(56, 1)
	self.ching.stats.recoil = self.ching.stats.recoil + 3
	self.ching.stats.concealment = 21
	self.ching.not_empty_reload_speed_mult = 1.10
	self.ching.timers.reload_not_empty = 2.10
	self.ching.timers.reload_not_empty_end = 0.80 -- 2.63
	self.ching.empty_reload_speed_mult = 1.00
	self.ching.timers.reload_empty = 1.40
	self.ching.timers.reload_empty_end = 0.50 -- 1.90
	--self.ching.price = 150*1000


	-- SVD/Grom
	self.siltstone.sdesc1 = "caliber_r762x54r"
	self.siltstone.sdesc2 = "action_pistonshort"
	self.siltstone.stats.recoil = self.siltstone.stats.recoil + 4
	self.siltstone.stats.concealment = 18
	self.siltstone.not_empty_reload_speed_mult = 1.25
	self.siltstone.timers.reload_not_empty = 2.2
	self.siltstone.timers.reload_not_empty_end = 0.6 -- 2.24
	self.siltstone.empty_reload_speed_mult = 1.25
	self.siltstone.timers.reload_empty = 2.9
	self.siltstone.timers.reload_empty_end = 0.8 -- 2.96
	self.siltstone.reload_stance_mod = {ads = {translation = Vector3(3, 0, 3), rotation = Rotation(0, 0, 0)}}
	--self.siltstone.price = 300*1000
	self.siltstone.timers.equip = 0.70
	self.siltstone.timers.unequip = 0.70


	-- repeater
	self.winchester1874.sdesc1 = "caliber_r4440"
	self.winchester1874.sdesc2 = "action_lever"
	self.winchester1874.stats.concealment = 17
	self.winchester1874.reload_speed_mult = self.winchester1874.reload_speed_mult * 1.20
	self.winchester1874.anim_speed_mult = 1.20
	self.winchester1874.hipfire_uses_ads_anim = true
	self.winchester1874.fire_mode_data.fire_rate = 60/100
	self.winchester1874.stats.damage = 56 -- 280
	self.winchester1874.stats.spread = self.winchester1874.stats.spread - 5
	self.winchester1874.AMMO_MAX = 45
	self.winchester1874.AMMO_PICKUP = self:_pickup_chance(45, 1)
	self.winchester1874.reload_stance_mod = {ads = {translation = Vector3(5, 0, -4), rotation = Rotation(0, 0, 0)}}
	--self.winchester1874.price = 100*1000
	self.winchester1874.timers.unequip = 0.60
	self.winchester1874.timers.equip = 0.60
	self:apply_standard_bipod_stats("winchester1874")
	self.winchester1874.custom_bipod = true
	self.winchester1874.bipod_weapon_translation = Vector3(-2, -4, -2)
	pivot_shoulder_translation = Vector3(21.56, 55.3, -14.1)
	pivot_shoulder_rotation = Rotation(0, -0.1, 0.5)
	pivot_head_translation = Vector3(11, 48, -5.5)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.winchester1874.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.winchester1874.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.winchester1874.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.winchester1874.use_custom_anim_state = true
	self.winchester1874.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("winchester1874", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 49, 4),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.msr.sdesc1 = "caliber_r762x51"
	self.msr.sdesc2 = "action_bolt"
	self.msr.stats.damage = 56 -- 280
	self.msr.stats.concealment = 17
	self.msr.anim_speed_mult = 1.50
	self.msr.not_empty_reload_speed_mult = 1.00
	self.msr.timers.reload_not_empty = 2.55
	self.msr.timers.reload_not_empty_end = 0.80 -- 3.35
	self.msr.empty_reload_speed_mult = 1.00
	self.msr.timers.reload_empty = 3.15
	self.msr.timers.reload_empty_end = 1.00 -- 4.15
	--self.msr.price = 200*1000
	self:apply_standard_bipod_stats("msr")
	self.msr.custom_bipod = true
	self.msr.bipod_weapon_translation = Vector3(0, -6, -4)
	pivot_shoulder_translation = Vector3(20.11, 42.8, -8.14)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(11.5, 37, -4.75)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.msr.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.msr.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.msr.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.msr.use_custom_anim_state = true
	self.msr.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("msr", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 67, 6),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.model70.sdesc1 = "caliber_r3006"
	self.model70.sdesc2 = "action_bolt"
	self.model70.stats.concealment = 19
	self.model70.anim_speed_mult = 1.40
	self.model70.not_empty_reload_speed_mult = 1.60
	--self.model70.reload_not_empty = 3.35
	self.model70.timers.reload_not_empty_end = 0.70 -- 2.53
	self.model70.empty_reload_speed_mult = 1.55
	self.model70.timers.reload_empty = 4.15
	self.model70.timers.reload_empty_end = 0.80 -- 3.20
	--self.model70.price = 100*1000
	self:apply_standard_bipod_stats("model70")
	self.model70.custom_bipod = true
	self.model70.bipod_weapon_translation = Vector3(0, 6, -4)
	pivot_shoulder_translation = Vector3(19.46, 29, -8.68)
	pivot_shoulder_rotation = Rotation(0, 0, 0)
	pivot_head_translation = Vector3(11.5, 37, -4.75)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.model70.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.model70.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.model70.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.model70.use_custom_anim_state = true
	self.model70.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("model70", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 55.5, 3.5),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.wa2000.sdesc1 = "caliber_r762x51"
	self.wa2000.sdesc2 = "action_gas"
	self.wa2000.fire_mode_data.fire_rate = 60/180
	self.wa2000.CLIP_AMMO_MAX = 6
	self.wa2000.AMMO_MAX = 42
	self.wa2000.AMMO_PICKUP = self:_pickup_chance(42, 1)
	self.wa2000.stats.damage = 56 -- 280
	self.wa2000.stats.spread = self.wa2000.stats.spread - 5
	self.wa2000.stats.concealment = 23
	self.wa2000.not_empty_reload_speed_mult = 2.0
	--self.wa2000.timers.reload_not_empty = 4.64
	self.wa2000.timers.reload_not_empty_end = 0.90 -- 2.77
	self.wa2000.empty_reload_speed_mult = 2.0
	self.wa2000.timers.reload_empty = 5.8
	self.wa2000.timers.reload_empty_end = 1.20 -- 3.50
	self.wa2000.equip_stance_mod = {ads = {translation = Vector3(0, 0, -4), rotation = Rotation(0, 0, 0)}}
	self.wa2000.reload_stance_mod = {ads = {translation = Vector3(5, -5, -5), rotation = Rotation(0, 0, 0)}}
	--self.wa2000.price = 500*1000
	self.wa2000.timers.equip = 0.70
	self.wa2000.timers.unequip = 0.60
	self:apply_standard_bipod_stats("wa2000")
	self.wa2000.custom_bipod = true
	self.wa2000.bipod_weapon_translation = Vector3(0, 6, -4)
	pivot_shoulder_translation = Vector3(19.525, 3.5, -0.75)
	pivot_shoulder_rotation = Rotation(0, 0, 0)
	pivot_head_translation = Vector3(9, 13, -1)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.wa2000.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.wa2000.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.wa2000.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.wa2000.use_custom_anim_state = true
	self.wa2000.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("wa2000", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 50, 0),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.r93.sdesc1 = "caliber_r338"
	self.r93.sdesc2 = "action_bolt"
	self.r93.CLIP_AMMO_MAX = 5
	self.r93.stats.concealment = 17
	self.r93.not_empty_reload_speed_mult = 1.40
	--self.r93.timers.reload_not_empty = 2.82
	self.r93.timers.reload_not_empty_end = 0.70 -- 2.51
	self.r93.empty_reload_speed_mult = 1.40
	--self.r93.timers.reload_empty = 3.82
	self.r93.timers.reload_empty_end = 0.50 -- 3.09
	--self.r93.price = 300*1000
	self:apply_standard_bipod_stats("r93")
	self.r93.custom_bipod = true
	self.r93.bipod_weapon_translation = Vector3(-2, -6, -4)
	pivot_shoulder_translation = Vector3(20.555, 48.5, -8.55)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(10, 33, -4)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.r93.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.r93.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.r93.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.r93.use_custom_anim_state = true
	self.r93.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("r93", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 47, 4),
			rotation = Rotation(0, 0, 0)
		})
	end


	self.mosin.sdesc1 = "caliber_r762x54r"
	self.mosin.sdesc2 = "action_bolt"
	self.mosin.chamber = 0
	self.mosin.stats.concealment = 17
	self.mosin.not_empty_reload_speed_mult = 1.40
	self.mosin.timers.reload_not_empty = 3.4
	self.mosin.timers.reload_not_empty_end = 0.50 -- 2.79
	self.mosin.empty_reload_speed_mult = 1.40
	self.mosin.timers.reload_empty = 3.4
	self.mosin.timers.reload_empty_end = 0.50 -- 2.79
	--self.mosin.price = 50*1000
	self:apply_standard_bipod_stats("mosin")
	self.mosin.custom_bipod = true
	self.mosin.bipod_weapon_translation = Vector3(-2, -6, -4)
	pivot_shoulder_translation = Vector3(16.655, 40.5, -6.1)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(8, 35, -2)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.mosin.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.mosin.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.mosin.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.mosin.use_custom_anim_state = true
	self.mosin.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("mosin", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 70, 4),
			rotation = Rotation(0, 0, 0)
		})
	end


	-- vulpeserda
	self.desertfox.sdesc1 = "caliber_r338"
	self.desertfox.sdesc2 = "action_bolt"
	self.desertfox.stats.spread = self.desertfox.stats.spread - 15
	self.desertfox.stats.concealment = 21
	self.desertfox.anim_speed_mult = 1.20
	self.desertfox.not_empty_reload_speed_mult = 1.40
	self.desertfox.timers.reload_not_empty = 2.65
	self.desertfox.timers.reload_not_empty_end = 0.80 -- 2.46
	self.desertfox.empty_reload_speed_mult = 1.40
	self.desertfox.timers.reload_empty = 3.50
	self.desertfox.timers.reload_empty_end = 1.00 -- 3.21
	--self.desertfox.price = 300*1000
	self:apply_standard_bipod_stats("desertfox")
	self.desertfox.custom_bipod = true
	self.desertfox.bipod_weapon_translation = Vector3(0, -2, -4)
	pivot_shoulder_translation = Vector3(17.42, -2.8, -10.57)
	pivot_shoulder_rotation = Rotation(-0.2, 0.2, -0.2)
	pivot_head_translation = Vector3(10, 12, -6)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.desertfox.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.desertfox.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.desertfox.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.desertfox.use_custom_anim_state = true
	self.desertfox.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("desertfox", {
				name = "a_bp",
				base_a_obj = "a_body",
				position = Vector3(0, 30, 5),
				rotation = Rotation(0, 0, 0)
		})
	end


	self.m95.sdesc1 = "caliber_r50bmg"
	self.m95.sdesc2 = "action_bolt"
	self.m95.stats.concealment = 10
	--[[
	self.m95.pen_wall_dist_mult = 4
	self.m95.CLIP_AMMO_MAX = 5
	self.m95.AMMO_MAX = 10
	self.m95.stats.spread = self.m95.stats.spread + 5
	self.m95.stats.recoil = self.m95.stats.recoil - 20
	self.m95.AMMO_PICKUP = {1338, 50}
	self.m95.stats.damage = 70 -- 3500
	self.m95.stats_modifiers.damage = 50
	self.m95.fire_mode_data.fire_rate = 60/60
	self.m95.single.fire_rate = 60/60
	--]]
	self.m95.anim_speed_mult = 1.50
	self.m95.not_empty_reload_speed_mult = 1.25
	--self.m95.timers.reload_not_empty = 3.96
	self.m95.timers.reload_not_empty_end = 1.00 -- 3.97
	self.m95.empty_reload_speed_mult = 1.25
	self.m95.timers.reload_empty = 4.80
	self.m95.timers.reload_empty_end = 1.00 -- 4.64
	self.m95.equip_stance_mod = {ads = {translation = Vector3(0, 0, -3), rotation = Rotation(0, 0, 0)}}
	self.m95.reload_stance_mod = {ads = {translation = Vector3(10, 23, -5), rotation = Rotation(0, 0, 0)}}
	--self.m95.price = 500*1000
	self:apply_standard_bipod_stats("m95")
	self.m95.custom_bipod = true
	self.m95.bipod_weapon_translation = Vector3(-3, -6, -4)
	pivot_shoulder_translation = Vector3(2.96, -2.4, 2.33)
	pivot_shoulder_rotation = Rotation(0.1, 0.5, 0.5)
	pivot_head_translation = Vector3(-10, -23, 5)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.m95.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.m95.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.m95.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.m95.use_custom_anim_state = true
	self.m95.bipod_rof_mult = 1.25

	-- R700
	self.r700.sdesc1 = "caliber_r762x51"
	self.r700.sdesc2 = "action_bolt"
	self.r700.CLIP_AMMO_MAX = 10
	self.r700.stats.concealment = 17
	self.r700.not_empty_reload_speed_mult = 1.40
	self.r700.timers.reload_not_empty = 3.3
	self.r700.timers.reload_not_empty_end = 0.70 -- 2.51
	self.r700.empty_reload_speed_mult = 1.40
	self.r700.timers.reload_empty = 5
	self.r700.timers.reload_empty_end = 0.8 -- 3.09
	--self.r700.price = 300*1000
	self:apply_standard_bipod_stats("r700")
	self.r700.custom_bipod = true
	self.r700.bipod_weapon_translation = Vector3(-2, 0, -4)
	pivot_shoulder_translation = Vector3(19.38, 42.8, -8.53)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(11.5, 50, -4.75)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.r700.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.r700.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.r700.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.r700.use_custom_anim_state = true
	self.r700.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("r700", {
				name = "a_bp",
				base_a_obj = "a_body",
				position = Vector3(0, 47, 2),
				rotation = Rotation(0, 0, 0)
		})
	end

	-- Gunslinger pack rifle
	-- Marlin Model 1895 SBL
	self:inf_init("sbl", "snp")
	self.sbl.sdesc1 = "caliber_r4570govt"
	self.sbl.sdesc2 = "action_lever"
	self.sbl.stats.concealment = 17
	self.sbl.reload_speed_mult = self.sbl.reload_speed_mult * 1.20
	self.sbl.anim_speed_mult = 1.20
	self.sbl.hipfire_uses_ads_anim = true
	self.sbl.fire_mode_data.fire_rate = 60/100
	self.sbl.stats.damage = 56 -- 280
	self.sbl.stats.spread = self.sbl.stats.spread - 5
	self.sbl.CLIP_AMMO_MAX = 6
	self.sbl.AMMO_MAX = 45
	self.sbl.AMMO_PICKUP = self:_pickup_chance(45, 1)
	self.sbl.reload_stance_mod = {ads = {translation = Vector3(5, 0, -4), rotation = Rotation(0, 0, 0)}}
	--self.winchester1874.price = 100*1000
	self.sbl.timers.unequip = 0.60
	self.sbl.timers.equip = 0.60
	self:apply_standard_bipod_stats("sbl")
	self.sbl.custom_bipod = true
	self.sbl.bipod_weapon_translation = Vector3(-2, -4, -2)
	pivot_shoulder_translation = Vector3(21.56, 55.3, -14.1)
	pivot_shoulder_rotation = Rotation(0, -0.1, 0.5)
	pivot_head_translation = Vector3(11, 48, -5.5)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.sbl.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.sbl.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.sbl.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.sbl.use_custom_anim_state = true
	self.sbl.bipod_rof_mult = 1.25
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("sbl", {
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 49, 4),
			rotation = Rotation(0, 0, 0)
		})
	end

	-- QBU-88 sniper (Kang Arms X1 Sniper Rifle)
	self:inf_init("qbu88", "ar", {"dmr"})
	self:copy_stats("qbu88", "siltstone")
	self:copy_timers("qbu88", "siltstone")
	self.qbu88.sdesc1 = "caliber_r58x42"
	self.qbu88.sdesc2 = "action_gas"

	-- Tec-9
	self.tec9.sdesc1 = "caliber_p9x19"
	self.tec9.sdesc2 = "action_blowback"
	self.tec9.FIRE_MODE = "single"
	self.tec9.CAN_TOGGLE_FIREMODE = false
	self.tec9.fire_mode_data.fire_rate = 60/900
	self.tec9.auto.fire_rate = 60/900
	self.tec9.chamber = 0
	self.tec9.stats.spread = self.tec9.stats.spread + 10
	--self.tec9.stats.concealment = 27
	self.tec9.AMMO_MAX = 160
	self.tec9.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.tec9.not_empty_reload_speed_mult = 1.70
	self.tec9.timers.reload_not_empty = 2.15
	self.tec9.timers.reload_not_empty_end = 0.50 -- 1.56
	self.tec9.empty_reload_speed_mult = 1.70
	self.tec9.timers.reload_empty = 3.00
	self.tec9.timers.reload_empty_end = 0.80 -- 2.24
	--self.tec9.price = 50*1000
	self:copy_sdescs("x_tec9", "tec9", true)
	self:copy_stats("x_tec9", "tec9", true)
	self.x_tec9.AMMO_MAX = 180
	self.x_tec9.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_tec9.price = self.tec9.price * 1.5
	--self.x_tec9.stats.concealment = 27
	self.x_tec9.reload_speed_mult = self.x_tec9.reload_speed_mult * 1.10 * 1.30 -- 1.43x
	self.x_tec9.not_empty_reload_speed_mult = 1.00
	self.x_tec9.timers.reload_not_empty = 2.10
	self.x_tec9.timers.reload_not_empty_half = 1.60
	self.x_tec9.timers.reload_not_empty_end = 1.30 -- 2.38
	self.x_tec9.empty_reload_speed_mult = self.x_tec9.not_empty_reload_speed_mult * 0.80
	self.x_tec9.timers.reload_empty = 2.70
	self.x_tec9.timers.reload_empty_half = 2.30
	self.x_tec9.timers.reload_empty_end = 1.00 -- 3.2
	self.x_tec9.FIRE_MODE = "single"
	self.x_tec9.CAN_TOGGLE_FIREMODE = false



	self.mp9.sdesc1 = "caliber_p9x19"
	self.mp9.sdesc2 = "action_blowback"
	self.mp9.stats.concealment = 28
	self.mp9.fire_mode_data.fire_rate = 60/950
	self.mp9.auto.fire_rate = 60/950
	self.mp9.CLIP_AMMO_MAX = 15
	self.mp9.not_empty_reload_speed_mult = 1.80
	--self.mp9.timers.reload_not_empty = 1.51
	self.mp9.timers.reload_not_empty_end = 0.70 -- 1.22/-40% 2.04
	self.mp9.empty_reload_speed_mult = 1.80
	self.mp9.timers.reload_empty = 2.30
	self.mp9.timers.reload_empty_end = 0.50 -- 1.55/2.58
	--self.mp9.price = 100*1000
	self:copy_sdescs("x_mp9", "mp9", true)
	self:copy_stats("x_mp9", "mp9", true)
	self.x_mp9.stats.concealment = 28
	self.x_mp9.AMMO_MAX = 180
	self.x_mp9.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_mp9.price = self.mp9.price * 1.5
	self:copy_timers("x_mp9", "x_tec9")
	self.x_mp9.reload_speed_mult = self.x_mp9.reload_speed_mult * 1.25


	self.scorpion.sdesc1 = "caliber_p32acp"
	self.scorpion.sdesc2 = "action_blowback"
	self.scorpion.fire_mode_data.fire_rate = 60/850
	self.scorpion.stats.spread = self.scorpion.stats.spread - 5
	self.scorpion.stats.recoil = self.scorpion.stats.recoil + 10
	self.scorpion.stats.concealment = 29
	self.scorpion.AMMO_MAX = 160
	self.scorpion.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.scorpion.not_empty_reload_speed_mult = 1.65
	self.scorpion.timers.reload_not_empty = 1.9
	self.scorpion.timers.reload_not_empty_end = 0.50 -- 1.45
	self.scorpion.empty_reload_speed_mult = 1.5
	self.scorpion.timers.reload_empty = 2.40
	self.scorpion.timers.reload_empty_end = 0.60 -- 2.00
	self.scorpion.reload_stance_mod = {ads = {translation = Vector3(2, 0, -2), rotation = Rotation(0, 0, 0)}}
	--self.scorpion.price = 50*1000
	self:copy_sdescs("x_scorpion", "scorpion", true)
	self:copy_stats("x_scorpion", "scorpion", true)
	--self.x_scorpion.stats.concealment = 28
	self.x_scorpion.AMMO_MAX = 180
	self.x_scorpion.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_scorpion.price = self.scorpion.price * 1.5
	self:copy_timers("x_scorpion", "x_tec9")
	self.x_scorpion.reload_speed_mult = self.x_scorpion.reload_speed_mult * 1


	self.mp7.sdesc1 = "caliber_p46"
	self.mp7.sdesc2 = "action_pistonshort"
	self.mp7.stats.concealment = 28
	self.mp7.fire_mode_data.fire_rate = 60/950
	self.mp7.auto.fire_rate = 60/950
	self.mp7.not_empty_reload_speed_mult = 1.45
	self.mp7.timers.reload_not_empty = 1.80
	self.mp7.timers.reload_not_empty_end = 0.50 -- 1.59/-35% 2.44
	self.mp7.empty_reload_speed_mult = 1.35
	self.mp7.timers.reload_empty = 2.25
	self.mp7.timers.reload_empty_end = 0.50 -- 2.04/3.14
	self.mp7.stats.spread = self.mp7.stats.spread + 10
	self.mp7.stats.recoil = self.mp7.stats.recoil - 5
	self.mp7.AMMO_MAX = 160
	self.mp7.AMMO_PICKUP = self:_pickup_chance(160, 1)
	--self.mp7.price = 200*1000
	self:copy_sdescs("x_mp7", "mp7", true)
	self:copy_stats("x_mp7", "mp7", true)
	self.x_mp7.stats.concealment = 28
	self.x_mp7.AMMO_MAX = 180
	self.x_mp7.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_mp7.price = self.mp7.price * 1.5
	self:copy_timers("x_mp7", "x_tec9")
	self.x_mp7.reload_speed_mult = self.x_mp7.reload_speed_mult * 1


	self.cobray.sdesc1 = "caliber_p9x19"
	self.cobray.sdesc2 = "action_blowbackstraight"
	self.cobray.stats.concealment = 26
	self.cobray.chamber = 0
	self.cobray.CLIP_AMMO_MAX = 32
	self.cobray.AMMO_MAX = 160
	self.cobray.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.cobray.not_empty_reload_speed_mult = 1.10
	self.cobray.timers.reload_not_empty = 1.90
	self.cobray.timers.reload_not_empty_end = 0.50 -- 2.20
	self.cobray.empty_reload_speed_mult = 1.75
	self.cobray.timers.reload_empty = 3.60
	self.cobray.timers.reload_empty_end = 1.10 -- 2.69
	--self.cobray.price = 50*1000
	self:copy_sdescs("x_cobray", "cobray", true)
	self:copy_stats("x_cobray", "cobray", true)
	self.x_cobray.stats.concealment = 26
	self.x_cobray.chamber = 0
	self.x_cobray.AMMO_MAX = 192
	self.x_cobray.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_cobray.price = self.cobray.price * 1.5
	self:copy_timers("x_cobray", "x_tec9")
	self.x_cobray.reload_speed_mult = self.x_cobray.reload_speed_mult * 0.85


	self.uzi.sdesc1 = "caliber_p9x19"
	self.uzi.sdesc2 = "action_blowback"
	self.uzi.chamber = 0
	self.uzi.fire_mode_data.fire_rate = 60/700
	self.uzi.auto.fire_rate = 60/700
	self.uzi.stats.spread = self.uzi.stats.spread + 5
	self.uzi.stats.recoil = self.uzi.stats.recoil - 3
	self.uzi.CLIP_AMMO_MAX = 32
	self.uzi.AMMO_MAX = 160
	self.uzi.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.uzi.not_empty_reload_speed_mult = 1.30
	self.uzi.timers.reload_not_empty = 2.30
	self.uzi.timers.reload_not_empty_end = 0.70 -- 2.31
	self.uzi.empty_reload_speed_mult = 1.40
	self.uzi.timers.reload_empty = 3.35
	self.uzi.timers.reload_empty_end = 0.70 -- 2.89
	self.uzi.equip_stance_mod = {ads = {translation = Vector3(0, 0, -1), rotation = Rotation(0, 0, 0)}}
	self.uzi.reload_stance_mod = {ads = {translation = Vector3(4, 0, 0), rotation = Rotation(0, 0, 0)}}
	--self.uzi.price = 100*1000
	self:copy_sdescs("x_uzi", "uzi", true)
	self:copy_stats("x_uzi", "uzi", true)
	self.x_uzi.AMMO_MAX = 192
	self.x_uzi.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_uzi.price = self.uzi.price
	self:copy_timers("x_uzi", "x_tec9")
	self.x_uzi.reload_speed_mult = self.x_uzi.reload_speed_mult * 0.85


	-- mini-uzi
	self.baka.sdesc1 = "caliber_p9x19"
	self.baka.sdesc2 = "action_blowback"
	self.baka.chamber = 0
	self.baka.stats.spread = self.baka.stats.spread - 5
	--self.baka.stats.concealment = 29
	self.baka.AMMO_MAX = 160
	self.baka.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.baka.not_empty_reload_speed_mult = 1.00
	--self.baka.timers.reload_not_empty = 1.85
	self.baka.timers.reload_not_empty_end = 0.50 -- 2.35
	self.baka.empty_reload_speed_mult = 1.00
	self.baka.timers.reload_empty = 2.4
	self.baka.timers.reload_empty_end = 0.50 -- 2.90
	--self.baka.price = 100*1000
	self:copy_sdescs("x_baka", "baka", true)
	self:copy_stats("x_baka", "baka", true)
	--self.x_baka.stats.concealment = 29
	self.x_baka.AMMO_MAX = 192
	self.x_baka.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_baka.price = self.baka.price * 1.5
	self:copy_timers("x_baka", "x_tec9")
	self.x_baka.reload_speed_mult = self.x_baka.reload_speed_mult * 0.85


	self.sr2.sdesc1 = "caliber_p9x21"
	self.sr2.sdesc2 = "action_gas"
	self.sr2.stats.concealment = 27
	self.sr2.fire_mode_data.fire_rate = 60/900
	self.sr2.CLIP_AMMO_MAX = 30
	self.sr2.not_reload_speed_mult = 1.25
	self.sr2.timers.reload_not_empty = 2.00
	self.sr2.timers.reload_not_empty_end = 0.80 -- 2.24
	self.sr2.empty_reload_speed_mult = 1.65
	self.sr2.timers.reload_empty = 3.60
	self.sr2.timers.reload_empty_end = 1.20 -- 2.91
	self.sr2.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	--self.sr2.price = 300*1000
	self:copy_sdescs("x_sr2", "sr2", true)
	self:copy_stats("x_sr2", "sr2", true)
	self.x_sr2.AMMO_MAX = 180
	self.x_sr2.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self.x_sr2.stats.concealment = 27
	--self.x_sr2.price = self.sr2.price * 1.5
	self.x_sr2.reload_speed_mult = self.x_sr2.reload_speed_mult * 1
	self.x_sr2.not_empty_reload_speed_mult = 0.75 -- 3.07
	self.x_sr2.timers.reload_not_empty = 1.80
	self.x_sr2.timers.reload_not_empty_half = 1.30
	self.x_sr2.timers.reload_not_empty_end = 0.50
	self.x_sr2.empty_reload_speed_mult = 0.65 -- 4.15
	self.x_sr2.timers.reload_empty = 2.20
	self.x_sr2.timers.reload_empty_half = 1.60
	self.x_sr2.timers.reload_empty_end = 0.50


	self.p90.sdesc1 = "caliber_p57"
	self.p90.sdesc2 = "action_blowbackstraight"
	self.p90.fire_mode_data.fire_rate = 60/900
	self.p90.auto.fire_rate = 60/900
	self.p90.stats.spread = self.p90.stats.spread - 10
	self.p90.stats.concealment = 26
	self.p90.not_empty_reload_speed_mult = 1.10
	--self.p90.timers.reload_not_empty = 2.55
	self.p90.timers.reload_not_empty_end = 0.80 -- 3.05
	self.p90.not_empty_reload_speed_mult = 1.00
	self.p90.timers.reload_empty = 3.25
	self.p90.timers.reload_empty_end = 0.50 -- 3.75
	--self.p90.price = 200*1000
	self:copy_sdescs("x_p90", "p90", true)
	self:copy_stats("x_p90", "p90", true)
	self.x_p90.stats.concealment = 26
	self.x_p90.AMMO_MAX = 200
	self.x_p90.AMMO_PICKUP = self:_pickup_chance(200, 1)
	--self.x_p90.price = self.p90.price * 1.5
	self.x_p90.reload_speed_mult = self.x_p90.reload_speed_mult * 1
	self.x_p90.not_empty_reload_speed_mult = 0.80
	self.x_p90.timers.reload_not_empty = 2.20
	self.x_p90.timers.reload_not_empty_half = 1.80 -- should be ~-0.75/mag_17? overall, 4sec/5.33sec
	self.x_p90.timers.reload_not_empty_end = 1.00 -- 4
	self.x_p90.empty_reload_speed_mult = 0.70
	self.x_p90.timers.reload_empty = 2.70
	self.x_p90.timers.reload_empty_half = 2.30
	self.x_p90.timers.reload_empty_end = 1.00 -- 5.28


	self.mac10.sdesc1 = "caliber_p45acp"
	self.mac10.sdesc2 = "action_blowbackstraight"
	self.mac10.stats.concealment = 30
	self.mac10.chamber = 0
	self.mac10.fire_mode_data.fire_rate = 60/1100
	self.mac10.CLIP_AMMO_MAX = 15
	self.mac10.not_empty_reload_speed_mult = 1.70
	self.mac10.timers.reload_not_empty = 1.55
	self.mac10.timers.reload_not_empty_end = 0.50 -- 1.21/-30% 1.73
	self.mac10.empty_reload_speed_mult = 1.80
	self.mac10.timers.reload_empty = 2.30
	self.mac10.timers.reload_empty_end = 0.50 -- 1.55/2.21
	self.mac10.reload_stance_mod = {ads = {translation = Vector3(2, 0, -5), rotation = Rotation(0, 0, 0)}}
	--self.mac10.price = 50*1000
	self:copy_sdescs("x_mac10", "mac10", true)
	self:copy_stats("x_mac10", "mac10", true)
	self.x_mac10.stats.concealment = 30
	self.x_mac10.AMMO_MAX = 180
	self.x_mac10.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_mac10.price = self.mac10.price * 1.5
	self:copy_timers("x_mac10", "x_tec9")
	self.x_mac10.reload_speed_mult = self.x_mac10.reload_speed_mult * self:convert_reload_to_mult("mag_75")


	-- vector/vertex
	self.polymer.sdesc1 = "caliber_p45acp"
	self.polymer.sdesc2 = "action_blowbackdelayed"
	self.polymer.stats.concealment = 25
	self.polymer.fire_mode_data.fire_rate = 60/1200
	self.polymer.CLIP_AMMO_MAX = 25
	self.polymer.stats.spread = self.polymer.stats.spread - 10
	self.polymer.stats.recoil = self.polymer.stats.recoil + 5
	self.polymer.not_empty_reload_speed_mult = 1.10
	--self.polymer.timers.reload_not_empty = 2.00
	self.polymer.timers.reload_not_empty_end = 0.50 -- 2.27
	self.polymer.empty_reload_speed_mult = 1.10
	--self.polymer.timers.reload_empty = 2.50
	self.polymer.timers.reload_empty_end = 0.50 -- 2.73
	--self.polymer.price = 200*1000
	self:copy_sdescs("x_polymer", "polymer", true)
	self:copy_stats("x_polymer", "polymer", true)
	self.x_polymer.stats.concealment = 26
	self.x_polymer.AMMO_MAX = 200
	self.x_polymer.AMMO_PICKUP = self:_pickup_chance(200, 1)
	--self.x_polymer.price = self.polymer.price
	self:copy_timers("x_polymer", "x_tec9")
	self.x_polymer.reload_speed_mult = self.x_polymer.reload_speed_mult * 0.90
	self.x_polymer.timers.reload_empty = self.x_tec9.timers.reload_empty + 0.15
	self.x_polymer.timers.reload_empty_half = self.x_tec9.timers.reload_empty_half + 0.10


	self.m45.sdesc1 = "caliber_p9x19m39b"
	self.m45.sdesc2 = "action_blowbackstraight"
	--self.m45.stats.concealment = 24
	self.m45.chamber = 0
	self.m45.CLIP_AMMO_MAX = 36
	self.m45.AMMO_MAX = 144
	self.m45.AMMO_PICKUP = self:_pickup_chance(144, 1)
	self.m45.stats.spread = self.m45.stats.spread - 5
	self.m45.not_empty_reload_speed_mult = 1.40
	self.m45.timers.reload_not_empty = 2.60
	self.m45.timers.reload_not_empty_end = 0.80 -- 2.43 / -15% 2.86
	self.m45.empty_reload_speed_mult = 1.50
	self.m45.timers.reload_empty = 3.55
	self.m45.timers.reload_empty_end = 1.00 -- 3.03 / 3.56
	self.m45.reload_stance_mod = {ads = {translation = Vector3(0, 5, -5), rotation = Rotation(0, 0, 0)}}
	--self.m45.price = 50*1000
	self:copy_sdescs("x_m45", "m45", true)
	self:copy_stats("x_m45", "m45", true)
	self.x_m45.stats.concealment = 26
	self.x_m45.AMMO_MAX = 216
	self.x_m45.AMMO_PICKUP = self:_pickup_chance(216, 1)
	--self.x_m45.price = self.m45.price * 1.5
	self:copy_timers("x_m45", "x_tec9")
	self.x_m45.reload_speed_mult = self.x_m45.reload_speed_mult * 0.80


	-- tatonka/bizon
	self.coal.sdesc1 = "caliber_p9x18"
	self.coal.sdesc2 = "action_blowbackstraight"
	--self.coal.stats.concealment = 24
	self.coal.fire_mode_data.fire_rate = 60/650
	self.coal.auto.fire_rate = 60/650
	self.coal.AMMO_MAX = 128
	self.coal.AMMO_PICKUP = self:_pickup_chance(128, 1)
	self.coal.not_empty_reload_speed_mult = 1.00
	self.coal.timers.reload_not_empty = 3.15
	self.coal.timers.reload_not_empty_end = 0.50 -- 3.65
	self.coal.empty_reload_speed_mult = 1.00
	self.coal.timers.reload_empty = 4.00
	self.coal.timers.reload_empty_end = 0.50 -- 4.5
	self:inf_init("coalprimary", "smg", {"range_long"})
	self:copy_sdescs("coalprimary", "coal")
	self:copy_stats("coalprimary", "coal")
	self.coalprimary.stats.concealment = 25
	self.coalprimary.AMMO_MAX = 192
	self.coalprimary.AMMO_PICKUP = self:_pickup_chance(192, 1)
	self:copy_timers("coalprimary", "coal")
	--self.coal.price = 200*1000
	self:copy_sdescs("x_coal", "coal", true)
	self:copy_stats("x_coal", "coal", true)
	--self.x_coal.stats.concealment = 24
	self.x_coal.AMMO_MAX = 256
	self.x_coal.AMMO_PICKUP = self:_pickup_chance(256, 1)
	self.x_coal.no_auto_anim = true
	--self.x_coal.price = self.coal.price * 1.5
	self:copy_timers("x_coal", "x_tec9")
	self.x_coal.reload_speed_mult = self.x_coal.reload_speed_mult * 0.50



	self.new_mp5.sdesc1 = "caliber_p9x19"
	self.new_mp5.sdesc2 = "action_blowbackroller"
	--self.new_mp5.stats.concealment = 24
	self.new_mp5.fire_mode_data.fire_rate = 60/800
	self.new_mp5.not_empty_reload_speed_mult = 1.20
	--self.new_mp5.timers.reload_not_empty = 2.4
	self.new_mp5.timers.reload_not_empty_end = 0.50 -- 2.42
	self.new_mp5.empty_reload_speed_mult = 1.40
	self.new_mp5.timers.reload_empty = 3.50
	self.new_mp5.timers.reload_empty_end = 0.70 -- 3.00
	--self.new_mp5.price = 150*1000
	self:inf_init("new_mp5primary", "smg", {"range_long"})
	self:copy_sdescs("new_mp5primary", "new_mp5")
	self:copy_stats("new_mp5primary", "new_mp5")
	self.new_mp5primary.stats.concealment = 27
	self.new_mp5primary.AMMO_MAX = 180
	self.new_mp5primary.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self:copy_timers("new_mp5primary", "new_mp5")
	--
	self:copy_sdescs("x_mp5", "new_mp5", true)
	self:copy_stats("x_mp5", "new_mp5", true)
	self.x_mp5.stats.concealment = 25
	self.x_mp5.AMMO_MAX = 180
	self.x_mp5.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_mp5.price = self.new_mp5.price * 1.5
	self.x_mp5.reload_speed_mult = self.x_mp5.reload_speed_mult * 1.05
	self.x_mp5.not_empty_reload_speed_mult = self.x_sr2.not_empty_reload_speed_mult * 1
	self.x_mp5.timers.reload_not_empty = self.x_sr2.timers.reload_not_empty
	self.x_mp5.timers.reload_not_empty_half = self.x_sr2.timers.reload_not_empty_half
	self.x_mp5.timers.reload_not_empty_end = self.x_sr2.timers.reload_not_empty_end
	self.x_mp5.empty_reload_speed_mult = self.x_sr2.not_empty_reload_speed_mult * 1
	self.x_mp5.timers.reload_empty = self.x_sr2.timers.reload_empty
	self.x_mp5.timers.reload_empty_half = self.x_sr2.timers.reload_empty_half
	self.x_mp5.timers.reload_empty_end = 0.80


	-- signature/mpx
	self.shepheard.sdesc1 = "caliber_p9x19"
	self.shepheard.sdesc2 = "action_gasshort"
	self.shepheard.stats.concealment = 25
	self.shepheard.CLIP_AMMO_MAX = 15
	self.shepheard.fire_mode_data.fire_rate = 60/850
	self.shepheard.auto.fire_rate = 60/850
	self.shepheard.not_empty_reload_speed_mult = 1.75
	self.shepheard.timers.reload_not_empty = 2.10
	self.shepheard.timers.reload_not_empty_end = 0.70 -- 1.60/-35% 2.46
	self.shepheard.empty_reload_speed_mult = 1.75
	self.shepheard.timers.reload_empty = 2.85
	self.shepheard.timers.reload_empty_end = 0.50 -- 1.91/2.93
	--self.shepheard.price = 150*1000
	self:inf_init("shepheardprimary", "smg", {"range_long"})
	self:copy_sdescs("shepheardprimary", "shepheard")
	self:copy_stats("shepheardprimary", "shepheard")
	self.shepheardprimary.stats.concealment = 28
	self.shepheardprimary.CLIP_AMMO_MAX = 15
	self.shepheardprimary.AMMO_MAX = 180
	self.shepheardprimary.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self:copy_timers("shepheardprimary", "shepheard")
	--
	self:copy_sdescs("x_shepheard", "shepheard", true)
	self:copy_stats("x_shepheard", "shepheard", true)
	self.x_shepheard.stats.concealment = 28
	self.x_shepheard.AMMO_MAX = 180
	self.x_shepheard.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_shepheard.price = self.shepheard.price * 1.5
	self.x_shepheard.reload_speed_mult = self.x_shepheard.reload_speed_mult * 0.80 * self:convert_reload_to_mult("mag_50")
	self.x_shepheard.not_empty_reload_speed_mult = 1.35
	self.x_shepheard.timers.reload_not_empty = 1.30
	self.x_shepheard.timers.reload_not_empty_half = 1.20
	self.x_shepheard.timers.reload_not_empty_end = 1.20 -- 1.85
	self.x_shepheard.empty_reload_speed_mult = 1.25
	self.x_shepheard.timers.reload_empty = 2.20
	self.x_shepheard.timers.reload_empty_half = 2.00 -- fuck this reload animation
	self.x_shepheard.timers.reload_empty_end = 0.80 -- 2.4
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint( "shepheardprimary", {
				name = "a_b_long",
				base_a_obj = "a_b",
				position = Vector3( 0, 9.5, 0)
			}
		)
	end


	-- jackal/impact-45
	self.schakal.sdesc1 = "caliber_p45acp"
	self.schakal.sdesc2 = "action_blowback"
	--self.schakal.stats.concealment = 24
	self.schakal.fire_mode_data.fire_rate = 60/600
	self.schakal.CLIP_AMMO_MAX = 25
	self.schakal.not_empty_reload_speed_mult = 1.40 --1.35
	self.schakal.timers.reload_not_empty = 2.20
	self.schakal.timers.reload_not_empty_end = 0.80 -- xx --2.22/-25% 2.96/+30% 1.71
	self.schakal.empty_reload_speed_mult = 1.50 --1.45
	self.schakal.timers.reload_empty = 3.55
	self.schakal.timers.reload_empty_end = 0.50 -- xx --2.79/3.72/2.15
	--self.schakal.price = 150*1000
	-- 2.20/2.96
	self:inf_init("schakalprimary", "smg", {"range_long", "dmg_50"})
	self:copy_sdescs("schakalprimary", "schakal")
	self:copy_stats("schakalprimary", "schakal")
	self.schakalprimary.stats.concealment = 27
	self.schakalprimary.CLIP_AMMO_MAX = 25
	self.schakalprimary.AMMO_MAX = 175
	self.schakalprimary.AMMO_PICKUP = self:_pickup_chance(175, 1)
	self:copy_timers("schakalprimary", "schakal")
	--
	self:copy_sdescs("x_schakal", "schakal", true)
	self:copy_stats("x_schakal", "schakal", true)
	self.x_schakal.stats.concealment = 26
	self.x_schakal.AMMO_MAX = 200
	self.x_schakal.AMMO_PICKUP = self:_pickup_chance(200, 1)
	--self.x_schakal.price = self.schakal.price * 1.5
	self:copy_timers("x_schakal", "x_mp5")
	self.x_schakal.reload_speed_mult = self.x_schakal.reload_speed_mult * 1.10


	self.sterling.sdesc1 = "caliber_p9x19"
	self.sterling.sdesc2 = "action_blowback"
	self.sterling.chamber = 0
	self.sterling.fire_mode_data.fire_rate = 60/550
	self.sterling.auto.fire_rate = 60/550
	self.sterling.stats.spread = self.sterling.stats.spread + 5
	self.sterling.stats.recoil = self.sterling.stats.recoil + 2
	self.sterling.stats.concealment = 22
	self.sterling.CLIP_AMMO_MAX = 24 --15/24/34
	self.sterling.no_auto_anim = true
	self.sterling.reload_speed_mult = self.sterling.reload_speed_mult * 1 * self:convert_reload_to_mult("mag_75") -- *1.2
	self.sterling.not_empty_reload_speed_mult = 1.20
	self.sterling.timers.reload_not_empty = 2.30
	self.sterling.timers.reload_not_empty_end = 0.60 -- 2.00
	self.sterling.empty_reload_speed_mult = 1.55
	self.sterling.timers.reload_empty = 3.10
	self.sterling.timers.reload_empty_end = 0.80 -- 2.52
	--self.sterling.price = 50*1000
	self:copy_sdescs("x_sterling", "sterling", true)
	self:copy_stats("x_sterling", "sterling", true)
	self.x_sterling.stats.concealment = 24
	self.x_sterling.no_auto_anim = true
	self.x_sterling.AMMO_MAX = 192
	self.x_sterling.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_sterling.price = self.sterling.price * 1.5
	self:copy_timers("x_sterling", "x_tec9")
	self.x_sterling.reload_speed_mult = self.x_sterling.reload_speed_mult * 1


	-- mp40
	self.erma.sdesc1 = "caliber_p9x19"
	self.erma.sdesc2 = "action_blowbackstraight"
	--self.erma.stats.concealment = 24
	self.erma.chamber = 0
	self.erma.fire_mode_data.fire_rate = 60/550
	self.erma.auto.fire_rate = 60/550
	self.erma.CLIP_AMMO_MAX = 32
	self.erma.AMMO_MAX = 128
	self.erma.AMMO_PICKUP = self:_pickup_chance(128, 1)
	self.erma.not_empty_reload_speed_mult = 1.0
	self.erma.timers.reload_not_empty = 1.9
	self.erma.timers.reload_not_empty_end = 0.50 -- 2.60
	self.erma.empty_reload_speed_mult = 1.0
	self.erma.timers.reload_empty = 3.05
	self.erma.timers.reload_empty_end = 0.30 -- 3.35
	self.erma.reload_stance_mod = {ads = {translation = Vector3(0, 5, -5), rotation = Rotation(0, 0, 0)}}
	--self.erma.price = 100*1000
	self:copy_sdescs("x_erma", "erma", true)
	self:copy_stats("x_erma", "erma", true)
	self.x_erma.stats.concealment = 25
	self.x_erma.AMMO_MAX = 192
	self.x_erma.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_erma.price = self.erma.price * 1.5
	self:copy_timers("x_erma", "x_tec9")
	self.x_erma.reload_speed_mult = self.x_erma.reload_speed_mult * 0.85


	self.m1928.sdesc1 = "caliber_p45acp"
	self.m1928.sdesc2 = "action_blowback"
	self.m1928.chamber = 0
	self.m1928.fire_mode_data.fire_rate = 60/700
	self.m1928.auto.fire_rate = 60/700
	self.m1928.stats.recoil = self.m1928.stats.recoil - 7 -- this is for having 25% more ammo you doofus
	self.m1928.stats.concealment = 22
	self.m1928.AMMO_MAX = 150
	self.m1928.AMMO_PICKUP = self:_pickup_chance(150, 1)
	self.m1928.not_empty_reload_speed_mult = 1.35
	self.m1928.timers.reload_not_empty = 3.25
	self.m1928.timers.reload_not_empty_end = 0.80 -- 3.00
	self.m1928.empty_reload_speed_mult = 1.35
	self.m1928.timers.reload_empty = 4.00
	self.m1928.timers.reload_empty_end = 1.00 -- 3.70
	self.m1928.equip_speed_mult = 1.8
	self.m1928.timers.equip = 1.25
	self:inf_init("m1928primary", "smg", {"range_long", "dmg_50"})
	self:copy_sdescs("m1928primary", "m1928")
	self:copy_stats("m1928primary", "m1928")
	self.m1928primary.stats.concealment = 24
	self.m1928primary.AMMO_MAX = 200
	self.m1928primary.AMMO_PICKUP = self:_pickup_chance(200, 1)
	self:copy_timers("m1928primary", "m1928")
	--self.m1928.price = 250*1000
	self:copy_sdescs("x_m1928", "m1928", true)
	self:copy_stats("x_m1928", "m1928", true)
	self.x_m1928.stats.concealment = 24
	self.x_m1928.AMMO_MAX = 200
	self.x_m1928.AMMO_PICKUP = self:_pickup_chance(200, 1)
	--self.x_m1928.price = self.m1928.price * 1.5
	self:copy_timers("x_m1928", "x_tec9")
	self.x_m1928.reload_speed_mult = self.x_m1928.reload_speed_mult * 0.60
	self.x_m1928.timers.reload_empty = self.x_tec9.timers.reload_empty + 0.02



	self.olympic.sdesc1 = "caliber_r556x45"
	self.olympic.sdesc2 = "action_di"
	self.olympic.stats.concealment = 26
	self.olympic.fire_mode_data.fire_rate = 60/700
	self.olympic.auto.fire_rate = 60/700
	self.olympic.CLIP_AMMO_MAX = 20
	self.olympic.not_empty_reload_speed_mult = 1.30 * self:convert_reload_to_mult("mag_66")
	--self.olympic.timers.reload_not_empty = 2.16
	self.olympic.timers.reload_not_empty_end = 0.70 -- 
	self.olympic.empty_reload_speed_mult = 1.35 * self:convert_reload_to_mult("mag_66")
	self.olympic.timers.reload_empty = 2.90
	self.olympic.timers.reload_empty_end = 1.20 -- 
	--self.olympic.price = 150*1000
	self:inf_init("olympicprimary", "ar", nil)
	self.olympicprimary.categories = {"assault_rifle"}
	self:copy_sdescs("olympicprimary", "olympic")
	self:copy_stats("olympicprimary", "olympic")
	self.olympicprimary.stats.concealment = 26
	self.olympicprimary.CLIP_AMMO_MAX = 20
	self.olympicprimary.AMMO_MAX = 180
	self.olympicprimary.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self:copy_timers("olympicprimary", "olympic")
	--
	self:copy_sdescs("x_olympic", "olympic", true)
	self:copy_stats("x_olympic", "olympic", true)
	--self.x_olympic.price = self.olympic.price * 1.5
	self:copy_timers("x_olympic", "x_tec9")
	self.x_olympic.stats.concealment = 25
	self.x_olympic.AMMO_MAX = 200
	self.x_olympic.AMMO_PICKUP = self:_pickup_chance(200, 1)
	self.x_olympic.reload_speed_mult = self.x_olympic.reload_speed_mult * 1


	self.akmsu.sdesc1 = "caliber_r545x39"
	self.akmsu.sdesc2 = "action_gaslongaks74"
	self.akmsu.stats.concealment = 22
	self.akmsu.fire_mode_data.fire_rate = 60/700
	self.akmsu.auto.fire_rate = 60/700
	self.akmsu.not_empty_reload_speed_mult = 1.10
	self.akmsu.timers.reload_not_empty = 1.95
	self.akmsu.timers.reload_not_empty_end = 0.70 -- 2.41
	self.akmsu.empty_reload_speed_mult = 1.50
	self.akmsu.timers.reload_empty = 3.20
	self.akmsu.timers.reload_empty_end = 1.30 -- 3.00
	self.akmsu.reload_stance_mod = {ads = {translation = Vector3(2, 0, -4), rotation = Rotation(0, 5, 0)}}
	--self.akmsu.price = 100*1000
	self:inf_init("akmsuprimary", "ar", nil)
	self.akmsuprimary.categories = {"assault_rifle"}
	self:copy_sdescs("akmsuprimary", "akmsu")
	self:copy_stats("akmsuprimary", "akmsu")
	self:copy_timers("akmsuprimary", "akmsu")
	self.akmsuprimary.stats.concealment = 22
	--
	self:copy_sdescs("x_akmsu", "akmsu", true)
	self:copy_stats("x_akmsu", "akmsu", true)
	self.x_akmsu.stats.concealment = 22
	self.x_akmsu.AMMO_MAX = 180
	self.x_akmsu.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_akmsu.price = self.akmsu.price * 1.5
	self:copy_timers("x_akmsu", "x_tec9")
	self.x_akmsu.reload_speed_mult = self.x_akmsu.reload_speed_mult * 0.85


	-- cz 805b
	self.hajk.sdesc1 = "caliber_r556x45"
	self.hajk.sdesc2 = "action_gas"
	self.hajk.fire_mode_data.fire_rate = 60/750
	self.hajk.stats.spread = self.hajk.stats.spread + 15
	self.hajk.stats.recoil = self.hajk.stats.recoil - 7
	self.hajk.stats.concealment = 20
	self.hajk.not_empty_reload_speed_mult = 1.00
	self.hajk.timers.reload_not_empty = 1.80
	self.hajk.timers.reload_not_empty_end = 0.70 -- 2.50
	self.hajk.empty_reload_speed_mult = 1.20
	self.hajk.timers.reload_empty = 2.80
	self.hajk.timers.reload_empty_end = 1.10 -- 
	--self.hajk.price = 200*1000
	self:inf_init("hajkprimary", "ar", nil)
	self.hajkprimary.categories = {"assault_rifle"}
	self:copy_sdescs("hajkprimary", "hajk")
	self:copy_stats("hajkprimary", "hajk")
	self:copy_timers("hajkprimary", "hajk")
	self.hajkprimary.stats.concealment = 20
	--
	self:copy_sdescs("x_hajk", "hajk", true)
	self:copy_stats("x_hajk", "hajk", true)
	self.x_hajk.stats.concealment = 20
	self.x_hajk.AMMO_MAX = 180
	self.x_hajk.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_hajk.price = self.hajk.price * 1.5
	self:copy_timers("x_hajk", "x_tec9")
	self.x_hajk.reload_speed_mult = self.x_hajk.reload_speed_mult * 0.85

	-- Vityaz
	self:inf_init("vityaz", "smg", {"range_long"})
	self.vityaz.sdesc1 = "caliber_p9x19"
	self.vityaz.sdesc2 = "action_blowback"
	self:copy_timers("vityaz", "ak5")
	self.vityaz.stats.concealment = 22

	self:inf_init("vityazprimary", "smg", {"range_long", "dmg_50"})
	self:copy_sdescs("vityazprimary", "vityaz")
	self:copy_stats("vityazprimary", "vityaz")
	self:copy_timers("vityazprimary", "vityaz")
	self.vityazprimary.stats.concealment = 23
	self.vityazprimary.AMMO_MAX = 180

	self:inf_init("vityaz", "smg", {"range_long"})
	self:copy_sdescs("x_vityaz", "vityaz", true)
	self:copy_stats("x_vityaz", "vityaz", true)
	self:copy_timers("x_vityaz", "vityaz", true)

	
	-- Miyaka 10 (Minebea PM-9) SMG
	self:inf_init("pm9", "smg", {"range_short"})
	self:copy_timers("pm9", "baka")
	self:copy_stats("pm9", "baka")
	self.pm9.fire_mode_data.fire_rate = 60/1100
	self.pm9.sdesc1 = "caliber_p9x19"
	self.pm9.sdesc2 = "action_blowback"

	self:inf_init("x_pm9", "smg", {"range_short"})
	self:copy_timers("x_pm9", "x_baka")
	self:copy_stats("x_pm9", "x_baka")
	self.x_pm9.fire_mode_data.fire_rate = 60/1100
	self.x_pm9.sdesc1 = "caliber_p9x19"
	self.x_pm9.sdesc2 = "action_blowback"


	self.b92fs.sdesc1 = "caliber_p9x19"
	self.b92fs.sdesc2 = "action_shortrecoil"
	self.b92fs.CLIP_AMMO_MAX = 15
	--self.b92fs.stats.concealment = 30
	self.b92fs.not_empty_reload_speed_mult = 1.0
	--self.b92fs.timers.reload_not_empty = 1.47
	self.b92fs.timers.reload_not_empty_end = 0.50 -- xx
	self.b92fs.empty_reload_speed_mult = 1.0
	self.b92fs.timers.reload_empty = 2.05
	self.b92fs.timers.reload_empty_end = 0.40 -- xx
	--self.b92fs.price = 100*1000
	self:copy_sdescs("x_b92fs", "b92fs", true)
	self.x_b92fs.CLIP_AMMO_MAX = self.b92fs.CLIP_AMMO_MAX * 2
	self.x_b92fs.AMMO_MAX = 180
	self.x_b92fs.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self.x_b92fs.stats.concealment = 30
	--self.x_b92fs.price = self.b92fs.price * 1.5
	self.x_b92fs.not_empty_reload_speed_mult = 1.15
	self.x_b92fs.timers.reload_not_empty = 3.00
	self.x_b92fs.timers.reload_not_empty_half = 2.00
	self.x_b92fs.timers.reload_not_empty_end = 0.50 -- 3.04
	self.x_b92fs.empty_reload_speed_mult = 1.25
	self.x_b92fs.timers.reload_empty = 3.00
	self.x_b92fs.timers.reload_empty_half = 2.00
	self.x_b92fs.timers.reload_empty_end = 1.30 -- 4.00


	self.glock_17.sdesc1 = "caliber_p9x19"
	self.glock_17.sdesc2 = "action_shortrecoil"
	self.glock_17.CLIP_AMMO_MAX = 19
	self.glock_17.AMMO_MAX = 152
	self.glock_17.AMMO_PICKUP = self:_pickup_chance(152, 1)
	self:copy_timers("glock_17", "b92fs")
	--self.glock_17.stats.concealment = 30
	--self.glock_17.price = 50*1000
	self:copy_sdescs("x_g17", "glock_17", true)
	self.x_g17.AMMO_MAX = 170
	self.x_g17.AMMO_PICKUP = self:_pickup_chance(170, 1)
	--self.x_g17.stats.concealment = 30
	--self.x_g17.price = self.b92fs.price * 1.5
	self:copy_timers("x_g17", "x_b92fs")



	self.glock_18c.sdesc1 = "caliber_p9x19"
	self.glock_18c.sdesc2 = "action_shortrecoil"
	--self.glock_18c.stats.concealment = 29
	self.glock_18c.fire_mode_data.fire_rate = 60/1100
	self.glock_18c.stats.damage = self.glock_18c.stats.damage - 5
	self.glock_18c.stats.spread = self.glock_18c.stats.spread - 25
	self.glock_18c.CLIP_AMMO_MAX = 19
	self.glock_18c.AMMO_MAX = 152
	self.glock_18c.AMMO_PICKUP = self:_pickup_chance(152, 1)
	self:copy_timers("glock_18c", "b92fs")
	--self.glock_18c.price = 150*1000
	self:copy_sdescs("x_g18c", "glock_18c", true)
	self:copy_stats("x_g18c", "glock_18c", true)
	--self.x_g18c.stats.concealment = 29
	self.x_g18c.AMMO_MAX = 170
	self.x_g18c.AMMO_PICKUP = self:_pickup_chance(170, 1)
	self.x_g18c.BURST_FIRE = nil
	--self.x_g18c.price = self.glock_18c.price * 1.5
	self:copy_timers("x_g18c", "x_b92fs")


	self.pl14.sdesc1 = "caliber_p9x19"
	self.pl14.sdesc2 = "action_shortrecoil"
	self.pl14.CLIP_AMMO_MAX = 15
	self:copy_timers("pl14", "b92fs")
	self.pl14.stats.concealment = 30
	--self.pl14.price = 250*1000
	self:copy_sdescs("x_pl14", "pl14", true)
	self.x_pl14.stats.concealment = 30
	self.x_pl14.CLIP_AMMO_MAX = self.pl14.CLIP_AMMO_MAX * 2
	self.x_pl14.AMMO_MAX = 180
	self.x_pl14.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_pl14.price = self.pl14.price * 1.5
	self:copy_timers("x_pl14", "x_b92fs")

	self.packrat.sdesc1 = "caliber_p9x19"
	self.packrat.sdesc2 = "action_shortrecoil"
	self.packrat.stats.concealment = 30
	self.packrat.CLIP_AMMO_MAX = 15
	self.packrat.not_empty_reload_speed_mult = 1.0
	self.packrat.timers.reload_not_empty = 1.40
	self.packrat.timers.reload_not_empty_end = 0.50 -- 1.52
	self.packrat.empty_reload_speed_mult = 1.0
	self.packrat.timers.reload_empty = 1.90
	self.packrat.timers.reload_empty_end = 0.70 -- 2.08
	--self.packrat.price = 150*1000
	self:copy_sdescs("x_packrat", "packrat", true)
	self.x_packrat.stats.concealment = 30
	self.x_packrat.CLIP_AMMO_MAX = self.packrat.CLIP_AMMO_MAX * 2
	self.x_packrat.AMMO_MAX = 180
	self.x_packrat.AMMO_PICKUP = self:_pickup_chance(180, 1)
	--self.x_packrat.price = self.packrat.price * 1.5
	self:copy_timers("x_packrat", "x_b92fs")


	-- Five-seveN
	self.lemming.sdesc1 = "caliber_p57"
	self.lemming.sdesc2 = "action_blowbackdelayed"
	self.lemming.stats.concealment = 30
	self.lemming.CLIP_AMMO_MAX = 20
	self.lemming.AMMO_MAX = 140
	self.lemming.AMMO_PICKUP = self:_pickup_chance(140, 1)
	self.lemming.can_shoot_through_enemy = false
	self.lemming.can_shoot_through_shield = false
	self.lemming.can_shoot_through_wall = false
	self.lemming.not_empty_reload_speed_mult = 1.0
	--self.lemming.timers.reload_not_empty = 1.50
	self.lemming.timers.reload_not_empty_end = 0.50
	self.lemming.empty_reload_speed_mult = 1.0
	self.lemming.timers.reload_empty = 2.05
	self.lemming.timers.reload_empty_end = 0.60
	--self.lemming.price = 200*1000
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint("lemming", {
			name = "a_ns",
			base_a_obj = "a_ns",
			position = Vector3(0, -0.7, 0),
			rotation = Rotation(0, 0, 0)
		})
	end

	-- M13
	self.legacy.sdesc1 = "caliber_p9x19"
	self.legacy.sdesc2 = "action_blowbackgasdelayed"
	self.legacy.stats.spread = self.legacy.stats.spread - 5
	--self.legacy.stats.concealment = 30
	self.legacy.reload_speed_mult = self.legacy.reload_speed_mult * 1.15
	self.legacy.not_empty_reload_speed_mult = 1.00
	--self.legacy.timers.reload_not_empty = 1.50
	self.legacy.timers.reload_not_empty_end = 0.50
	self.legacy.empty_reload_speed_mult = 1.00
	--self.legacy.timers.reload_empty = 2.15
	self.legacy.timers.reload_empty_end = 0.50
	--self.legacy.price = 50*1000
	self:copy_sdescs("x_legacy", "legacy", true)
	self.x_legacy.stats.concealment = 30
	self.x_legacy.CLIP_AMMO_MAX = self.legacy.CLIP_AMMO_MAX * 2
	self.x_legacy.AMMO_MAX = 182
	self.x_legacy.AMMO_PICKUP = self:_pickup_chance(182, 1)
	--self.x_legacy.price = self.legacy.price * 1.5
	self:copy_timers("x_legacy", "x_b92fs")

	-- baby deagle/jericho
	self:inf_init("sparrow", "pistol", nil)
	self.sparrow.sdesc1 = "caliber_p9x19"
	self.sparrow.sdesc2 = "action_shortrecoil"
	self.sparrow.stats.concealment = 28
	self:copy_timers("sparrow", "b92fs")

	self:inf_init("x_sparrow", "pistol", nil)
	self.x_sparrow.sdesc1 = "caliber_p9x19"
	self.x_sparrow.sdesc2 = "action_shortrecoil"
	self.sparrow.stats.concealment = 27
	self:copy_timers("x_sparrow", "x_b92fs")

	-- Walther PPK/Gruber Kurz
	self.ppk.sdesc1 = "caliber_p32acp"
	self.ppk.sdesc2 = "action_blowbackstraight"
	--self.ppk.stats.concealment = 30
	self.ppk.CLIP_AMMO_MAX = 7
	self:copy_timers("ppk", "b92fs")
	self.ppk.reload_speed_mult = self.ppk.reload_speed_mult * self:convert_reload_to_mult("mag_50")
	--self.ppk.price = 100*1000
	self:copy_sdescs("x_ppk", "ppk", true)
	self.x_ppk.stats.concealment = 30
	self.x_ppk.CLIP_AMMO_MAX = self.ppk.CLIP_AMMO_MAX * 2
	self.x_ppk.AMMO_MAX = 98
	self.x_ppk.AMMO_PICKUP = self:_pickup_chance(98, 1)
	--self.x_ppk.price = self.ppk.price * 1.5
	self:copy_timers("x_ppk", "x_b92fs")
	self.x_ppk.reload_speed_mult = self.x_ppk.reload_speed_mult * self:convert_reload_to_mult("mag_50")


	self.g26.sdesc1 = "caliber_p9x19"
	self.g26.sdesc2 = "action_shortrecoil"
	self.g26.CLIP_AMMO_MAX = 12
	self.g26.AMMO_MAX = 156
	self.g26.AMMO_PICKUP = self:_pickup_chance(156, 1)
	--self.g26.AMMO_MAX = 84
	--self.g26.AMMO_PICKUP = self:_pickup_chance(84, 1)
	self.g26.stats.concealment = 30
	self:copy_timers("g26", "b92fs")
	self.g26.reload_speed_mult = self.g26.reload_speed_mult * self:convert_reload_to_mult("mag_75")
	--self.g26.price = 50*1000
	self:copy_sdescs("jowi", "g26", true)
	self.jowi.stats.concealment = 30
	self.jowi.CLIP_AMMO_MAX = self.g26.CLIP_AMMO_MAX * 2
	--self.jowi.AMMO_MAX = 96
	--self.jowi.AMMO_PICKUP = self:_pickup_chance(96, 1)
	self.jowi.AMMO_MAX = 192
	self.jowi.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.jowi.price = self.g26.price * 1.5
	self:copy_timers("jowi", "x_b92fs")
	self.jowi.reload_speed_mult = self.jowi.reload_speed_mult * self:convert_reload_to_mult("mag_75")


	self.g22c.sdesc1 = "caliber_p40sw"
	self.g22c.sdesc2 = "action_shortrecoil"
	self.g22c.stats.concealment = 29
	self.g22c.CLIP_AMMO_MAX = 17
	self.g22c.AMMO_MAX = 85
	self.g22c.AMMO_PICKUP = self:_pickup_chance(85, 1)
	self:copy_timers("g22c", "b92fs")
	--
	self:copy_sdescs("x_g22c", "g22c", true)
	self.x_g22c.stats.concealment = 29
	self.x_g22c.CLIP_AMMO_MAX = self.g22c.CLIP_AMMO_MAX * 2
	self.x_g22c.AMMO_MAX = 102
	self.x_g22c.AMMO_PICKUP = self:_pickup_chance(102, 1)
	self:copy_timers("x_g22c", "x_b92fs")


	self.usp.sdesc1 = "caliber_p45acp"
	self.usp.sdesc2 = "action_shortrecoil"
	self.usp.stats.concealment = 29
	self.usp.CLIP_AMMO_MAX = 12
	self.usp.AMMO_MAX = 84
	self.usp.AMMO_PICKUP = self:_pickup_chance(84, 1)
	self:copy_timers("usp", "b92fs")
	--
	self:copy_sdescs("x_usp", "usp", true)
	self.x_usp.stats.concealment = 29
	self.x_usp.CLIP_AMMO_MAX = self.usp.CLIP_AMMO_MAX * 2
	self.x_usp.AMMO_MAX = 96
	self.x_usp.AMMO_PICKUP = self:_pickup_chance(96, 1)
	self:copy_timers("x_usp", "x_b92fs")


	self.c96.sdesc1 = "caliber_p763mauser"
	self.c96.sdesc2 = "action_shortrecoil"
	--self.c96.stats.concealment = 28
	self.c96.chamber = 0
	self.c96.clipload = 10
	self.c96.CAN_TOGGLE_FIREMODE = true
	self.c96.sounds.fire_single = "c96_fire" -- necessary to hear firing sounds on auto
	self.c96.reload_speed_mult = self.c96.reload_speed_mult * 1.10
	self.c96.not_empty_reload_speed_mult = 1.50
	self.c96.timers.reload_not_empty = 3.70
	self.c96.timers.reload_not_empty_end = 1.00 -- 2.51
	self.c96.empty_reload_speed_mult = 1.50
	self.c96.timers.reload_empty = 3.70
	self.c96.timers.reload_empty_end = 1.00 -- 2.51
	--
	--self.x_c96.stats.concealment = 28
	self.x_c96.clipload = 10
	self.x_c96.AMMO_MAX = 100
	self.x_c96.AMMO_PICKUP = self:_pickup_chance(100, 1)
	self:copy_sdescs("x_c96", "c96", true)
	self:copy_timers("x_c96", "x_b92fs")
	self.x_c96.reload_speed_mult = self.x_c96.reload_speed_mult * 1.10
	self.x_c96.timers.reload_not_empty_half = 1.80
	self.x_c96.timers.reload_empty_half = 1.80


	self.colt_1911.sdesc1 = "caliber_p45acp"
	self.colt_1911.sdesc2 = "action_shortrecoil"
	--self.colt_1911.stats.concealment = 29
	self.colt_1911.CLIP_AMMO_MAX = 7
	self.colt_1911.AMMO_MAX = 77
	self.colt_1911.AMMO_PICKUP = self:_pickup_chance(77, 1)
	self:copy_timers("colt_1911", "b92fs")
	self.colt_1911.reload_speed_mult = self.colt_1911.reload_speed_mult * self:convert_reload_to_mult("mag_50")
	--
	self:copy_sdescs("x_1911", "colt_1911", true)
	self.x_1911.stats.concealment = 29
	self.x_1911.CLIP_AMMO_MAX = self.colt_1911.CLIP_AMMO_MAX * 2
	self.x_1911.AMMO_MAX = 98
	self.x_1911.AMMO_PICKUP = self:_pickup_chance(98, 1)
	self:copy_timers("x_1911", "x_b92fs")
	self.x_1911.reload_speed_mult = self.x_1911.reload_speed_mult * self:convert_reload_to_mult("mag_50")


	-- Crosskill Guard
	self.shrew.sdesc1 = "caliber_p45acp"
	self.shrew.sdesc2 = "action_shortrecoil"
	--self.shrew.stats.concealment = 30
	self.shrew.CLIP_AMMO_MAX = 7
	self:copy_timers("shrew", "b92fs")
	self.shrew.reload_speed_mult = self.shrew.reload_speed_mult * self:convert_reload_to_mult("mag_50") * 0.95
	--
	self:copy_sdescs("x_shrew", "shrew", true)
	--self.x_shrew.stats.concealment = 30
	self.x_shrew.CLIP_AMMO_MAX = self.shrew.CLIP_AMMO_MAX * 2
	self.x_shrew.AMMO_MAX = 98
	self.x_shrew.AMMO_PICKUP = self:_pickup_chance(98, 1)
	self:copy_timers("x_shrew", "x_b92fs")
	self.x_shrew.reload_speed_mult = self.x_shrew.reload_speed_mult * self:convert_reload_to_mult("mag_50") * 0.95

	-- Crosskill chunky compact (why does this even exist)
	self:inf_init("m1911", "pistol", "medium")
	self:copy_stats("m1911", "colt_1911")
	self:copy_sdescs("m1911", "colt_1911")
	self:copy_timers("m1911", "colt_1911")

	self:inf_init("x_m1911", "pistol", "medium")
	self:copy_stats("x_m1911", "x_1911")
	self:copy_sdescs("x_m1911", "x_1911")
	self:copy_timers("x_m1911", "x_1911")

	self.hs2000.sdesc1 = "caliber_p45acp"
	self.hs2000.sdesc2 = "action_shortrecoil"
	--self.hs2000.stats.concealment = 29
	self.hs2000.CLIP_AMMO_MAX = 13
	self.hs2000.AMMO_MAX = 78
	self.hs2000.AMMO_PICKUP = self:_pickup_chance(78, 1)
	self:copy_timers("hs2000", "b92fs")
	--
	self:copy_sdescs("x_hs2000", "hs2000", true)
	--self.x_hs2000.stats.concealment = 29
	self.x_hs2000.CLIP_AMMO_MAX = self.hs2000.CLIP_AMMO_MAX * 2
	self.x_hs2000.AMMO_MAX = 91
	self.x_hs2000.AMMO_PICKUP = self:_pickup_chance(91, 1)
	self:copy_timers("x_hs2000", "x_b92fs")


	self.p226.sdesc1 = "caliber_p40sw"
	self.p226.sdesc2 = "action_shortrecoil"
	--self.p226.stats.concealment = 29
	self.p226.CLIP_AMMO_MAX = 13
	self.p226.AMMO_MAX = 78
	self.p226.AMMO_PICKUP = self:_pickup_chance(78, 1)
	self:copy_timers("p226", "b92fs")
	--
	self:copy_sdescs("x_p226", "p226", true)
	--self.x_p226.stats.concealment = 20
	self.x_p226.CLIP_AMMO_MAX = self.p226.CLIP_AMMO_MAX * 2
	self.x_p226.AMMO_MAX = 91
	self.x_p226.AMMO_PICKUP = self:_pickup_chance(91, 1)
	self:copy_timers("x_p226", "x_b92fs")


	-- parabellum/luger
	self.breech.sdesc1 = "caliber_p9x19"
	self.breech.sdesc2 = "action_shortrecoilluger"
	--self.breech.stats.concealment = 29
	self.breech.not_empty_reload_speed_mult = self:convert_reload_to_mult("mag_50")
	self.breech.timers.reload_not_empty = 1.33
	self.breech.timers.reload_not_empty_end = 0.50
	self.breech.empty_reload_speed_mult = self:convert_reload_to_mult("mag_50")
	self.breech.timers.reload_empty = 1.80
	self.breech.timers.reload_empty_end = 0.70
	--
	self:copy_sdescs("x_breech", "breech", true)
	--self.x_breech.stats.concealment = 29
	self.x_breech.CLIP_AMMO_MAX = self.breech.CLIP_AMMO_MAX * 2
	self.x_breech.AMMO_MAX = 100
	self.x_breech.AMMO_PICKUP = self:_pickup_chance(100, 1)
	self:copy_timers("x_breech", "x_b92fs")
	self.x_breech.reload_speed_mult = self.x_breech.reload_speed_mult * self:convert_reload_to_mult("mag_50")


	self.deagle.sdesc1 = "caliber_p50ae"
	self.deagle.sdesc2 = "action_gas"
	--self.deagle.stats.concealment = 28
	self.deagle.CLIP_AMMO_MAX = 7
	self.deagle.not_empty_reload_speed_mult = 1.20
	--self.deagle.timers.reload_not_empty = 1.85
	self.deagle.timers.reload_not_empty_end = 0.60 -- 1.63
	self.deagle.empty_reload_speed_mult = 1.20
	self.deagle.timers.reload_empty = 2.70
	self.deagle.timers.reload_empty_end = 1.00 -- 2.47
	--
	self:copy_sdescs("x_deagle", "deagle", true)
	--self.x_deagle.stats.concealment = 28
	self.x_deagle.CLIP_AMMO_MAX = self.deagle.CLIP_AMMO_MAX * 2
	self.x_deagle.AMMO_MAX = 42
	self.x_deagle.AMMO_PICKUP = self:_pickup_chance(42, 1)
	self:copy_timers("x_deagle", "x_b92fs")


	self.new_raging_bull.sdesc1 = "caliber_p44"
	self.new_raging_bull.sdesc2 = "action_dasa"
	self.new_raging_bull.stats.concealment = 28
	self.new_raging_bull.chamber = 0
	self.new_raging_bull.not_empty_reload_speed_mult = 1.0
	self.new_raging_bull.timers.reload_not_empty = 2.15
	self.new_raging_bull.timers.reload_not_empty_end = 0.30 -- 1.96
	self.new_raging_bull.empty_reload_speed_mult = 1.0
	self.new_raging_bull.timers.reload_empty = 2.15
	self.new_raging_bull.timers.reload_empty_end = 0.30 -- 1.96
	--
	self:copy_sdescs("x_rage", "new_raging_bull", true)
	self.x_rage.stats.concealment = 28
	self.x_rage.chamber = 0
	self.x_rage.CLIP_AMMO_MAX = self.new_raging_bull.CLIP_AMMO_MAX * 2
	self.x_rage.AMMO_MAX = 48
	self.x_rage.AMMO_PICKUP = self:_pickup_chance(48, 1)
	self.x_rage.not_empty_reload_speed_mult = self.x_b92fs.not_empty_reload_speed_mult * 1.10
	self.x_rage.timers.reload_not_empty = 3.00
	self.x_rage.timers.reload_not_empty_half = 2.70
	self.x_rage.timers.reload_not_empty_end = 1.30
	self.x_rage.empty_reload_speed_mult = self.x_b92fs.not_empty_reload_speed_mult * 1.10
	self.x_rage.timers.reload_empty = 3.00
	self.x_rage.timers.reload_empty_half = 2.70
	self.x_rage.timers.reload_empty_end = 1.40


	self.mateba.sdesc1 = "caliber_p357"
	self.mateba.sdesc2 = "action_dasa"
	self.mateba.stats.concealment = 28
	self.mateba.chamber = 0
	self.mateba.not_empty_reload_speed_mult = 1.65
	self.mateba.timers.reload_not_empty = 3.30
	self.mateba.timers.reload_not_empty_end = 0.80 -- 2.48
	self.mateba.empty_reload_speed_mult = 1.65
	self.mateba.timers.reload_empty = 3.30
	self.mateba.timers.reload_empty_end = 0.80 -- 2.48
	--
	self:copy_sdescs("x_2006m", "mateba", true)
	self.x_2006m.stats.concealment = 28
	self.x_2006m.chamber = 0
	self.x_2006m.CLIP_AMMO_MAX = self.mateba.CLIP_AMMO_MAX * 2
	self.x_2006m.AMMO_MAX = 48
	self.x_2006m.AMMO_PICKUP = self:_pickup_chance(48, 1)
	self.x_2006m.not_empty_reload_speed_mult = self.x_b92fs.not_empty_reload_speed_mult
	self.x_2006m.timers.reload_not_empty = self.x_b92fs.timers.reload_not_empty
	self.x_2006m.timers.reload_not_empty_half = self.x_rage.timers.reload_not_empty_half - 0.30
	self.x_2006m.timers.reload_not_empty_end = 1.50
	self.x_2006m.empty_reload_speed_mult = self.x_b92fs.empty_reload_speed_mult
	self.x_2006m.timers.reload_empty = self.x_b92fs.timers.reload_empty
	self.x_2006m.timers.reload_empty_half = self.x_rage.timers.reload_empty_half - 0.20
	self.x_2006m.timers.reload_empty_end = self.x_b92fs.timers.reload_empty_end


	-- castigo
	self.chinchilla.sdesc1 = "caliber_p44"
	self.chinchilla.sdesc2 = "action_da"
	--self.chinchilla.stats.concealment = 28
	self.chinchilla.chamber = 0
	self.chinchilla.not_empty_reload_speed_mult = 1.25
	self.chinchilla.timers.reload_not_empty = 2.80
	self.chinchilla.timers.reload_not_empty_end = 0.50 -- 2.11
	self.chinchilla.empty_reload_speed_mult = 1.25
	self.chinchilla.timers.reload_empty = 2.80
	self.chinchilla.timers.reload_empty_end = 0.50 -- 2.11
	--
	self:copy_sdescs("x_chinchilla", "chinchilla", true)
	--self.x_chinchilla.stats.concealment = 28
	self.x_chinchilla.chamber = 0
	self.x_chinchilla.CLIP_AMMO_MAX = self.chinchilla.CLIP_AMMO_MAX * 2
	self.x_chinchilla.AMMO_MAX = 48
	self.x_chinchilla.AMMO_PICKUP = self:_pickup_chance(48, 1)
	self.x_chinchilla.not_empty_reload_speed_mult = self.x_b92fs.not_empty_reload_speed_mult
	self.x_chinchilla.timers.reload_not_empty = 3.40
	self.x_chinchilla.timers.reload_not_empty_half = nil
	self.x_chinchilla.timers.reload_not_empty_end = 0.50
	self.x_chinchilla.empty_reload_speed_mult = self.x_b92fs.not_empty_reload_speed_mult
	self.x_chinchilla.timers.reload_empty = 3.40
	self.x_chinchilla.timers.reload_empty_half = nil
	self.x_chinchilla.timers.reload_empty_end = 0.50

	-- Peacemaker
	self.peacemaker.sdesc1 = "caliber_p45lc"
	self.peacemaker.sdesc2 = "action_sa"
	self.peacemaker.stats.concealment = 28
	self.peacemaker.chamber = 0
	self.peacemaker.stats.damage = 56 -- 280
	self.peacemaker.stats.recoil = self.peacemaker.stats.recoil - 20
	self.peacemaker.fire_mode_data.fire_rate = 60/180
	self.peacemaker.anim_speed_mult = 0.80
	self.peacemaker.reload_speed_mult = self.peacemaker.reload_speed_mult * 1.25
	self.peacemaker.AMMO_MAX = 30
	self.peacemaker.AMMO_PICKUP = self:_pickup_chance(30, 1)
	self.peacemaker.timers.shotgun_reload_exit_empty = 0.50
	self.peacemaker.timers.shotgun_reload_exit_not_empty = 0.50
	self.peacemaker.timers.shell_reload_early = 0.50
	self.peacemaker.timers.shotgun_reload_enter_mult = 1.25
	if not self.peacemaker.stats_modifiers then
		self.peacemaker.stats_modifiers = {}
	end
	self.peacemaker.stats_modifiers.damage = 5

	-- Model 3 revolver
	self:inf_init("model3", "pistol", "heavy")
	self.model3.sdesc1 = "caliber_p44russian"
	self.model3.sdesc2 = "action_sa"
	self.model3.chamber = 0
	self:copy_stats("model3", "new_raging_bull")
	self:copy_timers("model3", "new_raging_bull")

	self:inf_init("x_model3", "pistol", "heavy")
	self.x_model3.sdesc1 = "caliber_p44russian"
	self.x_model3.sdesc2 = "action_sa"
	self.x_model3.chamber = 0
	self:copy_stats("x_model3", "x_rage")
	self:copy_timers("x_model3", "x_rage")

	-- Igor/Stechkin
	self.stech.sdesc1 = "caliber_p9x19"
	self.stech.sdesc2 = "action_blowback"
	self.stech.CLIP_AMMO_MAX = 20
	self.stech.AMMO_MAX = 160
	self.stech.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self.stech.fire_mode_data.fire_rate = 60/750
	self:copy_timers("stech", "b92fs")

	self.x_stech.sdesc1 = "caliber_p9x19"
	self.x_stech.sdesc2 = "action_blowback"
	self.x_stech.CLIP_AMMO_MAX = 40
	self.x_stech.AMMO_MAX = 180
	self.x_stech.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self.x_stech.fire_mode_data.fire_rate = 60/750
	self:copy_timers("x_stech", "x_b92fs")
	
	-- Hudson H9/Holt
	self.holt.sdesc1 = "caliber_p9x19"
	self.holt.sdesc2 = "action_shortrecoil"
	self.holt.CLIP_AMMO_MAX = 15
	self.holt.AMMO_MAX = 150
	self.holt.AMMO_PICKUP = self:_pickup_chance(150, 1)
	self:copy_timers("holt", "b92fs")
	
	self.x_holt.sdesc1 = "caliber_p9x19"
	self.x_holt.sdesc2 = "action_shortrecoil"
	self.x_holt.CLIP_AMMO_MAX = 30
	self.x_holt.AMMO_MAX = 180
	self.x_holt.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self:copy_timers("x_holt", "x_b92fs")

	-- CZ-75
	self:inf_init("czech", "pistol", nil)
	self.czech.sdesc1 = "caliber_p9x19"
	self.czech.sdesc2 = "action_shortrecoil"
	self:copy_timers("czech", "b92fs")
	self.czech.stats.concealment = 30
	self.czech.AMMO_MAX = 144
	self.czech.AMMO_PICKUP = self:_pickup_chance(144, 1)
	self.czech.fire_mode_data.fire_rate = 60/1000

	self:inf_init("x_czech", "pistol", nil)
	self:copy_sdescs("x_czech", "czech", true)
	self.x_czech.stats.concealment = 30
	self.x_czech.AMMO_MAX = 180
	self.x_czech.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self.x_czech.fire_mode_data.fire_rate = 60/1000
	self:copy_timers("x_czech", "x_b92fs")


	-- Type 54 (model 54), cheap chink copy of the TT-33
	-- Apparently the ingame one is actually a TT-33, even though Overkill calls it the Type 54? Let's say it's a TT-33 then.
	self:inf_init("type54", "pistol", "medium")
	self.type54.sdesc1 = "caliber_p762x25"
	self.type54.sdesc2 = "action_shortrecoil"
	self:copy_timers("type54", "b92fs")

	-- TT-33 underbarrel :(
	self.type54_underbarrel.DAMAGE = nil
	self.type54_underbarrel.ignore_crit_damage = false
	self.type54_underbarrel.ignore_damage_multipliers = false
	self.type54_underbarrel.ignore_damage_upgrades = false
	self:inf_init("type54_underbarrel", "shotgun", {"rof_slow", "range_slowpump", "is_underbarrel"})
	self:copy_timers("type54_underbarrel", "judge")
	self.type54_underbarrel.timers.reload_not_empty = 1.78
	self.type54_underbarrel.timers.reload_empty = 1.78
	self.type54_underbarrel.timers.unequip = 0.6
	self.type54_underbarrel.timers.equip = 0.6
	self.type54_underbarrel.timers.equip_underbarrel = 0.4
	self.type54_underbarrel.timers.unequip_underbarrel = 0.4



	-- Akimbo TT-33
	self:inf_init("x_type54", "pistol", "medium")
	self:copy_sdescs("x_type54", "type54", true)
	self.x_type54.AMMO_MAX = 100
	self:copy_timers("x_type54", "x_b92fs")

	-- Please stop
	self.x_type54_underbarrel.DAMAGE = nil
	self.x_type54_underbarrel.ignore_crit_damage = false
	self.x_type54_underbarrel.ignore_damage_multipliers = false
	self.x_type54_underbarrel.ignore_damage_upgrades = false
	self:inf_init("x_type54_underbarrel", "shotgun", {"rof_slow", "range_slowpump", "is_underbarrel"})
	self.x_type54_underbarrel.AMMO_MAX = 10
	self:copy_timers("x_type54_underbarrel", "x_judge")
	self.x_type54_underbarrel.timers.reload_not_empty = 3
	self.x_type54_underbarrel.timers.reload_empty = 3
	self.x_type54_underbarrel.timers.unequip = 0.5
	self.x_type54_underbarrel.timers.equip = 0.5
	self.x_type54_underbarrel.timers.reload_not_empty_half = 2.5
	self.x_type54_underbarrel.timers.reload_empty_half = 2.5

	-- RSh-12
	self:inf_init("rsh12", "pistol", "heavy")
	self.rsh12.sdesc1 = "caliber_r127x55sts130"
	self.rsh12.sdesc2 = "action_da"
	self.rsh12.chamber = 0
	self:copy_timers("rsh12", "new_raging_bull")


	-- Joceline O/U
	self.b682.sdesc1 = "caliber_s12g"
	self.b682.sdesc2 = "action_breakou"
	self.b682.stats.spread = self.b682.stats.spread + 10
	self.b682.stats.concealment = 21
	self.b682.shake.fire_steelsight_multiplier = 0.25 -- fucking grip puts the hand in the way
	self.b682.reload_speed_mult = self.b682.reload_speed_mult * 0.90
	self.b682.not_empty_reload_speed_mult = 1.00
	self.b682.timers.reload_not_empty = 1.90
	self.b682.timers.reload_not_empty_end = 1.30 -- 2.9
	self.b682.empty_reload_speed_mult = 1.00
	self.b682.timers.reload_empty = 1.90
	self.b682.timers.reload_empty_end = 1.30 -- 2.9
	self.b682.reload_stance_mod = {ads = {translation = Vector3(5, -5, -5), rotation = Rotation(0, 0, 0)}}
	--self.b682.price = 500*1000


	self.huntsman.sdesc1 = "caliber_s12g"
	self.huntsman.sdesc2 = "action_breaksxs"
	self.huntsman.stats.spread = self.huntsman.stats.spread - 5
	self.huntsman.stats.concealment = 21
	self.huntsman.anim_speed_mult = 1.25
	self.huntsman.not_empty_reload_speed_mult = 1.00
	self.huntsman.timers.reload_not_empty = 2.00
	self.huntsman.timers.reload_not_empty_end = 0.80 -- 2.80
	self.huntsman.empty_reload_speed_mult = 1.00
	self.huntsman.timers.reload_empty = 2.00
	self.huntsman.timers.reload_empty_end = 0.80 -- 2.80
	self.huntsman.reload_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	--self.huntsman.price = 400*1000


	-- claire
	self.coach.sdesc1 = "caliber_s12g"
	self.coach.sdesc2 = "action_breaksxs"
	self.coach.stats.spread = self.coach.stats.spread - 5
	self.coach.stats.concealment = 21
	self.coach.AMMO_MAX = 22
	self.coach.AMMO_PICKUP = self:_pickup_chance(22, 1)
	self.coach.anim_speed_mult = 1.50
	self.coach.not_empty_reload_speed_mult = 0.90
	self.coach.timers.reload_not_empty = 1.60
	self.coach.timers.reload_not_empty_end = 1.00
	self.coach.empty_reload_speed_mult = 0.90
	self.coach.timers.reload_empty = 1.60
	self.coach.timers.reload_empty_end = 1.00
	--self.coach.price = 200*1000
	self:inf_init("coachprimary", "shotgun", {"dmg_heavy", "rof_db"})
	self:copy_sdescs("coachprimary", "coach")
	self:copy_stats("coachprimary", "coach")
	self.coachprimary.stats.concealment = 21
	self.coachprimary.AMMO_MAX = 28
	self.coachprimary.AMMO_PICKUP = self:_pickup_chance(28, 1)
	self:copy_timers("coachprimary", "coach")


	self.saiga.sdesc1 = "caliber_s12g"
	self.saiga.sdesc2 = "action_gas"
	self.saiga.FIRE_MODE = "single"
	self.saiga.stats.concealment = 19
	--self.saiga.CAN_TOGGLE_FIREMODE = false
	self.saiga.fire_mode_data = {fire_rate = 60/700} -- good luck hitting anything outside of hugging range, dipshit
	self.saiga.AMMO_MAX = 49
	self.saiga.AMMO_PICKUP = self:_pickup_chance(49, 1)
	self.saiga.not_empty_reload_speed_mult = 1.00
	self.saiga.timers.reload_not_empty = 2.65
	self.saiga.timers.reload_not_empty_end = 0.60 -- 2.83
	self.saiga.empty_reload_speed_mult = 1.15
	self.saiga.timers.reload_empty = 3.70
	self.saiga.timers.reload_empty_end = 1.00 -- 3.62
	--self.saiga.price = 150*1000


	self.benelli.sdesc1 = "caliber_s12g"
	self.benelli.sdesc2 = "action_gas"
	self.benelli.stats.concealment = 21
	self.benelli.anim_speed_mult = 1.50
	self.benelli.AMMO_MAX = 48
	self.benelli.AMMO_PICKUP = self:_pickup_chance(48, 1)
	self.benelli.reload_speed_mult = self.benelli.reload_speed_mult * 1
	self.benelli.CLIP_AMMO_MAX = 6
	--self.benelli.price = 150*1000
	self.benelli.timers.equip = 0.60
	self.benelli.timers.unequip = 0.60
	self.benelli.timers.shotgun_reload_exit_empty = 1.20
	self.benelli.timers.shell_reload_early = 0.10


	--self.spas12.price = 250*1000
	self.spas12.sdesc1 = "caliber_s12g"
	self.spas12.sdesc2 = "action_gas"
	self.spas12.stats.concealment = 20
	self.spas12.timers.equip = 0.60
	self.spas12.timers.unequip = 0.60
	self.spas12.timers.shotgun_reload_exit_empty = 1.20
	self.spas12.timers.shell_reload_early = 0.10


	self.ksg.sdesc1 = "caliber_s12g"
	self.ksg.sdesc2 = "action_pump"
	self.ksg.stats.concealment = 23
	self.ksg.AMMO_MAX = 42
	self.ksg.AMMO_PICKUP = self:_pickup_chance(42, 1)
	self.ksg.reload_speed_mult = self.ksg.reload_speed_mult * 0.90
	self.ksg.reload_stance_mod = {ads = {translation = Vector3(5, 5, -5), rotation = Rotation(0, 0, 0)}}
	self.ksg.fire_mode_data.fire_rate = 60/105
	--self.ksg.price = 100*1000
	self.ksg.timers.shell_reload_early = 0.10


	self.aa12.sdesc1 = "caliber_s12g"
	self.aa12.sdesc2 = "action_blowbackapi"
	self.aa12.chamber = 0
	self.aa12.stats.concealment = 23
	--self.aa12.FIRE_MODE = "single"
	self.aa12.CAN_TOGGLE_FIREMODE = false
	self.aa12.fire_mode_data = {fire_rate = 60/360}
	--self.aa12.fire_mode_data.fire_rate = 0.20
	self.aa12.not_empty_reload_speed_mult = 1.10
	self.aa12.timers.reload_not_empty = 3.00
	self.aa12.timers.reload_not_empty_end = 0.60 -- 2.90/-30% 4.14
	self.aa12.empty_reload_speed_mult = 1.15
	self.aa12.timers.reload_empty = 3.8
	self.aa12.timers.reload_empty_end = 1.00 -- 3.69/5.27
	self.aa12.equip_stance_mod = {ads = {translation = Vector3(3, 0, -3), rotation = Rotation(0, 0, 0)}}
	self.aa12.reload_stance_mod = {ads = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 10, 0)}}
	--self.aa12.price = 250*1000


	-- BREAKER
	self.boot.sdesc1 = "caliber_s12g1887"
	self.boot.sdesc2 = "action_lever"
	self.boot.stats.concealment = 24
	self.boot.CLIP_AMMO_MAX = 5
	self.boot.AMMO_MAX = 40
	self.boot.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self.boot.anim_speed_mult = 1.50
	self.boot.stats.spread = self.boot.stats.spread - 20
	--self.boot.reload_speed_mult = self.boot.reload_speed_mult * 0.80
	--self.boot.price = 100*1000
	self.boot.ads_uses_hipfire_anim = true
	self.boot.ads_anim_speed_mult = 1.20
	self.boot.timers.shotgun_reload_exit_not_empty = 0.50
	self.boot.timers.shotgun_reload_exit_empty = 0.80
	self.boot.timers.shell_reload_early = 0.30
	self.boot.timers.shotgun_reload_shell = 0.57
	self.boot.timers.shotgun_reload_enter_mult = 1.25
	--self.boot.timers.shotgun_reload_exit_empty_mult = 0.80
	self.boot.equip_speed_mult = 1.40
	self.boot.equip_stance_mod = {ads = {translation = Vector3(2, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.boot.reload_stance_mod = {ads = {translation = Vector3(8, 5, -5), rotation = Rotation(0, 10, 0)}}
	--self.boot.offhand_reload_speed_mult = 0.567/0.33 -- the fucking reload timers on this gun cause me trouble without end
	self.boot.shell_by_shell_loop_speed_mult = 1/(0.567/0.33)


	self.r870.sdesc1 = "caliber_s12g"
	self.r870.sdesc2 = "action_pump"
	self.r870.stats.spread = self.r870.stats.spread + 10
	self.r870.stats.concealment = 20
	--self.r870.fire_mode_data.fire_rate = 0.60
	--self.r870.single.fire_rate = 0.60
	self.r870.CLIP_AMMO_MAX = 8
	self.r870.AMMO_MAX = 40
	self.r870.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self.r870.anim_speed_mult = 0.80
	--self.r870.price = 150*1000
	self.r870.timers.shotgun_reload_enter = 0.3
	self.r870.timers.shotgun_reload_shell = 0.5666666666666667
	self.r870.timers.shotgun_reload_first_shell_offset = self.r870.timers.shotgun_reload_shell - 0.33
	self.r870.timers.shotgun_reload_exit_not_empty = 0.3
	self.r870.timers.shotgun_reload_exit_empty = 0.7
	self.r870.timers.shell_reload_early = 0.10
	self.r870.timers.equip = 0.70
	self.r870.timers.unequip = 0.70


	self.serbu.sdesc1 = "caliber_s12g"
	self.serbu.sdesc2 = "action_pump"
	self.serbu.stats.spread = self.serbu.stats.spread - 20
	self.serbu.stats.concealment = 24
	--self.serbu.fire_mode_data.fire_rate = 0.50
	--self.serbu.single.fire_rate = 0.50
	self.serbu.CLIP_AMMO_MAX = 4
	self.serbu.AMMO_MAX = 28
	self.serbu.AMMO_PICKUP = self:_pickup_chance(28, 1)
	self.serbu.anim_speed_mult = 0.90
	--self.serbu.price = 150*1000
	self.serbu.timers.unequip = 0.60
	self.serbu.timers.shell_reload_early = 0.10
	--[[
	self.serbu.shotgun_ammo_stance_mod = {
		hip = {
			{translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, -100), speed = 5},
			{translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, -80), speed = 5},
			{translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, -60), speed = 5},
			{translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, -40), speed = 5},
			{translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, -20), speed = 5}
		},
		ads = {
			{translation = Vector3(-5, 0, 0), rotation = Rotation(0, 0, 0), speed = 5},
			{translation = Vector3(5, 0, 0), rotation = Rotation(0, 0, 0), speed = 5},
			{translation = Vector3(-5, 0, 0), rotation = Rotation(0, 0, 0), speed = 5},
			{translation = Vector3(5, 0, 0), rotation = Rotation(0, 0, 0), speed = 5},
			{translation = Vector3(-5, 0, 0), rotation = Rotation(0, 0, 0), speed = 5}
		}
	}
	--]]


	self.m37.sdesc1 = "caliber_s12g"
	self.m37.sdesc2 = "action_pump"
	self.m37.stats.spread = self.m37.stats.spread + 10
	self.m37.stats.concealment = 21
	self.m37.anim_speed_mult = 1.20
	self.m37.CLIP_AMMO_MAX = 4
	self.m37.AMMO_MAX = 24
	self.m37.AMMO_PICKUP = self:_pickup_chance(24, 1)
	self.m37.equip_stance_mod = {ads = {translation = Vector3(2, -4, -3), rotation = Rotation(0, 0, 0)}}
	--self.m37.price = 100*1000
	self.m37.equip_speed_mult = 1.60
	self.m37.reload_speed_mult = self.m37.reload_speed_mult * 1.20 --1.10
	self.m37.timers.equip = 1.00
	self.m37.timers.unequip = 0.60
	self.m37.timers.shell_reload_early = 0.15
	self.m37.timers.shotgun_reload_exit_not_empty = 0.8
	self.m37.timers.shotgun_reload_exit_empty_mult = 0.80
	self:inf_init("m37primary", "shotgun", {"rof_slow", "range_slowpump"})
	self:copy_sdescs("m37primary", "m37")
	self:copy_stats("m37primary", "m37")
	self:copy_timers("m37primary", "m37")
	--self.m37primary.AMMO_MAX = 180
	--self.m37primary.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self.m37primary.stats.concealment = 21
	self.m37primary.animations = self.m37primary.animations or {}
	self.m37primary.animations.reload_shell_by_shell = true
	if self.SetupAttachmentPoint then
		self:SetupAttachmentPoint( "m37primary", {
			name = "a_b_slayer",
			base_a_obj = "a_b",
			position = Vector3( 0, 15, 0 ),
		})
	end


	self.striker.sdesc1 = "caliber_s12g"
	self.striker.sdesc2 = "action_da"
	self.striker.chamber = 0
	self.striker.stats.spread = self.striker.stats.spread - 15
	self.striker.stats.concealment = 24
	--self.striker.fire_mode_data.fire_rate = 0.10
	--self.striker.single.fire_rate = 0.10
	self.striker.AMMO_MAX = 36
	self.striker.AMMO_PICKUP = self:_pickup_chance(36, 1)
	--self.striker.price = 150*1000
	self.striker.timers.shell_reload_early = 0.20


	-- goliath
	self.rota.sdesc1 = "caliber_s12g"
	self.rota.sdesc2 = "action_da"
	self.rota.stats.concealment = 23
	self.rota.chamber = 0
	--self.rota.fire_mode_data.fire_rate = 0.20
	--self.rota.single.fire_rate = 0.20
	self.rota.AMMO_MAX = 36
	self.rota.AMMO_PICKUP = self:_pickup_chance(36, 1)
	self.rota.reload_speed_mult = self.rota.reload_speed_mult * 0.85
	self.rota.timers.reload_not_empty = 2.50
	self.rota.timers.reload_not_empty_end = 0.50 -- 3.00
	self.rota.timers.reload_empty = 2.50
	self.rota.timers.reload_empty_end = 0.50 -- 3.00
	self.rota.equip_stance_mod = {ads = {translation = Vector3(5, -5, -3), rotation = Rotation(0, 0, 0)}}
	self.rota.reload_stance_mod = {ads = {translation = Vector3(5, -8, -5), rotation = Rotation(0, 0, 0)}}
	--self.rota.price = 200*1000
	self:copy_sdescs("x_rota", "rota", true)
	self.x_rota.AMMO_MAX = 48
	self.x_rota.AMMO_PICKUP = self:_pickup_chance(48, 1)
	--self.x_rota.price = self.rota.price * 1.5
	self:copy_timers("x_rota", "x_tec9")
	self.x_rota.stats.concealment = 23
	self.x_rota.empty_reload_speed_mult = self.x_tec9.empty_reload_speed_mult * 0.85
	self.x_rota.timers.reload_empty = self.x_tec9.timers.reload_empty - 0.60
	self.x_rota.timers.reload_empty_half = self.x_tec9.timers.reload_empty_half - 0.60


	-- GRIMMS
	self.basset.sdesc1 = "caliber_s12g"
	self.basset.sdesc2 = "action_gas"
	self.basset.stats.concealment = 22
	self.basset.CLIP_AMMO_MAX = 7
	self.basset.AMMO_MAX = 35
	self.basset.AMMO_PICKUP = self:_pickup_chance(35, 1)
	self.basset.not_empty_reload_speed_mult = 0.80
	self.basset.timers.reload_not_empty = 2.10
	self.basset.timers.reload_not_empty_end = 0.50 -- 2.89
	self.basset.empty_reload_speed_mult = 0.80
	self.basset.timers.reload_empty = 2.60
	self.basset.timers.reload_empty_end = 0.50 -- 3.44
	--self.basset.price = 150*1000
	self.basset.CAN_TOGGLE_FIREMODE = false
	self.basset.FIRE_MODE = "single"
	--
	self:copy_sdescs("x_basset", "basset", true)
	self.x_basset.stats.concealment = 22
	self.x_basset.BURST_FIRE = false
	self.x_basset.CLIP_AMMO_MAX = self.basset.CLIP_AMMO_MAX * 2
	self.x_basset.AMMO_MAX = 42
	self.x_basset.AMMO_PICKUP = self:_pickup_chance(42, 1)
	self.x_basset.CAN_TOGGLE_FIREMODE = false
	self.x_basset.FIRE_MODE = "single"
	self.x_basset.BURST_FIRE = 2
	--self.x_basset.price = self.basset.price * 1.5
	self:copy_timers("x_basset", "x_tec9")


	self.judge.sdesc1 = "caliber_s410"
	self.judge.sdesc2 = "action_da"
	--self.judge.stats.concealment = 29
	self.judge.chamber = 0
	self.judge.AMMO_MAX = 40
	self.judge.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self.judge.stats.spread = self.judge.stats.spread - 20
	self.judge.not_empty_reload_speed_mult = 1.00
	self.judge.timers.reload_not_empty = 1.80
	self.judge.timers.reload_not_empty_end = 0.70 -- 2.50
	self.judge.empty_reload_speed_mult = 1.00
	self.judge.timers.reload_empty = 1.80
	self.judge.timers.reload_empty_end = 0.70 -- 2.50
	--self.judge.price = 150*1000
	self:copy_sdescs("x_judge", "judge", true)
	self.x_judge.stats.concealment = 29
	self.x_judge.chamber = 0
	self.x_judge.stats.spread = self.judge.stats.spread
	self.x_judge.AMMO_MAX = 50
	self.x_judge.AMMO_PICKUP = self:_pickup_chance(50, 1)
	--self.judge.price = self.judge.price * 1.5
	self:copy_timers("x_judge", "x_b92fs")
	self.x_judge.timers.reload_not_empty_end = 1.50
	self.x_judge.timers.reload_empty_half = self.x_b92fs.timers.reload_empty_half - 0.20

	-- Winchester 1897
	self:inf_init("m1897", "shotgun", {"rof_slow", "range_slowpump"})
	self.m1897.sdesc1 = "caliber_s12g"
	self.m1897.sdesc2 = "action_pump"
	self.m1897.CLIP_AMMO_MAX = 5
	self.m1897.AMMO_MAX = 40
	self.m1897.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self.m1897.stats.spread = self.m1897.stats.spread + 10
	self.m1897.stats.concealment = 24
	self:copy_timers("m1897", "m37")

	-- Mossberg 590 (Mosconi 12G Tactical Shotgun)
	self:inf_init("m590", "shotgun", {"rof_slow", "range_slowpump"})
	self.m590.sdesc1 = "caliber_s12g"
	self.m590.sdesc2 = "action_pump"
	self.m590.stats.spread = self.m590.stats.spread + 10
	self.m590.AMMO_MAX = 40
	self.m590.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self:copy_timers("m590", "r870")
	self.m590.stats.concealment = 21


	self.tecci.sdesc1 = "caliber_r556x45"
	self.tecci.sdesc2 = "action_pistonshort"
	self.tecci.stats.concealment = 18
	self.tecci.fire_mode_data.fire_rate = 60/700
	self.tecci.AMMO_MAX = 200
	self.tecci.AMMO_PICKUP = self:_pickup_chance(200, 1)
	self.tecci.equip_speed_mult = 1.5
	self.tecci.not_empty_reload_speed_mult = 2 * self:convert_reload_to_mult("mag_300")
	--self.tecci.timers.reload_not_empty = 3.80
	self.tecci.timers.reload_not_empty_end = 1.00 -- 
	self.tecci.empty_reload_speed_mult = 1.9 * self:convert_reload_to_mult("mag_300")
	--self.tecci.timers.reload_empty = 4.70
	self.tecci.timers.reload_empty_end = 1.00 -- 



	self.rpk.sdesc1 = "caliber_r762x39"
	self.rpk.sdesc2 = "action_gaslong"
	self.rpk.stats.concealment = 13
	self.rpk.chamber = 1
	self.rpk.fire_mode_data.fire_rate = 60/600
	self.rpk.stats.spread = self.rpk.stats.spread + 10
	self.rpk.stats.recoil = self.rpk.stats.recoil + 5
	self.rpk.CLIP_AMMO_MAX = 75
	self.rpk.taser_reload_amount = 50
	self.rpk.AMMO_MAX = 300
	self.rpk.AMMO_PICKUP = self:_pickup_chance(225, 1)
	self.rpk.not_empty_reload_speed_mult = 1.00
	self.rpk.timers.reload_not_empty = 3.35
	self.rpk.timers.reload_not_empty_end = 0.50 -- 3.85
	self.rpk.empty_reload_speed_mult = 1.25
	self.rpk.timers.reload_empty = 4.30
	self.rpk.timers.reload_empty_end = 1.20 -- 4.40
	self.rpk.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.rpk.reload_stance_mod = {ads = {translation = Vector3(0, 0, -6), rotation = Rotation(0, 5, 0)}}
	self.rpk.CAN_TOGGLE_FIREMODE = true


	self.m249.sdesc1 = "caliber_r556x45"
	self.m249.sdesc2 = "action_gas"
	self.m249.stats.concealment = 12
	self.m249.bipod_weapon_translation = Vector3(-8.5, 20, -8)
	self.m249.fire_mode_data.fire_rate = 60/850
	self.m249.auto.fire_rate = 60/850
	self.m249.stats.spread = self.m249.stats.spread - 20
	self.m249.CLIP_AMMO_MAX = 200
	self.m249.taser_reload_amount = 75
	self.m249.AMMO_MAX = 400
	self.m249.AMMO_PICKUP = self:_pickup_chance(225, 1)
	self.m249.not_empty_reload_speed_mult = 1
	self.m249.timers.reload_not_empty = 5.25
	self.m249.timers.reload_not_empty_end = 1.00 -- 6.25
	self.m249.empty_reload_speed_mult = 1
	self.m249.timers.reload_empty = 5.25
	self.m249.timers.reload_empty_end = 1.00 -- 6.25


	self.hk21.sdesc1 = "caliber_r762x51"
	self.hk21.sdesc2 = "action_blowbackroller"
	self.hk21.stats.concealment = 10
	self.hk21.bipod_weapon_translation = Vector3(-5.5, 10, -3)
	self.hk21.chamber = 1
	self.hk21.fire_mode_data.fire_rate = 60/800
	self.hk21.auto.fire_rate = 60/800
	self.hk21.stats.spread = self.hk21.stats.spread + 10
	self.hk21.stats.recoil = self.hk21.stats.recoil - 5
	self.hk21.CLIP_AMMO_MAX = 100 -- 150
	self.hk21.taser_reload_amount = 50
	self.hk21.not_empty_reload_speed_mult = 1.20
	self.hk21.timers.reload_not_empty = 4.40
	self.hk21.timers.reload_not_empty_end = 1.50 -- 4.92
	self.hk21.empty_reload_speed_mult = 1.30
	--self.hk21.timers.reload_empty = 6.7
	self.hk21.timers.reload_empty_end = 1.30 -- 6.15
	self.hk21.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.hk21.reload_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}


	self.mg42.sdesc1 = "caliber_r792mauser"
	self.mg42.sdesc2 = "action_rollerlock"
	self.mg42.stats.concealment = 10
	self.mg42.bipod_weapon_translation = Vector3(-5, 20, -10)
	self.mg42.fire_mode_data.fire_rate = 60/1200
	self.mg42.stats.spread = self.mg42.stats.spread + 5
	self.mg42.stats.recoil = self.mg42.stats.recoil - 5
	self.mg42.CLIP_AMMO_MAX = 50
	self.mg42.not_empty_reload_speed_mult = 2.20
	self.mg42.timers.reload_not_empty = 6.5
	self.mg42.timers.reload_not_empty_end = 1.2 -- 3.50
	self.mg42.empty_reload_speed_mult = 2.20
	self.mg42.timers.reload_empty = 6.5
	self.mg42.timers.reload_empty_end = 1.2 -- 3.50
	self.mg42.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.mg42.reload_stance_mod = {ads = {translation = Vector3(5, 8, -5), rotation = Rotation(0, 0, 0)}}
	self.mg42.bipod_deploy_multiplier = self.mg42.bipod_deploy_multiplier * 1.3
	-- The MG42 *has no* singlefire sound, Overkill. All you did was break it.
	self.mg42.sounds.fire_single = nil


	-- ksp58
	self.par.sdesc1 = "caliber_r762x51"
	self.par.sdesc2 = "action_gas"
	self.par.stats.concealment = 11
	self.par.fire_mode_data.fire_rate = 60/600
	self.par.CLIP_AMMO_MAX = 100
	self.par.taser_reload_amount = 50
	self.par.reload_speed_mult = 1.35
	self.par.timers.reload_not_empty = 6.3
	self.par.timers.reload_not_empty_end = 1.0 -- 5.41
	self.par.timers.reload_empty = 6.3
	self.par.timers.reload_empty_end = 1.0 -- 5.41
	self.par.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.par.reload_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	
	-- m60
	self.m60.sdesc1 = "caliber_r762x51"
	self.m60.sdesc2 = "action_gas"
	self.m60.stats.concealment = 8
	self.m60.fire_mode_data.fire_rate = 60/550
	self.m60.CLIP_AMMO_MAX = 200
	self.m60.taser_reload_amount = 50
	self.m60.reload_speed_mult = 1.35
	self.m60.timers.reload_not_empty = 5
	self.m60.timers.reload_not_empty_end = 2 -- 5.41
	self.m60.timers.reload_empty = 5
	self.m60.timers.reload_empty_end = 2 -- 5.41
	self.m60.equip_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}
	self.m60.reload_stance_mod = {ads = {translation = Vector3(0, 0, -2), rotation = Rotation(0, 0, 0)}}

	-- vulcan/hephaestus
	self.m134.sdesc1 = "caliber_r762x51"
	self.m134.sdesc2 = "action_minigun"
	self.m134.stats.concealment = 6
	self.m134.fire_mode_data.fire_rate = 60/2000
	self.m134.reload_speed_mult = 1.25
	self.m134.timers.reload_empty = 7.55
	self.m134.timers.reload_empty_end = 1.20 -- 7.00
	self.m134.timers.reload_not_empty = 7.55
	self.m134.timers.reload_not_empty_end = 1.20
	self.m134.CLIP_AMMO_MAX = 300
	self.m134.taser_reload_amount = 150
	self.m134.AMMO_MAX = 600
	self.m134.AMMO_PICKUP = self:_pickup_chance(300, 1)


	-- microgun
	self.shuno.sdesc1 = "caliber_r556x45"
	self.shuno.sdesc2 = "action_minigun"
	self.shuno.stats.damage = self.shuno.stats.damage - 10
	self.shuno.stats.spread = self.shuno.stats.spread - 15
	self.shuno.stats.recoil = self.shuno.stats.recoil + 15
	self.shuno.stats.concealment = 8
	self.shuno.fire_mode_data.fire_rate = 60/3000
	self.shuno.no_sound_fix = true
	self.shuno.CLIP_AMMO_MAX = 400
	self.shuno.taser_reload_amount = 200
	self.shuno.AMMO_MAX = 799.5 -- fully loaded multiplies to 999 instead of 1000
	self.shuno.AMMO_PICKUP = self:_pickup_chance(400, 1)
	self.shuno.reload_speed_mult = 1.35
	self.shuno.unequip_speed_mult = 1.70
	self.shuno.timers.equip = 2.0
	self.shuno.equip_speed_mult = 2.20
	--self.shuno.timers.reload_not_empty = 7.80
	self.shuno.timers.reload_not_empty_end = 3.00 -- 8.00
	--self.shuno.timers.reload_empty = 7.80
	self.shuno.timers.reload_empty_end = 3.00
	self.shuno.spin_up_time = 0.40
	self.shuno.spin_down_speed_mult = self.shuno.spin_up_time/0.30 -- (+0.15)




	-- M79
	self.gre_m79.sdesc1 = "caliber_g40mm"
	self.gre_m79.sdesc2 = "action_breakopen"
	self.gre_m79.stats.concealment = 20
	self.gre_m79.stats.damage = 60.0
	self.gre_m79.AMMO_PICKUP = {1338, 20}
	self.gre_m79.reload_speed_mult = 1.6
	self.gre_m79.timers.reload_not_empty = 2.40
	self.gre_m79.timers.reload_not_empty_end = 0.80 -- 3.20
	self.gre_m79.timers.reload_empty = 2.40
	self.gre_m79.timers.reload_empty_end = 0.80 -- 3.20

	-- Secondary M79
	self:copy_sdescs("gre_m79secondary", "gre_m79")
	self.gre_m79secondary.stats.concealment = 20
	self.gre_m79secondary.stats.damage = 60.0
	self.gre_m79secondary.AMMO_PICKUP = {1338, 15}
	self.gre_m79secondary.AMMO_MAX = 4
	self.gre_m79secondary.CLIP_AMMO_MAX = 1
	self.gre_m79secondary.chamber = 0
	self:copy_timers("gre_m79secondary", "gre_m79")
	-- Hacky workaround to sync this as a China Puff/China Lake
	-- We can't fully base this weapon on the china lake in main.xml because that causes crashes and other issues
	self.gre_m79secondary.based_on = "china"

	-- m32
	self.m32.sdesc1 = "caliber_g40mm"
	self.m32.sdesc2 = "action_da"
	self.m32.stats.concealment = 15
	self.m32.stats.damage = 60.0
	self.m32.AMMO_PICKUP = {1338, 15}
	self.m32.timers.shell_reload_early = 1.00
	self.m32.timers.shotgun_reload_exit_empty = 1.00
	self.m32.timers.shotgun_reload_exit_not_empty = 1.00


	-- fuck china
	self.china.sdesc1 = "caliber_g40mm"
	self.china.sdesc2 = "action_pump"
	self.china.stats.damage = 60.0
	self.china.stats.concealment = 15
	self.china.chamber = 1
	self.china.AMMO_MAX = 4
	self.china.AMMO_PICKUP = {1338, 15}
	self.china.anim_speed_mult = 1
	self.china.fire_mode_data.fire_rate = 1.5
	self.china.single.fire_rate = 1.5
	self.china.timers.shotgun_reload_exit_not_empty = 0.60
	self.china.timers.shotgun_reload_exit_empty = 1.50
	self.china.timers.shell_reload_early = 0.60


	-- Compact 40mm/M320
	self.slap.sdesc1 = "caliber_g40mm"
	self.slap.sdesc2 = "action_breakopen"
	self.slap.stats.damage = 60.0
	--self.slap.stats.concealment = 22
	self.slap.AMMO_MAX = 4 -- Only way to properly get the china lake cool guy reload to work for now was to raise its max ammo, so this one now also needs a raise.
	self.slap.AMMO_PICKUP = {1338, 15}
	self.slap.reload_speed_mult = 1.00
	self.slap.timers.reload_not_empty = 2.30
	self.slap.timers.reload_not_empty_end = 1.20 -- 3.50
	self.slap.timers.reload_empty = 2.30
	self.slap.timers.reload_empty_end = 1.20 -- 3.50


	-- XM25
	self.arbiter.sdesc1 = "caliber_g25mm"
	self.arbiter.sdesc2 = "action_gas"
	--self.arbiter.stats.concealment = 18
	self.arbiter.chamber = 1
	self.arbiter.stats.damage = 30.0
	self.arbiter.AMMO_MAX = 10
	self.arbiter.AMMO_PICKUP = {1338, 20}
	self.arbiter.not_empty_reload_speed_mult = 1.00
	self.arbiter.timers.reload_not_empty = 3.34
	self.arbiter.timers.reload_not_empty_end = 0.80 -- 
	self.arbiter.empty_reload_speed_mult = 1.00
	self.arbiter.timers.reload_empty = 4.00
	self.arbiter.timers.reload_empty_end = 1.50 -- 


	--self.rpg7.stats.concealment = 5
	self.rpg7.AMMO_MAX = 1.7 -- rounds to 2
	self.rpg7.AMMO_PICKUP = {1338, 3}
	self.rpg7.not_empty_reload_speed_mult = 1.20
	self.rpg7.timers.reload_not_empty = 6.50
	self.rpg7.timers.reload_not_empty_end = 0.60 -- 5.91
	self.rpg7.empty_reload_speed_mult = 1.20
	self.rpg7.timers.reload_empty = 6.50
	self.rpg7.timers.reload_empty_end = 0.60 -- 5.91


	-- FLASH
	--self.ray.stats.concealment = 5
	self.ray.AMMO_MAX = 3.5 -- rounds to 4
	self.ray.AMMO_PICKUP = {1338, 6}
	self.ray.not_empty_reload_speed_mult = 1.20
	self.ray.timers.reload_not_empty = 6.00
	self.ray.timers.reload_not_empty_end = 1.80 -- 6.50
	self.ray.empty_reload_speed_mult = 1.20
	self.ray.timers.reload_empty = 5.75
	self.ray.timers.reload_empty_end = 1.80 -- 6.30




	self.flamethrower_mk2.sdesc1 = "caliber_flammenwerfer"
	self.flamethrower_mk2.sdesc2 = "action_flammenwerfer"
	self.flamethrower_mk2.sdesc3 = "range_fire"
	self.flamethrower_mk2.stats.damage = 25
	self.flamethrower_mk2.stats.concealment = 15
	self.flamethrower_mk2.shake.fire_multiplier = 0.10
	self.flamethrower_mk2.shake.fire_steelsight_multiplier = 0.05
	self.flamethrower_mk2.no_sound_fix = true
	self.flamethrower_mk2.reload_speed_mult = 1.65
	self.flamethrower_mk2.timers.reload_not_empty = 8.25
	self.flamethrower_mk2.timers.reload_not_empty_end = 1.00 -- 5.61
	self.flamethrower_mk2.timers.reload_empty = 8.25
	self.flamethrower_mk2.timers.reload_empty_end = 1.00
	self.flamethrower_mk2.CLIP_AMMO_MAX = 200
	self.flamethrower_mk2.AMMO_MAX = 400
	self.flamethrower_mk2.AMMO_PICKUP = self:_pickup_chance(400, 1)
	self.flamethrower_mk2.fire_mode_data.fire_rate = 60/1200
	self.flamethrower_mk2.auto.fire_rate = 60/1200
	self.flamethrower_mk2.fire_dot_data = {
		dot_trigger_chance = 75,
		dot_damage = 2.5,
		dot_length = 2.1,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}

	-- secondary flamer
	self.system.sdesc1 = "caliber_flammenwerfer"
	self.system.sdesc2 = "action_blowtorch"
	self.system.sdesc3 = "range_fire"
	self.system.stats.damage = 25
	self.system.stats.concealment = 15
	self.system.shake.fire_multiplier = 0.10
	self.system.shake.fire_steelsight_multiplier = 0.05
	self.system.reload_speed_mult = 1.65
	self.system.timers.reload_not_empty = 8.30
	self.system.timers.reload_not_empty_end = 1.50 -- 5.94
	self.system.timers.reload_empty = 8.30
	self.system.timers.reload_empty_end = 1.50
	self.system.CLIP_AMMO_MAX = 100
	self.system.AMMO_MAX = 200
	self.system.AMMO_PICKUP = self:_pickup_chance(200, 1)
	self.system.fire_mode_data.fire_rate = 60/1200
	self.system.auto.fire_rate = 60/1200
	self.system.fire_dot_data = self.flamethrower_mk2.fire_dot_data
	self.system.equip_stance_mod = {ads = {translation = Vector3(2, -3, 0), rotation = Rotation(0, 0, 0)}}
	self.system.reload_stance_mod = {ads = {translation = Vector3(2, -3, 0), rotation = Rotation(0, 0, 0)}}




	-- plainsrider
	self.plainsrider.ads_movespeed_mult = 2
	self.plainsrider.sdesc1 = "bm_w_plainsrider_desc_short"
	self.plainsrider.stats.damage = 40
	--self.plainsrider.stats.concealment = 30
	self.plainsrider.AMMO_MAX = 30
	self.plainsrider.AMMO_PICKUP = {1338, 100}
	self.plainsrider.timers.reload_empty = 0.50
	self.plainsrider.timers.reload_empty_end = 0.25
	self.plainsrider.bow_reload_speed_multiplier = 1
	self.plainsrider.reload_speed_mult = 1
	self.plainsrider.charge_speed_mult = 1.50
	self.plainsrider.charge_data = {max_t = 0.9/self.plainsrider.charge_speed_mult}

	-- longbow
	self.long.ads_movespeed_mult = 2
	self.long.sdesc1 = "bm_w_long_desc_short"
	self.long.stats.damage = 50
	self.long.stats_modifiers = {damage = 10}
	self.long.stats.concealment = 30
	self.long.AMMO_MAX = 24
	self.long.AMMO_PICKUP = {1338, 100}
	self.long.timers.reload_empty = 0.70
	self.long.timers.reload_empty_end = 0.60
	self.long.reload_speed_mult = 1.25
	self.long.charge_speed_mult = 1.25
	self.long.charge_data = {max_t = 0.9/self.long.charge_speed_mult}

	-- compound bow
	self.elastic.ads_movespeed_mult = 2
	self.elastic.sdesc1 = "bm_w_elastic_desc_short"
	self.elastic.stats.damage = 50
	self.elastic.stats_modifiers = {damage = 10}
	self.elastic.stats.concealment = 30
	self.elastic.AMMO_MAX = 24
	self.elastic.AMMO_PICKUP = {1338, 100}
	self.elastic.timers.reload_empty = 0.70
	self.elastic.timers.reload_empty_end = 0.60
	self.elastic.reload_speed_mult = 1.25
	self.elastic.charge_speed_mult = 1.00
	self.elastic.charge_data = {max_t = 0.9/self.elastic.charge_speed_mult}

	-- light crossbow
	self.frankish.sdesc1 = "bm_w_frankish_desc_short"
	self.frankish.stats.damage = 40
	self.frankish.stats.concealment = 30
	self.frankish.fire_mode_data = {fire_rate = 1.0}
	self.frankish.AMMO_MAX = 30
	self.frankish.AMMO_PICKUP = {1338, 100}
	self.frankish.reload_speed_mult = 1.20
	self.frankish.timers.reload_empty = 1.50
	self.frankish.timers.reload_empty_end = 0.30 -- 1.5

	-- heavy crossbow
	self.arblast.sdesc1 = "bm_w_arblast_desc_short"
	self.arblast.stats.damage = 100
	self.arblast.stats_modifiers = {damage = 10}
	self.arblast.fire_mode_data = {fire_rate = 1.0}
	self.arblast.stats.concealment = 30
	self.arblast.AMMO_MAX = 14
	self.arblast.AMMO_PICKUP = {1338, 60}
	self.arblast.timers.reload_empty = 2.90
	self.arblast.timers.reload_empty_end = 0.90
	self.arblast.reload_speed_mult = 1.25 -- 3.04

	-- pistol crossbow
	self.hunter.ads_movespeed_mult = 2.0
	self.hunter.sdesc1 = "bm_w_hunter_desc_short"
	self.hunter.fire_mode_data = {fire_rate = 0.75}
	self.hunter.stats.damage = 25
	self.hunter.stats.concealment = 30
	self.hunter.AMMO_MAX = 24
	self.hunter.AMMO_PICKUP = {1338, 100}
	self.hunter.timers.reload_empty = 1.00
	self.hunter.timers.reload_empty_end = 0.40
	self.hunter.reload_speed_mult = 1.20

	-- airbow
	self.ecp.sdesc1 = "bm_w_ecp_desc_short"
	self.ecp.recoil_table = InFmenu.rtable.hrifle
	self.ecp.kick = InFmenu.rstance.dmr
	self.ecp.stats.damage = 22
	self.ecp.stats.concealment = 20
	self.ecp.not_empty_reload_speed_mult = 1.25
	self.ecp.timers.reload_not_empty = 3
	self.ecp.timers.reload_not_empty_end = 0.60 -- 2.88
	self.ecp.empty_reload_speed_mult = 1.25
	self.ecp.timers.reload_empty = 3
	self.ecp.timers.reload_empty_end = 0.60 -- 2.88
	self.ecp.reload_stance_mod = {ads = {translation = Vector3(5, -10, -5), rotation = Rotation(0, 0, 0)}}







	self.saw.sdesc1 = "caliber_saw"
	self.saw.sdesc2 = "action_saw"
	self.saw.stats.damage = 35
	self.saw.stats.concealment = 25
	self.saw.CLIP_AMMO_MAX = 60
	self.saw.AMMO_MAX = 120
	self.saw.AMMO_PICKUP = {3, 3}
	self.saw.recoil_table = InFmenu.rtable.norecoil

	self.saw_secondary.sdesc1 = "caliber_saw"
	self.saw_secondary.sdesc2 = "action_saw"
	self.saw_secondary.stats.damage = 35
	self.saw_secondary.stats.concealment = 25
	self.saw_secondary.CLIP_AMMO_MAX = 60
	self.saw_secondary.AMMO_MAX = 120
	self.saw_secondary.AMMO_PICKUP = {3, 3}
	self.saw_secondary.recoil_table = InFmenu.rtable.norecoil


	-- SECONDARY AKIMBOS
	-- These mostly work already through main.xml, but they need stats fixes
	
	-- Table of original akimbos as key, and new akimbos as value
	local primary_to_secondary_akimbos = {
		x_pl14 = "x_pl14_secondary",
		x_sparrow = "x_sparrow_secondary",
		x_legacy = "x_legacy_secondary",
		jowi = "x_jowi_secondary", -- Thanks for the inconsistent naming Overkill
		x_b92fs = "x_b92fs_secondary",
		x_g17 = "x_g17_secondary",
		x_packrat = "x_packrat_secondary",
		x_holt = "x_holt_secondary"
	}
	
	-- Normally the ammo akimbos have is (primary ammo)/1.8
	-- But max ammo doesn't quite match up with mag sizes most of the time, let's fix that
	local secondary_akimbo_ammo_overrides = {
		x_sparrow_secondary = 120,
		x_g17_secondary = 121, -- Aargh
		x_b92fs_secondary = 120,
		x_pl14_secondary = 120,
		x_legacy_secondary = 117,
		x_jowi_secondary = 120,
		x_packrat_secondary = 120,
		x_holt_secondary = 120
	}

	-- Copy name/description and fix some stats automagically
	-- This will save us a ton of unnecessary XML work
	for pri, sec in pairs(primary_to_secondary_akimbos) do
		self:inf_init(sec, "pistol", nil)
		self:copy_stats(sec, pri)
		self:copy_sdescs(sec, pri)
		self:copy_timers(sec, pri)
		self[sec].name_id = self[pri].name_id
		self[sec].desc_id = self[pri].desc_id
		-- Concealment is relative, -1 concealment for bringing *a whole extra gun* is already generous
		self[sec].stats.concealment = self[pri].stats.concealment - 1

		-- Set max ammo
		-- Base ammo for a lot of lighter primary akimbos is 180, so the new max ammo for secondaries will be ~120 (or slightly higher/lower so the mags match up)
		-- Ammo pickup is always the same as a 120-ammo pistol though, would be unfair otherwise
		local max_ammo = secondary_akimbo_ammo_overrides[sec] or math.ceil(self[pri].AMMO_MAX / 1.6)
		self[sec].AMMO_MAX = max_ammo
		self[sec].AMMO_PICKUP = self:_pickup_chance(120, 1)
	end



	-- CUSTOM WEAPONS

	-- With debug on, execute the function normally so it crashes hard if something goes wrong
	-- With debug off, silently eat any errors. Custom weapon stats might not work correctly.
	-- I'm so done with people's entire games crashing over an update to a custom weapon mod
	if InFmenu.settings.debug then
		self:_inf_init_custom_weapons(lmglist)
	else
		local successful, errmessage = pcall(WeaponTweakData._inf_init_custom_weapons, self, lmglist)
		if not successful then
			log("[InF] FATAL ERROR while loading custom weapon stats:")
			if not errmessage then
				errmessage = "(Unable to obtain error message)"
			end
			log(errmessage)

			local userdialogerrmessage = "An error occurred while trying to initialize support for custom weapons. Some custom weapons may have incorrect stats.\n\n"
			userdialogerrmessage = userdialogerrmessage .. "It is strongly recommended to create an issue on the IREnFIST Github repository (or comment on the Mod Workshop page), with your latest BLT Log attached (PAYDAY 2/mods/logs)."
			if IREnFIST.last_attempted_custom_weapon_mod then
				userdialogerrmessage = userdialogerrmessage .. "\n\nSuspected mod: " .. IREnFIST.last_attempted_custom_weapon_mod
			end

			-- Open a message dialog box in the menu, notifying the user that an error occurred trying to intitialize weapons
			-- Don't just leave them hanging
			Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_weapontweak_failedinit", function(menu_manager, nodes)            
				QuickMenu:new("IREnFIST - Error initializing custom weapons", userdialogerrmessage, {
					[1] = {
						text = "OK",
						is_cancel_button = true
					}
				}):show()
			end)
		end
	end
	
	-- The text guide on how to add custom weapon support was moved to the bottom of wpn_stats_custom.lua


	-- Don't touch this, this should be the last line in the weapontweakdata init hook
	-- Enables better compatibility with other mods if they choose to override or supplement something InF does
	Hooks:Call("inf_weapontweak_initcomplete", self)
end

-- FUCK TURRETS
local cancerous = {"swat_van_turret_module", "ceiling_turret_module", "ceiling_turret_module_no_idle", "ceiling_turret_module_longer_range", "aa_turret_module", "crate_turret_module"}
local smallercancerous = {"ceiling_turret_module", "ceiling_turret_module_no_idle", "ceiling_turret_module_longer_range", "crate_turret_module"}

function WeaponTweakData:setcancerhealth(healthmult, clipmult)
	for a, turret in pairs(cancerous) do
		self[turret].HEALTH_INIT = 400.0 * healthmult
		self[turret].BODY_DAMAGE_CLAMP = 5000.0
		self[turret].BAG_DMG_MUL = 2 -- 'headshot'
		self[turret].headshot_dmg_mul = 2 -- crit
		self[turret].EXPLOSION_DMG_MUL = 1
		self[turret].FIRE_DMG_MUL = 1 -- totally untested, what's the worst that could happen
		self[turret].SHIELD_HEALTH_INIT = 400.0 * healthmult
		self[turret].SHIELD_DAMAGE_CLAMP = 5000.0
		self[turret].AUTO_REPAIR = false

		self[turret].CLIP_SIZE = math.ceil(83 * clipmult) -- 5s of firing: 1000rpm, 0.06sec/round
		self[turret].AUTO_RELOAD_DURATION = 5
		self[turret].DAMAGE_MUL_RANGE = {{800, 3}, {1000, 1.5}, {1500, 1}}
	end

	for a, turret in pairs(smallercancerous) do
		self[turret].HEALTH_INIT = 200.0 * healthmult
		self[turret].SHIELD_HEALTH_INIT = 200.0 * healthmult
	end
end


Hooks:PostHook(WeaponTweakData, "_set_normal", "chemo_normal", function(self)
	self:setcancerhealth(0.50, 1)
end)
Hooks:PostHook(WeaponTweakData, "_set_hard", "chemo_hard", function(self)
	self:setcancerhealth(0.50, 1)
end)
Hooks:PostHook(WeaponTweakData, "_set_overkill", "chemo_vhard", function(self)
	self:setcancerhealth(0.60, 1)
end)
Hooks:PostHook(WeaponTweakData, "_set_overkill_145", "chemo_ovk", function(self)
	self:setcancerhealth(0.80, 1)
end)

Hooks:PostHook(WeaponTweakData, "_set_easy_wish", "chemo_mayhem", function(self)
	self:setcancerhealth(1.00, 2)
end)

Hooks:PostHook(WeaponTweakData, "_set_overkill_290", "chemo_dw", function(self)
	self:setcancerhealth(1.20, 2)
end)

Hooks:PostHook(WeaponTweakData, "_set_sm_wish", "chemo_ds", function(self)
	self:setcancerhealth(1.25, 2)
end)

-- stop russian enemies from dealing triple the damage of their american counterparts for no good reason
Hooks:PostHook(WeaponTweakData, "_set_overkill_145", "gundmgovk", function(self)
	if InFmenu.settings.copfalloff == true then
		self.ak47_ass_npc.DAMAGE = 1
		self.scar_npc.DAMAGE = 1
	end
end)
Hooks:PostHook(WeaponTweakData, "_set_easy_wish", "gundmgmh", function(self)
	if InFmenu.settings.copfalloff == true then
		self.ak47_ass_npc.DAMAGE = 1
		self.scar_npc.DAMAGE = 1
	end
end)
Hooks:PostHook(WeaponTweakData, "_set_overkill_290", "gundmgdw", function(self)
	if InFmenu.settings.copfalloff == true then
		self.ak47_ass_npc.DAMAGE = 1
		self.g36_npc.DAMAGE = 1 -- you too seriously wtf
		self.scar_npc.DAMAGE = 1
	end
end)

Hooks:PostHook(WeaponTweakData, "_set_sm_wish", "gundmgds", function(self)
	if InFmenu.settings.copfalloff == true then
		self.ak47_ass_npc.DAMAGE = 1
		self.g36_npc.DAMAGE = 1
		self.scar_npc.DAMAGE = 1
		-- restore defaults instead of 225 damage ass cancer
		self.m4_npc.DAMAGE = 1
		self.m4_yellow_npc.DAMAGE = 1
		self.r870_npc.DAMAGE = 3
		self.benelli_npc.DAMAGE = 3

	end
end)

dofile(ModPath .. "infcore.lua")
-- If the config file is corrupt, this function WILL fail, and it will fail very loudly and obviously.
dofile(ModPath .. "lua/assert_config_should_not_crash.lua")
If_This_Appears_In_Your_Crashlog_Delete_Your_InF_Save_Txt()

Hooks:RegisterHook("inf_weaponfactorytweak_initcomplete")

-- Obtain function for custom weapon part support
dofile(ModPath .. "lua/wpn_parts_custom.lua")

--[[
anim_speed_mult
inf_rof_mult
falloff_min_dmg_penalty -- use 'displayed damage' i.e. 10, not 1.0
falloff_begin_mult
falloff_end_mult
armor_piercing_sub
reload_speed_mult
movement_speed
recoil_table
recoil_loop_point
ads_movespeed_mult
recoil_vertical_mult
recoil_horizontal_mult
ads_recoil_vertical_mult
ads_recoil_horizontal_mult
pen_shield_dmg_mult
pen_wall_dmg_mult
--]]

--[[
can define underbarrel chamber with partid.chamber, defaults to 0
can override desc_id/unit, but not stats (unless weapon overrides?)
if two parts are directly selectable by the player and one forbids the other, both should forbid each other
cannot use part to override custom stats of other part
--]]


local function checkfolders(subfolder, file)
	local filename = file or "main.xml"
	if SystemFS:exists("mods/" .. subfolder .. "/" .. filename) or SystemFS:exists("assets/mod_overrides/" .. subfolder .. "/" .. filename) then
		return true
	end
	return false
end

-- adds a set of parts to a single part's forbids list
local function add_multiple_to_forbids(forbidref, partlist)
	for a, b in ipairs(partlist) do
		table.insert(forbidref, b)
	end
end

-- sets correct ammo type sdescs for shotgun ammo
function WeaponFactoryTweakData:inf_shotgun_ammo_overrides(wpn, shelltype)
	local caliberend = "s12g"
	if shelltype then
		caliberend = shelltype
	end
	local caliber = "caliber_" .. caliberend

	local ammolist = {{"wpn_fps_upg_a_slug", "_ap"}, {"wpn_fps_upg_a_custom", "_000"}, {"wpn_fps_upg_a_custom_free", "_breach"}, {"wpn_fps_upg_a_explosive", "_he"}, {"wpn_fps_upg_a_piercing", "_fl"}, {"wpn_fps_upg_a_dragons_breath", "_db"}}
	for a, b in ipairs(ammolist) do
		self[wpn].override = self[wpn].override or {}
		self[wpn].override[b[1]] = {custom_stats = deep_clone(self.parts[b[1]].custom_stats)}
		self[wpn].override[b[1]].custom_stats.sdesc1 = caliber .. b[2]

--		if b[2] == "_000" or b[2] == "_fl" or b[2] == "_breach" then
--			self[wpn].override[b[1]].custom_stats.sdesc3 = finalrange .. b[2]
--		elseif b[2] == "_slug" or b[2] == "_he" then
--			self[wpn].override[b[1]].custom_stats.sdesc3 = range_shotslug
--		elseif b[2] == "_db" then
--			self[wpn].override[b[1]].custom_stats.sdesc3 = range_shotdb
--		end
	end
end


-- how many seconds to put off delay functions
-- necessary to prevent other weapon hooks from overwriting my clearly superior stats
local delay = 0.50


--local dummy = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
local dummy = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy"


-- manually do magsize and sdesc adjustments
function WeaponFactoryTweakData:convert_custom_stats(part, valuefrom, valueto)
	self.parts[part].custom_stats = self.parts[part].custom_stats or {}
	self.parts[part].custom_stats.rstance = InFmenu.rstance[valueto]
	self.parts[part].custom_stats.recoil_table = InFmenu.rtable[valueto]
	self.parts[part].custom_stats.recoil_loop_point = InFmenu.wpnvalues[valueto].recoil_loop_point
	self.parts[part].custom_stats.armor_piercing_add = InFmenu.wpnvalues[valueto].armor_piercing_chance - InFmenu.wpnvalues[valuefrom].armor_piercing_chance
	self.parts[part].custom_stats.body_armor_dmg_penalty_mul = InFmenu.wpnvalues[valueto].body_armor_dmg_penalty_mul or 1

	if valueto == "dmr" or valueto == "ldmr" or valueto == "hdmr" then
		self.parts[part].custom_stats.taser_hole = true
		self.parts[part].custom_stats.can_shoot_through_shield = true
		self.parts[part].custom_stats.can_shoot_through_wall = true
		self.parts[part].custom_stats.can_shoot_through_enemy = true
	else
		self.parts[part].custom_stats.taser_hole = false
		self.parts[part].custom_stats.can_shoot_through_shield = false
		if InFmenu.settings.allpenwalls == false then
			self.parts[part].custom_stats.can_shoot_through_wall = false
		end
		self.parts[part].custom_stats.can_shoot_through_enemy = false
	end
end

function WeaponFactoryTweakData:convert_rof(part, valuefrom, valueto)
	self.parts[part].custom_stats = self.parts[part].custom_stats or {}

	local before = nil
	local after = nil
	if type(valuefrom) == "number" then
		before = valuefrom
	elseif InFmenu.wpnvalues[valuefrom].rof then
		before = InFmenu.wpnvalues[valuefrom].rof
	end
	if type(valueto) == "number" then
		after = valueto
	elseif InFmenu.wpnvalues[valueto].rof then
		after = InFmenu.wpnvalues[valueto].rof
	end

	if before and after then
		self.parts[part].custom_stats.inf_rof_mult = after/before
		self.parts[part].custom_stats.anim_speed_mult = before/after
	end
end

function WeaponFactoryTweakData:convert_ammo_pickup(part, valuefrom, valueto)
	self.parts[part].custom_stats = self.parts[part].custom_stats or {}

	local before = 1
	local after = 1
	if type(valuefrom) == "number" then
		before = valuefrom
	else
		before = InFmenu.wpnvalues[valuefrom].ammo
	end
	if type(valueto) == "number" then
		after = valueto
	else
		after = InFmenu.wpnvalues[valueto].ammo
	end

	self.parts[part].custom_stats.ammo_pickup_min_mul = after/before
	self.parts[part].custom_stats.ammo_pickup_max_mul = after/before
end

function WeaponFactoryTweakData:convert_total_ammo_mod(part, valuefrom, valueto)
	local before = 1
	local after = 1
	if type(valuefrom) == "number" then
		before = valuefrom
	else
		before = InFmenu.wpnvalues[valuefrom].ammo
	end
	if type(valueto) == "number" then
		after = valueto
	else
		after = InFmenu.wpnvalues[valueto].ammo
	end

	self.parts[part].stats = self.parts[part].stats or {value = 0, concealment = 0}
	self.parts[part].stats.total_ammo_mod = math.floor(((after/before - 1) * 1000) + 0.5)
end

function WeaponFactoryTweakData:convert_stats(part, valuefrom, valueto)
	self.parts[part].stats = self.parts[part].stats or {value = 0, concealment = 0}
	self.parts[part].stats.damage = InFmenu.wpnvalues[valueto].damage - InFmenu.wpnvalues[valuefrom].damage
	self.parts[part].stats.spread = InFmenu.wpnvalues[valueto].spread - InFmenu.wpnvalues[valuefrom].spread
	self.parts[part].stats.recoil = InFmenu.wpnvalues[valueto].recoil - InFmenu.wpnvalues[valuefrom].recoil
end


function WeaponFactoryTweakData:convert_part(part, valuefrom, valueto, ammofrom, ammoto, roffrom, rofto)
	self:convert_custom_stats(part, valuefrom, valueto)
	self:convert_rof(part, roffrom or valuefrom, rofto or valueto)
	self:convert_ammo_pickup(part, ammofrom or valuefrom, ammoto or valueto)
	self:convert_total_ammo_mod(part, ammofrom or valuefrom, ammoto or valueto)
	self:convert_stats(part, valuefrom, valueto)
end

-- special case where the weapon uses both ammo and non-ammo parts so that stats are both visible and applied like usual
-- this one's for the non-ammo part
function WeaponFactoryTweakData:convert_part_half_a(part, valuefrom, valueto, ammofrom, ammoto, roffrom, rofto)
	--self:convert_custom_stats(part, valuefrom, valueto)
	self:convert_rof(part, roffrom or valuefrom, rofto or valueto)
	--self:convert_ammo_pickup(part, ammofrom or valuefrom, ammoto or valueto)
	self:convert_total_ammo_mod(part, ammofrom or valuefrom, ammoto or valueto)
	self:convert_stats(part, valuefrom, valueto)
end
-- and this one's for the ammo
function WeaponFactoryTweakData:convert_part_half_b(part, valuefrom, valueto, ammofrom, ammoto, roffrom, rofto)
	self:convert_custom_stats(part, valuefrom, valueto)
	--self:convert_rof(part, roffrom or valuefrom, rofto or valueto)
	self:convert_ammo_pickup(part, ammofrom or valuefrom, ammoto or valueto)
	--self:convert_total_ammo_mod(part, ammofrom or valuefrom, ammoto or valueto)
	--self:convert_stats(part, valuefrom, valueto)
end







Hooks:PostHook(WeaponFactoryTweakData, "init", "inf_initweaponfactory_partstats", function(self, params)
	-- Check if BeardLib is installed, THIS IS NECESSARY for InF to work. Apparently this isn't clear enough for some people,
	-- so I'll let the crashlogs speak for themselves.
	-- I'm not going to hardcode a check for BeardLib's existence, instead I am simply going to check if the primary SMG's are loaded.
	-- Just in case another mod comes around to replace BeardLib
	if not self.parts.inf_bipod_part then
		error("Could not initialize IREnFIST weaponmods (weaponfactorytweakdata self.parts.inf_bipod_part)! Is BeardLib installed?")
	end

	local shotgun_slug_mult = 0.20/0.50
	local silencercustomstats = {falloff_min_dmg_penalty = 10, falloff_begin_mult = 0.75, falloff_end_mult = 0.75}
	local shotgunsilencercustomstats = {}
	local snpsilencercustomstats = {pen_shield_dmg_mult = 0.80}

	-- rifle/pistol suppressors
	local silstatsconc0 = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		spread = 5,
		recoil = 0,
		concealment = 0
	}
	local silstatsconc1 = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		spread = 5,
		recoil = 3,
		concealment = -1
	}
	local silstatsconc2 = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		spread = 5,
		recoil = 6,
		concealment = -2
	}
	-- sniper rifle
	local silstatssnp = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		recoil = 4,
		concealment = -2
	}
	-- shotgun
	local silstatssho = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		recoil = 4,
		concealment = -2
	}

	-- barrel presets
	local barrel_m1 = {
		value = 1,
		spread = 5,
		recoil = 3,
		reload = -5,
		concealment = -1
	}
	local barrel_m2 = {
		value = 2,
		spread = 10,
		recoil = 6,
		reload = -10,
		concealment = -2
	}
	local barrel_p1 = {
		value = 1,
		spread = -5,
		recoil = -2,
		reload = 5,
		concealment = 1
	}
	local barrel_p2 = {
		value = 2,
		spread = -10,
		recoil = -4,
		reload = 10,
		concealment = 2
	}
	local barrel_p3 = {
		value = 2,
		spread = -15,
		recoil = -6,
		reload = 15,
		concealment = 3
	}
	local barrelsho_m1 = {
		value = 1,
		spread = 10,
		recoil = 2,
		reload = -8,
		concealment = -1
	}
	local barrelsho_m2 = {
		value = 2,
		spread = 20,
		recoil = 4,
		reload = -16,
		concealment = -2
	}
	local barrelsho_m3 = {
		value = 2,
		spread = 30,
		recoil = 6,
		reload = -24,
		concealment = -2
	}
	local barrelsho_p1 = {
		value = 1,
		spread = -15,
		recoil = -2,
		reload = 8,
		concealment = 1
	}
	local barrelsho_p2 = {
		value = 2,
		spread = -20,
		recoil = -4,
		reload = 16,
		concealment = 2
	}
	local barrelsho_p3 = {
		value = 2,
		spread = -30,
		recoil = -6,
		reload = 24,
		concealment = 3
	}
	local barrelshoammo_m1 = {
		value = 1,
		spread = 10,
		recoil = 2,
		reload = -8,
		concealment = -1
	}
	local barrelshoammo_m2 = {
		value = 2,
		spread = 20,
		recoil = 4,
		reload = -16,
		concealment = -2
	}
	local barrelshoammo_p1 = {
		value = 1,
		spread = -10,
		recoil = -2,
		reload = 12,
		concealment = 1
	}
	local barrelshoammo_p2 = {
		value = 2,
		spread = -20,
		recoil = -4,
		reload = 24,
		concealment = 2
	}
	local barrelshoammo_p3 = {
		value = 2,
		spread = -30,
		recoil = -6,
		reload = 36,
		concealment = 3
	}
	-- stock presets
	local stock_snp = {
		value = 1,
		recoil = 10,
		reload = -10,
		concealment = -2
	}

	-- double barrel presets
	local db_barrel = {
		value = 1,
		spread = -30,
		reload = 20,
		concealment = 3
	}
	local db_stock = {
		value = 1,
		recoil = -10,
		reload = 10,
		concealment = 3
	}

	-- mag presets
	local mag_17 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_17.reload,
		concealment = 5
	}
	local mag_25 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_25.reload,
		concealment = 5
	}
	local mag_33 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_33.reload,
		concealment = 4
	}
	local mag_50 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_50.reload,
		concealment = 3
	}
	local mag_66 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_66.reload,
		concealment = 2
	}
	local mag_75 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_75.reload,
		concealment = 2
	}
	local mag_125 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_125.reload,
		concealment = -1
	}
	local mag_133 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_133.reload,
		concealment = -2
	}
	local mag_150 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_150.reload,
		concealment = -2
	}
	local mag_200 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_200.reload,
		concealment = -2
	}
	local mag_250 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_250.reload,
		concealment = -2
	}
	local mag_300 = {
		value = 0,
		reload = InFmenu.wpnvalues.reload.mag_300.reload,
		concealment = -4
	}
	local mag_alternating = {
		value = 1,
		reload = -20,
		concealment = -1
	}

	local nostats = {
		value = 0,
		concealment = 0
	}

function WeaponFactoryTweakData:halve_value(data)
	if data then
		return math.floor((data + 0.5)/2)
	end
end


	local switch_snubnose = 1.35



	local primarysmgadds = {}
	local primarysmgadds_specific = {}
	local primarysmglist = {
		["wpn_fps_smg_hajkprimary"] = true,
		["wpn_fps_smg_shepheardprimary"] = true,
		["wpn_fps_smg_coalprimary"] = true,
		["wpn_fps_smg_thompsonprimary"] = true,
		["wpn_fps_smg_olympicprimary"] = true,
		["wpn_fps_smg_mp5primary"] = true,
		["wpn_fps_smg_schakalprimary"] = true,
		["wpn_fps_smg_akmsuprimary"] = true
		--["wpn_fps_shot_m37primary"] = true
	}
	local customsightaddlist = {
		{"wpn_fps_smg_hajkprimary", "wpn_fps_smg_hajk"},
		{"wpn_fps_smg_shepheardprimary", "wpn_fps_smg_shepheard"},
		{"wpn_fps_smg_coalprimary", "wpn_fps_smg_coal"},
		{"wpn_fps_smg_thompsonprimary", "wpn_fps_smg_thompson"},
		{"wpn_fps_smg_olympicprimary", "wpn_fps_smg_olympic"},
		{"wpn_fps_smg_mp5primary", "wpn_fps_smg_mp5"},
		{"wpn_fps_smg_schakalprimary", "wpn_fps_smg_schakal"},
		{"wpn_fps_smg_akmsuprimary", "wpn_fps_smg_akmsu"}
		--{"wpn_fps_shot_m37primary", "wpn_fps_shot_m37"}
	}



	self.wpn_fps_smg_olympic.override = self.wpn_fps_smg_olympic.override or {}
	self.wpn_fps_smg_olympicprimary.override = self.wpn_fps_smg_olympicprimary.override or {}
	self.wpn_fps_sho_boot.override = self.wpn_fps_sho_boot.override or {}

	-- prevent crashes and issues related to attaching those fuckin m4 moe pack stocks
	-- add stock adapters to weapons that don't have them
--[[
	self.wpn_fps_smg_hajk.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_smg_mp5.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_smg_schakal.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_ass_ak5.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_smg_mac10.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_lmg_par.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_ass_fal.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_ass_asval.stock_adapter = "wpn_upg_ak_s_adapter"
	self.wpn_fps_ass_scar.stock_adapter = "wpn_upg_ak_s_adapter"

	-- forbid AK standard grip or it'll appear on weapons that shouldn't have it
	self.parts.wpn_fps_ass_fal_body_standard.forbids = self.parts.wpn_fps_ass_fal_body_standard.forbids or {}
	table.insert(self.parts.wpn_fps_ass_fal_body_standard.forbids, "wpn_upg_ak_g_standard")

	self.parts.wpn_fps_ass_asval_body_standard.forbids = self.parts.wpn_fps_ass_asval_body_standard.forbids or {}
	table.insert(self.parts.wpn_fps_ass_asval_body_standard.forbids, "wpn_upg_ak_g_standard")

	self.parts.wpn_fps_ass_scar_body_standard.forbids = self.parts.wpn_fps_ass_scar_body_standard.forbids or {}
	table.insert(self.parts.wpn_fps_ass_scar_body_standard.forbids, "wpn_upg_ak_g_standard")
--]]


	-- SIGHTS
	-- Professional's Choice
	self.parts.wpn_fps_upg_o_t1micro.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- See More Sight
	self.parts.wpn_fps_upg_o_cmore.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- Speculator Sight
	self.parts.wpn_fps_upg_o_reflex.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- Compact Holosight
	self.parts.wpn_fps_upg_o_eotech_xps.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- Holographic Sight
	self.parts.wpn_fps_upg_o_eotech.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- Surgeon Sight
	self.parts.wpn_fps_upg_o_docter.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	-- Solar Sight
	self.parts.wpn_fps_upg_o_rx30.stats = {
		value = 1,
		zoom = 3,
		concealment = -2
	}
	-- Trigonom Sight
	self.parts.wpn_fps_upg_o_rx01.stats = {
		value = 1,
		zoom = 3,
		concealment = -2
	}
	-- Combat Sight
	self.parts.wpn_fps_upg_o_cs.forbids = {
		"wpn_fps_amcar_uupg_body_upperreciever",
		--"wpn_fps_ass_m16_os_frontsight",
		"wpn_fps_ass_scar_o_flipups_up",
		"wpn_fps_upg_o_xpsg33_magnifier" -- added
	}
	--self.parts.wpn_fps_upg_o_cs.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_cs.stats = {
		value = 1,
		zoom = 3,
		concealment = -2
	}
	-- Military Red Dot Sight
	--self.parts.wpn_fps_upg_o_aimpoint.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_aimpoint.stats = {
		value = 1,
		zoom = 3,
		concealment = -2
	}
	--self.parts.wpn_fps_upg_o_aimpoint_2.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_aimpoint_2.stats = {
		value = 1,
		zoom = 3,
		concealment = -2
	}
	-- Milspec Scope
	self.parts.wpn_fps_upg_o_specter.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_specter.stats = {
		value = 1,
		zoom = 5,
		concealment = -2
	}
	-- ACOUGH
	self.parts.wpn_fps_upg_o_acog.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_acog.stats = {
		value = 1,
		zoom = 5,
		concealment = -2
	}
	-- Recon Sight
	self.parts.wpn_fps_upg_o_spot.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_spot.stats = {
		value = 1,
		zoom = 5,
		concealment = -2
	}

	-- BMG Advanced Combat Sight (trijicon)
	self.parts.wpn_fps_upg_o_bmg.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_bmg.stats = {
		value = 1,
		zoom = 5,
		concealment = -2
	}
	
	-- FC1 compact profile sight
	self.parts.wpn_fps_upg_o_fc1.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_fc1.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}
	
	-- UH maelstrom
	self.parts.wpn_fps_upg_o_uh.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_uh.stats = {
		value = 1,
		zoom = 0,
		concealment = -1
	}

	-- Roach/Pistol Red Dot Sight
	self.parts.wpn_fps_upg_o_rmr.stats = {
		value = 1,
		concealment = -1
	}
	
	-- Riktpunkt
	self.parts.wpn_fps_upg_o_rikt.stats = {
		value = 1,
		concealment = -1
	}
	
	-- Microsight
	self.parts.wpn_fps_upg_o_rms.stats = {
		value = 1,
		concealment = -1
	}

	-- default sniper scope/hyperion
	self.parts.inf_shortdot.customsight = true
	self.parts.inf_shortdot.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.inf_shortdot.stats = {
		value = 1,
		zoom = 6,
		concealment = 0
	}
	self.wpn_fps_snp_mosin.adds.inf_shortdot = self.wpn_fps_snp_mosin.adds.wpn_fps_upg_o_shortdot
	self.wpn_fps_snp_model70.adds.inf_shortdot = self.wpn_fps_snp_model70.adds.wpn_fps_upg_o_shortdot
	self.wpn_fps_snp_siltstone.adds.inf_shortdot = self.wpn_fps_snp_siltstone.adds.wpn_fps_upg_o_shortdot
--[[
	self.parts.wpn_fps_upg_o_shortdot.name_id = "shortdot_name"
	self.parts.wpn_fps_upg_o_shortdot.desc_id = "shortdot_desc"
	self.parts.wpn_fps_upg_o_shortdot.perks = {"scope", "highlight"}
--]]
	self.parts.wpn_fps_upg_o_shortdot.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_shortdot.stats = {
		value = 1,
		zoom = 6,
		concealment = 0
	}
	self.parts.wpn_fps_upg_o_shortdot_vanilla.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_shortdot_vanilla.stats = {
		value = 1,
		zoom = 6,
		concealment = 0
	}
	-- Theia Magnified Scope
	self.parts.wpn_fps_upg_o_leupold.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_leupold.stats = {
		value = 2,
		zoom = 10,
		concealment = -1
	}
	-- Box Buddy
	self.parts.wpn_fps_upg_o_box.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_box.stats = {
		value = 2,
		zoom = 10,
		concealment = -1
	}

	local sightlist = {"wpn_fps_upg_o_t1micro", "wpn_fps_upg_o_cmore", "wpn_fps_upg_o_reflex", "wpn_fps_upg_o_eotech_xps", "wpn_fps_upg_o_eotech", "wpn_fps_upg_o_rx30", "wpn_fps_upg_o_rx01", "wpn_fps_upg_o_docter", "wpn_fps_upg_o_cs", "wpn_fps_upg_o_specter", "wpn_fps_upg_o_aimpoint", "wpn_fps_upg_o_aimpoint_2", "wpn_fps_upg_o_acog", "wpn_fps_upg_o_spot", "wpn_fps_upg_o_bmg", "wpn_fps_upg_o_fc1", "wpn_fps_upg_o_uh"} -- all non-sniper sights
	local sightlist_noacog = {"wpn_fps_upg_o_t1micro", "wpn_fps_upg_o_cmore", "wpn_fps_upg_o_reflex", "wpn_fps_upg_o_eotech_xps", "wpn_fps_upg_o_eotech", "wpn_fps_upg_o_rx30", "wpn_fps_upg_o_rx01", "wpn_fps_upg_o_docter", "wpn_fps_upg_o_cs", "wpn_fps_upg_o_specter", "wpn_fps_upg_o_aimpoint", "wpn_fps_upg_o_aimpoint_2", } -- no acog/recon (extends too far back)
	-- parts that are not added to the sightlist for sniper-corrected overrides (because they're already correct)
	local sniper_concealment_parts = {{"wpn_fps_upg_o_leupold", -4+1}, {"wpn_fps_upg_o_box", -4+1}, {"inf_shortdot", -3}, {"wpn_fps_upg_o_shortdot", -3}, {"wpn_fps_upg_o_shortdot_vanilla", -3}} -- number is ('correct' concealment) - (actual part concealment)


	-- descriptions for sights on tiny weapons that mount them on some ridiculous front rail
	local wtfstopthat = {"wpn_fps_smg_cobray", "wpn_fps_smg_scorpion"}
	for a, wpn in pairs(wtfstopthat) do
		if not self[wpn].override then
			self[wpn].override = {}
		end
		for b, sight in pairs(sightlist) do
			self[wpn].override[sight] = {desc_id = "inf_sight_wtfstop"}
		end
	end

	local gunlist_snp = {{"wpn_fps_snp_msr", -3}, {"wpn_fps_snp_model70", -3}, {"wpn_fps_snp_r93", -3}, {"wpn_fps_snp_mosin", -3}, {"wpn_fps_snp_wa2000", -3}, {"wpn_fps_snp_desertfox", -3}, {"wpn_fps_snp_m95", -3}, {"wpn_fps_snp_tti", -3}, {"wpn_fps_snp_siltstone", -3}, {"wpn_fps_snp_r700", -3}}
	-- used to add correct conceal to sniper scopes after custom weapons have been added


	-- Marksman's Sight
	self.parts.wpn_upg_o_marksmansight_rear.stats = {
		value = 1,
		zoom = 0
	}
	-- 45-Degree Irons
	self.parts.wpn_fps_upg_o_45iron.stats = {
		value = 1,
		gadget_zoom = 2
	}
	-- 45-Degree Red Dot Sight
	self.parts.wpn_fps_upg_o_45rds.stats = {
		value = 1,
		gadget_zoom = 2
	}
	-- Riktpunkt 45-Degree Sight
	self.parts.wpn_fps_upg_o_45rds_v2.stats = {
		value = 1,
		gadget_zoom = 2
	}
	-- Riktpunkt Magnifier
	self.parts.wpn_fps_upg_o_xpsg33_magnifier.stats = {
		value = 1,
		gadget_zoom = 10,
		concealment = -1
	}
	-- The other magnifier (signature magnifier or whatever)
	self.parts.wpn_fps_upg_o_sig.stats = {
		value = 1,
		gadget_zoom = 10,
		concealment = -1
	}
	-- InF BUIS part
	self.parts.inf_buis.internal_part = true
	self.parts.inf_buis.a_obj = "a_s"
	self.parts.inf_buis.sub_type = "second_sight"
	self.parts.inf_buis.stats = {
		value = 1,
		gadget_zoom = 2
	}
	self.parts.inf_buis.stance_mod = {
		wpn_fps_ass_aug = {translation = Vector3(-0.12, -5, -3.4), rotation = Rotation(-0.15, 0.5, 0)}
	}
	for a, sight in pairs(sightlist) do
		self.wpn_fps_ass_aug.override[sight] = {forbids = deep_clone(self.parts[sight].forbids)}
		table.insert(self.wpn_fps_ass_aug.override[sight].forbids, "inf_buis")
	end
	table.insert(self.parts.wpn_upg_o_marksmansight_rear_vanilla.forbids, "inf_buis")
	self.wpn_fps_ass_aug.override.inf_buis = {desc_id = "bm_wp_inf_buis_desc_aug"}
	if BeardLib.Utils:ModLoaded("AUG A1 Kit") then
		table.insert(self.wpn_fps_ass_aug.uses_parts, "inf_buis")
	end


	-- Single Fire Lock/Lightened Bolt
	self.parts.wpn_fps_upg_i_singlefire.custom_stats = {inf_rof_mult = 0.90}
	self.parts.wpn_fps_upg_i_singlefire.sub_type = "autofire"
	self.parts.wpn_fps_upg_i_singlefire.perks = {}
	--self.parts.wpn_fps_upg_i_singlefire.forbids = {"wpn_fps_upg_pn_over", "wpn_fps_upg_pn_under"}
	self.parts.wpn_fps_upg_i_singlefire.stats = {
		value = 1,
	}
	-- Auto Fire Lock/Ultra-Light Bolt
	self.parts.wpn_fps_upg_i_autofire.custom_stats = {inf_rof_mult = 1.10}
	self.parts.wpn_fps_upg_i_autofire.perks = {}
	--self.parts.wpn_fps_upg_i_autofire.forbids = {"wpn_fps_upg_pn_over", "wpn_fps_upg_pn_under"}
	self.parts.wpn_fps_upg_i_autofire.stats = {
		value = 1,
	}


	-- NON-SIGHT GADGETS AND SHIT
	-- Tactical Laser Module
	self.parts.wpn_fps_upg_fl_ass_smg_sho_peqbox.stats = {
		value = 1,
		concealment = -1
	}
	-- Assault Light
	self.parts.wpn_fps_upg_fl_ass_smg_sho_surefire.stats = {
		value = 1,
		concealment = -1
	}
	-- Compact Laser Module
	self.parts.wpn_fps_upg_fl_ass_laser.stats = {
		value = 1,
	}
	-- Military Laser Module
	self.parts.wpn_fps_upg_fl_ass_peq15.stats = {
		value = 1,
		concealment = -2
	}
	-- LED Combo
	self.parts.wpn_fps_upg_fl_ass_utg.stats = {
		value = 2,
		concealment = -2
	}
	
	-- 45 degree ironsights
	-- Why why why does this *add* concealment in vanilla?
	self.parts.wpn_fps_upg_o_45steel.stats = {
		value = 1,
		gadget_zoom = 1,
		concealment = -1
	}

	-- Pocket Laser
	self.parts.wpn_fps_upg_fl_pis_laser.stats = {
		value = 1,
		concealment = -1
	}
	-- Tactical Pistol Light
	self.parts.wpn_fps_upg_fl_pis_tlr1.stats = {
		value = 1,
		concealment = -1
	}
	-- Polymer Flashlight
	self.parts.wpn_fps_upg_fl_pis_m3x.stats = {
		value = 1,
		concealment = -1
	}
	-- Micro Laser
	self.parts.wpn_fps_upg_fl_pis_crimson.stats = {
		value = 1,
	}
	-- Combined Module
	self.parts.wpn_fps_upg_fl_pis_x400v.stats = {
		value = 2,
		concealment = -2
	}



	-- GENERIC BARREL GARBAGE
	-- Stubby Compensator
	self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats = {
		value = 1,
		spread = 5,
		concealment = -1
	}
	-- Ported Compensator
	self.parts.wpn_fps_upg_ass_ns_battle.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	-- The Tank
	self.parts.wpn_fps_upg_ns_ass_smg_tank.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	-- Fire Breather
	self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats = {
		value = 1,
		spread = 2,
		recoil = 1,
		concealment = -1
	}
	-- Competitor's Compensator
	self.parts.wpn_fps_upg_ass_ns_jprifles.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	-- Tactical Compensator
	self.parts.wpn_fps_upg_ass_ns_surefire.stats = {
		value = 1,
		spread = 5,
		concealment = -1
	}
	-- Funnel of Fun Nozzle
	self.parts.wpn_fps_upg_ass_ns_linear.stats = {
		value = 1,
		spread = 2,
		recoil = 1,
		concealment = -1
	}

	-- IPSC Compensator
	self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats = {
		value = 1,
		spread = 5,
		concealment = -1
	}
	-- Facepunch Compensator
	self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	
	-- Typhoon Compensator
	self.parts.wpn_fps_upg_ns_pis_typhoon.stats = {
		value = 1,
		recoil = 1,
		spread = 2,
		concealment = -1
	}
	
	-- Marmon Compensator
	self.parts.wpn_fps_upg_ns_ass_smg_v6.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}

	-- The Bigger The Better
	self.parts.wpn_fps_upg_ns_ass_smg_large.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_ass_smg_large.stats = deep_clone(silstatsconc2)
	-- PBS Suppressor
	self.parts.wpn_fps_upg_ns_ass_pbs1.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_ass_pbs1.stats = deep_clone(silstatsconc2)
	-- Medium Suppressor
	self.parts.wpn_fps_upg_ns_ass_smg_medium.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = deep_clone(silstatsconc1)
	-- Size Doesn't Matter
	self.parts.wpn_fps_upg_ns_ass_smg_small.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_ass_smg_small.stats = deep_clone(silstatsconc0)



	-- Shark Teeth
	--self.parts.wpn_fps_upg_ns_shot_shark.custom_stats = {armor_piercing_sub = 0.80}
	self.parts.wpn_fps_upg_ns_shot_shark.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	-- King's Crown
	--self.parts.wpn_fps_upg_shot_ns_king.custom_stats = {armor_piercing_sub = 0.80}
	self.parts.wpn_fps_upg_shot_ns_king.stats = {
		value = 1,
		recoil = 2,
		concealment = -1
	}
	-- Donald's Horizontal Leveller
	self.parts.wpn_fps_upg_ns_duck.stats = {
		value = 1,
		spread_multi = {2.00, 0.5},
		concealment = -1
	}
	-- Silent Killer
	self.parts.wpn_fps_upg_ns_shot_thick.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_upg_ns_shot_thick.stats = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		damage = -3,
		spread = 10,
		recoil = 3,
		concealment = -2
	}
	-- Ssh!
	self.parts.wpn_fps_upg_ns_sho_salvo_large.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_upg_ns_sho_salvo_large.stats = {
		value = 1,
		suppression = 12,
		alert_size = 12,
		damage = -3,
		spread = 10,
		recoil = 3,
		concealment = -2
	}




	-- Flash Hider
	self.parts.wpn_fps_upg_pis_ns_flash.stats = {
		value = 1,
		spread = 2,
		recoil = 1,
		concealment = -1
	}


	-- Monolith Suppressor
	self.parts.wpn_fps_upg_ns_pis_large.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_large.stats = deep_clone(silstatsconc2)
	-- Asepsis Suppressor
	self.parts.wpn_fps_upg_ns_pis_medium_slim.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_medium_slim.stats = deep_clone(silstatsconc2)
	-- Jungle Ninja Suppressor
	self.parts.wpn_fps_upg_ns_pis_jungle.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_jungle.stats = deep_clone(silstatsconc2)
	-- Champion's Suppressor
	self.parts.wpn_fps_upg_ns_pis_large_kac.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_large_kac.stats = deep_clone(silstatsconc2)
	-- Standard Issue Suppressor
	self.parts.wpn_fps_upg_ns_pis_medium.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_medium.stats = deep_clone(silstatsconc1)
	-- Roctec Suppressor
	self.parts.wpn_fps_upg_ns_pis_medium_gem.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_medium_gem.stats = deep_clone(silstatsconc1)
	-- Size Doesn't Matter
	self.parts.wpn_fps_upg_ns_pis_small.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_pis_small.stats = deep_clone(silstatsconc0)
	-- Budget Suppressor
	self.parts.wpn_fps_upg_ns_ass_filter.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_ass_filter.stats = deep_clone(silstatsconc1)
	self.parts.wpn_fps_upg_ns_ass_filter.stats.concealment = -2



	-- VARIOUS GADGETS
	-- Military Laser Module
	self.parts.wpn_fps_upg_fl_ass_peq15.stats = {
		value = 1,
		concealment = -2
	}
	-- Compact Laser Module
	self.parts.wpn_fps_upg_fl_ass_laser.stats = {
		value = 1
	}
	-- lion bipod
	self.parts.wpn_fps_upg_bp_lmg_lionbipod.custom_stats = {recoil_horizontal_mult = 2}
	--
	--self.parts.inf_bipod_snp.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.inf_bipod_snp.forbids = {"wpn_fps_snp_mosin_b_obrez"}

	-- Internal bipod part
	self.parts.inf_bipod_part.perks = {
		"bipod"
	}

	if BeardLib.Utils:ModLoaded("Custom Attachment Points") or BeardLib.Utils:ModLoaded("WeaponLib") then
		table.insert(self.wpn_fps_snp_msr.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_model70.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_wa2000.uses_parts, "inf_bipod_snp") -- REMOVE LATER
		table.insert(self.wpn_fps_snp_r93.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_mosin.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_desertfox.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_r700.uses_parts, "inf_bipod_snp")
		--table.insert(self.wpn_fps_snp_m95.uses_parts, "inf_bipod_snp")
		table.insert(self.wpn_fps_snp_winchester.uses_parts, "inf_bipod_snp")
	end

	-- lmg offset
	--self.parts.inf_lmg_offset.internal_part = true
	self.parts.inf_lmg_offset.forbids = {"inf_lmg_offset_nongadget"}
	self.parts.inf_lmg_offset.stats = {
		value = 0,
		gadget_zoom = 2
	}
	self.parts.inf_lmg_offset.stance_mod = {
		wpn_fps_lmg_rpk = {translation = Vector3(4, 0, -1)},
		wpn_fps_lmg_mg42 = {translation = Vector3(4, 0, -1)},
		wpn_fps_lmg_hk21 = {translation = Vector3(4, 0, -1)},
		wpn_fps_lmg_m249 = {translation = Vector3(4, 0, -1)},
		wpn_fps_lmg_par = {translation = Vector3(4, 0, -1)},
		wpn_fps_lmg_m60 = {translation = Vector3(4, 0, -1)},
	}
	--self.parts.inf_lmg_offset_nongadget.internal_part = true
	self.parts.inf_lmg_offset_nongadget.forbids = {"inf_lmg_offset"}
	self.parts.inf_lmg_offset_nongadget.stance_mod = deep_clone(self.parts.inf_lmg_offset.stance_mod)


	-- SHOTGUN AMMO TYPES
	-- AP Slug
	self.parts.wpn_fps_upg_a_slug.custom_stats = {
		armor_piercing_add = 1,
		can_shoot_through_shield = true,
		can_shoot_through_wall = true,
		damage_far_mul = 5,
		damage_near_mul = 5,
		can_shoot_through_enemy = true,
		rays = 1,
		taser_hole = true,
		sdesc1 = "caliber_s12g_ap",
		sdesc3 = "range_shotslug",
		sdesc3_range_override = true
	}
	self.parts.wpn_fps_upg_a_slug.stats = {
		value = 0,
		damage = 8,
		spread = 20,
		spread_multi = {shotgun_slug_mult, shotgun_slug_mult}
	}
	-- 000 Buck
	self.parts.wpn_fps_upg_a_custom.custom_stats = {
		rays = 8,
		sdesc1 = "caliber_s12g_000"
	}
	self.parts.wpn_fps_upg_a_custom.stats = {
		value = 0,
		spread = -20,
		damage = 4
	}
	-- breacher rounds
	self.parts.wpn_fps_upg_a_custom_free.name_id = "bm_wp_upg_a_custom_free"
	self.parts.wpn_fps_upg_a_custom_free.desc_id = "bm_wp_upg_a_custom_free_desc"
	self.parts.wpn_fps_upg_a_custom_free.forbids = {"wpn_fps_upg_ns_shot_thick", "wpn_fps_upg_ns_sho_salvo_large", "wpn_fps_sho_aa12_barrel_silenced", "wpn_fps_sho_rota_b_silencer", "wpn_fps_sho_striker_b_suppressed"}
	self.parts.wpn_fps_upg_a_custom_free.custom_stats = {
		rays = 8,
		--damage_near = 300,
		--damage_far = 500,
		damage_near_mul = 0.20,
		damage_far_mul = 0.20,
		can_breach = true, breach_power_mult = 1, -- mult not functioning yet
		sdesc1 = "caliber_s12g_breach"
	}
	self.parts.wpn_fps_upg_a_custom_free.stats = {
		value = 0,
		damage = -10
	}
	-- HE-FRAG Rounds
	self.parts.wpn_fps_upg_a_explosive.custom_stats = {
		ignore_statistic = true,
		damage_far_mul = 10,
		damage_near_mul = 10,
		bullet_class = "InstantExplosiveBulletBase",
		rays = 1,
		ammo_pickup_min_mul = 0.75,
		ammo_pickup_max_mul = 0.75,
		sdesc1 = "caliber_s12g_he",
		sdesc3 = "range_shotslug",
		sdesc3_range_override = true
	}
	self.parts.wpn_fps_upg_a_explosive.stats = {
		value = 0,
		total_ammo_mod = -500,
		spread = 20,
		damage = 10,
		spread_multi = {shotgun_slug_mult, shotgun_slug_mult}
	}
	-- Flechette Rounds
	self.parts.wpn_fps_upg_a_piercing.custom_stats = {
		damage_near_mul = 1.25,
		damage_far_mul = 1.25,
		rays = 14,
		sdesc1 = "caliber_s12g_fl"
	}
	self.parts.wpn_fps_upg_a_piercing.stats = {
		value = 0,
		damage = -4,
		spread = 20
	}
	-- Dragon's Breath
	self.parts.wpn_fps_upg_a_dragons_breath.custom_stats = {
		armor_piercing_add = 1,
		ignore_statistic = true,
		muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath",
		bullet_class = "FlameBulletBase",
		--can_shoot_through_shield = true, -- go fuck yourself buddy
		rays = 12,
		fire_dot_data = {
			dot_trigger_chance = "100",
			dot_damage = "1.5",
			dot_length = "3.1",
			dot_trigger_max_distance = "1500",
			dot_tick_period = "0.5"
		},
		sdesc1 = "caliber_s12g_db",
		sdesc3 = "range_shotdb",
		sdesc3_range_override = true
	}
	self.parts.wpn_fps_upg_a_dragons_breath.stats = {
		value = 0,
		damage = -12,
		spread_multi = {1.25, 1.25},
		concealment = 0
	}


	-- show correct caliber for shotgun alternate ammo types
	self:inf_shotgun_ammo_overrides("wpn_fps_sho_boot", "s12g1887")
	self:inf_shotgun_ammo_overrides("wpn_fps_pis_judge", "s410")
	self:inf_shotgun_ammo_overrides("wpn_fps_pis_x_judge", "s410")



	-- Add CAR-4 parts to AMCAR
	-- Be honest, you just want this for the Throwback skin
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_upper_reciever_edge")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_upper_reciever_round")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_b_long")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_b_short")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_ass_m4_b_beowulf")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_draghandle_ballos")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_draghandle_core")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_ass_m4_upper_reciever_ballos")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_ass_m4_upper_reciever_core")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_ass_m4_lower_reciever_core")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_fg_rail")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_m4_uupg_fg_lr300")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_vg_ass_smg_afg")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_fg_jp")
	table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_fg_smr")
	
	-- Fix sound missing on non-Hawks soundpack heavy barrel
	self.parts.wpn_fps_upg_ass_m4_b_beowulf.sound_switch = nil

	-- SHARED AMCAR FAMILY/STANAG MAG PARTS
	-- burst-fire
	self.parts.inf_burst_only.internal_part = true
	self.parts.inf_burst_only.custom_stats = {has_burst_fire = true, burst_size = 3, adaptive_burst_size = false, inf_rof_mult = 1.2, anim_speed_mult = 1/1.2} -- makes rate of fire reflect on stats screen
	self.parts.inf_burst_only.perks = {"fire_mode_single"}
	self.parts.inf_burst_only.stats = deep_clone(nostats)
	self.parts.inf_burst.internal_part = true
	self.parts.inf_burst.custom_stats = {has_burst_fire = true, burst_size = 3, adaptive_burst_size = false, burst_fire_rate_multiplier = 1.2}
	self.parts.inf_burst.stats = deep_clone(nostats)
	
	-- Same as above but no RoF increase
	self.parts.inf_burst_only_norpm.internal_part = true
	self.parts.inf_burst_only_norpm.custom_stats = {has_burst_fire = true, burst_size = 3, adaptive_burst_size = false, inf_rof_mult = 1, anim_speed_mult = 1}
	self.parts.inf_burst_only_norpm.perks = {"fire_mode_single"}
	self.parts.inf_burst_only_norpm.stats = deep_clone(nostats)
	self.parts.inf_burst_norpm.internal_part = true
	self.parts.inf_burst_norpm.custom_stats = {has_burst_fire = true, burst_size = 3, adaptive_burst_size = false, burst_fire_rate_multiplier = 1}
	self.parts.inf_burst_norpm.stats = deep_clone(nostats)

	-- Same as above but 2-round bursts
	self.parts.inf_doubleburst_only_norpm.internal_part = true
	self.parts.inf_doubleburst_only_norpm.custom_stats = {has_burst_fire = true, burst_size = 2, adaptive_burst_size = false, inf_rof_mult = 1, anim_speed_mult = 1}
	self.parts.inf_doubleburst_only_norpm.perks = {"fire_mode_single"}
	self.parts.inf_doubleburst_only_norpm.stats = deep_clone(nostats)
	self.parts.inf_doubleburst_norpm.internal_part = true
	self.parts.inf_doubleburst_norpm.custom_stats = {has_burst_fire = true, burst_size = 2, adaptive_burst_size = false, burst_fire_rate_multiplier = 1}
	self.parts.inf_doubleburst_norpm.stats = deep_clone(nostats)
	
	-- Heavy Barrel
	self.parts.wpn_fps_upg_ass_m4_b_beowulf.custom_stats = {}
	self.parts.wpn_fps_upg_ass_m4_b_beowulf.stats = deep_clone(barrel_m2)
	self.wpn_fps_ass_m16.override.wpn_fps_upg_ass_m4_b_beowulf = {}
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_ass_m4_b_beowulf = {}
	-- CAR-4 300 blackout
	self.parts.inf_car4_blk.sub_type = "autofire"
--[[
	self.parts.inf_car4_blk.custom_stats = {
		rstance = InFmenu.rstance.hrifle,
		recoil_table = InFmenu.rtable.hrifle,
		recoil_loop_point = InFmenu.wpnvalues.hrifle.recoil_loop_point,
		ammo_pickup_min_mul = 0.667,
		ammo_pickup_max_mul = 0.667,
		sdesc1 = "caliber_r300blackout"
	}
	self.parts.inf_car4_blk.stats.total_ammo_mod = -333
--]]
	self.parts.inf_car4_blk.forbids = self.parts.inf_car4_blk.forbids or {}
	self:convert_part("inf_car4_blk", "lrifle", "mrifle")
	self.parts.inf_car4_blk.custom_stats.sdesc1 = "caliber_r300blackout"

	-- Long Barrel
	self.parts.wpn_fps_m4_uupg_b_long.stats = deep_clone(barrel_m2)
	-- Short Barrel
	self.parts.wpn_fps_m4_uupg_b_short.stats = deep_clone(barrel_p2)
	-- Milspec Magazine
	self.parts.wpn_fps_m4_uupg_m_std.stats = deep_clone(mag_133)
	self.parts.wpn_fps_m4_uupg_m_std.stats.extra_ammo = 10

	self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std.stats = deep_clone(mag_133)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std.stats.extra_ammo = self.parts.wpn_fps_m4_uupg_m_std.stats.extra_ammo * 2
	self.wpn_fps_ass_m16.override.wpn_fps_m4_uupg_m_std = {}
	self.wpn_fps_ass_amcar.override.wpn_fps_m4_uupg_m_std = {}
	-- Quadstack Killyourself
	self.parts.wpn_fps_upg_m4_m_quad.stats = deep_clone(mag_200)
	self.parts.wpn_fps_upg_m4_m_quad.stats.extra_ammo = 30

	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_quad = {}
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_quad.stats = deep_clone(mag_300)
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_quad.stats.extra_ammo = 40
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_quad.stats = deep_clone(mag_300)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_quad.stats.extra_ammo = 80
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_quad = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_quad)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_quad = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_quad)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_quad.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_quad.stats)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_quad.stats.extra_ammo = 60
	-- Tactical Mag
	self.parts.wpn_fps_upg_m4_m_pmag.stats = deep_clone(nostats)
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag.stats)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
	-- Expert Mag
	self.parts.wpn_fps_ass_l85a2_m_emag.stats = deep_clone(nostats)
	self.wpn_fps_smg_olympic.override.wpn_fps_ass_l85a2_m_emag = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_m16.override.wpn_fps_ass_l85a2_m_emag = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_amcar.override.wpn_fps_ass_l85a2_m_emag = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_ass_l85a2_m_emag = deep_clone(self.parts.wpn_fps_ass_l85a2_m_emag.stats)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_ass_l85a2_m_emag = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
	-- L5 Mag
	self.parts.wpn_fps_upg_m4_m_l5.stats = deep_clone(nostats)
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_l5 = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_l5 = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_l5 = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_l5 = deep_clone(self.parts.wpn_fps_upg_m4_m_l5.stats)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_l5 = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
	-- Speed Pull Mag
	self.parts.wpn_fps_m4_upg_m_quick.stats = deep_clone(nostats)
	self.wpn_fps_smg_olympic.override.wpn_fps_m4_upg_m_quick = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_m16.override.wpn_fps_m4_upg_m_quick = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_ass_amcar.override.wpn_fps_m4_upg_m_quick = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_m4_upg_m_quick = deep_clone(self.parts.wpn_fps_m4_upg_m_quick.stats)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_upg_m_quick = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
	-- Vintage Mag
	self.parts.wpn_fps_upg_m4_m_straight.stats = deep_clone(mag_66)
	self.parts.wpn_fps_upg_m4_m_straight.stats.extra_ammo = -10

	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_straight.stats = deep_clone(mag_66)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_straight.stats.extra_ammo = self.parts.wpn_fps_upg_m4_m_straight.stats.extra_ammo * 2
	--self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_straight.stats.reload = self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_straight.stats.reload + 20
	-- Uggo- Ergo Grip
	self.parts.wpn_fps_upg_m4_g_ergo.stats = deep_clone(nostats)
	-- Sniper Grip
	self.parts.wpn_fps_upg_m4_g_sniper.stats = deep_clone(nostats)
	-- Rubber Grip
	self.parts.wpn_fps_upg_m4_g_hgrip.stats = deep_clone(nostats)
	-- Straight Grip
	self.parts.wpn_fps_upg_m4_g_mgrip.stats = deep_clone(nostats)
	self.wpn_fps_snp_m95.override.wpn_fps_upg_m4_g_mgrip = {}
	
	-- Titanium Skeleton Grip
	self.parts.wpn_fps_upg_g_m4_surgeon.stats = deep_clone(nostats)

	-- Standard Stock
	self.parts.wpn_fps_upg_m4_s_standard.stats = deep_clone(nostats)
	-- Tactical Stock
	self.parts.wpn_fps_upg_m4_s_pts.stats = deep_clone(nostats)
	-- Wide Stock
	self.parts.wpn_fps_upg_m4_s_crane.stats = deep_clone(nostats)
	-- War-Torn Stock
	self.parts.wpn_fps_upg_m4_s_mk46.stats = deep_clone(nostats)
	-- Two-Piece Stock
	self.parts.wpn_fps_upg_m4_s_ubr.stats = deep_clone(nostats)

	-- Exotique
	self.parts.wpn_fps_m4_upper_reciever_edge.stats = deep_clone(nostats)
	-- Helios
	self.parts.wpn_fps_upg_ass_m4_upper_reciever_ballos.stats = deep_clone(nostats)
	-- Thrust Primus
	self.parts.wpn_fps_upg_ass_m4_upper_reciever_core.stats = deep_clone(nostats)
	-- Thrust Secundus
	self.parts.wpn_fps_upg_ass_m4_lower_reciever_core.stats = deep_clone(nostats)


	-- AMR-16 PARTS
	-- Railed Handguard
	self.parts.wpn_fps_m16_fg_railed.stats = deep_clone(nostats)
	-- Blast From the Past
	self.parts.wpn_fps_m16_fg_vietnam.stats = deep_clone(nostats)
	-- Long Ergonomic Handguard
	self.parts.wpn_fps_upg_ass_m16_fg_stag.stats = deep_clone(nostats)
	-- default carry handle
	table.insert(self.parts.wpn_fps_ass_m16_o_handle_sight.forbids, "inf_amr16_ironsretain")
	-- ironsight retain
	self.parts.inf_amr16_ironsretain.depends_on = "sight"
	-- full heavy rifle ammo
	self.parts.inf_amr16_har.internal_part = true
	self.parts.inf_amr16_har.sub_type = "autofire"
	self:convert_part("inf_amr16_har", "mrifle", "hrifle")
	self.parts.inf_amr16_har.custom_stats.sdesc1 = "caliber_r556x45m855"
	if BeardLib.Utils:ModLoaded("BipodM16") then
		self.parts.wpn_fps_m16_extra_bipod.adds = {"inf_bipod_part"}
		self.parts.wpn_fps_m16_extra_bipod.type = "bipod"
		self.parts.wpn_fps_m16_extra_bipod.custom_stats = {recoil_horizontal_mult = 2}
		self.parts.wpn_fps_m16_extra_bipod.stats = {
			value = 0,
			concealment = -1
		}
	end



	-- CAR-4 PARTS
	-- Stealth Barrel
	self.parts.wpn_fps_m4_uupg_b_sd.custom_stats = silencercustomstats
	self.parts.wpn_fps_m4_uupg_b_sd.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_m4_uupg_b_sd.stats.spread = 0
	self.parts.wpn_fps_m4_uupg_b_sd.stats.concealment = 0
	-- Aftermarket Special
	self.parts.wpn_fps_m4_uupg_fg_lr300.stats = deep_clone(nostats)
	-- Competition Handguard
	self.parts.wpn_fps_upg_fg_jp.stats = deep_clone(nostats)
	-- Gazelle Rail
	self.parts.wpn_fps_upg_fg_smr.stats = deep_clone(nostats)
	-- Lovis Handguard
	self.parts.wpn_fps_upg_ass_m4_fg_lvoa.stats = deep_clone(nostats)
	-- River Handguard
	self.parts.wpn_fps_upg_ass_m4_fg_moe.stats = deep_clone(nostats)
	-- Folding Stock
	self.parts.wpn_fps_m4_uupg_s_fold.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	-- default ironsight
	self.parts.wpn_fps_m4_uupg_o_flipup.forbids = {"wpn_fps_upg_o_xpsg33_magnifier", "inf_car4_ironsretain"}
	-- ironsight retain
	self.parts.inf_car4_ironsretain.forbids = {"wpn_fps_upg_o_xpsg33_magnifier", "wpn_fps_upg_o_acog", "wpn_fps_upg_o_spot"}
	self.parts.inf_car4_ironsretain.depends_on = "sight"



	-- PARA PARTS
	-- Medium Barrel
	self.parts.wpn_fps_m4_uupg_b_medium.stats = deep_clone(barrel_m2)
	-- Railed Handguard
	self.parts.wpn_fps_smg_olympic_fg_railed.stats = deep_clone(nostats)
	-- Aftermarket Shorty
	self.parts.wpn_fps_upg_smg_olympic_fg_lr300.stats = deep_clone(nostats)
	-- Shorter Than Short
	self.parts.wpn_fps_smg_olympic_s_short.stats = deep_clone(nostats)
	-- fire rate delimiter
	self.parts.inf_m231fpw.internal_part = true
	self.parts.inf_m231fpw.custom_stats = {inf_rof_mult = 1200/700, anim_speed_mult = 700/1200, chamber = 0, sdesc2 = "action_gas"}
	self.parts.inf_m231fpw.stats = {
		value = 0,
		spread = -25,
		recoil = -5,
		concealment = 0
	}


	-- Lightpis to mediumpis parts
	self:convert_part("inf_lightpis_to_mediumpis_ammo", "lightpis", "mediumpis")
	self.parts.inf_lightpis_to_mediumpis_ammo.custom_stats.sdesc1 = "caliber_p45acp"


	-- SHARED AK FAMILY PARTS
	-- RIFLE IS FINE
	self.parts.inf_ivan.override = {}
	self.parts.inf_ivan.internal_part = true
	self.parts.inf_ivan.stats = deep_clone(nostats)
	local akparts = {"wpn_upg_ak_fg_combo2", "wpn_upg_ak_fg_combo3", "wpn_upg_ak_fg_combo1", "wpn_upg_ak_fg_combo4", "wpn_fps_upg_m4_s_standard", "wpn_fps_upg_m4_s_pts", "wpn_upg_ak_s_folding", "wpn_upg_ak_s_psl", "wpn_fps_upg_ak_g_hgrip", "wpn_fps_upg_ak_g_pgrip", "wpn_fps_upg_ak_g_wgrip", "wpn_fps_upg_m4_s_crane", "wpn_fps_upg_m4_s_mk46", "wpn_fps_upg_ak_fg_tapco", "wpn_fps_upg_fg_midwest", "wpn_fps_upg_ak_b_draco", "wpn_fps_upg_ak_m_quad", "wpn_fps_upg_m4_s_ubr", "wpn_fps_upg_ak_g_rk3", "wpn_fps_upg_ak_s_solidstock", "wpn_fps_upg_o_ak_scopemount", "wpn_fps_upg_ak_m_uspalm", "wpn_fps_upg_ak_fg_krebs", "wpn_fps_upg_ak_fg_trax", "wpn_fps_upg_ak_b_ak105", "wpn_fps_upg_ass_ak_b_zastava", "wpn_fps_upg_ak_m_quick", "wpn_fps_snp_tti_s_vltor", "wpn_fps_smg_akmsu_fg_rail", "wpn_upg_ak_s_skfoldable", "wpn_fps_upg_ak_fg_zenit", "wpn_fps_sho_saiga_b_short", "wpn_upg_saiga_fg_lowerrail", "wpn_fps_sho_saiga_fg_holy", "wpn_fps_sho_basset_m_extended", "wpn_fps_pis_smolak_fg_polymer", "wpn_fps_pis_smolak_m_custom"} -- no sights, barrel attachments, or gadgets... yet?
	for a, b in ipairs(akparts) do
		if self.parts[b] then
			self.parts.inf_ivan.override[b] = {desc_id = self.parts[b].name_id .. "_desc_fine"}
		end
	end

	local akdmr_mag_location = "a_m"
	if BeardLib.Utils:ModLoaded("Custom Attachment Points") or BeardLib.Utils:ModLoaded("WeaponLib") then
		akdmr_mag_location = "a_m_dmr"
	end
	-- AK-74 DMR kit
	self.parts.inf_ak74_zastava.override = {
		wpn_fps_ass_74_m_standard = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_upg_ak_m_akm = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_upg_ak_m_akm_gold = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_fps_upg_ak_m_uspalm = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_fps_upg_ak_m_quick = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location}
	}
	self:convert_part("inf_ak74_zastava", "lrifle", "ldmr", nil, nil, 650, nil)
	self.parts.inf_ak74_zastava.custom_stats.sdesc1 = "caliber_r792mauser"
	self.parts.inf_ak74_zastava.stats.extra_ammo = -10
	self.parts.inf_ak74_zastava.stats.reload = -10
	self.parts.inf_ak74_zastava.forbids = {"wpn_fps_upg_ak_m_quad"}
	self.parts.inf_ak74_zastava.sub_type = "singlefire"
	self.parts.inf_ak74_zastava.perks = {"fire_mode_single"}
	-- AKM DMR kit
	self.parts.inf_akm_zastava.override = {
		wpn_fps_ass_74_m_standard = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_upg_ak_m_akm = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_upg_ak_m_akm_gold = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_fps_upg_ak_m_uspalm = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location},
		wpn_fps_upg_ak_m_quick = {unit = "units/pd2_dlc_big/weapons/wpn_fps_ass_fal_pts/wpn_fps_ass_fal_m_standard", third_unit = "units/pd2_dlc_big/weapons/wpn_third_ass_fal_pts/wpn_third_ass_fal_m_standard", a_obj = akdmr_mag_location}
	}
	self:convert_part("inf_akm_zastava", "mrifle", "ldmr", nil, nil, 600, nil)
	self.parts.inf_akm_zastava.custom_stats.sdesc1 = "caliber_r792mauser"
	self.parts.inf_akm_zastava.stats.extra_ammo = -10
	self.parts.inf_akm_zastava.forbids = {"wpn_fps_upg_ak_m_quad"}
	self.parts.inf_akm_zastava.sub_type = "singlefire"
	self.parts.inf_akm_zastava.perks = {"fire_mode_single"}
	-- dmr barrel
	self.wpn_fps_ass_74.override.wpn_fps_upg_ass_ak_b_zastava = {}
	self.parts.wpn_fps_upg_ass_ak_b_zastava.custom_stats = {}
	self.parts.wpn_fps_upg_ass_ak_b_zastava.stats = deep_clone(barrel_m2)
	-- Slavic Dragon Barrel
	self.parts.wpn_fps_upg_ak_b_draco.stats = deep_clone(barrel_p2)
	-- Modern Barrel
	self.parts.wpn_fps_upg_ak_b_ak105.stats = deep_clone(barrel_p1)
	-- Railed Wood Rail
	self.parts.wpn_upg_ak_fg_combo2.stats = deep_clone(nostats)
	-- Tactical Russian Handguard
	self.parts.wpn_upg_ak_fg_combo3.stats = deep_clone(nostats)
	-- Battleproven Handguard
	self.parts.wpn_fps_upg_ak_fg_tapco.stats = deep_clone(nostats)
	-- Lightweight Rail
	self.parts.wpn_fps_upg_fg_midwest.stats = deep_clone(nostats)
	-- Scarab Rail
	self.parts.wpn_fps_upg_ak_fg_krebs.stats = deep_clone(nostats)
	-- Sarcophagus Rail
	self.parts.wpn_fps_upg_ak_fg_trax.stats = deep_clone(nostats)
	-- Quadstack Trashical
	self.parts.wpn_fps_upg_ak_m_quad.forbids = {"inf_ak74_zastava", "inf_akm_zastava"}
	self.parts.wpn_fps_upg_ak_m_quad.stats = deep_clone(mag_200)
	self.parts.wpn_fps_upg_ak_m_quad.stats.extra_ammo = 30
	self.wpn_fps_smg_x_akmsu.override.wpn_fps_upg_ak_m_quad.stats = deep_clone(self.parts.wpn_fps_upg_ak_m_quad.stats)
	self.wpn_fps_smg_x_akmsu.override.wpn_fps_upg_ak_m_quad.stats.extra_ammo = self.wpn_fps_smg_x_akmsu.override.wpn_fps_upg_ak_m_quad.stats.extra_ammo * 2
	-- Low Drag Magazine
	self.parts.wpn_fps_upg_ak_m_uspalm.stats = deep_clone(nostats)
	self.wpn_fps_smg_x_akmsu.override.wpn_fps_upg_ak_m_uspalm.stats = deep_clone(nostats)
	-- Speed Pull Magazine
	self.parts.wpn_fps_upg_ak_m_quick.stats = deep_clone(nostats)
	-- Rubber Grip
	self.parts.wpn_fps_upg_ak_g_hgrip.stats = deep_clone(nostats)
	-- Plastic Grip
	self.parts.wpn_fps_upg_ak_g_pgrip.stats = deep_clone(nostats)
	-- Wood Grip
	self.parts.wpn_fps_upg_ak_g_wgrip.stats = deep_clone(nostats)
	-- Aluminum Grip
	self.parts.wpn_fps_upg_ak_g_rk3.stats = deep_clone(nostats)
	-- Underfolding Stock
	self.parts.wpn_upg_ak_s_folding.stats = deep_clone(nostats)
	-- Wooden Sniper Stock
	self.parts.wpn_upg_ak_s_psl.stats = {
		value = 0,
		spread = 5,
		recoil = 5,
		reload = -10,
		concealment = -2
	}
	-- Side-Folding Stock
	self.parts.wpn_upg_ak_s_skfoldable.stats = deep_clone(nostats)
	self.wpn_fps_smg_akmsu.override = self.wpn_fps_smg_akmsu.override or {}
	self.wpn_fps_smg_akmsu.override.wpn_upg_ak_s_skfoldable = {desc_id = "bm_wp_ak_s_skfoldable_akmsu_desc"}
	-- Solid Stock
	self.parts.wpn_fps_upg_ak_s_solidstock.stats = deep_clone(nostats)
	-- Scopemount
	self.parts.wpn_fps_upg_o_ak_scopemount.stats = deep_clone(nostats)


	-- SAIKA PARTS/IZHMA PARTS
	if not self.wpn_fps_shot_saiga.override then
		self.wpn_fps_shot_saiga.override = {}
	end
	self.wpn_fps_shot_saiga.override.wpn_fps_ass_akm_body_upperreceiver_vanilla = { 
		unit = "units/payday2/weapons/wpn_fps_ass_74_pts/wpn_fps_ass_74_body_upperreceiver" 
	}
	-- Short Barrel
	self.parts.wpn_fps_sho_saiga_b_short.stats = deep_clone(barrelsho_p3)
	-- Tactical Russian (Saiga)
	self.parts.wpn_upg_saiga_fg_lowerrail.stats = deep_clone(nostats)
	-- Hollow Handle
	self.parts.wpn_fps_sho_saiga_fg_holy.stats = deep_clone(nostats)


	-- KRINKOV PARTS
	-- default magazine
	self.wpn_fps_smg_akmsu.override = self.wpn_fps_smg_akmsu.override or {}
	self.wpn_fps_smg_akmsu.override.wpn_upg_ak_m_akm = { unit = "units/payday2/weapons/wpn_fps_ass_74_pts/wpn_fps_ass_74_m_standard", third_unit = "units/payday2/weapons/wpn_third_ass_74_pts/wpn_third_ass_74_m_standard" }
	self.wpn_fps_smg_x_akmsu.override.wpn_upg_ak_m_akm = self.wpn_fps_smg_akmsu.override.wpn_upg_ak_m_akm
	-- Moscow Special
	self.parts.wpn_fps_smg_akmsu_fg_rail.stats = deep_clone(nostats)
	-- Aluminum Handguard
	self.parts.wpn_fps_upg_ak_fg_zenit.stats = deep_clone(nostats)
	-- ksyukha full heavy rifle ammo
	self.parts.inf_akmsu_har.override = {
		wpn_upg_ak_m_akm = {unit = "units/payday2/weapons/wpn_fps_upg_ak_reusable/wpn_upg_ak_m_akm", third_unit = "units/payday2/weapons/wpn_third_upg_ak_reusable/wpn_third_upg_ak_m_akm"}
	}
	self.parts.inf_akmsu_har.sub_type = "autofire"
--[[
	self.parts.inf_akmsu_har.custom_stats = {rstance = InFmenu.rstance.hrifle, recoil_table = InFmenu.rtable.hrifle, recoil_loop_point = 9, ammo_pickup_min_mul = 0.75, ammo_pickup_max_mul = 0.75, armor_piercing_add = 0.20, sdesc1 = "caliber_r762x39"}
	self.parts.inf_akmsu_har.stats = {
		value = 0,
		total_ammo_mod = -250,
		damage = 25,
		recoil = -15,
		concealment = 0
	}
--]]
	--self:convert_part("inf_akmsu_har", "carbine", "mrifle", nil, InFmenu.wpnvalues.carbine.ammo - 30)
	self:convert_part("inf_akmsu_har", "carbine", "mcarbine")
	self.parts.inf_akmsu_har.custom_stats.sdesc1 = "caliber_r762x39"
--[[
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har = {}
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har.custom_stats = deep_clone(self.parts.inf_akmsu_har.custom_stats)
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har.custom_stats.ammo_pickup_min_mul = 0.666
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har.custom_stats.ammo_pickup_max_mul = 0.666
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har.stats = deep_clone(self.parts.inf_akmsu_har.stats)
	self.wpn_fps_smg_x_akmsu.override.inf_akmsu_har.stats.total_ammo_mod = -333
--]]



	-- AK5 PARTS
	-- CQB Barrel
	self.parts.wpn_fps_ass_ak5_b_short.stats = deep_clone(barrel_p2)
	-- Karbin Ceres
	self.parts.wpn_fps_ass_ak5_fg_ak5c.stats = deep_clone(nostats)
	-- Belgian Heat
	self.parts.wpn_fps_ass_ak5_fg_fnc.stats = deep_clone(nostats)
	-- Bertil Stock
	self.parts.wpn_fps_ass_ak5_s_ak5b.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Caesar Stock
	self.parts.wpn_fps_ass_ak5_s_ak5c.stats = deep_clone(nostats)


	-- CLARION PARTS
	-- Long Barrel
	self.parts.wpn_fps_ass_famas_b_long.stats = deep_clone(barrel_m1)
	-- Short Barrel
	self.parts.wpn_fps_ass_famas_b_short.stats = deep_clone(barrel_p1)
	-- Sniper Barrel
	self.parts.wpn_fps_ass_famas_b_sniper.stats = deep_clone(barrel_m2)
	-- Suppressed Barrel
	self.parts.wpn_fps_ass_famas_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_famas_b_suppressed.stats = deep_clone(silstatsconc2)
	-- G2 Grip
	self.parts.wpn_fps_ass_famas_g_retro.stats = deep_clone(nostats)


	-- COMMANDO 552 PARTS
	-- Long Barrel
	self.parts.wpn_fps_ass_s552_b_long.stats = deep_clone(barrel_m1)
	-- Enhanced Handguard
	self.parts.wpn_fps_ass_s552_fg_standard_green.stats = deep_clone(nostats)
	-- Railed Handguard
	self.parts.wpn_fps_ass_s552_fg_railed.stats = deep_clone(nostats)
	-- Enhanced Grip
	self.parts.wpn_fps_ass_s552_g_standard_green.stats = deep_clone(nostats)
	-- Enhanced Stock
	self.parts.wpn_fps_ass_s552_s_standard_green.stats = deep_clone(nostats)
	-- Heat Treated Body
	self.parts.wpn_fps_ass_s552_body_standard_black.stats = deep_clone(nostats)



	-- UAR PARTS
	-- Long Barrel
	self.parts.wpn_fps_aug_b_long.stats = deep_clone(barrel_m2)
	-- Short Barrel
	self.parts.wpn_fps_aug_b_short.stats = deep_clone(barrel_p2)
	-- A3 Tactical Foregrip
	self.parts.wpn_fps_aug_fg_a3.stats = deep_clone(nostats)
	-- Raptor Polymer Body
	self.parts.wpn_fps_aug_body_f90.stats = deep_clone(nostats)
	-- Speed Pull Mag
	self.parts.wpn_fps_ass_aug_m_quick.stats = deep_clone(nostats)
	if BeardLib.Utils:ModLoaded("AUG A1 Kit") then
		-- A1 body
		self.parts.wpn_fps_aug_body_aug_a1.stats = deep_clone(nostats)
		-- A3 body
		self.parts.wpn_fps_aug_body_aug_a3.stats = deep_clone(nostats)
		-- 42rnd Mag
		self.parts.wpn_fps_aug_m_a1_42.stats = deep_clone(mag_133)
		self.parts.wpn_fps_aug_m_a1_42.stats.extra_ammo = 10
		-- Swarovski Scope
		self.parts.wpn_fps_aug_o_scope_a1.custom_stats = {disallow_ads_while_reloading = true}
		self.parts.wpn_fps_aug_o_scope_a1.stats = {
			value = 0,
			zoom = 5,
			concealment = -2
		}

	end


	-- JP36 PARTS
	-- Compact Handguard
	self.parts.wpn_fps_ass_g36_fg_c.stats = deep_clone(barrel_p1)
	-- Polizei Special
	self.parts.wpn_fps_ass_g36_fg_ksk.stats = deep_clone(nostats)
	-- Long Handguard
	self.parts.wpn_fps_upg_g36_fg_long.stats = {
		value = 0,
		spread = 10,
		recoil = 2,
		reload = -10,
		concealment = -3
	}
	-- Speed Pull Mag
	self.parts.wpn_fps_ass_g36_m_quick.stats = deep_clone(nostats)
	-- Solid Stock
	self.parts.wpn_fps_ass_g36_s_kv.stats = deep_clone(nostats)
	-- Sniper Stock
	self.parts.wpn_fps_ass_g36_s_sl8.stats = deep_clone(stock_snp)
	-- Original Sight
	self.parts.wpn_fps_ass_g36_o_vintage.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_ass_g36_o_vintage.stats = {
		value = 0,
		zoom = 5,
		concealment = -2
	}
	if BeardLib.Utils:ModLoaded("BipodG36") and self.wpn_fps_g36_fg_bipod then
		Hooks:RemovePostHook("BipodG36") -- was causing g36c handguard to not replace barrel
		self.parts.wpn_fps_g36_fg_bipod.override = {
			wpn_fps_upg_g36_fg_long = {unit = "units/override/pd2_dlc_tng/weapons/wpn_fps_ass_g36_fg_long/wpn_fps_upg_g36_fg_long"}
		}
		self.parts.wpn_fps_g36_fg_bipod.forbids = {"wpn_fps_ass_g36_fg_c", "wpn_fps_ass_g36_fg_k", "wpn_fps_ass_g36_fg_ksk"}
		-- fixes barrel issues
		table.insert(self.parts.wpn_fps_ass_g36_fg_c.forbids, "wpn_fps_g36_fg_bipod")
		table.insert(self.parts.wpn_fps_ass_g36_fg_k.forbids, "wpn_fps_g36_fg_bipod")
		table.insert(self.parts.wpn_fps_ass_g36_fg_ksk.forbids, "wpn_fps_g36_fg_bipod")



		self.parts.wpn_fps_g36_fg_bipod.adds = {"inf_bipod_part"}
		self.parts.wpn_fps_g36_fg_bipod.type = "bipod"
		self.parts.wpn_fps_g36_fg_bipod.custom_stats = {recoil_horizontal_mult = 2}
		self.parts.wpn_fps_g36_fg_bipod.stats = {
			value = 0,
			concealment = -1
		}
	end


	-- QUEEN'S WRATH PARTS
	-- Versatile Handguard
	self.parts.wpn_fps_ass_l85a2_fg_short.stats = deep_clone(nostats)
	-- Prodigious Barrel
	self.parts.wpn_fps_ass_l85a2_b_long.stats = deep_clone(barrel_m2)
	-- Diminutive Barrel
	self.parts.wpn_fps_ass_l85a2_b_short.stats = deep_clone(barrel_p1)
	-- Delightful Grip
	self.parts.wpn_fps_ass_l85a2_g_worn.stats = deep_clone(nostats)


	-- LION'S ROAR PARTS
	-- CQB Barrel
	self.parts.wpn_fps_ass_vhs_b_short.stats = deep_clone(barrel_p1)
	-- Silenced Barrel
	self.parts.wpn_fps_ass_vhs_b_silenced.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_vhs_b_silenced.stats = deep_clone(silstatsconc2)
	-- Precision Barrel
	self.parts.wpn_fps_ass_vhs_b_sniper.stats = deep_clone(barrel_m2)
	-- Delightful Grip
	self.parts.wpn_fps_ass_l85a2_g_worn.stats = deep_clone(nostats)
	-- Delightful Grip
	self.parts.wpn_fps_ass_l85a2_g_worn.stats = deep_clone(nostats)


	-- BOOTLEG PARTS
	-- AML Barrel
	self.parts.wpn_fps_ass_tecci_b_long.stats = deep_clone(barrel_m1)
	-- Bootstrap Compensator
	self.parts.wpn_fps_ass_tecci_ns_special.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}


	-- MILLENIUM PARTS
	-- Dunes Tactical Receiver
	self.parts.wpn_fps_ass_corgi_body_lower_strap.stats = deep_clone(nostats)
	-- Short Barrel
	self.parts.wpn_fps_ass_corgi_b_short.stats = deep_clone(barrel_p2)
	-- fix ADS coord
--[[
	self.parts.wpn_fps_ass_corgi_dh_standard.stance_mod = {
		wpn_fps_ass_corgi = {translation = Vector3(0, -5, 0)}
	}
--]]


	-- AK12/AK.12/FLINT PARTS
	self.wpn_fps_ass_flint.adds = self.wpn_fps_ass_flint.adds or {}
	-- move sights closer
	self.parts.wpn_fps_ass_flint_body_upperreceiver.stance_mod = {
		wpn_fps_ass_flint = {translation = Vector3(0, -15, 0)}
	}
	self.parts.wpn_fps_ass_flint_o_standard.stance_mod = {
		wpn_fps_ass_flint = {translation = Vector3(0, 15, 0)}
	}
	-- don't fuck up custom sights
	-- sightdummy1: added to sights
	self.parts.inf_sightdummy = {
		a_obj = "a_m",
		type = "sightdummy",
		name_id = "bm_wp_flint_m_release_standard",
		unit = dummy,
		third_unit = dummy,
		stats = {value = 0, concealment = 0},
		stance_mod = {
			wpn_fps_ass_flint = {translation = Vector3(0, 15, 0)},
			wpn_fps_shot_m37primary = {translation = Vector3(0, 0, -0.61)}
		}
	}
	self.wpn_fps_ass_flint.adds.wpn_fps_upg_o_visionking = {"inf_sightdummy"}
	self.wpn_fps_ass_flint.adds.wpn_fps_upg_o_st10 = {"inf_sightdummy"}

	-- sightdummy2: forbidden by anything with a stance mod (except things that put forbids in their hooks but w/e i'll cross that bridge when i come to it)
	self.parts.inf_sightdummy2 = {
		a_obj = "a_m",
		type = "sightdummy",
		name_id = "bm_wp_flint_m_release_standard",
		unit = dummy,
		third_unit = dummy,
		stats = {value = 0, concealment = 0},
		stance_mod = {
--[[
			wpn_fps_ass_heffy_762 = {translation = Vector3(0, 0, -0.45)},
			wpn_fps_ass_heffy_939 = {translation = Vector3(0, 0, -0.45)},
			wpn_fps_ass_heffy_545 = {translation = Vector3(0, 0, -0.45)},
			wpn_fps_ass_heffy_556 = {translation = Vector3(0, 0, -0.45)}
--]]
		}
	}
	





	-- EAGLE HEAVY PARTS
	-- Long Barrel
	self.parts.wpn_fps_ass_scar_b_long.stats = deep_clone(barrel_m1)
	-- Short Barrel
	self.parts.wpn_fps_ass_scar_b_short.stats = deep_clone(barrel_p2)
	-- Rail Extension
	self.parts.wpn_fps_ass_scar_fg_railext.stats = deep_clone(nostats)
	-- Sniper Stock
	self.parts.wpn_fps_ass_scar_s_sniper.stats = deep_clone(stock_snp)


	-- FALCON PARTS
	-- CQB Handguard
	self.parts.wpn_fps_ass_fal_fg_01.stats = deep_clone(barrel_p2)
	-- Retro Handguard
	self.parts.wpn_fps_ass_fal_fg_03.stats = deep_clone(nostats)
	-- Marksman Handguard
	self.parts.wpn_fps_ass_fal_fg_04.stats = deep_clone(nostats)
	-- Wooden Handguard
	self.parts.wpn_fps_ass_fal_fg_wood.stats = deep_clone(nostats)
	-- Tactical Grip
	self.parts.wpn_fps_ass_fal_g_01.stats = deep_clone(nostats)
	-- Extended Magazine/Tercel
	self.parts.wpn_fps_ass_fal_m_01.stats = deep_clone(mag_200)
	self.parts.wpn_fps_ass_fal_m_01.stats.extra_ammo = 20
	-- CQB Stock
	self.parts.wpn_fps_ass_fal_s_01.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	-- Marksman Stock
	self.parts.wpn_fps_ass_fal_s_03.stats = deep_clone(stock_snp)
	-- Wooden Stock
	self.parts.wpn_fps_ass_fal_s_wood.stats = deep_clone(nostats)

	-- DMR Kit
	self:convert_part("inf_fnfal_dmrkit", "hrifle", "dmr", nil, nil, 700, nil)
	self.parts.inf_fnfal_dmrkit.custom_stats.sdesc1 = "caliber_r762x51dm151"
	self.parts.inf_fnfal_dmrkit.perks = {"fire_mode_single"}
	
	-- Forbid larger mag and fire rate mods
	self.parts.inf_fnfal_dmrkit.forbids = { "wpn_fps_ass_fal_m_01", "wpn_fps_upg_i_singlefire", "wpn_fps_upg_i_autofire" }

	-- Classic Kit
	self:convert_part("inf_fnfal_classickit", "hrifle", "mrifle")
	self.parts.inf_fnfal_classickit.custom_stats.sdesc1 = "caliber_r280"
	self.parts.inf_fnfal_classickit.stats.extra_ammo = 10

	-- GEWEHR 3 PARTS
	-- Sniper Barrel (G3 DMR kit)
	self:convert_part_half_a("wpn_fps_ass_g3_b_sniper", "hrifle", "dmr", nil, nil, 600, nil)
	self:convert_part_half_b("wpn_fps_ammo_type", "hrifle", "dmr", nil, nil, 600, nil)
	self.parts.wpn_fps_ass_g3_b_sniper.custom_stats.sdesc1 = "caliber_r762x51dm151"
	self.parts.wpn_fps_ass_g3_b_sniper.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_g3_b_sniper.forbids = self.parts.wpn_fps_ass_g3_b_sniper.forbids or {}
	self.parts.wpn_fps_ass_g3_b_sniper.perks = {"fire_mode_single"}
	table.insert(self.parts.wpn_fps_ass_g3_b_sniper.forbids, "wpn_fps_ass_g3_m_30mag") -- forbid g3 various attachment parts
	table.insert(self.parts.wpn_fps_ass_g3_b_sniper.forbids, "wpn_fps_ass_g3_m_50drum")
	-- Assault Kit
	self.parts.wpn_fps_ass_g3_b_short.stats = deep_clone(barrel_p1)
	-- Precision Handguard
	self.parts.wpn_fps_ass_g3_fg_psg.stats = deep_clone(nostats)
	-- Tactical Handguard
	self.parts.wpn_fps_ass_g3_fg_railed.stats = deep_clone(nostats)
	-- Wooden Handguard
	self.parts.wpn_fps_ass_g3_fg_retro.stats = deep_clone(nostats)
	-- Plastic Handguard
	self.parts.wpn_fps_ass_g3_fg_retro_plastic.stats = deep_clone(nostats)
	-- Retro Grip
	self.parts.wpn_fps_ass_g3_g_retro.stats = deep_clone(nostats)
	-- Precision Grip
	self.parts.wpn_fps_ass_g3_g_sniper.stats = deep_clone(nostats)
	-- Precision Stock
	self.parts.wpn_fps_ass_g3_s_sniper.stats = deep_clone(stock_snp)
	-- Wooden Stock
	self.parts.wpn_fps_ass_g3_s_wood.stats = deep_clone(nostats)
	if BeardLib.Utils:ModLoaded("BipodG3") then
		self.parts.wpn_fps_g3_fg_expbipod.type = "bipod"
		self.parts.wpn_fps_g3_fg_expbipod.adds = {"inf_bipod_part"}
		self.parts.wpn_fps_g3_fg_expbipod.custom_stats = {recoil_horizontal_mult = 2}
		self.parts.wpn_fps_g3_fg_expbipod.stats = {
			value = 0,
			concealment = -1
		}
	end


	-- AS VALKYRIA PARTS
	-- default parts
	self.parts.wpn_fps_ass_asval_b_standard.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_asval_s_standard.forbids = {"inf_asval_dmr"}
	self.parts.wpn_fps_ass_asval_scopemount.forbidden_by_sight_rail = true
	-- DMR rounds
	self:convert_part("inf_asval_dmr", "mrifle", "ldmr", nil, nil, 700, nil)
	self.parts.inf_asval_dmr.custom_stats.sdesc1 = "caliber_r9x39bp"
	self.parts.inf_asval_dmr.internal_part = true
	self.parts.inf_asval_dmr.sub_type = "singlefire"
	self.parts.inf_asval_dmr.perks = {"fire_mode_single"}
	self.parts.inf_asval_dmr.stats.extra_ammo = 0
	self.parts.inf_asval_dmr.stats.reload = -15
	-- HAR rounds
	self:convert_part("inf_asval_sp6", "mrifle", "hrifle")
	self.parts.inf_asval_sp6.custom_stats.sdesc1 = "caliber_r9x39sp6"
	self.parts.inf_asval_sp6.sub_type = "autofire"
	self.parts.inf_asval_sp6.internal_part = true
	-- Prototype Barrel
	self.parts.wpn_fps_ass_asval_b_proto.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_asval_b_proto.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_asval_b_proto.stats.alert_size = 12
	self.parts.wpn_fps_ass_asval_b_proto.stats.suppression = 12
	-- Solid Stock
	self.parts.wpn_fps_ass_asval_s_solid.custom_stats = {inf_rof_mult = 700/900}
	self.parts.wpn_fps_ass_asval_s_solid.stats = deep_clone(stock_snp)


	-- GALIL HAR PARTS
	-- FABulous Handguard
	self.parts.wpn_fps_ass_galil_fg_fab.stats = deep_clone(nostats)
	-- CQB Handguard
	self.parts.wpn_fps_ass_galil_fg_mar.stats = deep_clone(barrel_p2)
	-- Light Handguard
	self.parts.wpn_fps_ass_galil_fg_sar.stats = deep_clone(nostats)
	-- Sniper Handguard
	self.parts.wpn_fps_ass_galil_fg_sniper.stats = deep_clone(barrel_m1)

	-- Add bipod support to GALIL
	-- This code was originally inside the if-statement below, but this is unnecessary.
	local galilhandguards = {"wpn_fps_ass_galil_fg_standard", "wpn_fps_ass_galil_fg_sniper"}
	for a, part in pairs(galilhandguards) do
		self.parts[part].adds = self.parts[part].adds or {}
		table.insert(self.parts[part].adds, "inf_bipod_part")
		self.parts[part].custom_stats = self.parts[part].custom_stats or {}
		self.parts[part].custom_stats.recoil_horizontal_mult = 2
	end

	if BeardLib.Utils:ModLoaded("Bipod Galil") then
		self.parts.wpn_fps_ass_galil_bipod_folded.type = "bipod"
		self.parts.wpn_fps_ass_galil_bipod_folded.custom_stats = {recoil_horizontal_mult = 1/2}
		self.parts.wpn_fps_ass_galil_bipod_folded.stats = {
			value = 0,
			concealment = 1
		}
		DelayedCalls:Add("galilbipoddelay", delay, function(self, params)
			table.insert(tweak_data.weapon.factory.parts.wpn_fps_ass_galil_bipod_folded.forbids, "inf_bipod_part")
		end)
	end
	-- Sniper Grip
	self.parts.wpn_fps_ass_galil_g_sniper.stats = deep_clone(nostats)
	-- FABulous Stock
	self.parts.wpn_fps_ass_galil_s_fab.stats = deep_clone(nostats)
	-- Light Stock
	self.parts.wpn_fps_ass_galil_s_light.stats = deep_clone(nostats)
	-- Plastic Stock
	self.parts.wpn_fps_ass_galil_s_plastic.stats = deep_clone(nostats)
	-- Skeletal Stock
	self.parts.wpn_fps_ass_galil_s_skeletal.stats = deep_clone(nostats)
	-- Sniper Stock
	self.parts.wpn_fps_ass_galil_s_sniper.stats = deep_clone(stock_snp)
	-- Wooden Stock
	self.parts.wpn_fps_ass_galil_s_wood.stats = deep_clone(nostats)


	-- CAV-2000
	-- Appalachian Handguard
	self.parts.wpn_fps_ass_sub2000_fg_gen2.stats = deep_clone(nostats)
	-- Delabarre Handguard
	self.parts.wpn_fps_ass_sub2000_fg_railed.stats = deep_clone(nostats)
	-- Tooth Fairy Suppressor
	self.parts.wpn_fps_ass_sub2000_fg_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_sub2000_fg_suppressed.stats = deep_clone(silstatsconc0)



	-- LITTLE FRIEND PARTS
	-- default irons
	table.insert(self.parts.wpn_fps_ass_contraband_o_standard.forbids, "inf_contraband_ironsretain")


	





	-- M308 PARTS
	-- Abraham Body
	self.parts.wpn_fps_ass_m14_body_ebr.stats = deep_clone(nostats)
	-- Jaeger Body
	self.parts.wpn_fps_ass_m14_body_jae.stats = deep_clone(nostats)
	-- B-Team Stock
	-- Seriously fuck this thing's stats in vanilla, absolutely bullshit. Who thought of this?
	self.parts.wpn_fps_ass_m14_body_ruger.stats = deep_clone(nostats)
	-- Scope Mount
	self.parts.wpn_fps_upg_o_m14_scopemount.stats = deep_clone(nostats)

	-- Surplus special is just an ammo type based on a dummy, this is all you have to do
	self:convert_part("inf_m308_20rnd", "ldmr", "hrifle", nil, nil, 600, 700)
	self.parts.inf_m308_20rnd.custom_stats.sdesc1 = "caliber_r3006surplus"
	self.parts.inf_m308_20rnd.custom_stats.CAN_TOGGLE_FIREMODE = true
	self.parts.inf_m308_20rnd.sub_type = "autofire"

	if BeardLib.Utils:ModLoaded("BipodM14") then
		self.parts.wpn_fps_m14_extra_bipod.adds = {"inf_bipod_part"}
		self.parts.wpn_fps_m14_extra_bipod.type = "bipod"
		self.parts.wpn_fps_m14_extra_bipod.custom_stats = {recoil_horizontal_mult = 2}
		self.parts.wpn_fps_m14_extra_bipod.stats = {
			value = 0,
			concealment = -1
		}
	end


	-- GARAND PARTS
	-- Tanker Barrel
	self.parts.wpn_fps_ass_ching_b_short.stats = deep_clone(barrel_p2)
	-- don't do this shit you la-la man
	self.parts.wpn_fps_ass_ching_fg_railed.stats = deep_clone(nostats)
	-- Magpouch Stock
	self.parts.wpn_fps_ass_ching_s_pouch.stats = deep_clone(nostats)



	-- CONTRACTOR 308 PARTS
	-- Contractor Stock
	self.parts.wpn_fps_snp_tti_s_vltor.stats = deep_clone(nostats)
	-- Contractor Silencer
	self.parts.wpn_fps_snp_tti_ns_hex.custom_stats = silencercustomstats
	self.parts.wpn_fps_snp_tti_ns_hex.stats = deep_clone(silstatsconc2)
	-- Contractor Grip
	self.parts.wpn_fps_snp_tti_g_grippy.stats = deep_clone(nostats)


	-- SVD/GROM PARTS
	-- Tikho Barrel
	self.parts.wpn_fps_snp_siltstone_b_silenced.custom_stats = silencercustomstats
	self.parts.wpn_fps_snp_siltstone_b_silenced.stats = deep_clone(silstatsconc1)
	-- Grievky Compensator
	self.parts.wpn_fps_snp_siltstone_ns_variation_b.stats = deep_clone(nostats)
	-- Lightweight Handguard
	self.parts.wpn_fps_snp_siltstone_fg_polymer.stats = deep_clone(nostats)
	-- Lightweight Stock
	self.parts.wpn_fps_snp_siltstone_s_polymer.stats = deep_clone(nostats)
	-- iron sights
	self.parts.wpn_fps_snp_siltstone_iron_sight.custom_stats = {sdesc3 = "misc_irons"}
	self.parts.wpn_fps_snp_siltstone_iron_sight.stats = {
		value = 0,
		concealment = 3
	}


	-- RATTLESNAKE PARTS
	-- Long Barrel
	self.parts.wpn_fps_snp_msr_b_long.stats = deep_clone(barrel_m1)
	-- Sniper Suppressor
	self.parts.wpn_fps_snp_msr_ns_suppressor.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_msr_ns_suppressor.stats = deep_clone(silstatssnp)
	-- Tactical Aluminum Body
	self.parts.wpn_fps_snp_msr_body_msr.stats = deep_clone(nostats)


	-- MODEL 70 PARTS/PLATYPUS PARTS
	-- Beak Suppressor
	self.parts.wpn_fps_snp_model70_ns_suppressor.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_model70_ns_suppressor.stats = deep_clone(silstatssnp)
	-- Iron Sights
	self.parts.wpn_fps_snp_model70_iron_sight.custom_stats = {sdesc3 = "misc_irons"}
	self.parts.wpn_fps_snp_model70_iron_sight.stats = {
		value = 0,
		concealment = 3
	}



	-- LEBENSAUGER PARTS
	-- Langer Barrel
	self.parts.wpn_fps_snp_wa2000_b_long.stats = deep_clone(barrel_m1)
	-- Gedaempfter Barrel
	self.parts.wpn_fps_snp_wa2000_b_suppressed.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_wa2000_b_suppressed.stats = deep_clone(silstatssnp)
	-- Leichter Grip
	self.parts.wpn_fps_snp_wa2000_g_light.stats = deep_clone(nostats)
	-- Subtiler Grip
	self.parts.wpn_fps_snp_wa2000_g_stealth.stats = deep_clone(nostats)
	-- Walnuss Grip
	self.parts.wpn_fps_snp_wa2000_g_walnut.stats = deep_clone(nostats)
	--
	if BeardLib.Utils:ModLoaded("Bipod WA2000") then
		DelayedCalls:Add("wa2000bipoddelay", delay, function(self, params)
			table.insert(tweak_data.weapon.factory.parts.wpn_fps_snp_wa2000_bipod.adds, "inf_bipod_part")

			tweak_data.weapon.factory.parts.wpn_fps_snp_wa2000_nobipod.override.inf_bipod_snp = {
				override = {wpn_fps_snp_wa2000_body_standard = {unit = "units/mods/weapons/wpn_fps_snp_wa2000_pts/wpn_fps_snp_wa2000_body_nobipod"}}
			}
		end)
		self.parts.wpn_fps_snp_wa2000_bipod.type = "bipod"
		self.parts.wpn_fps_snp_wa2000_bipod.internal_part = false
		self.parts.wpn_fps_snp_wa2000_bipod.stats = {
			value = 0,
			concealment = -1
		}
		self.parts.wpn_fps_snp_wa2000_nobipod.type = "bipod"
		self.parts.wpn_fps_snp_wa2000_nobipod.internal_part = false
		self.parts.wpn_fps_snp_wa2000_nobipod.stats = {
			value = 0,
			recoil = -2,
			concealment = 1
		}
		self.wpn_fps_snp_wa2000.override = self.wpn_fps_snp_wa2000.override or {}
		self.wpn_fps_snp_wa2000.override.inf_bipod_snp = {
			override = {
				wpn_fps_snp_wa2000_body_standard = {unit = "units/mods/weapons/wpn_fps_snp_wa2000_pts/wpn_fps_snp_wa2000_body_nobipod"}
			}
		}
	end


	-- REPEATER 1873 PARTS
	-- long barrel
	self.parts.wpn_fps_snp_winchester_b_long.stats = deep_clone(barrel_m1)
	-- sshhh
	self.parts.wpn_fps_snp_winchester_b_suppressed.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_winchester_b_suppressed.stats = deep_clone(silstatssnp)
	-- ZOOM
	self.parts.wpn_fps_upg_winchester_o_classic.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_winchester_o_classic.stats = {
		value = 0,
		zoom = 10,
		concealment = -2
	}
	


	-- R93 PARTS
	-- Short Barrel
	self.parts.wpn_fps_snp_r93_b_short.stats = deep_clone(barrel_p2)
	-- Compensated Suppressor
	self.parts.wpn_fps_snp_r93_b_suppressed.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_r93_b_suppressed.stats = deep_clone(silstatssnp)
	-- Wooden Body
	self.parts.wpn_fps_snp_r93_body_wood.stats = deep_clone(nostats)


	-- MOSIN NAGANT PARTS
	-- Long Barrel
	self.parts.wpn_fps_snp_mosin_b_standard.stats = deep_clone(barrel_m2)
	-- Short Barrel
	self.parts.wpn_fps_snp_mosin_b_short.stats = deep_clone(barrel_p2)
	-- Silenced Barrel
	self.parts.wpn_fps_snp_mosin_b_sniper.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_mosin_b_sniper.stats = deep_clone(silstatssnp)
	-- BLACK BODY
	self.parts.wpn_fps_snp_mosin_body_black.stats = deep_clone(nostats)
	-- Bayonet
	self.parts.wpn_fps_snp_mosin_ns_bayonet.stats = {
		value = 0,
		min_damage = 10.0,
		max_damage = 10.0,
		min_damage_effect = 0.10,
		max_damage_effect = 0.10,
		concealment = -2,
		range = 100
	}
	-- Ironsight
	self.parts.wpn_fps_snp_mosin_iron_sight.custom_stats = {sdesc3 = "misc_irons"}
	self.parts.wpn_fps_snp_mosin_iron_sight.stats = {
		value = 0,
		concealment = 3
	}


	-- VULPESERDA PARTS
	-- Fennec Barrel
	self.parts.wpn_fps_snp_desertfox_b_long.stats = deep_clone(barrel_m2)
	-- Silenced Barrel
	self.parts.wpn_fps_snp_desertfox_b_silencer.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_desertfox_b_silencer.stats = deep_clone(silstatssnp)



	-- THANATOS PARTS
	-- Tank Buster
	self.parts.wpn_fps_snp_m95_barrel_long.stats = deep_clone(barrel_m2)
	-- CQB Barrel
	self.parts.wpn_fps_snp_m95_barrel_short.stats = {
		value = 0,
		spread = -20,
		recoil = -5,
		reload = 12,
		concealment = 3
	}
	-- Suppressed Barrel
	self.parts.wpn_fps_snp_m95_barrel_suppressed.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_m95_barrel_suppressed.stats = deep_clone(silstatssnp)
	self.parts.wpn_fps_snp_m95_barrel_suppressed.stats.concealment = -1
	-- bipod remover (beardlib)
	self.parts.inf_m95_nobipod.forbids = {"inf_bipod_part"}
	self.parts.inf_m95_nobipod.override = {
		wpn_fps_snp_m95_bipod = {unit = dummy, third_unit = dummy}
	}
	self.parts.wpn_fps_snp_m95_bipod.adds = {"inf_bipod_part"}
	
	-- R700 PARTS
	-- Military stock
	self.parts.wpn_fps_snp_r700_s_military.stats = {
		value = 1,
		reload = 5,
		concealment = -1
	}
	-- Tactical stock
	self.parts.wpn_fps_snp_r700_s_tactical.stats = deep_clone(nostats)

	self.parts.inf_50bmg_incendiary.sub_type = "ammo_dragons_breath"
	self.parts.inf_50bmg_incendiary.internal_part = true
	self.parts.inf_50bmg_incendiary.custom_stats = {
		sdesc1 = "caliber_r50bmgm8",
		bullet_class = "FlameBulletBase",
		can_shoot_through_shield = true,
		can_shoot_through_enemy = true,
		can_shoot_through_wall = true,
		--rays = 1,
		fire_dot_data = {
			dot_trigger_chance = "100",
			dot_damage = "1.5",
			dot_length = "3.1",
			dot_trigger_max_distance = "10000", -- 100m
			dot_tick_period = "0.5"
		}
	}
	self.parts.inf_50bmg_incendiary.stats = deep_clone(nostats)

	self.parts.inf_50bmg_raufoss.sub_type = "ammo_explosive"
	self.parts.inf_50bmg_raufoss.internal_part = true
	self.parts.inf_50bmg_raufoss.custom_stats = {
		sdesc1 = "caliber_r50bmgmk211",
		bullet_class = "InstantExplosiveBulletBase",
		ignore_statistic = true,
		can_shoot_through_shield = true,
		can_shoot_through_enemy = true,
		can_shoot_through_wall = true,
		--rays = 1,
		fire_dot_data = {
			dot_trigger_chance = "100",
			dot_damage = "1.5",
			dot_length = "3.1",
			dot_trigger_max_distance = "10000", -- 100m
			dot_tick_period = "0.5"
		},
		bullet_damage_fraction = 0.80,
		ammo_pickup_max_mul = 0.50,
		visor_dmg_mult = 1.5
	}
	self.parts.inf_50bmg_raufoss.stats = deep_clone(nostats)
	-- don't allow this shit to be used without the crash fix
	if not BeardLib.Utils:ModLoaded("Fix Custom Weapon Dragons Breath Crash") then
		self.parts.wpn_fps_snp_m95_magazine.forbids = self.parts.wpn_fps_snp_m95_magazine.forbids or {}
		table.insert(self.parts.wpn_fps_snp_m95_magazine.forbids, "inf_50bmg_raufoss")
		table.insert(self.parts.wpn_fps_snp_m95_magazine.forbids, "inf_50bmg_incendiary")
		self.parts.inf_50bmg_raufoss.desc_id = "bm_wp_inf_50bmg_raufoss_restricted_desc"
		self.parts.inf_50bmg_incendiary.desc_id = "bm_wp_inf_50bmg_raufoss_restricted_desc"
	end

	-- Marlin Model 1895/Bernetti Rangehitter parts
	-- Long barrel
	-- The barrel shortens the mag tube for some reason, so the gun should get better stats than other long barrels at the cost of capacity
	self.parts.wpn_fps_snp_sbl_b_long.stats = {
		value = 2,
		spread = 8,
		recoil = 5,
		concealment = -1,
		extra_ammo = -1
	}
	-- Silenced barrel (wind whistler)
	-- NOT a short barrel at all. Not even slightly.
	-- This also basically halves the tube so also cut down the mag capacity here
	self.parts.wpn_fps_snp_sbl_b_short.stats = {
		value = 2,
		suppression = 12,
		alert_size = 12,
		recoil = 6,
		concealment = -1,
		extra_ammo = -2
	}
	self.parts.wpn_fps_snp_sbl_b_short.custom_stats = deep_clone(snpsilencercustomstats)
	-- Magpouch stock
	self.parts.wpn_fps_snp_sbl_s_saddle.stats = deep_clone(nostats)

	-- Ironsights (scope removal)
	self.parts.inf_marlin1895_ironsights.stats = {
		value = 0,
		concealment = 3
	}
	local pivot_shoulder_translation = Vector3(0, 0, 0)
	local pivot_shoulder_rotation = Rotation(0, 0, 0)
	local pivot_head_translation = Vector3(0, 0, -0.8)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.parts.inf_marlin1895_ironsights.stance_mod = {
		wpn_fps_snp_sbl = {
			translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation),
			rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		}
	}
	

	-- QBU-88 parts
	-- Short barrel
	self.parts.wpn_fps_snp_qbu88_b_short.stats = deep_clone(barrel_p1)
	-- Long barrel
	self.parts.wpn_fps_snp_qbu88_b_long.stats = deep_clone(barrel_m1)
	-- Extended mag
	self.parts.wpn_fps_snp_qbu88_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_snp_qbu88_m_extended.stats.extra_ammo = 5

	-- CMP PARTS
	-- Extended Magazine
	self.parts.wpn_fps_smg_mp9_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_smg_mp9_m_extended.stats.extra_ammo = 15
	self.wpn_fps_smg_x_mp9.override.wpn_fps_smg_mp9_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_mp9_m_extended.stats)
	self.wpn_fps_smg_x_mp9.override.wpn_fps_smg_mp9_m_extended.stats.extra_ammo = self.wpn_fps_smg_x_mp9.override.wpn_fps_smg_mp9_m_extended.stats.extra_ammo * 2
	-- Skeletal Stock
	self.parts.wpn_fps_smg_mp9_s_skel.stats = deep_clone(stock_snp)
	-- Tactical Suppressor
	self.parts.wpn_fps_smg_mp9_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_mp9_b_suppressed.stats = deep_clone(silstatsconc2)


	-- SPECOPS SMG PARTS
	-- Extended Mag
	self.parts.wpn_fps_smg_mp7_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_smg_mp7_m_extended.stats.extra_ammo = 20
	self.wpn_fps_smg_x_mp7.override.wpn_fps_smg_mp7_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_mp7_m_extended.stats)
	self.wpn_fps_smg_x_mp7.override.wpn_fps_smg_mp7_m_extended.stats.extra_ammo = self.wpn_fps_smg_x_mp7.override.wpn_fps_smg_mp7_m_extended.stats.extra_ammo * 2
	-- MP7 suppressor
	self.parts.wpn_fps_smg_mp7_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_mp7_b_suppressed.stats = deep_clone(silstatsconc2)
	-- Extended Stock
	self.parts.wpn_fps_smg_mp7_s_long.stats = {
		value = 0,
		recoil = 4,
		concealment = -1
	}


	-- SWEDISH K PARTS
	-- Swedish Barrel
	self.parts.wpn_fps_smg_m45_b_green.stats = deep_clone(nostats)
	-- Grease Barrel
	self.parts.wpn_fps_smg_m45_b_small.stats = deep_clone(barrel_p2)
	-- Swedish Body
	self.parts.wpn_fps_smg_m45_body_green.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_smg_m45_g_ergo.stats = deep_clone(nostats)
	-- Bling Grip
	self.parts.wpn_fps_smg_m45_g_bling.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_smg_m45_m_extended.stats = deep_clone(mag_133)
	self.parts.wpn_fps_smg_m45_m_extended.stats.extra_ammo = 14
	self.wpn_fps_smg_x_m45.override.wpn_fps_smg_m45_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_m45_m_extended.stats)
	self.wpn_fps_smg_x_m45.override.wpn_fps_smg_m45_m_extended.stats.extra_ammo = self.wpn_fps_smg_x_m45.override.wpn_fps_smg_m45_m_extended.stats.extra_ammo * 2
	-- Folded Stock
	self.parts.wpn_fps_smg_m45_s_folded.stats = {
		value = 0,
		recoil = -4,
		concealment = 1
	}


	-- KOBUS 90 PARTS
	-- Long Barrel
	self.parts.wpn_fps_smg_p90_b_long.stats = deep_clone(barrel_m2)
	-- Civilian Market Barrel
	self.parts.wpn_fps_smg_p90_b_civilian.stats = deep_clone(barrel_m2)
	-- Mall Ninja
	self.parts.wpn_fps_smg_p90_b_ninja.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_p90_b_ninja.stats = deep_clone(silstatsconc2)
	-- Speed Pull Mag
	self.parts.wpn_fps_smg_p90_m_strap.stats = deep_clone(nostats)
	-- Custom Assault Frame
	self.parts.wpn_fps_smg_p90_body_boxy.stats = deep_clone(nostats)

	-- PDW AP Kit
	-- Applies to P90 and MP7
	self.parts.inf_pdw_apkit.stats = {
		spread = 3,
		recoil = -3,
		damage = -3
	}
	self.parts.inf_pdw_apkit.custom_stats = {
		can_shoot_through_enemy = true,
		can_shoot_through_shield = true,
		can_shoot_through_wall = true,
		pen_shield_dmg_mult = 0.5,
		pen_wall_dmg_mult = 1,
		ammo_pickup_max_mul = 0.5
	}

	-- COMPACT-5 PARTS
	-- Sehr Kurz
	self.parts.wpn_fps_smg_mp5_fg_m5k.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- Polizei Tactical
	self.parts.wpn_fps_smg_mp5_fg_mp5a5.stats = deep_clone(nostats)
	-- The Ninja
	self.parts.wpn_fps_smg_mp5_fg_mp5sd.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_mp5_fg_mp5sd.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_smg_mp5_fg_mp5sd.stats.concealment = 0
	-- Enlightened Handguard
	self.parts.wpn_fps_smg_mp5_fg_flash.stats = {
		value = 0,
		concealment = -1
	}
	-- Adjustable Stock
	self.parts.wpn_fps_smg_mp5_s_adjust.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	-- Spartan Stock
	self.parts.wpn_fps_smg_mp5_s_folding.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	-- Bare Essentials
	self.parts.wpn_fps_smg_mp5_s_ring.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
	self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_ring = {desc_id = ""}
	-- Straight Magazine
	self.parts.wpn_fps_smg_mp5_m_straight.custom_stats = {sdesc1 = "caliber_p10", armor_piercing_add = 0.13}
	self.parts.wpn_fps_smg_mp5_m_straight.stats = {
		value = 0,
		damage = 10,
		recoil = -10,
		concealment = 0
	}
if BeardLib.Utils:ModLoaded("MP5K FG") then
	self.parts.wpn_fps_smg_mp5_fg_stripped.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	primarysmgadds_specific.wpn_fps_smg_mp5primary = primarysmgadds_specific.wpn_fps_smg_mp5primary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_fg_stripped")
end


	-- SIGNATURE MPX PARTS
	self.wpn_fps_smg_shepheard.override = self.wpn_fps_smg_shepheard.override or {}
	self.wpn_fps_smg_shepheard.override.wpn_fps_smg_shepheard_dh_standard = {
		stance_mod = {
			wpn_fps_smg_shepheard = {translation = Vector3(0, -10, 0)}
		}
	}
	self.wpn_fps_smg_shepheardprimary.override = self.wpn_fps_smg_shepheardprimary.override or {}
	self.wpn_fps_smg_shepheardprimary.override.wpn_fps_smg_shepheard_dh_standard = {
		stance_mod = {
			wpn_fps_smg_shepheard = {translation = Vector3(0, -10, 0)}
		}
	}
	-- Short Handguard
	self.parts.wpn_fps_smg_shepheard_body_short.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- Extended Magazine
	self.parts.wpn_fps_smg_shepheard_mag_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_smg_shepheard_mag_extended.stats.extra_ammo = 15
	self.wpn_fps_smg_x_shepheard.override.wpn_fps_smg_shepheard_mag_extended.stats = deep_clone(self.parts.wpn_fps_smg_shepheard_mag_extended.stats)
	self.wpn_fps_smg_x_shepheard.override.wpn_fps_smg_shepheard_mag_extended.stats.extra_ammo = self.wpn_fps_smg_x_shepheard.override.wpn_fps_smg_shepheard_mag_extended.stats.extra_ammo * 2
	self.wpn_fps_smg_x_shepheard.override.wpn_fps_smg_shepheard_mag_extended.stats.reload = self.wpn_fps_smg_x_shepheard.override.wpn_fps_smg_shepheard_mag_extended.stats.reload - 15
	-- No Stock
	self.parts.wpn_fps_smg_shepheard_s_no.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}


	-- MP40 PARTS
	-- Folded Stock
	self.parts.wpn_fps_smg_shepheard_s_no.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}



	-- MARK 10 PARTS
	-- Railed Handguard
	self.parts.wpn_fps_smg_mac10_body_ris.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Extended Mag
	self.parts.wpn_fps_smg_mac10_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_smg_mac10_m_extended.stats.extra_ammo = 15
	self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_mac10_m_extended.stats)
	self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_extended.stats.extra_ammo = self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_extended.stats.extra_ammo * 2
	-- Speed Pull Mag
	self.parts.wpn_fps_smg_mac10_m_quick.stats = deep_clone(mag_200)
	self.parts.wpn_fps_smg_mac10_m_quick.stats.extra_ammo = 15
	self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick.stats = deep_clone(self.parts.wpn_fps_smg_mac10_m_quick.stats)
	self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick.stats.extra_ammo = self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick.stats.extra_ammo * 2
	--self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick.stats.reload = self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick.stats.reload - 5
	-- Skeletal Stock
	self.parts.wpn_fps_smg_mac10_s_skel.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	-- Custom Built Frame
	self.parts.wpn_fps_smg_mac10_body_modern.stats = deep_clone(nostats)


	-- KOBRA PARTS
	-- skorpion suppressor
	self.parts.wpn_fps_smg_scorpion_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_scorpion_b_suppressed.stats = deep_clone(silstatsconc1)
	-- Wood Grip
	self.parts.wpn_fps_smg_scorpion_g_wood.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_smg_scorpion_g_ergo.stats = deep_clone(nostats)
	-- "Extended" Mag
	self.parts.wpn_fps_smg_scorpion_m_extended.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_smg_scorpion_m_extended.stats = {
		value = 0,
		recoil = 5,
		reload = -20,
		concealment = -1
	}
	self.wpn_fps_smg_x_scorpion.override.wpn_fps_smg_scorpion_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_scorpion_m_extended.stats)
	-- No Stock
	self.parts.wpn_fps_smg_scorpion_s_nostock.stats = {
		value = 0,
		recoil = -3,
		concealment = 1
	}
	-- Unfolded Stock
	self.parts.wpn_fps_smg_scorpion_s_unfolded.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}


	-- BLASTER 9 PARTS
	-- Short Barrel
	self.parts.wpn_fps_smg_tec9_b_standard.stats = deep_clone(barrel_p2)
	-- Ghetto Blaster
	self.parts.wpn_fps_smg_tec9_ns_ext.stats = deep_clone(barrel_m2)
	-- hold it sideways for maximum accuracy
	self.parts.wpn_fps_smg_tec9_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_tec9_m_extended.stats.extra_ammo = 12
	self.wpn_fps_smg_x_tec9.override.wpn_fps_smg_tec9_m_extended.stats = deep_clone(self.parts.wpn_fps_smg_tec9_m_extended.stats)
	self.wpn_fps_smg_x_tec9.override.wpn_fps_smg_tec9_m_extended.stats.extra_ammo = self.wpn_fps_smg_x_tec9.override.wpn_fps_smg_tec9_m_extended.stats.extra_ammo * 2
	-- Just Bend It
	self.parts.wpn_fps_smg_tec9_s_unfolded.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}

	-- Remove firemode internals from tec9

	local autofire_index = nil
	local singlefire_index = nil
	for i,v in pairs(self.wpn_fps_smg_tec9.uses_parts) do
		if v == "wpn_fps_upg_i_autofire" then
			autofire_index = i
		end
		if v == "wpn_fps_upg_i_singlefire" then
			singlefire_index = i
		end
	end

	-- One weird trick to remove elements from a table without jumbling up the indexes of the next elements to remove, software engineers hate him!
	table.remove(self.wpn_fps_smg_tec9.uses_parts, math.max(autofire_index, singlefire_index))
	table.remove(self.wpn_fps_smg_tec9.uses_parts, math.min(autofire_index, singlefire_index))

	autofire_index = nil
	singlefire_index = nil

	for i,v in pairs(self.wpn_fps_smg_x_tec9.uses_parts) do
		if v == "wpn_fps_upg_i_autofire" then
			autofire_index = i
		end
		if v == "wpn_fps_upg_i_singlefire" then
			singlefire_index = i
		end
	end

	table.remove(self.wpn_fps_smg_x_tec9.uses_parts, math.max(autofire_index, singlefire_index))
	table.remove(self.wpn_fps_smg_x_tec9.uses_parts, math.min(autofire_index, singlefire_index))

	-- Full-auto conversion
	self.parts.inf_fullauto_conversion.sub_type = "autofire"
	self.parts.inf_fullauto_conversion.perks = {
		"fire_mode_auto"
	}

	-- VERTEX PARTS/VECTOR PARTS
	-- Precision Barrel
	self.parts.wpn_fps_smg_polymer_barrel_precision.stats = deep_clone(barrel_m2)
	-- HPS suppressor
	self.parts.wpn_fps_smg_polymer_ns_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_polymer_ns_silencer.stats = deep_clone(silstatsconc1)



	-- UZI PARTS
	-- Silent Death
	self.parts.wpn_fps_smg_uzi_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_uzi_b_suppressed.stats = deep_clone(silstatsconc1)
	-- Tactical Foregrip
	self.parts.wpn_fps_smg_uzi_fg_rail.stats = deep_clone(nostats)
	-- Ergo Stock
	self.parts.wpn_fps_smg_uzi_s_leather.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Solid Stock
	self.parts.wpn_fps_smg_uzi_s_solid.stats = {
		value = 0,
		recoil = 3,
		concealment = -2
	}
	-- Folded Stock
	self.parts.wpn_fps_smg_uzi_s_standard.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}


	-- MINI UZI
	-- Custom Barrel
	self.parts.wpn_fps_smg_baka_b_comp.stats = deep_clone(nostats)
	-- Spring Suppressor
	self.parts.wpn_fps_smg_baka_b_smallsupp.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_baka_b_smallsupp.stats = deep_clone(silstatsconc0)
	-- Maki Suppressor
	self.parts.wpn_fps_smg_baka_b_midsupp.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_baka_b_midsupp.stats = deep_clone(silstatsconc1)
	-- Futomako Suppressor
	self.parts.wpn_fps_smg_baka_b_longsupp.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_baka_b_longsupp.stats = deep_clone(silstatsconc2)
	-- No Stock
	self.parts.wpn_fps_smg_baka_s_standard.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	-- Unfolded Stock
	self.parts.wpn_fps_smg_baka_s_unfolded.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Add No Stock to Akimbo mini uzi
	table.insert(self.wpn_fps_smg_x_baka.uses_parts, "wpn_fps_smg_baka_s_standard")
	if not self.wpn_fps_smg_x_baka.override then
		self.wpn_fps_smg_x_baka.override = {}
	end
	table.insert(self.wpn_fps_smg_x_baka.override, { stats = { value = 0, recoil = -1, concealment = 1 } })


	-- VERESK PARTS
	-- Unfolded Stock
	self.parts.wpn_fps_smg_sr2_s_unfolded.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Tishina Suppressor
	self.parts.wpn_fps_smg_sr2_ns_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_sr2_ns_silencer.stats = deep_clone(silstatsconc2)
	-- Speed Pull Mag
	self.parts.wpn_fps_smg_sr2_m_quick.stats = deep_clone(nostats)



	-- PATCHETT PARTS
	-- Long Barrel
	self.parts.wpn_fps_smg_sterling_b_long.stats = deep_clone(barrel_m2)
	-- Short Barrel
	self.parts.wpn_fps_smg_sterling_b_short.stats = deep_clone(barrel_p2)
	-- Suppressed Barrel
	self.parts.wpn_fps_smg_sterling_b_suppressed.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_sterling_b_suppressed.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_smg_sterling_b_suppressed.stats.concealment = -1
	-- Heatsinked Suppressed Barrel
	self.parts.wpn_fps_smg_sterling_b_e11.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_sterling_b_e11.stats = deep_clone(silstatsconc0)
	-- Long Magazine
	self.parts.wpn_fps_smg_sterling_m_long.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_sterling_m_long.stats.extra_ammo = 10
	self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_long.stats = deep_clone(self.parts.wpn_fps_smg_sterling_m_long.stats)
	self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_long.stats.extra_ammo = self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_long.stats.extra_ammo * 2
	-- Short Magazine
	self.parts.wpn_fps_smg_sterling_m_short.stats = deep_clone(mag_66)
	self.parts.wpn_fps_smg_sterling_m_short.stats.extra_ammo = -9
	self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_short.stats = deep_clone(self.parts.wpn_fps_smg_sterling_m_short.stats)
	self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_short.stats.extra_ammo = self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_short.stats.extra_ammo * 2
	self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_short.stats.reload = self.wpn_fps_smg_x_sterling.override.wpn_fps_smg_sterling_m_short.stats.reload + 10
	-- Folded Stock
	self.parts.wpn_fps_smg_sterling_s_folded.stats = {
		value = 0,
		recoil = -4,
		concealment = 1
	}
	-- No Stock
	self.parts.wpn_fps_smg_sterling_s_nostock.stats = {
		value = 0,
		recoil = -8,
		concealment = 2
	}
	-- Solid Stock
	self.parts.wpn_fps_smg_sterling_s_solid.stats = {
		value = 0,
		recoil = 4,
		concealment = -1
	}


	-- CHICAGO TYPEWRITER PARTS
	-- Long Barrel
	self.parts.wpn_fps_smg_thompson_barrel_long.stats = {
		value = 0,
		spread = 10,
		recoil = 6,
		reload = -8,
		concealment = -2
	}
	-- Stubby Barrel
	self.parts.wpn_fps_smg_thompson_barrel_short.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- Black Foregrip
	self.parts.wpn_fps_smg_thompson_foregrip_discrete.stats = deep_clone(nostats)
	-- Black Grip
	self.parts.wpn_fps_smg_thompson_grip_discrete.stats = deep_clone(nostats)
	-- Black Stock
	self.parts.wpn_fps_smg_thompson_stock_discrete.stats = deep_clone(nostats)
	-- QD Sling Stock
	self.parts.wpn_fps_smg_thompson_stock_nostock.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}


	-- JACKET'S PIECE PARTS
	-- 80s Calling
	self.parts.wpn_fps_smg_cobray_body_upper_jacket.stats = deep_clone(nostats)
	-- Slotted Barrel Extension
	self.parts.wpn_fps_smg_cobray_ns_barrelextension.stats = {
		value = 0,
		spread = 5,
		recoil = 5,
		reload = -10,
		concealment = -3
	}
	-- Werbell's Suppressor
	self.parts.wpn_fps_smg_cobray_ns_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_cobray_ns_silencer.stats = deep_clone(silstatsconc2)

	-- Gripless
	self.parts.cobray_body_lower_nofg.stats = deep_clone(nostats)
	self.parts.cobray_body_lower_nofg.weapon_hold_override = {
		wpn_fps_smg_cobray = "scorpion",
		bm_w_cobray = "scorpion"
	}
	self.parts.x_cobray_body_lower_nofg.stats = deep_clone(nostats)
	self.parts.x_cobray_body_lower_nofg.weapon_hold_override = nil

	self.parts.cobray_body_lower_jacket_nofg.stats = deep_clone(nostats)
	self.parts.cobray_body_lower_jacket_nofg.weapon_hold_override = {
		wpn_fps_smg_cobray = "scorpion",
		bm_w_cobray = "scorpion"
	}
	self.parts.x_cobray_body_lower_jacket_nofg.stats = deep_clone(nostats)
	self.parts.x_cobray_body_lower_jacket_nofg.weapon_hold_override = nil

	-- Gripless steelsight tweak
	local pivot_shoulder_translation = Vector3(1.4316, 28.7626, -1.04143)
	local pivot_shoulder_rotation = Rotation(0.106668, -0.0849211, 0.628574)
	local pivot_head_translation = Vector3(0, 15, 0)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.parts.cobray_body_lower_nofg.stance_mod = {
		wpn_fps_smg_cobray = {
			translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation),
			rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		}
	}
	self.parts.cobray_body_lower_jacket_nofg.stance_mod = {
		wpn_fps_smg_cobray = {
			translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation),
			rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
		}
	}


	-- IMPACT-45 PARTS/JACKAL PARTS
	-- Civilian Barrel
	self.parts.wpn_fps_smg_schakal_b_civil.stats = deep_clone(barrel_m2)
	-- Long Magazine
	self.parts.wpn_fps_smg_schakal_m_long.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_schakal_m_long.stats.extra_ammo = 15
	self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_long.stats = deep_clone(self.parts.wpn_fps_smg_schakal_m_long.stats)
	self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_long.stats.extra_ammo = self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_long.stats.extra_ammo * 2
	-- Short Magazine
	self.parts.wpn_fps_smg_schakal_m_short.stats = deep_clone(mag_33)
	self.parts.wpn_fps_smg_schakal_m_short.stats.extra_ammo = -15
	self.parts.wpn_fps_smg_schakal_m_short.stats.damage = InFmenu.wpnvalues.hrifle.damage - InFmenu.wpnvalues.longsmg.damage
	self.parts.wpn_fps_smg_schakal_m_short.stats.reload = math.floor(self.parts.wpn_fps_smg_schakal_m_short.stats.reload/2) -- i hate these fucking mags so much
	self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_short.stats = deep_clone(self.parts.wpn_fps_smg_schakal_m_short.stats)
	self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_short.stats.extra_ammo = self.wpn_fps_smg_x_schakal.override.wpn_fps_smg_schakal_m_short.stats.extra_ammo * 2
	-- Silentgear Suppressor
	self.parts.wpn_fps_smg_schakal_ns_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_schakal_ns_silencer.stats = deep_clone(silstatsconc1)
	-- Civilian Stock
	self.parts.wpn_fps_smg_schakal_s_civil.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}
	-- Folded Stock
	self.parts.wpn_fps_smg_schakal_s_folded.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	-- Twinkle Grip
	self.parts.wpn_fps_smg_schakal_vg_surefire.stats = deep_clone(nostats)



	-- CZ 805B PARTS
	-- Short Barrel
	self.parts.wpn_fps_smg_hajk_b_short.stats = deep_clone(barrel_p2)
	-- Medium Barrel
	self.parts.wpn_fps_smg_hajk_b_medium.stats = deep_clone(barrel_p1)

	-- Vityaz parts
	-- Silenced barrel
	self.parts.wpn_fps_smg_vityaz_b_supressed.stats = deep_clone(silstatsconc1)
	self.parts.wpn_fps_smg_vityaz_b_supressed.custom_stats = deep_clone(silencercustomstats)
	-- Long barrel
	self.parts.wpn_fps_smg_vityaz_b_long.stats = deep_clone(barrel_m1)
	-- Bull stock (no stock)
	self.parts.wpn_fps_smg_vityaz_s_short.stats = {
		value = 1,
		concealment = 2,
		recoil = -5
	}




	-- REINFELD FAMILY PARTS
	-- Shell Rack (also modified under remington various parts)
	self.parts.wpn_fps_shot_r870_body_rack.stats = {
		value = 0,
		reload = 5,
		concealment = -1
	}
	-- Extended Tube
	self.parts.wpn_fps_shot_r870_m_extended.stats = {
		value = 0,
		extra_ammo = 1,
		concealment = -1
	}
	-- Short Enough Tactical Stock (rail, no stock)
	self.parts.wpn_fps_shot_r870_s_nostock_big.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	-- Short Enough Tactical (no stock)
	self.parts.wpn_fps_shot_r870_s_nostock.stats = {
		value = 0,
		recoil = -2,
		concealment = 2
	}
	-- Government Issue Tactical (rail, stock)
	self.parts.wpn_fps_shot_r870_s_solid_big.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- no stock, block-type receiver rail
	--wpn_fps_shot_r870_s_nostock_single
	-- block-type receiver rail?
	--wpn_fps_shot_r870_s_solid_single

	-- Muldon Stock
	self.parts.wpn_fps_shot_r870_s_folding.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.wpn_fps_shot_serbu.override.wpn_fps_shot_r870_s_folding = {
		stats = {
			value = 0,
			recoil = 2,
			concealment = -1
		}
	}


	-- REINBECK PARTS
	-- Zombie Hunter Pump
	self.parts.wpn_fps_shot_r870_fg_wood.stats = deep_clone(nostats)


	-- LOCOMOTIVE PARTS
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_a_slug = nil
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_a_custom = nil
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_a_custom_free = nil
	-- Extended Tube
	self.parts.wpn_fps_shot_shorty_m_extended_short.stats = {
		value = 0,
		extra_ammo = 1,
		concealment = -1
	}
	-- Solid Stock
	self.parts.wpn_fps_shot_r870_s_solid.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	-- Tactical Shorty (rail, no stock) (also modified under remington various parts)
	self.parts.wpn_fps_shot_shorty_s_nostock_short.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Police Shorty (rail, stock)
	self.parts.wpn_fps_shot_shorty_s_solid_short.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	-- don't fucking use these stocks on a shotgun you disgusting shitbag
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard = {
		stats = {
			value = 0,
			recoil = 3,
			concealment = -2
		}
	}

	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_pts = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_crane = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_mk46 = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_ubr = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard

	-- MOSCONI PARTS
	self.wpn_fps_shot_huntsman.override.wpn_fps_upg_a_explosive = nil
	-- Road Warrior
	self.parts.wpn_fps_shot_huntsman_b_short.stats = deep_clone(db_barrel)
	-- Gangster Special
	self.parts.wpn_fps_shot_huntsman_s_short.stats = deep_clone(db_stock)


	-- JOCELINE PARTS
	self.wpn_fps_shot_b682.override.wpn_fps_upg_a_explosive = nil
	-- Short Barrel
	self.parts.wpn_fps_shot_b682_b_short.stats = deep_clone(db_barrel)
	-- Wrist Wrecker
	self.parts.wpn_fps_shot_b682_s_short.stats = deep_clone(db_stock)
	-- Luxurious Ammo Pouch
	self.parts.wpn_fps_shot_b682_s_ammopouch.stats = deep_clone(nostats)


	-- CLAIRE PARTS
	self.wpn_fps_sho_coach.override.wpn_fps_upg_a_explosive = nil
	-- Sawed-Off Barrel
	self.parts.wpn_fps_sho_coach_b_short.stats = deep_clone(db_barrel)
	-- Deadman's Stock
	self.parts.wpn_fps_sho_coach_s_short.stats = deep_clone(db_stock)



	-- M1014 PARTS
	-- Short Barrel
	self.parts.wpn_fps_sho_ben_b_short.stats = deep_clone(barrelshoammo_p2)
	self.parts.wpn_fps_sho_ben_b_short.stats.extra_ammo = -2
	-- Long Barrel
	self.parts.wpn_fps_sho_ben_b_long.stats = deep_clone(barrelshoammo_m1)
	self.parts.wpn_fps_sho_ben_b_long.stats.extra_ammo = 1
	-- Collapsed Stock
	self.parts.wpn_fps_sho_ben_s_collapsed.stats = {
		value = 0,
		recoil = -6,
		concealment = 2
	}
	-- Solid Stock
	self.parts.wpn_fps_sho_ben_s_solid.stats = {
		value = 0,
		recoil = 3,
		concealment = -2
	}


	-- RAVEN PARTS
	-- Long Barrel
	self.parts.wpn_fps_sho_ksg_b_long.stats = deep_clone(barrelshoammo_m2)
	self.parts.wpn_fps_sho_ksg_b_long.stats.extra_ammo = 4
	self.parts.wpn_fps_sho_ksg_b_long.stats.spread = 5
	-- Short Barrel
	self.parts.wpn_fps_sho_ksg_b_short.stats = deep_clone(barrelshoammo_p2)
	self.parts.wpn_fps_sho_ksg_b_short.stats.extra_ammo = -4
	self.parts.wpn_fps_sho_ksg_b_short.stats.spread = -5
	-- Flip-Up Sight
	self.parts.wpn_fps_upg_o_mbus_rear.stats = deep_clone(nostats)


	-- SPAS PARTS
	-- mesa nero/half-life mode (pump/doubleshot)
	self.parts.inf_spas_valve.internal_part = true
	self.parts.inf_spas_valve.custom_stats = {inf_rof_mult = 120/360, anim_speed_mult = 360/120, override_hold = "r870_shotgun", sdesc2 = "action_spas_valve", has_burst_fire = true, burst_size = 2, adaptive_burst_size = false, burst_fire_rate_table = {10, 0.7}, burst_recoil_table = {0, 2}}
	self.parts.inf_spas_valve.stats = {
		value = 0,
		damage = 5,
		concealment = 0
	}
	-- vichingo/sven coop mode (pump/semi)
	self.parts.inf_spas_sven.internal_part = true
	self.parts.inf_spas_sven.custom_stats = {inf_rof_mult = 120/360, anim_speed_mult = 360/120, override_hold = "r870_shotgun", burst_override_hold = "benelli", sdesc2 = "action_spas_sven", has_burst_fire = true, burst_size = 50, adaptive_burst_size = true, burst_fire_rate_multiplier = 3, delayed_burst_recoil = false} -- burst_spread_mult = 1.25
	self.parts.inf_spas_sven.stats = deep_clone(nostats)
	-- Extended Tube
	self.parts.wpn_fps_sho_b_spas12_long.stats = {
		value = 0,
		extra_ammo = 2,
		concealment = -1
	}
	-- Folded Stock
	self.parts.wpn_fps_sho_s_spas12_folded.stats = {
		value = 0,
		recoil = -3,
		concealment = 1
	}
	-- No Stock
	self.parts.wpn_fps_sho_s_spas12_nostock.stats = {
		value = 0,
		recoil = -6,
		concealment = 2
	}
	-- Solid Stock
	self.parts.wpn_fps_sho_s_spas12_solid.stats = {
		value = 0,
		recoil = 3,
		concealment = -1
	}


	-- FIREBRAND PARTS
	-- slightly longer barrel
	self.parts.wpn_fps_sho_aa12_barrel_long.stats = deep_clone(barrelsho_m1)
	-- pew
	self.parts.wpn_fps_sho_aa12_barrel_silenced.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_sho_aa12_barrel_silenced.stats = deep_clone(silstatssho)
	-- drum mag
	--self.parts.wpn_fps_sho_aa12_mag_drum.custom_stats = {ammo_pickup_min_mul = 0.83, ammo_pickup_max_mul = 0.83}
	self.parts.wpn_fps_sho_aa12_mag_drum.stats = deep_clone(mag_250)
	self.parts.wpn_fps_sho_aa12_mag_drum.stats.extra_ammo = 12
	self.parts.wpn_fps_sho_aa12_mag_drum.stats.concealment = -5


	-- BREAKER PARTS
	-- Short Barrel
	self.parts.wpn_fps_sho_boot_b_short.stats = deep_clone(barrelshoammo_p2)
	self.parts.wpn_fps_sho_boot_b_short.stats.extra_ammo = -1
	self.parts.wpn_fps_sho_boot_b_short.stats.spread = -15
	-- Long Barrel
	self.parts.wpn_fps_sho_boot_b_long.stats = deep_clone(barrelshoammo_m2)
	self.parts.wpn_fps_sho_boot_b_long.stats.extra_ammo = 1
	-- Long Stock
	self.parts.wpn_fps_sho_boot_s_long.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}
	-- Treated Body
	self.parts.wpn_fps_sho_boot_body_exotic.stats = deep_clone(nostats)



	-- M37 PARTS
	--
	self.parts.wpn_fps_shot_m37_b_short.stats = deep_clone(barrelsho_p2)
	--
	self.parts.wpn_fps_shot_m37_s_short.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	self.parts.wpn_fps_shot_m37_m_standard.stance_mod = {
		wpn_fps_shot_m37 = {translation = Vector3(0, 1, 0)}
	}


	-- GOLIATH PARTS
	-- Short Barrel
	self.parts.wpn_fps_sho_rota_b_short.stats = deep_clone(barrelsho_p1)
	-- Silenced Barrel
	self.parts.wpn_fps_sho_rota_b_silencer.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_sho_rota_b_silencer.stats = deep_clone(silstatssho)
	self.parts.wpn_fps_sho_rota_b_silencer.stats.recoil = math.floor(self.parts.wpn_fps_sho_rota_b_silencer.stats.recoil/2)
	self.parts.wpn_fps_sho_rota_b_silencer.stats.concealment = 0


	-- STREET SWEEPER PARTS
	self.wpn_fps_sho_striker.override.wpn_fps_upg_a_slug = nil
	self.wpn_fps_sho_striker.override.wpn_fps_upg_a_custom = nil
	self.wpn_fps_sho_striker.override.wpn_fps_upg_a_custom_free = nil
	-- Long Barrel
	self.parts.wpn_fps_sho_striker_b_long.stats = deep_clone(barrelsho_m1)
	-- Suppressed Barrel
	self.parts.wpn_fps_sho_striker_b_suppressed.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_sho_striker_b_suppressed.stats = deep_clone(silstatssho)


	-- GRIMM PARTS
	-- Little Brother Foregrip
	self.parts.wpn_fps_sho_basset_fg_short.stats = deep_clone(barrelsho_p2)
	-- Extended Magazine
	self.parts.wpn_fps_sho_basset_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_sho_basset_m_extended.stats.extra_ammo = 3
	self.wpn_fps_sho_x_basset.override.wpn_fps_sho_basset_m_extended.stats = deep_clone(self.parts.wpn_fps_sho_basset_m_extended.stats)
	self.wpn_fps_sho_x_basset.override.wpn_fps_sho_basset_m_extended.stats.extra_ammo = self.wpn_fps_sho_x_basset.override.wpn_fps_sho_basset_m_extended.stats.extra_ammo * 2


	-- JUDGE PARTS
	self.wpn_fps_pis_judge.override.wpn_fps_upg_a_piercing = nil
	self.wpn_fps_pis_judge.override.wpn_fps_upg_a_explosive = nil
	self.wpn_fps_pis_x_judge.override.wpn_fps_upg_a_explosive = nil
	self.wpn_fps_pis_x_judge.override.wpn_fps_upg_a_piercing = nil
	-- Custom Reinforced Frame
	self.parts.wpn_fps_pis_judge_body_modern.stats = deep_clone(nostats)

	-- TRENCH GUN/WINCHESTER MODEL 1897/REINFELD 88 PARTS
	-- Long barrel
	self.parts.wpn_fps_shot_m1897_b_long.stats = deep_clone(barrelsho_m1)
	-- Ventilated barrel, not actually that much shorter so we'll take it
	self.parts.wpn_fps_shot_m1897_b_short.stats = deep_clone(nostats)
	-- Artisan Stock
	-- You should be ashamed of yourself
	self.parts.wpn_fps_shot_m1897_s_short.stats = deep_clone(nostats)

	-- Mossberg 590/Mosconi 12G Tactical Shotgun parts
	-- Silenced barrel
	self.parts.wpn_fps_sho_m590_b_suppressor.stats = deep_clone(silstatssho)
	self.parts.wpn_fps_sho_m590_b_suppressor.custom_stats = deep_clone(silencercustomstats)
	-- Long barrel+long tube
	self.parts.wpn_fps_sho_m590_b_long.stats = deep_clone(barrelsho_m1)
	self.parts.wpn_fps_sho_m590_b_long.stats.extra_ammo = 1
	-- Rail body
	self.parts.wpn_fps_sho_m590_body_rail.stats = deep_clone(nostats)



	-- CHIMANO FAMILY PARTS
	-- Ventilated Compensator
	self.parts.wpn_fps_pis_g18c_co_1.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Velocity Compensator
	self.parts.wpn_fps_pis_g18c_co_comp_2.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Ugly Magazine
	self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = 14
	-- overrides for akimbos
	self.wpn_fps_pis_x_g22c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats = deep_clone(self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats)
	self.wpn_fps_pis_x_g22c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = self.wpn_fps_pis_x_g22c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo * 2
	self.wpn_fps_pis_x_g17.override.wpn_fps_pis_g18c_m_mag_33rnd.stats = deep_clone(self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats)
	self.wpn_fps_pis_x_g17.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = self.wpn_fps_pis_x_g17.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo * 2
	-- chimano compact uses a standard glock mag instead
	self.wpn_fps_pis_g26.override.wpn_fps_pis_g18c_m_mag_33rnd = {
		stats = deep_clone(mag_200),
		unit = "units/payday2/weapons/wpn_fps_pis_g17_pts/wpn_fps_pis_g17_m_standard",
		third_unit = "units/payday2/weapons/wpn_third_pis_g17_pts/wpn_third_pis_g17_m_standard"
	}
	self.wpn_fps_pis_g26.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = 7
	self.wpn_fps_jowi.override.wpn_fps_pis_g18c_m_mag_33rnd.stats = deep_clone(self.wpn_fps_pis_g26.override.wpn_fps_pis_g18c_m_mag_33rnd.stats)
	self.wpn_fps_jowi.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = self.wpn_fps_jowi.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo * 2

	self.wpn_fps_jowi.override.wpn_fps_pis_g18c_m_mag_33rnd.unit = "units/payday2/weapons/wpn_fps_pis_g17_pts/wpn_fps_pis_g17_m_standard"
	self.wpn_fps_jowi.override.wpn_fps_pis_g18c_m_mag_33rnd.third_unit = "units/payday2/weapons/wpn_third_pis_g17_pts/wpn_third_pis_g17_m_standard"
	-- akimbo stryks
	self.wpn_fps_pis_x_g18c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats = deep_clone(self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats)
	self.wpn_fps_pis_x_g18c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo = self.wpn_fps_pis_x_g18c.override.wpn_fps_pis_g18c_m_mag_33rnd.stats.extra_ammo * 2
	-- Ergo Grip
	self.parts.wpn_fps_pis_g18c_g_ergo.stats = deep_clone(nostats)
	-- Platypus Grip
	self.parts.wpn_fps_pis_g26_g_gripforce.stats = deep_clone(nostats)
	-- Grip Laser
	self.parts.wpn_fps_pis_g26_g_laser.stats = deep_clone(nostats)
	

	-- STRYK 18C PARTS
	-- Ugly Fucking Stock
	self.parts.wpn_fps_pis_g18c_s_stock.stats = {
		value = 0,
		spread = 5,
		recoil = 2,
		reload = -10,
		concealment = -2
	}

	-- CHIMANO CUSTOM PARTS
	self.parts.wpn_fps_pis_g22c_b_long.stats = deep_clone(barrel_m1)

	-- CHIMANO COMPACT PARTS
	-- Striking Slide
	self.parts.wpn_fps_pis_g26_b_custom.stats = deep_clone(nostats)
	-- Striking Body
	self.parts.wpn_fps_pis_g26_body_custom.stats = deep_clone(nostats)
	-- Striking Mag
	self.parts.wpn_fps_pis_g26_m_contour.stats = deep_clone(nostats)






	-- BERNETTI PARTS
	-- Professional Compensator
	self.parts.wpn_fps_pis_beretta_co_co1.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Competitor's Compensator
	self.parts.wpn_fps_pis_beretta_co_co2.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Ergo Grip
	self.parts.wpn_fps_pis_beretta_g_ergo.stats = deep_clone(nostats)
	-- Engraved Grip
	self.parts.wpn_fps_pis_beretta_g_engraved.stats = deep_clone(nostats)
	-- Extended Mag
	self.parts.wpn_fps_pis_beretta_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_beretta_m_extended.stats.extra_ammo = 15
	self.wpn_fps_x_b92fs.override.wpn_fps_pis_beretta_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_beretta_m_extended.stats)
	self.wpn_fps_x_b92fs.override.wpn_fps_pis_beretta_m_extended.stats.extra_ammo = self.wpn_fps_x_b92fs.override.wpn_fps_pis_beretta_m_extended.stats.extra_ammo * 2
	-- Elite Slide
	self.parts.wpn_fps_pis_beretta_sl_brigadier.stats = deep_clone(nostats)
	-- Custom Titanium Frame
	self.parts.wpn_fps_pis_beretta_body_modern.stats = deep_clone(nostats)


	-- CONTRACTOR PARTS
	-- Contractor Compensator
	self.parts.wpn_fps_pis_packrat_ns_wick.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}
	-- Tritium Sights
	self.parts.wpn_fps_pis_packrat_o_expert.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_pis_packrat_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_packrat_m_extended.stats.extra_ammo = 10
	self.wpn_fps_x_packrat.override.wpn_fps_pis_packrat_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_packrat_m_extended.stats)
	self.wpn_fps_x_packrat.override.wpn_fps_pis_packrat_m_extended.stats.extra_ammo = self.wpn_fps_x_packrat.override.wpn_fps_pis_packrat_m_extended.stats.extra_ammo * 2



	-- SPARROW PARTS
	-- Ported Barrel
	self.parts.wpn_fps_pis_sparrow_b_comp.stats = deep_clone(nostats)
	-- Threaded Barrel
	self.parts.wpn_fps_pis_sparrow_b_threaded.stats = deep_clone(nostats)
	-- Spike Grip
	self.parts.wpn_fps_pis_sparrow_g_cowboy.stats = deep_clone(nostats)
	-- Spike Kit
	self.parts.wpn_fps_pis_sparrow_body_941.stats = deep_clone(nostats)


	-- PL14 PARTS
	-- Prototype Barrel
	self.parts.wpn_fps_pis_pl14_b_comp.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Extended Magazine
	self.parts.wpn_fps_pis_pl14_m_extended.stats = {
		value = 0,
		extra_ammo = 2,
		reload = -5,
		concealment = -1
	}
	self.wpn_fps_pis_x_pl14.override.wpn_fps_pis_pl14_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_pl14_m_extended.stats)
	self.wpn_fps_pis_x_pl14.override.wpn_fps_pis_pl14_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_pl14.override.wpn_fps_pis_pl14_m_extended.stats.extra_ammo * 2

	-- M13 PARTS
	-- Threaded Barrel
	self.parts.wpn_fps_pis_pl14_m_extended.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Wooden Grip
	self.parts.wpn_fps_pis_legacy_g_wood.stats = deep_clone(nostats)


	-- FIVE-SEVEN PARTS
	-- Uglier Barrel
	self.parts.wpn_fps_pis_lemming_b_nitride.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_pis_lemming_m_ext.stats = deep_clone(mag_125)
	self.parts.wpn_fps_pis_lemming_m_ext.stats.extra_ammo = 4

	-- AP Kit
	self.parts.inf_lemming_apkit.stats = {
		spread = 2,
		recoil = -2,
		damage = -3
	}
	self.parts.inf_lemming_apkit.custom_stats = {
		can_shoot_through_enemy = true,
		can_shoot_through_shield = true,
		can_shoot_through_wall = true,
		pen_shield_dmg_mult = 0.5,
		pen_wall_dmg_mult = 1,
		ammo_pickup_max_mul = 0.5
	}


	-- M13 PARTS
	-- Threaded Barrel
	self.parts.wpn_fps_pis_legacy_b_threaded.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Wooden Grip
	self.parts.wpn_fps_pis_legacy_g_wood.stats = deep_clone(nostats)






	-- CROSSKILL PARTS
	-- Long Slide
	self.parts.wpn_fps_pis_1911_b_long.stats = deep_clone(barrel_m1)
	-- Vented Slide
	self.parts.wpn_fps_pis_1911_b_vented.stats = deep_clone(nostats)
	-- Punisher Compensator
	self.parts.wpn_fps_pis_1911_co_1.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Aggressor Compensator
	self.parts.wpn_fps_pis_1911_co_2.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Bling Grip
	self.parts.wpn_fps_pis_1911_g_bling.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_pis_1911_g_ergo.stats = deep_clone(nostats)
	-- Engraved Grip
	self.parts.wpn_fps_pis_1911_g_engraved.stats = deep_clone(nostats)
	-- don't do this
	self.parts.wpn_fps_pis_1911_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_1911_m_extended.stats.extra_ammo = 5
	self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_1911_m_extended.stats)
	self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_extended.stats.extra_ammo = self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_extended.stats.extra_ammo * 2
	-- why don't you use those extra bullets to kill yourself
	self.parts.wpn_fps_pis_1911_m_big.stats = deep_clone(mag_300)
	self.parts.wpn_fps_pis_1911_m_big.stats.extra_ammo = 11
	self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_big.stats = deep_clone(self.parts.wpn_fps_pis_1911_m_big.stats)
	self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_big.stats.extra_ammo = self.wpn_fps_x_1911.override.wpn_fps_pis_1911_m_big.stats.extra_ammo * 2


	-- CROSSKILL GUARD PARTS
	-- Blinged Grip
	self.parts.wpn_fps_pis_shrew_g_bling.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_pis_shrew_g_ergo.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_pis_shrew_m_extended.stats = deep_clone(mag_125)
	self.parts.wpn_fps_pis_shrew_m_extended.stats.extra_ammo = 2
	self.wpn_fps_pis_x_shrew.override.wpn_fps_pis_shrew_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_shrew_m_extended.stats)
	self.wpn_fps_pis_x_shrew.override.wpn_fps_pis_shrew_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_shrew.override.wpn_fps_pis_shrew_m_extended.stats.extra_ammo * 2
	-- what the fuck is this garbage
	self.parts.wpn_fps_pis_shrew_sl_milled.stats = deep_clone(nostats)

	-- CROSSKILL CHUNKY COMPACT PARTS
	-- Extended mag
	self.parts.wpn_fps_pis_m1911_m_extended.stats = {
		extra_ammo = 1,
		concealment = -1,
		reload = -1
	}
	-- Chunky hunter barrel/slide
	self.parts.wpn_fps_pis_m1911_sl_hardballer.stats = deep_clone(barrel_m1)
	-- Platinum slide
	self.parts.wpn_fps_pis_m1911_sl_match.stats = deep_clone(nostats)


	-- INTERCEPTOR PARTS
	-- Ventilated Compensator
	self.parts.wpn_fps_pis_usp_co_comp_1.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Velocity Compensator
	self.parts.wpn_fps_pis_usp_co_comp_2.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Expert Slide
	self.parts.wpn_fps_pis_usp_b_expert.stats = deep_clone(nostats)
	-- Match Slide
	self.parts.wpn_fps_pis_usp_b_match.stats = deep_clone(nostats)
	-- i hate you
	self.parts.wpn_fps_pis_usp_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_usp_m_extended.stats.extra_ammo = 8
	self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_usp_m_extended.stats)
	self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_extended.stats.extra_ammo * 2
	-- i really hate you
	self.parts.wpn_fps_pis_usp_m_big.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_usp_m_big.stats.extra_ammo = 12
	self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_big.stats = deep_clone(self.parts.wpn_fps_pis_usp_m_big.stats)
	self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_big.stats.extra_ammo = self.wpn_fps_pis_x_usp.override.wpn_fps_pis_usp_m_big.stats.extra_ammo * 2


	-- SIGNATURE 40 PARTS
	-- Two-Tone Slide
	self.parts.wpn_fps_pis_p226_b_equinox.stats = deep_clone(nostats)
	-- Long Slide
	self.parts.wpn_fps_pis_p226_b_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Ergo Grip
	self.parts.wpn_fps_pis_p226_g_ergo.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_pis_p226_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_p226_m_extended.stats.extra_ammo = 9
	self.wpn_fps_pis_x_p226.override.wpn_fps_pis_p226_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_p226_m_extended.stats)
	self.wpn_fps_pis_x_p226.override.wpn_fps_pis_p226_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_p226.override.wpn_fps_pis_p226_m_extended.stats.extra_ammo * 2
	-- Ventilated .40
	self.parts.wpn_fps_pis_p226_co_comp_1.stats = {
		value = 0,
		reload = 2,
		concealment = -1
	}
	-- Velocity .40
	self.parts.wpn_fps_pis_p226_co_comp_2.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}


	-- HS2000 PARTS
	-- Custom Slide
	self.parts.wpn_fps_pis_hs2000_sl_custom.stats = {
		value = 0,
		spread = -5,
		recoil = 2,
		concealment = 1
	}
	-- Long Slide
	self.parts.wpn_fps_pis_hs2000_sl_long.stats = deep_clone(nostats)
	-- Extended Magazine
	self.parts.wpn_fps_pis_hs2000_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_hs2000_m_extended.stats.extra_ammo = 12
	self.wpn_fps_pis_x_hs2000.override.wpn_fps_pis_hs2000_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_hs2000_m_extended.stats)
	self.wpn_fps_pis_x_hs2000.override.wpn_fps_pis_hs2000_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_hs2000.override.wpn_fps_pis_hs2000_m_extended.stats.extra_ammo * 2


	-- GRUBER KURZ PARTS
	-- Long Slide
	self.parts.wpn_fps_pis_ppk_b_long.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Laser Grip
	self.parts.wpn_fps_pis_ppk_g_laser.stats = deep_clone(nostats)


	-- BROOMSTICK PARTS
	-- Precision Barrel
	self.parts.wpn_fps_pis_c96_b_long.stats = deep_clone(barrel_m2)
	-- DL-44
	self.parts.wpn_fps_pis_c96_nozzle.stats = deep_clone(nostats)
	-- Barrel Sight
	self.parts.wpn_fps_pis_c96_sight.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_pis_c96_sight.stats = {
		value = 0,
		zoom = 5,
		concealment = 0
	}
	-- Extended Magazine
	self.parts.wpn_fps_pis_c96_m_extended.stats = {
		value = 0,
		extra_ammo = 10,
		concealment = -2
	}
	self.wpn_fps_pis_x_c96.override.wpn_fps_pis_c96_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_c96_m_extended.stats)
	self.wpn_fps_pis_x_c96.override.wpn_fps_pis_c96_m_extended.stats.extra_ammo = self.wpn_fps_pis_x_c96.override.wpn_fps_pis_c96_m_extended.stats.extra_ammo * 2
	-- Solid Stock
	self.parts.wpn_fps_pis_c96_s_solid.stats = {
		value = 0,
		recoil = 5,
		reload = -10,
		concealment = -2
	}
	-- default receiver
	-- sets semiauto only
	self.parts.wpn_fps_pis_c96_body_standard.adds = {"inf_c96_semionly"}
	self.parts.inf_c96_semionly = {
		a_obj = "a_g",
		type = "internalshit",
		name_id = "bm_wp_c96_semiplox",
		unit = dummy,
		stats = {value = 0},
		perks = {"fire_mode_single"}
	}
	-- schnellfeuer
	self.parts.inf_c96_auto.forbids = {"inf_c96_semionly"}
	self.parts.inf_c96_auto.sub_type = "autofire"
	self.parts.inf_c96_auto.custom_stats = {inf_rof_mult = 900/600, anim_speed_mult = 600/900, sdesc2 = "action_shortrecoilmod"}
	self.parts.inf_c96_auto.internal_part = true
	self.parts.inf_c96_auto.stats = {
		value = 0,
		damage = -10,
		concealment = 0
	}


	-- PARABELLUM PARTS
	-- Reinforced Barrel
	self.parts.wpn_fps_pis_breech_b_reinforced.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}
	-- Short Barrel
	self.parts.wpn_fps_pis_breech_b_short.stats = {
		value = 0,
		spread = -5,
		recoil = -5,
		concealment = 1
	}
	-- Engraved Grip
	self.parts.wpn_fps_pis_breech_g_custom.stats = deep_clone(nostats)	




	-- BRONCO PARTS
	-- Aggressor Barrel
	self.parts.wpn_fps_pis_rage_b_comp1.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Ventilated Barrel
	self.parts.wpn_fps_pis_rage_b_comp2.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Overcompensating Barrel
	self.parts.wpn_fps_pis_rage_b_long.custom_stats = {inf_rof_mult = 180/240, anim_speed_mult = 240/180}
	self.parts.wpn_fps_pis_rage_b_long.stats = {
		value = 0,
		recoil = 10,
		concealment = -2
	}
	-- Pocket Surprise Barrel
	self.parts.wpn_fps_pis_rage_b_short.custom_stats = {switchspeed_mult = switch_snubnose}
	self.parts.wpn_fps_pis_rage_b_short.stats = {
		value = 0,
		spread = -30,
		recoil = -10,
		concealment = 3
	}
	-- Slimline Cylinder
	self.parts.wpn_fps_pis_rage_body_smooth.stats = deep_clone(nostats)
	-- Wooden Ergo Grip
	self.parts.wpn_fps_pis_rage_g_ergo.stats = deep_clone(nostats)


	-- MATEVER PARTS
	-- Pesante Barrel
	self.parts.wpn_fps_pis_2006m_b_long.stats = deep_clone(barrel_m1)
	-- Medio Barrel
	self.parts.wpn_fps_pis_2006m_b_medium.stats = deep_clone(barrel_p1)
	-- Piccolo Barrel
	self.parts.wpn_fps_pis_2006m_b_short.custom_stats = {switchspeed_mult = switch_snubnose}
	self.parts.wpn_fps_pis_2006m_b_short.stats = {
		value = 0,
		spread = -30,
		recoil = -5,
		reload = 20,
		concealment = 4
	}
	-- Noir Grip
	self.parts.wpn_fps_pis_2006m_g_bling.stats = deep_clone(nostats)


	-- DEAGLE PARTS
	-- Long Barrel
	self.parts.wpn_fps_pis_deagle_b_long.stats = deep_clone(barrel_m2)
	-- OVERKILL Compensator
	self.parts.wpn_fps_pis_deagle_co_long.stats = deep_clone(barrel_m2)
	-- La Femme Compensator
	self.parts.wpn_fps_pis_deagle_co_short.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Bling Grip
	self.parts.wpn_fps_pis_deagle_g_bling.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_pis_deagle_g_ergo.stats = deep_clone(nostats)
	-- please have more self respect than to use this
	self.parts.wpn_fps_pis_deagle_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_deagle_m_extended.stats.extra_ammo = 3

	self.wpn_fps_x_deagle.override.wpn_fps_pis_deagle_m_extended.stats = deep_clone(self.parts.wpn_fps_pis_deagle_m_extended.stats)
	self.wpn_fps_x_deagle.override.wpn_fps_pis_deagle_m_extended.stats.extra_ammo = self.wpn_fps_x_deagle.override.wpn_fps_pis_deagle_m_extended.stats.extra_ammo * 2
	-- Custom Milled Barrel
	self.parts.wpn_fps_pis_deagle_b_modern.stats = deep_clone(nostats)



	-- CASTIGO PARTS
	-- Diablo Barrel
	self.parts.wpn_fps_pis_chinchilla_b_satan.custom_stats = {inf_rof_mult = 180/240, anim_speed_mult = 240/180}
	self.parts.wpn_fps_pis_chinchilla_b_satan.stats = {
		value = 0,
		recoil = 10,
		concealment = -2
	}
	-- Carnival Grip
	self.parts.wpn_fps_pis_chinchilla_g_black.stats = deep_clone(nostats)
	-- Cruz Grip
	self.parts.wpn_fps_pis_chinchilla_g_death.stats = deep_clone(nostats)




	-- PEACEMAKER PARTS
	-- Buntline Barrel
	self.parts.wpn_fps_pis_peacemaker_b_long.custom_stats = {inf_rof_mult = 80/120, anim_speed_mult = 120/80}
	self.parts.wpn_fps_pis_peacemaker_b_long.stats = {
		value = 0,
		spread = 10,
		recoil = 10,
		concealment = -3
	}
	-- Shootout Barrel
	self.parts.wpn_fps_pis_peacemaker_b_short.stats = deep_clone(barrel_p1)
	-- gold lmao
	self.parts.wpn_fps_pis_peacemaker_g_bling.stats = deep_clone(nostats)
	-- stop
	self.parts.wpn_fps_pis_peacemaker_s_skeletal.stats = {
		value = 0,
		recoil = 5,
		reload = -10,
		concealment = -2
	}

	-- Beretta 93R Parts
	self.parts.wpn_fps_pis_beer_b_robo.stats = deep_clone(barrel_m2)
	
	self.parts.wpn_fps_pis_beer_g_lux.stats = {
		value = 0
	}
	
	self.parts.wpn_fps_pis_beer_g_robo.stats = {
		value = 0
	}
	
	-- CZ 75 parts
	self.parts.wpn_fps_pis_czech_b_long.stats = deep_clone(barrel_m1)
	
	self.parts.wpn_fps_pis_czech_g_sport.stats = {
		value = 0
	}
	
	self.parts.wpn_fps_pis_czech_g_luxury.stats = {
		value = 0
	}
	
	-- Stechkin/Igor Parts
	self.parts.wpn_fps_pis_stech_b_long.stats = deep_clone(barrel_m1)
	
	self.parts.wpn_fps_pis_stech_g_luxury.stats = {
		value = 1
	}
	
	self.parts.wpn_fps_pis_stech_g_tactical.stats = {
		value = 0
	}
	
	self.parts.wpn_fps_pis_stech_s_standard.stats = {
		value = 0,
		spread = 5,
		recoil = 2,
		concealment = -2
	}

	-- Hudson H9/Holt Parts
	self.parts.wpn_fps_pis_holt_g_ergo.stats = {
		value = 0
	}
	
	self.parts.wpn_fps_pis_holt_g_bling.stats = {
		value = 1
	}

	-- Model 3 parts
	-- Shorter barrel (napoleon barrel)
	self.parts.wpn_fps_pis_model3_b_short.stats = deep_clone(barrel_p1)
	-- Longer barrel (opera long barrel)
	self.parts.wpn_fps_pis_model3_b_long.stats = deep_clone(barrel_m1)
	-- Bling grip (mule bone grip)
	self.parts.wpn_fps_pis_model3_g_bling.stats = deep_clone(nostats)


	-- RPK PARTS
	-- Tactical Handguard
	self.parts.wpn_fps_lmg_rpk_fg_standard.stats = deep_clone(nostats)
	-- Plastic Stock
	self.parts.wpn_fps_lmg_rpk_s_standard.stats = deep_clone(nostats)


	-- KSP PARTS
	-- Long Barrel
	self.parts.wpn_fps_lmg_m249_b_long.stats = deep_clone(barrel_m1)
	-- Railed Handguard
	self.parts.wpn_fps_lmg_m249_fg_mk46.stats = deep_clone(nostats)
	-- Solid Stock
	self.parts.wpn_fps_lmg_m249_s_solid.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}


	-- BRENNER 21 PARTS
	-- Long Barrel
	self.parts.wpn_fps_lmg_hk21_b_long.stats = deep_clone(barrel_m1)
	-- Shorty
	self.parts.wpn_fps_lmg_hk21_fg_short.stats = deep_clone(barrel_p3)
	-- Ergo Grip
	self.parts.wpn_fps_lmg_hk21_g_ergo.stats = deep_clone(nostats)
	-- Slowfire internal
	self.parts.inf_hk21_slowfire.stats = deep_clone(nostats)
	self.parts.inf_hk21_slowfire.custom_stats = {
		inf_rof_mult = 450/800
	}

	-- Brenner leftie grip part
	-- BeardLibs findmod seems to return false (because its not a mod_override?) so we only check if the part exists
	if self.parts.wpn_fps_lmg_hk21_fg_short_leftie then
		self.parts.wpn_fps_lmg_hk21_fg_short_leftie.stats = deep_clone(barrel_p3)
	end

	-- MG42 PARTS
	-- Light Barrel
	self.parts.wpn_fps_lmg_mg42_b_mg34.custom_stats = {inf_rof_mult = 850/1200}
	self.parts.wpn_fps_lmg_mg42_b_mg34.stats = deep_clone(nostats)
	-- Heatsinked Suppressed Barrel
	self.parts.wpn_fps_lmg_mg42_b_vg38.stance_mod = {wpn_fps_lmg_mg42 = {translation = Vector3(0, 0, 0), rotation = Rotation(0, 2, 0)}}
	self.parts.wpn_fps_lmg_mg42_b_vg38.custom_stats = {inf_rof_mult = 700/1200}
	self.parts.wpn_fps_lmg_mg42_b_vg38.stats = {
		value = 0,
		suppression = 12,
		alert_size = 12,
		concealment = 0
	}


	-- KSP58 PARTS
	-- Short Barrel
	self.parts.wpn_fps_lmg_par_b_short.stats = deep_clone(barrel_p1)
	-- Plastic Stock
	self.parts.wpn_fps_lmg_par_s_plastic.stats = deep_clone(nostats)
	-- ROF rampup
	self.parts.inf_devotion.internal_part = true
	self.parts.inf_devotion.custom_stats = {has_burst_fire = true, burst_size = 999, adaptive_burst_size = true, sdesc2 = "action_devotion"}
	self.parts.inf_devotion.custom_stats.burst_fire_rate_table = {0.6, 0.6, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5}
	--self.parts.inf_devotion.custom_stats.burst_recoil_table = {0, 0}
	self.parts.inf_devotion.perks = {"fire_mode_single"}
	self.parts.inf_devotion.stats = deep_clone(nostats)

	-- M60 PARTS
	-- Short barrel
	self.parts.wpn_fps_lmg_m60_b_short.stats = deep_clone(barrel_p1)
	-- Tactical foregrip
	self.parts.wpn_fps_lmg_m60_fg_tactical.stats = deep_clone(nostats)
	-- Tropical foregrip
	self.parts.wpn_fps_lmg_m60_fg_tropical.stats = deep_clone(nostats)
	-- Modernized foregrip
	self.parts.wpn_fps_lmg_m60_fg_keymod.stats = deep_clone(nostats)


	-- HEPHAESTUS/VULCAN PARTS
	-- I'll Take Half That
	self.parts.wpn_fps_lmg_m134_body_upper_light.stats = deep_clone(mag_50)
	self.parts.wpn_fps_lmg_m134_body_upper_light.stats.extra_ammo = -125
	self.parts.wpn_fps_lmg_m134_body_upper_light.stats.concealment = 0
	-- The Stump Barrel
	self.parts.wpn_fps_lmg_m134_barrel_short.custom_stats = {spin_up_time_mult = 0.30/0.50}
	self.parts.wpn_fps_lmg_m134_barrel_short.stats = {
		value = 0,
		spread = -25,
		recoil = -10,
		reload = 15,
		concealment = 4
	}
	-- Aerial Assault Barrel
	self.parts.wpn_fps_lmg_m134_barrel_extreme.custom_stats = {spin_up_time_mult = 0.80/0.50, spin_down_speed_mult = 0.80/0.50}
	self.parts.wpn_fps_lmg_m134_barrel_extreme.stats = {
		value = 0,
		spread = 10,
		recoil = 15,
		concealment = -2
	}


	-- MICROGUN PARTS
	-- XS Barrel
	self.parts.wpn_fps_lmg_shuno_b_short.custom_stats = {spin_up_time_mult = 0.25/0.40}
	self.parts.wpn_fps_lmg_shuno_b_short.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- XS Heat Sink Barrel
	self.parts.wpn_fps_lmg_shuno_b_heat_short.custom_stats = {spin_up_time_mult = 0.25/0.40}
	self.parts.wpn_fps_lmg_shuno_b_heat_short.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- Heat Sink Barrel
	self.parts.wpn_fps_lmg_shuno_b_heat_long.stats = deep_clone(nostats)






	-- GL40 PARTS
	-- Pirate Barrel
	self.parts.wpn_fps_gre_m79_barrel_short.stats = {
		value = 0,
		total_ammo_mod = -125,
		spread = -10,
		concealment = 4
	}
	-- Sawed-Off Stock
	self.parts.wpn_fps_gre_m79_stock_short.stats = {
		value = 0,
		total_ammo_mod = -125,
		recoil = -10,
		reload = -10,
		concealment = 4
	}
	-- incendiary grenade
	self.parts.wpn_fps_upg_a_grenade_launcher_incendiary.custom_stats = {launcher_grenade = "launcher_incendiary", sdesc1 = "caliber_g40mmIC"}

	-- CHINA LAKE PARTS
	--
	self.parts.wpn_fps_gre_china_s_short.stats = {
		value = 0,
		recoil = -10,
		reload = -10,
		concealment = 4
	}


	-- SERAPH PARTS
	--
	self.parts.wpn_fps_gre_m32_barrel_short.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	--
	self.parts.wpn_fps_gre_m32_no_stock.stats = {
		value = 0,
		recoil = -10,
		concealment = 2
	}


	-- ARBITER PARTS
	-- Long Barrel
	self.parts.wpn_fps_gre_arbiter_b_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	-- Bombardier Barrel
	self.parts.wpn_fps_gre_arbiter_b_comp.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- shit's on fire yo
	self.parts.wpn_fps_upg_a_grenade_launcher_incendiary_arbiter.custom_stats = {sdesc1 = "caliber_g25mmIC"}



	-- FLAMETHROWER MK2 PARTS
	-- rare
	self.parts.wpn_fps_fla_mk2_mag_rare.custom_stats = {ammo_pickup_min_mul = 1.50, ammo_pickup_max_mul = 1.50, sdesc1 = "caliber_forjournalists"}
	self.parts.wpn_fps_fla_mk2_mag_rare.stats = {
		value = 0,
		extra_ammo = 100,
		total_ammo_mod = 500,
		damage = -10,
		concealment = 0
	}
	-- well done
	self.parts.wpn_fps_fla_mk2_mag_welldone.custom_stats = {ammo_pickup_min_mul = 0.50, ammo_pickup_max_mul = 0.50, sdesc1 = "caliber_forcommies"}
	self.parts.wpn_fps_fla_mk2_mag_welldone.stats = {
		value = 0,
		extra_ammo = -50,
		total_ammo_mod = -500,
		damage = 25,
		concealment = 0
	}


	-- SECONDARY FLAMETHROWER PARTS
	-- Merlin Nozzle
	self.parts.wpn_fps_fla_system_b_wtf.stats = deep_clone(nostats)
	-- High Temperature Mixture
	self.parts.wpn_fps_fla_system_m_high.custom_stats = {ammo_pickup_min_mul = 0.50, ammo_pickup_max_mul = 0.50, sdesc1 = "caliber_forcommies"}
	self.parts.wpn_fps_fla_system_m_high.stats = {
		value = 0,
		extra_ammo = -25,
		total_ammo_mod = -500,
		damage = 25,
		concealment = 0
	}
	-- Low Temperature Mixture
	self.parts.wpn_fps_fla_system_m_low.custom_stats = {ammo_pickup_min_mul = 1.50, ammo_pickup_max_mul = 1.50, sdesc1 = "caliber_forjournalists"}
	self.parts.wpn_fps_fla_system_m_low.stats = {
		value = 0,
		extra_ammo = 50,
		total_ammo_mod = 500,
		damage = -10,
		concealment = 0
	}





	-- PLAINSRIDER PARTS
	-- Poison Arrow
	self.parts.wpn_fps_upg_a_bow_poison.custom_stats.sdesc3 = "caliber_apoison"
	self.parts.wpn_fps_upg_a_bow_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Arrow
	--self.parts.wpn_fps_upg_a_bow_explosion.custom_stats = {launcher_grenade = "west_arrow_exp", ammo_pickup_max_mul = 0.25}
	self.parts.wpn_fps_upg_a_bow_explosion.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_upg_a_bow_explosion.custom_stats.sdesc3 = "caliber_aexplosive"
	self.parts.wpn_fps_upg_a_bow_explosion.stats = {
		value = 0,
		total_ammo_mod = -500,
		reload = -25,
		concealment = 0
	}

	-- LONGBOW PARTS
	-- Poison Arrow
	self.parts.wpn_fps_bow_long_m_poison.custom_stats.sdesc3 = "caliber_apoison"
	self.parts.wpn_fps_bow_long_m_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Arrow
	self.parts.wpn_fps_bow_long_m_explosive.custom_stats.ammo_pickup_max_mul = 0.50
	self.parts.wpn_fps_bow_long_m_explosive.custom_stats.sdesc3 = "caliber_aexplosive"
	self.parts.wpn_fps_bow_long_m_explosive.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)


	-- COMPOUND BOW PARTS
	--
	self.parts.wpn_fps_bow_elastic_body_tactic.stats = deep_clone(nostats)
	-- Tactical Frame
	self.parts.wpn_fps_bow_elastic_g_1.stats = deep_clone(nostats)
	-- Wooden Grip
	self.parts.wpn_fps_bow_elastic_g_2.stats = deep_clone(nostats)
	-- Ergo Grip
	self.parts.wpn_fps_bow_elastic_g_3.stats = deep_clone(nostats)
	-- Poison Arrow
	self.parts.wpn_fps_bow_elastic_m_poison.custom_stats.sdesc3 = "caliber_apoison"
	self.parts.wpn_fps_bow_elastic_m_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Arrow
	self.parts.wpn_fps_bow_elastic_m_explosive.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_bow_elastic_m_explosive.custom_stats.sdesc3 = "caliber_aexplosive"
	self.parts.wpn_fps_bow_elastic_m_explosive.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)


	-- AIRBOW PARTS
	-- Light Stock
	self.parts.wpn_fps_bow_ecp_s_bare.stats = deep_clone(nostats)
	-- Poison Bolt
	self.parts.wpn_fps_bow_ecp_m_arrows_poison.custom_stats.sdesc3 = "caliber_bpoison"
	self.parts.wpn_fps_bow_ecp_m_arrows_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Bolt
	self.parts.wpn_fps_bow_ecp_m_arrows_explosive.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_bow_ecp_m_arrows_explosive.custom_stats.sdesc3 = "caliber_bexplosive"
	self.parts.wpn_fps_bow_ecp_m_arrows_explosive.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)


	-- LIGHT CROSSBOW PARTS
	-- Poison Bolt
	self.parts.wpn_fps_bow_frankish_m_poison.custom_stats.sdesc3 = "caliber_bpoison"
	self.parts.wpn_fps_bow_frankish_m_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Bolt
	self.parts.wpn_fps_bow_frankish_m_explosive.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_bow_frankish_m_explosive.custom_stats.sdesc3 = "caliber_bexplosive"
	self.parts.wpn_fps_bow_frankish_m_explosive.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)


	-- HEAVY CROSSBOW PARTS
	-- Poison Bolt
	self.parts.wpn_fps_bow_arblast_m_poison.custom_stats.sdesc3 = "caliber_bpoison"
	self.parts.wpn_fps_bow_arblast_m_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Bolt
	self.parts.wpn_fps_bow_arblast_m_explosive.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_bow_arblast_m_explosive.custom_stats.sdesc3 = "caliber_bexplosive"
	self.parts.wpn_fps_bow_arblast_m_explosive.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)


	-- PISTOL CROSSBOW PARTS
	-- Carbon Limb
	self.parts.wpn_fps_bow_hunter_b_carbon.stats = deep_clone(nostats)
	-- Skeletal Limb
	self.parts.wpn_fps_bow_hunter_b_skeletal.stats = deep_clone(nostats)
	-- Camo Grip
	self.parts.wpn_fps_bow_hunter_g_camo.stats = deep_clone(nostats)
	-- Walnut Grip
	self.parts.wpn_fps_bow_hunter_g_walnut.stats = deep_clone(nostats)
	-- Poison Bolt
	self.parts.wpn_fps_upg_a_crossbow_poison.custom_stats.sdesc3 = "caliber_bpoison"
	self.parts.wpn_fps_upg_a_crossbow_poison.stats = {
		value = 0,
		damage = -15,
		concealment = 0
	}
	-- Explosive Bolt
	self.parts.wpn_fps_upg_a_crossbow_explosion.custom_stats.ammo_pickup_max_mul = 0.25
	self.parts.wpn_fps_upg_a_crossbow_explosion.custom_stats.sdesc3 = "caliber_bexplosive"
	self.parts.wpn_fps_upg_a_crossbow_explosion.stats = deep_clone(self.parts.wpn_fps_upg_a_bow_explosion.stats)




	-- OVE9000 SAW PARTS
	-- Silent Motor
	self.parts.wpn_fps_saw_body_silent.custom_stats = {sdesc2 = "action_saw_silent"}
	self.parts.wpn_fps_saw_body_silent.stats = {
		value = 0,
		alert_size = 9,
		suppression = 9,
		damage = -5,
		concealment = 0
	}
	-- Fast Motor
	self.parts.wpn_fps_saw_body_speed.custom_stats = {sdesc2 = "action_saw_fast", inf_rof_mult = 1.5}
	self.parts.wpn_fps_saw_body_speed.stats = {
		value = 0,
		damage = 0,
		concealment = 0
	}
	-- Durable Blade
	self.parts.wpn_fps_saw_m_blade_durable.custom_stats = {sdesc1 = "caliber_saw_durable", ammo_pickup_min_mul = 2, ammo_pickup_max_mul = 2}
	self.parts.wpn_fps_saw_m_blade_durable.stats = {
		value = 0,
		extra_ammo = 60,
		total_ammo_mod = 1000,
		damage = -10,
		concealment = 0
	}
	-- Sharp Blade
	self.parts.wpn_fps_saw_m_blade_sharp.custom_stats = {sdesc1 = "caliber_saw_sharp", ammo_pickup_min_mul = 0.5, ammo_pickup_max_mul = 0.5, saw_ene_dmg_mult = 2}
	self.parts.wpn_fps_saw_m_blade_sharp.stats = {
		value = 0,
		extra_ammo = -40,
		total_ammo_mod = -500,
		damage = 5,
		concealment = 0
	}



	-- LEGENDARY GARBAGE
	self.parts.wpn_fps_ass_74_b_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_deagle_b_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_fla_mk2_body_fierybeast.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_r870_b_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_1911_fl_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_model70_s_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_svinet_b_standard.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m16_b_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m16_s_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_judge_b_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_boot_b_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_boot_fg_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_boot_o_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_ksg_b_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_tecci_b_legend.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_shorty_b_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_shorty_fg_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m14_b_legendary.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m14_body_legendary.stats = deep_clone(nostats)
	

	-- Add all sights to akimbos
	-- List of sights so we can add these to akimbo variants
	local weapon_sights = {"wpn_fps_upg_o_t1micro", "wpn_fps_upg_o_cmore", "wpn_fps_upg_o_reflex", "wpn_fps_upg_o_eotech_xps", "wpn_fps_upg_o_eotech", "wpn_fps_upg_o_rx30", "wpn_fps_upg_o_rx01", "wpn_fps_upg_o_docter", "wpn_fps_upg_o_cs", "wpn_fps_upg_o_specter", "wpn_fps_upg_o_aimpoint", "wpn_fps_upg_o_aimpoint_2", "wpn_fps_upg_o_acog", "wpn_fps_upg_o_spot", "wpn_fps_upg_o_bmg", "wpn_fps_upg_o_fc1", "wpn_fps_upg_o_uh", "wpn_upg_o_marksmansight_rear", "wpn_fps_upg_o_rmr", "wpn_fps_upg_o_rms", "wpn_fps_upg_o_rikt" }

	local function string_starts(String, Start)
		return string.sub(String,1,string.len(Start))==Start
	end

	-- I hate this
	for wpn, data in pairs(self) do
		-- Is akimbo weapon
		if type(wpn) == "string" and string_starts(wpn, "wpn_fps") and string.find(wpn, "_x_") then
			-- Get name of single weapon variant
			local single_wpn = self[wpn:gsub("_x_", "_")]
			-- Check if single weapon exists (it should)
			if single_wpn then
				-- If it does, loop over all sights, check if the single weapon has them, and if so, add them to the akimbo weapon.
				for i, sight in pairs(weapon_sights) do
					if table.contains(single_wpn.uses_parts, sight) then
						-- Add to uses_parts
						table.insert(self[wpn].uses_parts, sight)

						-- If there is an override, also copy it
						if single_wpn.override and single_wpn.override[sight] then
							-- Extra nil checks because not all weapons have overrides
							if not self[wpn].override then
								self[wpn].override = {}
							end
							self[wpn].override[sight] = single_wpn.override[sight]
						end
					end
				end
			end
		end
	end

	-- These weapons do not fit the standard naming scheme so we have to run over them again and add the sights
	local akimbo_wpn_translations = {
		{
			single = "wpn_fps_pis_deagle",
			akimbo = "wpn_fps_x_deagle"
		},
		{
			single = "wpn_fps_pis_1911",
			akimbo = "wpn_fps_x_1911"
		},
		{
			single = "wpn_fps_pis_beretta",
			akimbo = "wpn_fps_x_b92fs"
		},
	}

	for i, wpn in pairs(akimbo_wpn_translations) do
		for j, sight in pairs(weapon_sights) do
			if table.contains(self[wpn.single].uses_parts, sight) then
				table.insert(self[wpn.akimbo].uses_parts, sight)

				if self[wpn.single].override and self[wpn.single].override[sight] then
					if not self[wpn.akimbo].override then
						self[wpn.akimbo].override = {}
					end
					self[wpn.akimbo].override[sight] = self[wpn.single].override[sight]
				end
			end
		end
	end


	-- With debug on, execute the function normally so it crashes hard if something goes wrong
	-- With debug off, silently eat any errors. Custom weapon parts might not work correctly.
	if InFmenu.settings.debug then
		self:_init_inf_custom_weapon_parts(gunlist_snp, customsightaddlist, primarysmgadds, primarysmgadds_specific)
	else
		local successful, errmessage = pcall(WeaponFactoryTweakData._init_inf_custom_weapon_parts, self, gunlist_snp, customsightaddlist, primarysmgadds, primarysmgadds_specific)
		if not successful then
			log("[InF] FATAL ERROR while loading custom weapon parts:")
			if not errmessage then
				errmessage = "(Unable to obtain error message)"
			end
			log(errmessage)
			
			-- Open a message dialog box in the menu, notifying the user that an error occurred trying to intitialize weaponmods
			-- Don't just leave them hanging
			Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_weaponfactorytweak_failedinit", function(menu_manager, nodes)            
				QuickMenu:new("IREnFIST - Error initializing parts", "An error occurred while trying to initialize support for custom weapon mods. Some weaponmods may have incorrect stats.\n\nIt is strongly recommended to create an issue on the IREnFIST Github repository (or comment on the Mod Workshop page), with your latest BLT Log attached (PAYDAY 2/mods/logs).", {
					[1] = {
						text = "OK",
						is_cancel_button = true
					}
				}):show()
			end)

		end
	end

	-- The guide on how to add custom weapon mod support was moved to the bottom of wpn_parts_custom.lua


--!!

--[[
STANDARD SIGHT OFFSETS
wpn_fps_ass_galil_fg_fab
	translation = Vector3(0, 0, -3.5)
wpn_fps_ass_galil_fg_mar
	translation = Vector3(0, -8, -2.2)
wpn_fps_upg_ak_fg_krebs/wpn_fps_upg_ak_fg_trax
	translation = Vector3(0, 0, -3.8)
wpn_fps_upg_ak_fg_zenit
	translation = Vector3(0, 0, -3.3)
wpn_fps_upg_o_ak_scopemount
	translation = Vector3(0, 0, -4.6)
	translation = Vector3(-0.028, 0, -4.36) (AKMSU)
wpn_fps_upg_o_m14_scopemount
	translation = Vector3(-0.03, 0, -5.21)
--]]


	-- add sights/sight/override data to primary SMGs
	-- manually list all primary SMGs and sight mounts
	local sightmounts = {"wpn_fps_ass_galil_fg_fab", "wpn_fps_ass_galil_fg_mar", "wpn_fps_upg_ak_fg_krebs", "wpn_fps_upg_ak_fg_trax", "wpn_fps_upg_ak_fg_zenit", "wpn_fps_upg_o_ak_scopemount", "wpn_fps_upg_o_m14_scopemount"}

	-- get all parts that potentially have data to copy over to the primarysmg
	local parts_with_data = {}
	local forbidden_by_sight_rail = {}
	for partname, a in pairs(self.parts) do
		if self.parts[partname].stance_mod then
			table.insert(parts_with_data, partname)
			-- allow forbidding inf_sightdummy
			if self.parts[partname].customsight then
				self.parts[partname].forbids = self.parts[partname].forbids or {}
				table.insert(self.parts[partname].forbids, "inf_sightdummy2")
			end
		end
		if self.parts[partname].forbidden_by_sight_rail then
			table.insert(forbidden_by_sight_rail, partname)
		end
	end

	-- correct sight concealment for sniper rifles
	for a, wpndata in pairs(gunlist_snp) do
		local wpnname = wpndata[1]
		local concealoffset = wpndata[2] or -3

		if not self[wpnname].override then
			self[wpnname].override = {}
		end
		for b, sight in pairs(sightlist) do
			if self.parts[sight].stats then
				self[wpnname].override[sight] = {
					stats = {
						value = self.parts[sight].stats.value,
						zoom = self.parts[sight].stats.zoom,
						concealment = (self.parts[sight].stats.concealment or 0) - concealoffset
					}
				}
			end
		end
		for c, sightdata in pairs(sniper_concealment_parts) do
			local sight = sightdata[1]
			local sightoffset = sightdata[2]
			if self.parts[sight].stats then
				self[wpnname].override[sight] = {
					stats = {
						value = self.parts[sight].stats.value,
						zoom = self.parts[sight].stats.zoom,
						concealment = (self.parts[sight].stats.concealment or 0) - concealoffset + sightoffset
					}
				}
			end
		end
	end

	-- copy all the data from weapon a to weapon b
	for a, wpndata in pairs(customsightaddlist) do
		local smgpri = wpndata[1]
		local smgsec = wpndata[2]
		local is_different_weapon = wpndata[3] -- don't copy over all uses_parts, only sights
		local add_list = wpndata[4]
		if not is_different_weapon then
			self[smgpri].uses_parts = deep_clone(self[smgsec].uses_parts)
			if primarysmglist[smgpri] then
				for b, part in ipairs(primarysmgadds) do
					table.insert(self[smgpri].uses_parts, part)
				end
				if primarysmgadds_specific[smgpri] then
					for c, part in ipairs(primarysmgadds_specific[smgpri]) do
						table.insert(self[smgpri].uses_parts, part)
					end
				end
			end
			if self[smgsec].override then
				self[smgpri].override = deep_clone(self[smgsec].override)
			end
			if self[smgsec].adds then
				self[smgpri].adds = deep_clone(self[smgsec].adds)
			end
			if self[smgsec].stock_adapter then
				self[smgpri].stock_adapter = self[smgsec].stock_adapter
			end
		end

		for b, part in pairs(parts_with_data) do
			if self.parts[part].stance_mod and self.parts[part].stance_mod[smgsec] then
				self.parts[part].stance_mod[smgpri] = deep_clone(self.parts[part].stance_mod[smgsec])
			end
			-- copy sight mount data for default sights
			for c, mountname in pairs(sightmounts) do
				if self.parts[mountname].override[part] and self.parts[mountname].override[part].stance_mod[smgsec] then
					self.parts[mountname].override[part].stance_mod[smgpri] = self.parts[mountname].override[part].stance_mod[smgsec]
				end
			end
			if self.parts[part].customsight then
				-- don't attach part to newweapon if it doesn't have a stance for templateweapon
				if self.parts[part].stance_mod[smgsec] then
					local sightbase = self.parts[part].customsightbase or "wpn_fps_upg_o_specter"
					table.insert(self[smgpri].uses_parts, part)
					if self[smgsec].adds and self[smgsec].adds[sightbase] and not is_different_weapon then
						self[smgpri].adds[part] = deep_clone(self[smgsec].adds[sightbase])
					end
				end
			end
		end
	end


	-- copy sight mount data for custom sights
	-- needs to come after sight mods set their data
	DelayedCalls:Add("sightmountdelay", delay, function(self, params)
		for c, mountname in pairs(sightmounts) do
			for a, wpndata in pairs(customsightaddlist) do
				local smgpri = wpndata[1]
				local smgsec = wpndata[2]
				--local is_different_weapon = wpndata[3]
				for b, part in pairs(parts_with_data) do
					if tweak_data.weapon.factory.parts[part].customsight then
						local sightbase = tweak_data.weapon.factory.parts[part].customsightbase or "wpn_fps_upg_o_specter"
						local mountpart = tweak_data.weapon.factory.parts[mountname]
						local mount_has_sightbase_stance = mountpart.override[sightbase] and mountpart.override[sightbase].stance_mod and mountpart.override[sightbase].stance_mod[smgsec]
						if mount_has_sightbase_stance and mountpart.override[part] and mountpart.override[part].stance_mod then
							local partstancemod = mountpart.override[part].stance_mod
							partstancemod[smgpri] = partstancemod[smgsec]
							if tweak_data.weapon.factory.parts[part].customsighttrans and tweak_data.weapon.factory.parts[part].customsighttrans[mountname] then
								partstancemod[smgpri].translation = partstancemod[smgpri].translation + tweak_data.weapon.factory.parts[part].customsighttrans[mountname].translation
							end
						end
					end
				end
			end
		end
	end)



	-- alternate sight rail stuff
	self.parts.inf_sightrail.depends_on = "sight"
	self.parts.inf_sightrail.stance_mod = self.parts.inf_sightrail.stance_mod or {}
	self.parts.inf_sightrail.stance_mod.wpn_fps_ass_asval = {translation = Vector3(0, 0, -3.5)}
	self.parts.inf_sightrail.forbids = self.parts.inf_sightrail.forbids or {}
	self.parts.inf_sightrail.override = self.parts.inf_sightrail.override or {}
	for b, part in pairs(parts_with_data) do
		self.parts.inf_sightrail.override[part] = {a_obj = "a_o_notugly"}
	end
	for b, part in pairs(forbidden_by_sight_rail) do	
		if self.parts[part].forbidden_by_sight_rail then
			table.insert(self.parts.inf_sightrail.forbids, part)
		end
	end

	-- alternate sight rail stuff
	self.parts.inf_sightrail_invis.depends_on = "sight"
	self.parts.inf_sightrail_invis.stance_mod = self.parts.inf_sightrail_invis.stance_mod or {}
	self.parts.inf_sightrail_invis.stance_mod.wpn_fps_smg_minebea = {translation = Vector3(0.05, 0, -4)}
	self.parts.inf_sightrail_invis.forbids = self.parts.inf_sightrail_invis.forbids or {}
	self.parts.inf_sightrail_invis.override = self.parts.inf_sightrail_invis.override or {}
	for b, part in pairs(parts_with_data) do
		self.parts.inf_sightrail_invis.override[part] = {a_obj = "a_o_notugly"}
	end
	for b, part in pairs(forbidden_by_sight_rail) do	
		if self.parts[part].forbidden_by_sight_rail then
			table.insert(self.parts.inf_sightrail_invis.forbids, part)
		end
	end
	self.parts.inf_sightrail_invis.override.wpn_fps_upg_o_aimpoint = {a_obj = "a_o_notugly_aimpoint"}
	self.parts.inf_sightrail_invis.override.wpn_fps_upg_o_aimpoint_2 = {a_obj = "a_o_notugly_aimpoint"}
	self.parts.inf_sightrail_invis.override.wpn_fps_upg_o_zeiss = {a_obj = "a_o_notugly_aimpoint"}

	self.parts.inf_invis_stance.stance_mod = {}
	self.parts.inf_invis_stance.stance_mod.wpn_fps_ass_drongo = {translation = Vector3(0.07, -7, 1.174)}

if BeardLib.Utils:ModLoaded("Custom Attachment Points") or BeardLib.Utils:ModLoaded("WeaponLib") then
	table.insert(self.wpn_fps_ass_asval.uses_parts, "inf_sightrail")

	if self.wpn_fps_smg_minebea then
		table.insert(self.wpn_fps_smg_minebea.uses_parts, "inf_sightrail_invis")
	end
end

	-- print concealment data
	-- DOES NOT CURRENTLY ACCOUNT FOR OVERRIDES
	--[[
	DelayedCalls:Add("gimmeconcealdata", 1, function(self, params)
		local function ends_with(str, ending)
		return ending == "" or str:sub(-#ending) == ending
		end
		for a, b in pairs(tweak_data.weapon.factory) do
			local parts_list = {}
			if tweak_data.weapon.factory[a].uses_parts and not (ends_with(a, "_npc") or ends_with(a, "_primary") or ends_with(a, "_secondary")) then
				log(a)
				for c, d in pairs(tweak_data.weapon.factory[a].uses_parts) do
					local part = tweak_data.weapon.factory.parts[d]
					if part and part.stats then
						if part.stats.concealment and (part.stats.concealment > 0) then
							if not parts_list[part.type] or (parts_list[part.type].concealment < part.stats.concealment) then
								parts_list[part.type] = {name = d, concealment = part.stats.concealment}
							end
						end
					end
				end
				for e, f in pairs(parts_list) do
					log("- " .. parts_list[e].name .. ": " .. parts_list[e].concealment)
				end
				log(" ")
			end
		end
	end)
	--]]

	-- SECONDARY AKIMBOS
	-- These mostly work already through main.xml, but they need animation fixes so the slides and mags aren't just static while firing/reloading
	-- They also need their uses_parts and default blueprint copied over, no way in hell am I going to do that shit manually
	-- Has to come after custom part support in case these parts add anything to the pistols

	-- Table of original akimbos as key, and new akimbos as value
	local primary_to_secondary_akimbos = {
		wpn_fps_pis_x_pl14 = "wpn_fps_pis_x_pl14_secondary",
		wpn_fps_pis_x_sparrow = "wpn_fps_pis_x_sparrow_secondary",
		wpn_fps_pis_x_legacy = "wpn_fps_pis_x_legacy_secondary",
		wpn_fps_jowi = "wpn_fps_pis_x_jowi_secondary",
		wpn_fps_x_b92fs = "wpn_fps_pis_x_b92fs_secondary",
		wpn_fps_pis_x_g17 = "wpn_fps_pis_x_g17_secondary",
		wpn_fps_x_packrat = "wpn_fps_pis_x_packrat_secondary",
		wpn_fps_pis_x_holt = "wpn_fps_pis_x_holt_secondary"
	}
	
	-- Copy animations, uses_parts and default blueprint
	-- This will save us a ton of unnecessary XML work
	for pri, sec in pairs(primary_to_secondary_akimbos) do
		-- Animations don't always exist, thank you so much
		if self[pri].animations then
			self[sec].animations = deep_clone(self[pri].animations)
		end
		-- Sometimes they're on the overrides instead
		if self[pri].override then
			self[sec].override = deep_clone(self[pri].override)
		end

		-- Add missing gadget rails and stuff
		if self[pri].adds then
			self[sec].adds = deep_clone(self[pri].adds)
		end

		self[sec].uses_parts = deep_clone(self[pri].uses_parts)
		self[sec].default_blueprint = deep_clone(self[pri].default_blueprint)
	end

	-- Don't touch this, this should be the last line in the weaponfactorytweakdata init hook
	-- Enables better compatibility with other mods if they choose to override something InF does
	Hooks:Call("inf_weaponfactorytweak_initcomplete", self, params)

end)



Hooks:PostHook(WeaponFactoryTweakData, "create_bonuses", "infcharmstats", function(self, params)

	local function ends_with(str, ending)
		return ending == "" or str:sub(-#ending) == ending
	end

	-- money
	self.parts.wpn_fps_upg_bonus_team_exp_money_p3.stats = {value = 0}

	-- generic stat-boosters
	self.parts.wpn_fps_upg_bonus_concealment_p1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_concealment_p1.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_recoil_p1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_recoil_p1.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_spread_p1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_spread_p1.stats = {value = 0}


	-- weapon-specific boosts
	self.parts.wpn_fps_upg_bonus_damage_p1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_damage_p1.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_total_ammo_p1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_total_ammo_p1.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_concealment_p2.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_concealment_p2.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_concealment_p3.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_concealment_p3.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_damage_p2.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_damage_p2.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_total_ammo_p3.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_total_ammo_p3.stats = {value = 0}
	self.parts.wpn_fps_upg_bonus_spread_n1.custom_stats = self.parts.wpn_fps_upg_bonus_team_exp_money_p3.custom_stats
	self.parts.wpn_fps_upg_bonus_spread_n1.stats = {value = 0}

	for part_id, part_data in pairs(self.parts) do
		if part_data.stats and part_data.stats.value then
			if InFmenu.settings.changeitemprices then
				part_data.stats.value = 0
			end
			part_data.has_description = true
		end
--[[
		if part_data.pcs ~= {} and part_data.pcs ~= nil then
			part_data.is_a_unlockable = true
		end
--]]
	end

end)


--[[
GIVE TO ALL WEAPONS
tecci stock
tecci receivers
para stock
m16 stock
wpn_fps_snp_tti_vg_standard
swappable vertical grips
swappable drag handles
bizon grip
ak12 stock
ak12 grip
ak12 mag
add default ak grip to ak12

wpn_fps_smg_schakal_ns_silencer
VHS barrel ext
L85 barrel ext
PBS suppressor
wpn_fps_snp_tti_ns_standard
wpn_fps_snp_tti_ns_hex
wpn_fps_ass_contraband_s_standard
wpn_fps_snp_wa2000_b_suppressed
wpn_fps_ass_tecci_ns_standard
wpn_fps_ass_tecci_ns_special
wpn_fps_ass_tecci_s_standard
wpn_fps_smg_mp7_b_suppressed
wpn_fps_smg_sr2_ns_silencer
wpn_fps_smg_mp9_b_suppressed
wpn_fps_smg_cobray_ns_silencer
wpn_fps_smg_polymer_barrel_precision
wpn_fps_smg_polymer_ns_silencer
wpn_fps_smg_cobray_ns_barrelextension -- lol
wpn_fps_smg_scorpion_b_suppressed -- probable failure
micro uzi suppressors -- probable failure
--]]

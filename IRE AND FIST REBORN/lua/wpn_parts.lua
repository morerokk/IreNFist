dofile(ModPath .. "infcore.lua")

Hooks:RegisterHook("inf_weaponfactorytweak_initcomplete")

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







Hooks:PostHook(WeaponFactoryTweakData, "init", "infpartstats", function(self, params)
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
if BeardLib.Utils:ModLoaded("BipodG36") then
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
		concealment = -2
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

	-- SR EINHERI PARTS
if BeardLib.Utils:ModLoaded("SR-3M Vikhr") then
	-- default mag
	self.parts.wpn_fps_ass_sr3m_mag.stats = {}
	-- mounting sights in an aesthetic fashion
	self.parts.wpn_fps_upg_sr3m_cover_rail.stats = {}
	-- dotsight
	--[[
	self.parts.wpn_fps_upg_sr3m_leupold_pro.stats = {
		value = 0,
		zoom = 0,
		concealment = -1
	}
	]]
	-- 20rnd mag
	self.parts.wpn_fps_upg_sr3m_mag_20rnd.stats = deep_clone(mag_66)
	self.parts.wpn_fps_upg_sr3m_mag_20rnd.stats.extra_ammo = -10
	-- no stock
	self.parts.wpn_fps_upg_sr3m_nostock.stats = {
		value = 0,
		recoil = -3,
		concealment = 1
	}
	-- CAA collapsible stock
	self.parts.wpn_fps_upg_sr3m_stock_caam4.stats = {
		value = 0,
		recoil = 3,
		concealment = -1
	}

	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_standard = {
		stats = {
			value = 0,
			recoil = 3,
			concealment = -1
		}
	}
	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_standard = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_pts = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_crane = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_mk46 = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard
	self.wpn_fps_ass_sr3m.override.wpn_fps_upg_m4_s_ubr = self.wpn_fps_shot_serbu.override.wpn_fps_upg_m4_s_standard

	-- SR-3M suppressor
	self.parts.wpn_fps_upg_sr3m_supp.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_sr3m_supp.stats = deep_clone(silstatsconc2)
	-- groza suppressor
	self.parts.wpn_fps_upg_sr3m_supp_groza.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_sr3m_supp_groza.stats = deep_clone(silstatsconc2)
	-- no VFG
	self.parts.wpn_fps_upg_sr3m_vertgrip_cover.stats = deep_clone(nostats)


end



	-- CZ-75 SHADOW PARTS
if BeardLib.Utils:ModLoaded("cz") then
	-- prevents from loading after InF and overwriting my clearly-superior stats
	-- now done via delayed calls
	--Hooks:RemovePostHook("czInit")

	-- Stealth Suppressor
	self.parts.wpn_fps_pis_cz_sil.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_cz_sil.stats = deep_clone(silstatsconc1)
	-- Sharktooth Suppressor
	self.parts.wpn_fps_pis_cz_smallsil.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_cz_smallsil.stats = deep_clone(silstatsconc2)
	-- Snowflake Compensator
	self.parts.wpn_fps_pis_cz_comp.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- 
	self.parts.wpn_fps_pis_cz_m_ext.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_cz_m_ext.stats.extra_ammo = 15

	self.parts.wpn_fps_pis_cz_g_bling.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz_b_silver.stats = deep_clone(nostats)
	DelayedCalls:Add("cz75shadowdelay", delay, function(self, params)
		tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_cz_m_ext.stats)
		tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats.extra_ammo = tweak_data.weapon.factory.wpn_fps_pis_x_cz.override.wpn_fps_pis_cz_m_ext.stats.extra_ammo * 2
	end)
end

	-- M2 HEAVY BARREL
if BeardLib.Utils:ModLoaded("M2HB_HMG") then
	self.parts.inf_lmg_offset.stance_mod.wpn_fps_lmg_m2hb = {translation = Vector3(4, 0, -1)}
	self.parts.inf_lmg_offset_nongadget.stance_mod.wpn_fps_lmg_m2hb = {translation = Vector3(4, 0, -1)}
	table.insert(self.wpn_fps_lmg_m2hb.uses_parts, "inf_lmg_offset")
	table.insert(self.wpn_fps_lmg_m2hb.uses_parts, "inf_lmg_offset_nongadget")
end

	-- MATEBA 6 UNICA PARTS
if BeardLib.Utils:ModLoaded("Mateba Model 6 Unica") then
	-- Compensator
	self.parts.wpn_fps_upg_unica6_comp.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Black Laminated Grip
	--self.parts.wpn_fps_upg_unica6_grip_black.stats = deep_clone(nostats)
end


if BeardLib.Utils:ModLoaded("Contender Special") then
	-- standard
	self.parts.wpn_fps_special_contender_shell_rifle.internal_part = true
	self.parts.wpn_fps_special_contender_shell_rifle.type = "ammo"
	self.parts.wpn_fps_special_contender_shell_rifle.stats = deep_clone(nostats)
	-- heavy
	self.parts.wpn_fps_special_contender_ammo_AP.internal_part = true
	self.parts.wpn_fps_special_contender_ammo_AP.type = "ammo"
	self.parts.wpn_fps_special_contender_ammo_AP.stats = {
		value = 0,
		total_ammo_mod = -333,
		damage = 40,
		recoil = -15,
		reload = -25,
		concealment = 0
	}
	-- light
	self.parts.wpn_fps_special_contender_ammo_22lr.internal_part = true
	self.parts.wpn_fps_special_contender_ammo_22lr.type = "ammo"
	self.parts.wpn_fps_special_contender_ammo_22lr.stats = {
		value = 0,
		total_ammo_mod = 500,
		damage = -16,
		recoil = 10,
		reload = 25,
		concealment = 0
	}
	-- shotgun
	self.parts.wpn_fps_special_contender_ammo_410bore.internal_part = true
	self.parts.wpn_fps_special_contender_ammo_410bore.type = "ammo"
	self.parts.wpn_fps_special_contender_ammo_410bore.stats = {
		value = 0,
		spread = -30,
		spread_multi = {1/shotgun_slug_mult, 1/shotgun_slug_mult},
		concealment = 0
	}
	-- why
	self.parts.wpn_fps_special_contender_ns_silencer.stats = {
		value = 0,
		alert_size = 12,
		suppression = 12,
		damage = -5,
		recoil = 5,
		concealment = -1
	}

DelayedCalls:Add("contenderdelay", delay, function(self, params)
	-- why is the shield penetration being overwritten on the light round but not sdesc1
	-- fuck this gay earth

	-- standard
	--tweak_data.weapon.factory.parts.wpn_fps_special_contender_shell_rifle.custom_stats = {rays = 1}
	-- light
	tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_22lr.custom_stats = {sdesc1 = "caliber_r3030", rays = 1, contender_shield_hack = true, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true, ammo_pickup_min_mul = 1.5, ammo_pickup_max_mul = 1.5}
	-- heavy
	tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_AP.custom_stats = {sdesc1 = "caliber_r3006", rays = 1, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true, ammo_pickup_min_mul = 0.66, ammo_pickup_max_mul = 0.66}
	-- shotgun
	tweak_data.weapon.factory.parts.wpn_fps_special_contender_ammo_410bore.custom_stats = {sdesc1 = "caliber_s410", rays = 10, can_shoot_through_enemy = false, can_shoot_through_shield = false, can_shoot_through_wall = false, damage_far_mul = 0.10, damage_near_mul = 0.10}
end)
end


if BeardLib.Utils:ModLoaded("m1c") then
	-- funnel compensator
	self.parts.wpn_fps_ass_m1c_comp.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- don't do it
	self.parts.wpn_fps_ass_m1c_rail.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m1c_mag.stance_mod = {
		wpn_fps_ass_m1c = {translation = Vector3(0, 7, 0), rotation = Rotation(0, 0, 0)}
	}
end

if BeardLib.Utils:ModLoaded("Tokarev SVT-40") then
	-- upgraded muzzle brake
	self.parts.wpn_fps_upg_svt40_muzzle_brake_upg.stats = deep_clone(nostats)
	-- PU scopes
	self.parts.wpn_fps_upg_svt40_pu_scope.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_svt40_pu_scope.stats = {
		value = 0,
		zoom = 5,
		concealment = -3
	}
	-- camo
	self.parts.wpn_fps_upg_svt40_stock_finish_snow2.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_svt40_stock_spetzjungle3.stats = deep_clone(nostats)
	-- prototype suppressor
	self.parts.wpn_fps_upg_svt40_suppressor.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_svt40_suppressor.stats = deep_clone(silstatsconc2)
end

if BeardLib.Utils:ModLoaded("AN-94 AR") then
	self.parts.wpn_fps_ass_akrocket_s_adjusted.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_akrocket_g_mod.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_akrocket_fg_modern.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_akrocket_ns_sil.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_akrocket_ns_sil.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_ass_akrocket_b_heavy.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_ass_akrocket_b_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_ass_akrocket_m_fast.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_akrocket_m_extended.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_akrocket_m_fastext.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("tilt") then
	self.parts.wpn_fps_ass_tilt_g_wood.stats = deep_clone(nostats)
	-- bulk magazine
	self.parts.wpn_fps_ass_tilt_mag_big.stats = deep_clone(self.parts.wpn_fps_upg_ak_m_quad.stats)
	-- tactical magazine
	self.parts.wpn_fps_ass_tilt_mag_tactical.stats = deep_clone(nostats)
	-- swift magazine
	self.parts.wpn_fps_ass_tilt_mag_swift.stats = deep_clone(nostats)
	-- folding stock
	self.parts.wpn_fps_ass_tilt_stock_fold.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	-- no stock
	self.parts.wpn_fps_ass_tilt_stock_none.stats = {
		value = 0,
		spread = -5,
		recoil = -5,
		concealment = 3
	}
	-- tactical stock
	self.parts.wpn_fps_ass_tilt_stock_tactical.stats = deep_clone(nostats)
	-- wood stock
	self.parts.wpn_fps_ass_tilt_stock_wood.stats = deep_clone(nostats)
	-- 7.62 ammo
	self:convert_part("wpn_fps_ass_tilt_a_fuerte", "lrifle", "mrifle")
	self.parts.wpn_fps_ass_tilt_a_fuerte.custom_stats.sdesc1 = "caliber_r762x39"
	self.parts.wpn_fps_ass_tilt_a_fuerte.internal_part = true
DelayedCalls:Add("an92delayedcall", delay, function(self, params)
	tweak_data.weapon.factory:convert_ammo_pickup("wpn_fps_ass_tilt_a_fuerte", InFmenu.wpnvalues.lrifle.ammo, InFmenu.wpnvalues.mrifle.ammo)
	tweak_data.weapon.factory.parts.wpn_fps_upg_o_tilt_scopemount.stance_mod = {
		wpn_fps_ass_tilt = {
			translation = Vector3(0, -10, -2.6), -- bring it closer to the face
			rotation = Rotation(0, 0, 0)
		}
	}
end)
end


if BeardLib.Utils:ModLoaded("Makarov Pistol") then
	-- pmm 12rnd mag
	self.parts.wpn_fps_pis_pm_m_custom.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 4
	self.parts.wpn_fps_pis_pm_m_custom.stats.concealment = 0
	-- dumbfuck single column
	self.parts.wpn_fps_pis_pm_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 8
	-- go suck-start a shotgun
	self.parts.wpn_fps_pis_pm_m_drum.custom_stats = {rstance = InFmenu.rstance.lightpis, recoil_table = InFmenu.rtable.lightpis, armor_piercing_sub = 0.11, ammo_pickup_min_mul = 1.875, ammo_pickup_max_mul = 1.875}
	self.parts.wpn_fps_pis_pm_m_drum.stats = {
		value = 0,
		extra_ammo = 76,
		total_ammo_mod = 875, -- 80 to 150
		damage = -25,
		spread = -35,
		reload = -50,
		concealment = -15
	}
	-- modern body
	self.parts.wpn_fps_pis_pm_b_custom.stats = deep_clone(nostats)
DelayedCalls:Add("makarovdelayedcall", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_custom.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_custom.stats)
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 8
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_extended.stats)
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 16
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_drum.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_drum.stats)
	tweak_data.weapon.factory.wpn_fps_pis_xs_pm.override.wpn_fps_pis_pm_m_drum.stats.extra_ammo = 152

	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_custom.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_custom.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_custom.stats.extra_ammo = 8
	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_extended.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_extended.stats.extra_ammo = 16
	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_drum.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_pm_m_drum.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_pm.override.wpn_fps_pis_pm_m_drum.stats.extra_ammo = 152 -- 96 to 180
end)
end


if BeardLib.Utils:ModLoaded("Remington Various Attachment") then
	-- heat-shielded barrel
	self.parts.wpn_fps_shot_mossberg_b_heat.stats = deep_clone(nostats)
	-- flashlight grip
	self.parts.wpn_fps_shot_870_fg_surefire.stats = {
		value = 0,
		concealment = -1
	}
	-- long rail system
	self.parts.wpn_fps_shot_870_rail_mcs.stats = {
		value = 0,
		concealment = -1
	}
	table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_ass_scar_o_flipups_up")
	table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_upg_870_o_ghostring")
	table.insert(self.parts.wpn_fps_shot_870_rail_mcs.forbids, "wpn_fps_upg_870_o_ghostring_short")
	-- short rail system
	self.parts.wpn_fps_shot_870_rail_aftermarket.stats = {
		value = 0,
		concealment = -1
	}
	table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_ass_scar_o_flipups_up")
	table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_upg_870_o_ghostring")
	table.insert(self.parts.wpn_fps_shot_870_rail_aftermarket.forbids, "wpn_fps_upg_870_o_ghostring_short")
	-- railed pump
	self.parts.wpn_fps_shot_870_fg_rail.stats = deep_clone(nostats)
	-- foreend strap
	self.parts.wpn_fps_shot_mossberg_fg_short.stats = deep_clone(nostats)
	-- synthetic pump
	self.parts.wpn_fps_shot_mossberg_fg_pump.stats = deep_clone(nostats)
	-- hunt down the refund pump
	self.parts.wpn_fps_shot_r870_fg_hdtf.stats = deep_clone(nostats)
	-- hunt down the refund stock
	self.parts.wpn_fps_shot_r870_s_hdtf.stats = deep_clone(nostats)
	-- loco vertical pump
	self.parts.wpn_fps_shot_870_fg_vertical.stats = deep_clone(nostats)
	-- semi-grip stock
	self.parts.wpn_fps_shot_mossberg_s_grip.stats = deep_clone(nostats)

	-- shielded ghost ring
	self.parts.wpn_fps_shot_mossberg_o_heat.forbids = self.parts.wpn_fps_shot_mossberg_o_heat.forbids or {}
	table.insert(self.parts.wpn_fps_shot_mossberg_o_heat.forbids, "wpn_fps_ass_scar_o_flipups_up")

DelayedCalls:Add("reinbeckpartsdelayedcall", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_o_heat.stance_mod = {
		wpn_fps_shot_r870 = {translation = Vector3(0.1, -5, 0.3), rotation = Rotation(0, 0.5, 0)}
	}
--[[
	tweak_data.weapon.factory.parts.wpn_fps_shot_870_iron_aftermarket.stance_mod = {
		 wpn_fps_shot_r870 = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 2.1, -0)},
	     wpn_fps_shot_serbu = {translation = Vector3(-0.01, 0, -3.5), rotation = Rotation(0, 4, -0)}
	}
	tweak_data.weapon.factory.parts.wpn_fps_shot_870_iron_mcs.stance_mod = {
		wpn_fps_shot_r870 = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 0.2, -0)},
	    wpn_fps_shot_serbu = {translation = Vector3(0, 0, -3.0), rotation = Rotation(0, 0.2, -0)}
	}

	tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_o_heat.stance_mod = {
		wpn_fps_shot_r870 = {translation = Vector3(0.1, -5, -1.2), rotation = Rotation(0, 0.5, 0)}
	}
	tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_b_heat.override.wpn_fps_shot_mossberg_o_heat.stance_mod = {
		wpn_fps_shot_r870 = {translation = Vector3(0.09, -5, -1.0), rotation = Rotation(0, 0, -0)}
	}
	tweak_data.weapon.factory.parts.wpn_fps_shot_mossberg_b_heat.override.wpn_fps_shot_870_iron_aftermarket.stance_mod = {
		wpn_fps_shot_r870 = {translation = Vector3(-0.05, 0, -2.7), rotation = Rotation(-0.05, 1.1, -0)}
	}
--]]

	-- locomotive gains stats with long stocks
	tweak_data.weapon.factory.wpn_fps_shot_serbu.override.wpn_fps_shot_mossberg_s_grip = {stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_shot_r870_s_solid.stats)}
	tweak_data.weapon.factory.wpn_fps_shot_serbu.override.wpn_fps_shot_r870_s_hdtf = {stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_shot_r870_s_solid.stats)}


	-- undo statfix for vanilla parts
	tweak_data.weapon.factory.parts.wpn_fps_shot_r870_body_rack.stats = {
		value = 0,
		reload = 5,
		concealment = -1
	}
	tweak_data.weapon.factory.parts.wpn_fps_shot_shorty_s_nostock_short.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
end)

end


if BeardLib.Utils:ModLoaded("Winchester Model 1912") then
	-- base receiver
	self.parts.wpn_fps_shot_m1912_receiver.stats = deep_clone(nostats)
	-- field barrel
	self.parts.wpn_fps_upg_m1912_barrel_field.stats = {
		value = 0,
		spread = 10,
		recoil = 6,
		reload = -8,
		concealment = -2
	}
	-- riot barrel
	self.parts.wpn_fps_upg_m1912_barrel_riot.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	-- field forend
	self.parts.wpn_fps_upg_m1912_forend_field.stats = deep_clone(nostats)
	-- heat shield
	self.parts.wpn_fps_upg_m1912_heat_shield.stats = deep_clone(nostats)
	-- cutts compensator
	self.parts.wpn_fps_upg_m1912_ns_cutts.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	-- duck choke
	self.parts.wpn_fps_upg_m1912_ns_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
	-- cheek rest stock
	self.parts.wpn_fps_upg_m1912_stock_cheekrest.stats = deep_clone(nostats)
	-- cheek rest w/recoil pad
	self.parts.wpn_fps_upg_m1912_stock_cheekrest_pad.stats = deep_clone(nostats)
	-- recoil pad
	self.parts.wpn_fps_upg_m1912_stock_pad.stats = deep_clone(nostats)
	-- sawn-off stock
	self.parts.wpn_fps_upg_m1912_stock_sawnoff.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
	self.parts.wpn_fps_shot_m1912_receiver.stance_mod = {
		wpn_fps_shot_m1912 = {translation = Vector3(0, 1, 0)}
	}
end


if BeardLib.Utils:ModLoaded("KS-23") then
	-- shrapnel-25
	self.parts.wpn_fps_upg_ks23_ammo_buckshot_8pellet.custom_stats = {rays = 8, damage_near_mul = 25/15, damage_far_mul = 35/30, sdesc1 = "caliber_s23mm25"}
	self.parts.wpn_fps_upg_ks23_ammo_buckshot_8pellet.stats = {
		value = 0,
		damage = -20,
		spread = 20,
		concealment = 0
	}
	-- shrapnel-10
	self.parts.wpn_fps_upg_ks23_ammo_buckshot_20pellet.custom_stats = {rays = 20, damage_near_mul = 10/15, damage_far_mul = 20/30, sdesc1 = "caliber_s23mm10"}
	self.parts.wpn_fps_upg_ks23_ammo_buckshot_20pellet.stats = {
		value = 0,
		damage = 20,
		spread = -35,
		concealment = 0
	}
	-- barricade
	self.parts.wpn_fps_upg_ks23_ammo_slug.custom_stats = {damage_near_mul = 3, damage_far_mul = 3, rays = 1, armor_piercing_add = 1, sdesc3 = "range_shotslug", sdesc3_range_override = true, taser_hole = true, can_shoot_through_enemy = true, can_shoot_through_shield = true, can_shoot_through_wall = true}
	self.parts.wpn_fps_upg_ks23_ammo_slug.stats = {
		value = 0,
		damage = 40,
		spread = 20,
		spread_multi = {shotgun_slug_mult, shotgun_slug_mult},
		concealment = 0
	}

	-- short barrel
	self.parts.wpn_fps_upg_ks23_barrel_short.stats = {
		value = 0,
		spread = -15,
		reload = 15,
		concealment = 2
	}
	-- pistol grip
	self.parts.wpn_fps_upg_ks23_stock_pistolgrip.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
	-- pistol grip+wire stock
	self.parts.wpn_fps_upg_ks23_stock_pistolgrip_wire.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	-- receiver
	self.parts.wpn_fps_shot_ks23_rec.stance_mod = {
		wpn_fps_shot_ks23 = {translation = Vector3(0, 0, 0)}
	}
end


if BeardLib.Utils:ModLoaded("Marlin Model 1894 Custom") then
	-- default parts
	self.parts.wpn_fps_snp_m1894_loading_spring.stats = {}
	self.parts.wpn_fps_snp_m1894_irons.stats = {
		value = 0,
		zoom = 0,
		concealment = 3
	}
	self.parts.wpn_fps_upg_m1894_supp_gemtech_gm45.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_m1894_supp_gemtech_gm45.stats = deep_clone(silstatsconc2)
end

-- primary svu/SVU-T
if BeardLib.Utils:ModLoaded("svudragunov") then
	table.insert(gunlist_snp, {"wpn_fps_snp_svu_dragunov", -3})
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_spot")
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "inf_shortdot")
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_box")
	table.insert(customsightaddlist, {"wpn_fps_snp_svu_dragunov", "wpn_fps_snp_desertfox", true})
	self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_snp_desertfox)
	self.parts.inf_shortdot.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.inf_shortdot.stance_mod.wpn_fps_snp_desertfox)
	self.parts.wpn_fps_upg_o_box.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_box.stance_mod.wpn_fps_snp_desertfox)
	-- default part
	self.parts.wpn_fps_snp_svu_dragunov_b_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_snp_svu_dragunov_b_silencer.stats = deep_clone(nostats)
	-- i want my glaz sound
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "inf_svu_unsil")
	self.parts.inf_svu_unsil.unit = "units/mods/weapons/wpn_fps_snp_svu_dragunov_pts/wpn_fps_snp_svu_dragunov_b_silencer"
	self.parts.inf_svu_unsil.stats = {
		value = 0,
		alert_size = -11,
		suppression = -10,
		recoil = -6,
		concealment = 0
	}

	-- add parts that came out after the custom weapon did
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_45rds")
	self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_snp_desertfox)
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_45rds_v2")
	self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_snp_desertfox)
	table.insert(self.wpn_fps_snp_svu_dragunov.uses_parts, "wpn_fps_upg_o_xpsg33_magnifier")
	self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_snp_svu_dragunov = deep_clone(self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_snp_desertfox)
end

-- secondary svu
if BeardLib.Utils:ModLoaded("SVU") then
	-- default parts
	self.parts.wpn_fps_snp_svu_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_svu_pso.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_snp_svu_pso.stats = {
		value = 0,
		zoom = 7,
		concealment = 0
	}

	self.parts.wpn_fps_upg_svu_bipod.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_svu_dtk2.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_upg_svu_grip_plastic.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_svu_handguard_camo.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_svu_handguard_plastic.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_svu_irons.stats = {
		value = 0,
		zoom = 0,
		concealment = 3
	}
	self.parts.wpn_fps_upg_svu_supp_pbs1.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_svu_supp_pbs1.stats = deep_clone(silstatsconc2)
	table.insert(gunlist_snp, {"wpn_fps_snp_svu", -3})
end


if BeardLib.Utils:ModLoaded("Gewehr 43") then
	table.insert(gunlist_snp, {"wpn_fps_snp_g43", -3})
	self.parts.wpn_fps_snp_g43_clothwrap.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_g43_sling.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_g43_zf4.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_snp_g43_zf4.stats = {
		value = 0,
		zoom = 7,
		concealment = 0
	}
	self.parts.wpn_fps_snp_g43_zf4_switch.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_snp_g43_zf4_switch.stats = {
		value = 0,
		zoom = 7,
		concealment = 0
	}
	self.parts.wpn_fps_snp_g43_zf4_irons.stats = {
		value = 0,
		gadget_zoom = 1,
		concealment = 0
	}
	self.parts.wpn_fps_snp_g43_irons.stats = {
		value = 0,
		zoom = 0,
		concealment = 3
	}
	self.parts.wpn_fps_snp_g43_silencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_snp_g43_silencer.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_snp_g43_a_no_ap.custom_stats = {ammo_pickup_min_mul = 0.60, ammo_pickup_max_mul = 0.60, sdesc1 = "caliber_r792mauserk"}
	self.parts.wpn_fps_snp_g43_a_no_ap.stats = {
		value = 0,
		total_ammo_mod = -400,
		damage = 85,
		recoil = -5,
		reload = -15,
		concealment = 0
	}
end

-- primary mosin-nagant obrez
if BeardLib.Utils:ModLoaded("Mosin Nagant Obrez Kit") then
	table.insert(self.parts.wpn_fps_snp_mosin_b_obrez.forbids, "inf_bipod_snp")
	self.parts.wpn_fps_snp_mosin_b_obrez.custom_stats = {muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath"}
	self.parts.wpn_fps_snp_mosin_b_obrez.stats = {
		value = 0,
		spread = -30,
		concealment = 3
	}
	self.parts.wpn_fps_snp_mosin_body_obrez.stats = {
		value = 0,
		recoil = -10,
		concealment = 3
	}
end

-- secondary obrez
if BeardLib.Utils:ModLoaded("Mosin Nagant M9130 Obrez") then
	-- ridiculous flash is set in wpn_stats
	-- default part
	self.parts.wpn_fps_snp_obrez_clip.stats = deep_clone(nostats)

	-- sil
	self.parts.wpn_fps_upg_obrez_ns_supp.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_obrez_ns_supp.stats = deep_clone(silstatssnp)
	-- svt-40 brake
	self.parts.wpn_fps_upg_obrez_ns_svt40_brake.stats = {
		value = 0,
		recoil = 3,
		concealment = -1
	}
end


-- BAR
if BeardLib.Utils:ModLoaded("BAR LMG") then
	self.parts.wpn_fps_ass_bar_g_monitor.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_bar_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_ass_bar_bipod.adds = {"inf_bipod_part"}
	self.parts.wpn_fps_ass_bar_bipod.type = "bipod"
	self.parts.wpn_fps_ass_bar_bipod.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_bar_carryhandle.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_bar_b_para.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_bar_fg_sleeve.stats = {
		value = 0,
		spread = -10,
		concealment = 2
	}
	self.parts.wpn_fps_ass_bar_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_ass_bar_m_extended.stats.extra_ammo = 20
	self.parts.wpn_fps_ass_bar_ns_cutts.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}

	table.insert(self.wpn_fps_ass_bar.uses_parts, "inf_bar_slowfire")
	self.parts.inf_bar_slowfire.internal_part = true
	self.parts.inf_bar_slowfire.custom_stats = {has_burst_fire = true, burst_size = 300, adaptive_burst_size = true, burst_fire_rate_multiplier = 400/600}
	self.parts.inf_bar_slowfire.stats = deep_clone(nostats)
DelayedCalls:Add("bardelaycall", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_ass_bar.override.wpn_fps_snp_msr_ns_suppressor = {
		stats = deep_clone(silstatsconc2),
		custom_stats = silencercustomstats,
		desc_id = "bar_sil_desc",
		forbids = {"wpn_fps_ass_bar_bipod"}
	}
end)
end

if BeardLib.Utils:ModLoaded("QBZ-97B") then
	self.parts.wpn_fps_ass_qbz97b_mag_short.stats = deep_clone(mag_66)
	self.parts.wpn_fps_ass_qbz97b_mag_short.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_qbz97b_mag_pmag.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_qbz97b_mag_magpul.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_qbz97b_95b_body.custom_stats = {sdesc1 = "caliber_r58x42"}
	self.parts.wpn_fps_ass_qbz97b_95b_body.stats = deep_clone(nostats)
	-- fuck these sights
	self.parts.wpn_fps_ass_qbz97b_sights_95b.pcs = nil
	self.parts.wpn_fps_ass_qbz97b_rec_upper.stance_mod = {
		wpn_fps_ass_qbz97b = {translation = Vector3(0, 3, -2.35), rotation = Rotation(0, 1.5, 0)}
	}
	self.parts.wpn_fps_ass_qbz97b_rail.stance_mod = {
		wpn_fps_ass_qbz97b = {translation = Vector3(0, 0, 2.565), rotation = Rotation(0, -1.6, 0)}
	}
	self.parts.wpn_fps_ass_qbz97b_95b_body.stance_mod = {
		wpn_fps_ass_qbz97b = {translation = Vector3(0, 0, 1.7), rotation = Rotation(0, -0.7, 0)}
	}
	self.parts.wpn_fps_ass_qbz97b_95b_body.adds = {"wpn_fps_ass_qbz97b_95b_wrap", "wpn_fps_ass_qbz97b_sights_95b"}
	self.parts.wpn_fps_ass_qbz97b_95b_body.override.wpn_fps_ass_qbz97b_sights = {unit = dummy, third_unit = dummy}
	self.parts.wpn_fps_ass_qbz97b_95b_body.override.wpn_fps_ass_qbz97b_rail.stance_mod = {
		wpn_fps_ass_qbz97b = {translation = Vector3(0, 0, 0.15), rotation = Rotation(0, 0.6, 0)}
	}
DelayedCalls:Add("qbz97bdelaycall", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_ass_qbz97b_sights.stance_mod = {}
	tweak_data.weapon.factory.parts.wpn_fps_ass_qbz97b_sights_95b.stance_mod = {}
end)
end

if BeardLib.Utils:ModLoaded("Seburo M5") then
	self.parts.wpn_fps_pis_seburo_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_seburo_f_silver.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_seburo_s_silver.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_seburo_autofire.stats = deep_clone(nostats)

	self.parts.wpn_fps_pis_seburo_m_extended.stats = deep_clone(mag_133)
	self.parts.wpn_fps_pis_seburo_m_extended.stats.extra_ammo = 6

	self.parts.wpn_fps_pis_seburo_s_s9.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_seburo_g_s9.stats = deep_clone(nostats)
DelayedCalls:Add("seburom5delaycall", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_pis_seburo.override.wpn_fps_pis_seburo_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_seburo.override.wpn_fps_pis_seburo_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_seburo.override.wpn_fps_pis_seburo_m_extended.stats.extra_ammo = tweak_data.weapon.factory.parts.wpn_fps_pis_seburo_m_extended.stats.extra_ammo * 2

	tweak_data.weapon.factory.parts.wpn_fps_pis_x_seburo_sight_up.stats.gadget_zoom = 3
	tweak_data.weapon.factory.parts.wpn_fps_pis_x_seburo_sight_up.stance_mod.wpn_fps_pis_x_seburo = {translation = Vector3(-3.8, 0, 0.9), rotation = Rotation(0, 0, 0)}
end)
end


if BeardLib.Utils:ModLoaded("HKG11") then
	self.parts.wpn_fps_upg_temple_i_matthewreilly.perks = nil
	self.parts.wpn_fps_upg_temple_i_matthewreilly.custom_stats = {has_burst_fire = false, inf_rof_mult = 2100/460} -- this is fucking stupid
	self.parts.wpn_fps_upg_temple_i_matthewreilly.stats = {
		value = 0,
		spread = -20,
		concealment = 0
	}
--[[
	self.parts.wpn_fps_ass_temple_o_dummy.scope_overlay_hide_weapon = true
	self.parts.wpn_fps_ass_temple_o_dummy.scope_overlay = "guis/dlcs/mods/textures/pd2/overlay/g11_reticleoverlay"
--]]
	self.parts.wpn_fps_ass_temple_o_dummy.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_ass_temple_o_dummy.stats = {
		value = 0,
		zoom = 3,
		concealment = 0
	}
end

if BeardLib.Utils:ModLoaded("Beretta 93R") then
	self.parts.wpn_fps_upg_b93r_comp_93r.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_upg_b93r_comp_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_upg_b93r_flash.stats = {
		value = 0,
		spread = 2,
		recoil = 1,
		concealment = -1
	}
	self.parts.wpn_fps_upg_b93r_grip_plastic.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_b93r_leupold_pro.stats = {
		value = 0,
		zoom = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_b93r_ncstar_4.stats = {
		value = 0,
		zoom = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_b93r_sight_tritium.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_b93r_vertgrip_rail.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("TOZ-34") then
	self.parts.wpn_fps_shot_toz34_sight_rail.stance_mod = {wpn_fps_shot_toz34 = {translation = Vector3(0, -11, -0.2), rotation = Rotation(0, 0.2, 0)}}
	self.parts.wpn_fps_shot_toz34_body.stance_mod = {wpn_fps_shot_toz34 = {translation = Vector3(0, 11, 0.2), rotation = Rotation(0, -0.2, 0)}}
	self.parts.wpn_fps_shot_toz34_body.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_toz34_ammo_000_magnum.custom_stats = {
		rays = 8,
		damage_near_mul = 0.80,
		damage_far_mul = 0.80,
		sdesc1 = "caliber_s12g_000magnum",
		ammo_pickup_min_mul = 0.80,
		ammo_pickup_max_mul = 0.80
	}
	self.parts.wpn_fps_upg_toz34_ammo_000_magnum.stats = {
		value = 0,
		total_ammo_mod = -200,
		damage = 6
	}
	self.parts.wpn_fps_upg_toz34_barrel_short.stats = deep_clone(db_barrel)
	self.parts.wpn_fps_upg_toz34_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_toz34_choke_modified.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_toz34_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
	self.parts.wpn_fps_upg_toz34_stock_short.stats = deep_clone(db_stock)
end


	-- MEUSOC grip
if BeardLib.Utils:ModLoaded("Pachmayr Grip") then
	self.parts.wpn_fps_pis_1911_g_pachmayr.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("TOZ-66") then
	self.parts.wpn_fps_shot_toz66_body.stats = {}
	self.parts.wpn_fps_shot_toz66_body.stance_mod = {wpn_fps_shot_toz66 = {translation = Vector3(0, 0, 1.5)}}

	self.parts.wpn_fps_upg_toz66_ammo_000_magnum.custom_stats = {
		rays = 8,
		damage_near_mul = 0.80,
		damage_far_mul = 0.80,
		sdesc1 = "caliber_s12g_000magnum",
		ammo_pickup_min_mul = 0.80,
		ammo_pickup_max_mul = 0.80
	}
	self.parts.wpn_fps_upg_toz66_ammo_000_magnum.stats = {
		value = 0,
		total_ammo_mod = -200,
		damage = 6
	}
	self.parts.wpn_fps_upg_toz66_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_toz66_choke_modified.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_toz66_duckbill.stats = deep_clone(self.parts.wpn_fps_upg_ns_duck.stats)
end

if BeardLib.Utils:ModLoaded("PU Scope") then
	self.parts.wpn_fps_snp_mosin_pu_scope.custom_stats = {disallow_ads_while_reloading = true}
end

if BeardLib.Utils:ModLoaded("pdr") then
	-- swift mag
	self.parts.wpn_fps_smg_pdr_m_pmag.stats = deep_clone(nostats)
	-- short mag
	self.parts.wpn_fps_smg_pdr_m_short.stats = deep_clone(mag_66)
	self.parts.wpn_fps_smg_pdr_m_short.stats.extra_ammo = -10
end

if BeardLib.Utils:ModLoaded("Steyr AUG A3 9mm XS") then
	self.parts.wpn_fps_smg_aug9mm_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_aug9mm_barrel_long.stats = {
		value = 0,
		spread = 15,
		recoil = 9,
		reload = -12,
		concealment = -2
	}
	self.parts.wpn_fps_upg_aug9mm_barrel_medium.stats = {
		value = 0,
		spread = 5,
		recoil = 3,
		reload = -4,
		concealment = -1
	}
	self.parts.wpn_fps_upg_aug9mm_mag_ext.stats = deep_clone(mag_133)
	self.parts.wpn_fps_upg_aug9mm_mag_ext.stats.extra_ammo = 8

	self.parts.wpn_fps_upg_aug9mm_supp_gm9.custom_stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_medium.custom_stats)
	self.parts.wpn_fps_upg_aug9mm_supp_gm9.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_medium.stats)
	self.parts.wpn_fps_upg_aug9mm_supp_osprey.custom_stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_large.custom_stats)
	self.parts.wpn_fps_upg_aug9mm_supp_osprey.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_large.stats)
	self.parts.wpn_fps_upg_aug9mm_vg_bcm.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_upg_aug9mm_vg_fab_reg.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_aug9mm_vg_m900.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_aug9mm_vg_troy.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_aug9mm_vg_troy_short.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("L115") then
	table.insert(gunlist_snp, {"wpn_fps_snp_l115", -3})
	self.parts.wpn_fps_snp_l115_mag.stats = nil
	table.insert(self.wpn_fps_snp_l115.uses_parts, "inf_shortdot")
	self.parts.inf_shortdot.stance_mod.wpn_fps_snp_l115 = deep_clone(self.parts.inf_shortdot.stance_mod.wpn_fps_snp_msr)

	self.parts.wpn_fps_upg_l115_barrel_awc.custom_stats = snpsilencercustomstats
	--self.parts.wpn_fps_upg_l115_barrel_awc.custom_stats.sdesc1 = "caliber_r308"
	self.parts.wpn_fps_upg_l115_barrel_awc.stats = deep_clone(silstatssnp)
	self.parts.wpn_fps_upg_l115_supp.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_l115_supp.stats = deep_clone(silstatssnp)
	if BeardLib.Utils:ModLoaded("Custom Attachment Points") or BeardLib.Utils:ModLoaded("WeaponLib") then
		table.insert(self.wpn_fps_snp_l115.uses_parts, "inf_bipod_snp")
	end
end

if BeardLib.Utils:ModLoaded("US Optics ST-10 Scope") then
	self.parts.wpn_fps_upg_o_st10.customsight = true
	self.parts.wpn_fps_upg_o_st10.customsighttrans = {}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 3, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 10, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, -10, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, -10, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, -10, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 14, 0)}
	self.parts.wpn_fps_upg_o_st10.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 2, 0)}
	self.parts.wpn_fps_upg_o_st10.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_specter.custom_stats)
	self.parts.wpn_fps_upg_o_st10.stats = {
		value = 0,
		zoom = 8,
		concealment = -3
	}
end

if BeardLib.Utils:ModLoaded("ZeissMod") then
	self.parts.wpn_fps_upg_o_zeiss.customsight = true
	self.parts.wpn_fps_upg_o_zeiss.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
end

if BeardLib.Utils:ModLoaded("AK Topless") then
	self.parts.wpn_fps_ass_akm_topless.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ass_akm_topless")
	table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_akm_topless")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_akm_topless")
	table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_akm_topless")
	primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_akm_topless")
end

if BeardLib.Utils:ModLoaded("Montana 5.56") then
	self.parts.wpn_fps_ass_yayo_fg_rail.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_yayo_mag_dual.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_ass_yayo_mag_dual.stats = {
		value = 0,
		reload = -20,
		concealment = -1
	}
	self.parts.wpn_fps_ass_yayo_mag_pmag.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_yayo_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
	-- pacino grip
	self.parts.wpn_fps_ass_yayo_g_ergo.stats = deep_clone(nostats)
	-- tony grip
	self.parts.wpn_fps_ass_yayo_g_hk.stats = deep_clone(nostats)
	-- soza stock (dark tactical)
	self.parts.wpn_fps_ass_yayo_s_tactical.stats = deep_clone(nostats)
	-- modern stock (dark standard)
	self.parts.wpn_fps_ass_yayo_s_modern.stats = deep_clone(nostats)
	--
	self:convert_part("wpn_fps_ass_yayo_potato", "lrifle", "lrifle", 120, InFmenu.wpnvalues.lrifle.ammo)
	self.parts.wpn_fps_ass_yayo_potato.custom_stats.sdesc3 = "misc_blank"
	self.parts.wpn_fps_ass_yayo_potato.stats = {
		value = 0,
		total_ammo_mod = 500,
		concealment = 4
	}

	self.parts.wpn_fps_ass_yayo_flipup.stance_mod.wpn_fps_ass_yayo = {translation = Vector3(0, 0, -1), rotation = Rotation(0, -0.5, 0)}
end

if BeardLib.Utils:ModLoaded("Bren Ten") then
	self.parts.wpn_fps_pis_sonny_sl_runt.stats = {
		value = 0,
		spread = -5,
		concealment = 1
	}
end

if BeardLib.Utils:ModLoaded("VisionKing VS1.5-5x30QZ") then
	self.parts.wpn_fps_upg_o_visionking.customsight = true
	self.parts.wpn_fps_upg_o_visionking.customsighttrans = {}
	self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 10, 0)}
	self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 16, 0)}
	self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 16, 0)}
	self.parts.wpn_fps_upg_o_visionking.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 8, 0)}
	self.parts.wpn_fps_upg_o_visionking.custom_stats = {self.parts.wpn_fps_upg_o_specter.custom_stats}
	self.parts.wpn_fps_upg_o_visionking.stats = {
		value = 0,
		zoom = 7,
		concealment = -3
	}
end

if BeardLib.Utils:ModLoaded("CompM4s Sight") then
	self.parts.wpn_fps_upg_o_compm4s.customsight = true
	self.parts.wpn_fps_upg_o_compm4s.stats = {
		value = 0,
		zoom = 0,
		concealment = -1,
	}
end

if BeardLib.Utils:ModLoaded("STG 44") then
	self.parts.wpn_fps_ass_stg44_b_short.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_stg44_b_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_ass_stg44_m_short.stats = deep_clone(mag_33)
	self.parts.wpn_fps_ass_stg44_m_short.stats.extra_ammo = -20

	self.parts.wpn_fps_ass_stg44_m_long.stats = deep_clone(mag_133)
	self.parts.wpn_fps_ass_stg44_m_long.stats.extra_ammo = 10

	self.parts.wpn_fps_ass_stg44_m_double.custom_stats = {alternating_reload = 1.5}
	self.parts.wpn_fps_ass_stg44_m_double.stats = deep_clone(mag_alternating)

	self.parts.wpn_fps_ass_stg44_m_short_double.custom_stats = {alternating_reload = 1.5}
	self.parts.wpn_fps_ass_stg44_m_short_double.stats = deep_clone(mag_alternating)
	self.parts.wpn_fps_ass_stg44_m_short_double.stats.extra_ammo = -20

	self.parts.wpn_fps_ass_stg44_s_plast.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_stg44_sing.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_stg44_o_scope.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_acog.custom_stats)
	self.parts.wpn_fps_ass_stg44_o_scope.stats = deep_clone(self.parts.wpn_fps_upg_o_acog.stats)
	self.parts.wpn_fps_ass_stg44_o_scope_switch.custom_stats = deep_clone(self.parts.wpn_fps_upg_o_acog.custom_stats)
	self.parts.wpn_fps_ass_stg44_o_scope_switch.stats = deep_clone(self.parts.wpn_fps_upg_o_acog.stats)
	self.parts.wpn_fps_ass_stg44_fg_mp5.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_stg44_fg_r.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_stg44_s_a280.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	self.parts.wpn_fps_ass_stg44_fg_a280.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("HK G3A3 M203") then
	self.parts.wpn_fps_ass_g3m203_mag.stats = {}
	self.parts.wpn_fps_upg_g3m203_barrel_g3ka4.stats = {
		value = 0,
		spread = -5,
		concealment = 1
	}
	self.parts.wpn_fps_upg_g3m203_grip_psg1.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_handguard_rail.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_handguard_psg1.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_handguard_wide.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_handguard_wide_bipod.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_handguard_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_stock_g3ka4.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	self.parts.wpn_fps_upg_g3m203_stock_magpul_prs.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_stock_magpul_prs_largepad.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_upg_g3m203_stock_psg1.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	self.parts.wpn_fps_upg_g3m203_stock_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g3m203_supp_socom762.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_g3m203_supp_socom762.stats = deep_clone(silstatsconc1)
	self.parts.wpn_fps_upg_g3m203_trigger_group_navy.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats or {}
	self.parts.wpn_fps_upg_g3m203_gre_buckshot.custom_stats.sdesc3 = "misc_gl40x46mmbuck"
	self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats or {}
	self.parts.wpn_fps_upg_g3m203_gre_flechette.custom_stats.sdesc3 = "misc_gl40x46mmflechette"
	self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats = self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats or {}
	self.parts.wpn_fps_upg_g3m203_gre_incendiary.custom_stats.sdesc3 = "misc_gl40x46mmIC"
end

if BeardLib.Utils:ModLoaded("AAC Honey Badger") then
	-- default part
	self.parts.wpn_fps_ass_bajur_b_std.custom_stats = silencercustomstats

	self.parts.wpn_fps_upg_bajur_b_long.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_bajur_b_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_upg_bajur_b_long.stats.alert_size = 12
	self.parts.wpn_fps_upg_bajur_b_long.stats.spread = self.parts.wpn_fps_upg_bajur_b_long.stats.spread + 5
	self.parts.wpn_fps_upg_bajur_b_short.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_bajur_b_short.stats = {
		value = 0,
		alert_size = 12,
		spread = -5,
		concealment = 1
	}
	self.parts.wpn_fps_upg_bajur_m_quick.stats = deep_clone(mag_66)
	self.parts.wpn_fps_upg_bajur_m_quick.stats.extra_ammo = -10
	self.parts.wpn_fps_upg_bajur_m_plate.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_bajur_s_ext.stats = {
		value = 0,
		recoil = 5,
		concealment = -2
	}
	self.parts.wpn_fps_upg_bajur_s_nope.stats = {
		value = 0,
		recoil = -5,
		concealment = 2
	}
	self:convert_part("wpn_fps_upg_bajur_am_grendel", "mrifle", "hrifle")
	self.parts.wpn_fps_upg_bajur_am_grendel.custom_stats = {sdesc1 = "caliber_r65grendel"}
	self.parts.wpn_fps_upg_bajur_am_grendel.stats.extra_ammo = -5
	self.parts.wpn_fps_upg_bajur_am_grendel.stats.reload = 10

	self.parts.wpn_fps_upg_bajur_fg_dmr.stats.extra_ammo = -10
	self.parts.wpn_fps_upg_bajur_fg_dmr.stats.concealment = -1
DelayedCalls:Add("bajurdelaycall", delay, function(self, params)
	tweak_data.weapon.factory:convert_part("wpn_fps_upg_bajur_fg_dmr", "mrifle", "ldmr")
	tweak_data.weapon.factory.parts.wpn_fps_upg_bajur_fg_dmr.custom_stats = {sdesc1 = "caliber_r50beowulf"}
end)
end

if BeardLib.Utils:ModLoaded("Kobra Sight") then
	self.parts.wpn_fps_upg_o_kobra.customsight = true
	self.parts.wpn_fps_upg_o_kobra.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
end

if BeardLib.Utils:ModLoaded("OKP-7 Sight") then
	self.parts.wpn_fps_upg_o_okp7.customsight = true
	self.parts.wpn_fps_upg_o_okp7.customsighttrans = {}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0.6, 0, 0.93)}
	self.parts.wpn_fps_upg_o_okp7.stats = deep_clone(self.parts.wpn_fps_upg_o_t1micro.stats)
end

if BeardLib.Utils:ModLoaded("af2011") then
	self.parts.wpn_fps_pis_af2011_body_standard.stats = {
		value = 0,
		spread_multi = {2.00, 0.50},
		concealment = 0
	}

	self.parts.wpn_fps_pis_af2011_g_bling.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_af2011_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_af2011_b_silver.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_af2011_m_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_af2011_m_ext.stats.extra_ammo = 10
--[[
	self.parts.wpn_fps_pis_af2011_a_uno.custom_stats = {sdesc1 = "caliber_p38spc"}
	self.parts.wpn_fps_pis_af2011_a_uno.stats = {
		value = 0,
		damage = -10,
		recoil = 10,
		concealment = 0
	}
--]]
--[[
	self.parts.wpn_fps_pis_af2011_a_shield.custom_stats = {sdesc1 = "caliber_p45s"}
	self.parts.wpn_fps_pis_af2011_a_shield.stats = {
		value = 0,
		damage = InFmenu.wpnvalues.supermediumpis.damage - InFmenu.wpnvalues.mediumpis.damage,
		recoil = InFmenu.wpnvalues.supermediumpis.recoil - InFmenu.wpnvalues.mediumpis.recoil,
		concealment = 0
	}
--]]
	self:convert_part("wpn_fps_pis_af2011_a_uno", "mediumpis", "lightpis", 96, 160)
	self.parts.wpn_fps_pis_af2011_a_uno.custom_stats.sdesc1 = "caliber_p38spc"
	self:convert_part("wpn_fps_pis_af2011_a_shield", "mediumpis", "supermediumpis", 96, 64)
	self.parts.wpn_fps_pis_af2011_a_shield.custom_stats.sdesc1 = "caliber_p45s"
DelayedCalls:Add("af2011delaycall", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_pis_x_af2011.override.wpn_fps_pis_af2011_m_ext.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_pis_af2011_m_ext.stats)
	tweak_data.weapon.factory.wpn_fps_pis_x_af2011.override.wpn_fps_pis_af2011_m_ext.stats.extra_ammo = tweak_data.weapon.factory.parts.wpn_fps_pis_af2011_m_ext.stats.extra_ammo * 2
end)
end

if BeardLib.Utils:ModLoaded("1P69 Giperon Scope CS5") then
	self.parts.wpn_fps_upg_o_1p69.customsight = true
	self.parts.wpn_fps_upg_o_1p69.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_1p69.stats = {
		value = 0,
		zoom = 8,
		concealment = -3
	}
end

if BeardLib.Utils:ModLoaded("STF-12") then
	-- it's a short barrel
	self.parts.wpn_fps_shot_stf12_b_long.stats = deep_clone(barrelsho_p1)
	self.parts.wpn_fps_shot_stf12_choke.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)

	-- fix ADS
	self.parts.wpn_fps_shot_stf12_body_standard.stance_mod = {}
	--self.parts.wpn_fps_shot_stf12_body_standard.stance_mod.wpn_fps_shot_stf12 = {translation = Vector3(0, 0, -1.5), rotation = Rotation(0, 0, 0)}
	-- can't just stick the magnifier on without a sight to magnify
	self.parts.wpn_fps_shot_stf12_sights.forbids = self.parts.wpn_fps_shot_stf12_sights.forbids or {}
	table.insert(self.parts.wpn_fps_shot_stf12_sights.forbids, "wpn_fps_upg_o_xpsg33_magnifier")
	table.insert(customsightaddlist, {"wpn_fps_shot_stf12", "wpn_fps_shot_r870", true})
end

if BeardLib.Utils:ModLoaded("PO 4x24P Scope") then
	self.parts.wpn_fps_upg_o_po4.customsight = true
	self.parts.wpn_fps_upg_o_po4.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_po4.stats = {
		value = 0,
		zoom = 6,
		concealment = -2
	}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m4 = {translation = Vector3(0.204, 0, 0.70)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_amcar = {translation = Vector3(0.204, -1, 1.16)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m16 = {translation = Vector3(0.2, 0, 1.15)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_olympic = {translation = Vector3(0.2, 0, 1.14)} -- automatically transferred to primary version
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_74 = {translation = Vector3(0.2, -16, -1.9)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_akm = {translation = Vector3(0.2, -16, -1.9)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_akm_gold = {translation = Vector3(0.2, -16, -1.9)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_asval = {translation = Vector3(0.205, 3, 1.27)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_saiga = {translation = Vector3(0.26, -16, -1.71)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_r870 = {translation = Vector3(0.217, -5, -3.51)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_akmsu = {translation = Vector3(0.2, -16, -2.07)} --
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_ak5 = {translation = Vector3(0.22, -5, -2.26)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_aug = {translation = Vector3(0.2, 0, -1.53)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_g36 = {translation = Vector3(0.18, -5, -1.71)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_m14 = {translation = Vector3(0.18, -15, -2.59)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp5 = {translation = Vector3(0.2, 0, -1.67)} --
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_s552 = {translation = Vector3(0.155, 0, -0.88)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_scar = {translation = Vector3(0.2, -3, 0.97)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_m95 = {translation = Vector3(0.2, -4, -2.56)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_msr = {translation = Vector3(0.205, -14, -2.295)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_r93 = {translation = Vector3(0.20, -10, -2.51)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_fal = {translation = Vector3(0.2, 0, -2.27)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_ben = {translation = Vector3(0.2, -5, -1.97)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_ksg = {translation = Vector3(0.2, 0, -0.05)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_g3 = {translation = Vector3(0.235, -8, -2.14)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_galil = {translation = Vector3(0.20, -2, -1.96)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_famas = {translation = Vector3(0.20, -5, -5)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_spas12 = {translation = Vector3(0.04, 0, -2.69)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_mosin = {translation = Vector3(0.2, -32, -3.03)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_thompson = {translation = Vector3(0.2, -24, -2.95)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_l85a2 = {translation = Vector3(0.19, 2, 3.135)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_vhs = {translation = Vector3(0.195, -4, 0.07)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_aa12 = {translation = Vector3(0.19, 0, 1.35)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_m32 = {translation = Vector3(0.2, 3, 2.2)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_wa2000 = {translation = Vector3(0.195, -9, 2.015)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_tecci = {translation = Vector3(0.205, 2, -0.43)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_model70 = {translation = Vector3(0.2, -12, -2.78)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_hajk = {translation = Vector3(0.2, 0, 0.77)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_desertfox = {translation = Vector3(0.195, -20, -2.69)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_schakal = {translation = Vector3(0.2, 0, -1.55)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_contraband = {translation = Vector3(0.195, -5, -0.43)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_tti = {translation = Vector3(0.2, 1, 1.15)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_snp_siltstone = {translation = Vector3(0.2, 4, -2.76)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_flint = {translation = Vector3(0.19, 0, -1.435)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_coal = {translation = Vector3(0.2, 10, -2.75)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_ching = {translation = Vector3(0.2, -18, -1.51)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_bow_ecp = {translation = Vector3(0.2, -10, -2.08)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_corgi = {translation = Vector3(0.2, -11, -1.03)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_shepheard = {translation = Vector3(0.195, -8, 0.84)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_ass_komodo = {translation = Vector3(0.2, 3, 1.35)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_bow_elastic = {translation = Vector3(0.2, 0, -0.25)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_serbu = {translation = Vector3(0.22, -4, -3.5)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_p90 = {translation = Vector3(0.195, -4, -1.77)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp9 = {translation = Vector3(0.2, 4, -2.22)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mac10 = {translation = Vector3(0.2, -12, -1.84)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_m45 = {translation = Vector3(0.195, -14, -2.67)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_mp7 = {translation = Vector3(0.195, -4, -1.56)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_rage = {translation = Vector3(0.17, -15, -3.35)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_deagle = {translation = Vector3(0.2, -18, -3.45)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_striker = {translation = Vector3(0.2, 0, -1.51)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_scorpion = {translation = Vector3(0.195, -10, -3.92)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_tec9 = {translation = Vector3(0.2, -2, -3.73)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_uzi = {translation = Vector3(0.2, -6, -3.83)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_pis_judge = {translation = Vector3(0.24, -16, -4.06)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_rpg7 = {translation = Vector3(0.2, 3, 1.28)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_polymer = {translation = Vector3(0.2, 2, 0.60)}
	--self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_shot_m37 = {translation = Vector3(0.2, -8, -2.80)} -- not usable
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_sr2 = {translation = Vector3(0.195, 10, -3.31)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_rota = {translation = Vector3(0.2, -6, 0.84)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_arbiter = {translation = Vector3(0.2, 0, 0.85)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_smg_erma = {translation = Vector3(0.202, -4, -2.9)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_sho_basset = {translation = Vector3(0.195, -2, 0.56)}
	self.parts.wpn_fps_upg_o_po4.stance_mod.wpn_fps_gre_slap = {translation = Vector3(0.18, 0, -0.59)}
end

if BeardLib.Utils:ModLoaded("CheyTac M200") then
	-- big default scope with 8 zoom
	table.insert(gunlist_snp, {"wpn_fps_snp_m200", -4})
	self.parts.wpn_fps_snp_m200_deltatitanium.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_snp_m200_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m200_barrel_bipod.adds = {"inf_bipod_part"}
	self.parts.wpn_fps_upg_m200_barrel_bipod.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_m200_supp.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_m200_supp.stats = deep_clone(silstatssnp)
end

if BeardLib.Utils:ModLoaded("EOTech 552 Holographic Sight") then
	self.parts.wpn_fps_upg_o_eotech552.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)

	self.parts.wpn_fps_upg_o_eotech552.customsight = true
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans = {}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 0, 0.335)}
	self.parts.wpn_fps_upg_o_eotech552.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 0, 0.335)}
DelayedCalls:Add("eotech552_grayingmyhair", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_upg_o_eotech552.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -10, -1)}
end)
end

if BeardLib.Utils:ModLoaded("Minebea SMG") then
	self.parts.wpn_fps_smg_minebea_m_standard.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_minebea_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_minebea_m_extended.stats.extra_ammo = 10
	self.parts.wpn_fps_smg_minebea_s_no.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_smg_minebea_s_extended.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	--self.parts.wpn_fps_smg_minebea_barrelext.custom_stats = {muzzleflash = "effects/payday2/particles/weapons/9mm_auto_silence"}
	self.parts.wpn_fps_smg_minebea_barrelext.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_smg_minebea_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_minebea_o_adapter.forbidden_by_sight_rail = true
	self.parts.wpn_fps_smg_minebea_ironsight.forbids = {"inf_sightrail_invis"}
DelayedCalls:Add("minebeadelay", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_smg_minebea_m_extended.stats)
	tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats.extra_ammo = tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_m_extended.stats.extra_ammo * 2

	tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_s_extended = {desc_id = "bm_wp_wpn_fps_smg_minebea_s_extended_desc_x"}
	tweak_data.weapon.factory.wpn_fps_smg_x_minebea.override.wpn_fps_smg_minebea_s_no = {desc_id = "bm_wp_wpn_fps_smg_minebea_s_no_desc_x"}

	tweak_data.weapon.factory.parts.wpn_fps_smg_minebea_ironsight.stance_mod = {
		wpn_fps_smg_minebea = {translation = Vector3(-0.025, -7, -0.7)}
	}
end)
end

if BeardLib.Utils:ModLoaded("Thermal Scope") then
	self.parts.wpn_fps_upg_o_thersig.stats = deep_clone(self.parts.wpn_fps_upg_o_aimpoint.stats)
end

if BeardLib.Utils:ModLoaded("Ghost Ring Sight") then
	self.parts.wpn_fps_upg_p226_o_ghostring.stats = deep_clone(nostats)
	local r870stocks = {"wpn_fps_shot_r870_s_folding", "wpn_fps_upg_m4_s_standard", "wpn_fps_upg_m4_s_pts", "wpn_fps_upg_m4_s_crane", "wpn_fps_upg_m4_s_mk46", "wpn_fps_upg_m4_s_ubr", "wpn_fps_snp_tti_s_vltor"}
	for a, stock in pairs(r870stocks) do
		self.parts[stock].forbids = self.parts[stock].forbids or {}
		table.insert(self.parts[stock].forbids, "wpn_fps_upg_870_o_ghostring")
		table.insert(self.parts[stock].forbids, "wpn_fps_upg_870_o_ghostring_short")
	end

	self.parts.wpn_fps_upg_870_o_ghostring.forbids = self.parts.wpn_fps_upg_870_o_ghostring.forbids or {}
	table.insert(self.parts.wpn_fps_upg_870_o_ghostring.forbids, "wpn_fps_ass_scar_o_flipups_up")
	self.parts.wpn_fps_upg_870_o_ghostring_short.forbids = self.parts.wpn_fps_upg_870_o_ghostring_short.forbids or {}
	table.insert(self.parts.wpn_fps_upg_870_o_ghostring_short.forbids, "wpn_fps_ass_scar_o_flipups_up")

	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_upg_m37_o_ghostring")
	self.wpn_fps_shot_m37primary.adds = self.wpn_fps_shot_m37primary.adds or {}
	self.wpn_fps_shot_m37primary.adds.wpn_fps_upg_m37_o_ghostring = {"inf_sightdummy"}

-- no worky
--[[
DelayedCalls:Add("ghostringdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_upg_m37_o_ghostring.stance_mod.wpn_fps_shot_m37primary = {translation = Vector3(0, 0, -0.61)}
end)
--]]
end

if BeardLib.Utils:ModLoaded("HX25 Handheld Grenade Launcher") then
	self.parts.wpn_fps_gre_hx25_barrel.custom_stats = {}
	self.parts.wpn_fps_gre_hx25_barrel.stats = {
		value = 0,
		spread_multi = {2, 2},
		concealment = 0
	}
	-- default ammo
	self.parts.wpn_fps_gre_hx25_explosive_ammo.custom_stats = {
		ignore_statistic = true,
		damage_far_mul = 10,
		damage_near_mul = 10,
		bullet_class = "InstantExplosiveBulletBase",
		rays = 1,
		sdesc3 = nil,
		sdesc3_range_override = true,
		instant_multishot_per_1ammo = 7,
		instant_multishot_dmg_mul = 1/7,
		bullet_damage_fraction = 0.25
	}
	self.parts.wpn_fps_upg_hx25_buckshot_ammo.sound_switch = {suppressed = "infalt"}
	self.parts.wpn_fps_upg_hx25_buckshot_ammo.custom_stats = {rays = 20, sdesc1 = "caliber_ghx25buck", ammo_pickup_max_mul = 2}
	self.parts.wpn_fps_upg_hx25_buckshot_ammo.stats = {
		value = 0,
		spread = -20,
		concealment = 0
	}
	--[[
	self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.custom_stats = {
		armor_piercing_add = 1,
		ammo_pickup_max_mul = 2,
		ignore_statistic = true,
		muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath",
		bullet_class = "FlameBulletBase",
		can_shoot_through_shield = true,
		rays = 12,
		fire_dot_data = {
			dot_trigger_chance = "100",
			dot_damage = "1.5",
			dot_length = "3.1",
			dot_trigger_max_distance = "1500",
			dot_tick_period = "0.5"
		},
		sdesc1 = "caliber_ghx25db",
		sdesc3 = "range_shotdb",
		sdesc3_range_override = true
	}
	
	self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.sound_switch = {suppressed = "infalt"}
	self.parts.wpn_fps_upg_hx25_dragons_breath_ammo.stats = {
		value = 0,
		damage = -12,
		spread = -35,
		concealment = 0
	}
	]]
	self.parts.wpn_fps_upg_hx25_sight_iron_il.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hx25_sight_rmr.stats = {
		value = 0,
		concealment = -1
	}
end

if BeardLib.Utils:ModLoaded("Illuminated Iron Sight Pack") then
	self.parts.wpn_fps_upg_1911_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_b92fs_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_baka_tritium.stats = {value = 0, concealment = 0}
	--self.parts.wpn_fps_upg_colt_def_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_deagle_tritium.stats = {value = 0, concealment = 0}
	--self.parts.wpn_fps_upg_fs_tritium.stats = {value = 0, concealment = 0}
	--self.parts.wpn_fps_upg_g18c_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_g22c_tritium.stats = {value = 0, concealment = 0}
	--self.parts.wpn_fps_upg_g26_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_hs2000_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_sparrow_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_p226_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_pl14_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_usp_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_asval_nightsight.stats = {value = 0, concealment = 0}
	primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_akmsu_nightsight")
	primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_cz805_tritium")
	primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_ump45_tritium")
	self.parts.wpn_fps_upg_asval_nightsight.forbids = {"inf_sightrail"}
	
	self.parts.wpn_fps_upg_beer_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_chinchilla_fiber.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_czech_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_shrew_tritium.stats = {value = 0, concealment = 0}
	self.parts.wpn_fps_upg_stech_tritium.stats = {value = 0, concealment = 0}
end

if BeardLib.Utils:ModLoaded("stock_attachment_pack") then
	primarysmgadds_specific.wpn_fps_smg_mp5primary = primarysmgadds_specific.wpn_fps_smg_mp5primary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_folded")
	table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_adjusted")
	table.insert(primarysmgadds_specific.wpn_fps_smg_mp5primary, "wpn_fps_smg_mp5_s_nostock")
	primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_smg_schakal_s_nostock")
	primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_smg_hajk_s_nostock")
	table.insert(self.wpn_fps_smg_x_hajk.uses_parts, "wpn_fps_smg_hajk_s_nostock")
	primarysmgadds_specific.wpn_fps_smg_coalprimary = primarysmgadds_specific.wpn_fps_smg_coalprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_coalprimary, "wpn_fps_smg_coal_s_nostock")
	primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_smg_olympic_s_adjusted")

	self.parts.wpn_fps_ass_tecci_s_extended.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_smg_tec9_s_retrac2.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_smg_tec9_s_retrac1.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_m4_s_collapsed.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_upg_m4_s_pts_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_upg_m4_s_crane_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_upg_m4_s_mk46_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_upg_m4_s_ubr_col.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_smg_olympic_s_adjusted.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_ass_ak5_s_ak5c_ret.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_ass_tecci_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_shot_r870_s_unfolded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_smg_mp9_s_folded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_smg_cobray_s_folded.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_smg_coal_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_smg_mp7_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)
	self.parts.wpn_fps_gre_slap_s_nostock.stats = deep_clone(self.parts.wpn_fps_upg_m4_s_collapsed.stats)

	self.parts.wpn_upg_ak_s_collapsed.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.wpn_fps_ass_asval.override = self.wpn_fps_ass_asval.override or {}
	self.wpn_fps_ass_asval.override.wpn_upg_ak_s_collapsed = {adds = {"wpn_fps_ass_asval_g_standard"}}

	self.parts.wpn_upg_ak_s_folded_gold.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_upg_saiga_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_upg_ak_s_skfolded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_ak5_s_ak5a_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_ak5_s_ak5b_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_ak5_s_ak5c_col.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_m14_body_collapsed.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_smg_mp5_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_asval_s_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_lmg_m249_s_retracted.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_smg_cobray_s_nostock.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_sta_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_fab_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_light_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_plastic_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_skeletal_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_sniper_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_ass_galil_s_wood_folded.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)
	self.parts.wpn_fps_smg_schakal_s_nostock.stats = deep_clone(self.parts.wpn_upg_ak_s_collapsed.stats)

	self.parts.wpn_fps_ass_g3_s_nostock.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
	self.parts.wpn_fps_smg_mp5_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_smg_uzi_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_smg_polymer_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_ass_fal_s_folded.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_snp_winchester_s_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_snp_r93_body_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_snp_msr_body_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_snp_model70_s_sawed.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_lmg_mg42_reciever_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_lmg_hk21_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_smg_hajk_s_nostock.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)
	self.parts.wpn_fps_smg_mp5_s_adjusted.stats = deep_clone(self.parts.wpn_fps_ass_g3_s_nostock.stats)

	self.parts.wpn_fps_sho_ben_s_nostock.stats = {
		value = 0,
		recoil = -9,
		concealment = 3
	}

	self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_folded = {
		stats = {
			value = 0,
			recoil = 3,
			concealment = -1
		}
	}
	self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_adjusted = {stats = deep_clone(nostats)}
	self.wpn_fps_smg_x_mp5.override.wpn_fps_smg_mp5_s_nostock = {stats = deep_clone(nostats)}
end

if BeardLib.Utils:ModLoaded("amt") then
	self.parts.wpn_fps_upg_amt_visionking.stats = {
		value = 0,
		zoom = 7,
		concealment = -3
	}
	self.parts.wpn_fps_pis_amt_g_smooth.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_amt_g_rosewood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_amt_b_long.stats = deep_clone(barrel_m2)
	self.parts.wpn_fps_pis_amt_m_short.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_amt_m_short.stats.extra_ammo = 4
end

if BeardLib.Utils:ModLoaded("Vanilla Styled Weapon Mods") and self.parts.wpn_fps_pis_lebman_body_classic then
	self.parts.wpn_fps_ass_flint_b_short.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_flint_b_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_ass_flint_m_long.stats = deep_clone(mag_133)
	self.parts.wpn_fps_ass_flint_m_long.stats.extra_ammo = 10
	self.parts.wpn_fps_ass_flint_g_custom.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_flint_s_solid.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_contraband_b_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_ass_contraband_s_tecci.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}

	-- the barrel just floats lmao
	self.parts.wpn_fps_smg_shepheard_body_long.stats = deep_clone(barrel_m2)
	if not table.contains(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_body_long") then
		table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_body_long")
		table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_smg_shepheard_fg_long")
	end

	self.parts.wpn_fps_ass_komodo_b_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_lmg_shuno_b_long.custom_stats = {spin_up_time_mult = 0.60/0.40}
	self.parts.wpn_fps_lmg_shuno_b_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_pis_lemming_b_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_pis_lemming_body_silver.stats = deep_clone(nostats)

	self.parts.wpn_fps_snp_siltstone_b_short.stats = deep_clone(barrel_p2)

	self.parts.wpn_fps_pis_breech_g_stealth.stats = deep_clone(nostats)

	self.parts.wpn_fps_snp_winchester_b_short.stats = deep_clone(barrel_p2)

	self.parts.wpn_fps_pis_c96_b_short.stats = deep_clone(barrel_p1)

	self.parts.wpn_fps_pis_packrat_sl_silver.stats = deep_clone(nostats)

	self.parts.wpn_fps_smg_cobray_m_extended.stats = deep_clone(mag_125)
	self.parts.wpn_fps_smg_cobray_m_extended.stats.extra_ammo = 8
	self.parts.wpn_fps_smg_cobray_m_extended_akimbo.stats = deep_clone(mag_125)
	self.parts.wpn_fps_smg_cobray_m_extended_akimbo.stats.extra_ammo = 16

	self.parts.wpn_fps_ass_scar_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_ass_scar_m_extended.stats.extra_ammo = 10

	self.parts.wpn_fps_snp_tti_b_long.stats = deep_clone(barrel_m1)

	self.parts.wpn_fps_ass_corgi_b_medium.stats = deep_clone(barrel_p1)

	self.parts.wpn_fps_pis_g18c_b_long.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_tecci_s_minicontra.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_tecci_vg_ergo.stats = deep_clone(nostats)

	self.parts.wpn_fps_shot_shorty_fg_rail.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_ak_m_proto.stats = deep_clone(nostats)

	self.parts.wpn_fps_shot_m37_o_expert.stats = deep_clone(nostats)
	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_o_expert")
	self.parts.wpn_fps_shot_m37_o_expert.stance_mod.wpn_fps_shot_m37primary = deep_clone(self.parts.wpn_fps_shot_m37_o_expert.stance_mod.wpn_fps_shot_m37)

	self.parts.wpn_fps_sho_b_spas12_small.stats = deep_clone(barrelsho_p2)
	self.parts.wpn_fps_smg_uzi_b_carbine.stats = deep_clone(barrel_m2)
	self.parts.wpn_fps_pis_g17_b_bling.stats = deep_clone(nostats)

	-- Reinbeck foregrip/pumps
	self.parts.wpn_fps_shot_beck_pump_custom.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_beck_pump_swat.stats = { value = 1, concealment = -1 }

	-- SGS parts
	-- Sniper stock
	self.parts.wpn_fps_snp_sgs_s_sniper.stats = deep_clone(nostats)
	-- Marksman grip
	self.parts.wpn_fps_snp_sgs_g_black.stats = deep_clone(nostats)
	-- Scout Foregrip
	self.parts.wpn_fps_snp_sgs_fg_rail.stats = deep_clone(nostats)
	-- Extended Barrel
	self.parts.wpn_fps_snp_sgs_b_long.stats = deep_clone(barrel_m1)
	-- Silenced Barrel
	self.parts.wpn_fps_snp_sgs_b_sil.stats = deep_clone(silstatssnp)

	-- ACAR-9 parts
	-- Extended mags
	self.parts.wpn_fps_smg_car9_m_extended.stats.extra_ammo = 5
	self.parts.wpn_fps_smg_car9_m_extended_akimbo.stats.extra_ammo = 10 -- Isn't this what overrides are for?
	-- Steel Barrel
	self.parts.wpn_fps_smg_car9_b_long.stats = deep_clone(barrel_m1)
	-- Hush foregrip
	self.parts.wpn_fps_smg_car9_fg_rail.stats = deep_clone(nostats)

	-- Dragon 5.45 parts
	-- Discreet Foregrip
	self.parts.wpn_fps_pis_smolak_fg_polymer.stats = deep_clone(nostats)

	-- Add Ivans Legacy
	table.insert(self.wpn_fps_pis_smolak.uses_parts, "inf_ivan")

	-- Lebman/Crosskill auto parts
	-- Room broom kit
	self.parts.wpn_fps_pis_lebman_body_classic.stats = deep_clone(nostats)
	-- Chrome slides
	self.parts.wpn_fps_pis_lebman_b_chrome.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_lebman_b_chrome_akimbo.stats = deep_clone(nostats)
	-- Giant stock lmao
	self.parts.wpn_fps_pis_lebman_stock.stats = {
		value = 0,
		spread = 5,
		recoil = 2,
		reload = -10,
		concealment = -2
	}
	-- Crosskill classic grip
	self.parts.wpn_fps_pis_1911_g_classic.stats = deep_clone(nostats)
	-- Wooden grip
	self.parts.wpn_fps_pis_cold_g_wood.stats = deep_clone(nostats)
	-- Crosskill classic sneaky frame
	self.parts.wpn_fps_pis_cold_body_custom.stats = deep_clone(nostats)
	-- Crosskill classic extended mag
	self.parts.wpn_fps_pis_cold_m_extended.stats = {
		extra_ammo = 5,
		concealment = -2
	}
	self.parts.wpn_fps_pis_x_cold_m_extended.stats = {
		extra_ammo = 10,
		concealment = -2
	}

	-- AMR-12 parts
	-- Enforcer foregrip
	self.parts.wpn_fps_shot_amr12_fg_railed.stats = deep_clone(nostats)
	-- Breacher Foregrip
	self.parts.wpn_fps_shot_amr12_fg_short.stats = deep_clone(barrelsho_p2)

	-- Reinbeck M1 Parts
	-- Classic Heat Barrel
	self.parts.wpn_fps_shot_beck_b_heat_dummy.stats = deep_clone(nostats)
	-- Trench Sweeper Nozzle
	self.parts.wpn_fps_upg_ns_shot_grinder.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	-- Enforcer stock
	self.parts.wpn_fps_shot_beck_s_tac.stats = deep_clone(nostats)
	-- Ghost stock
	self.parts.wpn_fps_shot_beck_s_wrist.stats = {
		value = 0,
		concealment = 2,
		recoil = -2
	}
	-- Shell rack
	self.parts.wpn_fps_shot_beck_shells.stats = {
		value = 0,
		reload = 5,
		concealment = -1
	}

	-- Valkyrie Stock
	self.parts.wpn_fps_ass_m16_s_op.stats = deep_clone(nostats)
	-- Ratnik Stock
	self.parts.wpn_fps_ass_m4_s_russian.stats = deep_clone(nostats)
	-- Sport Grip
	self.parts.wpn_fps_ass_m4_g_fancy.stats = deep_clone(nostats)
	-- Schafer Grip
	self.parts.wpn_fps_ass_m4_g_sg.stats = deep_clone(nostats)
	-- Heavy Compensator
	self.parts.wpn_fps_upg_ns_ass_smg_heavy.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
	-- Grievky Nozzle
	self.parts.wpn_fps_upg_ns_ass_smg_russian.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats)
	-- Fugitive Foregrip
	self.parts.wpn_fps_ass_amcar_fg_covers_base.stats = deep_clone(nostats)
	-- Cylinder Foregrip
	self.parts.wpn_fps_ass_amcar_fg_cylinder.stats = deep_clone(nostats)
	-- HeistEye Gadget
	self.parts.wpn_fps_upg_fl_ass_smg_sho_marker.stats = { concealment = -1 }
	-- AK titanium grip
	self.parts.wpn_upg_ak_g_titanium.stats = deep_clone(nostats)
	-- AK Speedpull Mag
	self.parts.wpn_fps_pis_smolak_m_custom.stats = deep_clone(nostats)
	-- Smooth AK Cover
	self.parts.wpn_fps_sho_saiga_upper_receiver_smooth.stats = deep_clone(nostats)
	-- Low profile pistol compensator
	self.parts.wpn_fps_upg_pis_ns_edge.stats = {
		value = 0,
		spread = 2,
		recoil = 1,
		concealment = -1
	}
	-- HS covert frame
	self.parts.wpn_fps_pis_hs2000_body_stealth.stats = deep_clone(nostats)

	-- Theia micro sight
	self.parts.wpn_fps_upg_o_cqb.stats = {
		value = 0,
		concealment = -1
	}

	-- Continental Mag
	self.parts.wpn_fps_ass_m4_m_wick.stats = deep_clone(mag_66)
	self.parts.wpn_fps_ass_m4_m_wick.stats.extra_ammo = -10

	-- M308 classic body
	self.parts.wpn_fps_ass_m14_body_old.stats = deep_clone(nostats)
end

-- Vanilla styled modpack 2
if BeardLib.Utils:ModLoaded("Vanilla Styled Weapon Mods Volume 2") and self.parts.wpn_fps_shot_minibeck_shells then
	self.parts.wpn_fps_shot_minibeck_shells.stats = {
		value = 0,
		reload = 5,
		concealment = -1
	}
	self.parts.wpn_fps_upg_ns_ass_smg_pro.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_ns_ass_smg_pro.custom_stats = silencercustomstats

	-- M60 long barrel
	self.parts.wpn_fps_lmg_m60_b_longer.stats = deep_clone(barrel_m1)
end

if BeardLib.Utils:ModLoaded("Zenith 10mm") then
	self.parts.wpn_fps_upg_zenith_ammo_ap.custom_stats = {sdesc1 = "caliber_p10hr", pen_shield_dmg_mult = 0.20/0.25, ammo_pickup_min_mul = 0.50, ammo_pickup_max_mul = 0.50, can_shoot_through_shield = true, can_shoot_through_wall = true}
	self.parts.wpn_fps_upg_zenith_ammo_ap.internal_part = true
	self.parts.wpn_fps_upg_zenith_ammo_ap.stats = {
		value = 0,
		total_ammo_mod = -500,
		concealment = 0
	}
	self.parts.wpn_fps_upg_zenith_mag_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_zenith_mag_ext.stats.extra_ammo = 4
	self.parts.wpn_fps_upg_zenith_supp.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_zenith_compact_laser.desc_id = "bm_wp_wpn_fps_upg_zenith_compact_laser_desc"
end

if BeardLib.Utils:ModLoaded("Widowmaker TX") then
	self.parts.wpn_fps_shot_wmtx_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_wmtx_ammo_minishell.custom_stats = {sdesc1 = "caliber_s12dx", rays = 6, ammo_pickup_min_mul = 1.50, ammo_pickup_max_mul = 1.50}
	self.parts.wpn_fps_upg_wmtx_ammo_minishell.stats = {
		value = 0,
		extra_ammo = 4,
		total_ammo_mod = 500,
		damage = -10,
		recoil = 15,
		concealment = 0
	}

	self.parts.wpn_fps_upg_wmtx_gastube_burst.custom_stats = {has_burst_fire = true, burst_size = 2}
	self.parts.wpn_fps_upg_wmtx_gastube_burst.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_wmtx_heatshield.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_wmtx_ns_firebull.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("DP12 Shotgun") then
	self.parts.wpn_fps_sho_dp12_o_standard.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -0.3)}}
	self.parts.wpn_fps_sho_dp12_ns_breacher.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)

	self.parts.wpn_fps_sho_dp12_fg_novg.custom_stats = {set_reload_stance_mod = {ads = {translation = Vector3(15, -20, 0), rotation = Rotation(0, 0, 0)}}}
	self.parts.wpn_fps_sho_dp12_fg_novg.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -1.4)}}
	self.parts.wpn_fps_sho_dp12_fg_novg.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_sho_dp12_fg_novg_rail.custom_stats = {set_reload_stance_mod = {ads = {translation = Vector3(15, -20, 0), rotation = Rotation(0, 0, 0)}}}
	self.parts.wpn_fps_sho_dp12_fg_novg_rail.stance_mod = {wpn_fps_sho_dp12 = {translation = Vector3(0, 0, -1.4)}}
	self.parts.wpn_fps_sho_dp12_fg_novg_rail.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_sho_dp12_m_ext.stats = {
		value = 0,
		extra_ammo = 2,
		concealment = -1
	}
	self.parts.wpn_fps_sho_dp12_b_ext.stats = deep_clone(barrelsho_m1)

DelayedCalls:Add("dp12delay", delay, function(self, params)
	-- clear double-firing overrides, the barrels can be fired separately now
	tweak_data.weapon.factory.wpn_fps_sho_dp12.override = {}
end)
end

if BeardLib.Utils:ModLoaded("ELCAN SpecterDR with Docter Sight") then
	self.parts.wpn_fps_upg_o_su230_docter.customsight = true
	self.parts.wpn_fps_upg_o_su230_docter.stats = {
		value = 0,
		zoom = 5,
		concealment = -3
	}
	--self.parts.wpn_fps_upg_o_su230_docter_switch.type = "gadget" -- game needs this so it doesn't apply the second sight's data to the ADS by default
	self.parts.wpn_fps_upg_o_su230_docter_switch.stats = {
		value = 0,
		gadget_zoom = 1,
		concealment = 0,
	}

	-- is this hair loss
DelayedCalls:Add("specdoc_grayingmyhair", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_upg_o_su230_docter.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -12, -1.3)}
	tweak_data.weapon.factory.parts.wpn_fps_upg_o_su230_docter_switch.stance_mod.wpn_fps_ass_mk18s = {translation = Vector3(0, -18, -5.3)}
end)
end

if BeardLib.Utils:ModLoaded("gsup") then
	-- pistol sils
	self.parts.wpn_fps_ass_ns_g_sup1.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup1.stats = deep_clone(silstatsconc2) --3

	self.parts.wpn_fps_ass_ns_g_sup2.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup2.stats = deep_clone(silstatsconc1)

	-- rifle sils
	self.parts.wpn_fps_ass_ns_g_sup3.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup3.stats = deep_clone(silstatsconc2)

	self.parts.wpn_fps_ass_ns_g_sup4.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup4.stats = deep_clone(silstatsconc2)

	self.parts.wpn_fps_ass_ns_g_sup5.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup5.stats = deep_clone(silstatsconc1) --

	-- pistol sil
	self.parts.wpn_fps_ass_ns_g_sup6.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup6.stats = deep_clone(silstatsconc2) --

	-- model 70
	self.parts.wpn_fps_ass_ns_g_sup7.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup7.stats = deep_clone(silstatssnp)

	-- pistol sil
	self.parts.wpn_fps_ass_ns_g_sup8.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ns_g_sup8.stats = deep_clone(silstatsconc2) --

	table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup3")
	table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup4")
	table.insert(primarysmgadds, "wpn_fps_ass_ns_g_sup5")
end

if BeardLib.Utils:ModLoaded("Lost Gadgets Pack") then
	self.parts.wpn_fps_upg_fl_anpeq2.desc_id = "bm_wp_wpn_fps_upg_fl_anpeq2_desc"
	self.parts.wpn_fps_upg_fl_anpeq2.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_fl_dbal_d2.desc_id = "bm_wp_wpn_fps_upg_fl_dbal_d2_desc"
	self.parts.wpn_fps_upg_fl_dbal_d2.stats = {
		value = 0,
		concealment = -2
	}
	self.parts.wpn_fps_upg_fl_m600p.desc_id = "bm_wp_wpn_fps_upg_fl_m600p_desc"
	self.parts.wpn_fps_upg_fl_m600p.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_fl_utg.desc_id = "bm_wp_wpn_fps_upg_fl_utg_desc"
	self.parts.wpn_fps_upg_fl_utg.stats = {
		value = 0,
		concealment = 0
	}

	self.parts.wpn_fps_upg_fl_unimax.desc_id = "bm_wp_wpn_fps_upg_fl_unimax_desc"
	self.parts.wpn_fps_upg_fl_unimax.stats = {
		value = 0,
		concealment = 0
	}
	-- every one of these part names just blends into the next and on top of that they recycle existing descriptions
	self.parts.wpn_fps_upg_fl_pis_inforce_apl.desc_id = "bm_wp_wpn_fps_upg_fl_pis_inforce_apl_desc"
	self.parts.wpn_fps_upg_fl_pis_inforce_apl.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_fl_pis_unimax.desc_id = "bm_wp_wpn_fps_upg_fl_pis_unimax_desc"
	self.parts.wpn_fps_upg_fl_pis_unimax.stats = {
		value = 0,
		concealment = 0
	}
	self.parts.wpn_fps_upg_fl_pis_utg.desc_id = "bm_wp_wpn_fps_upg_fl_utg_desc"
	self.parts.wpn_fps_upg_fl_pis_utg.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_fl_unimax_inforce.desc_id = "bm_wp_wpn_fps_upg_fl_unimax_inforce_desc"
	self.parts.wpn_fps_upg_fl_unimax_inforce.stats = {
		value = 0,
		concealment = -1
	}
end

if BeardLib.Utils:ModLoaded("Heavy Metal Muzzle Device Pack") then
	self.parts.wpn_fps_upg_ns_ass_mb556k.stats = deep_clone(self.parts.wpn_fps_upg_ass_ns_surefire.stats)
	self.parts.wpn_fps_upg_ns_ass_tbrake.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
	self.parts.wpn_fps_upg_ns_ass_vortex.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
	table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_mb556k")
	table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_tbrake")
	table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_vortex")

	self.parts.wpn_fps_upg_ns_pis_aek919.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats)
	self.parts.wpn_fps_upg_ns_pis_tact_flash.stats = deep_clone(self.parts.wpn_fps_upg_pis_ns_flash.stats)
	self.parts.wpn_fps_upg_ns_pis_yhm.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats)
	self.parts.wpn_fps_upg_ns_pis_major.stats = deep_clone(self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats)

	self.parts.wpn_fps_upg_ns_shot_gk_01.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_ns_shot_nomad.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
end

if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - AK") then
	self.parts.wpn_fps_upg_fg_ak_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g_ak_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_s_ak_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak_m_pmag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak556_m_pmag.stats = deep_clone(nostats)

	primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_g_ak_moe")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_s_ak_moe")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_upg_ak_m_pmag")
end

if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - M4") then
	self.parts.wpn_fps_upg_fg_moe2.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_g_m4_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_s_m4_sl_c.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.wpn_fps_smg_mac10.override.wpn_fps_upg_s_m4_sl_c = {stats = deep_clone(nostats)}
	self.parts.wpn_fps_upg_m4_m_pmag40.stats = deep_clone(mag_125)
	self.parts.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 10
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40 = {
		stats = deep_clone(mag_200)
	}
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 20
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag40 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats)
	}
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo * 2
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40 = {}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag40.stats)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag40.stats.extra_ammo = 20
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag40 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag40)

	primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_g_m4_moe")
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_sl_c")
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag40")
	primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_sl_c")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag40")

	-- add VAL grip or you'll be holding onto air
--[[
	self.wpn_fps_ass_asval.override = self.wpn_fps_ass_asval.override or {}
	self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_pts = {adds = {"wpn_fps_ass_asval_g_standard"}}
	self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_sl = {adds = {"wpn_fps_ass_asval_g_standard"}}
	self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_sl_c = {adds = {"wpn_fps_ass_asval_g_standard"}}
	self.wpn_fps_ass_asval.override.wpn_fps_upg_s_m4_pts_c = {adds = {"wpn_fps_ass_asval_g_standard"}}
--]]
end

if BeardLib.Utils:ModLoaded("Magpul Attachments Pack - Universal") then
	self.parts.wpn_fps_upg_fg_moe2_short.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_s_m4_ubr.stats = deep_clone(nostats)
	primarysmgadds_specific.wpn_fps_smg_olympicprimary = primarysmgadds_specific.wpn_fps_smg_olympicprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_ubr")
	--
	self.parts.wpn_fps_upg_s_m4_prs.stats = {
		value = 0,
		spread = 5,
		recoil = 5,
		reload = -10,
		concealment = -2
	}
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_prs")
	--
	self.parts.wpn_fps_upg_s_m4_pts.stats = deep_clone(nostats)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_pts")
	primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts")
	--
	self.parts.wpn_fps_upg_s_m4_sl.stats = deep_clone(nostats)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_sl")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_sl")
	self.parts.wpn_fps_upg_s_m4_pts_c.stats = { 
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.wpn_fps_smg_mac10.override.wpn_fps_upg_s_m4_sl_c = {stats = deep_clone(nostats)}
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_s_m4_pts_c")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_s_m4_pts_c")
	--
	self.parts.wpn_fps_upg_m4_m_pmagsolid.stats = deep_clone(nostats)
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmagsolid = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmagsolid = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmagsolid = {
		stats = deep_clone(self.parts.wpn_fps_m4_uupg_m_std.stats)
	}
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmagsolid = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmagsolid.stats)
	}
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmagsolid = deep_clone(self.wpn_fps_smg_x_olympic.override.wpn_fps_m4_uupg_m_std)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmagsolid")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmagsolid")
	--
	self.parts.wpn_fps_upg_m4_m_pmag10.stats = deep_clone(mag_33)
	self.parts.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = 8

	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10 = {
		stats = deep_clone(mag_50)
	}
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -10
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag10 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats)
	}
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag10 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10.stats)
	}
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -20
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag10 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag10 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag10)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmagsolid")
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag10")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmagsolid")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag10")
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10 = {}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag10.stats)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag10.stats.extra_ammo = -40
	--
	self.parts.wpn_fps_upg_m4_m_pmag20.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
		stats = deep_clone(nostats)
	}
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag20 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
	}
	self.wpn_fps_smg_x_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
	}
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20 = {}
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_pmag20.stats)
	self.wpn_fps_smg_x_hajk.override.wpn_fps_upg_m4_m_pmag20.stats.extra_ammo = -20
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag20")
	--
--[[
	self.parts.wpn_fps_upg_m4_m_pmag3.stats = deep_clone(nostats)
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3 = {
		stats = self.parts.wpn_fps_m4_uupg_m_std.stats
	}
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag3 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3.stats)
	}
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag3 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag3 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag3)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag3")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag3")
--]]
	--
	self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20 = {
		stats = deep_clone(nostats)
	}
	self.wpn_fps_smg_olympicprimary.override.wpn_fps_upg_m4_m_pmag20 = {
		stats = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20.stats)
	}
	self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
	self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag20 = deep_clone(self.wpn_fps_smg_olympic.override.wpn_fps_upg_m4_m_pmag20)
	table.insert(primarysmgadds_specific.wpn_fps_smg_olympicprimary, "wpn_fps_upg_m4_m_pmag20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_m4_m_pmag20")
end

if BeardLib.Utils:ModLoaded("Lahti L-35") then
	self.parts.wpn_fps_upg_l35_barrel_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_upg_l35_grip_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_l35_grip_wood_window.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_l35_mag_drum.stats = deep_clone(mag_300)
	self.parts.wpn_fps_upg_l35_mag_drum.stats.extra_ammo = 24
	self.parts.wpn_fps_upg_l35_mag_drum.stats.spread = -20

	self.parts.wpn_fps_upg_l35_mag_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_l35_mag_ext.stats.extra_ammo = 4

	self.parts.wpn_fps_upg_l35_mag_long.stats = deep_clone(mag_200)
	self.parts.wpn_fps_upg_l35_mag_long.stats.extra_ammo = 8
end

if BeardLib.Utils:ModLoaded("OTs-14-4A Groza") then
	self.parts.wpn_fps_ass_ots_14_4a_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ots_14_4a_supp.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats.spread = 0
	self.parts.wpn_fps_upg_ots_14_4a_supp_b.stats.concealment = -1

	table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_762")
	table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_545")
	table.insert(self.wpn_fps_ass_ots_14_4a.uses_parts, "inf_groza_556")
	self.parts.inf_groza_762.unit = self.parts.wpn_upg_ak_m_akm.unit
	self.parts.inf_groza_762.third_unit = self.parts.wpn_upg_ak_m_akm.third_unit
	self.parts.inf_groza_762.custom_stats = {sdesc1 = "caliber_r762x39"}
	self.parts.inf_groza_762.stats = deep_clone(mag_150)
	self.parts.inf_groza_762.stats.extra_ammo = 10

	self.parts.inf_groza_545.unit = self.parts.wpn_fps_ass_74_m_standard.unit
	self.parts.inf_groza_545.third_unit = self.parts.wpn_fps_ass_74_m_standard.third_unit
	self:convert_part("inf_groza_545", "mrifle", "lrifle")
	self.parts.inf_groza_545.custom_stats.sdesc1 = "caliber_r545x39"
	self.parts.inf_groza_545.stats.extra_ammo = 10
	self.parts.inf_groza_545.stats.reload = mag_150.reload
	self.parts.inf_groza_545.stats.concealment = mag_150.concealment

	self.parts.inf_groza_556.unit = self.parts.wpn_fps_m4_uupg_m_std_vanilla.unit
	self.parts.inf_groza_556.third_unit = self.parts.wpn_fps_m4_uupg_m_std_vanilla.third_unit
	self:convert_part("inf_groza_556", "mrifle", "lrifle")
	self.parts.inf_groza_556.custom_stats.sdesc1 = "caliber_r556x45"
	self.parts.inf_groza_556.stats.extra_ammo = 10
	self.parts.inf_groza_556.stats.reload = mag_150.reload
	self.parts.inf_groza_556.stats.concealment = mag_150.concealment
end

if BeardLib.Utils:ModLoaded("M16A1 Wooden Furniture") then
	self.parts.wpn_fps_ass_m16_fg_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m16_s_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m16_g_wood.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("MK18 Specialist") then
	self.parts.wpn_fps_ass_mk18s_fg_black.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_grip_black.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_tacstock.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_vg_ptk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_carry.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_mag_speed.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_mk18s_mag_big.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_quad.stats)
	self.parts.wpn_fps_ass_mk18s_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)

	self.parts.wpn_fps_ass_mk18s_a_weak.custom_stats = {sdesc1 = "caliber_r556x45m193"}
	self.parts.wpn_fps_ass_mk18s_a_weak.stats = deep_clone(nostats)

	self:convert_part("wpn_fps_ass_mk18s_a_classic", "lrifle", "mrifle")
	self.parts.wpn_fps_ass_mk18s_a_classic.custom_stats.sdesc1 = "caliber_r556x45mk262"

	self:convert_part("wpn_fps_ass_mk18s_a_strong", "lrifle", "mrifle")
	self.parts.wpn_fps_ass_mk18s_a_strong.custom_stats.sdesc1 = "caliber_r556x45m855"

	self:convert_part("wpn_fps_ass_mk18s_a_dmr", "lrifle", "hrifle")
	self.parts.wpn_fps_ass_mk18s_a_dmr.custom_stats.sdesc1 = "caliber_r556x45mk318"

	table.insert(self.wpn_fps_ass_mk18s.uses_parts, "inf_mk18_nomagwelldevice")
end

if BeardLib.Utils:ModLoaded("Lewis Gun") then
	self.parts.wpn_fps_upg_lewis_bolt_aa.stats = {
		value = 0,
		spread = -5,
		concealment = 0
	}
	--self.wpn_fps_lmg_lewis.override.inf_bipod_part = {a_obj = "a_b"}
	self.parts.wpn_fps_upg_lewis_bipod.custom_stats = {recoil_horizontal_mult = 2}
--[[
	self.parts.wpn_fps_upg_lewis_bipod.animations = nil -- don't have improvedbipods crash the game thx
	self.parts.wpn_fps_upg_lewis_bipod.perks = nil
	-- 
	self.parts.wpn_fps_upg_lewis_bipod.adds = {"inf_bipod_part"}
--]]
	self.parts.wpn_fps_upg_lewis_handle.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_lewis_sight_zf12.stats = deep_clone(self.parts.wpn_fps_upg_o_specter.stats)
	self.parts.wpn_fps_upg_lewis_stock_aa.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
end

if BeardLib.Utils:ModLoaded("HK416") then
	self.parts.wpn_fps_ass_hk416_bolt.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_hk416_grip_magpul_miad.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_hk416_grip_magpul_moe.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_hk416_grip_vindicator.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hk416_mag_pull_assist.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hk416_sights_frontfold.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hk416_barrel_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_upg_hk416_handguard_long.stats = {
		value = 0,
		spread = 5,
		concealment = -1
	}
	self.parts.wpn_fps_upg_hk416_barrel_short.stats = {
		value = 0,
		spread = -5,
		concealment = 1
	}
	self.parts.wpn_fps_upg_hk416_handguard_c.stats = {
		value = 0,
		spread = -5,
		concealment = 1
	}
	self.parts.wpn_fps_upg_hk416_stock_hk416c.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
	self.parts.wpn_fps_upg_hk416_stock_hk416c_collapsed.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}

	-- New handguards
	self.parts.wpn_fps_upg_hk416_handguard_elite.stats = {
		value = 0,
		recoil = -1,
		concealment = 1
	}
	self.parts.wpn_fps_upg_hk416_handguard_hera_irs.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hk416_handguard_smr.stats = {
		value = 0,
		spread = 1,
		concealment = -1
	}
	self.parts.wpn_fps_upg_hk416_handguard_smrlong.stats = {
		value = 0,
		spread = 2,
		concealment = -2
	}
	self.parts.wpn_fps_upg_hk416_handguard_troyalpha.stats = {
		recoil = 1,
		concealment = -1
	}

	-- New stocks
	self.parts.wpn_fps_upg_hk416_stock_e1.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_hk416_stock_slimline.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("HK416C Standalone") then
	self.parts.wpn_fps_upg_drongo_s_orig.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_drongo_s_compact.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
	self.parts.wpn_fps_ass_drongo_lower.stance_mod = {
		wpn_fps_ass_drongo = {translation = Vector3(-0.07, -7, -1.17)}
	}
--[[
	table.insert(customsightaddlist, {"wpn_fps_ass_drongo", "wpn_fps_ass_tecci", true})
	self.parts.wpn_fps_ass_drongo_lower.stance_mod = {
		wpn_fps_ass_drongo = {translation = Vector3(-0.07, -7, -1.17)}
	}
	for a, sight in pairs(sightlist) do
		self.wpn_fps_ass_drongo.adds[sight] = {"inf_invis_stance"}
	end
--]]

	-- taking the nuclear option
	Hooks:RemovePostHook("drongo_boneless_Init")
	self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_aimpoint.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_aimpoint_2.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_docter.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_eotech.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_t1micro.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_cmore.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_cs.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_eotech_xps.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_reflex.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_rx01.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_rx30.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_45rds.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_spot.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.drongo = deep_clone(self.parts.wpn_fps_upg_o_xpsg33_magnifier.stance_mod.wpn_fps_ass_m4)
	self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_ass_drongo = deep_clone(self.parts.wpn_fps_upg_o_45rds_v2.stance_mod.wpn_fps_ass_m4)
end

if BeardLib.Utils:ModLoaded("HK417 Standalone") then
	self.parts.wpn_fps_upg_recce_s_orig.stats = deep_clone(nostats)

	table.insert(self.wpn_fps_ass_recce.uses_parts, "inf_hk417_dmr")
	self:convert_part("inf_hk417_dmr", "hrifle", "ldmr", nil, nil, 600, nil)
	self.parts.inf_hk417_dmr.custom_stats.sdesc1 = "caliber_r762x51dm151"
	self.parts.inf_hk417_dmr.perks = {"fire_mode_single"}
	self.parts.inf_hk417_dmr.stats.reload = -20
end

if BeardLib.Utils:ModLoaded("acwr") then
	self.parts.wpn_fps_ass_acwr_expert.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_acwr_mag_pmag.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_acwr_covers.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_acwr_mag_smol.stats = deep_clone(self.parts.wpn_fps_upg_m4_m_straight.stats)
	self.parts.wpn_fps_ass_acwr_b_short.stats = deep_clone(barrel_p2)

	self.parts.wpn_fps_ass_acwr_gl_fire.custom_stats = {sdesc3 = "misc_gl40x46mmIC"}
end

if BeardLib.Utils:ModLoaded("SAI GRY") then
	self.parts.wpn_fps_upg_saigry_mag_pmag.stats = deep_clone(mag_75)
	self.parts.wpn_fps_upg_saigry_mag_pmag.stats.extra_ammo = -10
	self.parts.wpn_fps_upg_saigry_mag_stanag.stats = deep_clone(self.parts.wpn_fps_upg_saigry_mag_pmag.stats)
	self.parts.wpn_fps_upg_saigry_stock_folded.stats = deep_clone(self.parts.wpn_fps_m4_uupg_s_fold.stats)
	self.parts.wpn_fps_upg_saigry_jailbrake.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	self:convert_part("wpn_fps_upg_saigry_a_556", "mrifle", "lrifle")
	self.parts.wpn_fps_upg_saigry_a_556.custom_stats.sdesc1 = "caliber_r556x45"
end

if BeardLib.Utils:ModLoaded("Owen Gun") then
	self.parts.wpn_fps_smg_owen_b_43.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_owen_s_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_owen_sling.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_owen_low_window.stats = deep_clone(nostats)

	self.parts.wpn_fps_smg_owen_m_double.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_smg_owen_m_double.stats = {
		value = 0,
		reload = -20,
		concealment = -2
	}
	self.parts.wpn_fps_smg_owen_s_no.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_smg_owen_s_wood.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
end

if BeardLib.Utils:ModLoaded("PP-19-01 Vityaz") then
	self.parts.wpn_fps_smg_vityaz_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_grip_ak.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_grip_molot.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_grip_rk3.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_grip_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_handguard_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_handguard_arsenal.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_handguard_chaos.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_handguard_terminator.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_handguard_zenit.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_stock_molot.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vityaz_stock_zenit.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_vityaz_stock.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_vityaz_stock.pcs = nil

	self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.internal_part = true
	self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.custom_stats = {sdesc1 = "caliber_p10", armor_piercing_add = 0.13}
	self.parts.wpn_fps_upg_vityaz_ammo_9mm_p.stats = {
		value = 0,
		damage = 10,
		recoil = -10,
		concealment = 0
	}
	self.parts.wpn_fps_upg_vityaz_barrel_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_upg_vityaz_bolt_lightweight.forbids = {"wpn_fps_upg_i_autofire"}
	self.parts.wpn_fps_upg_vityaz_bolt_lightweight.custom_stats = deep_clone(self.parts.wpn_fps_upg_i_autofire.custom_stats)
	self.parts.wpn_fps_upg_vityaz_bolt_lightweight.stats = deep_clone(self.parts.wpn_fps_upg_i_autofire.stats)

	self.parts.wpn_fps_upg_vityaz_supp.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_vityaz_supp.stats = deep_clone(silstatsconc2)

	self.parts.wpn_fps_upg_vityaz_mag_dual.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_upg_vityaz_mag_dual.stats = {
		value = 0,
		reload = -20,
		concealment = -2
	}
	self.parts.wpn_fps_upg_vityaz_stock_akm.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
end

if BeardLib.Utils:ModLoaded("Tactical Operator Attachments") then
	self.parts.wpn_fps_upg_s_devgru.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_fg_ropup.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_fg_daniel.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_fg_deadline.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_fg_patrick.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scar_s_collapsed.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_wellgrip.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_ns_dragon.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
	self.parts.wpn_fps_upg_ns_hock.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_hock.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_ns_osprey.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ns_osprey.stats = deep_clone(silstatsconc2)

	table.insert(primarysmgadds, "wpn_fps_upg_ns_dragon")
	table.insert(primarysmgadds, "wpn_fps_upg_ns_hock")
	table.insert(primarysmgadds, "wpn_fps_upg_ns_osprey")

	self.parts.wpn_fps_upg_tecci_am_beefy.custom_stats = {sdesc1 = "caliber_r556x45m193"}
	self.parts.wpn_fps_upg_tecci_am_beefy.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_mp9_s_no.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_upg_sub2000_m_short.custom_stats = {}
	self.parts.wpn_fps_upg_sub2000_m_short.stats = deep_clone(mag_50)
	self.parts.wpn_fps_upg_sub2000_m_short.stats.extra_ammo = -16

	self:convert_part("wpn_fps_upg_ching_am_crap", "dmr", "ldmr", 56, InFmenu.wpnvalues.ldmr.ammo + 8)
	self.parts.wpn_fps_upg_ching_am_crap.custom_stats.sdesc1 = "caliber_r3006surplus"
	self.parts.wpn_fps_upg_ching_am_crap.stats.threat = 0
	self.parts.wpn_fps_upg_ching_am_crap.stats.reload = 25

	-- wat do
	self.parts.wpn_fps_upg_am_hollow_small.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_am_hollow_small.pcs = nil
	self.parts.wpn_fps_upg_am_hollow_large.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_am_hollow_large.pcs = nil
	self.parts.wpn_fps_upg_am_gomerpyle.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_am_gomerpyle.pcs = nil
	self.parts.wpn_fps_upg_am_lame.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_am_lame.pcs = nil

	self.parts.wpn_fps_upg_m14_m_tape.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_mp5_m_ten.stats = deep_clone(self.parts.wpn_fps_smg_mp5_m_straight.stats)
	self:convert_part("wpn_fps_upg_schakal_m_nine", "longsmg", "shortsmg")
	self.parts.wpn_fps_upg_schakal_m_nine.custom_stats.sdesc1 = "caliber_p9x19"
	self.parts.wpn_fps_upg_schakal_m_atai.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_vg_bcm.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vg_cadex.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vg_jowi.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vg_angle.stats = deep_clone(nostats)
	primarysmgadds_specific.wpn_fps_smg_schakalprimary = primarysmgadds_specific.wpn_fps_smg_schakalprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_vg_bcm")
	table.insert(primarysmgadds_specific.wpn_fps_smg_schakalprimary, "wpn_fps_upg_vg_cadex")
	primarysmgadds_specific.wpn_fps_smg_hajkprimary = primarysmgadds_specific.wpn_fps_smg_hajkprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_vg_bcm")
	table.insert(primarysmgadds_specific.wpn_fps_smg_hajkprimary, "wpn_fps_upg_vg_cadex")

	self.parts.wpn_fps_upg_pn_over.custom_stats = {inf_rof_mult = 1.10}
	self.parts.wpn_fps_upg_pn_over.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_pn_under.custom_stats = {inf_rof_mult = 0.90}
	self.parts.wpn_fps_upg_pn_under.stats = deep_clone(nostats)

DelayedCalls:Add("carlsoperatorattachdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_upg_am_gomerpyle.custom_stats = {}
	tweak_data.weapon.factory.parts.wpn_fps_upg_am_hollow_small.custom_stats = {}
	tweak_data.weapon.factory.parts.wpn_fps_upg_am_hollow_large.custom_stats = {headshot_dmg_mult = 1}

	tweak_data.weapon.factory.parts.wpn_fps_upg_m14_m_tape.custom_stats = {}

	tweak_data.weapon.factory.parts.wpn_fps_upg_mp5_m_ten.stats = deep_clone(tweak_data.weapon.factory.parts.wpn_fps_smg_mp5_m_straight.stats)
	tweak_data.weapon.factory:convert_ammo_pickup("wpn_fps_upg_schakal_m_nine", InFmenu.wpnvalues.longsmg.ammo, InFmenu.wpnvalues.shortsmg.ammo)
	tweak_data.weapon.factory.parts.wpn_fps_upg_schakal_m_atai.custom_stats = {}

	tweak_data.weapon.factory.parts.wpn_fps_upg_tr_match.override_weapon_multiply = nil

	tweak_data.weapon.factory.parts.wpn_fps_upg_pn_over.override_weapon_multiply = {fire_mode_data = {fire_rate = 1}}
	tweak_data.weapon.factory.parts.wpn_fps_upg_pn_under.override_weapon_multiply = {fire_mode_data = {fire_rate = 1}}
end)
end

if BeardLib.Utils:ModLoaded("l1a1") then
	self.parts.wpn_fps_ass_l1a1_grip_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_l1a1_foregrip_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_l1a1_stock_wood.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_l1a1_barrel_long.stats = deep_clone(barrel_m1)
	self.parts.wpn_fps_ass_l1a1_ns_fal.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats)

	self.parts.wpn_fps_ass_l1a1_mag_big.stats = deep_clone(mag_150)
	self.parts.wpn_fps_ass_l1a1_mag_big.stats.extra_ammo = 10
	self.parts.wpn_fps_ass_l1a1_mag_short.stats = deep_clone(mag_50)
	self.parts.wpn_fps_ass_l1a1_mag_short.stats.extra_ammo = -10
end

if BeardLib.Utils:ModLoaded("Mk14") then
	table.insert(gunlist_snp, {"wpn_fps_snp_wargoddess", -3})
	--self.parts.wpn_fps_snp_wargoddess_b_ebr.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_snp_wargoddess_o_dummy.stats = {
		value = 0,
		concealment = 0
	}
	self.parts.wpn_fps_snp_wargoddess_s_mod0_un.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_wargoddess_s_mod0_in.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_snp_wargoddess_supp.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_wargoddess_supp.stats = deep_clone(silstatssnp)
end

if BeardLib.Utils:ModLoaded("sg552") then
	self.parts.wpn_fps_ass_sg552_g_ergo.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_sg552_m_milspec.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_sg552_s_tactical.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_sg552_s_modern.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_sg552_a_dmg.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_sg552_fg_large.stats = {
		value = 0,
		spread = 10,
		recoil = 2,
		reload = -10,
		concealment = -2
	}
	self.parts.wpn_fps_ass_sg552_fg_holo.stats = {
		value = 0,
		spread = 15,
		recoil = 3,
		reload = -15,
		concealment = -3
	}
	self.parts.wpn_fps_ass_sg552_s_folding.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_sg552_s_modern.stats = deep_clone(stock_snp)

	-- fixing attachable sight alignment
	-- custom sights still wrong tho bcuz lmao
	self.parts.wpn_fps_ass_sg552_b_standard.stance_mod = {
		wpn_fps_ass_sg552 = {translation = Vector3(0.12, 0, -0.35)}
	}
	self.parts.wpn_fps_ass_sg552_b_standard.adds = {"wpn_fps_ass_m16_os_frontsight"}
	self.wpn_fps_ass_sg552.override = self.wpn_fps_ass_sg552.override or {}
	self.wpn_fps_ass_sg552.override.wpn_fps_ass_m16_os_frontsight = {
		unit = dummy, third_unit = dummy,
		stance_mod = {
			wpn_fps_ass_sg552 = {translation = Vector3(-0.12, 0, 0.35)}
		}
	}

DelayedCalls:Add("sg552delay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_a_dmg.custom_stats = {sdesc1 = "caliber_r556x45"}

	--tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_o_flipup.stance_mod.wpn_fps_ass_sg552.translation = tweak_data.weapon.factory.parts.wpn_fps_ass_sg552_o_flipup.stance_mod.wpn_fps_ass_sg552.translation + Vector3(0.12, 0, -0.35)
end)
end

if BeardLib.Utils:ModLoaded("Beretta Px4 Storm") and self.parts.wpn_fps_pis_px4_mag then
	self.parts.wpn_fps_pis_px4_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_px4_barrel_sd.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_px4_grip_backstrap_rubber.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_px4_sight_dot.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_px4_sight_tritium.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_px4_ammo_9mm.override = {}
	self.parts.wpn_fps_upg_px4_ammo_9mm.override_weapon_add = {}
	self.parts.wpn_fps_upg_px4_ammo_9mm.override_weapon_multiply = {}
	self:convert_part("wpn_fps_upg_px4_ammo_9mm", "mediumpis", "lightpis")
	self.parts.wpn_fps_upg_px4_ammo_9mm.custom_stats.sdesc1 = "caliber_p9x19"
	self.parts.wpn_fps_upg_px4_ammo_9mm.internal_part = true

	self.parts.wpn_fps_upg_px4_ammo_45acp.override = {}
	self.parts.wpn_fps_upg_px4_ammo_45acp.override_weapon_add = {}
	self.parts.wpn_fps_upg_px4_ammo_45acp.override_weapon_multiply = {}
	self:convert_part("wpn_fps_upg_px4_ammo_45acp", "mediumpis", "supermediumpis")
	self.parts.wpn_fps_upg_px4_ammo_45acp.custom_stats.sdesc1 = "caliber_p45s"
	self.parts.wpn_fps_upg_px4_ammo_45acp.internal_part = true
end

if BeardLib.Utils:ModLoaded("Sword Cutlass Grips") then
	self.parts.wpn_fps_pis_beretta_g_cutlass.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("Walther P99 AS") then
	self:convert_part("wpn_fps_upg_p99_ammo_40sw", "lightpis", "mediumpis", nil, 84)
	self.parts.wpn_fps_upg_p99_ammo_40sw.custom_stats.sdesc1 = "caliber_p40sw"
	self.parts.wpn_fps_upg_p99_ammo_40sw.stats.extra_ammo = -3
	self.parts.wpn_fps_upg_p99_ammo_40sw.stats.reload = 0
	self.parts.wpn_fps_upg_p99_ammo_40sw.internal_part = true

	self.parts.wpn_fps_upg_p99_barrel_threaded.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_p99_sight_ghostring.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_p99_sight_tritium.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_p99_barrel_ported.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_upg_p99_mag_ext.stats = deep_clone(mag_133)
	self.parts.wpn_fps_upg_p99_mag_ext.stats.extra_ammo = 5
	self.parts.wpn_fps_upg_p99_sight_rail.stats = {
		value = 0,
		concealment = -1
	}
end

if BeardLib.Utils:ModLoaded("Leupold DeltaPoint Sight") then
	self.parts.wpn_fps_upg_o_deltapoint.stats = {
		value = 0,
		zoom = 0,
		concealment = 0
	}
end

if BeardLib.Utils:ModLoaded("Tromix Barrel-Ext") then
	self.parts.wpn_fps_upg_ns_ass_smg_tromix.stats = {
		value = 0,
		recoil = 3,
		concealment = -2
	}
	table.insert(primarysmgadds, "wpn_fps_upg_ns_ass_smg_tromix")
end

if BeardLib.Utils:ModLoaded("M45A1 CQBP") then
	self.parts.wpn_fps_pis_m45a1_m_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_m45a1_m_ext.stats.extra_ammo = 3
end

if BeardLib.Utils:ModLoaded("Mossberg 590") then
	self.parts.wpn_fps_shot_m590_ironsight.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_sightrail.stats = deep_clone(nostats)

	self.parts.wpn_fps_shot_m590_s_old.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_heat_shield.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_s_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_fg_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_fg_hdtf.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m590_s_hdtf.stats = deep_clone(nostats)

	self.parts.wpn_fps_shot_m590_b_short.stats = deep_clone(barrelsho_p2)
	self.parts.wpn_fps_shot_m590_b_short.stats.extra_ammo = -1

	self.parts.wpn_fps_shot_m590_b_silencer.custom_stats = shotgunsilencercustomstats
	self.parts.wpn_fps_shot_m590_b_silencer.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_thick.stats)

DelayedCalls:Add("mossberg590delay", delay, function(self, params)
	tweak_data.weapon.factory.wpn_fps_shot_m590.override.wpn_fps_shot_r870_body_rack.stats = nil
end)
end

if BeardLib.Utils:ModLoaded("Vepr-12") then
	self.parts.wpn_fps_upg_vepr12_grip_ak_plastic.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_grip_ak_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_handguard_ak_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_handguard_midwest.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_handguard_terminator.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_stock_ak_plastic.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_stock_ak_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_vepr12_stock_sok.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_vepr12_mag_sgm.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_vepr12_mag_sgm.stats.extra_ammo = 4

	self.parts.wpn_fps_upg_vepr12_barrel_long.stats = deep_clone(barrelsho_m1)
end

if BeardLib.Utils:ModLoaded("M3 Grease Gun") then
	self.parts.wpn_fps_smg_m3_b_suppressor.custom_stats = silencercustomstats
	self.parts.wpn_fps_smg_m3_b_suppressor.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_smg_m3_s_ext.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_smg_m3_s_no.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_smg_m3_b_small.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_smg_m3_sling.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_m3_sling_l.stats = deep_clone(nostats)

	self.parts.wpn_fps_smg_m3_m_short.stats = deep_clone(mag_66)
	self.parts.wpn_fps_smg_m3_m_short.stats.extra_ammo = -10
	self.parts.wpn_fps_smg_m3_m_long.stats = deep_clone(mag_133)
	self.parts.wpn_fps_smg_m3_m_long.stats.extra_ammo = 10
	self.parts.wpn_fps_smg_m3_m_double.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_smg_m3_m_double.stats = {
		value = 0,
		reload = -20,
		concealment = -2
	}

DelayedCalls:Add("greasegundelay", delay, function(self, params)
	tweak_data.weapon.factory:convert_part("wpn_fps_smg_m3_a_9mm", "shortsmg", "longsmg")
	tweak_data.weapon.factory.parts.wpn_fps_smg_m3_a_ovk_9mm.custom_stats = {sdesc1 = "caliber_p9x19nade"}
	tweak_data.weapon.factory.parts.wpn_fps_smg_m3_a_ovk_9mm.stats = deep_clone(nostats)
end)
end

if BeardLib.Utils:ModLoaded("Howa AR") then
	self:convert_part("wpn_fps_ass_howa_t64_body", "lrifle", "hrifle")
	self.parts.wpn_fps_ass_howa_t64_body.custom_stats.sdesc1 = "caliber_r762x51jp"
	self.parts.wpn_fps_ass_howa_t64_body.custom_stats.use_reload_2 = true
	self.parts.wpn_fps_ass_howa_t64_body.stats.reload = 0

	self.parts.wpn_fps_ass_howa_s_wrapped.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_howa_m_supido.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_howa_bayonet.stats = deep_clone(self.parts.wpn_fps_snp_mosin_ns_bayonet.stats)
	self.parts.wpn_fps_ass_howa_b_para.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_howa_s_skeletal.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_howa_m_para.stats = deep_clone(mag_66)
	self.parts.wpn_fps_ass_howa_m_para.stats.extra_ammo = -10
DelayedCalls:Add("howadelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_ass_howa_t64_body.override_weapon_add = {}
	tweak_data.weapon.factory.parts.wpn_fps_ass_howa_t64_body.override.wpn_fps_ass_howa_b_para.stats = {}
end)
end

if BeardLib.Utils:ModLoaded("vp70") then
	self.parts.wpn_fps_pis_vp70_body_early.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_s_scifi.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_stp_standard.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_m_speed_std.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_grip_ergo.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_ac_9x21imi.custom_stats = {sdesc1 = "caliber_p9x21imi"}
	self.parts.wpn_fps_pis_vp70_ac_9x21imi.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_vp70_lc_stormtrooper.stats = deep_clone(nostats)

	self.parts.wpn_fps_pis_vp70_autofire.stats = {
		value = 0,
		spread = -15,
		concealment = 0
	}
	self.parts.wpn_fps_pis_vp70_stock_standard.custom_stats = {has_burst_fire = true, burst_fire_rate_table = {2100/600, 2100/600, 0.33}}
	self.parts.wpn_fps_pis_vp70_stock_standard.stats = {
		value = 0,
		recoil = 8,
		reload = -25,
		concealment = -4
	}
	self:convert_ammo_pickup("wpn_fps_pis_vp70_stock_standard", 144, 108)
	self:convert_total_ammo_mod("wpn_fps_pis_vp70_stock_standard", 144, 108)
	self.parts.wpn_fps_pis_vp70_m_ext.stats = deep_clone(mag_133)
	self.parts.wpn_fps_pis_vp70_m_ext.stats.extra_ammo = 6
end

if BeardLib.Utils:ModLoaded("lapd") then
	self.parts.wpn_fps_pis_lapd_grip_pearl.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_lapd_grip_polymer.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_lapd_grip_cherry.stats = deep_clone(nostats)

	table.insert(self.wpn_fps_pis_lapd.uses_parts, "inf_lapd_556")
	table.insert(self.wpn_fps_pis_x_lapd.uses_parts, "inf_lapd_556")
	self.parts.inf_lapd_556.custom_stats = {sdesc1 = "caliber_r556x45"}
	self.parts.inf_lapd_556.sound_switch = {suppressed = "infalt"}
	self.parts.inf_lapd_556.stats = deep_clone(nostats)

	self.parts.wpn_fps_pis_lapd_b_standard.stance_mod = {
		wpn_fps_pis_lapd = {translation = Vector3(0.2, 0, 0)}
	}
--[[
	self.parts.wpn_fps_pis_lapd_a_bronco.stats = {
		value = 0,
		damage = 195 - InFmenu.wpnvalues.heavypis.damage,
		recoil = -10,
		concealment = 0
	}
	self:convert_total_ammo_mod("wpn_fps_pis_lapd_a_bronco", 35, 30)
DelayedCalls:Add("bladerunnerdelayedcall", delay, function(self, params)
	tweak_data.weapon.factory:convert_ammo_pickup("wpn_fps_pis_lapd_a_bronco", 35, 30)
	tweak_data.weapon.factory.parts.wpn_fps_pis_lapd_a_bronco.custom_stats.sdesc1 = "caliber_r556x45"
end)
--]]
end

if BeardLib.Utils:ModLoaded("Valday 1P87") then
	self.parts.wpn_fps_upg_o_valday1p87.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
	self.parts.wpn_fps_upg_o_valday1p87.customsight = true
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans = {}
	local valdayoffset = -0.8
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_ass_galil_fg_fab = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_ass_galil_fg_mar = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_krebs = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_trax = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_ak_fg_zenit = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_o_ak_scopemount = {translation = Vector3(0, 0, valdayoffset)}
	self.parts.wpn_fps_upg_o_valday1p87.customsighttrans.wpn_fps_upg_o_m14_scopemount = {translation = Vector3(0, 0, valdayoffset)}
end

if BeardLib.Utils:ModLoaded("Remington R5 RGP") then
	self.parts.wpn_fps_upg_mikon_s_viper.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_mikon_am_parp.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_mikon_am_parp.custom_stats = {sdesc1 = "caliber_r556x45m193"}
	self:convert_part("wpn_fps_upg_mikon_am_spc", "lrifle", "mrifle")
	self.parts.wpn_fps_upg_mikon_am_spc.custom_stats.sdesc1 = "caliber_r300blackout"
	self.parts.wpn_fps_upg_mikon_am_spc.stats.extra_ammo = 0
end

if BeardLib.Utils:ModLoaded("Parker-Hale PDW") then
	self.parts.wpn_fps_upg_nya_s_nope.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_upg_nya_cpu_turbo.custom_stats = {burst_fire_rate_multiplier = 800/1400}
	self.parts.wpn_fps_upg_nya_cpu_turbo.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_nya_cpu_slow.custom_stats = {burst_fire_rate_multiplier = 600/1400}
	self.parts.wpn_fps_upg_nya_cpu_slow.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_nya_am_dillon.stats = deep_clone(nostats)

	self.wpn_fps_smg_x_nya.override = self.wpn_fps_smg_x_nya.override or {}
	self.wpn_fps_smg_x_nya.override.wpn_fps_upg_nya_cpu_turbo = {
		custom_stats = {inf_rof_mult = 800/1400},
		desc_id = "inf_xidw_cpu_turbo_desc"
	}
	self.wpn_fps_smg_x_nya.override.wpn_fps_upg_nya_cpu_slow = {
		custom_stats = {inf_rof_mult = 600/1400},
		desc_id = "inf_xidw_cpu_slow_desc"
	}
DelayedCalls:Add("memecatdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_upg_nya_am_dillon.custom_stats = {sdesc1 = "caliber_p9x19idw"}
	tweak_data.weapon.factory.parts.wpn_fps_upg_nya_cpu_slow.override_weapon = nil
	tweak_data.weapon.factory.parts.wpn_fps_upg_nya_cpu_turbo.override_weapon = nil
end)
end

if BeardLib.Utils:ModLoaded("ARX-160 REBORN") then
	table.insert(self.wpn_fps_ass_lazy.uses_parts, "inf_car4_ironsretain")
	self.parts.wpn_fps_upg_lazy_b_long.stats = deep_clone(barrel_m2)
--[[
	self.parts.wpn_fps_upg_lazy_s_fold.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
--]]
	--self.parts.wpn_fps_upg_lazy_am_beefish.stats = 
end

if BeardLib.Utils:ModLoaded("DP28") then
	self.parts.wpn_fps_lmg_dp28_stock_dpm.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_dp28_g_dpm.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_dp28_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_lmg_dp28_bipod.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_dp28_tripod_top.custom_stats = {recoil_horizontal_mult = 2.00, bipod_recoil_vertical_mult = 0.50, bipod_recoil_horizontal_mult = 0.50}
	self.parts.wpn_fps_lmg_dp28_tripod_top.stats = {
		value = 0,
		concealment = -5
	}
	self.parts.wpn_fps_lmg_dp28_barrel_lord.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_lmg_dp28_barrel_dt.stats = deep_clone(nostats)

	self.parts.wpn_fps_lmg_dp28_stock_dt.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_dp28_g_dt.stats = deep_clone(nostats)
	self.parts.wpn_fps_lmg_dp28_barrel_dpm36.stats = deep_clone(nostats)


	self.parts.wpn_fps_lmg_dp28_m_dt.custom_stats = {deploy_ads_stance_mod = {translation = Vector3(0, 2.5, -1.825), rotation = Rotation(0, 0, 0)}}
	self.parts.wpn_fps_lmg_dp28_m_dt.stats = deep_clone(mag_125)
	self.parts.wpn_fps_lmg_dp28_m_dt.stats.extra_ammo = 13
	self.parts.wpn_fps_lmg_dp28_m_dpm36.stance_mod = {
		wpn_fps_lmg_dp28 = {translation = Vector3(0, 0, 1.6), rotation = Rotation(0, 0, 0)}
	}
	self.parts.wpn_fps_lmg_dp28_m_dpm36.stats = deep_clone(mag_75)
	self.parts.wpn_fps_lmg_dp28_m_dpm36.stats.extra_ammo = -13
	self.parts.wpn_fps_lmg_dp28_m_dpm35.stats = {
		value = 0,
		extra_ammo = 153,
		spread = -40,
		reload = -50,
		concealment = -5
	}
DelayedCalls:Add("dp28delay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_lmg_dp28_m_dpm35.timer_adder = nil -- fuck your reload timers
end)
end

-- Actually ingame now
--[[
if BeardLib.Utils:ModLoaded("M60") then
	self.parts.wpn_fps_lmg_m60_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m60_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_upg_m60_bipod.desc_id = "bm_wp_wpn_fps_upg_m60_bipod_desc"

	-- bad company 2 vietnam ADS
	self.parts.wpn_fps_upg_m60_irons.override = self.parts.wpn_fps_upg_m60_irons.override or {}
	self.parts.wpn_fps_upg_m60_irons.override.wpn_fps_upg_m60bc2v_body = {
		stance_mod = {
			wpn_fps_lmg_m60 = {translation = Vector3(0.06, -9, 0), rotation = Rotation(0, -0.1, -0)}
		}
	}

	-- m60e4 ADS
	if self.parts.wpn_fps_lmg_m60e4_furnisight then
		self.parts.wpn_fps_lmg_m60e4_furnisight.stance_mod = {
			wpn_fps_lmg_m60 = {translation = Vector3(0, 0, 3), rotation = Rotation(0, 0, 0)}
		}
	end
end
]]

if BeardLib.Utils:ModLoaded("RPD") then
	self.parts.wpn_fps_upg_rpd_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_upg_rpd_bipod.desc_id = "bm_wp_wpn_fps_upg_rpd_bipod_desc"
	self.parts.wpn_fps_lmg_rpd_mag.stats = deep_clone(nostats)
	-- irons are slightly off
	self.parts.wpn_fps_lmg_rpd_mag.stance_mod = {
		wpn_fps_lmg_rpd = {translation = Vector3(0.05, 0, 0), rotation = Rotation(-0.1, 0, 0)}
	}
end

if BeardLib.Utils:ModLoaded("LSAT") then
	self.parts.wpn_fps_lmg_lsat_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_lsat_barrel_long.stats = deep_clone(barrel_m2)
	self.parts.wpn_fps_upg_lsat_barrel_short.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_upg_lsat_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_upg_lsat_fab_ptk.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_lsat_magpul_afg.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_lsat_stock_collapsed.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_upg_lsat_irons.internal_part = true
end

if BeardLib.Utils:ModLoaded("GSPS Various Attachment") then
	self.parts.wpn_fps_shot_m37_b_trench.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m37_b_deerslayer.stats = deep_clone(barrelsho_m2)
	self.parts.wpn_fps_shot_m37_s_rack.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_m37_s_stakeout.stats = deep_clone(self.parts.wpn_fps_shot_m37_s_short.stats)

	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_b_trench")
	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_b_deerslayer")
	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_s_rack")
	table.insert(self.wpn_fps_shot_m37primary.uses_parts, "wpn_fps_shot_m37_s_stakeout")
end

if BeardLib.Utils:ModLoaded("gtt33") then
	self.parts.wpn_fps_pis_gtt33_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_gtt33_g_white.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_gtt33_g_bling.stats = deep_clone(nostats)
	--self.parts.wpn_fps_pis_gtt33_comp.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
	self.parts.wpn_fps_pis_gtt33_comp2.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
	self.parts.wpn_fps_pis_gtt33_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_pis_gtt33_m_extended.stats.extra_ammo = 8

	self.parts.wpn_fps_pis_gtt33_a_c45.internal_part = true
	self.parts.wpn_fps_pis_gtt33_a_c45.custom_stats = {sdesc1 = "caliber_p762x25badtaste"}
	self.parts.wpn_fps_pis_gtt33_a_c45.stats = deep_clone(nostats)
	--self:convert_part("wpn_fps_pis_gtt33_a_c45", "", "")
end

if BeardLib.Utils:ModLoaded("Fang-45") then
	self.parts.wpn_fps_smg_fang45_m_std.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_fang45_s_folded.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
end

if BeardLib.Utils:ModLoaded("CZ 75 B") then
	self.parts.wpn_fps_pis_cz75b_g_pre.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_g_b.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_g_rub.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_g_coco.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_g_wal.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_f_stainless.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_sl_stainless.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_f_blued.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_f_gold.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_sl_gold.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_ba_ext.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_ba_threaded.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_sl_comp.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_cz75b_fg_mag.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	self.parts.wpn_fps_pis_cz75b_f_comp.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_pis_cz75b_m_comp.stats = { -- not used
		value = 0,
		extra_ammo = -2,
		reload = 10,
		concealment = 2
	}
	self.parts.wpn_fps_pis_cz75b_m_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_cz75b_m_ext.stats.extra_ammo = 8
	self.parts.wpn_fps_pis_cz75b_ba_std.stance_mod = {
		wpn_fps_pis_cz75b = {translation = Vector3(-0.05, 0, -0.3), rotation = Rotation(0, 0.9, 0)}
	}
	-- wpn_fps_pis_cz75b_ba_ext
DelayedCalls:Add("cz75bdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_pis_cz75b_ba_std.weapon_stance_override = nil -- fix this shit later
	tweak_data.weapon.factory.parts.wpn_fps_pis_cz75b_ba_ext.weapon_stance_override = nil
end)
end

if BeardLib.Utils:ModLoaded("CZ 75 Short Rail") then
	self.parts.wpn_fps_pis_rally_m_ext.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_rally_m_ext.stats.extra_ammo = 10
	self.parts.wpn_fps_pis_rally_g_wood.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_rally_g_bacon.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_rally_ba_dummy.stance_mod = {
		wpn_fps_pis_rally = {translation = Vector3(0.05, 0, -0.2), rotation = Rotation(0, 0, 0)}
	}
DelayedCalls:Add("gunsmithcatsdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_pis_rally_sl_std.weapon_stance_override = nil -- fix this shit later
	tweak_data.weapon.factory.parts.wpn_fps_pis_rally_sl_silver.weapon_stance_override = nil
end)
end

if BeardLib.Utils:ModLoaded("CZ Auto Pistol") then
	self.parts.wpn_fps_pis_czauto_ns_compensated.stats = deep_clone(self.parts.wpn_fps_pis_g18c_co_1.stats)
	self.parts.wpn_fps_pis_czauto_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_pis_czauto_m_extended.stats.extra_ammo = 10
	self.parts.wpn_fps_pis_czauto_vg_mag.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	self.parts.wpn_fps_pis_czauto_g_wooden.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_czauto_g_walnut.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_czauto_g_pearl.stats = deep_clone(nostats)
--[[
DelayedCalls:Add("czopdelay", delay, function(self, params)
	if tweak_data.weapon.factory.parts.wpn_fps_pis_czauto_vg_mag.override_weapon then
		tweak_data.weapon.factory.parts.wpn_fps_pis_czauto_vg_mag.override_weapon.use_stance = nil -- fix this shit later
	end
end)
--]]
end

if BeardLib.Utils:ModLoaded("Chiappa Rhino 60DS") and self.parts.wpn_fps_pis_rhino_bullets then
	self.parts.wpn_fps_pis_rhino_bullets.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_rhino_grip_rubber_small.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_rhino_grip_wood_small.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_rhino_sight_fiber.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon_add = {}
	self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon_multiply = {}
	self.parts.wpn_fps_upg_rhino_ammo_40sw.override_weapon = {}
	self.parts.wpn_fps_upg_rhino_ammo_40sw.override = {}
	self:convert_part("wpn_fps_upg_rhino_ammo_40sw", "heavypis", "supermediumpis")
	self.parts.wpn_fps_upg_rhino_ammo_40sw.custom_stats.sdesc1 = "caliber_p40sw"

	-- self.parts.wpn_fps_upg_rhino_frame_200ds.custom_stats = {switchspeed_mult = switch_snubnose}
	--[[
	self.parts.wpn_fps_upg_rhino_frame_200ds.stats = {
		value = 0,
		spread = -30,
		recoil = -10,
		reload = 20,
		concealment = 3
	}
	]]
end

if BeardLib.Utils:ModLoaded("Sjögren Inertia") then
	self.parts.wpn_fps_upg_sjogren_barrel_medium.stats = deep_clone(barrelsho_p1)
	self.parts.wpn_fps_upg_sjogren_barrel_short.stats = deep_clone(barrelsho_p3)
end


if BeardLib.Utils:ModLoaded("ThompsonM1a1") then
	self.parts.wpn_fps_smg_tm1a1_ns_ext.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_tm1a1_body_black.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_tm1a1_body_noiron.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_tm1a1_body_blacknoiron.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_tm1a1_b_standard.stats = deep_clone(barrel_p3)
	self.parts.wpn_fps_smg_tm1a1_ns_cutts.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)
	self.parts.wpn_fps_smg_tm1a1_s_unfolded.stats = {
		value = 0,
		recoil = 4,
		concealment = -2
	}
	self.parts.wpn_fps_smg_tm1a1_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_tm1a1_m_extended.stats.extra_ammo = 10
	self.parts.wpn_fps_smg_x_tm1a1_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_smg_x_tm1a1_m_extended.stats.extra_ammo = 20
	self.parts.wpn_fps_smg_tm1a1_m_jungle.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_smg_tm1a1_m_jungle.stats = {
		value = 0,
		reload = -20,
		concealment = -2
	}
	self.parts.wpn_fps_smg_x_tm1a1_m_jungle.custom_stats = {alternating_reload = 1.20/0.80}
	self.parts.wpn_fps_smg_x_tm1a1_m_jungle.stats = {
		value = 0,
		reload = -20,
		concealment = -2
	}
	self:convert_part_half_a("wpn_fps_smg_tm1a1_lower_reciever_30", "longsmg", "carbine")
	self.parts.wpn_fps_smg_tm1a1_lower_reciever_30.stats.spread = 0
	self.parts.wpn_fps_smg_tm1a1_lower_reciever_30.stats.suppression = 0

	self.parts.wpn_fps_smg_tm1a1_body_standard.stance_mod = {
		wpn_fps_smg_tm1a1 = {translation = Vector3(0, 2, 0), rotation = Rotation(0, 0, 0)}
	}

DelayedCalls:Add("ww2tommydelay", delay, function(self, params)
	tweak_data.weapon.factory:convert_part_half_b("wpn_fps_smg_tm1a1_lower_reciever_30", "longsmg", "carbine")
	tweak_data.weapon.factory.parts.wpn_fps_smg_tm1a1_lower_reciever_30.custom_stats.sdesc1 = "caliber_r30carbine"
end)
end

if BeardLib.Utils:ModLoaded("M6G Magnum") then
	self.parts.wpn_fps_pis_m6g_grip_discrete.stats = {
		value = 0,
		concealment = 2
	}
	self.parts.wpn_fps_pis_m6g_a_fire.custom_stats = {
		sdesc1 = "caliber_p117ic",
		bullet_class = "FlameBulletBase",
		fire_dot_data = {
			dot_trigger_chance = "100",
			dot_damage = "1.5",
			dot_length = "3.1",
			dot_trigger_max_distance = "10000", -- 100m
			dot_tick_period = "0.5"
		}
	}
	self.parts.wpn_fps_pis_m6g_a_fire.stats = {
		value = 0,
		damage = -20,
		concealment = 0
	}
	self.parts.wpn_fps_pis_m6g_a_he.custom_stats = {sdesc1 = "caliber_p117he", bullet_class = "InstantExplosiveBulletBase", ignore_statistic = true, bullet_damage_fraction = 80/200}
	self.parts.wpn_fps_pis_m6g_a_he.stats = {
		value = 0,
		damage = 30,
		concealment = 0
	}
	self.parts.wpn_fps_pis_m6g_a_shield.custom_stats = {sdesc1 = "caliber_p117saphe", bullet_class = "InstantExplosiveBulletBase", ignore_statistic = true, bullet_damage_fraction = 120/180}
	self.parts.wpn_fps_pis_m6g_a_shield.sub_type = "ammo_explosive"
	self.parts.wpn_fps_pis_m6g_a_shield.stats = {
		value = 0,
		damage = 10,
		concealment = 0
	}
end

if BeardLib.Utils:ModLoaded("AK-9") then
	self.parts.wpn_fps_ass_heffy_939_ba_tiss.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_939_fh_tiss.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_939_st_tiss.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_939_ur_tiss.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_939_m_tiss_20.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_o_ak9_l_scopemount.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_939_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
end

if BeardLib.Utils:ModLoaded("AK-47") then
	self.parts.wpn_fps_ass_heffy_762_pg_t2.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_ak47.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ur_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_akmsu.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lr_akmsu.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lr_rpk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_rpk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ufg_rpk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_rpk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_bp_rpk_folded.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_ak103.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_ak103.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ufg_ak103.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_pg_ak103.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_ak103.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_ak104.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_vepr.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lr_vepr.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_vepr.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_md90.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_t56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_t56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_bl_t56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ufg_bl_t56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_pg_bl_t56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_stp_mpi.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_amd63.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_amd63.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_m70.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_m70.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lr_m92.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_m92.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ro_m92.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_tabuk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_sp_tabuk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_rk62.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_rk62.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_pg_rk62.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_rk62.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_bake_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ufg_none.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_none.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_none.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_m92.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_tabuk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_ty56.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_amd65.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_rk62.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_st_tabuk.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_pg_amd65.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ba_ak109.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_o_ak47_l_scopemount.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_vg_amd63.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_vg_amd65.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_lfg_md90.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ch_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_m70.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_762_ba_akmsu.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_heffy_762_ba_rpk.stats = deep_clone(barrel_m2)
	self.parts.wpn_fps_ass_heffy_762_ba_ak104.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_heffy_762_ba_md90.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_heffy_762_ba_amd65.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_heffy_762_ba_m92.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_heffy_762_ba_tabuk.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_ass_heffy_762_bp_rpk.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_ass_heffy_762_bp_rpk.stats = {
		value = 0,
		concealment = -1
	}

	self.parts.wpn_fps_ass_heffy_762_m_steel_5.stats = deep_clone(mag_17)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_5.stats.extra_ammo = -25
	self.parts.wpn_fps_ass_heffy_762_m_steel_10.stats = deep_clone(mag_33)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_10.stats.extra_ammo = -20
	self.parts.wpn_fps_ass_heffy_762_m_bake_10.stats = deep_clone(mag_33)
	--self.parts.wpn_fps_ass_heffy_762_m_bake_10.stats.extra_ammo = -20
	self.parts.wpn_fps_ass_heffy_762_m_steel_20.stats = deep_clone(mag_66)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_20.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_heffy_762_m_steel_40.stats = deep_clone(mag_133)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_40.stats.extra_ammo = 10
	self.parts.wpn_fps_ass_heffy_762_m_steel_75.stats = {
		value = 0,
		--extra_ammo = 45,
		spread = -15,
		recoil = 10,
		reload = -30,
		concealment = -9
	}

	self.parts.wpn_fps_ass_heffy_762_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}

	self.parts.wpn_fps_ass_heffy_762_st_akms.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_akmsu.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_amd65.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_2_mpi.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_3_mpi.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_bl_t56.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_762_st_br_t56.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
end

-- Apparently theres two mods called AK74? Thanks
if BeardLib.Utils:ModLoaded("AK-74") and self.parts.wpn_fps_ass_heffy_545_fh_ak74 then
	self.parts.wpn_fps_ass_heffy_545_fh_ak74.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_aks74u.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lr_aks74u.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lr_rpk74.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_rpk74.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lfg_rpk74.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_ufg_rpk74.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_bp_rpk74_folded.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lr_ak74m.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lfg_ak74m.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_ufg_ak74m.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_pg_ak74m.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_st_ak74m.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_ba_ak105.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_ak105.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_ba_ak107.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_ak107.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_tantal.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_m_steel_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_st_rpk74.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_o_ak74_l_scopemount.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_ufg_74flat.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_lfg_74flat.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_pg_74flat.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_st_74flat.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_st_ak74_poly.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_545_ba_aks74u.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_ass_heffy_545_ba_rpk74.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_ass_heffy_545_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
	self.parts.wpn_fps_ass_heffy_545_st_aks74.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_545_st_aks74u.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_ass_heffy_545_st_md86.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}

	self.parts.wpn_fps_ass_heffy_545_m_bake_45.stats = deep_clone(mag_150)
	--self.parts.wpn_fps_ass_heffy_545_m_bake_45.stats.extra_ammo = 15
	self.parts.wpn_fps_ass_heffy_545_m_poly_45.stats = deep_clone(mag_150)
	--self.parts.wpn_fps_ass_heffy_545_m_poly_45.stats.extra_ammo = 15
	self.parts.wpn_fps_ass_heffy_545_m_poly_60.stats = deep_clone(mag_200)
	--self.parts.wpn_fps_ass_heffy_545_m_poly_60.stats.extra_ammo = 30
end

if BeardLib.Utils:ModLoaded("AK-101") and self.parts.wpn_fps_ass_heffy_556_fh_ak101 then
	self.parts.wpn_fps_ass_heffy_556_fh_ak101.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_fh_ak102.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_ba_ak108.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_fh_ak108.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_o_ak101_l_scopemount.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_ba_t84s.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_ch_t84s.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_fh_t84s.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_ur_t84s.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_556_ba_ak102.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_heffy_556_ba_t84s_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_ass_heffy_556_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
end

if BeardLib.Utils:ModLoaded("AK Color Attachments") then
	self.parts.wpn_fps_ass_heffy_all_mc_bake_bl.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_mc_bake_or.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_camo.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("AK Extra Attachments") then
	self.parts.wpn_fps_ass_heffy_545_st_ivan.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}

	self.parts.wpn_fps_ass_heffy_all_ufg_heat.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_st_moe.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_ulti.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_honor.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_honor.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_zenit.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_zenit.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_rk3.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_rub.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_sco.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_laminate.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_laminate.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_laminate.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_st_laminate.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_st_sho.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_st_pkm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ro_blops.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fm_blops.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ro_ins.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_stpa_gl.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_banana_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_pmag_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_proto_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_fleur_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_m_circle_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_556_m_wieger_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_ch_ak117.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_warrior.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ro_warrior.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_fo_warrior.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_m_ak103_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_m_ivan_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_m_pmag_30.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_fun.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_545_fh_tank.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_fun.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_fh_tank.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_fh_krebs.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_krebs.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_krebs.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_ufg_alpha.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_lfg_alpha.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_762_pg_akmwood.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_pg_saw.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_tr_alpha.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_762_m_star_20.stats = deep_clone(mag_66)
	--self.parts.wpn_fps_ass_heffy_762_m_star_20.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_heffy_762_m_bar_20.stats = deep_clone(mag_66)
	--self.parts.wpn_fps_ass_heffy_762_m_bar_20.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_heffy_762_m_box_20.stats = deep_clone(mag_66)
	--self.parts.wpn_fps_ass_heffy_762_m_box_20.stats.extra_ammo = -10
	self.parts.wpn_fps_ass_heffy_762_m_pmag_20.stats = deep_clone(mag_66)
	self.parts.wpn_fps_ass_heffy_762_m_pmag_10.stats = deep_clone(mag_33)
	self.parts.wpn_fps_ass_heffy_762_m_helical_64.stats = deep_clone(mag_200)
	--self.parts.wpn_fps_ass_heffy_762_m_helical_64.stats.extra_ammo = 34

	self.parts.wpn_fps_ass_heffy_762_m_steel_8.stats = deep_clone(mag_25)
	self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats = deep_clone(mag_200)
	self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_50.stats.reload + 3
	self.parts.wpn_fps_ass_heffy_762_m_steel_60.stats = deep_clone(mag_200)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_60.stats.extra_ammo = 30
	self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats = deep_clone(mag_200)
	self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_70.stats.reload - 3
	self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats = deep_clone(mag_300)
	self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_80.stats.reload + 3
	self.parts.wpn_fps_ass_heffy_762_m_steel_90.stats = deep_clone(mag_300)
	--self.parts.wpn_fps_ass_heffy_762_m_steel_90.stats.extra_ammo = 60
	self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats = deep_clone(mag_300)
	self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats.reload = self.parts.wpn_fps_ass_heffy_762_m_steel_100.stats.reload - 3
	self.parts.wpn_fps_ass_heffy_762_m_steel_180.stats = {
		value = 0,
		--extra_ammo = 150,
		total_ammo_mod = 2000,
		spread = -50,
		recoil = 20,
		--reload = -50,
		concealment = -12
	}
	self.parts.wpn_fps_ass_heffy_762_m_steel_180.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.2*(100 + InFmenu.wpnvalues.reload.mag_300.reload))
	self.parts.wpn_fps_ass_heffy_762_m_steel_260.stats = {
		value = 0,
		--extra_ammo = 230,
		total_ammo_mod = 3000,
		spread = -60,
		recoil = 20,
		--reload = -60,
		concealment = -15
	}
	self.parts.wpn_fps_ass_heffy_762_m_steel_260.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.4*(100 + InFmenu.wpnvalues.reload.mag_300.reload))
	self.parts.wpn_fps_ass_heffy_762_m_steel_1160A.stats = {
		value = 0,
		--extra_ammo_new = 1130,
		total_ammo_mod = 10000,
		spread = -80,
		recoil = 30,
		--reload = -80,
		concealment = -30
	}
	self.parts.wpn_fps_ass_heffy_762_m_steel_1160A.stats.reload = InFmenu.wpnvalues.reload.mag_300.reload - math.floor(0.8*(100 + InFmenu.wpnvalues.reload.mag_300.reload))


	primarysmgadds_specific.wpn_fps_smg_akmsuprimary = primarysmgadds_specific.wpn_fps_smg_akmsuprimary or {}
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_fh_fun")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_fh_tank")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_star_20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_bar_20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_box_20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_pmag_20")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_pmag_10")
	--table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_helical_64")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_8")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_50")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_60")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_70")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_80")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_90")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_100")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_180")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_260")
	table.insert(primarysmgadds_specific.wpn_fps_smg_akmsuprimary, "wpn_fps_ass_heffy_762_m_steel_1160A")

	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_fh_fun")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_fh_tank")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_star_20")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_bar_20")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_box_20")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_pmag_20")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_pmag_10")
	--table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_helical_64")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_8")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_50")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_60")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_70")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_80")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_90")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_100")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_180")
	table.insert(self.wpn_fps_smg_x_akmsu.uses_parts, "wpn_fps_ass_heffy_762_m_steel_260")



	self.parts.wpn_fps_ass_heffy_all_gl_gp25_sight_up.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_all_gl_gp25.stats = {
		value = 0,
		concealment = -5
	}
	self:convert_ammo_pickup("wpn_fps_ass_heffy_all_gl_gp25", "lrifle", "lrifle_gl")
	self:convert_total_ammo_mod("wpn_fps_ass_heffy_all_gl_gp25", "lrifle", "lrifle_gl")
	self.parts.wpn_fps_ass_heffy_all_gl_gp25.custom_stats = {sdesc3 = "misc_gl40vog"}

	self.parts.wpn_fps_upg_gl_lpo70.chamber = 0
	self.parts.wpn_fps_upg_gl_lpo70.stats = {
		value = 0,
		concealment = -5
	}
	self:convert_ammo_pickup("wpn_fps_upg_gl_lpo70", "lrifle", "lrifle_gl")
	self:convert_total_ammo_mod("wpn_fps_upg_gl_lpo70", "lrifle", "lrifle_gl")
	self.parts.wpn_fps_upg_gl_lpo70.custom_stats = {sdesc3 = "misc_flammen"}


	local mrifle_gl_mult = InFmenu.wpnvalues.mrifle_gl.ammo/InFmenu.wpnvalues.mrifle.ammo
	local mrifle_with_underbarrel = {"wpn_fps_ass_heffy_762", "wpn_fps_ass_heffy_gold"}
	local mrifle_underbarrel = {"wpn_fps_ass_heffy_all_gl_gp25", "wpn_fps_upg_gl_lpo70"}
	for a, b in pairs(mrifle_with_underbarrel) do
		for c, d in pairs(mrifle_underbarrel) do
			self[b].override = self[b].override or {}
			self[b].override[c] = self[b].override[c] or {}
			self[b].override[c].custom_stats = {
				ammo_pickup_min_mul = mrifle_gl_mult, ammo_pickup_max_mul = mrifle_gl_mult
			}
			if c == "wpn_fps_upg_gl_lpo70" then
				self[b].override[c].custom_stats.sdesc3 = "misc_flammen"
				--self[b].override[c].desc_id = "bm_wp_wpn_fps_upg_gl_lpo70_desc2" -- SHIT DON'T WANT TO WORK
			else
				self[b].override[c].custom_stats.sdesc3 = "misc_gl40vog"
				--self[b].override[c].desc_id = "bm_wp_wpn_fps_ass_heffy_all_gl_gp25_desc2"
			end
			self[b].override[c].stats = {
				value = 0,
				concealment = -5
			}
			self[b].override[c].stats.total_ammo_mod = math.floor(((mrifle_gl_mult - 1) * 1000) + 0.5)
		end
	end

	self.parts.wpn_fps_ass_heffy_all_sm_cover.stance_mod = {
		wpn_fps_ass_heffy_762 = {translation = Vector3(0, 0, 0.45)},
		wpn_fps_ass_heffy_939 = {translation = Vector3(0, 0, 0.45)},
		wpn_fps_ass_heffy_545 = {translation = Vector3(0, 0, 0.45)},
		wpn_fps_ass_heffy_556 = {translation = Vector3(0, 0, 0.45)}
	}
	self.parts.wpn_fps_ass_heffy_all_sm_cover.adds = {"inf_sightdummy2"}
end

if BeardLib.Utils:ModLoaded("Golden-AKMS") then
	self.parts.wpn_fps_ass_heffy_gold_st_akm.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_gold_st_akms.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_heffy_gold_fh_none.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_o_gold_l_scopemount.stats = deep_clone(nostats)

	self.parts.wpn_fps_ass_heffy_gold_m_steel_40.stats = deep_clone(mag_133)
	--self.parts.wpn_fps_ass_heffy_gold_m_steel_40.stats.extra_ammo = 10
	self.parts.wpn_fps_ass_heffy_gold_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
end

if BeardLib.Utils:ModLoaded("Saiga-12") then
	self.parts.wpn_fps_sho_heffy_12g_ext_saiga12k.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_heffy_12g_lfg_utg_short.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_heffy_12g_lfg_utg_long.stats = deep_clone(nostats)
	self.parts.wpn_fps_sho_heffy_12g_ro_rail.stats = deep_clone(nostats)

	self.parts.wpn_fps_sho_heffy_12g_m_poly_10.stats = deep_clone(mag_200)
	--self.parts.wpn_fps_sho_heffy_12g_m_poly_10.stats.extra_ammo = 5

	self.parts.wpn_fps_sho_heffy_12g_st_none.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
end

if BeardLib.Utils:ModLoaded("Nagant M1895") then
	self.parts.wpn_fps_pis_m1895_cylinder.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m1895_body_blued.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m1895_body_gold.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m1895_body_polished.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m1895_body_worn.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_m1895_irons_radium.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_m1895_supp_ro2.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_m1895_supp_ro2.stats = deep_clone(silstatsconc0)
	self.parts.wpn_fps_upg_m1895_supp_gemtech_gm9.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_m1895_supp_gemtech_gm9.stats = deep_clone(silstatsconc1)
	self.parts.wpn_fps_upg_m1895_supp_osprey.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_m1895_supp_osprey.stats = deep_clone(silstatsconc2)

	self.parts.wpn_fps_upg_m1895_barrel_long.stats = deep_clone(barrel_m1)
end

if BeardLib.Utils:ModLoaded("VHS Various Attachment") then
	self.parts.wpn_fps_ass_vhs_body_future.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_vhs_m_lsw.stats = {
		value = 0,
		reload = -10,
		concealment = -2
	}
	self.parts.wpn_fps_ass_vhs_ub_nade.stats = {
		value = 0,
		concealment = -3
	}
	self:convert_part("wpn_fps_ass_vhs_ub_nade", "lrifle", "lrifle_gl")
	self.parts.wpn_fps_ass_vhs_ub_nade.custom_stats = {sdesc3 = "misc_gl40x46mm"}
end

if BeardLib.Utils:ModLoaded("Aimpoint CompM2 Sight") then
	self.parts.wpn_fps_upg_o_compm2.customsight = true
	self.parts.wpn_fps_upg_o_compm2.stats = {
		value = 0,
		zoom = 3,
		concealment = -1,
	}
end

if BeardLib.Utils:ModLoaded("Stealth Flashlights") then
	self.parts.wpn_fps_upg_fl_wml.desc_id = "bm_wp_wpn_fps_upg_fl_wml_desc"
	self.parts.wpn_fps_upg_fl_pis_micro90.desc_id = "bm_wp_wpn_fps_upg_fl_micro90_desc"
end

if BeardLib.Utils:ModLoaded("Gepard GM6 Lynx") then
	table.insert(gunlist_snp, {"wpn_fps_snp_lynx", -3})
	self.parts.wpn_fps_snp_lynx_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_lynx_a_low.internal_part = true
	self.parts.wpn_fps_snp_lynx_a_low.stats = deep_clone(nostats)

	self.parts.wpn_fps_snp_lynx_o_special.custom_stats = {disallow_ads_while_reloading = true}

	self.parts.wpn_fps_snp_lynx_b_cqb.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_snp_msr_ns_suppressor.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_lynx_b_supp.stats = deep_clone(silstatssnp)

	self.parts.wpn_fps_snp_lynx_m_short.stats = deep_clone(mag_50)
	self.parts.wpn_fps_snp_lynx_m_short.stats.extra_ammo = -6
DelayedCalls:Add("lynxdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_snp_lynx_a_low.custom_stats = {sdesc1 = "caliber_r127x108"}
end)
end

if BeardLib.Utils:ModLoaded("PPSh-41") then
	--self.parts.wpn_fps_upg_ppsh_barrel_extension.stats = deep_clone(barrel_m1)
	--self.parts.wpn_fps_upg_ppsh_stock_black.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_ppsh_stock_camo_jungle.stats = deep_clone(nostats)
	self.parts.wpn_fps_smg_ppsh_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ppsh_barrel_k50m.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ppsh_barrel_sawnoffcomp.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ppsh_stock_k50m.stats = {
		value = 0,
		recoil = -6,
		concealment = 2,
	}
	self.parts.wpn_fps_upg_ppsh_stock_k50m_ext.stats = {
		value = 0,
		recoil = -9,
		concealment = 3,
	}

	self.parts.wpn_fps_upg_ppsh_mag_drum.custom_stats = {use_reload_2 = true, mod_empty_reload_speed_mult = 0.80, set_reload_stance_mod = {hip = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 0, 0)}, ads = {translation = Vector3(0, 0, -5), rotation = Rotation(0, 0, 0)}}}
	self.parts.wpn_fps_upg_ppsh_mag_drum.stats = deep_clone(mag_200)
	self.parts.wpn_fps_upg_ppsh_mag_drum.stats.extra_ammo = 36
end

if BeardLib.Utils:ModLoaded("CSGO Sniper Scope") then
	self.parts.wpn_fps_upg_o_csgoscope.customsight = true
	self.parts.wpn_fps_upg_o_csgoscope.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_upg_o_csgoscope.stats = {
		value = 0,
		zoom = 8,
		concealment = -3
	}
end

if BeardLib.Utils:ModLoaded("M1 Garand Modpack") then
	self.parts.wpn_fps_ass_ching_o_m84.customsight = true
	self.parts.wpn_fps_ass_ching_o_m84.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_ass_ching_o_m84.stats = {
		value = 0,
		zoom = 10,
		concealment = -3
	}
	--wpn_fps_ass_ching_ironsight_switch

	self.parts.wpn_fps_ass_ching_ns_flashhider.stats = deep_clone(self.parts.wpn_fps_upg_ass_ns_linear.stats)

	self.parts.wpn_fps_ass_ching_ns_expsilencer.custom_stats = silencercustomstats
	self.parts.wpn_fps_ass_ching_ns_expsilencer.stats = deep_clone(silstatsconc1)
end

if BeardLib.Utils:ModLoaded("Kel-Tec RFB") then
	self.parts.wpn_fps_upg_leet_fg_ext.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_leet_b_smol.stats = deep_clone(barrel_p2)
end

if BeardLib.Utils:ModLoaded("Silent Killer High Standard HDM") then
	self.parts.wpn_fps_pis_hshdm_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_hshdm_frame_gold.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_hshdm_barrel.custom_stats = silencercustomstats
end

if BeardLib.Utils:ModLoaded("Silent Killer Maxim 9") then
	self.parts.wpn_fps_pis_max9_b_standard.custom_stats = silencercustomstats

	self.parts.wpn_fps_pis_max9_b_short.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_max9_b_short.stats = {
		value = 0,
		suppression = 12,
		alert_size = 12,
		spread = -5,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_pis_max9_b_short.stats.reload = barrel_p1.reload

	self.parts.wpn_fps_pis_max9_b_nosup.custom_stats = {sdesc4 = "misc_blank", falloff_min_dmg_penalty = 0}
	self.parts.wpn_fps_pis_max9_b_nosup.stats = {
		value = 0,
		spread = -10,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_pis_max9_b_nosup.stats.reload = barrel_p2.reload
end

if BeardLib.Utils:ModLoaded("Silent Killer Welrod") then
	self.parts.wpn_fps_pis_welrod_b_bolt.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_welrod_b_short.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_pis_welrod_b_short.stats.alert_size = -2
	self.parts.wpn_fps_pis_welrod_b_short.stats.suppression = -2
	self.parts.wpn_fps_pis_welrod_glow.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_welrod_trigger_guard.custom_stats = {use_goldeneye_reload = false}
	self.parts.wpn_fps_pis_welrod_trigger_guard.stats = deep_clone(nostats)

	self.parts.wpn_fps_pis_welrod_a_ap.stats = deep_clone(nostats)
	self:convert_ammo_pickup("wpn_fps_pis_welrod_a_ap", "heavypis", 30)
	self:convert_total_ammo_mod("wpn_fps_pis_welrod_a_ap", "heavypis", 30)
end

if BeardLib.Utils:ModLoaded("PB") then
	self.parts.wpn_fps_pis_pb_ns_std.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_pb_ns_std.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_pis_pb_ns_std.stats.concealment = -1
end

if BeardLib.Utils:ModLoaded("G3 Various Attachment") then
	--self.parts.wpn_fps_upg_g3_bipod.type = "bipod"
	--self.parts.wpn_fps_upg_g3_bipod.adds = {"inf_bipod_part"}
	self.parts.wpn_fps_upg_g3_bipod.custom_stats = {recoil_horizontal_mult = 2}
	self.parts.wpn_fps_upg_g3_bipod.stats = {
		value = 0,
		concealment = -1
	}

	self.parts.wpn_fps_ass_g3_g_ergo.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_g3_s_polymer.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_g3_fg_carbine.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_ass_g3_s_retractable.stats = {
		value = 0,
		recoil = -6,
		concealment = 2
	}

	self.parts.wpn_fps_ass_g3_m_50drum.stats = deep_clone(mag_250)
	self.parts.wpn_fps_ass_g3_m_50drum.stats.extra_ammo = 30
	self.parts.wpn_fps_ass_g3_m_30mag.stats = deep_clone(mag_150)
	self.parts.wpn_fps_ass_g3_m_30mag.stats.extra_ammo = 10
end

if BeardLib.Utils:ModLoaded("Browning Auto Shotgun") then
	self.parts.wpn_fps_shot_auto5_b_short.stats = deep_clone(barrelsho_p1)
	self.parts.wpn_fps_shot_auto5_b_reinforced.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_auto5_s_pad.stats = deep_clone(nostats)
	self.parts.wpn_fps_shot_auto5_s_grip.stats = deep_clone(nostats)

	self.parts.wpn_fps_shot_auto5_m_extended.stats = {
		value = 0,
		extra_ammo = 2,
		concealment = -2
	}
	self.parts.wpn_fps_shot_auto5_m_long.stats = {
		value = 0,
		extra_ammo = 4,
		concealment = -3
	}
	self.parts.wpn_fps_shot_auto5_s_sawed.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}
end

if BeardLib.Utils:ModLoaded("M40A5") then
	table.insert(self.wpn_fps_snp_m40a5.uses_parts, "inf_bipod_snp")
	table.insert(gunlist_snp, {"wpn_fps_snp_m40a5", -3})
	self.parts.wpn_fps_snp_m40a5_m8541.custom_stats = {disallow_ads_while_reloading = true}
	self.parts.wpn_fps_snp_m40a5_mag.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_m40a5_omega.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_m40a5_omega.stats = deep_clone(silstatssnp)
end

if BeardLib.Utils:ModLoaded("PKA-S Sight") then
	self.parts.wpn_fps_upg_o_pkas.stats = deep_clone(self.parts.wpn_fps_upg_o_aimpoint.stats)
	self.parts.wpn_fps_upg_o_pkas.customsight = true
end

if BeardLib.Utils:ModLoaded("Trijicon ACOG TA648 Scope") then
	self.parts.wpn_fps_upg_o_ta648.stats = {
		value = 0,
		zoom = 6,
		concealment = -3
	}
	self.parts.wpn_fps_upg_o_ta648.customsight = true
	self.parts.wpn_fps_upg_o_ta648.custom_stats = {disallow_ads_while_reloading = true}
end

if BeardLib.Utils:ModLoaded("Desert Tech MDR") then
	self.parts.wpn_fps_ass_mdr_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_mdr_vg_bcm.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_mdr_vg_fab_reg.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_mdr_vg_lt_fug.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_mdr_barrel_long.stats = deep_clone(barrel_m2)
	self.parts.wpn_fps_upg_mdr_comp.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats)

	self.parts.wpn_fps_upg_mdr_mag_30.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_mdr_mag_30.stats.extra_ammo = 10
	self.parts.wpn_fps_upg_mdr_pmag.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_mdr_pmag.stats.extra_ammo = 10

	self.parts.wpn_fps_upg_mdr_supp_omega.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_mdr_supp_omega.stats = deep_clone(silstatsconc1)
end

if BeardLib.Utils:ModLoaded("FN SCAR-L") then
	self.parts.wpn_fps_upg_scarl_barrel_cqc.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_upg_scarl_barrel_cqc_mod.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_upg_scarl_upper_pdw.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_upg_scarl_barrel_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_upg_scarl_stock_cheek.stats = {
		value = 0,
		recoil = 2,
		concealment = -1
	}
	self.parts.wpn_fps_upg_scarl_stock_collapsed.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_upg_scarl_stock_pdw.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_upg_scarl_stock_pdw_collapsed.stats = {
		value = 0,
		recoil = -6,
		concealment = 3
	}

	self.parts.wpn_fps_upg_scarl_mag_pdw.stats = deep_clone(mag_66)
	self.parts.wpn_fps_upg_scarl_mag_pdw.stats.extra_ammo = -10

	--self.parts.wpn_fps_upg_scarl_grip_magpul_miad.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_scarl_grip_magpul_moe.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_scarl_grip_vindicator.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scarl_mag_pull_assist.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_scarl_rail_nitro_v.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scarl_rail_pws_srx.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scarl_rail_vltor_casv.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scarl_rail_kinetic_mrex.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scarl_rail_midwest_ext.stats = deep_clone(nostats)
end

if BeardLib.Utils:ModLoaded("FN SCAR-L M203") then
	self.parts.wpn_fps_upg_scar_m203_barrel_long.stats = deep_clone(barrel_m2)

	self.parts.wpn_fps_upg_scar_m203_stock_collapsed.stats = {
		value = 0,
		recoil = -2,
		concealment = 1
	}
	self.parts.wpn_fps_upg_scar_m203_stock_pdw.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
	self.parts.wpn_fps_upg_scar_m203_sight.stats = {
		value = 0,
		gadget_zoom = 2,
		concealment = 0
	}

	--self.parts.wpn_fps_upg_scar_m203_grip_magpul_miad.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_scar_m203_grip_magpul_moe.stats = deep_clone(nostats)
	--self.parts.wpn_fps_upg_scar_m203_grip_vindicator.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_scar_m203_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_scar_m203_mag_pull_assist.stats = deep_clone(nostats)
end

--[[
if BeardLib.Utils:ModLoaded("Kar98k") then
	self.parts.wpn_fps_snp_kar98k_b_medium.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_snp_kar98k_b_short.stats = deep_clone(barrel_p2)

	self.parts.wpn_fps_snp_kar98k_b_geha.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_kar98k_body_black.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_kar98k_body_1935.stats = deep_clone(nostats)
	self.parts.wpn_fps_snp_kar98k_body_1935_black.stats = deep_clone(nostats)

	self.parts.wpn_fps_snp_kar98k_b_sniper.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_snp_kar98k_b_sniper.stats = deep_clone(silstatssnp)

	self.parts.wpn_fps_snp_kar98k_m_geha.stats = {
		value = 0,
		extra_ammo = -2,
		spread = -30,
		concealment = 0
	}

DelayedCalls:Add("kar98kdelay", delay, function(self, params)
	tweak_data.weapon.factory.parts.wpn_fps_snp_kar98k_iron_sight.stats = deep_clone(nostats)
	tweak_data.weapon.factory.parts.wpn_fps_snp_kar98k_iron_sight.stats.zoom = 0
	tweak_data.weapon.factory.parts.wpn_fps_upg_a_german12.custom_stats = {
		rays = 10,
		armor_piercing_add = 0,
		can_shoot_through_enemy = false, 
		can_shoot_through_shield = false, 
		can_shoot_through_wall = false,
		damage_far_mul = 0.15,
		damage_near_mul = 0.30,
	}
end)
end
--]]

if BeardLib.Utils:ModLoaded("SKS") then
	self.parts.wpn_fps_ass_sks_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_sks_mag_tapco.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_sks_supp_dtk4.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_sks_supp_dtk4.stats = deep_clone(silstatsconc1)
	self.parts.wpn_fps_upg_sks_supp_pbs1.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_sks_supp_pbs1.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_sks_barrel_short_sksd.stats = deep_clone(barrel_p1)
	self.parts.wpn_fps_upg_sks_dtk1.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
	self.parts.wpn_fps_upg_sks_dtk2.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
end

if BeardLib.Utils:ModLoaded("MAS-49") then
	table.insert(gunlist_snp, {"wpn_fps_snp_mas49", -3})
	self.parts.wpn_fps_snp_mas49_scope_apx.custom_stats = {disallow_ads_while_reloading = true}

	self.parts.wpn_fps_upg_mas49_barrel_short.stats = deep_clone(barrel_p3)
	self.parts.wpn_fps_upg_mas49_irons.custom_stats = {sdesc3 = "misc_irons"}
	self.parts.wpn_fps_upg_mas49_irons.stats = {
		value = 0,
		concealment = 0 -- auto-bumped up to 3
	}
end

if BeardLib.Utils:ModLoaded("AK-12") then
	self.parts.wpn_fps_ass_ak12_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak12_grip_molot.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak12_mag_magpul.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_ak12_mag_quad.stats = deep_clone(mag_200)
	self.parts.wpn_fps_upg_ak12_mag_quad.stats.extra_ammo = 30
	self.parts.wpn_fps_upg_ak12_barrel_ak12u.stats = deep_clone(barrel_p2)
	self.parts.wpn_fps_upg_ak12_barrel_rpk12.stats = deep_clone(barrel_m2)
	self:convert_part("wpn_fps_upg_ak12_barrel_svk12", "lrifle", "ldmr")
	self.parts.wpn_fps_upg_ak12_barrel_svk12.stats.extra_ammo = -10
	self.parts.wpn_fps_upg_ak12_barrel_svk12.custom_stats.rof_mult = nil
	self.parts.wpn_fps_upg_ak12_barrel_svk12.custom_stats.sdesc1 = "caliber_r762x51"

	self.parts.wpn_fps_upg_ak12_dtk1.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
	self.parts.wpn_fps_upg_ak12_supp_tgp_a.custom_stats = silencercustomstats
	self.parts.wpn_fps_upg_ak12_supp_tgp_a.stats = deep_clone(self.parts.wpn_fps_upg_ns_ass_smg_tank.stats)
	
	self.parts.wpn_fps_upg_ak12_stock_folding.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
end

if BeardLib.Utils:ModLoaded("AK-12/76") and self.parts.wpn_fps_shot_ak12_76_mag then
	self.parts.wpn_fps_shot_ak12_76_mag.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak12_76_grip_molot.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_ak12_76_mag_magpul.stats = deep_clone(nostats)

	self.parts.wpn_fps_upg_ak12_76_gk_01.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_shark.stats)
	self.parts.wpn_fps_upg_ak12_76_stock_folding.stats = {
		value = 0,
		recoil = -4,
		concealment = 2
	}
end

if BeardLib.Utils:ModLoaded("RAZOR AMG UH-1") and self.parts.wpn_fps_upg_o_razoramg then
	self.parts.wpn_fps_upg_o_razoramg.customsight = true
	self.parts.wpn_fps_upg_o_razoramg.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
end

if BeardLib.Utils:ModLoaded("Trijicon RMR Sight") and self.parts.wpn_fps_upg_o_rmr_riser then
	self.parts.wpn_fps_upg_o_rmr_riser.customsight = true
	self.parts.wpn_fps_upg_o_rmr_riser.stats = deep_clone(self.parts.wpn_fps_upg_o_eotech.stats)
end

-- McMillan CS5
if BeardLib.Utils:ModLoaded("McMillan CS5") and self.parts.wpn_fps_upg_cs5_barrel_short then
	-- Long barrel
	self.parts.wpn_fps_upg_cs5_barrel_long.stats = deep_clone(barrel_m1)
	-- Short barrel
	self.parts.wpn_fps_upg_cs5_barrel_short.stats = deep_clone(barrel_p2)
	-- Suppressed barrel
	self.parts.wpn_fps_upg_cs5_barrel_suppressed.custom_stats = snpsilencercustomstats
	self.parts.wpn_fps_upg_cs5_barrel_suppressed.stats = deep_clone(silstatssnp)
	-- Bipod
	self.parts.wpn_fps_upg_cs5_harris_bipod.stats = {
		value = 0,
		concealment = -1
	}
	self.parts.wpn_fps_upg_cs5_harris_bipod.custom_stats = {recoil_horizontal_mult = 2}

	-- Add the McMillan CS5 to be eligible for all the sniper custom parts, like the customizable Leupold
	table.insert(self.wpn_fps_snp_cs5.uses_parts, "wpn_fps_upg_o_spot")
	table.insert(self.wpn_fps_snp_cs5.uses_parts, "inf_shortdot")
	table.insert(self.wpn_fps_snp_cs5.uses_parts, "wpn_fps_upg_o_box")
	table.insert(gunlist_snp, {"wpn_fps_snp_cs5", -3})
end

-- FN SCAR MK17 (Eagle Tactical)
if BeardLib.Utils:ModLoaded("MK17") and self.parts.wpn_fps_upg_mk17_b_smol then
	-- Long barrel
	self.parts.wpn_fps_upg_mk17_b_long.stats = deep_clone(barrel_m1)
	-- Short barrel
	self.parts.wpn_fps_upg_mk17_b_smol.stats = deep_clone(barrel_p1)

	-- Heavy Bolt, converts to light DMR
	self:convert_part("wpn_fps_upg_mk17_bolt_old", "hrifle", "ldmr")

	-- Extended Rail
	self.parts.wpn_fps_upg_mk17_ex_rail.stats = deep_clone(nostats)

	-- Night Ops Kit
	self.parts.wpn_fps_upg_mk17_rec_lower_black.stats = deep_clone(nostats)

	-- Speed-pull mag
	self.parts.wpn_fps_upg_mk17_m_quick.stats = deep_clone(nostats)

	-- Golden State magazine
	self.parts.wpn_fps_upg_mk17_m_smol.stats = {
		value = 0,
		extra_ammo = -10,
		concealment = 2
	}

	-- Extended stock
	self.parts.wpn_fps_upg_mk17_s_extended.stats = {
		value = 2,
		recoil = 2,
		concealment = -1
	}
	-- No stock
	self.parts.wpn_fps_upg_mk17_s_no.stats = {
		value = 1,
		recoil = -2,
		concealment = 1
	}

	-- DMR Kit, converts to DMR
	-- No shield piercing because that only seems to work on "ammo" weaponmod types >:(
	-- TODO: Give this part no stats, but give it a hidden DMR ammo dummy mod.
	self:convert_part("wpn_fps_upg_mk17_rec_upper_mk20", "hrifle", "dmr")
end

-- CARL WAS HERE AGAIN
-- my own guns
-- FN Five-seveN MK2
if BeardLib.Utils:ModLoaded("Not Rarted Five-seveN") and self.parts.wpn_fps_upg_hoxy_o_scopemount then
	-- I REGRET NOTHING.
	-- threaded barrel
	self.parts.wpn_fps_upg_hoxy_b_threaded.stats = deep_clone(barrel_m1)

	-- +p+ boolet
	self:convert_part("wpn_fps_upg_hoxy_am_plusp", "lightpis", "mediumpis")

	-- um3 scope mount
	self.parts.wpn_fps_upg_hoxy_o_scopemount.stats = deep_clone(nostats)
	-- todo update this for when the gemtech sfn suppressor gets unfucked
end

-- ST AR-15
if BeardLib.Utils:ModLoaded("Spikes Tactical AR-15") and self.parts.wpn_fps_upg_flat_bolt_sai then
	-- Remove ST AR-15 posthook because it causes issues, sorry
	Hooks:RemovePostHook("star15_init")

	self.parts.wpn_fps_upg_flat_bolt_sai.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_flat_fg_blk.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_flat_rec_lower_blk.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_flat_rec_upper_blk.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_flat_s_pod.stats = deep_clone(nostats)
	self.parts.wpn_fps_upg_flat_vg_no.stats = deep_clone(nostats)

	-- Silencer barrel ext
	self.parts.wpn_fps_upg_flat_ns_thic.stats = deep_clone(silstatsconc2)
	self.parts.wpn_fps_upg_flat_ns_thic.custom_stats = silencercustomstats

	-- Conversion kits for anti-materiel and regular AR
	-- Remove all the overrides and multiplications/custom stats first
	self.parts.wpn_fps_upg_flat_am_woof.custom_stats = {}
	self.parts.wpn_fps_upg_flat_am_woof.override_weapon_multiply = {}
	self.parts.wpn_fps_upg_flat_am_woof.override_weapon = {}
	self.parts.wpn_fps_upg_flat_am_woof.override = {}

	self.parts.wpn_fps_upg_flat_am_weak.custom_stats = {}
	self.parts.wpn_fps_upg_flat_am_weak.override_weapon_multiply = {}
	self.parts.wpn_fps_upg_flat_am_weak.override_weapon = {}
	self.parts.wpn_fps_upg_flat_am_weak.override = {}

	self:convert_part("wpn_fps_upg_flat_am_woof", "ldmr", "hdmr", 80, 30)
	self.parts.wpn_fps_upg_flat_am_woof.stats.extra_ammo = -20
	self.parts.wpn_fps_upg_flat_am_woof.custom_stats.sdesc1 = "caliber_r762x51dm151"
	-- Forbid using this with larger or smaller mags
	if not self.parts.wpn_fps_upg_flat_am_woof.forbids then
		self.parts.wpn_fps_upg_flat_am_woof.forbids = {}
	end
	table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_upg_m4_m_quad")
	table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_upg_m4_m_straight")
	if self.parts.wpn_fps_ass_m4_m_wick then
		table.insert(self.parts.wpn_fps_upg_flat_am_woof.forbids, "wpn_fps_ass_m4_m_wick")
	end

	self:convert_part("wpn_fps_upg_flat_am_weak", "ldmr", "mrifle", 80, 120)
	self.parts.wpn_fps_upg_flat_am_weak.custom_stats.sdesc1 = "caliber_r556x45"

	self.parts.wpn_fps_upg_flat_am_woof.override_weapon = {
		categories = { "snp" },
		sounds = {
			fire = "spikes_fire_bwlf",
			fire_single = "spikes_fire_bwlf"
		}
	}
end

-- Desert Eagle Duet
-- Deagle XIX
if BeardLib.Utils:ModLoaded("Desert Eagle XIX") and self.parts.wpn_fps_upg_deltaoneniner_frame_borat then
	-- Bling Frame
	self.parts.wpn_fps_upg_deltaoneniner_frame_borat.stats = deep_clone(nostats)
	-- Sweetheart Grip
	self.parts.wpn_fps_upg_deltaoneniner_g_waifu.stats = deep_clone(nostats)
	-- Extended Mag
	self.parts.wpn_fps_upg_deltaoneniner_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_deltaoneniner_m_extended.stats.extra_ammo = 3
end

-- Deagle L5
if BeardLib.Utils:ModLoaded("Desert Eagle L5") and self.parts.wpn_fps_upg_limafive_frame_pink then
	-- Pink Frame
	self.parts.wpn_fps_upg_limafive_frame_pink.stats = deep_clone(nostats)
	-- Sweetheart Grip
	self.parts.wpn_fps_upg_limafive_g_waifu.stats = deep_clone(nostats)
	-- Extended Mag
	self.parts.wpn_fps_upg_limafive_m_extended.stats = deep_clone(mag_150)
	self.parts.wpn_fps_upg_limafive_m_extended.stats.extra_ammo = 3
	-- Dakota Special Slide
	self:convert_part("wpn_fps_upg_limafive_sl_morbid", "heavypis", "supermediumpis")
	self.parts.wpn_fps_upg_limafive_sl_morbid.custom_stats.sdesc1 = "caliber_p38spc"
end

-- HL1 9mm pistol
if BeardLib.Utils:ModLoaded("Half Life 1 Glock") and self.parts.wpn_fps_pis_hl1g_suppress then
	self.parts.wpn_fps_pis_hl1g_suppress.custom_stats = silencercustomstats
	self.parts.wpn_fps_pis_hl1g_suppress.stats = deep_clone(silstatsconc1)
end

-- Glock 17 Gen 3
-- So many calibers, holy
if BeardLib.Utils:ModLoaded("Glock 17 Gen 3") then
	-- .22 LR conversion kit
	self.parts.wpn_fps_pis_glawk_a1_22lr.stats = deep_clone(nostats)
	self.parts.wpn_fps_pis_glawk_a1_22lr.stats.spread = -2
	self.parts.wpn_fps_pis_glawk_a1_22lr.stats.recoil = 2
	self.parts.wpn_fps_pis_glawk_a1_22lr.custom_stats.sdesc1 = "caliber_p22lr"

	-- .40 S&W conversion kit
	self:convert_part("wpn_fps_pis_glawk_a1_40sw", "lightpis", "mediumpis")
	self.parts.wpn_fps_pis_glawk_a1_40sw.custom_stats.sdesc1 = "caliber_p40sw"

	-- 10mm auto conversion kit
	self:convert_part("wpn_fps_pis_glawk_a2_10mm", "lightpis", "mediumpis")
	self.parts.wpn_fps_pis_glawk_a2_10mm.custom_stats.sdesc1 = "caliber_p10"

	-- .357 SIG conversion kit
	self:convert_part("wpn_fps_pis_glawk_a3_357sig", "lightpis", "supermediumpis")
	self.parts.wpn_fps_pis_glawk_a3_357sig.custom_stats.sdesc1 = "caliber_p357sig"

	-- .45 ACP conversion kit
	self:convert_part("wpn_fps_pis_glawk_a4_45acp", "lightpis", "supermediumpis")
	self.parts.wpn_fps_pis_glawk_a4_45acp.custom_stats.sdesc1 = "caliber_p45acp"

	-- .45 GAP conversion kit
	self:convert_part("wpn_fps_pis_glawk_a5_45gap", "lightpis", "supermediumpis")
	self.parts.wpn_fps_pis_glawk_a5_45gap.custom_stats.sdesc1 = "caliber_p45gap"

	-- Pachmayr Grip
	self.parts.wpn_fps_pis_glawk_gr_pachmayr.stats = deep_clone(nostats)
end

-- Glock 19
if BeardLib.Utils:ModLoaded("Glock 19") and self.parts.wpn_fps_upg_g19_ammo_9mm_p then
	self:convert_part("wpn_fps_upg_g19_ammo_9mm_p", "lightpis", "mediumpis")
	self.parts.wpn_fps_upg_g19_ammo_9mm_p.custom_stats.sdesc1 = "caliber_p9x19nade"
end

-- TR-1
if BeardLib.Utils:ModLoaded("TR-1") and self.parts.wpn_fps_ass_hugsforleon_upper then
	self.parts.wpn_fps_ass_hugsforleon_upper.stats = deep_clone(nostats)
end

-- ACR
if BeardLib.Utils:ModLoaded("acwr") and self.parts.wpn_fps_ass_acwr_b_short then
	self.parts.wpn_fps_ass_acwr_b_short.stats = deep_clone(barrel_p1)
end

-- Dokkaebi M14
if BeardLib.Utils:ModLoaded("Dokkaebi M14 modpack") and self.parts.wpn_fps_ass_m14_body_goblin then
	self.parts.wpn_fps_ass_m14_body_goblin.stats = deep_clone(nostats)
	self.parts.wpn_fps_ass_m14_body_goblin.custom_stats = {}
	
	-- By default this mod forbids the firemode mods, the M14 doesn't have these anymore
	-- There's no real reason to forbid anything except the scope mount then
	self.parts.wpn_fps_ass_m14_body_goblin.forbids = {
		"wpn_fps_upg_o_m14_scopemount"
	}
end

-- Dokkaebi SMG-12
if BeardLib.Utils:ModLoaded("Dokkaebi SMG12 modpack") and self.parts.wpn_fps_mp_master_m_standard then
	-- No speedpull speed
	self.parts.wpn_fps_mp_master_m_standard.stats = deep_clone(nostats)

	-- Large mag
	self.parts.wpn_fps_mp_master_m_extended.stats = deep_clone(mag_200)
	self.parts.wpn_fps_mp_master_m_extended.stats.extra_ammo = 15

	-- No stock
	self.parts.wpn_fps_mp_master_s_no.stats = {
		value = 0,
		recoil = -2,
		concealment = 2
	}
	-- Folded stock
	self.parts.wpn_fps_mp_master_s_extended.stats = {
		value = 0,
		recoil = -1,
		concealment = 1
	}

	-- Silencer
	self.parts.wpn_fps_mp_master_ns_silent.custom_stats = silencercustomstats
	self.parts.wpn_fps_mp_master_ns_silent.stats = deep_clone(silstatsconc2)

	-- Foregrips
	self.parts.wpn_fps_mp_master_vg_angle.stats = deep_clone(nostats)
	self.parts.wpn_fps_mp_master_vg_straight.stats = deep_clone(nostats)
end

-- HOW TO ADD CUSTOM WEAPON MOD SUPPORT
-- This applies to any BeardLib mod that adds custom weapon mods, whether they come with an actual weapon or not.
-- You first need the weapon mod's ID, which can be found in the mod's XML files (such as main.xml).

-- You need to check if the BeardLib mod is loaded, but also check if at least 1 given part is not nil.
-- This will help prevent crashes if someone else makes a beardlib mod with the same name, or if the author drastically changes their weapon mods around.
-- The BeardLib mod's name is actually defined in the main.xml file. This is <table name="mymod">, where the name would then be "mymod".

-- Example:
-- if BeardLib.Utils:ModLoaded("Glock 19") and self.parts.wpn_fps_upg_g19_ammo_9mm_p then
	-- This is a "conversion mod". It converts the weapon from A to B. In this case, this higher-caliber ammo changes the glock 19 from a light pistol into a medium pistol,
	-- effectively making it equal to other medium pistols such as the Crosskill.
	-- The from/to is based on the weapon values in InfMenu (infcore.lua). So it's not "pistol light", but "lightpis".
	-- self:convert_part("wpn_fps_upg_g19_ammo_9mm_p", "lightpis", "mediumpis")
	-- This also changes the caliber in the weapon's short description.
	-- self.parts.wpn_fps_upg_g19_ammo_9mm_p.custom_stats.sdesc1 = "caliber_p9x19nade"
-- end

-- One note about conversion kits (especially to/from DMR's) is that shield and enemy piercing gets iffy
-- if you try to apply that to a weaponmod that isn't of the "ammo" type.

-- This is something you will see a lot. Any weapon mod that shouldn't have any stat changes (grips, front guards etc) should have its stats cloned from the "nostats" table.
-- self.parts.wpn_fps_pis_glawk_gr_pachmayr.stats = deep_clone(nostats)

-- Silencers are another common feature. Clone their stats from the most appropriate silencer preset (depending on size) and also clone the silencer custom stats.
-- self.parts.wpn_fps_pis_hl1g_suppress.custom_stats = silencercustomstats
-- self.parts.wpn_fps_pis_hl1g_suppress.stats = deep_clone(silstatsconc1)

-- Barrels is something you see often, these also have presets. There's long/longer, short/shorter, etc.
-- m1 and m2 are long/longer, p1 and p2 are short/shorter.
-- There's more, you can find them further up in this file.
-- self.parts.wpn_fps_ass_myar_barrel.stats = deep_clone(barrel_m1)

-- For anything else (such as sights) you'll just have to look at other weaponmods added in this file.
-- The most useful ones for you to look at will probably be other custom ones, but vanilla mods might also give you some insight.

-- For custom weapons that have additional tweakdata in weapontweakdata or weaponfactorytweakdata, sometimes their code runs after InF does.
-- The best way to fix this is to remove their PostHook using Hooks:RemovePostHook("hook_id")
-- If that hook normally does some required setup work (such as mod compatibility or custom attachment points) then please do so in your code as well.
-- A delayed call can also be done to fix the tweakdata but this is incredibly unreliable.

-- Finally, please use a code editor that can spot and highlight syntax errors for you. Test it out and make sure it catches errors.
-- Visual Studio Code has a few addons that merely highlight Lua syntax, but there are others that also highlight syntax errors. Get one of those.

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

	-- Why did this bit of code below exist?
	-- It breaks all angled sights (giving them +concealment)
	-- And sightlist already exists anyway.

	-- add possible sights to list of parts for sniper rifles to override
	--[[
	for a, part in pairs(parts_with_data) do
		-- do not adjust concealments of parts that already have sniper-adjusted concealment
		local has_part = nil
		for b, snppart in pairs(sniper_concealment_parts) do
			if snppart[1] == part then
				has_part = true
				break
			end
		end
		if not has_part and self.parts[part].pcs then
			table.insert(sightlist, part)
		end
	end
	]]

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

-- Don't touch this, this should be the last line in the weaponfactorytweakdata init hook
-- Enables better compatibility with other mods if they choose to override something InF does
Hooks:Call("inf_weaponfactorytweak_initcomplete", self)

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

	for a, id in pairs(self) do
		--
	end

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

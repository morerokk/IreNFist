_G.InFmenu = _G.InFmenu or {}
InFmenu._path = ModPath
InFmenu._data_path = SavePath .. 'infsave.txt'
InFmenu.settings = InFmenu.settings or {
	allpenwalls = true,
	reloadbreaksads = true,
	disable_autoreload = true,
	goldeneye = 1,

	rainbowassault = true,
	skulldozersahoy = 2,
	sanehp = true,
	copfalloff = true,
	copmiss = true,

	runkick = false,
	kickyeet = 1,
	slidestealth = 2,
	slideloud = 3,
	slidewpnangle = 15,
	wallrunwpnangle = 15,
	dashcontrols = 4,

	txt_wpnname = 2
}

function InFmenu:Save()
	local file = io.open(InFmenu._data_path, 'w+')
	if file then
		file:write(json.encode(InFmenu.settings))
		file:close()
	end
end

function InFmenu:Load()
	local file = io.open(InFmenu._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			InFmenu.settings[k] = v
		end
		file:close()
	end
end

InFmenu.Load()
-- generate save data even if nobody ever touches the mod options menu
InFmenu.Save()





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

InFmenu.rtable = {}
InFmenu.rstance = {}
InFmenu.wpnvalues = {}

InFmenu.rtable.lrifle = {
	{0.5, 0.5, -0.2, -0.2},
	{0.6, 0.6, -0.2, -0.2},
	{0.7, 0.7, -0.3, -0.3},
	{0.8, 0.8, -0.3, -0.3},
	{0.9, 0.9, -0.3, -0.3},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.1, 1.1, -0.5, -0.5},
	{1.2, 1.2, -0.5, 0.5},
	{1.3, 1.3, -0.5, 0.5},
	{1.3, 1.3, -0.2, -0.2}, -- loop
	{1.3, 1.3, 0.1, 0.1},
	{1.3, 1.3, 0.5, 0.5},
	{1.3, 1.3, 0.5, 0.5},
	{1.3, 1.3, 0.5, 0.5},
	{1.3, 1.3, 0.2, 0.2},
	{1.3, 1.3, -0.1, -0.1},
	{1.3, 1.3, -0.5, -0.5},
	{1.3, 1.3, -0.5, -0.5},
	{1.3, 1.3, -0.5, -0.5}
}
InFmenu.rtable.carbine = deep_clone(InFmenu.rtable.lrifle)

InFmenu.rtable.hrifle = {
	{0.5, 0.5, -0.2, -0.2},
	{0.6, 0.6, -0.2, -0.2},
	{0.7, 0.7, -0.2, -0.2},
	{0.8, 0.8, -0.2, -0.2},
	{0.9, 0.9, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.2, 1.2, -0.2, -0.2},
	{1.2, 1.2, 0.2, 0.2}, -- loop
	{1.2, 1.2, 0.4, 0.4},
	{1.3, 1.3, 0.5, 0.5},
	{1.3, 1.3, 0.5, 0.5},
	{1.2, 1.2, -0.2, -0.2},
	{1.2, 1.2, -0.4, -0.4},
	{1.3, 1.3, -0.5, -0.5},
	{1.3, 1.3, -0.5, -0.5}
}
InFmenu.rtable.mrifle = deep_clone(InFmenu.rtable.hrifle)
InFmenu.rtable.mcarbine = deep_clone(InFmenu.rtable.hrifle)

InFmenu.rtable.dmr = {
	{1.0, 1.0, 0.2, -0.2},
	{1.0, 1.0, 0.2, -0.2},
	{1.0, 1.0, 0.2, -0.2},
	{1.0, 1.0, 0.2, -0.2},
	{1.0, 1.0, 0.4, -0.4},
	{1.0, 1.0, 0.4, -0.4},
	{1.0, 1.0, 0.4, -0.4},
	{1.2, 1.2, 0.2, -0.2},
	{1.2, 1.2, 0.2, -0.2}, -- loop
	{1.2, 1.2, 0.4, -0.4},
	{1.3, 1.3, 0.5, -0.5},
	{1.3, 1.3, 0.5, -0.5},
	{1.2, 1.2, 0.2, -0.2},
	{1.2, 1.2, 0.4, -0.4},
	{1.3, 1.3, 0.5, -0.5},
	{1.3, 1.3, 0.5, -0.5}
}
InFmenu.rtable.ldmr = deep_clone(InFmenu.rtable.dmr)

InFmenu.rtable.shotgun = {
	{1.0, 1.0, 0.35, -0.35},
	{1.0, 1.0, 0.35, -0.35},
	{1.1, 1.1, 0.50, -0.40},
	{1.2, 1.2, 0.70, -0.55},
	{1.3, 1.3, 0.90, -0.60},
	{1.4, 1.4, 1.20, -0.70}
}

InFmenu.rtable.lmg = {
	{0.6, 0.6, -0.3, -0.3},
	{0.6, 0.6, -0.3, -0.3},
	{0.6, 0.6, -0.3, -0.3},
	{0.6, 0.6, -0.1, -0.1},
	{0.8, 0.8, 0.2, 0.2},
	{0.8, 0.8, 0.4, 0.4},
	{0.8, 0.8, 0.4, 0.4},
	{0.8, 0.8, 0.4, 0.4},
	{1.0, 1.0, -0.2, -0.2}, -- loop
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5}
}

InFmenu.rtable.lightpis = {
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, 0.2},
	{1.0, 1.0, -0.2, 0.2},
	{1.0, 1.0, -0.1, -0.1}, -- loop
	{1.0, 1.0, 0.0, 0.0},
	{1.0, 1.0, 0.3, 0.3},
	{1.0, 1.0, 0.3, 0.3},
	{1.0, 1.0, 0.3, 0.3},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, -0.0, -0.0},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3}
}

InFmenu.rtable.mediumpis = InFmenu.rtable.lightpis

InFmenu.rtable.heavypis = {
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, 0.1, 0.1},
	{1.2, 1.2, -0.2, -0.2}, -- loop
	{1.2, 1.2, -0.4, -0.4},
	{1.2, 1.2, -0.2, -0.2},
	{1.2, 1.2, 0.4, 0.4},
	{1.2, 1.2, -0.2, -0.2},
	{1.2, 1.2, -0.4, -0.4}
}
InFmenu.rtable.supermediumpis = InFmenu.rtable.heavypis

InFmenu.rtable.shortsmg = InFmenu.rtable.lrifle

InFmenu.rtable.longsmg = InFmenu.rtable.lrifle

--[[
InFmenu.rtable.akimbo = {
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.7, -0.7},
	{2.0, 2.0, 0.5, 0.5}, -- loop
	{2.0, 2.0, 1.2, 0.7},
	{2.0, 2.0, 1.2, 0.7},
	{2.0, 2.0, 1.2, 0.7},
	{2.0, 2.0, 0.5, 0.5},
	{2.0, 2.0, -0.2, -0.2},
	{2.0, 2.0, -1.2, -1.2},
	{2.0, 2.0, -1.2, -1.2},
	{2.0, 2.0, -1.2, -1.2}
}
--]]

InFmenu.rtable.minigun = {
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.3, -0.3},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.4, -0.4},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.5, 0.5},
	{1.0, 1.0, -0.2, -0.2}, -- loop
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, -0.2, -0.2},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.1, 0.1},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.5, 0.5},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, 0.2, 0.2},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.1, -0.1},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5},
	{1.0, 1.0, -0.5, -0.5}
}

InFmenu.rtable.norecoil = {
	{0, 0, 0, 0},
	{0, 0, 0, 0}
}

InFmenu.rtable.snp = {
	{1.25, 1.25, 1.0, -1.0},
	{1.25, 1.25, 1.0, -1.0}
}


-- recoil by stance
InFmenu.rstance.lrifle = {
	standing = {1.2, 1.2, 0.8, 0.8},
	crouching = {1.0, 1.0, 0.7, 0.7},
	steelsight = {0.6, 0.6, 0.5, 0.5}
}
InFmenu.rstance.carbine = InFmenu.rstance.lrifle
InFmenu.rstance.hrifle = InFmenu.rstance.lrifle
InFmenu.rstance.mrifle = InFmenu.rstance.hrifle
InFmenu.rstance.mcarbine = InFmenu.rstance.hrifle

InFmenu.rstance.shortsmg = kick_mult(InFmenu.rstance.lrifle, 1, 0.8, 1, 0.8, 1, 0.8)
InFmenu.rstance.longsmg = InFmenu.rstance.shortsmg

InFmenu.rstance.dmr = {
	standing = {1.5, 1.5, 0.8, 0.8},
	crouching = {1.3, 1.3, 0.6, 0.6},
	steelsight = {1.0, 1.0, 0.3, 0.3}
}
InFmenu.rstance.ldmr = {
	standing = {1.3, 1.3, 0.7, 0.7},
	crouching = {1.2, 1.2, 0.55, 0.55},
	steelsight = {0.9, 0.9, 0.25, 0.25}
}

InFmenu.rstance.snp = {
	standing = {1.5, 1.5, 0.8, 0.8},
	crouching = {1.3, 1.3, 0.6, 0.6},
	steelsight = {1.0, 1.0, 0.3, 0.3}
}

InFmenu.rstance.lightpis = {
	standing = {1.2, 1.2, 1.0, 1.0},
	crouching = {1.0, 1.0, 0.9, 0.9},
	steelsight = {0.5, 0.5, 0.5, 0.5}
}

InFmenu.rstance.mediumpis = {
	standing = {1.2, 1.2, 1.0, 1.0},
	crouching = {1.0, 1.0, 0.8, 0.8},
	steelsight = {0.7, 0.7, 0.6, 0.6}
}
InFmenu.rstance.supermediumpis = deep_clone(InFmenu.rstance.mediumpis)

InFmenu.rstance.heavypis = {
	standing = {3.0, 3.0, 1.6, 1.6},
	crouching = {2.6, 2.6, 1.2, 1.2},
	steelsight = {1.6, 1.6, 0.6, 0.6}
}

InFmenu.rstance.shotgun = {
	standing = {2.5, 2.5, 2.2, 2.2},
	crouching = {2.3, 2.3, 2.1, 2.1},
	steelsight = {1.8, 1.8, 1.6, 1.6}
}

InFmenu.rstance.lmg = {
	standing = {1.0, 1.0, 0.4, 0.4},
	crouching = {0.8, 0.8, 0.3, 0.3},
	steelsight = {0.6, 0.6, 0.25, 0.25}
}

InFmenu.rstance.minigun = {
	standing = {0.28, 0.28, 0.12, 0.12},
	crouching = {0.24, 0.24, 0.11, 0.11},
	steelsight = {0.20, 0.20, 0.10, 0.10}
}
--[[
InFmenu.rstance.minigun = {
	standing = {0.35, 0.35, 0.15, 0.15},
	crouching = {0.30, 0.30, 0.13, 0.13},
	steelsight = {0.25, 0.25, 0.12, 0.12}
}
--]]

InFmenu.rstance.one = {
	standing = {1, 1, 1, 1},
	crouching = {1, 1, 1, 1},
	steelsight = {1, 1, 1, 1}
}

InFmenu.rstance.norecoil = {
	standing = {0, 0, 0, 0},
	crouching = {0, 0, 0, 0},
	steelsight = {0, 0, 0, 0}
}




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
	self[wpn].price = 0
	self[wpn].BURST_FIRE = false
	self[wpn].autohit.MIN_RATIO = 0
	self[wpn].autohit.MAX_RATIO = 0
	self[wpn].autohit.INIT_RATIO = 0
	--self[wpn].aim_assist = {
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


InFmenu.wpnvalues.lrifle = {}
InFmenu.wpnvalues.lrifle.damage = 55
InFmenu.wpnvalues.lrifle.spread = 81
InFmenu.wpnvalues.lrifle.recoil = 71
InFmenu.wpnvalues.lrifle.armor_piercing_chance = 0.75
InFmenu.wpnvalues.lrifle.recoil_loop_point = 12
InFmenu.wpnvalues.lrifle.ammo = 180
InFmenu.wpnvalues.lrifle_gl = deep_clone(InFmenu.wpnvalues.lrifle)
InFmenu.wpnvalues.lrifle_gl.ammo = 120
InFmenu.wpnvalues.mrifle = {}
InFmenu.wpnvalues.mrifle.damage = 75
InFmenu.wpnvalues.mrifle.spread = 81
InFmenu.wpnvalues.mrifle.recoil = 61
InFmenu.wpnvalues.mrifle.armor_piercing_chance = 0.67
InFmenu.wpnvalues.mrifle.recoil_loop_point = 9
InFmenu.wpnvalues.mrifle.ammo = 120
InFmenu.wpnvalues.mrifle_gl = deep_clone(InFmenu.wpnvalues.mrifle)
InFmenu.wpnvalues.mrifle_gl.ammo = 80
InFmenu.wpnvalues.hrifle = {}
InFmenu.wpnvalues.hrifle.damage = 90
InFmenu.wpnvalues.hrifle.spread = 81
InFmenu.wpnvalues.hrifle.recoil = 56
InFmenu.wpnvalues.hrifle.armor_piercing_chance = 0.75
InFmenu.wpnvalues.hrifle.recoil_loop_point = 9
InFmenu.wpnvalues.hrifle.ammo = 120
InFmenu.wpnvalues.hrifle_gl = deep_clone(InFmenu.wpnvalues.hrifle)
InFmenu.wpnvalues.hrifle_gl.ammo = 80
InFmenu.wpnvalues.ldmr = {}
InFmenu.wpnvalues.ldmr.damage = 120 -- bring this up to 130 if i ever use the tankier death sentence health values
InFmenu.wpnvalues.ldmr.spread = 81
InFmenu.wpnvalues.ldmr.recoil = 51
InFmenu.wpnvalues.ldmr.armor_piercing_chance = 1
InFmenu.wpnvalues.ldmr.recoil_loop_point = 9
InFmenu.wpnvalues.ldmr.rof = 600
InFmenu.wpnvalues.ldmr.ammo = 80
InFmenu.wpnvalues.dmr = {}
InFmenu.wpnvalues.dmr.damage = 170
InFmenu.wpnvalues.dmr.spread = 86
InFmenu.wpnvalues.dmr.recoil = 41
InFmenu.wpnvalues.dmr.armor_piercing_chance = 1
InFmenu.wpnvalues.dmr.recoil_loop_point = 9
InFmenu.wpnvalues.dmr.rof = 420
InFmenu.wpnvalues.dmr.ammo = 50


-- mag presets
-- output: mag% * reload%
InFmenu.wpnvalues.reload = {}
-- 0.5
InFmenu.wpnvalues.reload.mag_17 = {reload = 200}
-- 0.6875
InFmenu.wpnvalues.reload.mag_25 = {reload = 175}
-- 0.767
InFmenu.wpnvalues.reload.mag_33 = {reload = 130}
-- 0.825
InFmenu.wpnvalues.reload.mag_50 = {reload = 65}
-- 0.858
InFmenu.wpnvalues.reload.mag_66 = {reload = 30}
-- 0.9
InFmenu.wpnvalues.reload.mag_75 = {reload = 20}
-- mag100 = 1
-- 1.1
InFmenu.wpnvalues.reload.mag_125 = {reload = -12}
-- 1.1305
InFmenu.wpnvalues.reload.mag_133 = {reload = -15}
-- 1.2
InFmenu.wpnvalues.reload.mag_150 = {reload = -20}
-- 1.3
InFmenu.wpnvalues.reload.mag_200 = {reload = -35}
--
InFmenu.wpnvalues.reload.mag_250 = {reload = -40}
-- 1.65
InFmenu.wpnvalues.reload.mag_300 = {reload = -45}

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

-- PISTOLS
InFmenu.wpnvalues.lightpis = {}
InFmenu.wpnvalues.lightpis.damage = 55
InFmenu.wpnvalues.lightpis.spread = 71
InFmenu.wpnvalues.lightpis.recoil = 71
InFmenu.wpnvalues.lightpis.armor_piercing_chance = 0.64
InFmenu.wpnvalues.lightpis.recoil_loop_point = 6
InFmenu.wpnvalues.lightpis.ammo = 150
InFmenu.wpnvalues.lightpis.rof = 600
InFmenu.wpnvalues.mediumpis = {}
InFmenu.wpnvalues.mediumpis.damage = 85
InFmenu.wpnvalues.mediumpis.spread = 71
InFmenu.wpnvalues.mediumpis.recoil = 61
InFmenu.wpnvalues.mediumpis.armor_piercing_chance = 0.75
InFmenu.wpnvalues.mediumpis.recoil_loop_point = 6
InFmenu.wpnvalues.mediumpis.ammo = 80
InFmenu.wpnvalues.mediumpis.rof = 600
InFmenu.wpnvalues.supermediumpis = {}
InFmenu.wpnvalues.supermediumpis.damage = 110
InFmenu.wpnvalues.supermediumpis.spread = 71
InFmenu.wpnvalues.supermediumpis.recoil = 51
InFmenu.wpnvalues.supermediumpis.armor_piercing_chance = 0.75
InFmenu.wpnvalues.supermediumpis.recoil_loop_point = 3
InFmenu.wpnvalues.supermediumpis.ammo = 60
InFmenu.wpnvalues.supermediumpis.rof = 600
InFmenu.wpnvalues.heavypis = {}
InFmenu.wpnvalues.heavypis.damage = 170
InFmenu.wpnvalues.heavypis.spread = 71
InFmenu.wpnvalues.heavypis.recoil = 46
InFmenu.wpnvalues.heavypis.armor_piercing_chance = 1
InFmenu.wpnvalues.heavypis.recoil_loop_point = 3
InFmenu.wpnvalues.heavypis.ammo = 42
InFmenu.wpnvalues.heavypis.rof = 300

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

		if self:has_in_table(subtype, "dmg_mid") then
			self[wpn].stats.damage = 43 -- 215 --38 -- 190
			self[wpn].stats.recoil = 41
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 1.25
		end
		if self:has_in_table(subtype, "dmg_light") then
			self[wpn].stats.damage = 38 -- 190
			self[wpn].stats.recoil = 56
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.25
			self[wpn].shake.fire_steelsight_multiplier = 1.25
		end
		if self:has_in_table(subtype, "dmg_vlight") then
			self[wpn].stats.damage = 36 -- 180
			self[wpn].stats.recoil = 51
			self[wpn].AMMO_MAX = 48
			self[wpn].AMMO_PICKUP = self:_pickup_chance(48, 1)
			self[wpn].shake.fire_multiplier = 1.00
			self[wpn].shake.fire_steelsight_multiplier = 1.00
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
	end
	if self:has_category(wpn, "akimbo") then
		self:inf_init_akimbo(wpn, "shotgun", 0)
	end
end

-- SUBMACHINE GUNS
InFmenu.wpnvalues.shortsmg = {}
InFmenu.wpnvalues.shortsmg.damage = 45
InFmenu.wpnvalues.shortsmg.spread = 51
InFmenu.wpnvalues.shortsmg.recoil = 81
InFmenu.wpnvalues.shortsmg.armor_piercing_chance = 0.60
InFmenu.wpnvalues.shortsmg.recoil_loop_point = 12
InFmenu.wpnvalues.shortsmg.ammo = 150
InFmenu.wpnvalues.longsmg = {}
InFmenu.wpnvalues.longsmg.damage = 50
InFmenu.wpnvalues.longsmg.spread = 61
InFmenu.wpnvalues.longsmg.recoil = 76
InFmenu.wpnvalues.longsmg.armor_piercing_chance = 0.60 -- not used below
InFmenu.wpnvalues.longsmg.recoil_loop_point = 12 -- not used below
InFmenu.wpnvalues.longsmg.ammo = 120
InFmenu.wpnvalues.carbine = {}
InFmenu.wpnvalues.carbine.damage = 55
InFmenu.wpnvalues.carbine.spread = 66
InFmenu.wpnvalues.carbine.recoil = 71
InFmenu.wpnvalues.carbine.armor_piercing_chance = 0.75
InFmenu.wpnvalues.carbine.recoil_loop_point = 12
InFmenu.wpnvalues.carbine.ammo = 120
InFmenu.wpnvalues.mcarbine = {}
InFmenu.wpnvalues.mcarbine.damage = 75
InFmenu.wpnvalues.mcarbine.spread = 66
InFmenu.wpnvalues.mcarbine.recoil = 66
InFmenu.wpnvalues.mcarbine.armor_piercing_chance = 0.67
InFmenu.wpnvalues.mcarbine.recoil_loop_point = 9
InFmenu.wpnvalues.mcarbine.ammo = 90
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
	if subtype == "medium" then
		self[wpn].pen_wall_dist_mult = 0.50
		self[wpn].stats.damage = 65
		self[wpn].stats.recoil = 56
		self[wpn].armor_piercing_chance = 0.80
		self[wpn].AMMO_MAX = 300
		self[wpn].AMMO_PICKUP = self:_pickup_chance(250, 1)
	elseif subtype == "heavy" then
		self[wpn].pen_wall_dist_mult = 0.66
		self[wpn].stats.damage = 75
		self[wpn].stats.recoil = 46
		self[wpn].armor_piercing_chance = 0.80
		self[wpn].AMMO_MAX = 200
		self[wpn].AMMO_PICKUP = self:_pickup_chance(167, 1)
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
	end
end

-- GRENADE LAUNCHERS
function WeaponTweakData:inf_init_gl(wpn, subtype)
	self[wpn].recoil_table = InFmenu.rtable.shotgun
	self[wpn].kick = InFmenu.rstance.shotgun
	self[wpn].spread.steelsight = 0.20
	self[wpn].spread.moving_steelsight = 0.20
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
	if not self:has_category(wpn, "smg") then
		self[wpn].BURST_FIRE = 2
	end
	if delaytime then
		self[wpn].recoil_apply_delay = delaytime or 0 --0.07
	end
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
end




local old_new_wep_init = WeaponTweakData._init_new_weapons
function WeaponTweakData:_init_new_weapons(...)
	old_new_wep_init(self,...)

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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.ak74.attachment_points then
		self.ak74.attachment_points = {}
	end
	table.list_append(self.ak74.attachment_points, {
		{
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	self:SetupAttachmentPoint("aug", {
		name = "nowhere",
		base_a_obj = "a_o",
		position = Vector3(0, -1000, -1000),
		rotation = Rotation(0, 0, 0)
	})
end


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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.akm.attachment_points then
		self.akm.attachment_points = {}
	end
	table.list_append(self.akm.attachment_points, {
		{
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		}
	})
end


	self:copy_sdescs("akm_gold", "akm")
	self:copy_stats("akm_gold", "akm")
	self.akm_gold.stats.concealment = self.akm.stats.concealment - 2
	self:copy_timers("akm_gold", "akm")
	self.akm_gold.price = 5*1000000
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.akm_gold.attachment_points then
		self.akm_gold.attachment_points = {}
	end
	table.list_append(self.akm_gold.attachment_points, {
		{
			name = "a_m_dmr",
			base_a_obj = "a_m",
			position = Vector3(0, 2, 0),
			rotation = Rotation(0, 0, 0)
		}
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
	self.g3.not_empty_reload_speed_mult = 0.90
	self.g3.timers.reload_not_empty = 1.4
	self.g3.timers.reload_not_empty_end = 0.6 -- 2.22
	self.g3.empty_reload_speed_mult = 1.0
	self.g3.timers.reload_empty = 1.9
	self.g3.timers.reload_empty_end = 1.1 -- 3.00
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
		self.g3.not_empty_reload_speed_mult = 1.60
		self.g3.timers.reload_not_empty = 2.5
		self.g3.timers.reload_not_empty_end = 1.0 -- 2.19
		self.g3.empty_reload_speed_mult = 1.55
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
	self.asval.not_empty_reload_speed_mult = 1.40
	self.asval.timers.reload_not_empty = 2.5
	self.asval.timers.reload_not_empty_end = 0.50 -- 2.14
	self.asval.empty_reload_speed_mult = 1.55
	self.asval.timers.reload_empty = 3.2
	self.asval.timers.reload_empty_end = 0.70 -- 2.52
	--self.asval.price = 500*1000
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.asval.attachment_points then
		self.asval.attachment_points = {}
	end
	table.list_append(self.asval.attachment_points, {
		{
			name = "a_o_notugly",
			base_a_obj = "a_o",
			position = Vector3(0, 2, -3),
			rotation = Rotation(0, 0, 0)
		},
		{
			name = "a_infrail",
			base_a_obj = "a_o",
			position = Vector3(0, 2, -2.75),
			rotation = Rotation(0, 0, 0)
		}
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
	--self.new_m14.CAN_TOGGLE_FIREMODE = false
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.winchester1874.attachment_points then
		self.winchester1874.attachment_points = {}
	end
	table.list_append(self.winchester1874.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 49, 4),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.msr.attachment_points then
		self.msr.attachment_points = {}
	end
	table.list_append(self.msr.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 67, 6),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.model70.attachment_points then
		self.model70.attachment_points = {}
	end
	table.list_append(self.model70.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 55.5, 3.5),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.wa2000.attachment_points then
		self.wa2000.attachment_points = {}
	end
	table.list_append(self.wa2000.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 50, 0),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.r93.attachment_points then
		self.r93.attachment_points = {}
	end
	table.list_append(self.r93.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 47, 4),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.mosin.attachment_points then
		self.mosin.attachment_points = {}
	end
	table.list_append(self.mosin.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 70, 4),
			rotation = Rotation(0, 0, 0)
		}
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.desertfox.attachment_points then
		self.desertfox.attachment_points = {}
	end
	table.list_append(self.desertfox.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 30, 5),
			rotation = Rotation(0, 0, 0)
		}
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

	self.r700.sdesc1 = "caliber_r762x51"
	self.r700.sdesc2 = "action_bolt"
	self.r700.CLIP_AMMO_MAX = 10
	self.r700.stats.concealment = 17
	self.r700.not_empty_reload_speed_mult = 1.40
	self.r700.timers.reload_not_empty = 4.8
	self.r700.timers.reload_not_empty_end = 0.70 -- 2.51
	self.r700.empty_reload_speed_mult = 1.40
	self.r700.timers.reload_empty = 5.5
	self.r700.timers.reload_empty_end = 0.50 -- 3.09
	--self.r700.price = 300*1000
	self:apply_standard_bipod_stats("r700")
	self.r700.custom_bipod = true
	self.r700.bipod_weapon_translation = Vector3(-2, -6, -4)
	pivot_shoulder_translation = Vector3(20.555, 48.5, -8.55)
	pivot_shoulder_rotation = Rotation(0.1, -0.1, 0.6)
	pivot_head_translation = Vector3(10, 33, -4)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.r700.stances.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.r700.stances.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.r700.stances.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.r700.use_custom_anim_state = true
	self.r700.bipod_rof_mult = 1.25
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.r700.attachment_points then
		self.r700.attachment_points = {}
	end
	table.list_append(self.r700.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 47, 4),
			rotation = Rotation(0, 0, 0)
		}
	})
end

	self.tec9.sdesc1 = "caliber_p9x19"
	self.tec9.sdesc2 = "action_blowback"
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
	--self.coalprimary.stats.concealment = 24
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
	--self.new_mp5primary.stats.concealment = 24
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
	self.shepheardprimary.stats.concealment = 25
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
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
	--self.schakalprimary.stats.concealment = 24
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
	self.m1928.stats.concealment = 22
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
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
	self.sparrow.sdesc1 = "caliber_p9x19"
	self.sparrow.sdesc2 = "action_shortrecoil"
	self.sparrow.stats.concealment = 30
	self.sparrow.CLIP_AMMO_MAX = 16
	self.sparrow.AMMO_MAX = 144
	self.sparrow.AMMO_PICKUP = self:_pickup_chance(144, 1)
	self:copy_timers("sparrow", "b92fs")
	--self.sparrow.price = 150*1000
	self:copy_sdescs("x_sparrow", "sparrow", true)
	self.x_sparrow.stats.concealment = 30
	self.x_sparrow.CLIP_AMMO_MAX = self.sparrow.CLIP_AMMO_MAX * 2
	self.x_sparrow.AMMO_MAX = 192
	self.x_sparrow.AMMO_PICKUP = self:_pickup_chance(192, 1)
	--self.x_sparrow.price = self.sparrow.price
	self:copy_timers("x_sparrow", "x_b92fs")


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

	-- Igor/Stechkin
	self.stech.sdesc1 = "caliber_p9x19"
	self.stech.sdesc2 = "action_blowback"
	self.stech.CLIP_AMMO_MAX = 20
	self.stech.AMMO_MAX = 160
	self.stech.AMMO_PICKUP = self:_pickup_chance(160, 1)
	self:copy_timers("stech", "b92fs")

	self.x_stech.sdesc1 = "caliber_p9x19"
	self.x_stech.sdesc2 = "action_blowback"
	self.x_stech.CLIP_AMMO_MAX = 40
	self.x_stech.AMMO_MAX = 180
	self.x_stech.AMMO_PICKUP = self:_pickup_chance(180, 1)
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
if BeardLib.Utils:FindMod("GSPS Various Attachment") then
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
	self.m60.timers.reload_not_empty = 9.1
	self.m60.timers.reload_not_empty_end = 1.0 -- 5.41
	self.m60.timers.reload_empty = 9.1
	self.m60.timers.reload_empty_end = 1.0 -- 5.41
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





	self.gre_m79.sdesc1 = "caliber_g40mm"
	self.gre_m79.sdesc2 = "action_breakopen"
	self.gre_m79.stats.concealment = 20
	self.gre_m79.stats.damage = 60.0
	self.gre_m79.AMMO_PICKUP = {1338, 20}
	self.gre_m79.reload_speed_mult = 1.00
	self.gre_m79.timers.reload_not_empty = 2.40
	self.gre_m79.timers.reload_not_empty_end = 0.80 -- 3.20
	self.gre_m79.timers.reload_empty = 2.40
	self.gre_m79.timers.reload_empty_end = 0.80 -- 3.20


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
	self.china.AMMO_MAX = 3
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
	self.slap.AMMO_MAX = 3
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













	-- CUSTOM WEAPONS

	-- Vikhr/SR Einheri
if BeardLib.Utils:FindMod("SR-3M Vikhr") then
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
if BeardLib.Utils:FindMod("cz") then
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

	-- Ha ha, the CZ 75 is now also sorta in the game, close enough
	self:inf_init("czech", "pistol", nil)
	self.czech.sdesc1 = "caliber_p9x19"
	self.czech.sdesc2 = "action_shortrecoil"
	self:copy_timers("czech", "b92fs")
	self.czech.stats.concealment = 30
	self.czech.AMMO_MAX = 144
	self.czech.AMMO_PICKUP = self:_pickup_chance(144, 1)

	self:inf_init("x_czech", "pistol", nil)
	self:copy_sdescs("x_czech", "czech", true)
	self.x_czech.stats.concealment = 30
	self.x_czech.AMMO_MAX = 180
	self.x_czech.AMMO_PICKUP = self:_pickup_chance(180, 1)
	self:copy_timers("x_czech", "x_b92fs")

	-- MA DEUCE
if BeardLib.Utils:FindMod("M2HB_HMG") then
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
if BeardLib.Utils:FindMod("Mateba Model 6 Unica") then
	self:inf_init("unica6", "pistol", "heavy")
	self.unica6.sdesc1 = "caliber_p357"
	self.unica6.sdesc2 = "action_mateba"
	self.unica6.chamber = 0
	self.unica6.stats.concealment = 28
	self:copy_timers("unica6", "new_raging_bull")
end


if BeardLib.Utils:FindMod("Contender Special") then
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

if BeardLib.Utils:FindMod("m1c") then
	self:inf_init("m1c", "ar", {"ldmr"})
	self.m1c.sdesc1 = "caliber_r30carbine"
	self.m1c.sdesc2 = "action_gasshort"
	self.m1c.AMMO_MAX = 90
	self.m1c.AMMO_PICKUP = self:_pickup_chance(90, 1)
	self:copy_timers("m1c", "new_m14")
	self.m1c.reload_speed_mult = self.m1c.reload_speed_mult * self:convert_reload_to_mult("mag_75")
	self.m1c.stats.concealment = 23
end


if BeardLib.Utils:FindMod("Tokarev SVT-40") then
	self:inf_init("svt40", "ar", {"dmr"})
	self.svt40.sdesc1 = "caliber_r762x54r"
	self.svt40.sdesc2 = "action_gasshort"
	self:copy_timers("svt40", "siltstone")
	self.svt40.stats.concealment = 23
end

if BeardLib.Utils:FindMod("AN-94 AR") then
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

if BeardLib.Utils:FindMod("tilt") then
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

if BeardLib.Utils:FindMod("Makarov Pistol") then
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


if BeardLib.Utils:FindMod("Remington Various Attachment") then
	Hooks:RemovePostHook("R870AttachModInit")

	-- removed the stat fix (bitch i got my own stats)
	if not self.r870.attachment_points then
		self.r870.attachment_points = {}
	end
		table.list_append(self.r870.attachment_points, {
			{
				name = "a_o_mcs",
				base_a_obj = "a_o",
				position = Vector3(0, 5, -0.35),
				rotation = Rotation(0, 0, 0)
			},
			{
				name = "a_ns_heat",
				base_a_obj = "a_ns",
				position = Vector3(0, 5, 0),
				rotation = Rotation(0, 0, 0)
			},
			{
				name = "a_fl_mcs",
				base_a_obj = "a_fl",
				position = Vector3(2.9, -5.8, 3.9),
				rotation = Rotation(0, 0, -90)
			}
		})

	if not self.serbu.attachment_points then
		self.serbu.attachment_points = {}
	end
		table.list_append(self.serbu.attachment_points, {
			{
				name = "a_fl_mcs",
				base_a_obj = "a_fl",
				position = Vector3(2.9, -5.8, 3.9),
				rotation = Rotation(0, 0, -90)
			},
			{
				name = "a_o_mcs",
				base_a_obj = "a_o",
				position = Vector3(0, 5, -0.35),
				rotation = Rotation(0, 0, 0)
			}
		})
end


if BeardLib.Utils:FindMod("Winchester Model 1912") then
	self:inf_init("m1912", "shotgun", {"rof_slow", "range_slowpump"})
	self.m1912.sdesc1 = "caliber_s12g"
	self.m1912.sdesc2 = "action_pump"
	self.m1912.AMMO_MAX = 40
	self.m1912.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self.m1912.stats.spread = self.m1912.stats.spread + 20
	self:copy_timers("m1912", "m37")
	self.m1912.stats.concealment = 19
end


if BeardLib.Utils:FindMod("KS-23") then
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

if BeardLib.Utils:FindMod("Marlin Model 1894 Custom") then
	InFmenu.has_secondary_sniper = true
	self:inf_init("m1894", "snp", nil)
	self.m1894.recategorize = "snp"
	self.m1894.sdesc1 = "caliber_p44"
	self.m1894.sdesc2 = "action_lever"
	self:copy_timers("m1894", "winchester1874")
	self.m1894.stats.damage = 56 -- 280
	self.m1894.stats.spread = self.m1894.stats.spread - 10
	self.m1894.stats.recoil = self.m1894.stats.recoil - 5
	--self.m1894.stats.concealment = 23
	--self.m1894.anim_speed_mult = 1.20
	--self.m1894.hipfire_uses_ads_anim = true
	self.m1894.AMMO_MAX = 24
	self.m1894.AMMO_PICKUP = self:_pickup_chance(24, 1)
end

-- primary SVU/SVU-T
if BeardLib.Utils:FindMod("svudragunov") then
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
if BeardLib.Utils:FindMod("SVU") then
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

if BeardLib.Utils:FindMod("Gewehr 43") then
	self:inf_init("g43", "ar", {"dmr"})
	self.g43.sdesc1 = "caliber_r792mauser"
	self.g43.sdesc2 = "action_gasshort"
	-- base 2.88/3.61
	self:copy_timers("g43", "fal")
	self.g43.reload_speed_mult = self.g43.reload_speed_mult * 0.90
	self.g43.stats.concealment = 20
end

if BeardLib.Utils:FindMod("Mosin Nagant M9130 Obrez") then
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

if BeardLib.Utils:FindMod("BAR LMG") then
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

if BeardLib.Utils:FindMod("QBZ-97B") then
	self:inf_init("qbz97b", "smg", {"range_carbine"})
	self.qbz97b.sdesc1 = "caliber_r556x45"
	self.qbz97b.sdesc2 = "action_pistonshort"
	self.qbz97b.fire_mode_data.fire_rate = 60/800
	self:copy_timers("qbz97b", "famas")
	self.qbz97b.stats.concealment = 25
end

if BeardLib.Utils:FindMod("Seburo M5") then
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

	self.seburo.attachment_points = {
		{
			name = "a_seburo5fl",
			base_a_obj = "a_fl",
			position = Vector3( 0, -1, -2.5 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5ns",
			base_a_obj = "a_ns", 
			position = Vector3( 0.1, -2, 0.1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5rds",
			base_a_obj = "a_rds", 
			position = Vector3( 0, 0, -1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_body",
			base_a_obj = "a_body", 
			position = Vector3( 0, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_sl",
			base_a_obj = "a_sl", 
			position = Vector3( 0, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_m",
			base_a_obj = "a_m", 
			position = Vector3( -0.35, 0, 0.35 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5ext_m",
			base_a_obj = "a_m", 
			position = Vector3( 0, -0.2, 0 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_bolt",
			base_a_obj = "a_bolt", 
			position = Vector3( 0.1, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		}
	}
	self.x_seburo.attachment_points = {
		{
			name = "a_seburo5fl",
			base_a_obj = "a_fl",
			position = Vector3( 0, -1, -2.5 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5ns",
			base_a_obj = "a_ns", 
			position = Vector3( 0.1, -2, 0.1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5rds",
			base_a_obj = "a_rds", 
			position = Vector3( 0, 0, -1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_body",
			base_a_obj = "a_body", 
			position = Vector3( 0, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_sl",
			base_a_obj = "a_sl", 
			position = Vector3( 0, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_m",
			base_a_obj = "a_m", 
			position = Vector3( -0.35, 0, 0.35 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5ext_m",
			base_a_obj = "a_m", 
			position = Vector3( 0, -0.2, 0 ), 
			rotation = Rotation( 0, 0, 0 )
		},
		{
			name = "a_seburo5re_bolt",
			base_a_obj = "a_bolt", 
			position = Vector3( 0.1, 0, 1 ), 
			rotation = Rotation( 0, 0, 0 )
		}
	}
end

if BeardLib.Utils:FindMod("HKG11") then
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

if BeardLib.Utils:FindMod("Beretta 93R") then
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
	self.beer.BURST_FIRE = 3
	self.beer.ADAPTIVE_BURST_SIZE = false
	self.beer.BURST_FIRE_RATE_MULTIPLIER = 1100/600
	self.beer.DELAYED_BURST_RECOIL = false
	self.beer.stats.spread = self.beer.stats.spread - 15
	self.beer.fire_mode_data.fire_rate = 60/1100
	self:copy_timers("beer", "b92fs")
	
	self:inf_init("x_beer", "pistol", nil)
	self.x_beer.sdesc1 = "caliber_p9x19"
	self.x_beer.sdesc2 = "action_shortrecoil"
	--self.x_beer.stats.concealment = 29
	self.x_beer.AMMO_MAX = 140
	self.x_beer.AMMO_PICKUP = self:_pickup_chance(140, 1)
	self.x_beer.BURST_FIRE = 3
	self.x_beer.ADAPTIVE_BURST_SIZE = false
	self.x_beer.BURST_FIRE_RATE_MULTIPLIER = 1100/600
	self.x_beer.DELAYED_BURST_RECOIL = false
	self.x_beer.stats.spread = self.x_beer.stats.spread - 15
	self.x_beer.fire_mode_data.fire_rate = 60/1100
	self:copy_timers("x_beer", "x_b92fs")

if BeardLib.Utils:FindMod("TOZ-34") then
	self:inf_init("toz34", "shotgun", {"dmg_heavy", "range_long", "rof_db"})
	self.toz34.sdesc1 = "caliber_s12g"
	self.toz34.sdesc2 = "action_breakou"
	self.toz34.stats.spread = self.toz34.stats.spread + 15
	self.toz34.stats.concealment = 21
	self.toz34.shake.fire_steelsight_multiplier = 0.25 -- fucking grip puts the hand in the way
	self:copy_timers("toz34", "b682")
	self.toz34.reload_speed_mult = self.toz34.reload_speed_mult * 0.95
end

if BeardLib.Utils:FindMod("TOZ-66") then
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
if BeardLib.Utils:FindMod("Akimbo TOZ-66") then
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
end

if BeardLib.Utils:FindMod("pdr") then
	Hooks:RemovePostHook("pdrModInit")
	self:inf_init("pdr", "smg", {"range_carbine"})
	self.pdr.sdesc1 = "caliber_r556x45"
	self.pdr.sdesc2 = "action_gasshort"
	self:copy_timers("pdr", "aug")
	self.pdr.stats.concealment = 23
end

if BeardLib.Utils:FindMod("Steyr AUG A3 9mm XS") then
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

if BeardLib.Utils:FindMod("L115") then
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.l115.attachment_points then
		self.l115.attachment_points = {}
	end
	table.list_append(self.l115.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 53, 4),
			rotation = Rotation(0, 0, 0)
		}
	})
end
end

if BeardLib.Utils:FindMod("Montana 5.56") then
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

if BeardLib.Utils:FindMod("Bren Ten") then
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


if BeardLib.Utils:FindMod("STG 44") then
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

if BeardLib.Utils:FindMod("HK G3A3 M203") then
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

if BeardLib.Utils:FindMod("AAC Honey Badger") then
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

if BeardLib.Utils:FindMod("af2011") then
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

if BeardLib.Utils:FindMod("STF-12") then
	self:inf_init("stf12", "shotgun", {"dmg_mid"})
	self.stf12.sdesc1 = "caliber_s12g"
	self.stf12.sdesc2 = "action_pump"
	self.stf12.stats.spread = self.stf12.stats.spread - 10
	self.stf12.stats.concealment = 23
	self:copy_timers("stf12", "r870")
end

if BeardLib.Utils:FindMod("CheyTac M200") then
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

if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.m200.attachment_points then
		self.m200.attachment_points = {}
	end
	table.list_append(self.m200.attachment_points, {
		{
			name = "a_nowhere",
			base_a_obj = "a_body",
			position = Vector3(0, -1000, -1000),
			rotation = Rotation(0, 0, 0)
		}
	})
end
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


if BeardLib.Utils:FindMod("Minebea SMG") then
	self:inf_init("minebea", "smg", nil)
	self.minebea.sdesc1 = "caliber_p9x19"
	self.minebea.sdesc2 = "action_blowback"
	self.minebea.chamber = 0
	--self.minebea.stats.concealment = 27
	self:copy_timers("minebea", "cobray")
	self.minebea.reload_speed_mult = self.minebea.reload_speed_mult * 1.15
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.minebea.attachment_points then
		self.minebea.attachment_points = {}
	end
	table.list_append(self.minebea.attachment_points, {
		{
			name = "a_o_notugly",
			base_a_obj = "a_o",
			position = Vector3(0, -22, -0.75),
			rotation = Rotation(0, 0, 0)
		},
		{
			name = "a_o_notugly_aimpoint",
			base_a_obj = "a_o",
			position = Vector3(0, -18, -0.75),
			rotation = Rotation(0, 0, 0)
		}
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

if BeardLib.Utils:FindMod("HX25 Handheld Grenade Launcher") then
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
if BeardLib.Utils:FindMod("amt") then
	self:inf_init("amt", "pistol", "heavy")
	self.amt.sdesc1 = "caliber_p44amp"
	self.amt.sdesc2 = "action_shortrecoil"
	self:copy_timers("amt", "deagle")
	self.amt.stats.concealment = 28
end

if BeardLib.Utils:FindMod("Zenith 10mm") then
	self:inf_init("zenith", "pistol", "supermedium")
	self.zenith.sdesc1 = "caliber_p10"
	self.zenith.sdesc2 = "action_shortrecoil"
	self:copy_timers("zenith", "lemming")
	self.zenith.reload_speed_mult = self.zenith.reload_speed_mult * self:convert_reload_to_mult("mag_66")
	--self.zenith.stats.concealment = 28
end

if BeardLib.Utils:FindMod("Widowmaker TX") then
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

if BeardLib.Utils:FindMod("DP12 Shotgun") then
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

if BeardLib.Utils:FindMod("Lahti L-35") then
	self:inf_init("l35", "pistol", "medium")
	self.l35.sdesc1 = "caliber_p9x19"
	self.l35.sdesc2 = "action_recoil"
	self:copy_timers("l35", "breech")
	--self.l35.stats.concealment = 29
end

if BeardLib.Utils:FindMod("OTs-14-4A Groza") then
	self:inf_init("ots_14_4a", "ar", {"medium"})
	self.ots_14_4a.sdesc1 = "caliber_r9x39"
	self.ots_14_4a.sdesc2 = "action_gas"
	self:copy_timers("ots_14_4a", "l85a2")
	self.ots_14_4a.stats.spread = self.ots_14_4a.stats.spread - 10
	self.ots_14_4a.stats.concealment = 25
	self.ots_14_4a.reload_speed_mult = self.ots_14_4a.reload_speed_mult * self:convert_reload_to_mult("mag_66")
DelayedCalls:Add("grozaakmagpoints", 0.50, function(self, params)
	table.list_append(tweak_data.weapon.ots_14_4a.attachment_points, {
		{
			name = "a_m_ak",
			base_a_obj = "a_m",
			position = Vector3(0, -1.25, 1),
			rotation = Rotation(0, 0, 0)
		},
		{
			name = "a_m_m4",
			base_a_obj = "a_m",
			position = Vector3(0, 0.5, 1),
			rotation = Rotation(0, 0, 0)
		}
	})
end)
end

if BeardLib.Utils:FindMod("MK18 Specialist") then
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

if BeardLib.Utils:FindMod("Lewis Gun") then
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

if BeardLib.Utils:FindMod("HK416") then
	self:inf_init("hk416", "ar", nil)
	self.hk416.sdesc1 = "caliber_r556x45"
	self.hk416.sdesc2 = "action_pistonshort"
	self:copy_timers("hk416", "new_m4")
	self.hk416.stats.concealment = 18
	 -- shift 3 left to actually visually confirm instead of just tilting for the sake of it
	self.hk416.reload_timed_stance_mod.empty.hip[1].translation = Vector3(-25, 0, -5)
	self.hk416.reload_timed_stance_mod.empty.ads[2].translation = Vector3(-13, -3, -15)
end

if BeardLib.Utils:FindMod("HK416C Standalone") then
	self:inf_init("drongo", "ar", nil)
	self.drongo.sdesc1 = "caliber_r556x45"
	self.drongo.sdesc2 = "action_pistonshort"
	self:copy_timers("drongo", "new_m4")
	self.drongo.stats.spread = self.drongo.stats.spread - 10
	self.drongo.stats.concealment = 21
	self.drongo.fire_mode_data.fire_rate = 60/800
end

if BeardLib.Utils:FindMod("HK417 Standalone") then
	self:inf_init("recce", "ar", {"heavy"})
	self.recce.sdesc1 = "caliber_r762x51"
	self.recce.sdesc2 = "action_pistonshort"
	self:copy_timers("recce", "contraband")
	self.recce.stats.concealment = 20
	self.recce.fire_mode_data.fire_rate = 60/600
	self.recce.FIRE_MODE = "auto"
end

if BeardLib.Utils:FindMod("acwr") then
	Hooks:RemovePostHook("acwrModInit")
	self.contraband_m203.weapon_hold = "contraband"
	self.contraband_m203.animations.reload_name_id = "contraband"

	self:inf_init("acwr2", "ar", nil)
	self.acwr2.sdesc1 = "caliber_r556x45"
	self.acwr2.sdesc2 = "action_gas"
	self.acwr2.fire_mode_data.fire_rate = 60/650
	self:copy_timers("acwr2", "new_m4")
	self.acwr2.stats.concealment = 22

	self:inf_init("acwr", "ar", {"has_gl"})
	self.acwr.sdesc1 = "caliber_r556x45"
	self.acwr.sdesc2 = "action_gas"
	self.acwr.sdesc3 = "misc_gl40x46mm"
	self.acwr.stats.concealment = 16
	self.acwr.fire_mode_data.fire_rate = 60/650
	self.acwr.FIRE_MODE = "auto"
	self:copy_timers("acwr", "contraband")
	--self.acwr.AMMO_MAX = 120
	--self.acwr.AMMO_PICKUP = self:_pickup_chance(120, 1)
end

if BeardLib.Utils:FindMod("SAI GRY") then
	self:inf_init("saigry", "ar", {"medium"})
	self.saigry.sdesc1 = "caliber_r300blackout"
	self.saigry.sdesc2 = "action_di"
	self.saigry.stats.concealment = 20
	self.saigry.fire_mode_data.fire_rate = 60/750
	self:copy_timers("saigry", "m16")
	self.saigry.reload_speed_mult = self.saigry.reload_speed_mult * self:convert_reload_to_mult("mag_133") * 0.85
end

if BeardLib.Utils:FindMod("Owen Gun") then
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

if BeardLib.Utils:FindMod("PP-19-01 Vityaz") then
	self:inf_init("vityaz", "smg", {"range_long"})
	self.vityaz.sdesc1 = "caliber_p9x19"
	self.vityaz.sdesc2 = "action_blowback"
	self:copy_timers("vityaz", "ak5")
	self.vityaz.stats.concealment = 24
end

if BeardLib.Utils:FindMod("l1a1") then
	Hooks:RemovePostHook("l1a1ModInit")
	self:inf_init("l1a1", "ar", {"ldmr"})
	self:copy_sdescs("l1a1", "fal")
	self:copy_timers("l1a1", "fal")
	self.l1a1.reload_speed_mult = self.l1a1.reload_speed_mult * 0.90
	self.l1a1.stats.concealment = 19
end

if BeardLib.Utils:FindMod("Mk14") then
	self:inf_init("wargoddess", "ar", {"ldmr"})
	self:copy_sdescs("wargoddess", "new_m14")
	self:copy_timers("wargoddess", "new_m14")
	self.wargoddess.stats.concealment = 18
end

if BeardLib.Utils:FindMod("sg552") then
	Hooks:RemovePostHook("sg552ModInit")
	self:inf_init("sg552", "ar", nil)
	self:copy_sdescs("sg552", "s552")
	self:copy_stats("sg552", "s552")
	self:copy_timers("sg552", "s552")
	self.sg552.stats.concealment = 24
end

if BeardLib.Utils:FindMod("Beretta Px4 Storm") then
	self:inf_init("px4", "pistol", "medium")
	self.px4.sdesc1 = "caliber_p40sw"
	self.px4.sdesc2 = "action_shortrecoil"
	self:copy_timers("px4", "sparrow")
	self.px4.AMMO_MAX = 84
	self.px4.AMMO_PICKUP = self:_pickup_chance(84, 1)
	--self.px4.stats.concealment = 29
end

if BeardLib.Utils:FindMod("Walther P99 AS") then
	self:inf_init("p99", "pistol", nil)
	self.p99.sdesc1 = "caliber_p9x19"
	self.p99.sdesc2 = "action_shortrecoil"
	self:copy_timers("p99", "packrat")
	--self.p99.stats.concealment = 30
end

if BeardLib.Utils:FindMod("M45A1 CQBP") then
	self:inf_init("m45a1", "pistol", "medium")
	self:copy_sdescs("m45a1", "colt_1911")
	self:copy_timers("m45a1", "colt_1911")
	self.m45a1.AMMO_MAX = 77
	self.m45a1.AMMO_PICKUP = self:_pickup_chance(77, 1)
	self.m45a1.stats.concealment = 29
end

if BeardLib.Utils:FindMod("Mossberg 590") then
	self:inf_init("m590", "shotgun", {"rof_slow", "range_slowpump"})
	self.m590.sdesc1 = "caliber_s12g"
	self.m590.sdesc2 = "action_pump"
	self.m590.stats.spread = self.m590.stats.spread + 10
	self.m590.AMMO_MAX = 40
	self.m590.AMMO_PICKUP = self:_pickup_chance(40, 1)
	self:copy_timers("m590", "m37")
	self.m590.stats.concealment = 21
end

if BeardLib.Utils:FindMod("Vepr-12") then
	self:inf_init("vepr12", "shotgun", {"dmg_vlight", "rof_mag"})
	self:copy_sdescs("vepr12", "saiga")
	self:copy_timers("vepr12", "flint")
	self.vepr12.FIRE_MODE = "single"
	self.vepr12.stats.spread = self.vepr12.stats.spread - 5
	self.vepr12.stats.concealment = 23
end

if BeardLib.Utils:FindMod("M3 Grease Gun") then
	Hooks:RemovePostHook("m3ModInit")
	self.x_m3.attachment_points = {
		{
				name = "a_fl",
				base_a_obj = "a_fl",
				position = Vector3(0.4, -21, 0),
				rotation = Rotation(0, 0, 0)
		}
	}
	self.m3.attachment_points = {
		{
                name = "a_o",
                base_a_obj = "a_o",
                position = Vector3(0, -17, 0),
                rotation = Rotation(0, 0, 0)
		},
		{
				name = "a_fl",
				base_a_obj = "a_fl",
				position = Vector3(0.4, -21, 0),
				rotation = Rotation(0, 0, 0)
		}
	}
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

if BeardLib.Utils:FindMod("Howa AR") then
	self:inf_init("howa", "ar", nil)
	self.howa.sdesc1 = "caliber_r556x45jp"
	self.howa.sdesc2 = "action_gas"
	self:copy_timers("howa", "ak5")
	self:copy_timers_to_reload2("howa", "galil")
	self.howa.stats.concealment = 20
end

if BeardLib.Utils:FindMod("vp70") then
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

if BeardLib.Utils:FindMod("lapd") then
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

if BeardLib.Utils:FindMod("Remington R5 RGP") then
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
if BeardLib.Utils:FindMod("Parker-Hale PDW") then
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

if BeardLib.Utils:FindMod("ARX-160 REBORN") then
	-- redundancy
	self:inf_init("lazy", "ar", nil)
	self.lazy.sdesc1 = "caliber_r556x45"
	self.lazy.sdesc2 = "action_gas"
	-- copies over the reload timer adjustments, flipturn, and InF-specific timers and other data
	self:copy_timers("lazy", "new_m4")
	self.lazy.fire_mode_data.fire_rate = 60/700
	self.lazy.stats.concealment = 21
end

if BeardLib.Utils:FindMod("DP28") then
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

if BeardLib.Utils:FindMod("M60") then
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

if BeardLib.Utils:FindMod("RPD") then
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

if BeardLib.Utils:FindMod("LSAT") then
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

if BeardLib.Utils:FindMod("gtt33") then
	Hooks:RemovePostHook("gtt33Init")
	self:inf_init("gtt33", "pistol", "medium")
	self.gtt33.sdesc1 = "caliber_p762x25"
	self.gtt33.sdesc2 = "action_shortrecoil"
	self:copy_timers("gtt33", "lemming")
	self.gtt33.reload_speed_mult = self.gtt33.reload_speed_mult * self:convert_reload_to_mult("mag_50")
	self.gtt33.CLIP_AMMO_MAX = 8
	--self.gtt33.stats.concealment = 29
end

if BeardLib.Utils:FindMod("Fang-45") then
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

if BeardLib.Utils:FindMod("CZ 75 B") then
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

if BeardLib.Utils:FindMod("CZ 75 Short Rail") then
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

if BeardLib.Utils:FindMod("CZ Auto Pistol") then
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

if BeardLib.Utils:FindMod("Chiappa Rhino 60DS") then
	self:inf_init("rhino", "pistol", "heavy")
	self.rhino.sdesc1 = "caliber_p357"
	self.rhino.sdesc2 = "action_dasa"
	self.rhino.chamber = 0
	self.rhino.stats.concealment = 28
	self:copy_timers("rhino", "chinchilla")
end

if BeardLib.Utils:FindMod("Trench Shotgun") then
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

if BeardLib.Utils:FindMod("Sjögren Inertia") then
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

if BeardLib.Utils:FindMod("ThompsonM1a1") then
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

if BeardLib.Utils:FindMod("M6G Magnum") then
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

if BeardLib.Utils:FindMod("AK-9") then
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

if BeardLib.Utils:FindMod("AK-47") then
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

if BeardLib.Utils:FindMod("AK-74") then
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

if BeardLib.Utils:FindMod("AK-101") then
	self:inf_init("heffy_556", "ar", nil)
	self.heffy_556.sdesc1 = "caliber_r545x39"
	self.heffy_556.sdesc2 = "action_gaslong"
	self:copy_timers("heffy_556", "flint")
end

if BeardLib.Utils:FindMod("Golden-AKMS") then
	self:inf_init("heffy_gold", "ar", {"medium"})
	self.heffy_gold.sdesc1 = "caliber_r762x39"
	self.heffy_gold.sdesc2 = "action_gaslong"
	self:copy_timers("heffy_gold", "flint")
	self.heffy_gold.price = 5*1000000
end

if BeardLib.Utils:FindMod("Saiga-12") then
	self:inf_init("heffy_12g", "shotgun", {"dmg_vlight", "rof_mag"})
	self:copy_sdescs("heffy_12g", "saiga")
	self:copy_timers("heffy_12g", "flint")
	self.heffy_12g.FIRE_MODE = "single"
	self.heffy_12g.reload_speed_mult = self.heffy_12g.reload_speed_mult * self:convert_reload_to_mult("mag_75")
end

if BeardLib.Utils:FindMod("AK Extra Attachments") then
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

if BeardLib.Utils:FindMod("Nagant M1895") then
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

if BeardLib.Utils:FindMod("VHS Various Attachment") then
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

if BeardLib.Utils:FindMod("Kolibri") then
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

if BeardLib.Utils:FindMod("Gepard GM6 Lynx") then
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

if BeardLib.Utils:FindMod("PPSh-41") then
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

if BeardLib.Utils:FindMod("PPS-43") then
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

if BeardLib.Utils:FindMod("Kel-Tec RFB") then
	self:inf_init("leet", "ar", {"ldmr"})
	self.leet.sdesc1 = "caliber_r762x51"
	self.leet.sdesc2 = "action_gasshort"
	self:copy_timers("leet", "komodo")
	self.leet.CLIP_AMMO_MAX = 20
DelayedCalls:Add("rfbflipturn", 0.50, function(self, params)
	-- i'm particular about seeing the reload animation wonkiness
	-- the misaligned mag/hand isn't as apparent in ADS, no adjustment needed
	tweak_data.weapon.leet.reload_timed_stance_mod = {
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

if BeardLib.Utils:FindMod("Silent Killer High Standard HDM") then
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

if BeardLib.Utils:FindMod("Silent Killer Maxim 9") then
	self:inf_init("max9", "pistol", nil)
	self.max9.sdesc1 = "caliber_p9x19"
	self.max9.sdesc2 = "action_blowback"
	self.max9.sdesc4 = "misc_alwayssilent"
	self.max9.AMMO_MAX = 153
	self.max9.AMMO_PICKUP = self:_pickup_chance(153, 1)
	--self.max9.stats.concealment = 28
	self:copy_timers("max9", "hs2000")
end

if BeardLib.Utils:FindMod("Silent Killer Welrod") then
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

if BeardLib.Utils:FindMod("PB") then
	self:inf_init("pb", "pistol", "medium")
	self.pb.sdesc1 = "caliber_p9x18"
	self.pb.sdesc2 = "action_blowbackstraight"
	self:copy_timers("pb", "lemming")
	self.pb.reload_speed_mult = self.pb.reload_speed_mult * self:convert_reload_to_mult("mag_50")
	self.pb.stats.recoil = self.pb.stats.recoil - 3
	self.pb.stats.concealment = 30
end

if BeardLib.Utils:FindMod("Browning Auto Shotgun") then
	self:inf_init("auto5", "shotgun", {"dmg_light", "rof_semi"})
	self.auto5.sdesc1 = "caliber_s12g"
	self.auto5.sdesc2 = "action_longrecoil"
	self.auto5.AMMO_MAX = 24
	self.auto5.AMMO_PICKUP = self:_pickup_chance(24, 1)
	self.auto5.stats.spread = self.auto5.stats.spread + 20
	--self.auto5.stats.concealment = 20
	self:copy_timers("auto5", "benelli")
end

if BeardLib.Utils:FindMod("M40A5") then
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
if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	if not self.m40a5.attachment_points then
		self.m40a5.attachment_points = {}
	end
	table.list_append(self.m40a5.attachment_points, {
		{
			name = "a_bp",
			base_a_obj = "a_body",
			position = Vector3(0, 68, 4),
			rotation = Rotation(0, 0, 0)
		}
	})
end
end

if BeardLib.Utils:FindMod("Desert Tech MDR") then
	self:inf_init("mdr", "ar", {"heavy"})
	self.mdr.sdesc1 = "caliber_r762x51"
	self.mdr.sdesc2 = "action_gas"
	self.mdr.stats.spread = self.mdr.stats.spread - 10
	--self.mdr.stats.concealment = 24
	self:copy_timers("mdr", "aug")
end

if BeardLib.Utils:FindMod("FN SCAR-L") then
	self:inf_init("scarl", "ar", nil)
	self.scarl.sdesc1 = "caliber_r556x45"
	self.scarl.sdesc2 = "action_pistonshort"
	self.scarl.stats.concealment = 21
	self:copy_timers("scarl", "new_m4")
end

if BeardLib.Utils:FindMod("FN SCAR-L M203") then
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
end

--[[
if BeardLib.Utils:FindMod("Kar98k") then
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

if BeardLib.Utils:FindMod("Golden Gun") then
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

if BeardLib.Utils:FindMod("SKS") then
	self:inf_init("sks", "ar", {"ldmr"})
	self.sks.sdesc1 = "caliber_r762x39"
	self.sks.sdesc2 = "action_gasshort"
	self:copy_timers("sks", "siltstone")
	self.sks.stats.concealment = 22
end

if BeardLib.Utils:FindMod("MAS-49") then
	self:inf_init("mas49", "ar", {"dmr"})
	self.mas49.sdesc1 = "caliber_r75x54"
	self.mas49.sdesc2 = "action_di"
	self:copy_timers("mas49", "siltstone")
	self.mas49.stats.concealment = 18
end

if BeardLib.Utils:FindMod("AK-12") then
	self:inf_init("ak12", "ar", nil)
	self.ak12.desc_id = "bm_w_ak12_200_desc"
	self.ak12.sdesc1 = "caliber_r545x39"
	self.ak12.sdesc2 = "action_gaslong"
	self.ak12.stats.concealment = 20
	self:copy_timers("ak12", "flint")
end

if BeardLib.Utils:FindMod("AK-12/76") then
	self:inf_init("ak12_76", "shotgun", {"dmg_vlight", "rof_mag"})
	self.ak12_76.sdesc1 = "caliber_s12g"
	self.ak12_76.sdesc2 = "action_gaslong"
	self:copy_timers("ak12_76", "flint")
	self.ak12_76.FIRE_MODE = "single"
end



	-- !!

if BeardLib.Utils:FindMod("Custom Attachment Points") or BeardLib.Utils:FindMod("WeaponLib") then
	for a, b in ipairs(lmglist) do
		if not self[b].attachment_points then
			self[b].attachment_points = {}
		end
		table.list_append(self[b].attachment_points, {
			{
				name = "a_nowhere",
				base_a_obj = "a_body",
				position = Vector3(0, -1000, -1000),
				rotation = Rotation(0, 0, 0)
			}
		})
	end
end


end





-- FUCK TURRETS
local cancerous = {"swat_van_turret_module", "ceiling_turret_module", "ceiling_turret_module_no_idle", "ceiling_turret_module_longer_range", "aa_turret_module", "crate_turret_module"}
smallercancerous = {"ceiling_turret_module", "ceiling_turret_module_no_idle", "ceiling_turret_module_longer_range", "crate_turret_module"}

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
		self.r870_npc.DAMAGE = 5
	end
end)
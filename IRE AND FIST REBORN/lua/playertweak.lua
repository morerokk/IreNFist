dofile(ModPath .. "infcore.lua")

local function checkfolders(subfolder, file)
	local filename = file or "main.xml"
	if SystemFS:exists("mods/" .. subfolder .. "/" .. filename) or SystemFS:exists("assets/mod_overrides/" .. subfolder .. "/" .. filename) then
		return true
	end
	return false
end

Hooks:PostHook(PlayerTweakData, "init", "fuckingletmeregen", function(self, params)
	-- i don't even remember changing this and i'm not sure if i want to change it back
	--self.damage.REGENERATE_TIME = 2 -- 3
end)

Hooks:PostHook(PlayerTweakData, "_set_sm_wish", "playertweak_cancerdifficulty", function(self, params)
	if InFmenu.settings.copfalloff == true then
		self.damage.MIN_DAMAGE_INTERVAL = 0.20
	end
end)


Hooks:PostHook(PlayerTweakData, "_init_new_stances", "stopswingingtheguns", function(self, params)

	for part_id, wpn in pairs(self.stances) do
		wpn.steelsight.vel_overshot.yaw_neg = 1
		wpn.steelsight.vel_overshot.yaw_pos = -1
		wpn.steelsight.vel_overshot.pitch_neg = -1
		wpn.steelsight.vel_overshot.pitch_pos = 1
		wpn.steelsight.shakers.breathing.amplitude = 0.005
	end


	local pivot_shoulder_translation = nil
	local pivot_shoulder_rotation = nil
	local pivot_head_translation = nil
	local pivot_head_rotation = nil

	-- LMGS
	-- RPK
	pivot_shoulder_translation = Vector3(10.6138, 27.7178, -4.97323)
	pivot_shoulder_rotation = Rotation(0.106543, -0.0842801, 0.628575)
	pivot_head_translation = Vector3(-0.02, 28.5, 0.05)
	pivot_head_rotation = Rotation(0.1, 0, 0)
	self.stances.rpk.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(10.6138, 20, -4.8)
	pivot_shoulder_rotation = Rotation(0.106543, -0.0842801, 0.628575)
	pivot_head_translation = Vector3(-0.02, 28.5, 0.05)
	pivot_head_rotation = Rotation(0.1, 0.25, 0)
	self.stances.rpk.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.rpk.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.rpk.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.rpk.bipod.vel_overshot.yaw_neg = 0
	self.stances.rpk.bipod.vel_overshot.yaw_pos = 0
	self.stances.rpk.bipod.vel_overshot.pitch_neg = 0
	self.stances.rpk.bipod.vel_overshot.pitch_pos = 0
	self.stances.rpk.bipod.shakers = {breathing = {amplitude = 0}}

	-- M249
	pivot_shoulder_translation = Vector3(10.7056, 4.38842, -0.747177)
	pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	pivot_head_translation = Vector3(-0.01, 12, -0.1)
	pivot_head_rotation = Rotation(0.05, 0.15, 0)
	self.stances.m249.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(10.7056, 2.38842, -0.747177)
	pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	pivot_head_translation = Vector3(-0.01, 12, -0.1)
	pivot_head_rotation = Rotation(0.05, 0.15, 0)
	self.stances.m249.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m249.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m249.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.m249.bipod.vel_overshot.yaw_neg = 0
	self.stances.m249.bipod.vel_overshot.yaw_pos = 0
	self.stances.m249.bipod.vel_overshot.pitch_neg = 0
	self.stances.m249.bipod.vel_overshot.pitch_pos = 0
	self.stances.m249.bipod.shakers = {breathing = {amplitude = 0}}

	-- HK21
	pivot_shoulder_translation = Vector3(8.56, 11.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 15, 0.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 0)
	self.stances.hk21.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(8.56, 18.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 15, 0.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 0)
	self.stances.hk21.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.hk21.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.hk21.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.hk21.bipod.vel_overshot.yaw_neg = 0
	self.stances.hk21.bipod.vel_overshot.yaw_pos = 0
	self.stances.hk21.bipod.vel_overshot.pitch_neg = 0
	self.stances.hk21.bipod.vel_overshot.pitch_pos = 0
	self.stances.hk21.bipod.shakers = {breathing = {amplitude = 0}}

	-- MG42
	pivot_shoulder_translation = Vector3(10.6654, 35.1711, 0.821937)
	pivot_shoulder_rotation = Rotation(0.106614, -0.0857193, 0.628153)
	pivot_head_translation = Vector3(-0.01, 25, 0.)
	pivot_head_rotation = Rotation(0.05, 0.1, 0)
	self.stances.mg42.steelsight.shoulders.translation =  pivot_head_translation - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.mg42.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	--
	self.stances.mg42.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.mg42.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.mg42.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.mg42.bipod.vel_overshot.yaw_neg = 0
	self.stances.mg42.bipod.vel_overshot.yaw_pos = 0
	self.stances.mg42.bipod.vel_overshot.pitch_neg = 0
	self.stances.mg42.bipod.vel_overshot.pitch_pos = 0
	self.stances.mg42.bipod.shakers = {breathing = {amplitude = 0}}

	-- FNMAG
	pivot_shoulder_translation = Vector3(10.7056, 4.38842, -0.747177)
	pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	pivot_head_translation = Vector3( 0.645, 10.5, 3.21 )
	pivot_head_rotation = Rotation( 0.15, 0, 0 )
	self.stances.par.steelsight.shoulders.translation =  pivot_head_translation - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.par.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(10.7, 13, 0.4)
	pivot_shoulder_rotation = Rotation(0.106618, -0.084954, 0.62858)
	pivot_head_translation = Vector3(0.645, 10.5, 3.21)
	pivot_head_rotation = Rotation(0.15, 1.2, 0)
	self.stances.par.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.par.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.par.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.par.bipod.vel_overshot.yaw_neg = 0
	self.stances.par.bipod.vel_overshot.yaw_pos = 0
	self.stances.par.bipod.vel_overshot.pitch_neg = 0
	self.stances.par.bipod.vel_overshot.pitch_pos = 0
	self.stances.par.bipod.shakers = {breathing = {amplitude = 0}}


if BeardLib.Utils:FindMod("M2HB") then
	self.stances.m2hb = deep_clone(self.stances.hk21)
	pivot_shoulder_translation = Vector3(8.56, 11.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 45, 45.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 45)
	self.stances.m2hb.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m2hb.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(8.56, 18.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 45, 45.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 45)
	self.stances.m2hb.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.m2hb.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.m2hb.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	self.stances.m2hb.bipod.vel_overshot.yaw_neg = 0
	self.stances.m2hb.bipod.vel_overshot.yaw_pos = 0
	self.stances.m2hb.bipod.vel_overshot.pitch_neg = 0
	self.stances.m2hb.bipod.vel_overshot.pitch_pos = 0
	self.stances.m2hb.bipod.shakers = {breathing = {amplitude = 0}}
end




	-- mosconi
	pivot_shoulder_translation = Vector3(10.6562, 32.9715, -6.73279)
	pivot_shoulder_rotation = Rotation(0.106667, -0.0844876, 0.629223)
	pivot_head_translation = Vector3(0, 27, -0.4)
	pivot_head_rotation = Rotation(0, 1, 0)
	self.stances.huntsman.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.huntsman.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()

	-- joceline
	pivot_shoulder_translation = Vector3(8.47311, 22.1434, -6.31211)
	pivot_shoulder_rotation = Rotation(-1.83462E-5, 0.00105637, 3.52956E-4)
	pivot_head_translation = Vector3(0, 30, -0.5)
	pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.b682.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.b682.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()

	-- reinfeld/locomotive
--[[
	pivot_shoulder_translation = Vector3(10.662, 3.33648, -4.35027)
	pivot_shoulder_rotation = Rotation(0.106662, -0.0849799, 0.628576)
	pivot_head_translation = Vector3(-0.01, 10, 1.5)
	pivot_head_rotation = Rotation(0.05, 0, 0)
	self.stances.r870.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.r870.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	
	self.stances.serbu.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.serbu.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
--]]

end)

if tweak_data then
	tweak_data.player.stances.m2hb = deep_clone(tweak_data.player.stances.hk21)
	pivot_shoulder_translation = Vector3(8.56, 11.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 45, 45.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 45)
	tweak_data.player.stances.m2hb.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	tweak_data.player.stances.m2hb.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	pivot_shoulder_translation = Vector3(8.56, 18.3934, -3.33201)
	pivot_shoulder_rotation = Rotation(4.78916E-5, 0.00548037, -0.00110991)
	pivot_head_translation = Vector3(-0.01, 45, 45.05)
	pivot_head_rotation = Rotation(0.1, 0.2, 45)
	tweak_data.player.stances.m2hb.bipod.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	tweak_data.player.stances.m2hb.bipod.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	tweak_data.player.stances.m2hb.bipod.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, 0, 0)
	tweak_data.player.stances.m2hb.bipod.vel_overshot.yaw_neg = 0
	tweak_data.player.stances.m2hb.bipod.vel_overshot.yaw_pos = 0
	tweak_data.player.stances.m2hb.bipod.vel_overshot.pitch_neg = 0
	tweak_data.player.stances.m2hb.bipod.vel_overshot.pitch_pos = 0
	tweak_data.player.stances.m2hb.bipod.shakers = {breathing = {amplitude = 0}}
end
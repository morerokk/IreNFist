dofile(ModPath .. "infcore.lua")

-- Modified file to still reset recoil in VR
-- Allows recoil to actually work in VR since there is no traditional "camera"

-- slows down 
function FPCameraPlayerBase:enter_shotgun_reload_loop(unit, state, ...)
	if alive(self._parent_unit) then
		local speed_multiplier = self._parent_unit:inventory():equipped_unit():base():reload_speed_multiplier() * (self._parent_unit:inventory():equipped_unit():base():weapon_tweak_data().shell_by_shell_loop_speed_mult or 1)

		self._unit:anim_state_machine():set_speed(Idstring(state), speed_multiplier)
	end
end

Hooks:PostHook(FPCameraPlayerBase, "init", "kickaccum_init", function(self, params)
	self._accumulated_recoil = 0
	self._last_shot_time = 0
	self._current_wpn = ""
	self._last_recover_time = 0
	self._recoil_apply_delay = 0
	self._last_unapplied_recoil_time = nil
end)

-- ADD SYSTEM TO AUTOMATICALLY RESET ALL RECOIL INSTEAD OF JUST A "FAST" PERIOD?

function FPCameraPlayerBase:has_category(wpnid, category)
	local hascat = false
	for u, v in ipairs (tweak_data.weapon[wpnid].categories) do
		if v == category then
			hascat = true
		end
	end
	return hascat
end

Hooks:PostHook(FPCameraPlayerBase, "update", "kickaccum_decrement", function(self, params)
	local recoil_recover_delay = 0.25
	local recoil_recover_time = 0.03
	local recoil_recoverfast_num = 0
	local recoil_recoverfast_delay = 0
	local recoil_recoverfast_time = 0
	local factory_id = ""
	local is_akimbo = false

	-- get recoil data
	if self._parent_unit then
		if self._parent_unit:inventory() then
			if self._parent_unit:inventory():equipped_unit() then
				if self._parent_unit:inventory():equipped_unit():base() then
					recoil_recover_delay = self._parent_unit:inventory():equipped_unit():base()._recoil_recover_delay or recoil_recover_delay
					self._recoil_apply_delay = self._parent_unit:inventory():equipped_unit():base()._recoil_apply_delay or self._recoil_apply_delay
					factory_id = self._parent_unit:inventory():equipped_unit():base()._factory_id
				end
			end
		end
	end

	if self._current_wpn == factory_id then
		if (self._accumulated_recoil > 0) and ((os.clock() - self._last_shot_time) > recoil_recover_delay) then
			if (os.clock() - self._last_recover_time) > recoil_recover_time then
				self._accumulated_recoil = math.clamp(self._accumulated_recoil - 1, 0, 2000)
				self._last_recover_time = os.clock()
			end
		end
	else
		self._current_wpn = factory_id
		self._accumulated_recoil = 0
	end
end)


-- Remove recoil auto-reset in desktop
-- Because of how recoil works in VR (esp. with VR Recoil), it should still reset like normal in VR.
-- This makes tapfiring the required method in VR, which I'm not sure if I like.
if not _G.IS_VR then
	local startShootingOrig = FPCameraPlayerBase.start_shooting
	local startShootingNew = function(self)
		self._recoil_kick.current = self._recoil_kick.current and self._recoil_kick.current or self._recoil_kick.accumulated or 0
		self._recoil_kick.h.current = self._recoil_kick.h.current and self._recoil_kick.h.current or self._recoil_kick.h.accumulated or 0
	end

	local stopShootingOrig = FPCameraPlayerBase.stop_shooting
	local stopShootingNew = function(self, wait)
		self._recoil_kick.to_reduce = self._recoil_kick.accumulated or 0
		self._recoil_kick.h.to_reduce = self._recoil_kick.h.accumulated or 0
		self._recoil_wait = 0
	end

	FPCameraPlayerBase.start_shooting = startShootingNew
	FPCameraPlayerBase.stop_shooting = stopShootingNew
	
	-- With SSO installed, override these on a delayed call
	if IREnFIST.mod_compatibility.sso then
		DelayedCalls:Add("inf_fpcamera_recoil_startstopshoot_ssocompat", 1, function()
			FPCameraPlayerBase.start_shooting = startShootingNew
			FPCameraPlayerBase.stop_shooting = stopShootingNew
		end)
	end
end


local recoilKickNew = function(self, up, down, left, right)
	-- set default recoil table
	local recoil_table = {
		{-1, -1, 0, 0}
	}
	local recoil_loop_point = 999

	-- get recoil table
	if self._parent_unit then
		if self._parent_unit:inventory() then
			if self._parent_unit:inventory():equipped_unit() then
				if self._parent_unit:inventory():equipped_unit():base() then
					if self._parent_unit:inventory():equipped_unit():base()._recoil_table then
						recoil_table = self._parent_unit:inventory():equipped_unit():base()._recoil_table
						recoil_loop_point = self._parent_unit:inventory():equipped_unit():base()._recoil_loop_point or 999
					end
				end
			end
		end
	end

	local recoil_index = self._accumulated_recoil+1
	-- don't pull table values that are off the table
	if recoil_index > #recoil_table then
		-- invalid or no recoil loop point
		if (recoil_loop_point or 0) > #recoil_table then
			recoil_index = #recoil_table
		-- use loop point
		else
			recoil_index = recoil_loop_point or #recoil_table
			self._accumulated_recoil = recoil_loop_point - 1
		end
	end

	-- send kick values
	local v = math.lerp(up * recoil_table[recoil_index][1], down * recoil_table[recoil_index][2], math.random())
	self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + v

	local h = math.lerp(left * recoil_table[recoil_index][3], right * recoil_table[recoil_index][4], math.random())
	self._recoil_kick.h.accumulated = (self._recoil_kick.h.accumulated or 0) + h

	-- set InF recoil system values
	self._last_shot_time = os.clock()
	self._last_unapplied_recoil_time = self._last_unapplied_recoil_time or self._last_shot_time
	self._current_wpn = self._parent_unit:inventory():equipped_unit():base()._factory_id
	self._accumulated_recoil = self._accumulated_recoil + 1
end

FPCameraPlayerBase.recoil_kick = recoilKickNew

-- With SSO installed, override recoil kick on a delayed call
if IREnFIST.mod_compatibility.sso then
	DelayedCalls:Add("inf_fpcamera_recoil_recoilkick_ssocompat", 1, function()
		FPCameraPlayerBase.recoil_kick = recoilKickNew
	end)
end

if not _G.IS_VR then
	local verticalKickOrig = FPCameraPlayerBase._vertical_recoil_kick
	function FPCameraPlayerBase:_vertical_recoil_kick(t, dt)

		local player_state = managers.player:current_state()

		-- firing delay to make akimbos work
		local r_value = 0
		if self._recoil_kick.accumulated then
			if (self._last_unapplied_recoil_time or 18000000) + self._recoil_apply_delay < os.clock() then
				r_value = self._recoil_kick.accumulated
				self._recoil_kick.accumulated = nil
				self._last_unapplied_recoil_time = nil
			end
		end

		-- reduce kick while tased
		if self._parent_unit then
			if self._parent_unit:movement() then
				if self._parent_unit:movement():tased() then
					r_value = r_value * 0.50
				end
			end
		end

		-- reduce recoil instead of removing it
		if player_state == "bipod" then
			r_value = r_value * 0.30
		end

		return r_value
	end

	local horizontalKickOrig = FPCameraPlayerBase._horizonatal_recoil_kick
	function FPCameraPlayerBase:_horizonatal_recoil_kick(t, dt)

		local player_state = managers.player:current_state()

		local r_value = 0
		if self._recoil_kick.h.accumulated then
			if (self._last_unapplied_recoil_time or 18000000) + self._recoil_apply_delay < os.clock() then
				r_value = self._recoil_kick.h.accumulated
				self._recoil_kick.h.accumulated = nil
			end
		end

		if self._parent_unit then
			if self._parent_unit:movement() then
				if self._parent_unit:movement():tased() then
					r_value = r_value * 0.50
				end
			end
		end

		-- reduce horizontal too
		if player_state == "bipod" then
			r_value = r_value * 0.30
		end

		return r_value
	end
end

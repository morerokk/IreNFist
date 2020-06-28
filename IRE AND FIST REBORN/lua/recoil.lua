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
--[[
					recoil_recover_time = self._parent_unit:inventory():equipped_unit():base()._recoil_recover_time
					recoil_recoverfast_num = self._parent_unit:inventory():equipped_unit():base()._recoil_recoverfast_num
					recoil_recoverfast_delay = self._parent_unit:inventory():equipped_unit():base()._recoil_recoverfast_delay
					recoil_recoverfast_time = self._parent_unit:inventory():equipped_unit():base()._recoil_recoverfast_time
--]]
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


-- removed lines concerning recoil resetting
local startShootingOrig = FPCameraPlayerBase.start_shooting
function FPCameraPlayerBase:start_shooting()
	if _G.IS_VR then
		return startShootingOrig(self)
	end

	self._recoil_kick.current = self._recoil_kick.current and self._recoil_kick.current or self._recoil_kick.accumulated or 0
	self._recoil_kick.h.current = self._recoil_kick.h.current and self._recoil_kick.h.current or self._recoil_kick.h.accumulated or 0
end

local stopShootingOrig = FPCameraPlayerBase.stop_shooting
function FPCameraPlayerBase:stop_shooting( wait )
	if _G.IS_VR then
		return stopShootingOrig(self, wait)
	end

	--local weapon = self._parent_unit:inventory():equipped_unit()
--[[
	local recoil_recover = weapon and self._parent_unit:inventory():equipped_unit():base()._recoil_recover
	if self._parent_unit:inventory():equipped_unit():base():in_burst_mode() then
		recoil_recover = recoil_recover * 0.80
	end
	if recoil_recover > 1 then
		recoil_recover = 1
	elseif recoil_recover < 0 then
		recoil_recover = 0
	end
--]]
	self._recoil_kick.to_reduce = self._recoil_kick.accumulated or 0
	self._recoil_kick.h.to_reduce = self._recoil_kick.h.accumulated or 0
	self._recoil_wait = 0
end


function FPCameraPlayerBase:recoil_kick(up, down, left, right)
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

local verticalKickOrig = FPCameraPlayerBase._vertical_recoil_kick
function FPCameraPlayerBase:_vertical_recoil_kick(t, dt)

	if _G.IS_VR then
		return verticalKickOrig(self, t, dt)
	end

	local player_state = managers.player:current_state()

	-- PD2's recoil accumulation values are used to determine camera rotation
	-- camera movetime is instant and there is no recovery, so we just use the value and reset it immediately
--[[
	local r_value = 0
	if self._recoil_kick.accumulated then
		r_value = self._recoil_kick.accumulated
		self._recoil_kick.accumulated = 0
	end
--]]
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

	if _G.IS_VR then
		return horizontalKickOrig(self, t, dt)
	end

	local player_state = managers.player:current_state()
--[[
	local r_value = 0
	if self._recoil_kick.h.accumulated then
		r_value = self._recoil_kick.h.accumulated
		self._recoil_kick.h.accumulated = 0
	end
--]]

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



--[[
function FPCameraPlayerBase:clbk_stance_entered(new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
	local t = managers.player:player_timer():time()

	if new_shoulder_stance then
		local transition = {}
		self._shoulder_stance.transition = transition
		transition.end_translation = new_shoulder_stance.translation + (stance_mod.translation or Vector3())
		transition.end_rotation = new_shoulder_stance.rotation * (stance_mod.rotation or Rotation())
		transition.start_translation = mvector3.copy(self._shoulder_stance.translation)
		transition.start_rotation = self._shoulder_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_head_stance then
		local transition = {}
		self._head_stance.transition = transition
		transition.end_translation = new_head_stance.translation
		transition.end_rotation = new_head_stance.rotation
		transition.start_translation = mvector3.copy(self._head_stance.translation)
		transition.start_rotation = self._head_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_vel_overshot then
		local transition = {}
		self._vel_overshot.transition = transition
		transition.end_pivot = new_vel_overshot.pivot
		transition.end_yaw_neg = new_vel_overshot.yaw_neg
		transition.end_yaw_pos = new_vel_overshot.yaw_pos
		transition.end_pitch_neg = new_vel_overshot.pitch_neg
		transition.end_pitch_pos = new_vel_overshot.pitch_pos
		transition.start_pivot = mvector3.copy(self._vel_overshot.pivot)
		transition.start_yaw_neg = self._vel_overshot.yaw_neg
		transition.start_yaw_pos = self._vel_overshot.yaw_pos
		transition.start_pitch_neg = self._vel_overshot.pitch_neg
		transition.start_pitch_pos = self._vel_overshot.pitch_pos
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_fov then
		if new_fov == self._fov.fov then
			self._fov.transition = nil
		else
			local transition = {}
			self._fov.transition = transition
			transition.end_fov = new_fov
			transition.start_fov = self._fov.fov
			transition.start_t = t
			transition.duration = duration * duration_multiplier
		end
	end

	if new_shakers then
		for effect, values in pairs(new_shakers) do
			for parameter, value in pairs(values) do
				self._parent_unit:camera():set_shaker_parameter(effect, parameter, value)
			end
		end
	end
end
--]]
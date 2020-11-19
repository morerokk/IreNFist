--[[
PRETTY SURE THIS IS BY SEVEN
I MODIFIED IT TO:
allow weapon mods to modify burst properties instead of exclusively tying it to weapontweakdata data
stop single-fire lock from disabling burst (to allow semi+burst weapons)
work with shotguns (for double barrels)
not give select-fire weapons inherent burst functionality
not singlefire with akimbos (FUCKING STRYKS WORK PLOX)
--]]

--[[
Weapon tweak data attributes:
	BURST_FIRE:
		<number>		-	Force enable burst fire using the specified number as the burst size (if weapon does not have a fire mode mod installed)
		nil	/undef		-	If the weapon can toggle fire mode and does not have a fire mode mod installed, enable burst fire with default burst size (3)
		false			-	Force disable burst fire even if weapon can toggle fire mode
		
	ADAPTIVE_BURST_SIZE:
		nil/true		-	Allow abortion of ongoing burst if trigger is released
		false			-	Force entire burst to be fired before resetting
		
	BURST_FIRE_RATE_MULTIPLIER:
		<number>		-	Apply specified multiplier to fire rate when firing in burst mode
		
	DELAYED_BURST_RECOIL:
		true/false	-	Build up and delay recoil until last shot in burst is fired
]]

if IreNFist.mod_compatibility.vanillahudplus then
	return
end

if RequiredScript == "lib/units/weapons/newraycastweaponbase" then

	local _update_stats_values_original = NewRaycastWeaponBase._update_stats_values
	local fire_rate_multiplier_original = NewRaycastWeaponBase.fire_rate_multiplier
	local recoil_multiplier_original = NewRaycastWeaponBase.recoil_multiplier
	local on_enabled_original = NewRaycastWeaponBase.on_enabled
	local on_disabled_original = NewRaycastWeaponBase.on_disabled
	local start_reload_original = NewRaycastWeaponBase.start_reload
	local fire_original = NewRaycastWeaponBase.fire
	local fire_original2 = NewRaycastWeaponBase.fire
	local toggle_firemode_original = NewRaycastWeaponBase.toggle_firemode
	local toggle_firemode_original2 = NewRaycastWeaponBase.toggle_firemode
	
	NewRaycastWeaponBase.DEFAULT_BURST_SIZE = 3
	NewRaycastWeaponBase.IDSTRING_SINGLE = Idstring("single")
	NewRaycastWeaponBase.IDSTRING_AUTO = Idstring("auto")
	
--[[
	function NewRaycastWeaponBase:_update_stats_values(...)
		_update_stats_values_original(self, ...)
		
		if not self:is_npc() then
			self._burst_rounds_remaining = 0
			self._burst_rounds_fired = 0



-- moved to newraycast

			self._has_auto = not self._locked_fire_mode and (self:can_toggle_firemode() or self:weapon_tweak_data().FIRE_MODE == "auto")
			self._has_burst_fire = (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false
			--self._has_burst_fire = (not self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) or (self:can_toggle_firemode() or self:weapon_tweak_data().BURST_FIRE) and self:weapon_tweak_data().BURST_FIRE ~= false
			--self._locked_fire_mode = self._locked_fire_mode or managers.weapon_factor:has_perk("fire_mode_burst", self._factory_id, self._blueprint) and Idstring("burst")
			self._burst_size = self:weapon_tweak_data().BURST_FIRE or NewRaycastWeaponBase.DEFAULT_BURST_SIZE
			self._adaptive_burst_size = self:weapon_tweak_data().ADAPTIVE_BURST_SIZE ~= false
			self._burst_fire_rate_multiplier = self:weapon_tweak_data().BURST_FIRE_RATE_MULTIPLIER or 1
			self._delayed_burst_recoil = self:weapon_tweak_data().DELAYED_BURST_RECOIL


			
		end
	end
--]]

--[[
Hooks:PostHook(NewRaycastWeaponBase, "_update_stats_values", "infnewstats", function(self, params)
	if not self:is_npc() then
		self._burst_rounds_remaining = 0
		self._burst_rounds_fired = 0
	end
end
--]]

	-- ALSO IN SHOTGUNS
	function NewRaycastWeaponBase:fire_rate_multiplier(...)
		local mult = 1

		mult = mult * self._inf_rof_mult

		if managers.player:current_state() == "bipod" then
			mult = mult * (self._bipod_rof_mult or 1)
		end

		if self:in_burst_mode() then --and (self._burst_rounds_fired <= self._burst_fire_rate_multiplier_shots) then
			local table_mult = 1
			-- read from table
			if self._burst_fire_rate_table then
				table_mult = self._burst_fire_rate_table[math.clamp(self._last_burst_rounds_fired, 1, #self._burst_fire_rate_table)]
			end
			mult = mult * table_mult * (self._burst_fire_rate_multiplier or 1)
		end

		return fire_rate_multiplier_original(self, ...) * mult
	end
	
	function NewRaycastWeaponBase:recoil_multiplier(...)
		local mult = 1

		if self:in_burst_mode() and self._burst_recoil_mult then --and (self._burst_rounds_fired <= self._burst_recoil_multiplier_shots) then
			mult = mult * (self._burst_recoil_mult or 1)
		end
		if self:in_burst_mode() and self._burst_recoil_table then
			mult = mult * self._burst_recoil_table[math.clamp(self._last_burst_rounds_fired, 1, #self._burst_recoil_table)]
		end
		if self._delayed_burst_recoil and self:in_burst_mode() and self:burst_rounds_remaining() then
			mult = 0
		end

		-- moved from fire()
--[[
		if self._burst_rounds_remaining <= 0 then
			self._burst_canceling_from_zero_shots = true
			self:cancel_burst()
		end
--]]
		
		return recoil_multiplier_original(self, ...) * mult
	end
	
	function NewRaycastWeaponBase:on_enabled(...)
		self:cancel_burst()
		return on_enabled_original(self, ...)
	end
	
	function NewRaycastWeaponBase:on_disabled(...)
		self:cancel_burst()
		return on_disabled_original(self, ...)
	end
	
	function NewRaycastWeaponBase:start_reload(...)
		self:cancel_burst()
		return start_reload_original(self, ...)
	end

	-- used for shotgun bursts
	function NewRaycastWeaponBase:fire2(...)
		local result = fire_original(self, ...)
		return result
	end

	function NewRaycastWeaponBase:fire(...)
		local result = fire_original(self, ...)

		if result and self:in_burst_mode() then
			if self:clip_empty() then
				self._last_burst_rounds_fired = self._last_burst_rounds_fired + 1
				self:cancel_burst()
			else
				self._burst_rounds_fired = self._burst_rounds_fired + 1
				self._last_burst_rounds_fired = self._burst_rounds_fired
				self._burst_rounds_remaining = (self._burst_rounds_remaining <= 0 and self._burst_size or self._burst_rounds_remaining) - 1
				-- also check for minimum burst length for adaptive bursts

-- moved end-burst to recoil mult so widowmaker doesn't zero out _burst_rounds_fired before the second shot determines which burst recoil table index it needs to read
--
				if self._burst_rounds_remaining <= 0 then
					self:cancel_burst()
				end
--
			end
		end
		
		return result
	end
	
	--Semi-override
	function NewRaycastWeaponBase:toggle_firemode(...)
		if self._has_burst_fire and not self:gadget_overrides_weapon_functions() then
			return self:_check_toggle_burst() or toggle_firemode_original(self, ...)
		else
			return toggle_firemode_original(self, ...)
		end
	end
	
	
	
	function NewRaycastWeaponBase:_check_toggle_burst()
		if self:in_burst_mode() then
			self:_set_burst_mode(false, false)
			return true
		elseif ((self._fire_mode == NewRaycastWeaponBase.IDSTRING_SINGLE) or (self._fire_mode == NewRaycastWeaponBase.IDSTRING_AUTO and not self:can_toggle_firemode())) and self._has_burst_fire then
			self:_set_burst_mode(true, false)
			return true
		else
			return false
		end
	end

	function NewRaycastWeaponBase:_set_burst_mode(status, skip_sound)
		self._in_burst_mode = status
		self._fire_mode = NewRaycastWeaponBase["IDSTRING_" .. (status and "SINGLE" or self._has_auto and "AUTO" or "SINGLE")]
		
		if not skip_sound then
			self._sound_fire:post_event(status and "wp_auto_switch_on" or self._has_auto and "wp_auto_switch_on" or "wp_auto_switch_off")
		end
		
		self:cancel_burst()
	end
	
	function NewRaycastWeaponBase:can_use_burst_mode()
		return self._has_burst_fire
	end
	
	function NewRaycastWeaponBase:in_burst_mode()
		return self._fire_mode == NewRaycastWeaponBase.IDSTRING_SINGLE and self._in_burst_mode and not self:gadget_overrides_weapon_functions()
	end
	
	function NewRaycastWeaponBase:burst_rounds_remaining()
		return self._burst_rounds_remaining > 0 and self._burst_rounds_remaining or false
	end
	
	function NewRaycastWeaponBase:cancel_burst(soft_cancel)
		if self._adaptive_burst_size or not soft_cancel then
			self._burst_rounds_remaining = 0
			
			if self._delayed_burst_recoil and self._burst_rounds_fired > 0 and not self._burst_canceling_from_zero_shots then
				self._setup.user_unit:movement():current_state():force_recoil_kick(self, self._burst_rounds_fired)
			end
			self._burst_rounds_fired = 0
			self._burst_canceling_from_zero_shots = nil
		end
	end

end

if RequiredScript == "lib/units/weapons/akimboweaponbase" then

	local _update_stats_values_original = AkimboWeaponBase._update_stats_values
	local fire_original = AkimboWeaponBase.fire
	local fire_rate_multiplier_original_ak = AkimboWeaponBase.fire_rate_multiplier
	local toggle_firemode_original_ak = AkimboWeaponBase.toggle_firemode
	
	-- Temporarily discontinued in favor of properly working Akimbo burstfire.
	-- If single-fire akimbo is ever implemented again, it will not use the vanilla firemode as a "two-round burst",
	-- because that conflicts with a weapon's potential actual burst mechanics.
	-- This probably wasn't an issue before the Beretta 93R came along
	--[[
	function AkimboWeaponBase:fire(...)
		local result = nil
		if self._fire_left_side == true and alive(self._second_gun) and not self:_in_burst_or_auto_mode() then
			result = self._second_gun:base().super.fire(self._second_gun:base(), ...)
			self._fire_left_side = false
		else
			results = fire_original(self, ...)
			self._fire_left_side = true
		end

		if result and self:in_burst_mode() then
			if self:clip_empty() then
				self._last_burst_rounds_fired = self._last_burst_rounds_fired + 1
				self:cancel_burst()
			else
				self._burst_rounds_fired = self._burst_rounds_fired + 1
				self._last_burst_rounds_fired = self._burst_rounds_fired
				self._burst_rounds_remaining = (self._burst_rounds_remaining <= 0 and self._burst_size or self._burst_rounds_remaining) - 1
				if self._burst_rounds_remaining <= 0 then
					self:cancel_burst()
				end
			end
		end

		if not self:_in_burst_or_auto_mode() then
			self._fire_callbacks = {}
		end
		
		return results
	end
	]]

	-- apply recoil only to the second shot if firing in burst/auto
	-- Disabled in VR because they already fire individually
	if not _G.IS_VR then
		Hooks:PostHook(AkimboWeaponBase, "_fire_second", "applykick", function(self, params)
			local state_data = self._setup.user_unit:movement()._state_data
			local weap_tweak_data = tweak_data.weapon[self:get_name_id()] -- was i supposed to unfuck this to self._equipped_unit:base():weapon_tweak_data() too
			local up, down, left, right = unpack(weap_tweak_data.kick[state_data.in_steelsight and "steelsight" or state_data.ducking and "crouching" or "standing"])
			-- use alternate stance kick multipliers as necessary
			if self._rstance then
				up, down, left, right = unpack(self._rstance[state_data.in_steelsight and "steelsight" or state_data.ducking and "crouching" or "standing"])
			end

			-- apply custom_stat recoil mults
			up = up * self._recoil_vertical_mult
			down = down * self._recoil_vertical_mult
			left = left * self._recoil_horizontal_mult * managers.player:upgrade_value("player", "recoil_h_mult", 1)
			right = right * self._recoil_horizontal_mult * managers.player:upgrade_value("player", "recoil_h_mult", 1)
			-- apply ADS-specific recoil mults
			if state_data.in_steelsight == true then
				up = up * self._ads_recoil_vertical_mult
				down = down * self._ads_recoil_vertical_mult
				left = left * self._ads_recoil_horizontal_mult
				right = right * self._ads_recoil_horizontal_mult
			end

			local recoil_multiplier = (self:recoil() + self:recoil_addend()) * self:recoil_multiplier() * 2 -- apply recoil for both weapons

			self._setup.user_unit:camera()._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)
		end)
	end
	
	-- Now that akimbos fire both weapons again, this can be done away with for now.
	-- I get that it was cool, but it looked pretty dumb animation-wise.
	-- This energy might be better invested in adding the ability to switch to a single version of your akimbo primary, even if your secondary is something else.
	-- Either way, akimbo single-fire oughta be separate from burst altogether.
	--[[
	function AkimboWeaponBase:fire_rate_multiplier(...)
		return fire_rate_multiplier_original_ak(self, ...) * (self:_in_burst_or_auto_mode() and 1 or 2)
	end
	]]
	
	--Override
	--[[
	function AkimboWeaponBase:toggle_firemode(...)
		return self._has_burst_fire and self:_check_toggle_burst() or toggle_firemode_original(self, ...)
	end
	]]
	
	--[[
	function AkimboWeaponBase:_set_burst_mode(status, skip_sound)
		if alive(self._second_gun) then
			self._second_gun:base():_set_burst_mode(status, skip_sound)
		end
		
		return AkimboWeaponBase.super._set_burst_mode(self, status, skip_sound)
	end
	]]
	
	function AkimboWeaponBase:_in_burst_or_auto_mode()
		return self._fire_mode == NewRaycastWeaponBase.IDSTRING_AUTO or self:in_burst_mode()
	end

end


if RequiredScript == "lib/units/beings/player/states/playerstandard" then

	local update_original = PlayerStandard.update
	local _check_action_primary_attack_original = PlayerStandard._check_action_primary_attack
	local _check_action_deploy_underbarrel_original = PlayerStandard._check_action_deploy_underbarrel

	function PlayerStandard:update(t, ...)
		update_original(self, t, ...)
		self:_update_burst_fire(t)
	end
	
	function PlayerStandard:_check_action_primary_attack(t, input, ...)
		-- check for minimum burst length
		if self._trigger_down and not input.btn_primary_attack_state and not (self._equipped_unit:base()._burst_rounds_fired <= self._equipped_unit:base()._min_adaptive_burst_length - 1) then
			self._equipped_unit:base():cancel_burst(true)
		end
		self._trigger_down = input.btn_primary_attack_state
		
		return _check_action_primary_attack_original(self, t, input, ...)
	end
	
	function PlayerStandard:_check_action_deploy_underbarrel(...)
		local new_action = _check_action_deploy_underbarrel_original(self, ...)
		
		if new_action and alive(self._equipped_unit) and self._equipped_unit:base() and self._equipped_unit:base():in_burst_mode() then
			managers.hud:set_teammate_weapon_firemode_burst(self._equipped_unit:base():selection_index())
		end
		
		return new_action
	end
	
	--Override
	function PlayerStandard:_check_action_weapon_firemode(t, input)
		local wbase = self._equipped_unit:base()
		if input.btn_weapon_firemode_press and wbase.toggle_firemode then
			self:_check_stop_shooting()
			if wbase:toggle_firemode() then
				if wbase:in_burst_mode() then
					managers.hud:set_teammate_weapon_firemode_burst(self._unit:inventory():equipped_selection())
				else
					managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, self._unit:inventory():equipped_selection(), wbase:fire_mode())
				end
			end
		end
	end
	
	
	function PlayerStandard:_update_burst_fire(t)
		if alive(self._equipped_unit) and self._equipped_unit:base():burst_rounds_remaining() then
			self:_check_action_primary_attack(t, { btn_primary_attack_state = true, btn_primary_attack_press = true })
		end
	end
	
	function PlayerStandard:force_recoil_kick(weap_base, manual_multiplier)
		local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier() * (manual_multiplier or 1)
		local up, down, left, right = unpack(weap_base:weapon_tweak_data().kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])
		self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)
	end

end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	
	HUDManager._USE_BURST_MODE = true	--Custom HUD compatibility

	HUDManager.set_teammate_weapon_firemode_burst = HUDManager.set_teammate_weapon_firemode_burst or function(self, id)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_weapon_firemode_burst(id)
	end

end

if RequiredScript == "lib/managers/hud/hudteammate" then
	
	--Default function for vanilla HUD. If using a custom HUD that alters fire mode HUD components, make sure to implement this function in it
	HUDTeammate.set_weapon_firemode_burst = HUDTeammate.set_weapon_firemode_burst or function(self, id, firemode, burst_fire)
	
		-- In VR, dont update the HUD
		-- TODO: if VR even has a firemode display, implement burst into it here
		-- UPDATE: It doesn't
		if _G.IS_VR then
			return
		end
	
		local is_secondary = id == 1
		local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
		local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
		local weapon_selection = is_secondary and secondary_weapon_panel:child("weapon_selection") or primary_weapon_panel:child("weapon_selection")
		if alive(weapon_selection) then
			local firemode_single = weapon_selection:child("firemode_single")
			local firemode_auto = weapon_selection:child("firemode_auto")
			if alive(firemode_single) and alive(firemode_auto) then
				firemode_single:show()
				firemode_auto:show()
			end
		end
	end
	
end
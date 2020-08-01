Hooks:Add("MenuManagerInitialize", "mmi_inf", function(menu_manager)
	-- custom keybind
	local mod
    for _, m in pairs(BLT.Mods:Mods()) do
        if m:GetName() == "Hold The Key" then
            mod = m
            break
        end
	end
	if mod and mod:IsEnabled() then
		HoldTheKey:Add_Keybind("inf_dash")
	end
end)

-- modified version, prevents objects from disappearing if toggling ADS while reloading
DelayedCalls:Add("ModernSightsInFmodification", 0.25, function(self, params)
	Hooks:RemovePostHook("FancyScopeCheck")
end)
function PlayerStandard:_stance_entered(unequipped, timemult)
	local stance_standard = tweak_data.player.stances.default[managers.player:current_state()] or tweak_data.player.stances.default.standard
	local head_stance = self._state_data.ducking and tweak_data.player.stances.default.crouched.head or stance_standard.head
	local stance_id = nil
	local stance_mod = {
		translation = Vector3(0, 0, 0),
		rotation = Rotation(0, 0, 0)
	}

	local duration = tweak_data.player.TRANSITION_DURATION + (self._equipped_unit:base():transition_duration() or 0)
	local duration_multiplier = self._state_data.in_steelsight and 1 / self._equipped_unit:base():enter_steelsight_speed_multiplier() or 1

	if not unequipped then
		stance_id = self._equipped_unit:base():get_stance_id()

		if self._state_data.in_steelsight and self._equipped_unit:base().stance_mod then
			stance_mod = self._equipped_unit:base():stance_mod() or stance_mod
		end
	end

	-- geddan
--[[
	stance_mod.rotation = stance_mod.rotation * Rotation(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
	duration = 0.01
--]]


	-- shift melee weapons
	local tdmelee = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()]
	if self._state_data.meleeing and tdmelee.stance_mod then
		if tdmelee.stance_mod.translation then
			stance_mod.translation = stance_mod.translation + tdmelee.stance_mod.translation
		end
		if tdmelee.stance_mod.rotation then
			stance_mod.rotation = stance_mod.rotation * tdmelee.stance_mod.rotation
		end
	end


	-- mid-reload viewmodel adjustments aka flipturn
	local reload_timed_stances = self._equipped_unit:base()._reload_timed_stance_mod
	if self:_is_reloading() and reload_timed_stances and self._flipturn_reload_state then
		local empty = 0
		local values = reload_timed_stances.not_empty
		if self._flipturn_reload_state > 99 then
			empty = 100
			values = reload_timed_stances.empty
		end
		if values then
			if self:in_steelsight() then
				values = values.ads
			else
				values = values.hip
			end
		end
		local flipturn_index = self._flipturn_reload_state - empty
		if values and values[flipturn_index] then
			if values[flipturn_index].translation then
				stance_mod.translation = stance_mod.translation + values[flipturn_index].translation
			end
			if values[flipturn_index].rotation then
				stance_mod.rotation = stance_mod.rotation * values[flipturn_index].rotation
			end
			if values[flipturn_index].sound and (flipturn_index > self._last_flipturn_sound) then
				self._unit:sound():_play(values[flipturn_index].sound)
				self._last_flipturn_sound = flipturn_index
			end
			duration_multiplier = duration_multiplier / (values[flipturn_index].speed or 1)
			duration_multiplier = duration_multiplier / (self._equipped_unit:base():reload_speed_multiplier()/self._equipped_unit:base():standard_reload_speed_multiplier())
		end
	end

	-- shell-by-shell viewmodel adjustments
	local shotgun_ammo_stances = self._equipped_unit:base()._shotgun_ammo_stance_mod
	if self:_is_reloading() and shotgun_ammo_stances then
		local values = shotgun_ammo_stances
		if values then
			if self:in_steelsight() then
				values = values.ads
			else
				values = values.hip
			end
		end
		local ammovalue = self._equipped_unit:base():get_ammo_remaining_in_clip() + 1
		if values and values[ammovalue] then
			if values[ammovalue].translation then
				stance_mod.translation = stance_mod.translation + values[ammovalue].translation
			end
			if values[ammovalue].rotation then
				stance_mod.rotation = stance_mod.rotation * values[ammovalue].rotation
			end
			duration_multiplier = duration_multiplier / (values[ammovalue].speed or 1)
			duration_multiplier = duration_multiplier / (self._equipped_unit:base():reload_speed_multiplier()/self._equipped_unit:base():standard_reload_speed_multiplier())
		end
	end

	-- post-shooting viewmodel adjustments aka shootturn
	-- works differently than the reload ones because i don't feel like going back and unfucking how the reload shit works
	local fire_timed_stances = self._equipped_unit:base()._fire_timed_stance_mod
	if fire_timed_stances and not self:_is_reloading() then
		if self:in_steelsight() then
			fire_timed_stances = fire_timed_stances.ads
		else
			fire_timed_stances = fire_timed_stances.hip
		end

		if fire_timed_stances[self._shootturn_state] then
			if fire_timed_stances[self._shootturn_state].translation then
				stance_mod.translation = stance_mod.translation + fire_timed_stances[self._shootturn_state].translation
			end
			if fire_timed_stances[self._shootturn_state].rotation then
				stance_mod.rotation = stance_mod.rotation * fire_timed_stances[self._shootturn_state].rotation
			end
			if fire_timed_stances[self._shootturn_state].sound and (self._shootturn_state > self._last_shootturn_sound) then
				self._unit:sound():_play(fire_timed_stances[self._shootturn_state].sound)
				self._last_shootturn_sound = self._shootturn_state
			end
			duration_multiplier = duration_multiplier / (fire_timed_stances[self._shootturn_state].speed or 1)
			if self._shootturn_state == #fire_timed_stances then
				self._shootturn_state = nil
				self._last_shootturn_sound = 0
			end
		end
		duration_multiplier = duration_multiplier / (self._equipped_unit:base():fire_rate_multiplier())
	end

	-- static adjustment of stance when reloading
	if self._equipped_unit:base()._reload_stance_mod and self:_is_reloading() then
		if self._state_data.in_steelsight and self._equipped_unit:base()._reload_stance_mod.ads then
			if self._equipped_unit:base()._reload_stance_mod.ads.translation then
				stance_mod.translation = stance_mod.translation + self._equipped_unit:base()._reload_stance_mod.ads.translation
			end
			if self._equipped_unit:base()._reload_stance_mod.ads.rotation then
				stance_mod.rotation = stance_mod.rotation * self._equipped_unit:base()._reload_stance_mod.ads.rotation
			end
		elseif self._equipped_unit:base()._reload_stance_mod.hip then
			if self._equipped_unit:base()._reload_stance_mod.hip.translation then
				stance_mod.translation = stance_mod.translation + self._equipped_unit:base()._reload_stance_mod.hip.translation
			end
			if self._equipped_unit:base()._reload_stance_mod.hip.rotation then
				stance_mod.rotation = stance_mod.rotation * self._equipped_unit:base()._reload_stance_mod.hip.rotation
			end
		end
	end
	-- or while equipping
	if self._equipped_unit:base()._equip_stance_mod and self:is_equipping() then
		if self._equipped_unit:base()._equip_stance_mod.ads and self._state_data.in_steelsight then
			if self._equipped_unit:base()._equip_stance_mod.ads.translation then
				stance_mod.translation = stance_mod.translation + self._equipped_unit:base()._equip_stance_mod.ads.translation
			end
			if self._equipped_unit:base()._equip_stance_mod.ads.rotation then
				stance_mod.rotation = stance_mod.rotation * self._equipped_unit:base()._equip_stance_mod.ads.rotation
			end
		elseif self._equipped_unit:base()._equip_stance_mod.hip then
			if self._equipped_unit:base()._equip_stance_mod.hip.translation then
				stance_mod.translation = stance_mod.translation + self._equipped_unit:base()._equip_stance_mod.hip.translation
			end
			if self._equipped_unit:base()._equip_stance_mod.hip.rotation then
				stance_mod.rotation = stance_mod.rotation * self._equipped_unit:base()._equip_stance_mod.hip.rotation
			end
		end
	end
	-- or while sliding (and not ADS)
	if self._is_sliding and not self._state_data.in_steelsight then
		stance_mod.translation = stance_mod.translation + Vector3(0, -3, 0)
		stance_mod.rotation = stance_mod.rotation * Rotation(0, 0, InFmenu.settings.slidewpnangle)
	end
	if self._is_wallrunning and not self._state_data.in_steelsight then
		stance_mod.translation = stance_mod.translation + Vector3(0, -3, 0)
		stance_mod.rotation = stance_mod.rotation * Rotation(0, 0, -1 * InFmenu.settings.wallrunwpnangle)
	end
	if timemult then
		duration_multiplier = duration_multiplier * timemult
	end

	-- goldeneye
	if ((InFmenu.settings.goldeneye == 2 and self._equipped_unit:base().akimbo) or InFmenu.settings.goldeneye == 3 or self._equipped_unit:base()._use_goldeneye_reload) and self:_is_reloading() then
		stance_mod.translation = Vector3(0, 0, -100)
		stance_mod.rotation = Rotation(0, 0, 0)
	end

	local stances = nil
	stances = (self:_is_meleeing() or self:_is_throwing_projectile()) and tweak_data.player.stances.default or tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = stances.standard
	--misc_attribs = (not self:_is_using_bipod() or self:_is_throwing_projectile() or stances.bipod) and (self._state_data.in_steelsight and stances.steelsight or self._state_data.ducking and stances.crouched or stances.standard)
	misc_attribs = self:_is_using_bipod() and not self:_is_throwing_projectile() and stances.bipod or self._state_data.in_steelsight and stances.steelsight or self._state_data.ducking and stances.crouched or stances.standard
	local new_fov = self:get_zoom_fov(misc_attribs) + 0

	self._camera_unit:base():clbk_stance_entered(misc_attribs.shoulders, head_stance, misc_attribs.vel_overshot, new_fov, misc_attribs.shakers, stance_mod, duration_multiplier, duration)
	managers.menu:set_mouse_sensitivity(self:in_steelsight())
end
Hooks:PostHook(PlayerStandard, "_stance_entered", "FancyScopeCheckInF", function(self, unequipped, timemult)
	if BeardLib.Utils:FindMod("Modern Sights") then
		if not unequipped then
			if self._state_data.in_steelsight and not self:_is_reloading() then
				self:set_ads_objects(true)
			else
				self:set_ads_objects(false)
			end
		end
	end
	-- prevent low sensitivity if ADS while reloading
	managers.menu:set_mouse_sensitivity(self:in_steelsight() and not self:_is_reloading() and not self:is_equipping())
end)

Hooks:PreHook(PlayerStandard, "_update_equip_weapon_timers", "nozoomuntilequippedpre", function(self, t, input)
	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._update_postequip_stance = true
	end
end)
Hooks:PostHook(PlayerStandard, "_update_equip_weapon_timers", "nozoomuntilequippedpost", function(self, t, input)
	if self._update_postequip_stance then
		self._update_postequip_stance = nil
		self:_stance_entered() -- update zoom
	end
end)


-- faster weapon switching
-- 1 = secondary
-- 2 = primary
local old_swapfunc = PlayerStandard._get_swap_speed_multiplier
function PlayerStandard:_get_swap_speed_multiplier(...)
	local mult = old_swapfunc(self, ...)
	if self._unit then
		-- pistol-in-secondary-slot switch speed bonus
		if self._unit:inventory():unit_by_selection(1):base():is_category("pistol") and not self._unit:inventory():unit_by_selection(1):base():is_category("akimbo") then
			mult = mult * (1.20 + managers.player:upgrade_value("player", "pistol_base_switchspeed_add", 0))
			mult = mult * managers.player:upgrade_value("player", "pistol_switchspeed_buff", 1)
		end
		-- shotgun skill switch speed bonus
		if self._unit:inventory():unit_by_selection(1):base():is_category("shotgun") or self._unit:inventory():unit_by_selection(2):base():is_category("shotgun") then
			if not self._unit:inventory():unit_by_selection(2):base():is_category("akimbo") then
				mult = mult * managers.player:upgrade_value("player", "shotgun_switchspeed_buff", 1)
			end
		end
		-- empty akimbo switch speed bonus
		if self._unit:inventory():unit_by_selection(2):base():is_category("akimbo") and self._unit:inventory():unit_by_selection(2):base():clip_empty() then
			mult = mult * managers.player:upgrade_value("player", "empty_akimbo_switch", 1)
		end
		-- weapon mod switch speed bonus
		mult = mult * self._unit:inventory():unit_by_selection(1):base()._switchspeed_mult
		mult = mult * self._unit:inventory():unit_by_selection(2):base()._switchspeed_mult
	end
	return mult
end

--[[
local old_upd = PlayerStandard.update
function PlayerStandard:update(t, dt)
	old_upd(self, t, dt)
	self:update_offhand_reload(t)
	-- cancel self-tase
	if self._state_data.self_shock_expire_t and self._state_data.self_shock_expire_t < t then
		self._ext_movement:on_tase_ended()
	end
	-- too lazy to figure out where update is getting its t and dt from
end
--]]
Hooks:PostHook(PlayerStandard, "update", "infupdate", function(self, t, dt)
	if self._state_data.self_shock_expire_t and self._state_data.self_shock_expire_t < t then
		self._ext_movement:on_tase_ended()
	end
	self._last_t = t
	self._last_dt = dt

	-- check shootturn timers
	local fire_timed_stances = self._equipped_unit:base()._fire_timed_stance_mod
	if fire_timed_stances and self._shootturn_state then
		local last_shootturn_state = self._shootturn_state --
		self._last_shot_dt = self._last_t - (self._last_shot_time or 0)
		if self:in_steelsight() then
			fire_timed_stances = fire_timed_stances.ads
		else
			fire_timed_stances = fire_timed_stances.hip
		end
		for i = self._shootturn_state, #fire_timed_stances, 1 do
			if (self._last_shot_dt > fire_timed_stances[i].t) and (self._shootturn_state ~= i) then
				self._shootturn_state = i
			end
		end
		if last_shootturn_state ~= self._shootturn_state then
			self:_stance_entered()
		end
	end

	-- geddan
--[[
	self._geddan = self._geddan or 0
	if (t - 0.05) > self._geddan then
		self:_stance_entered()
		self._geddan = t
	end
--]]
end)

Hooks:PostHook(PlayerStandard, "update", "infupdate_dontcopypasteover", function(self, t, dt)
	-- Hacky VR workaround, otherwise this crashes when quitting to main menu?
	if not self or not self.update_offhand_reload then return end
	self:update_offhand_reload(t)
end)

-- reload with other weapon out
function PlayerStandard:update_offhand_reload(t)
	-- Hacky VR workaround, otherwise this crashes when quitting to main menu?
	if not self._unit:inventory():unit_by_selection(2) then return end

	local wpnbase = self._unit:inventory():unit_by_selection(2):base()
	local on_last_mag = wpnbase:get_ammo_remaining_in_clip() == wpnbase:get_ammo_total()
	--local on_last_clip = wpnbase:weapon_tweak_data().clipload and 0 >= wpnbase:get_ammo_total()
	if self.offhand_reload_t and self.offhand_reload_t < t and not on_last_mag then
		self.offhand_reload_t = nil
		self._unit:sound():play("money_grab") -- money_grab pickup_ammo pickup_fak_skill pickup_ammo_health_boost
		if not ((self._running and not self._equipped_unit:base():run_and_shoot_allowed()) or self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile()) then
			self._ext_camera:play_redirect(self:get_animation("use"))
		end

		if wpnbase:reload_shell_expire_t() then
			-- shotgun reload
			local chamber = wpnbase._chamber or 0
			wpnbase:set_ammo_remaining_in_clip(math.min(wpnbase:get_ammo_max_per_clip() + chamber, wpnbase:get_ammo_remaining_in_clip() + 1))
			managers.hud:set_ammo_amount(wpnbase:selection_index(), wpnbase:ammo_info())
		else
			-- not-shotgun reload
			local clip_amount = nil
			wpnbase:on_reload(nil, self._state_data.reload_from_empty)
			self._state_data.reload_from_empty = nil
			self._state_data.queued_half_reload = nil
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(wpnbase:selection_index(), wpnbase:ammo_info())
		end
		-- queue another reload if cliploader or shotgun
		if not wpnbase:clip_full() and (wpnbase:weapon_tweak_data().clipload or wpnbase:reload_shell_expire_t()) then
			self.offhand_reload_t = t + self:get_offhand_reload_t(t, wpnbase)
			if wpnbase:weapon_tweak_data().timers.reload_empty_half then
				self.offhand_half_reload_t = t + self:get_offhand_half_reload_t(t, wpnbase)
			end
		end
	end
	-- half-reload version
	if self.offhand_half_reload_t and self.offhand_half_reload_t < t and not on_last_mag then
		self.offhand_half_reload_t = nil
		self._unit:sound():play("money_grab") -- money_grab pickup_ammo pickup_fak_skill pickup_ammo_health_boost
		if not ((self._running and not self._equipped_unit:base():run_and_shoot_allowed()) or self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile()) then
			self._ext_camera:play_redirect(self:get_animation("use"))
		end
		local clip_amount = nil
		wpnbase:on_reload_half()
		managers.statistics:reloaded()
		managers.hud:set_ammo_amount(wpnbase:selection_index(), wpnbase:ammo_info())
	end
end

function PlayerStandard:check_offhand_reload(t, switching)
	-- get primary weapon
	local wpnbase = self._unit:inventory():unit_by_selection(2):base()

	local is_primary = Utils:IsCurrentWeaponPrimary()
	--local is_secondary = Utils:IsCurrentWeaponSecondary()
	local can_pistol = Utils:IsCurrentSecondaryOfCategory("pistol") and managers.player:upgrade_value("player", "pistol_gives_offhand_reload", false) == true
	local can_ar = Utils:IsCurrentSecondaryOfCategory("assault_rifle") and managers.player:upgrade_value("player", "ar_gives_offhand_reload", false) == true
	local can_smg = Utils:IsCurrentSecondaryOfCategory("smg") and managers.player:upgrade_value("player", "smg_gives_offhand_reload", false) == true
	local can_sho = Utils:IsCurrentSecondaryOfCategory("shotgun") and managers.player:upgrade_value("player", "shotgun_gives_offhand_reload", false) == true
	local can_xbow = Utils:IsCurrentSecondaryOfCategory("crossbow") and managers.player:upgrade_value("player", "xbow_gives_offhand_reload", false) == true

	if switching and (can_pistol or can_ar or can_smg or can_sho or can_xbow) then
		-- cancel reload if switching back to the primary
		if self.offhand_reload_t or self.offhand_half_reload_t then
			self.offhand_reload_t = nil
			self.offhand_half_reload_t = nil
			self._state_data.reload_from_empty = nil
		-- start reload timer
		elseif not wpnbase:clip_full() and is_primary then
			self.offhand_reload_t = t + self:get_offhand_reload_t(t, wpnbase)
			-- half-reloads
			if wpnbase:weapon_tweak_data().timers.reload_empty_half and not self._state_data.queued_half_reload then
				self.offhand_half_reload_t = t + self:get_offhand_half_reload_t(t, wpnbase)
				self._state_data.queued_half_reload = true
				if wpnbase:clip_empty() then
					self._state_data.reload_from_empty = true
				end
			end
		end
	end
end

--[[
local old_ccwep = PlayerStandard._check_change_weapon
function PlayerStandard:_check_change_weapon(t, input)
	local switching = old_ccwep(self, t, input)

	--self:check_offhand_reload(t, switching)
end
--]]

function PlayerStandard:_start_action_unequip_weapon(t, data)
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.unequip_speed_mult or 1) -- change speed

	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier)

	self._change_weapon_data = data
	self:check_offhand_reload(t, true) --
	self._unequip_weapon_expire_t = t + (tweak_data.timers.unequip or 0.5) / speed_multiplier

	--self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local result = self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)

	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self._ext_network:send("switch_weapon", speed_multiplier, 1)
end

Hooks:PostHook(PlayerStandard, "_start_action_unequip_weapon", "shootturn_reset", function(self, params)
	self._shootturn_state = nil
	self._last_shootturn_sound = 0
end)

Hooks:PostHook(PlayerStandard, "_start_action_equip_weapon", "inf_applyequiphipstancemod", function(self, params)
	self:_stance_entered()
end)

function PlayerStandard:get_offhand_reload_t(t, wpnbase)
	local base_reload_time = 50
	-- shotgun reload
	if wpnbase:reload_shell_expire_t() then
		base_reload_time = wpnbase:reload_shell_expire_t() + wpnbase:reload_enter_expire_t() + wpnbase:reload_not_empty_exit_expire_t()
	elseif wpnbase:clip_empty() then
		base_reload_time = self:_get_timer_reload_empty() + self:_get_timer_reload_empty_end()
	else
		base_reload_time = self:_get_timer_reload_not_empty() + self:_get_timer_reload_not_empty_end()
	end
	return (base_reload_time / wpnbase:reload_speed_multiplier() * managers.player:upgrade_value("player", "offhand_reload_time_mult", 1) / (wpnbase:weapon_tweak_data().offhand_reload_speed_mult or 1))
end

function PlayerStandard:get_offhand_half_reload_t(t, wpnbase)
	local base_reload_time = 50
	if wpnbase:clip_empty() then
		base_reload_time = wpnbase:weapon_tweak_data().timers.reload_empty_half
	else
		base_reload_time = wpnbase:weapon_tweak_data().timers.reload_not_empty_half
	end
	return (base_reload_time / wpnbase:reload_speed_multiplier() * managers.player:upgrade_value("player", "offhand_reload_time_mult", 1) / (wpnbase:weapon_tweak_data().offhand_reload_speed_mult or 1))
end


-- These fixes break in VR and I don't care about them enough to fix it there. For the time being, VR reloading acts like vanilla.

-- based on custom weapon animation fixes
-- fabarm stf-12/mossberg 590 screwing with me
-- nobody screws with me binch
DelayedCalls:Add("fuckyourreloadfunc", 0.25, function(self, params)

	local startReloadEnterOrig = PlayerStandard._start_action_reload_enter
	function PlayerStandard:_start_action_reload_enter(t)
		if _G.IS_VR then
			return startReloadEnterOrig(self, t)
		end
	
		if self._equipped_unit:base():can_reload() then
			local weapon = self._equipped_unit:base()
			local tweak_data = weapon:weapon_tweak_data()
			managers.player:send_message_now(Message.OnPlayerReload, nil, self._equipped_unit)
			if not self:_can_ads_while_reloading() or InFmenu.settings.reloadbreaksads == true then
				self:_interupt_action_steelsight(t)
			end

			-- clear previously tracked queued shell reload
			self._equipped_unit:base()._queued_shell_loaded = nil

			if not self.RUN_AND_RELOAD then
				self:_interupt_action_running(t)
			end
			if self._equipped_unit:base():reload_enter_expire_t() and not tweak_data.animations.reload_shell_by_shell then
				local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()
				speed_multiplier = speed_multiplier * (tweak_data.timers.shotgun_reload_enter_mult or 1)
				self._ext_camera:play_redirect(Idstring("reload_enter_" .. self._equipped_unit:base().name_id), speed_multiplier)
				self._state_data.reload_enter_expire_t = t + self._equipped_unit:base():reload_enter_expire_t() / speed_multiplier
				self._equipped_unit:base():tweak_data_anim_play("reload_enter", speed_multiplier)
				--self:_stance_entered() -- update zoom
				managers.menu:set_mouse_sensitivity(false)
				if BeardLib.Utils:FindMod("Modern Sights") then
					self:set_ads_objects(false)
				end
				return
			elseif self._equipped_unit:base():reload_enter_expire_t() and tweak_data.animations.reload_shell_by_shell == true then
				local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()
				speed_multiplier = speed_multiplier * (tweak_data.timers.shotgun_reload_enter_mult or 1)
				self._ext_camera:play_redirect(Idstring("reload_enter_" .. weapon:weapon_tweak_data().animations.reload_name_id), speed_multiplier)
				self._state_data.reload_enter_expire_t = t + self._equipped_unit:base():reload_enter_expire_t() / speed_multiplier
				self._equipped_unit:base():tweak_data_anim_play("reload_enter", speed_multiplier)
				--self:_stance_entered() -- update zoom
				managers.menu:set_mouse_sensitivity(false)
				if BeardLib.Utils:FindMod("Modern Sights") then
					self:set_ads_objects(false)
				end
				return
			end
			self:_stance_entered()
			self:_start_action_reload(t)
		end
	end
end)

-- add a post-reload wait, the mag updating and being allowed to shoot are no longer the exact same timer
-- custom wpn animation fixes also implemented

-- delay because gm6 lynx will override this otherwise
DelayedCalls:Add("fuckyourshitgm6", 0.5, function(self, params)

local startActionReloadOrig = PlayerStandard._start_action_reload
function PlayerStandard:_start_action_reload(t)

	if _G.IS_VR then
		return startActionReloadOrig(self, t)
	end

	local weapon = self._equipped_unit:base()

	if weapon and weapon:can_reload() then
		weapon:tweak_data_anim_stop("fire")

		local speed_multiplier = weapon:reload_speed_multiplier()
		local empty_reload = weapon:clip_empty() and 1 or 0

		if weapon._use_shotgun_reload then
			empty_reload = weapon:get_ammo_max_per_clip() - weapon:get_ammo_remaining_in_clip()
		end

		local tweak_data = weapon:weapon_tweak_data()
		local reload_anim = "reload"
		local reload_prefix = weapon:reload_prefix() or ""
		local reload_name_id = tweak_data.animations.reload_name_id or weapon.name_id

		-- also use empty reload if at 1 ammo on akimbos
		if ((weapon:clip_empty() or weapon:get_ammo_remaining_in_clip() <= (tweak_data.empty_reload_threshold or 0)) and not (tweak_data.animations.ignore_fullreload or tweak_data.animations.ignore_nonemptyreload)) or tweak_data.animations.only_fullreload then
			local reload_ids = Idstring(reload_prefix .. "reload_" .. reload_name_id)
			local result = self._ext_camera:play_redirect(reload_ids, speed_multiplier)

			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_ids)

			self._state_data.reload_expire_t = t + (self:_get_timer_reload_empty() or weapon:reload_expire_t() or 2.6)/speed_multiplier
			self._state_data.reload_expire_end_t = self._state_data.reload_expire_t + (self:_get_timer_reload_empty_end()/speed_multiplier) -- self._state_data.reload_expire_end_t
			if tweak_data.timers.reload_empty_half and tweak_data.timers.reload_empty_half < tweak_data.timers.reload_empty then
				self._state_data.reload_half_t = t + tweak_data.timers.reload_empty_half/speed_multiplier --
				self._state_data.queued_half_reload = true
				if weapon:clip_empty() then
					self._state_data.reload_from_empty = true --
				end
			end
			self._flipturn_reload_state = 100
		else
			reload_anim = "reload_not_empty"
			local reload_ids = Idstring(reload_prefix .. "reload_not_empty_" .. reload_name_id)
			local result = self._ext_camera:play_redirect(reload_ids, speed_multiplier)

			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_ids)

			self._state_data.reload_expire_t = t + (self:_get_timer_reload_not_empty() or weapon:reload_expire_t() or 2.2)/speed_multiplier
			self._state_data.reload_expire_end_t = self._state_data.reload_expire_t + (self:_get_timer_reload_not_empty_end())/speed_multiplier --
			self._state_data.queued_half_reload = true
			if tweak_data.timers.reload_not_empty_half then
				self._state_data.reload_half_t = t + tweak_data.timers.reload_not_empty_half/speed_multiplier --
			end
			self._flipturn_reload_state = 0
		end

		weapon:start_reload()
		self:_stance_entered() -- update zoom
		managers.menu:set_mouse_sensitivity(false)
		if BeardLib.Utils:FindMod("Modern Sights") then
			self:set_ads_objects(false)
		end

		if not weapon:tweak_data_anim_play(reload_anim, speed_multiplier) then
			weapon:tweak_data_anim_play("reload", speed_multiplier)
			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_anim)
		end

		self._ext_network:send("reload_weapon", empty_reload, speed_multiplier)
	end
end
end)

-- read from newraycast base before reading from wpn_stats tweak data
function PlayerStandard:_get_timer_reload_empty()
	local wpnbase = self._equipped_unit:base()
	local timer = wpnbase._reload_empty_2 or wpnbase:weapon_tweak_data().timers.reload_empty
	return timer
end
function PlayerStandard:_get_timer_reload_empty_end()
	local wpnbase = self._equipped_unit:base()
	local timer = wpnbase._reload_empty_end_2 or wpnbase:weapon_tweak_data().timers.reload_empty_end or 0
	return timer
end
function PlayerStandard:_get_timer_reload_not_empty()
	local wpnbase = self._equipped_unit:base()
	local timer = wpnbase._reload_not_empty_2 or wpnbase:weapon_tweak_data().timers.reload_not_empty
	return timer
end
function PlayerStandard:_get_timer_reload_not_empty_end()
	local wpnbase = self._equipped_unit:base()
	local timer = wpnbase._reload_not_empty_end_2 or wpnbase:weapon_tweak_data().timers.reload_not_empty_end or 0
	return timer
end

function PlayerStandard:_get_reload_expire()
	return self._state_data.reload_expire_end_t
end

local updateReloadTimers_orig = PlayerStandard._update_reload_timers
function PlayerStandard:_update_reload_timers(t, dt, input)

	if _G.IS_VR then
		return updateReloadTimers_orig(self, t, dt, input)
	end

	-- mid-reload viewmodel adjustments
	local td = self._equipped_unit:base():weapon_tweak_data()
	if self:_is_reloading() and self._flipturn_reload_state and self._equipped_unit:base()._reload_timed_stance_mod then
		local empty = 0
		local values = self._equipped_unit:base()._reload_timed_stance_mod.not_empty or {}
		if self._flipturn_reload_state >= 100 then
			empty = 100
			values = self._equipped_unit:base()._reload_timed_stance_mod.empty or {}
		end
		if self:in_steelsight() then
			values = values.ads
		else
			values = values.hip
		end
		if values then
			for a, b in pairs(values) do
				--if (self._state_data.reload_expire_end_t - t) < values[a].t and a > (self._flipturn_reload_state - empty) then
				if (self:_get_reload_expire() and ((self:_get_reload_expire() - t) < values[a].t)) and a > (self._flipturn_reload_state - empty) then
					self._flipturn_reload_state = a + empty
					self:_stance_entered()
				end
			end
		end
	end
	if not self:_is_reloading() then
		self._flipturn_reload_state = nil
		self._last_flipturn_sound = 0
	end

	if self._state_data.reload_enter_expire_t and self._state_data.reload_enter_expire_t <= t then
		self._state_data.reload_enter_expire_t = nil

		self:_start_action_reload(t)
	end
--vv
	if self._state_data.reload_expire_end_t and self._state_data.reload_expire_end_t <= t then
		self._state_data.reload_expire_end_t = nil
		self:_stance_entered() -- update zoom
		--managers.menu:set_mouse_sensitivity(self:in_steelsight())
		if BeardLib.Utils:FindMod("Modern Sights") and self:in_steelsight() then
			self:set_ads_objects(true)
		end
	end
--^^

	if self._state_data.reload_expire_t then
		local interupt = nil

		if self._equipped_unit:base():update_reloading(t, dt, self._state_data.reload_expire_t - t) then
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
			self:_stance_entered() -- update zoom
			--managers.menu:set_mouse_sensitivity(self:in_steelsight())
			if BeardLib.Utils:FindMod("Modern Sights") and self:in_steelsight() == true then
				self:set_ads_objects(true)
			end

			if self._queue_reload_interupt then
				self._queue_reload_interupt = nil
				interupt = true
				-- need to clear post-reload wait here too
				-- or shell-by-shell loaders will fail to function for as long as the reload would have taken
				self._state_data.reload_expire_end_t = nil
				self._state_data.reload_half_t = nil
			end
		end

		if self._state_data.reload_half_t and self._state_data.reload_half_t <= t and self._state_data.queued_half_reload == true then
			self._equipped_unit:base():on_reload_half() -- do half
			self._state_data.reload_half_t = nil
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
		elseif self._state_data.reload_expire_t <= t or interupt then
			managers.player:remove_property("shock_and_awe_reload_multiplier")

			self._state_data.reload_expire_t = nil
			self:_stance_entered() -- update zoom
			--managers.menu:set_mouse_sensitivity(self:in_steelsight())
			if BeardLib.Utils:FindMod("Modern Sights") and self:in_steelsight() == true then
				self:set_ads_objects(true)
			end

			if self._equipped_unit:base():reload_exit_expire_t() then
				local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()

				-- pump if loading second round into DP-12
				if self._equipped_unit:base():started_reload_empty() or (self._equipped_unit:base():get_ammo_remaining_in_clip() == 2 and self._equipped_unit:base()._is_dp12) then
					speed_multiplier = speed_multiplier * (self._equipped_unit:base():weapon_tweak_data().timers.shotgun_reload_exit_empty_mult or 1)
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self:get_animation("reload_exit"), speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_exit", speed_multiplier)
					-- dp12 no longer needs pump
					self._equipped_unit:base():set_dp12_needs_pump(false)
				else
					speed_multiplier = speed_multiplier * (self._equipped_unit:base():weapon_tweak_data().timers.shotgun_reload_exit_not_empty_mult or 1)
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_not_empty_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self:get_animation("reload_not_empty_exit"), speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_not_empty_exit", speed_multiplier)
				end
			elseif self._equipped_unit then
				if not interupt then
					self._equipped_unit:base():on_reload(nil, self._state_data.reload_from_empty)
					self._state_data.reload_from_empty = nil
					self._state_data.queued_half_reload = nil
				end

				-- alternating reload
				if self:_is_underbarrel_attachment_active() then
					self._equipped_unit:base():toggle_alternating_reload(true)
				else
					self._equipped_unit:base():toggle_alternating_reload()
				end

				managers.statistics:reloaded()
				managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

				if input.btn_steelsight_state then
					self._steelsight_wanted = true
				elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not self._equipped_unit:base():run_and_shoot_allowed() then
					self._ext_camera:play_redirect(self:get_animation("start_running"))
				end
			end
		end
	end

	if self._state_data.reload_exit_expire_t and self._state_data.reload_exit_expire_t <= t then
		self._state_data.reload_exit_expire_t = nil

		if self._equipped_unit then
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if input.btn_steelsight_state then
				self._steelsight_wanted = true
			elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not self._equipped_unit:base():run_and_shoot_allowed() then
				self._ext_camera:play_redirect(self:get_animation("start_running"))
			end

			if self._equipped_unit:base().on_reload_stop then
				self._equipped_unit:base():on_reload_stop()
			end
			self:_stance_entered() -- update zoom
		end
	end
end

-- remove post-reload wait's block on actions when interrupting reload
Hooks:PostHook(PlayerStandard, "_interupt_action_reload", "resetreloadexpireend", function(self, params)
	self._state_data.reload_expire_end_t = nil
	self._state_data.reload_half_t = nil
end)


-- detects if post-reload wait is active
local isReloadingOrig = PlayerStandard._is_reloading
function PlayerStandard:_is_reloading()

	if _G.IS_VR then
		return isReloadingOrig(self)
	end

	--return self._state_data.reload_expire_t or self._state_data.reload_enter_expire_t or self._state_data.reload_exit_expire_t
	return self._state_data.reload_expire_end_t or self._state_data.reload_enter_expire_t or self._state_data.reload_exit_expire_t -- InF
end


-- doesn't break ADS scope overlay anymore
Hooks:PostHook( PlayerStandard, "_start_action_equip_weapon", "infswitchspeed", function(self, t)
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1) --

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)

	self._equip_weapon_expire_t = t + (tweak_data.timers.equip or 0.7) / speed_multiplier

	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	managers.upgrades:setup_current_weapon()

	self._check_run_anim = true
end)

function PlayerStandard:_start_action_equip(redirect, extra_time)
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1) --

	self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7) + (extra_time or 0)

	if redirect == self:get_animation("equip") then
		self._equipped_unit:base():tweak_data_anim_stop("unequip")
		self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	end

	local result = self._ext_camera:play_redirect((redirect or self:get_animation("equip")), speed_multiplier)
end

function PlayerStandard:_play_equip_animation()
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1) --

	self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7) / speed_multiplier
	local result = self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
end


function PlayerStandard:_interupt_action_throw_projectile(t)
	if not self:_is_throwing_projectile() then
		return
	end

	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1)

	self._state_data.projectile_idle_wanted = nil
	self._state_data.projectile_expire_t = nil
	self._state_data.projectile_throw_allowed_t = nil
	self._state_data.throwing_projectile = nil
	self._camera_unit_anim_data.throwing = nil

	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()
	self:_stance_entered()
end

--[[
function PlayerStandard:_start_action_equip_weapon(t)
	if self._change_weapon_data.next then
		local next_equip = self._ext_inventory:get_next_selection()
		next_equip = next_equip and next_equip.unit

		if next_equip then
			local state = self:_is_underbarrel_attachment_active(next_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_next(false)
	elseif self._change_weapon_data.previous then
		local prev_equip = self._ext_inventory:get_previous_selection()
		prev_equip = prev_equip and next_equip.unit

		if prev_equip then
			local state = self:_is_underbarrel_attachment_active(prev_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_previous(false)
	elseif self._change_weapon_data.selection_wanted then
		local select_equip = self._ext_inventory:get_selected(self._change_weapon_data.selection_wanted)
		select_equip = select_equip and select_equip.unit

		if select_equip then
			local state = self:_is_underbarrel_attachment_active(select_equip) and "underbarrel" or "standard"

			self:set_animation_state(state)
		end

		self._ext_inventory:equip_selection(self._change_weapon_data.selection_wanted, false)
	end

	self:set_animation_weapon_hold(nil)

	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1) --

	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)

	self._equip_weapon_expire_t = t + (tweak_data.timers.equip or 0.7) / speed_multiplier

	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	managers.upgrades:setup_current_weapon()
end
--]]





-- detect if ADS is allowed (after mag updates but before being allowed to shoot)
function PlayerStandard:_is_reloading_post_update()
	return self._state_data.reload_expire_t or self._state_data.reload_enter_expire_t or self._state_data.reload_exit_expire_t
end

function PlayerStandard:_changing_weapon_unequip()
	return self._unequip_weapon_expire_t
end

function PlayerStandard:_can_ads_while_reloading()
	--return true
	return not self._equipped_unit:base()._disallow_ads_while_reloading
end


function PlayerStandard:_start_action_steelsight(t, gadget_state)
	--if self:_changing_weapon_unequip() or self:_is_reloading_post_update() or self:_interacting() or self:_is_meleeing() or self._use_item_expire_t or self:_is_throwing_projectile() or self:_on_zipline() then
	-- now checks for is_reloading_post_update, for changing_weapon_unequip instead of changing_weapon
	-- no longer checks for reload or zipline, checks for weapon being unequipped instead of the entire weapon change state
	if self:_changing_weapon_unequip() or self:_interacting() or self:_is_meleeing() or self._use_item_expire_t or self:_is_throwing_projectile() or (self:_is_reloading_post_update() and not self:_can_ads_while_reloading()) then
		self._steelsight_wanted = true

		return
	end

	if self._running and not self._end_running_expire_t then
		self:_interupt_action_running(t)

		self._steelsight_wanted = true

		return
	end

	--
	self:rollback_flipturn_reload_state()

	self:_break_intimidate_redirect(t)

	self._steelsight_wanted = false
	self._state_data.in_steelsight = true

	self:_update_crosshair_offset()
	self:_stance_entered()
	self:_interupt_action_running(t)
	self:_interupt_action_cash_inspect(t)

	local weap_base = self._equipped_unit:base()

	if gadget_state ~= nil then
		weap_base:play_sound("gadget_steelsight_" .. (gadget_state and "enter" or "exit"))
	else
		weap_base:play_tweak_data_sound("enter_steelsight")
	end

	if weap_base:weapon_tweak_data().animations.has_steelsight_stance then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 1

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._state_data.reticle_obj = weap_base.get_reticle_obj and weap_base:get_reticle_obj()

	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") then
		local closest_ray = self._equipped_unit:base():check_autoaim(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), nil, true)

		self._camera_unit:base():clbk_aim_assist(closest_ray)
	end

	self._ext_network:send("set_stance", 3, false, false)
	managers.job:set_memory("cac_4", true)
end

-- need to figure out which flipturn data to use from the top because we've switched between hipfire/ADS
Hooks:PreHook(PlayerStandard, "_end_action_steelsight", "inf_exitads", function(self, t)
	self:rollback_flipturn_reload_state()
end)

-- determine new flipturn state from the top
function PlayerStandard:rollback_flipturn_reload_state()
	if self._flipturn_reload_state then
		if self._flipturn_reload_state > 99 then
			self._flipturn_reload_state = 100
		else
			self._flipturn_reload_state = 0
		end
	end
end

--[[
function PlayerStandard:has_category(wpnid, category)
	local hascat = false
	for u, v in ipairs (tweak_data.weapon[wpnid].categories) do
		if v == category then
			hascat = true
		end
	end
	return hascat
end
--]]

function PlayerStandard:_is_fire_disallowed(t)
	return (self._state_data.fire_disallow_t or 0) > t
end


-- minigun spinup shit
Hooks:PostHook(PlayerStandard, "enter", "infaddwindupvars", function(self, params)
	self._windup_check_t = 0
	self._windup_state = 0
	self._windup_last_downsound_t = 0
end)

Hooks:PostHook(PlayerStandard, "update", "infupdatewindup", function(self, t, dt)
	if (self._windup_state > 0) and (self._windup_check_t + 0.05 < t) then
		local winddown_mult = self._equipped_unit:base()._spin_down_speed_mult or 1
		self._windup_state = math.clamp(self._windup_state - (dt * winddown_mult), 0, 50)
		if self._using_superblt and (self._windup_last_downsound_t + 0.05 < t) then
			self._windup_last_downsound_t = t
			local variant = math.clamp(math.ceil((self._windup_state/self._equipped_unit:base()._spin_up_time) * 4), 1, 4)
			self._inf_sound:post_event("windup" .. variant)
		end
	end
end)

function PlayerStandard:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile() or self:_is_deploying_bipod() or self._menu_closed_fire_cooldown > 0 or self:is_switching_stances() or self:_is_fire_disallowed(t)

		if not action_forbidden then
			self._queue_reload_interupt = nil
			local start_shooting = false

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local weap_base = self._equipped_unit:base()
				local fire_mode = weap_base:fire_mode()
				local fire_on_release = weap_base:fire_on_release()

				-- ANIMATE FASTER
				local anim_speed_mult = 1
				-- but not during bursts
				if not weap_base:in_burst_mode() then
					anim_speed_mult = weap_base:fire_rate_multiplier() or 1
				end
				if weap_base._anim_speed_mult then
					anim_speed_mult = anim_speed_mult * weap_base._anim_speed_mult
				end
				if not self._state_data.in_steelsight then
					anim_speed_mult = anim_speed_mult * (weap_base._hipfire_anim_speed_mult or 1)
				else
					anim_speed_mult = anim_speed_mult * (weap_base._ads_anim_speed_mult or 1)
				end

				if weap_base:out_of_ammo() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif weap_base.clip_empty and weap_base:clip_empty() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
						-- "saved you a keystroke" - payday 2
						if InFmenu.settings.disable_autoreload == true then
							if self:_is_using_bipod() then
								self._equipped_unit:base():tweak_data_anim_stop("fire")
							elseif fire_mode == "single" then
								if (input.btn_primary_attack_press or self._equipped_unit:base().should_reload_immediately) and not InFmenu.settings.disable_autoreload == true then
									self:_start_action_reload_enter(t)
								end
							end
						else
							new_action = true

							self:_start_action_reload_enter(t)
						end
						--managers.hud:show_hint({text = "Reload!",time = 2}) -- display message
					end
				elseif self._running and not self._equipped_unit:base():run_and_shoot_allowed() then
					self:_interupt_action_running(t)
-- minigun windup
				elseif weap_base._spin_up_time and weap_base._spin_up_time > 0 and not (self._windup_state > weap_base._spin_up_time) then
					if self._windup_check_t < t then
						self._windup_check_t = t + 0.05 -- if you're playing this at less than 20 fps you're having a shitty time anyways
						self._windup_state = math.clamp(self._windup_state + 0.05, 0, weap_base._spin_up_time + 0.10)
						self._ext_camera:play_shaker("fire_weapon_rot", 0.30 * (self._windup_state/weap_base._spin_up_time))
						weap_base:tweak_data_anim_play("fire", 0.67 + (self._windup_state/weap_base._spin_up_time)/3)
						--log(self._windup_state)
						if self._using_superblt then
							local variant = math.clamp(math.ceil((self._windup_state/weap_base._spin_up_time) * 4), 1, 4)
							self._inf_sound:post_event("windup" .. variant)
						end
					end
--
				else
					self._windup_check_t = t + 0.05 -- prevent wind-down while firing
					if not self._shooting then
						if weap_base:start_shooting_allowed() then
							local start = fire_mode == "single" and input.btn_primary_attack_press
							start = start or fire_mode ~= "single" and input.btn_primary_attack_state
							start = start and not fire_on_release
							start = start or fire_on_release and input.btn_primary_attack_release

							if start then
								weap_base:start_shooting()
								self._camera_unit:base():start_shooting()

								self._shooting = true
								self._shooting_t = t
								start_shooting = true

								if fire_mode == "auto" and weap_base._no_auto_anim == false then -- fucking akimbo bizon anims
									self._unit:camera():play_redirect(self:get_animation("recoil_enter"), anim_speed_mult)

									if (not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire) and (not weap_base.third_person_important or weap_base.third_person_important and not weap_base:third_person_important()) then
										self._ext_network:send("sync_start_auto_fire_sound")
									end
								end
							end
						else
							self:_check_stop_shooting()

							return false
						end
					end

					local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
					local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
					local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
					local suppression_mul = managers.blackmarket:threat_multiplier()
					local dmg_mul = managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)

					if managers.player:has_category_upgrade("player", "overkill_all_weapons") or weap_base:is_category("shotgun", "saw") then
						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
					end

					local health_ratio = self._ext_damage:health_ratio()
					local primary_category = weap_base:weapon_tweak_data().categories[1]
					local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category)

					if damage_health_ratio > 0 then
						local upgrade_name = weap_base:is_category("saw") and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
						local damage_ratio = damage_health_ratio
						dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
					end

					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
					dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
					local fired = nil

					-- LAST WORD (shotgun last-shell mult)
					if weap_base:weapon_tweak_data().categories[1] == "shotgun" and weap_base:get_ammo_remaining_in_clip() <= managers.player:upgrade_value("player", "shotgun_last_shell_amount", 0) and weap_base:get_ammo_max_per_clip() >= 4 then
						dmg_mul = dmg_mul * managers.player:upgrade_value("player", "shotgun_last_shell_dmg_mult", 1)
					end

					if fire_mode == "single" then
						if input.btn_primary_attack_press and start_shooting then
							fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						elseif fire_on_release then
							if input.btn_primary_attack_release then
								fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							elseif input.btn_primary_attack_state then
								weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							end
						end
					elseif input.btn_primary_attack_state then
						fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					if weap_base.manages_steelsight and weap_base:manages_steelsight() then
						if weap_base:wants_steelsight() and not self._state_data.in_steelsight then
							self:_start_action_steelsight(t)
						elseif not weap_base:wants_steelsight() and self._state_data.in_steelsight then
							self:_end_action_steelsight(t)
						end
					end

					local charging_weapon = fire_on_release and weap_base:charging()

					if not self._state_data.charging_weapon and charging_weapon then
						self:_start_action_charging_weapon(t)
					elseif self._state_data.charging_weapon and not charging_weapon then
						self:_end_action_charging_weapon(t)
					end

					new_action = true

					if fired then
						-- DP-12 animation shenanigans
						if self._equipped_unit:base()._is_dp12 then
							if self._equipped_unit:base()._dp12_needs_pump == false then
								anim_speed_mult = 0
							end
							self._equipped_unit:base():toggle_dp12_needs_pump()
						end

						managers.rumble:play("weapon_fire")

						--local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
						local weap_tweak_data = self._equipped_unit:base():weapon_tweak_data() -- make my pasta work better with weaponlib
						local shake_multiplier = weap_tweak_data.shake[self._state_data.in_steelsight and "fire_steelsight_multiplier" or "fire_multiplier"]

						self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier)
						self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier, 1, 0.15)
						self._equipped_unit:base():tweak_data_anim_stop("unequip")
						self._equipped_unit:base():tweak_data_anim_stop("equip")

						if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", anim_speed_mult) then --
							weap_base:tweak_data_anim_play("fire", anim_speed_mult) --
						end

						if (fire_mode == "single" or weap_base._no_auto_anim == true) and weap_base:get_name_id() ~= "saw" then -- FUCKING AKIMBO BIZON ANIMS
							if not self._state_data.in_steelsight and not weap_base:weapon_tweak_data().hipfire_uses_ads_anim == true then
								self._ext_camera:play_redirect(self:get_animation("recoil"), anim_speed_mult) --
							elseif weap_tweak_data.animations.recoil_steelsight then
								self._ext_camera:play_redirect(((weap_base:is_second_sight_on() or weap_base:weapon_tweak_data().ads_uses_hipfire_anim) and self:get_animation("recoil")) or self:get_animation("recoil_steelsight"), anim_speed_mult) --
							end
						end

						-- if akimbo, only apply recoil on second shot
						-- Recoil is handled on a posthook as soon as the second shot in a pair is fired, so it does not have to be handled here at all.
						if not _G.IS_VR and weap_base.akimbo then
							-- increment accumulated recoil by one
							self._camera_unit:base():recoil_kick(0, 0, 0, 0)
						else
							local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier()

							--cat_print("jansve", "[PlayerStandard] Weapon Recoil Multiplier: " .. tostring(recoil_multiplier))

							local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])
							-- use alternate stance kick multipliers as necessary
							if weap_base._rstance then
								up, down, left, right = unpack(weap_base._rstance[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])
							end

							-- apply custom_stat recoil mults
							up = up * weap_base._recoil_vertical_mult
							down = down * weap_base._recoil_vertical_mult
							left = left * weap_base._recoil_horizontal_mult * managers.player:upgrade_value("player", "recoil_h_mult", 1)
							right = right * weap_base._recoil_horizontal_mult * managers.player:upgrade_value("player", "recoil_h_mult", 1)
							-- apply ADS-specific recoil mults
							if self._state_data.in_steelsight == true then
								up = up * weap_base._ads_recoil_vertical_mult
								down = down * weap_base._ads_recoil_vertical_mult
								left = left * weap_base._ads_recoil_horizontal_mult
								right = right * weap_base._ads_recoil_horizontal_mult
							end
							if self:_is_using_bipod() then
								up = up * weap_base._bipod_recoil_vertical_mult
								down = down * weap_base._bipod_recoil_vertical_mult
								left = left * weap_base._bipod_recoil_horizontal_mult
								right = right * weap_base._bipod_recoil_horizontal_mult
							end
							if self._state_data.in_steelsight == true and self:_is_using_bipod() then
								up = up * weap_base._bipod_ads_recoil_vertical_mult
								down = down * weap_base._bipod_ads_recoil_vertical_mult
								left = left * weap_base._bipod_ads_recoil_horizontal_mult
								right = right * weap_base._bipod_ads_recoil_horizontal_mult
							end

							self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)
						end

						if self._shooting_t then
							local time_shooting = t - self._shooting_t
							local achievement_data = tweak_data.achievement.never_let_you_go

							if achievement_data and weap_base:get_name_id() == achievement_data.weapon_id and achievement_data.timer <= time_shooting then
								managers.achievment:award(achievement_data.award)

								self._shooting_t = nil
							end
						end

						if managers.player:has_category_upgrade(primary_category, "stacking_hit_damage_multiplier") then
							self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
							self._state_data.stacking_dmg_mul[primary_category] = self._state_data.stacking_dmg_mul[primary_category] or {
								nil,
								0
							}
							local stack = self._state_data.stacking_dmg_mul[primary_category]

							if fired.hit_enemy then
								stack[1] = t + managers.player:upgrade_value(primary_category, "stacking_hit_expire_t", 1)
								stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_weapon_dmg_mul_stacks or 5)
							else
								stack[1] = nil
								stack[2] = 0
							end
						end

						if weap_base.set_recharge_clbk then
							weap_base:set_recharge_clbk(callback(self, self, "weapon_recharge_clbk_listener"))
						end

						managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

						local impact = not fired.hit_enemy

						if weap_base.third_person_important and weap_base:third_person_important() then
							self._ext_network:send("shot_blank_reliable", impact)
						elseif weap_base.akimbo and not weap_base:weapon_tweak_data().allow_akimbo_autofire or fire_mode == "single" then
							self._ext_network:send("shot_blank", impact)
						end
					elseif fire_mode == "single" then
						new_action = false
					end
				end
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt = true
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end

	return new_action
end

Hooks:PostHook(PlayerStandard, "_check_action_primary_attack", "turnflip_lastshottime", function(self, t, input)
	if self._shooting and self._equipped_unit:base()._fire_timed_stance_mod then
		self._last_shot_time = t
		self._shootturn_state = 1
		self._last_shootturn_sound = 0
		self:_stance_entered()
	end
end)

-- REALLY THAT SHITTY AKIMBO BIZON FIRING ANIMATION CANNOT POSSIBLY BE THE REAL ANIMATION I MUST HAVE A MOD THAT'S SCREWING IT UP SOMEHOW
function PlayerStandard:_check_stop_shooting()
	if self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())

		local weap_base = self._equipped_unit:base()

		if not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire then
			self._ext_network:send("sync_stop_auto_fire_sound")
		end

		local fire_mode = weap_base:fire_mode()

		if fire_mode == "auto" and not self:_is_reloading() and not self:_is_meleeing() and weap_base._no_auto_anim == false then
			self._unit:camera():play_redirect(self:get_animation("recoil_exit"))
		end

		self._shooting = false
		self._shooting_t = nil
	end
end



-- set chainsaw mode active
function PlayerStandard:_start_action_melee(t, input, instant)
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	--self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	self._state_data.melee_charge_wanted = nil
	self._state_data.meleeing = true
	self._state_data.melee_start_t = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and melee_entry == "weapon" and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	if instant then
		self:_do_action_melee(t, input)

		return
	end

	self:_stance_entered()

	if self._state_data.melee_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 0)
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	self._state_data.melee_global_value = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 1)

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
	local attack_allowed_expire_t = tweak_data.blackmarket.melee_weapons[melee_entry].attack_allowed_expire_t or 0.15
	self._state_data.melee_attack_allowed_t = t + (current_state_name ~= self:get_animation("melee_attack_state") and attack_allowed_expire_t or 0)
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant

	if not instant_hit then
		self._ext_network:send("sync_melee_start")
	end

	if current_state_name == self:get_animation("melee_attack_state") then
		self._ext_camera:play_redirect(self:get_animation("melee_charge"))

		return
	end

	local offset = nil

	if current_state_name == self:get_animation("melee_exit_state") then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(self:get_animation("base"))
		offset = (1 - segment_relative_time) * 0.9
	end

	offset = math.max(offset or 0, attack_allowed_expire_t)

	self._ext_camera:play_redirect(self:get_animation("melee_enter"), nil, offset)

	-- set chainsaw mode active
	if tweak_data.blackmarket.melee_weapons[melee_entry].chainsaw == true then
		self._state_data.chainsaw_t = t + (tweak_data.blackmarket.melee_weapons[melee_entry].chainsaw_delay or 0.8)
	end
end

-- unset chainsaw mode when melee button is released and set chainsaw correctly for second/third/etc swings
local old_cam = PlayerStandard._check_action_melee
function PlayerStandard:_check_action_melee(t, input)
	local cam = old_cam(self, t, input)
	if input.btn_melee_release then
		self._state_data.chainsaw_t = nil
	end
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	if cam == true and tweak_data.blackmarket.melee_weapons[melee_entry].chainsaw == true and not self._state_data.chainsaw_t then -- don't override the other chainsaw timer on first swing
		self._state_data.chainsaw_t = t + (tweak_data.blackmarket.melee_weapons[melee_entry].repeat_chainsaw_delay or 0.2)
	end
end

-- _do_melee_damage but modified for the needs of chainsaw melees
function PlayerStandard:_do_chainsaw_damage(t)
	melee_entry = melee_entry or managers.blackmarket:equipped_melee_weapon()
	--local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	--local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	local charge_lerp_value = 0 --instant_hit and 0 or self:_get_melee_charge_lerp_value(t, melee_damage_delay)

	--self._ext_camera:play_shaker(melee_vars[math.random(#melee_vars)], math.max(0.3, charge_lerp_value))

	local sphere_cast_radius = 20
	local col_ray = nil

	if melee_hit_ray then
		col_ray = melee_hit_ray ~= true and melee_hit_ray or nil
	else
		col_ray = self:_calc_melee_hit_ray(t, sphere_cast_radius)
	end

	if col_ray and alive(col_ray.unit) then
		local damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info(charge_lerp_value)
		local damage_effect_mul = math.max(managers.player:upgrade_value("player", "melee_knockdown_mul", 1), managers.player:upgrade_value(self._equipped_unit:base():weapon_tweak_data().categories and self._equipped_unit:base():weapon_tweak_data().categories[1], "melee_knockdown_mul", 1))
		if tweak_data.blackmarket.melee_weapons[melee_entry].stats.tick_damage then
			damage = tweak_data.blackmarket.melee_weapons[melee_entry].stats.tick_damage
		end
		damage = damage * managers.player:get_melee_dmg_multiplier()
		damage_effect = damage_effect * damage_effect_mul
		col_ray.sphere_cast_radius = sphere_cast_radius
		local hit_unit = col_ray.unit

		if hit_unit:character_damage() then
			--if bayonet_melee then
			--	self._unit:sound():play("fairbairn_hit_body", nil, false)
			--else
				local hit_sfx = "hit_body"

				if hit_unit:character_damage() and hit_unit:character_damage().melee_hit_sfx then
					hit_sfx = hit_unit:character_damage():melee_hit_sfx()
				end

				self:_play_melee_sound(melee_entry, hit_sfx, self._melee_attack_var)
				self:_play_melee_sound(melee_entry, "charge", self._melee_attack_var) -- continue playing charge sound after hit instead of silence
			--end

			if not hit_unit:character_damage()._no_blood then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray
				})
				managers.game_play_central:play_impact_sound_and_effects({
					no_decal = true,
					no_sound = true,
					col_ray = col_ray
				})
			end

			--self._camera_unit:base():play_anim_melee_item("hit_body")
		elseif self._on_melee_restart_drill and hit_unit:base() and (hit_unit:base().is_drill or hit_unit:base().is_saw) then
			hit_unit:base():on_melee_hit(managers.network:session():local_peer():id())
		else
			--if bayonet_melee then
			--	self._unit:sound():play("knife_hit_gen", nil, false)
			--else
				self:_play_melee_sound(melee_entry, "hit_gen", self._melee_attack_var)
				self:_play_melee_sound(melee_entry, "charge", self._melee_attack_var) -- continue playing charge sound after hit instead of silence
			--end

			--self._camera_unit:base():play_anim_melee_item("hit_gen")
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				no_sound = true,
				col_ray = col_ray,
				effect = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
			})
		end

		local custom_data = nil

		if _G.IS_VR and hand_id then
			custom_data = {
				engine = hand_id == 1 and "right" or "left"
			}
		end

		--managers.rumble:play("melee_hit", nil, nil, custom_data)
		managers.game_play_central:physics_push(col_ray)

		local character_unit, shield_knock = nil
		local can_shield_knock = managers.player:has_category_upgrade("player", "shield_knock")

		if can_shield_knock and hit_unit:in_slot(8) and alive(hit_unit:parent()) and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
			shield_knock = true
			character_unit = hit_unit:parent()
		end

		character_unit = character_unit or hit_unit

		if character_unit:character_damage() and character_unit:character_damage().damage_melee then
			local dmg_multiplier = 1

			if not managers.enemy:is_civilian(character_unit) and not managers.groupai:state():is_enemy_special(character_unit) then
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "non_special_melee_multiplier", 1)
			else
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_damage_multiplier", 1)
			end

			dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[melee_entry].stats.weapon_type) .. "_damage_multiplier", 1)

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if stack[1] and t < stack[1] then
					dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2])
				else
					stack[2] = 0
				end
			end

			local health_ratio = self._ext_damage:health_ratio()
			local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, "melee")

			if damage_health_ratio > 0 then
				local damage_ratio = damage_health_ratio
				dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) * damage_ratio)
			end

			dmg_multiplier = dmg_multiplier * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
			local target_dead = character_unit:character_damage().dead and not character_unit:character_damage():dead()
			local target_hostile = managers.enemy:is_enemy(character_unit) and not tweak_data.character[character_unit:base()._tweak_table].is_escort and character_unit:brain():is_hostile()
			local life_leach_available = managers.player:has_category_upgrade("temporary", "melee_life_leech") and not managers.player:has_activate_temporary_upgrade("temporary", "melee_life_leech")

			if target_dead and target_hostile and life_leach_available then
				managers.player:activate_temporary_upgrade("temporary", "melee_life_leech")
				self._unit:character_damage():restore_health(managers.player:temporary_upgrade_value("temporary", "melee_life_leech", 1))
			end

			local special_weapon = tweak_data.blackmarket.melee_weapons[melee_entry].special_weapon
			local action_data = {
				variant = "melee"
			}

			if special_weapon == "taser" then
				action_data.variant = "taser_tased"
			end

			if _G.IS_VR and melee_entry == "weapon" and not bayonet_melee then
				dmg_multiplier = 0.1
			end

			action_data.damage = shield_knock and 0 or damage * dmg_multiplier
			action_data.damage_effect = damage_effect
			action_data.attacker_unit = self._unit
			action_data.col_ray = col_ray

			if shield_knock then
				action_data.shield_knock = can_shield_knock
			end

			action_data.name_id = melee_entry
			action_data.charge_lerp_value = charge_lerp_value

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if character_unit:character_damage().dead and not character_unit:character_damage():dead() then
					stack[1] = t + managers.player:upgrade_value("melee", "stacking_hit_expire_t", 1)
					stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_melee_weapon_dmg_mul_stacks or 5)
				else
					stack[1] = nil
					stack[2] = 0
				end
			end

			local defense_data = character_unit:character_damage():damage_melee(action_data)

			self:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
			self:_perform_sync_melee_damage(hit_unit, col_ray, action_data.damage)

			return defense_data
		else
			self:_perform_sync_melee_damage(hit_unit, col_ray, damage)
		end
	end

	if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
		self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
		self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
			nil,
			0
		}
		local stack = self._state_data.stacking_dmg_mul.melee
		stack[1] = nil
		stack[2] = 0
	end

	return col_ray
end


-- anim speed
function PlayerStandard:_do_action_melee(t, input, skip_damage)
	self._state_data.meleeing = nil

	-- undo melee shift
	self:_stance_entered(nil)

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local pre_calc_hit_ray = tweak_data.blackmarket.melee_weapons[melee_entry].hit_pre_calculation
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
	self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)

	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + melee_damage_delay

		if pre_calc_hit_ray then
			self._state_data.melee_hit_ray = self:_calc_melee_hit_ray(t, 20) or true
		else
			self._state_data.melee_hit_ray = nil
		end
	end

	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"

	if instant_hit then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	else
		self._ext_network:send("sync_melee_discharge")
	end

	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self._melee_attack_var = 0

	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)

		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_bayonet") or self:get_animation("melee"))
		else
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_miss_bayonet") or self:get_animation("melee_miss"))
		end
	else
		local anim_speed = tweak_data.blackmarket.melee_weapons[melee_entry].swing_anim_speed_mult
		local state = self._ext_camera:play_redirect(self:get_animation("melee_attack"), anim_speed)
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		self._melee_attack_var = anim_attack_vars and math.random(#anim_attack_vars)

		self:_play_melee_sound(melee_entry, "hit_air", self._melee_attack_var)

		local melee_item_tweak_anim = "attack"
		local melee_item_prefix = ""
		local melee_item_suffix = ""
		local anim_attack_param = anim_attack_vars and anim_attack_vars[self._melee_attack_var]

		if anim_attack_param then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_param, anim_speed)

			melee_item_prefix = anim_attack_param .. "_"
		end

		if self._state_data.melee_hit_ray and self._state_data.melee_hit_ray ~= true then
			self._camera_unit:anim_state_machine():set_parameter(state, "hit", anim_speed)

			melee_item_suffix = "_hit"
		end

		melee_item_tweak_anim = melee_item_prefix .. melee_item_tweak_anim .. melee_item_suffix

		self._camera_unit:base():play_anim_melee_item(melee_item_tweak_anim)
	end
end




-- fixes floating the melee weapon floating in place of your rifle when cancelling melee animations earlier than normally allowed
local old_meleetimers = PlayerStandard._update_melee_timers
function PlayerStandard:_update_melee_timers(t, input)
	local meleewpn = managers.blackmarket:equipped_melee_weapon()

-- CHAINSAW
	if tweak_data.blackmarket.melee_weapons[meleewpn].chainsaw == true and self._state_data.chainsaw_t and self._state_data.chainsaw_t < t then
		--log("CHAINSAWING")
		self:_do_chainsaw_damage(t)
		self._state_data.chainsaw_t = t + 0.2
	end

	-- self-damage lmao
	if self._state_data.melee_damage_delay_t and self._state_data.melee_damage_delay_t <= t and tweak_data.blackmarket.melee_weapons[meleewpn].self_damage then
		local attack_data = {damage = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].self_damage}
		-- do armor damage
		local selfdmg = self._unit:character_damage():_calc_armor_damage(attack_data)
		-- take leftover damage and deal it to health
		attack_data.damage = math.clamp(attack_data.damage - selfdmg, 0, 500)
		self._unit:character_damage():_calc_health_damage(attack_data)
		self._unit:sound():play("player_hit") -- player_hit_permadamage
	end

	-- self-tase lmao
	if self._state_data.melee_damage_delay_t and self._state_data.melee_damage_delay_t <= t and tweak_data.blackmarket.melee_weapons[meleewpn].self_shock then
		if not tweak_data.blackmarket.melee_weapons[meleewpn].self_shock_threshold or (tweak_data.blackmarket.melee_weapons[meleewpn].self_shock_threshold <= self:_get_melee_charge_lerp_value(t)) then
			-- set unshock timer
			-- longer depending on remaining ammo + 
			local missing_bullets = math.clamp(((self._equipped_unit:base():weapon_tweak_data().taser_reload_amount or self._equipped_unit:base():get_ammo_max_per_clip()) - self._equipped_unit:base():get_ammo_remaining_in_clip()), 0, 999)
			empty_mag_time = missing_bullets * (self._equipped_unit:base():weapon_tweak_data().self_shock_time_per_bullet or 0.1)
			self._state_data.self_shock_expire_t = t + 0.2 + empty_mag_time

			-- apply shock
			local shockdata = {}
			self._unit:character_damage():damage_tase(shockdata)
		end
	end

	old_meleetimers(self, t, input)

	-- allow early interrupt
	local shortener = tweak_data.blackmarket.melee_weapons[meleewpn].early_expire_t or 0
	if self._state_data.melee_expire_t and self._state_data.melee_expire_t <= t+shortener and not (self._state_data.melee_charge_wanted or self._state_data.meleeing) then
		--self:_interupt_action_melee()
		if not self:_is_meleeing() then
			return
		end

		local speed_multiplier = self:_get_swap_speed_multiplier()
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1)

		--self._unit:sound():play("interupt_melee", nil, false)
		--self:_play_melee_sound(managers.blackmarket:equipped_melee_weapon(), "hit_air", self._melee_attack_var)
		self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
		self._equipped_unit:base():tweak_data_anim_stop("unequip")
		self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
		self._camera_unit:base():unspawn_melee_item()
		self._camera_unit:base():show_weapon()

		-- return to sprinting anim if running, also don't continually do the run animation if sprint-jumping while the meleeing weapon is being put away
		if self._running and not self._is_jumping then
			if not self._equipped_unit:base():run_and_shoot_allowed() and (not self._end_running_expire_t or not self:_is_meleeing()) then
				self._ext_camera:play_redirect(self:get_animation("start_running"))
			elseif self._end_running_expire_t or self:_is_meleeing() then
				self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
			else
				self._ext_camera:play_redirect(self:get_animation("idle"))
			end
		end

		if self._state_data.melee_charge_shake then
			self._ext_camera:stop_shaker(self._state_data.melee_charge_shake)

			self._state_data.melee_charge_shake = nil
		end

		-- moved section down here to avoid fucking with the run animation check above
		self._state_data.fire_disallow_t = self._state_data.melee_expire_t
		self._state_data.melee_hit_ray = nil
		self._state_data.melee_charge_wanted = nil
		self._state_data.melee_expire_t = nil
		self._state_data.melee_repeat_expire_t = nil
		self._state_data.melee_attack_allowed_t = nil
		self._state_data.melee_damage_delay_t = nil
		self._state_data.meleeing = nil
		self._state_data.chainsaw_t = nil --

		self:_stance_entered()
	end
end


function PlayerStandard:_start_action_jump(t, action_start_data)
	-- don't fuck with the animation if melee weapon is still out
	if self._running and not self.RUN_AND_RELOAD and not self._equipped_unit:base():run_and_shoot_allowed() and not self:_is_meleeing() then
		self:_interupt_action_reload(t)
		self._ext_camera:play_redirect(self:get_animation("stop_running"), self._equipped_unit:base():exit_run_speed_multiplier())
	end

	self:_interupt_action_running(t)

	self._jump_t = t
	local jump_vec = action_start_data.jump_vel_z * math.UP

	self._unit:mover():jump()

	if self._move_dir then
		local move_dir_clamp = self._move_dir:normalized() * math.min(1, self._move_dir:length())
		self._last_velocity_xy = move_dir_clamp * action_start_data.jump_vel_xy
		self._jump_vel_xy = mvector3.copy(self._last_velocity_xy)
	else
		self._last_velocity_xy = Vector3()
	end

	self:_perform_jump(jump_vec)
end


-- disable chainsaw when interrupting
local old_interrupt = PlayerStandard._interupt_action_melee
function PlayerStandard:_interupt_action_melee(t)
	old_interrupt(self, t)
	self._state_data.chainsaw_t = nil

	local speed_multiplier = self:_get_swap_speed_multiplier()
	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (tweak_data.equip_speed_mult or 1)

	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
	self._equipped_unit:base():tweak_data_anim_stop("unequip")
	self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
end



-- allow FASTER MELEE CHARGE AAAA
local old_meleecharge = PlayerStandard._get_melee_charge_lerp_value
function PlayerStandard:_get_melee_charge_lerp_value(...)
	local value = old_meleecharge(self, ...)
	return math.clamp(value * managers.player:upgrade_value("player", "imma_chargin_mah_melee", 1), 0, 1)
end



-- sprint while meleeing
function PlayerStandard:_start_action_running(t)
	if not self._move_dir then
		self._running_wanted = true

		return
	end

	if self:on_ladder() or self:_on_zipline() then
		return
	end

	if self._shooting and not self._equipped_unit:base():run_and_shoot_allowed() --[[or self:_changing_weapon() or self:_is_meleeing()--]] or self._use_item_expire_t or self._state_data.in_air or self:_is_throwing_projectile() or self:_is_charging_weapon() then
		self._running_wanted = true

		return
	end

	if self._state_data.ducking and not self:_can_stand() then
		self._running_wanted = true

		return
	end

	if not self:_can_run_directional() then
		return
	end

	self._running_wanted = false

	if managers.player:get_player_rule("no_run") then
		return
	end

	if not self._unit:movement():is_above_stamina_threshold() then
		return
	end

	if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_headbob") then
		self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
	end

	self:set_running(true)

	self._end_running_expire_t = nil
	self._start_running_t = t
	self._play_stop_running_anim = nil

	if (not self:_is_reloading() or not self.RUN_AND_RELOAD) and not self:_is_meleeing() then
		if not self._equipped_unit:base():run_and_shoot_allowed() then
			self._ext_camera:play_redirect(self:get_animation("start_running"))
		else
			self._ext_camera:play_redirect(self:get_animation("idle"))
		end
	end

	if not self.RUN_AND_RELOAD then
		self:_interupt_action_reload(t)
	end

	self:_interupt_action_steelsight(t)
	self:_interupt_action_ducking(t)

	-- prevent stance from sticking around if interrupting flipturn with a sprint
	self:_stance_entered()
end

function PlayerStandard:_end_action_running(t)
	if not self._end_running_expire_t then
		self._check_run_anim = nil
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		local stop_running = not self._equipped_unit:base():run_and_shoot_allowed() and (not self.RUN_AND_RELOAD or not self:_is_reloading())

		if stop_running and not self:_is_meleeing() then
			self._ext_camera:play_redirect(self:get_animation("stop_running"), speed_multiplier)
		end
	end
end

Hooks:PostHook(PlayerStandard, "_update_running_timers", "inf_applyrunanim", function(self, t)
	if self._check_run_anim and not self:_changing_weapon() and self._running then
		if not self._equipped_unit:base():run_and_shoot_allowed() then
			self._ext_camera:play_redirect(self:get_animation("start_running"))
		else
			self._ext_camera:play_redirect(self:get_animation("idle"))
		end
		self._check_run_anim = nil
	end
end)



-- bow charging mult
function PlayerStandard:_start_action_charging_weapon(t)
	self._state_data.charging_weapon = true
	self._state_data.charging_weapon_data = {
		t = t,
		max_t = 2.5
	}
	local ANIM_LENGTH = 1.5
	local max = self._equipped_unit:base():charge_max_t()
	local speed_multiplier = ANIM_LENGTH / max

	--
	local wtd = self._equipped_unit:base():weapon_tweak_data()
	speed_multiplier = speed_multiplier * (wtd.charge_speed_mult or 1)

	self._equipped_unit:base():tweak_data_anim_play("charge", speed_multiplier)
	self._ext_camera:play_redirect(self:get_animation("charge"), speed_multiplier)
end



function PlayerStandard:_check_action_deploy_bipod(t, input)
	local new_action = nil
	local action_forbidden = false

	if not input.btn_deploy_bipod then
		return
	end

	action_forbidden = self:_on_zipline() or self:_is_throwing_projectile() or self:_is_meleeing() or self:is_equipping() or self:_changing_weapon() -- or self:in_steelsight()

	if not action_forbidden then
		local weapon = self._equipped_unit:base()
		local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)

		if bipod_part and bipod_part[1] then
			local bipod_unit = bipod_part[1].unit:base()

			bipod_unit:check_state()

			new_action = true
		end
	end

	return new_action
end



-- no zoom while reloading
function PlayerStandard:get_zoom_fov(stance_data)
	local fov = stance_data and stance_data.FOV or 75
	local fov_multiplier = managers.user:get_setting("fov_multiplier")

	if self._state_data.in_steelsight and not self:_is_reloading() and not self._equip_weapon_expire_t then -- _is_reloading_post_update()
		fov = self._equipped_unit:base():zoom()
		fov_multiplier = 1 + (fov_multiplier - 1) / 2
	end

	return fov * fov_multiplier
end


-- from bipods that (actually) work
function PlayerStandard:update_fov_external()
	if not alive(self._equipped_unit) then
		return
	end

	local stance_id = self._equipped_unit:base():get_stance_id()
	local stances = tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = self._state_data.in_steelsight and stances.steelsight or (self._state_data.ducking) and stances.crouched or stances.standard
	if misc_attribs then		
		local new_fov = self:get_zoom_fov(misc_attribs) + 0
	else
		local new_fov = 60
	end
	self._camera_unit:base():set_fov_instant(new_fov)
end











-- GOTTA GO FAST
--[[
local old_movespeedfunc = PlayerStandard._get_max_walk_speed
function PlayerStandard:_get_max_walk_speed(...)
	local walkspeed = old_movespeedfunc(self,...)

	return walkspeed
end
--]]
-- !! REMEMBER NOT TO COPY THE _ads_movespeed_mult OVER (or i'll just block it off)
function PlayerStandard:_get_max_walk_speed(t, force_run)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"
	local ads_mult = 1

	if self._is_sliding then
		movement_speed = self._slide_speed
		speed_state = "run"
	elseif self._is_wallrunning then
		movement_speed = self._wallrun_speed
		speed_state = "run"
	elseif self._is_wallkicking then
		movement_speed = speed_tweak.RUNNING_MAX * 1.5
		speed_state = "run"
	elseif self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and not self:_is_reloading() and not _G.IS_VR then
		-- allow full walkspeed while reloading
		movement_speed = speed_tweak.STEELSIGHT_MAX
		speed_state = "steelsight"
		-- apply speed bonus to 'base' speed, up to normal runspeed (or duckspeed, if ducking)
		-- actual movespeed is lower than this due to another multiplier
		if alive(self._equipped_unit) and self._equipped_unit:base()._ads_movespeed_mult then
			local ads_speed_cap = speed_tweak.STANDARD_MAX
			if self._state_data.ducking then
				ads_speed_cap = speed_tweak.CROUCHING_MAX
			end
			-- !! VARIABLE DOES NOT EXIST IN STANDALONE
			movement_speed = math.min(movement_speed * self._equipped_unit:base()._ads_movespeed_mult, ads_speed_cap)
		end
	elseif self:on_ladder() then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	elseif self._running or force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end

	movement_speed = managers.modifiers:modify_value("PlayerStandard:GetMaxWalkSpeed", movement_speed, self._state_data, speed_tweak)
	local morale_boost_bonus = self._ext_movement:morale_boost()
	local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, self._ext_damage:health_ratio())
	multiplier = multiplier * (self._tweak_data.movement.multiplier[speed_state] or 1) -- fuck with this if 100% movespeed while aiming is required
	local apply_weapon_penalty = true

	if self:_is_meleeing() then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		apply_weapon_penalty = not tweak_data.blackmarket.melee_weapons[melee_entry].stats.remove_weapon_movement_penalty
	end

	if alive(self._equipped_unit) and apply_weapon_penalty then
		multiplier = multiplier * self._equipped_unit:base():movement_penalty()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "increased_movement_speed") then
		multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "increased_movement_speed", 1)
	end

	local final_speed = movement_speed * multiplier

	self._cached_final_speed = self._cached_final_speed or 0

	if final_speed ~= self._cached_final_speed then
		self._cached_final_speed = final_speed

		self._ext_network:send("action_change_speed", final_speed)
	end

	--log(final_speed)
	return final_speed
end

-- returns normal walkspeed (used to determine speed threshold for beginning a slide)
function PlayerStandard:_get_modified_move_speed(state)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = 0
	local final_speed = 0

	if speed_tweak then
		movement_speed = speed_tweak.STANDARD_MAX
		local speed_state = "walk"

		if state == "crouch" then
			movement_speed = speed_tweak.CROUCHING_MAX
			speed_state = "crouch"
		elseif state == "run" then
			movement_speed = speed_tweak.RUNNING_MAX
			speed_state = "run"
		end

		movement_speed = managers.modifiers:modify_value("PlayerStandard:GetMaxWalkSpeed", movement_speed, self._state_data, speed_tweak)
		local morale_boost_bonus = self._ext_movement:morale_boost()
		local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, nil)
		multiplier = multiplier * (self._tweak_data.movement.multiplier[speed_state] or 1)

		if alive(self._equipped_unit) then
			multiplier = multiplier * self._equipped_unit:base():movement_penalty()
		end

		final_speed = movement_speed * multiplier
	end

	return final_speed
end

Hooks:PostHook(PlayerStandard, "_start_action_ducking", "slide_startducking", function(self, params)
	self:_check_slide()
end)

function PlayerStandard:_check_slide()
	if not ((managers.groupai:state():whisper_mode() and InFmenu.settings.slidestealth == 1) or (not managers.groupai:state():whisper_mode() and InFmenu.settings.slideloud == 1)) then
		if self._last_velocity_xy and (self._running or self._state_data.in_air or self._is_wallkicking) then
			-- must be moving at least a certain speed to slide
			local movedir = self._move_dir or self._last_velocity_xy -- don't use self:get_sampled_xy() in any of the other lines in here
			local velocity = Vector3()
			mvector3.set(velocity, self._last_velocity_xy)
			local horizontal_speed = mvector3.normalize(velocity)
			local walkspeed = self:_get_modified_move_speed()
			local slide_cooldown = 1
			if self._slide_dir then
				-- reduce cooldown if not attempting slide in the same direction i.e. do the speedyboi
				local slide_angle = math.atan2(self._slide_dir.y, self._slide_dir.x)
				local move_angle = math.atan2(movedir.y, movedir.x)
				local angle_diff = math.abs(move_angle - slide_angle)
				if angle_diff > 45 then
					slide_cooldown = slide_cooldown / (angle_diff/45)
				end
			end
			if (self._is_wallkicking or (horizontal_speed > (walkspeed * 1.1))) and ((self._last_t - self._last_slide_time) > slide_cooldown) then
				self._is_sliding = true
				self._slide_dir = mvector3.copy(movedir)
				self._slide_slow_add = 0
				self._slide_desired_dir = mvector3.copy(movedir)
				self._sprinting_speed = self:_get_modified_move_speed("run")
				-- make it feel like a speedy slide
				self._slide_speed = self._sprinting_speed * 1.3 --self._tweak_data.movement.speed.RUNNING_MAX * 1.3
				self._slide_refresh_t = 0
				self._slide_last_z = self._unit:position().z
				self._slide_last_speed = self._slide_speed
				self._slide_end_speed = self:_get_modified_move_speed("crouch")/4 -- don't need to calculate every frame
				self._slide_speed_factor = self._slide_speed/(self._tweak_data.movement.speed.RUNNING_MAX * 1.3) -- it's magic
				self:_stance_entered()
--[[
				if not self._state_data.in_air and managers.user:get_setting("use_headbob") then
					self._ext_camera:play_shaker("player_start_running", 1)
					self._slide_has_played_shaker = true
				end
--]]
				self._last_slide_time = self._last_t
				if not self._state_data.in_air then
					self._is_wallkicking = nil
				end
			end
		end
	end
end

Hooks:PostHook(PlayerStandard, "_end_action_ducking", "slide_stopducking", function(self, params)
	self:_cancel_slide()
end)

Hooks:PostHook(PlayerStandard, "_determine_move_direction", "slide_movedir", function(self)
    if self._is_sliding then
		if self._move_dir then
			local slide_angle = math.atan2(self._slide_dir.y, self._slide_dir.x)
			local move_angle = math.atan2(self._move_dir.y, self._move_dir.x)
			-- use difference between slide and move angles to figure out if the player's trying to slow down
			local angle_diff = math.abs(math.abs(move_angle - slide_angle) - 180)
			if angle_diff < 30 then -- less than x degrees from 180 (rear angle)
				self._slide_slow_add = 1600
			elseif angle_diff < 60 then
				self._slide_slow_add = 800
			elseif angle_diff < 90 then
				self._slide_slow_add = 400
			elseif angle_diff < 120 then
				self._slide_slow_add = 200
			else
				self._slide_slow_add = 0
			end

			self._slide_desired_dir = mvector3.copy(self._move_dir)
			mvector3.multiply(self._slide_desired_dir, 0.2) -- level of control over slide direction
		elseif (managers.groupai:state():whisper_mode() and InFmenu.settings.slidestealth == 2) or (not managers.groupai:state():whisper_mode() and InFmenu.settings.slideloud == 2) then
			-- put on the superbrakes
			self._slide_slow_add = 1600
		end
		-- continue moving in slide direction
		self._move_dir = self._slide_dir
	end
	if (self._is_wallkicking or self._is_wallrunning) and not self._is_sliding then
		-- check user input direction to see if we should apply the brakes
		if self._is_wallrunning then
			self._wallrun_slow_add = 0
			if self._move_dir then
				local wallrun_vel = self:_get_sampled_xy()
				local wallrun_angle = math.atan2(wallrun_vel.y, wallrun_vel.x)
				local move_angle = math.atan2(self._move_dir.y, self._move_dir.x)
				local angle_diff = math.abs(math.abs(move_angle - wallrun_angle) - 180)
				-- angle diff is angle away from 180 (rear)
				if angle_diff < 90 then
					self._wallrun_slow_add = 800
				else
					self._wallrun_slow_add = 0
				end
			end
		end
		if self._is_wallkicking and (self._last_zdiff and self._last_zdiff < -0.33) then
			self._last_vault_boost_t = self._last_vault_boost_t or 0
			if self._unit:mover() and ((self._last_t - self._last_wallkick_t) > 0.3) and ((self._last_t - self._last_vault_boost_t) > 0.5) then
				-- small forward boost to vault over walls
				-- only applied if aiming high enough
				local rotation_flat = self._ext_camera:rotation()
				mvector3.set_x(rotation_flat, 0)
				mvector3.set_y(rotation_flat, 0)
				local facing_vec = Vector3(0, 50, 0)
				mvector3.rotate_with(facing_vec, rotation_flat)
				--self._last_velocity_xy = self._last_velocity_xy + facing_vec
				self._unit:mover():set_velocity(self._unit:sampled_velocity() + facing_vec)
				self._last_vault_boost_t = self._last_t
			end
		end
		self._move_dir = nil
	end
end)

Hooks:PostHook(PlayerStandard, "_end_action_ducking", "slide_stopducking", function(self, params)
	self:_cancel_slide()
end)

Hooks:PostHook(PlayerStandard, "_update_movement", "slide_update", function(self, t, dt)
	self:_check_wallkick(t, dt)

	if self._is_sliding then
		if not self._state_data.in_air then
			-- calculate stamina drain scaling based on current speed vs standard running speed
			local drain_mult = self._slide_speed/self._sprinting_speed
			-- drain stamina, prevent regen
			self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE * dt * drain_mult)
			if drain_mult > 0.50 then
				self._unit:movement():_restart_stamina_regen_timer()
			end
		end

		-- slow slide down as it continues
		self._slide_speed = math.clamp(self._slide_speed - ((400 + self._slide_slow_add) * dt * self._slide_speed_factor^2), 0, 1500)

		local last_refresh_dt = t - self._slide_refresh_t
		if self._slide_refresh_t and last_refresh_dt > 0.1 then

			if not self._state_data.in_air and (t - self._last_jump_t) > 0.20 then
				-- play slide-start stuff
				if not self._slide_has_played_shaker then
					if managers.user:get_setting("use_headbob") then
						self._ext_camera:play_shaker("player_start_running", 1)
					end
					self._slide_has_played_shaker = true
					if self._using_superblt then
						local choice = math.random(1, 2)
						self._inf_sound:post_event("slide_enter" .. choice)
					end
				end
				-- slide loops n shit
				if (t - self._last_snd_slide_t) > 0.20 then
					self._last_snd_slide_t = t
					self._last_snd_slide = self._last_snd_slide or 0
					self._last_snd_slide = (self._last_snd_slide % 6) + 1
					local pitch = ""
					if self._last_speed > (self._slide_end_speed * 5) then
						pitch = ""
					elseif self._last_speed > (self._slide_end_speed * 3) then
						pitch = "slow"
					elseif self._last_speed > (self._slide_end_speed * 2) then
						pitch = "slower"
					else
						pitch = "slowest"
					end
					if self._using_superblt then
						self._inf_sound:post_event("slide_loop" .. self._last_snd_slide .. pitch)
					end
				end
			end

			-- change speed depending on change in z position
			local current_z = self._unit:position().z
			local downspeed = self._slide_last_z - current_z
			-- prevent massive bullshit accelerations from wallkick elevation converting to speed
			if ((t - self._last_wallkick_t) > 0.3) then
				self._slide_speed = self._slide_speed + (downspeed * 10 * last_refresh_dt * self._slide_speed_factor^2)
			end
			self._slide_refresh_t = t
			self._slide_last_z = current_z

			-- apply change of direction
			if self._move_dir then
				mvector3.add(self._slide_dir, self._slide_desired_dir)
				mvector3.normalize(self._slide_dir) -- normalize or the gun goes shakey shakey
			end
		end
		-- kick fools
		if ((t - self._last_movekick_enemy_t) > 0.5) then
			local has_kicked = self:_do_movement_melee_damage(nil, self._is_wallkicking) -- do it really hard if you're still in midair
			if has_kicked then
				self._last_movekick_enemy_t = t
			end
		end

		-- update last known speed
--[[
		local vel = Vector3()
		mvector3.set(vel, self._last_velocity_xy)
		self._slide_last_speed = mvector3.normalize(vel)
--]]

		-- end slide if too slow
		-- grace period for wallkicking to prevent slide from failing because it's detecting a low pre-kick-acceleration speed
		if self._last_speed < (self._slide_end_speed) and ((t - self._last_wallkick_t) > 0.3) then
			self:_cancel_slide(3)
		end
	elseif self._is_wallkicking or self._is_dashing then
		-- coming in from that wallkick
		if not self._state_data.in_air then
			self._is_wallkicking = nil
		end
		if ((t - self._last_movekick_enemy_t) > 0.5) then
			local has_kicked = self:_do_movement_melee_damage(nil, self._is_wallkicking) -- megakick if wallkicking
			if has_kicked then
				self._last_movekick_enemy_t = t
			end
		end
		-- transition to slide bby
		if self._state_data.ducking then
			self:_check_slide()
		end
	elseif self._running and (InFmenu.settings.runkick == true or self._state_data.in_air) then
		-- sprinting
		if ((t - self._last_movekick_enemy_t) > 0.5) then
			local has_kicked = self:_do_movement_melee_damage(true, nil)
			if has_kicked then
				self._last_movekick_enemy_t = t
			end
		end
	end
end)

Hooks:PostHook(PlayerStandard, "_update_movement", "check_wallrun_update", function(self, t, dt)
	local tapping_sprint = self._controller:get_input_pressed("run")
	-- relaxed wallrun conditions to enable jump maps
	-- allow wallrunning while bouncing from wall to wall without explicitly enabling 
	local wallkick_off_cooldown = (self._is_wallkicking and ((t - self._last_wallkick_t) > 0.2))
	local dmgkick_off_cooldown = ((t - self._last_movekick_enemy_t) > 1)
	local holding_jump = self._controller:get_input_bool("jump")
	if not holding_jump and self._state_data.in_air and (tapping_sprint or wallkick_off_cooldown) and dmgkick_off_cooldown and mvector3.normalize(self:_get_sampled_xy()) > 0 then
		-- reduce cooldown if hitting a different wall
		local lenghtmult = 1
		if wallkick_off_cooldown then
			lengthmult = 1.5
		end
		local nearest_ray1 = self:_get_nearest_wall_ray_dir(lenghtmult, nil, nil, 0)
		local nearest_ray2 = self:_get_nearest_wall_ray_dir(lenghtmult, nil, nil, 40)
		local nearest_ray = nearest_ray1 or nearest_ray2
		if nearest_ray and self._last_wallrun_dir then
			local last_angle = math.atan2(self._last_wallrun_dir.y, self._last_wallrun_dir.x)
			local current_angle = math.atan2(nearest_ray.dir.y, nearest_ray.dir.x)
			local angle_diff = 180 - math.abs(((last_angle - current_angle) % 360) - 180)
			if angle_diff < 45 then
				self._new_wallrun_delay = 1.0
				if self._last_zdiff and self._last_zdiff < -0.25 then
					-- prevent wallrun from catching on the wall you just tried to jump up
					-- positive zdiff = downwards
					self._new_wallrun_delay = self._new_wallrun_delay * 3
				end
			else
				self._new_wallrun_delay = 0
			end
		end
		local wallrun_on_cooldown = (t - self._last_wallrun_t) < (self._new_wallrun_delay or 0)
		if not self._is_wallrunning and not wallrun_on_cooldown and self._unit:movement():is_above_stamina_threshold() and not self:on_ladder() and nearest_ray then
			self._sprinting_speed = self:_get_modified_move_speed("run")
			self._wallrun_speed = self._sprinting_speed * 1.5
			self._wallrun_last_speed = self._wallrun_speed
			self._wallrun_end_speed = self:_get_modified_move_speed("crouch")
			self._wallrun_speed_factor = self._wallrun_speed/(self._tweak_data.movement.speed.RUNNING_MAX * 1.3)
			self._is_wallrunning = true
			self:_stance_entered()
			if self._unit:mover() then
				--log("starting wallrun")
				local sampled_xy = mvector3.copy(self:_get_sampled_xy())
				mvector3.normalize(sampled_xy)
				mvector3.multiply(sampled_xy, self._wallrun_last_speed)
				self._unit:mover():set_gravity(Vector3(0, 0, 0))
				self._unit:mover():set_velocity(sampled_xy)
			end
			self._last_wallrun_dir = nearest_ray.dir
		end
	end

	if self._is_wallrunning then
		-- drain stamina, prevent regen
		self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE * dt * (self._wallrun_last_speed/self._sprinting_speed))
			self._unit:movement():_restart_stamina_regen_timer()

		-- keep pushing player along the wall
		if self._unit:mover() then
			local sampled_xy = mvector3.copy(self:_get_sampled_xy())
			mvector3.normalize(sampled_xy)
			mvector3.multiply(sampled_xy, self._wallrun_last_speed)
			self._unit:mover():set_velocity(sampled_xy)
		end

		-- slow wallrun down as it continues
		self._wallrun_last_speed = math.clamp(self._wallrun_last_speed - ((300 + (self._wallrun_slow_add or 0)) * dt * self._wallrun_speed_factor^2), 0, 1500)
		if self._wallrun_last_speed < self._wallrun_end_speed then
			self:_cancel_wallrun(t, "fall", 3)
			--log("ending wallrun: too slow")
		end
--[[
		if not self._state_data.in_air then
			self:_cancel_wallrun(t)
			--log("ending wallrun: hit ground")
		end
--]]
		if (t - self._last_wallrun_t > 0.1) then
			self._last_wallrun_t = t
			if self:on_ladder() or not self:_get_nearest_wall_ray_dir(1.5) then
				self._end_wallrun_kick_dir = self:_get_end_wallrun_kick_dir()
				self:_cancel_wallrun(t, fall)
				--log("ending wallrun: failed to detect wall")
			end
		end
	end
end)


function PlayerStandard:_check_action_jump(t, input)
	local new_action = nil
	local action_wanted = input.btn_jump_press

	-- kick off with force if jumping from wallrun
	if self._is_wallrunning and action_wanted then
--[[
		--log("ending wallrun: jumped")
		-- put wallhang on cooldown
--]]
		self:_cancel_wallrun(t, "jump")
	elseif action_wanted then
		local action_forbidden = self._jump_t and t < self._jump_t + 0.55
		action_forbidden = action_forbidden or self._unit:base():stats_screen_visible() or self._state_data.in_air or self:_interacting() or self:_on_zipline() or self:_does_deploying_limit_movement() or self:_is_using_bipod()

		if not action_forbidden then
			-- don't check for ducking anymore
			if self._state_data.on_ladder then
				self:_interupt_action_ladder(t)
			end

			local action_start_data = {}
			local jump_vel_z = tweak_data.player.movement_state.standard.movement.jump_velocity.z
			action_start_data.jump_vel_z = jump_vel_z

			if self._move_dir then
				local is_running = self._running and self._unit:movement():is_above_stamina_threshold() and t - self._start_running_t > 0.4
				local jump_vel_xy = tweak_data.player.movement_state.standard.movement.jump_velocity.xy[is_running and "run" or "walk"]
				action_start_data.jump_vel_xy = jump_vel_xy

				if is_running then
					self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN)
				end
			end

			--self._slide_has_played_shaker = nil -- play shaker again after landing
			new_action = self:_start_action_jump(t, action_start_data)
		end
	end

	return new_action
end

function PlayerStandard:_cancel_slide(timemult)
	self._is_sliding = nil
	self._slide_has_played_shaker = nil
	self:_stance_entered(nil, timemult)
end

Hooks:PostHook(PlayerStandard, "enter", "reset_advmov_enter", function(self, params)
	self:_cancel_slide()
	self._slide_end_speed = self:_get_modified_move_speed("crouch")/4 -- don't need to calculate every frame

	self._last_snd_slide_t = 0
	self._last_jump_t = 0

	self._last_slide_time = 0
	self._last_wallrun_t = 0
	self._is_wallkicking = nil
	self._wallkick_is_clinging = nil
	self._wallkick_hold_start_t = nil
	self._last_wallkick_t = 0
	self._last_movekick_enemy_t = 0
end)

Hooks:PostHook(PlayerStandard, "init", "reset_advmov_init", function(self, params)
	self._last_snd_slide_t = 0
	self._last_jump_t = 0

	self._last_slide_time = 0
	self._last_wallrun_t = 0
	self._is_wallkicking = nil
	self._wallkick_is_clinging = nil
	self._wallkick_hold_start_t = nil
	self._last_wallkick_t = 0
	self._last_movekick_enemy_t = 0

	if blt and blt.xaudio then
		self._using_superblt = true
	end
	if self._using_superblt then
		self._inf_sound = SoundDevice:create_source("inf_sounds")
		--self._inf_sound:set_position(managers.player:player_unit():position())
	end
end)


function PlayerStandard:_check_step(t)
	-- don't make footstep noises while sliding
	-- but do make footstep noises while wallrunning
	if (self._state_data.in_air and not self._is_wallrunning) or self._is_sliding then
		return
	end

	self._last_step_pos = self._last_step_pos or Vector3()
	local step_length = self._state_data.on_ladder and 50 or self._state_data.in_steelsight and (managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and 150 or 100) or self._state_data.ducking and 125 or self._running and 175 or 150

	if mvector3.distance_sq(self._last_step_pos, self._pos) > step_length * step_length then
		mvector3.set(self._last_step_pos, self._pos)
		self._unit:base():anim_data_clbk_footstep()
	end
end





-- lets me quickly adjust how far the detection rays should go
local wallslide_values = {60} -- minimum of 50-51?
wallslide_values[2] = wallslide_values[1] * 0.707 -- sin 45
wallslide_values[3] = wallslide_values[1] * 0.924 -- cos 22.5/sin 67.5
wallslide_values[4] = wallslide_values[1] * 0.383 -- sin 22.5/cos 67.5

--[[
function PlayerStandard:_check_wallrun_rays(all_directions)
	local playerpos = managers.player:player_unit():position()
	-- only get one axis of rotation so facing up doesn't end the wallrun via not detecting a wall to run on
	local rotation_flat = self._ext_camera:rotation()
	mvector3.set_x(rotation_flat, 0)
	mvector3.set_y(rotation_flat, 0)

	local ray_left = Vector3()
	mvector3.set(ray_left, playerpos)
	local ray_left_adjust = Vector3(-1 * wallslide_values[1], 0, 0)
	mvector3.rotate_with(ray_left_adjust, rotation_flat)
	mvector3.add(ray_left, ray_left_adjust)
	local left_check = Utils:GetCrosshairRay(playerpos, ray_left)

	local ray_right = Vector3()
	mvector3.set(ray_right, playerpos)
	local ray_right_adjust = Vector3(wallslide_values[1], 0, 0)
	mvector3.rotate_with(ray_right_adjust, rotation_flat)
	mvector3.add(ray_right, ray_right_adjust)
	local right_check = Utils:GetCrosshairRay(playerpos, ray_right)

	local ray_forward = nil
	local ray_back = nil

	if all_directions then
		ray_forward = Vector3()
		mvector3.set(ray_forward, managers.player:player_unit():position())
		local ray_forward_adjust = Vector3(0, wallslide_values[1], 0)
		mvector3.rotate_with(ray_forward_adjust, rotation_flat)
		mvector3.add(ray_forward, ray_forward_adjust)
		forward_check = Utils:GetCrosshairRay(playerpos, ray_forward)

		ray_back = Vector3()
		mvector3.set(ray_back, managers.player:player_unit():position())
		local ray_back_adjust = Vector3(0, -1 * wallslide_values[1], 0)
		mvector3.rotate_with(ray_back_adjust, rotation_flat)
		mvector3.add(ray_back, ray_back_adjust)
		back_check = Utils:GetCrosshairRay(playerpos, ray_back)
	end

	return (left_check or right_check or forward_check or back_check)
end
--]]

function PlayerStandard:_get_end_wallrun_kick_dir(mult)
	local magnitude = mult or 20 

	-- have a slight kick-off so you don't look like you're just sliding down a window pane
	local shortest_ray_dir = self:_get_nearest_wall_ray_dir(2)

	-- make it point the other way
	local final_vector = Vector3(0, 0, 0)
	if shortest_ray_dir and shortest_ray_dir.dir then
		mvector3.set(final_vector, shortest_ray_dir.dir)
	end
	final_vector = self:_reverse_vector(final_vector)
	mvector3.normalize(final_vector)
	mvector3.multiply(final_vector, magnitude)

	return final_vector
end

function PlayerStandard:_reverse_vector(vector)
	local new_vector = Vector3(0, 0, 0)
	mvector3.subtract(new_vector, vector)
	return new_vector
end

function PlayerStandard:_get_nearest_wall_ray_dir(ray_length_mult, raytarget, only_frontal_rays, z_offset)
	local length_mult = ray_length_mult or 1
	local playerpos = managers.player:player_unit():position()
	if z_offset then
		mvector3.add(playerpos, Vector3(0, 0, z_offset))
	end
	-- only get one axis of rotation so facing up doesn't end the wallrun via not detecting a wall to run on
	local rotation = self._ext_camera:rotation()
	mvector3.set_x(rotation, 0)
	mvector3.set_y(rotation, 0)
	local shortest_ray_dist = 10000
	local shortest_ray_dir = nil
	local shortest_ray = nil
	local first_ray_dist = 10000
	local first_ray_dir = nil
	local first_ray = nil

	-- alternate table to check more than cardinal and intercardinal directions
	local ray_adjust_table = nil
	if not self._nearest_wall_ray_dir_state then
		self._nearest_wall_ray_dir_state = true
		ray_adjust_table = {
			{-1 * wallslide_values[2], wallslide_values[2]}, -- 315, forward-left
			{0, wallslide_values[1]}, -- 360/0, forward
			{wallslide_values[2], wallslide_values[2]}, -- 45, forward-right
			{wallslide_values[1], 0}, -- 90, right
			{wallslide_values[2], -1 * wallslide_values[2]}, -- 135, back-right
			{0, -1 * wallslide_values[1]}, -- 180, back
			{-1 * wallslide_values[2], -1 * wallslide_values[2]}, -- 225, back-left
			{-1 * wallslide_values[1], 0} -- 270, left
		}
		if only_frontal_rays then
			ray_adjust_table[4] = nil
			ray_adjust_table[5] = nil
			ray_adjust_table[6] = nil
			ray_adjust_table[7] = nil
			ray_adjust_table[8] = nil
		end
	else
		self._nearest_wall_ray_dir_state = nil
		ray_adjust_table = {
			{-1 * wallslide_values[4], wallslide_values[3]}, -- 292.5
			{-1 * wallslide_values[3], wallslide_values[4]}, -- 337.5
			{wallslide_values[3], wallslide_values[4]}, -- 22.5
			{wallslide_values[4], wallslide_values[3]}, -- 67.5
			{wallslide_values[4], -1 * wallslide_values[3]}, -- 112.5
			{wallslide_values[3], -1 * wallslide_values[4]}, -- 157.5
			{-1 * wallslide_values[3], -1 * wallslide_values[4]}, -- 202.5
			{-1 * wallslide_values[4], -1 * wallslide_values[3]} -- 247.5
		}
		if only_frontal_rays then
			--ray_adjust_table[4] = nil
			ray_adjust_table[5] = nil
			ray_adjust_table[6] = nil
			ray_adjust_table[7] = nil
			ray_adjust_table[8] = nil
		end
	end

	for i = 1, #ray_adjust_table do
		local ray = Vector3()
		mvector3.set(ray, playerpos)
		local ray_adjust = Vector3(ray_adjust_table[i][1] * length_mult, ray_adjust_table[i][2] * length_mult, 0)
		mvector3.rotate_with(ray_adjust, rotation)
		mvector3.add(ray, ray_adjust)
		local ray_check = Utils:GetCrosshairRay(playerpos, ray)
		if ray_check and (shortest_ray_dist > ray_check.distance) then
			-- husks use different data reee
			local is_enemy = managers.enemy:is_enemy(ray_check.unit) and ray_check.unit:brain():is_hostile() -- exclude sentries
			local is_shield = ray_check.unit:in_slot(8) and alive(ray_check.unit:parent())
			local enemy_not_surrendered = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._surrendered or ray_check.unit:brain():surrendered())
			local enemy_not_joker = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._converted or (ray_check.unit:brain()._logic_data and ray_check.unit:brain()._logic_data.is_converted))
			local enemy_not_trading = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._logic_data and ray_check.unit:brain()._logic_data.name == "trade") -- i don't know how to check for trading on husk
			if raytarget == "enemy" and ((is_enemy and enemy_not_surrendered and enemy_not_joker and enemy_not_trading) or is_shield) then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
			elseif raytarget == "breakable" and ray_check.unit:damage() and not ray_check.unit:character_damage() then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
			elseif not raytarget then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
			end
		end
	end

	if shortest_ray_dist == 10000 then
		return nil
	else
		return {dir = shortest_ray_dir, raydata = shortest_ray}
	end
end


function PlayerStandard:_cancel_wallrun(t, kick_off_mode, timemult)
	local exit_wallrun_vel = Vector3()
	if self._unit:mover() and self._end_wallrun_kick_dir and kick_off_mode == "fall" then
		mvector3.add(exit_wallrun_vel, self._end_wallrun_kick_dir)
		self._unit:mover():set_velocity(exit_wallrun_vel)
	end

	if self._unit:mover() then
		self._unit:mover():set_gravity(Vector3(0, 0, -982))
	end

	if kick_off_mode == "jump" then
--[[
		local speed = self:_get_modified_move_speed("run")
		local kick_dir = Vector3(0, speed, 0)
		local rotation = self._ext_camera:rotation()
		mvector3.set_x(rotation, 0)
		mvector3.set_y(rotation, 0)
		--mvector3.set_z(rotation, 0)
		mvector3.rotate_with(kick_dir, rotation)
		-- mvector3.rotate_with(kick_dir, self._ext_camera:rotation())
		mvector3.add(exit_wallrun_vel, kick_dir)
		mvector3.add(exit_wallrun_vel, Vector3(0, 0, tweak_data.player.movement_state.standard.movement.jump_velocity.z))
--]]
		self:_do_wallkick()
	end

	self._is_wallrunning = nil
	self._last_wallrun_t = t
	self._last_wallkick_t = t
	self:_stance_entered(nil, timemult)
end

function PlayerStandard:_get_sampled_xy()
	--local vel = Vector3()
	--mvector3.set(vel, self._unit:sampled_velocity())
	local vel = mvector3.copy(self._unit:sampled_velocity())
	mvector3.set_z(vel, 0)
	return vel
end

function PlayerStandard:_do_wallkick()
	-- ending wallhang by wallkicking
	-- kick off of wall in the direction you're facing
	local fast_kickoff = false
	local final_vel = Vector3(0, 0, 0)
	--local nearest_wall_ray = self:_get_nearest_wall_ray_dir(2) -- extra long or the player can end up floating instead of wallkicking because the nearest wall isn't detected
	local nearest_ray1 = self:_get_nearest_wall_ray_dir(2, nil, nil, 0)
	local nearest_ray2 = self:_get_nearest_wall_ray_dir(2, nil, nil, 40)
	local nearest_wall_ray = nearest_ray1 or nearest_ray2
	local speed = self:_get_modified_move_speed("run")
	local kick_dir = Vector3(0, speed * 1.5, 0)
	local rotation = managers.player:equipped_weapon_unit():rotation()
	local rotation_flat = self._ext_camera:rotation()
	mvector3.set_x(rotation_flat, 0)
	mvector3.set_y(rotation_flat, 0)

	-- i have no idea how to read from rotations so you get this instead
	-- actual facing with vertical component
	local facing_vec = Vector3(0, 1, 0)
	mvector3.rotate_with(facing_vec, rotation)
	-- same xy direction, no elevation
	local forward_vec = Vector3(0, 1, 0)
	mvector3.rotate_with(forward_vec, rotation_flat)
	-- get difference to determine if player is facing over or under horizon
	local zdiff = forward_vec.z - facing_vec.z
	if true then --zdiff > 0 then
		fast_kickoff = true
	end

	if nearest_wall_ray and nearest_wall_ray.dir then
		self._last_wallrun_dir = nearest_wall_ray.dir
		--if fast_kickoff then
			-- 'fast' wallkick
			-- kick in direction player is facing
			--mvector3.multiply(kick_dir, 1.35) -- this mattered when fast/slow wallkicks were separate
			mvector3.rotate_with(kick_dir, rotation)
			mvector3.add(final_vel, kick_dir)

			-- vertical boost so you don't automatically fly into the ground regardless of trajectory
			mvector3.add(final_vel, Vector3(0, 0, 300 + (300 * zdiff)))

			-- vertical reduction if aiming upwards so you can't leap over houses in a single bound or some shit
			if zdiff < 0 then
				mvector3.add(final_vel, Vector3(0, 0, speed * zdiff * 0.5))
			end

			if self._unit:mover() then
				self._unit:mover():set_velocity(final_vel)
				self._unit:mover():set_gravity(Vector3(0, 0, -982))
			end

			self._last_zdiff = zdiff
--[[
		else
			-- 'slow' wallkick
			-- only apply horizontal direction
			mvector3.rotate_with(kick_dir, rotation_flat)
			mvector3.add(final_vel, kick_dir)

			-- scale jump value down if aiming too close to nearest wall
			local jump_amount = tweak_data.player.movement_state.standard.movement.jump_velocity.z
			local kick_angle = math.atan2(kick_dir.y, kick_dir.x)
			local wall_angle = math.atan2(nearest_wall_ray.dir.y, nearest_wall_ray.dir.x)
			-- the math continues to drive me up the wall
			local angle_diff = 180 - math.abs(((kick_angle - wall_angle) % 360) - 180)
			if angle_diff < 120 then
				jump_amount = (jump_amount*angle_diff)/120
			end
			mvector3.add(final_vel, Vector3(0, 0, jump_amount * 0.50))
		end

		if self._unit:mover() then
			self._unit:mover():set_velocity(final_vel)
			self._unit:mover():set_gravity(Vector3(0, 0, -982))
		end
--]]
	end

	if self._using_superblt then
		self._inf_sound:post_event("kick_off")
	else
		self._unit:sound():_play("footstep_land")
	end
	self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN)
	self._unit:movement():_restart_stamina_regen_timer()
	self._is_wallkicking = true
end

function PlayerStandard:_check_wallkick(t, dt)
	if ((t - self._last_wallkick_t) > 1.0) or self._is_wallkicking then
		local action_wanted = self._controller:get_input_bool("jump")
		local ads_mult = 1
		if self:in_steelsight() then
			ads_mult = 0.25
		end

		if action_wanted and self._state_data.in_air then
			local nearest_ray = self:_get_nearest_wall_ray_dir()

			-- check if wall angle is too close to the last one to prevent chain-jumping across single flat walls
			-- if you're gonna break a map you gotta at least earn it with some sick zig-zag hopping
			if nearest_ray and self._last_wallkick_dir then
				local last_angle = math.atan2(self._last_wallkick_dir.y, self._last_wallkick_dir.x)
				local current_angle = math.atan2(nearest_ray.dir.y, nearest_ray.dir.x)
				local angle_diff = 180 - math.abs(((last_angle - current_angle) % 360) - 180)
				if angle_diff < 45 then
					self._new_wallhang_delay = 0.75
				else
					self._new_wallhang_delay = 0
				end
			end
			local wallkick_on_cooldown = (self._is_wallkicking and (t - self._last_wallkick_t) < 0.25 + (self._new_wallhang_delay or 0))

			if not self._wallkick_hold_start_t then
				-- check if holding jump for long enough to cling (don't have to be touching wall yet, just prevent cases of clinging to things you're trying to jump on top of)
				self._wallkick_hold_start_t = t
			elseif self._wallkick_is_clinging and ((t - self._wallkick_hold_start_t) > 6) then
				-- slide down at full speed w/o ADS slowdown
				if self._unit:mover() then
					self._unit:mover():set_gravity(Vector3(0, 0, -982))
				end
				self._wallkick_is_clinging = nil
			elseif self._wallkick_is_clinging and ((t - self._wallkick_hold_start_t) > 4) then
				-- slide down at full speed w/ADS slowdown
				if self._unit:mover() then
					self._unit:mover():set_gravity(Vector3(0, 0, -550 * ads_mult))
				end
			elseif self._wallkick_is_clinging and ((t - self._wallkick_hold_start_t) > 2) then
				-- slide down at full speed w/ADS slowdown
				if self._unit:mover() then
					self._unit:mover():set_gravity(Vector3(0, 0, -300 * ads_mult))
				end
			elseif self._wallkick_is_clinging and ((t - self._wallkick_hold_start_t) > 0.3) then
				-- slide down wall very slowly while clinging
				if self._unit:mover() then
					self._unit:mover():set_gravity(Vector3(0, 0, -150 * ads_mult))
				end
			elseif ((t - self._wallkick_hold_start_t) > 0.15 or self._is_wallrunning) and not self._wallkick_is_clinging then
				if not wallkick_on_cooldown and nearest_ray and nearest_ray.raydata and nearest_ray.raydata.unit and not managers.enemy:is_enemy(nearest_ray.raydata.unit) and not nearest_ray.raydata.unit:in_slot(8) then
					-- cling to wall
					-- cancel out remaining vertical velocity since we're literally disabling the player's gravity
					if self._unit:mover() then
						self._unit:mover():set_gravity(Vector3(0, 0, 0))
						self._unit:mover():set_velocity(Vector3(0, 0, 0))
					end
					mvector3.multiply(self._last_velocity_xy, 0.05)
					mvector3.set_z(self._last_velocity_xy, 0)
					self._wallkick_is_clinging = true

					-- set last wall dir
					self._last_wallkick_dir = nearest_ray.dir
				end
			end
		end

		-- end wallhang if not holding jump or has landed
		if not action_wanted or not self._state_data.in_air then
			if self._wallkick_is_clinging and self._state_data.in_air and self._unit:movement():is_above_stamina_threshold() then
--[[
				-- ending wallhang by wallkicking
				-- kick off of wall in the direction you're facing
				local fast_kickoff = false
				local final_vel = Vector3(0, 0, 0)
				local nearest_wall_ray = self:_get_nearest_wall_ray_dir(2) -- extra long or the player can end up floating instead of wallkicking because the nearest wall isn't detected
				local speed = self:_get_modified_move_speed("run")
				local kick_dir = Vector3(0, speed * 1.50, 0)
				local rotation = self._ext_camera:rotation()
				local rotation_flat = self._ext_camera:rotation()
				mvector3.set_x(rotation_flat, 0)
				mvector3.set_y(rotation_flat, 0)

				-- i have no idea how to read from rotations so you get this instead
				-- actual facing with vertical component
				local facing_vec = Vector3(0, 1, 0)
				mvector3.rotate_with(facing_vec, rotation)
				-- same xy direction, no elevation
				local forward_vec = Vector3(0, 1, 0)
				mvector3.rotate_with(forward_vec, rotation_flat)
				-- get difference to determine if player is facing over or under horizon
				--log(forward_vec.z - facing_vec.z)
				if (forward_vec.z - facing_vec.z) > 0 then
					fast_kickoff = true
				end

				if nearest_wall_ray and nearest_wall_ray.dir then
					if fast_kickoff then
						-- kick in direction player is facing
						mvector3.multiply(kick_dir, 1.50)
						mvector3.rotate_with(kick_dir, rotation)
						mvector3.add(final_vel, kick_dir)

						-- vertical boost so you don't automatically fly into the ground regardless of trajectory
						mvector3.add(final_vel, Vector3(0, 0, 200))

						if self._unit:mover() then
							self._unit:mover():set_velocity(final_vel)
							self._unit:mover():set_gravity(Vector3(0, 0, -982))
						end
					else
						-- only apply horizontal direction
						mvector3.rotate_with(kick_dir, rotation_flat)
						mvector3.add(final_vel, kick_dir)

						-- scale jump value down if aiming too close to nearest wall
						local jump_amount = tweak_data.player.movement_state.standard.movement.jump_velocity.z
						local kick_angle = math.atan2(kick_dir.y, kick_dir.x)
						local wall_angle = math.atan2(nearest_wall_ray.dir.y, nearest_wall_ray.dir.x)
						-- the math continues to drive me up the wall
						local angle_diff = 180 - math.abs(((kick_angle - wall_angle) % 360) - 180)
						if angle_diff < 120 then
							jump_amount = (jump_amount*angle_diff)/120
						end
						mvector3.add(final_vel, Vector3(0, 0, jump_amount * 0.50))
					end

					if self._unit:mover() then
						self._unit:mover():set_velocity(final_vel)
						self._unit:mover():set_gravity(Vector3(0, 0, -982))
					end
				end
--]]
				self:_do_wallkick()

				-- put wallrun on cooldown
				self._last_wallrun_t = t
				self._is_wallkicking = true
				self._wallkick_is_clinging = nil
				self._wallkick_hold_start_t = nil
				self._last_wallkick_t = t
			else
				-- ending wallhang by landing
				self._wallkick_hold_start_t = nil
				self._wallkick_is_clinging = nil
				if self._unit:mover() and not self._state_data.on_ladder and not self._is_wallrunning then -- zipline don't have no mover lmao
					self._unit:mover():set_gravity(Vector3(0, 0, -982))
				end
			end
		end
	end
end

-- DON'T FORGET TO CHANGE THE INFMENU TO ADVMOV WHEN COPYING CHANGES OVER DOOFUS
function PlayerStandard:_do_movement_melee_damage(forward_only, strongkick)
	local enemy_ray1 = self:_get_nearest_wall_ray_dir(2, "enemy", forward_only, nil)
	local enemy_ray2 = self:_get_nearest_wall_ray_dir(2, "enemy", forward_only, 70)
	local enemy_ray = enemy_ray1 or enemy_ray2

	local breakable_ray1 = nil
	local breakable_ray2 = nil
	if not enemy_ray then
		breakable_ray1 = self:_get_nearest_wall_ray_dir(1, "breakable", forward_only)
		breakable_ray2 = self:_get_nearest_wall_ray_dir(1, "breakable", forward_only, 70)
	end
	local breakable_ray = breakable_ray1 or breakable_ray2

	if enemy_ray or breakable_ray then
		local target_ray_data = enemy_ray or breakable_ray
		local targetunit = target_ray_data.raydata.unit

		-- kick away if hitting an enemy/shield
		local finaltarget = targetunit
		if enemy_ray then
			local speed = self:_get_modified_move_speed("run")
			local kick_dir = target_ray_data.dir
			kick_dir = self:_reverse_vector(kick_dir)
			mvector3.normalize(kick_dir)
			mvector3.multiply(kick_dir, speed * 0.50)
			local jump_amount = tweak_data.player.movement_state.standard.movement.jump_velocity.z
			mvector3.add(kick_dir, Vector3(0, 0, jump_amount * 0.25))
			if self._unit:mover() then
				self._unit:mover():set_velocity(kick_dir)
			end
			local hit_sfx = "hit_body"
			if finaltarget:character_damage() and finaltarget:character_damage().melee_hit_sfx then
				hit_sfx = finaltarget:character_damage():melee_hit_sfx()
			end
			if self._using_superblt then
				if strongkick then
					self._inf_sound:post_event("kick_heavy")
				else
					self._inf_sound:post_event("kick_light")
				end
			else
				self:_play_melee_sound("fists", hit_sfx, 0)
				--self:_play_melee_sound("fists", "hit_gen", 0)
			end

			self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.5)
			self._unit:movement():_restart_stamina_regen_timer()
		end

		self._wallkick_hold_start_t = nil

		local can_shield_knock = managers.player:has_category_upgrade("player", "shield_knock") or not target_ray_data.raydata.unit:in_slot(8) -- can hit shields in the back
		local dmg_data = {
			damage = 5.0,
			damage_effect = 50.0,
			attacker_unit = self._unit,
			col_ray = target_ray_data.raydata,
			name_id = "wallkick",
			charge_lerp_value = 0,
			shield_knock = can_shield_knock			
		}
		-- this goes here so i can just copy paste this to standalone without manually changing values
		if not BeardLib.Utils:FindMod("irenfist") then
			dmg_data.damage = 18.0
			dmg_data.damage_effect = 200.0
		end
		if targetunit:in_slot(8) and alive(targetunit:parent()) and not targetunit:parent():character_damage():is_immune_to_shield_knockback() then
			-- shield behaviors
			dmg_data.damage = 0
			finaltarget = targetunit:parent()
		end
		if finaltarget and finaltarget:character_damage() and finaltarget:character_damage().damage_melee and dmg_data then -- blanket "what the fuck is crashing" prevention since i don't know how to reproduce it consistently
			local atk_dir_z_offset = -100
			local is_bulldozer = finaltarget:base():has_tag("tank")
			if strongkick and not is_bulldozer then
				dmg_data.damage = dmg_data.damage * 2
				dmg_data.variant = "counter_spooc"
				atk_dir_z_offset = atk_dir_z_offset * 2
			end
			-- hit enemy
			-- apply damage
			finaltarget:character_damage():damage_melee(dmg_data)
			self:_perform_sync_melee_damage(finaltarget, target_ray_data.raydata, dmg_data.damage)
			-- push corpse around
			-- don't push live targets, they'll ragdoll
			if finaltarget:character_damage()._health <= 0 then
				local hit_pos = mvector3.copy(finaltarget:movement():m_pos())
				local attack_dir = hit_pos - self._unit:movement():m_head_pos() - Vector3(0, 0, atk_dir_z_offset)
				local distance = mvector3.normalize(attack_dir)
				-- attack dir also controls how ridiculous the ragdoll push is
				-- Vector3(0, 0, 1) bounces directly upwards
				local magnitude = 1
				if strongkick then
					magnitude = 1.5
				end
				if InFmenu.settings.kickyeet then
					magnitude = magnitude * InFmenu.settings.kickyeet
				end
				mvector3.multiply(attack_dir, magnitude)
				managers.game_play_central:do_shotgun_push(finaltarget, target_ray_data.raydata.hit_position, attack_dir, distance)
			end
			self:_cancel_slide()
			self._ext_camera:play_shaker("player_start_running", 1)
		elseif finaltarget and not finaltarget:character_damage() and finaltarget:damage() and dmg_data then
			-- hit object
			-- core\lib\units\coreunitdamage.lua
			-- observe as exactly one argument is used
			if not managers.groupai:state():whisper_mode() then
				finaltarget:damage():add_damage(nil, nil, nil, nil, nil, nil, dmg_data.damage, nil, nil)
				self:_perform_sync_melee_damage(finaltarget, target_ray_data.raydata, dmg_data.damage)
			end
		else
			log("AAAAAAAAAAAAA WHY IS DUMB KICK NO WORK")
		end
		return true
	end
	return nil
end

Hooks:PostHook(PlayerStandard, "_update_movement", "dash_update", function(self, t, dt)
	if InFmenu.settings.dashcontrols and InFmenu.settings.dashcontrols > 1 then
		local input = self._controller:get_input_axis("move")
		local zero_input = (input.x == 0) and (input.y == 0)
		local input_matches_dash_dir = self._dash_dir and (input.x == self._dash_dir.x) and (input.y == self._dash_dir.y)
		local dash_off_cooldown = (t - (self._last_dash_time or 0)) > 0.80
		local dash_conditions = dash_off_cooldown and not self:on_ladder()

		if not self._state_data.in_air then
			local input_not_matching_or_zero = not zero_input and not input_matches_dash_dir
			local within_doubletap_window = ((t - (self._dash_primed_t or 0)) <= 0.15) and ((t - (self._dash_initial_tap_t or 0)) <= 0.30)
			local dash_primed_timeout = not within_doubletap_window
			local doubletap_conditions = (zero_input and within_doubletap_window) and (InFmenu.settings.dashcontrols == 3 or InFmenu.settings.dashcontrols == 4)
			local keybind_conditions = (HoldTheKey and HoldTheKey:Keybind_Held("inf_dash") and not self._running and not zero_input) and (InFmenu.settings.dashcontrols == 2 or InFmenu.settings.dashcontrols == 4)

			if input_matches_dash_dir and self._dash_stage == 2 then
				-- player has tapped for the second time
				self._dash_stage = 3
				self._dash_primed_t = t
			elseif dash_off_cooldown and ((self._dash_stage == 3 and doubletap_conditions) or keybind_conditions) then
				-- player has released for the second time (and not held down the input)
				local dir = self._dash_dir or input
				local dashed = self:_do_dash(dir)
				if dashed then
					self._dash_dir = nil
					self._dash_stage = 0
				end
			elseif input_not_matching_or_zero then
				-- initial tap/input different from previous
				self._dash_dir = input
				self._dash_stage = 1
				self._dash_initial_tap_t = t
			elseif dash_primed_timeout and self._dash_stage and (self._dash_stage > 2) then
				-- reset, previous readied dash timed out
				self._dash_dir = nil
				self._dash_stage = 0
			elseif zero_input and self._dash_stage == 1 then
				-- player has released input for the first time
				self._dash_stage = 2
			end

-- old immediately-dash-on-second-input implementation
--[[
			local within_doubletap_window = ((t - (self._dash_primed_t or 0)) < 0.10)
			local keybind_conditions = (HoldTheKey and HoldTheKey:Keybind_Held("inf_dash") and not self._running and not zero_input) and (InFmenu.settings.dashcontrols == 2 or InFmenu.settings.dashcontrols == 4)
			local doubletap_conditions = (input_matches_dash_dir and self._dash_stage and self._dash_stage == 2 and within_doubletap_window) and (InFmenu.settings.dashcontrols == 3 or InFmenu.settings.dashcontrols == 4)
			if dash_conditions and (keybind_conditions or doubletap_conditions) then
				local dashed = self:_do_dash(input)
				if dashed then
					self._dash_dir = nil
					self._dash_stage = 0
				end
			elseif not zero_input then
				-- initial input/input different from previous
				self._dash_dir = input
				self._dash_stage = 1
			elseif zero_input and self._dash_stage == 1 then
				-- player has released previous input (to double-tap)
				self._dash_stage = 2
				self._dash_primed_t = t
			end
--]]
		end

		if self._is_dashing and ((t - (self._last_dash_time or 0)) > 0.30) then
			self._is_dashing = nil
			--self._unit:camera():camera_unit():base():set_target_tilt(0)
		end
	end
end)

function PlayerStandard:_do_dash(input)
	if not (managers.player:current_state() == "mask_off" or managers.player:current_state() == "civilian") then
		-- check if carrying a bag
		local my_carry_data = managers.player:get_my_carry_data()
		local dash_mult = 1
		local dash_height_mult = 1
		if my_carry_data then
			-- and use its movespeed to scale down dash distance
			local carried_type = tweak_data.carry[my_carry_data.carry_id].type
			if tweak_data.carry.types[carried_type] then
				dash_mult = tweak_data.carry.types[carried_type].move_speed_modifier
				dash_height_mult = tweak_data.carry.types[carried_type].jump_modifier
			end
		end
		if self._unit:mover() then
			local rotation_flat = self._ext_camera:rotation()
			mvector3.set_x(rotation_flat, 0)
			mvector3.set_y(rotation_flat, 0)
			mvector3.rotate_with(input, rotation_flat)
			mvector3.multiply(input, (500 * dash_mult))
			mvector3.add(input, Vector3(0, 0, 200 * dash_height_mult))
			self._last_velocity_xy = input
			self._unit:mover():set_velocity(self._last_velocity_xy)
			self._last_dash_time = self._last_t
			self._ext_camera:play_shaker("player_land", 0.5)
			self._unit:sound():_play("footstep_land")
			self._is_dashing = true
			--self._unit:camera():camera_unit():base():set_target_tilt(3)
			self._unit:movement():_restart_stamina_regen_timer()
			return true
		end
	end
	return false
end

function PlayerStandard:_is_doing_advanced_movement()
	return self._is_sliding or self._is_wallkicking or self._is_wallrunning or self._is_dashing
end

function PlayerStandard:_advanced_movement_stamina_mult()
	if self._is_wallkicking or self._is_wallrunning then
		return 1.5
	else
		return 1
	end
end


function PlayerStandard:_advanced_movement_dodge_bonus()
	if self._is_dashing then
		return 0.20
	elseif self._is_sliding or self._is_wallkicking or self._is_wallrunning then
		return 0.10
	else
		return 0
	end
end

Hooks:PostHook(PlayerStandard, "_calculate_standard_variables", "wtfismyrealspeed", function(self, t, dt)
	self._last_speed = mvector3.normalize(self._unit:sampled_velocity())
	--log(self._last_speed)
	-- cannot trust last_velocity_xy
end)

Hooks:PostHook(PlayerStandard, "_start_action_jump", "set_jump_var_plox", function(self, t, action_start_data)
	self._last_jump_t = t
end)

--[[
function PlayerStandard:_get_ground_normal()
	local playerpos = mvector3.copy(managers.player:player_unit():position())
	local downpos = mvector3.copy(managers.player:player_unit():position() + Vector3(0, 0, -40))
	return ground_ray = Utils:GetCrosshairRay(playerpos, downpos)	
end
--]]
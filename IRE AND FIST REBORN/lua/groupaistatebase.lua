dofile(ModPath .. "infcore.lua")

-- On certain heists like Shacklethorne, set a 30 second delay before stuff starts spawning
if InFmenu.settings.enablenewassaults then
	Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "inf_badheist_spawn_delay_setwhispermode", function(self, enabled)

		if enabled then
			return
		end

		local job = Global.level_data and Global.level_data.level_id

		if job and IREnFIST.bad_heist_overrides[job] and IREnFIST.bad_heist_overrides[job].initial_spawn_delay then
			-- Set the difficulty to 0 to force no spawns
			local current_difficulty = self._difficulty_value
			self:set_difficulty(0)
			log("[InF] Set difficulty to 0 due to bad heist " .. job)

			-- After the specified delay, set the difficulty back to normal to allow spawns again
			DelayedCalls:Add("inf_badheist_dospawndelay", IREnFIST.bad_heist_overrides[job].initial_spawn_delay, function()
				self:set_difficulty(current_difficulty)
				log("[InF] Spawn delay on bad heist " .. job .. " expired, setting difficulty back to " .. current_difficulty)
			end)
		end

	end)
end

-- Gameover now happens after ~30 seconds instead of 10 seconds, allowing Stockholm Syndrome to function correctly
function GroupAIStateBase:check_gameover_conditions()
	if not Network:is_server() or managers.platform:presence() ~= "Playing" or setup:has_queued_exec() then
		return false
	end

	if game_state_machine:current_state().game_ended and game_state_machine:current_state():game_ended() then
		return false
	end

	if Global.load_start_menu or Application:editor() then
		return false
	end

	if not self:whisper_mode() and self._super_syndrome_peers and self:hostage_count() > 0 then
		for _, active in pairs(self._super_syndrome_peers) do
			if active then
				return false
			end
		end
	end

	local plrs_alive = false
	local plrs_disabled = true

	for u_key, u_data in pairs(self._player_criminals) do
		plrs_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			plrs_disabled = false

			break
		end
	end

	local ai_alive = false
	local ai_disabled = true

	for u_key, u_data in pairs(self._ai_criminals) do
		ai_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			ai_disabled = false

			break
		end
	end

	local gameover = false

	if not plrs_alive and not self:is_ai_trade_possible() then
		gameover = true
	elseif plrs_disabled and not ai_alive then
		gameover = true
	elseif plrs_disabled and ai_disabled then
		gameover = true
	end

	gameover = gameover or managers.skirmish:check_gameover_conditions()

	if gameover then
		if not self._gameover_clbk then
			self._gameover_clbk = callback(self, self, "_gameover_clbk_func")

			managers.enemy:add_delayed_clbk("_gameover_clbk", self._gameover_clbk, Application:time() + 30)
		end
	elseif self._gameover_clbk then
		managers.enemy:remove_delayed_clbk("_gameover_clbk")

		self._gameover_clbk = nil
	end

	return gameover
end

if InFmenu.settings.assaulttweakstype == 3 then
	-- Fix difficulty scaling in newer heists (starting at max procedural difficulty instead of a lower one)
	function GroupAIStateBase:set_difficulty(script_value, manual_value)
		if self._difficulty_value == 1 then
			return
		end
	
		if script_value then
			if script_value == 0 then
				self._difficulty_value = 0

				self._loud_diff_set = false 
				self:_calculate_difficulty_ratio()
	
				return
			elseif not self._loud_diff_set and script_value > 0  then

				self._difficulty_value = self._difficulty_value + 0.5
				self:_calculate_difficulty_ratio()
				self._loud_diff_set = true
	
				return
			end
	
		end
	
		if not manual_value then
			return
		end
	
	

		self._difficulty_value = self._difficulty_value + manual_value
	
		if self._difficulty_value > 1 then
			self._difficulty_value = 1
		end
	
		self:_calculate_difficulty_ratio()
	end
end

-- Optimize AI attention objects away in loud by unregistering the ones that don't matter.
-- Copied from Think Faster, and is therefore disabled if Think Faster is installed.
-- For compatibility reasons, this feature is also disabled if "Think Faster" is disabled in InF's options.
-- There is usually no need to *not* play with this fix, so that is not recommended unless you have another mod that fixes this already.
if not IREnFIST.mod_compatibility.think_faster and InFmenu.settings.thinkfaster then

	-- Holds removed attention objects. This is necessary for maps that might switch from loud back to stealth.
	local removed_attention_objects = {}

	local function is_attention_obj_unnecessary_for_loud(attention_object)
		return not attention_object.nav_tracker and not attention_object.unit:vehicle_driving() or attention_object.unit:in_slot(1) or attention_object.unit:in_slot(17) and attention_object.unit:character_damage()
	end

	local function unregister_attention_objects(self)
		local ai_attention_objects = self:get_all_AI_attention_objects()

		for u_key, attention_object in pairs(ai_attention_objects) do
			if is_attention_obj_unnecessary_for_loud(attention_object) then
				removed_attention_objects[u_key] = attention_object
				attention_object.handler:set_attention(nil)
			end
		end
	end

	local function reregister_attention_objects(self)
		local ai_attention_objects = self:get_all_AI_attention_objects()

		for u_key, attention_object in pairs(removed_attention_objects) do
			-- First, check if the attention object was actually registered again in the meantime. If so, skip it.
			-- If not registered, check if it still exists and is valid.
			if ai_attention_objects[u_key] then
				removed_attention_objects[u_key] = nil
			elseif attention_object and alive(attention_object.unit) then
				self:register_AI_attention_object(attention_object.unit, attention_object.handler, attention_object.nav_tracker, attention_object.team, attention_object.SO_access)
				removed_attention_objects[u_key] = nil
			end
		end
	end

	-- When stealth is enabled/disabled, unregister or re-register "attention objects" that are only useful in stealth (broken windows, corpses, etc.)
	-- Thanks RedFlame for bringing this to my attention!
	Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "inf_thinkfaster_unregister_attentionobjects_on_loud", function(self, enabled)
		-- Perform as server only
		if Network and not Network:is_server() then
			return
		end

		if enabled then
			-- Going stealth, register previously disabled attention objects again
			reregister_attention_objects(self)
		else
			-- Going loud, unregister useless attention objects
			unregister_attention_objects(self)
		end
	end)

	-- Additionally, when a new object is registered, check if it should actually be registered or not.
	local register_attention_obj_orig = GroupAIStateBase.register_AI_attention_object
	function GroupAIStateBase:register_AI_attention_object(unit, handler, nav_tracker, team, SO_access)
		-- In stealth, always register the object normally
		if managers.groupai:state():whisper_mode() then
			return register_attention_obj_orig(self, unit, handler, nav_tracker, team, SO_access)
		end

		local attention_obj = {
			unit = unit,
			handler = handler,
			nav_tracker = nav_tracker,
			team = team,
			SO_access = SO_access
		}

		if is_attention_obj_unnecessary_for_loud(attention_obj) then
			-- Object is unnecessary, add it to the local table of removed objects so that it could still be re-added later
			removed_attention_objects[unit:key()] = attention_obj
		else
			-- Object is necessary for loud, register it normally
			return register_attention_obj_orig(self, unit, handler, nav_tracker, team, SO_access)
		end    
	end

end

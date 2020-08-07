dofile(ModPath .. "infcore.lua")

-- On certain heists like Shacklethorne, set a 30 second delay before stuff starts spawning
Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "inf_badheist_spawn_delay_setwhispermode", function(self, enabled)

    if enabled then
        return
    end

    local job = Global.level_data and Global.level_data.level_id

    if job and IreNFist.bad_heist_overrides[job] and IreNFist.bad_heist_overrides[job].initial_spawn_delay then
        -- Set the difficulty to 0 to force no spawns
        local current_difficulty = self._difficulty_value
        self:set_difficulty(0)
        log("[InF] Set difficulty to 0 due to bad heist " .. job)

        -- After the specified delay, set the difficulty back to normal to allow spawns again
        DelayedCalls:Add("inf_badheist_dospawndelay", IreNFist.bad_heist_overrides[job].initial_spawn_delay, function()
            self:set_difficulty(current_difficulty)
            log("[InF] Spawn delay on bad heist " .. job .. " expired, setting difficulty back to " .. current_difficulty)
        end)
    end

end)

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

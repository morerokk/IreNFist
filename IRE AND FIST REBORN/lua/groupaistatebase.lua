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

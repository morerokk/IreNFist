dofile(ModPath .. "infcore.lua")

function HUDManager:set_holdout_indicator_enabled(enabled)
    self._teammate_panels[HUDManager.PLAYER_PANEL]:set_holdout_indicator_enabled(enabled)
end

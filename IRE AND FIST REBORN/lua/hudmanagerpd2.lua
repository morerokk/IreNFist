dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.beta then
    return
end

function HUDManager:set_holdout_indicator_enabled(enabled)
    self._teammate_panels[HUDManager.PLAYER_PANEL]:set_holdout_indicator_enabled(enabled)
end

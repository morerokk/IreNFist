dofile(ModPath .. "infcore.lua")

if IreNFist.mod_compatibility.wolfhud then
    function HUDManager:set_holdout_indicator_enabled(enabled)

    end
else
    function HUDManager:set_holdout_indicator_enabled(enabled)
        self._teammate_panels[HUDManager.PLAYER_PANEL]:set_holdout_indicator_enabled(enabled)
    end
end
dofile(ModPath .. "infcore.lua")

function HUDManager:set_holdout_indicator_enabled(enabled)
	if self._teammate_panels[HUDManager.PLAYER_PANEL] and self._teammate_panels[HUDManager.PLAYER_PANEL].set_holdout_indicator_enabled then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_holdout_indicator_enabled(enabled)
	end
end

function HUDManager:set_bulletstorm_charge_enabled(enabled)
	if self._teammate_panels[HUDManager.PLAYER_PANEL] and self._teammate_panels[HUDManager.PLAYER_PANEL].set_bulletstorm_charge_enabled then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_bulletstorm_charge_enabled(enabled)
	end
end

function HUDManager:set_bulletstorm_charge_level(level)
	if self._teammate_panels[HUDManager.PLAYER_PANEL] and self._teammate_panels[HUDManager.PLAYER_PANEL].set_bulletstorm_charge_level then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_bulletstorm_charge_level(level)
	end
end

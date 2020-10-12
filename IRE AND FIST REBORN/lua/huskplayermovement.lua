dofile(ModPath .. "infcore.lua")

-- When a client starts interacting, send a cop to try and arrest them
if InFmenu.settings.enablenewcopbehavior then
	Hooks:PostHook(HuskPlayerMovement, "sync_interaction_anim_start", "inf_huskstartinteract_sendcoptoarrest", function(self)
		-- Only the host should send cops
		if Network and Network:is_client() then
			return
		end

		CopUtils:SendCopToArrestPlayer(self._unit)
	end)
end

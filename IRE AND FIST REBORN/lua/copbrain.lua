-- Similarly to CopMovement, HRT's sometimes spawn without a team set.
-- This function is called to sync the units to late joiners. To prevent possible crashes, substitute a default team if none is set.
Hooks:PreHook(CopBrain, "save", "inf_setbraincopteam", function(self, save_data)
	if not self._logic_data.team then
		-- This function on CopMovement will also apply the changes to CopBrain
		self:movement():set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end)

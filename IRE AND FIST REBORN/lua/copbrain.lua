dofile(ModPath .. "infcore.lua")

if InFmenu.settings.enablenewassaults then
	-- Similarly to CopMovement, HRT's sometimes spawn without a team set.
	-- This function is called to sync the units to late joiners. To prevent possible crashes, substitute a default team if none is set.
	Hooks:PreHook(CopBrain, "save", "inf_setbraincopteam", function(self, save_data)
		if not self._logic_data.team then

			local team = managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")]
			self._logic_data.team = team

			-- Avoid crashes when movement is nil
			-- Not just movement() is nil but sometimes even the movement function doesn't fucking exist?
			if not self.movement or not self:movement() then
				return
			end
			self:movement():set_team(team)
		end
	end)
end

-- Taken verbatim from Skill Overhaul, registers a converted cop so we can call them over more easily later to revive the player.
Hooks:PostHook(CopBrain, "convert_to_criminal", "InF_SkillOverhaulCopBrainDoConvert", function(self)
	self._unit:unit_data().is_convert = true

	table.insert(IreNFist._converts, self._unit)    
end)

-- Winters, for the love of god end the assault already when you die
Hooks:PostHook(CopBrain, "clbk_death", "InF_CopBrain_wintersdeath_endassault", function(self)
	if unit and unit.base and unit:base() and unit:base()._tweak_table and unit:base()._tweak_table == "phalanx_vip" then
		managers.groupai:state():unregister_phalanx_vip()
	end
end)

-- If the pager was snatched, auto-answer it
if InFmenu.settings.beta then
	Hooks:PostHook(CopBrain, "clbk_alarm_pager", "SkillOverhaulSnatchPagerDo", function(self, ignore_this, data)
		if self._unit:base().inf_pagersnatched then
			self._unit:interaction():interact(managers.player:player_unit())
			return
		end
	end)
end

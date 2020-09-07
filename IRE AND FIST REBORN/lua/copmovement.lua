dofile(ModPath .. "infcore.lua")

if not InFmenu.settings.enablenewassaults then
	return
end

-- Sometimes HRT's spawn without a team set which crashes the game
-- Set a default team for cop units if they dont have a team
Hooks:PreHook(CopMovement, "team", "inf_setcopteamifnoteam", function(self)
    if not self._team then
        self:set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
    end
end)

function CopMovement:_override_weapons(primary, secondary)
    log("[INF] CopMovement _override weapons called!")

    if not primary or secondary then
        return
    end

    -- Weapon has to be dropped twice because I guess cops can sometimes have two weapons?
    -- I very seriously doubt that this is *ever* the case, but you never know.
    self._unit:inventory():drop_weapon()
    self._unit:inventory():drop_weapon()

    if primary then
        self._unit:inventory():add_unit_by_name(primary)
    end
    if secondary then
        self._unit:inventory():add_unit_by_name(secondary)
    end
end

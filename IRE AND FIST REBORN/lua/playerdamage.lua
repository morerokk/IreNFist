dofile(ModPath .. "infcore.lua")

-- Bipod damage multiplier
Hooks:PreHook(PlayerDamage, "damage_bullet", "inf_facetank", function(self, attack_data)
	if managers.player:current_state() == "bipod" then
		attack_data.damage = attack_data.damage * managers.player:upgrade_value("player", "bipod_dmg_taken_mult", 1)
	end
end)

if InFmenu.settings.enablenewcopbehavior then
	-- Cops put you in gay baby jail if they happen to catch you while you're interacting with something
	local playerdamage_damagemelee_orig = PlayerDamage.damage_melee
	function PlayerDamage:damage_melee(attack_data)

		local result = CopUtils:CheckLocalMeleeDamageArrest(self._unit, attack_data.attacker_unit, true)

		if result == "countered" then
			-- TODO: Arrest the cop instead of just knocking them down
			return CopUtils:CounterArrestAttacker(self._unit, attack_data.attacker_unit)
		elseif result == "arrested" then
			self._unit:movement():on_cuffed()
			return
		else
			return playerdamage_damagemelee_orig(self, attack_data)
		end
	end
end

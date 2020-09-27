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

		if Network and Network:is_client() then
			return
		end

		local state = self._unit:movement():current_state()
		-- Check if they're interacting
		local is_interacting = state._interacting and state:_interacting()
		if not is_interacting then
			return playerdamage_damagemelee_orig(self, attack_data)
		end

		-- But also check how long they've been interacting. It should be at least 0.5 seconds to avoid instant BS moments.
		if not state._interact_params or not state._interact_params.timer or not state._interact_expire_t then
			return playerdamage_damagemelee_orig(self, attack_data)
		end

		local current_interact_t = state._interact_params.timer - state._interact_expire_t
		if current_interact_t < 0.5 then
			return playerdamage_damagemelee_orig(self, attack_data)
		end

		self._unit:movement():change_state("arrested")
	end
end

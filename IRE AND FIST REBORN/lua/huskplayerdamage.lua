dofile(ModPath .. "infcore.lua")

if InFmenu.settings.enablenewcopbehavior then
	-- Cops put you in gay baby jail if they happen to catch you while you're interacting with something
	local huskplayerdamage_damagemelee_orig = HuskPlayerDamage.damage_melee
    function HuskPlayerDamage:damage_melee(attack_data)
		
		-- This function override *should* allow an InF host to dictate that a client should be cuffed, but I'm not sure.
		-- Either way, this code should never run as a client.
		if Network and Network:is_client() then
			return
		end

		local state = self._unit:movement():current_state()
		-- Check if they're interacting
		local is_interacting = state._interacting and state:_interacting()
		if not is_interacting then
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end

		-- But also check how long they've been interacting. It should be at least 0.5 seconds to avoid instant BS moments.
		if not state._interact_params or not state._interact_params.timer or not state._interact_expire_t then
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end

		local current_interact_t = self._interact_params.timer - self._interact_expire_t
		if current_interact_t < 0.5 then
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end

		self._unit:movement():on_cuffed()
	end
end

dofile(ModPath .. "infcore.lua")

if InFmenu.settings.enablenewcopbehavior then
	-- Cops put clients in gay baby jail if they happen to catch them while they're interacting with something
	local huskplayerdamage_damagemelee_orig = HuskPlayerDamage.damage_melee
	function HuskPlayerDamage:damage_melee(attack_data)

		-- Should only run for the host
		if Network and Network:is_client() then
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end

		-- If the client has InF, they can figure it out for themselves
		local peer = managers.network:session():peer_by_unit(self._unit)
		if peer and IreNFist.peersWithMod[peer:id()] then
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end

		local result = CopUtils:CheckClientMeleeDamageArrest(self._unit, attack_data.attacker_unit, true)

		if result == "counterarrest" then
			-- TODO: Arrest the cop instead of just knocking them down
			return CopUtils:CounterArrestAttacker(self._unit, attack_data.attacker_unit)
		elseif result == "countered" then
			return CopUtils:KnockDownAttacker(self._unit, attack_data.attacker_unit)
		elseif result == "arrested" then
			self._unit:movement():on_cuffed()
			attack_data.attacker_unit:sound():say("i03", true, false)
			return
		else
			return huskplayerdamage_damagemelee_orig(self, attack_data)
		end
	end
end

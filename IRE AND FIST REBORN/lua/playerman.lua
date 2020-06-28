Hooks:PostHook(PlayerManager, "on_headshot_dealt", "sniperarmor", function(self, params)
	local player_unit = self:player_unit()
	if player_unit then
		local damage_ext = player_unit:character_damage()
		local regen_armor_bonus = managers.player:upgrade_value("player", "snp_headshot_armor", 0)

		local primary_is_sniper = Utils:IsCurrentPrimaryOfCategory("snp") and Utils:IsCurrentWeaponPrimary()
		local secondary_is_sniper = Utils:IsCurrentSecondaryOfCategory("snp") and Utils:IsCurrentWeaponSecondary()

		-- Utils:IsCurrentWeapon("snp") doesn't want to work i guess
		if damage_ext and regen_armor_bonus > 0 and (primary_is_sniper or secondary_is_sniper) then
			damage_ext:restore_armor(regen_armor_bonus)
		end
	end
end)

Hooks:PreHook(PlayerManager, "on_killshot", "stamonkill", function(self, killed_unit, variant, headshot, weapon_id)
	if self:get_current_state() and self:get_current_state():_is_doing_advanced_movement() then
		local value = managers.player:upgrade_value("player", "advmov_stamina_on_kill", 0)
		self:get_current_state()._unit:movement():_change_stamina(value)
	end
end)


local old_sdc = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(...)
	local chance = old_sdc(self, ...)
	if self:get_current_state() and self:get_current_state():_is_doing_advanced_movement() then
		chance = chance + self:get_current_state():_advanced_movement_dodge_bonus() --managers.player:upgrade_value("player", "slide_dodge_addend", 0)
	end
	return chance
end
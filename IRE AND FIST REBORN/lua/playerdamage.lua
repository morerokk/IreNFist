Hooks:PreHook(PlayerDamage, "damage_bullet", "inf_facetank", function(self, attack_data)
	if managers.player:current_state() == "bipod" then
		attack_data.damage = attack_data.damage * managers.player:upgrade_value("player", "bipod_dmg_taken_mult", 1)
	end
end)

Hooks:PreHook(PlayerDamage, "damage_bullet", "inf_facetank", function(self, attack_data)
	if managers.player:current_state() == "bipod" then
		attack_data.damage = attack_data.damage * managers.player:upgrade_value("player", "bipod_dmg_taken_mult", 1)
	end
--[[
	local player_rot = managers.player:equipped_weapon_unit():rotation()
	mvector3.set_x(player_rot, 0)
	mvector3.set_y(player_rot, 0)
	local forward_dir = Vector3(0, 1, 0)
	mvector3.rotate_with(forward_dir, player_rot)

	local forward_angle = math.atan2(forward_dir.y, forward_dir.x)
	local attack_angle = math.atan2(attack_data.col_ray.ray.y, attack_data.col_ray.ray.x)
	local angle_diff = math.abs(forward_angle - attack_angle)

	-- angle to left or right (so 45 is 90 degrees total coverage)
	local shield_angle = 30
	if math.abs(angle_diff - 180) < shield_angle then
		if attack_data.armor_piercing then
			-- hit by sniper
			attack_data.damage = attack_data.damage * 0.50
		else
			attack_data.damage = attack_data.damage * 0.01
		end
	end
--]]
end)
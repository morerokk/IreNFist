-- reload whenever you want
function SawWeaponBase:can_reload()
	return SawWeaponBase.super.can_reload(self)
end

-- show actual ammo count instead of remaining sawblades
function SawWeaponBase:ammo_info()
	--return self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip(), self:remaining_full_clips(), self:get_ammo_max()
	return self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip(), self:get_ammo_total(), self:get_ammo_max()
end

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit

	if hit_unit and hit_unit:character_damage() then
		damage = damage * 5 * (managers.player:player_unit():inventory():equipped_unit():base()._saw_ene_dmg_mult or 1)
	end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end

-- make ammo use not retardo-random
function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if self:get_ammo_remaining_in_clip() == 0 then
		return
	end

	local user_unit = self._setup.user_unit
	local ray_res, hit_something = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if hit_something then
		self:_start_sawing_effect()

		local ammo_usage = 2

		if ray_res.hit_enemy then
			if managers.player:has_category_upgrade("saw", "enemy_slicer") then
				ammo_usage = managers.player:upgrade_value("saw", "enemy_slicer", 2)
			else
				ammo_usage = 2
			end
		end

		if managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") then
			local roll = math.rand(1)
			local chance = managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)

			if roll < chance then
				ammo_usage = 0
			end
		end

		if managers.player:has_active_temporary_property("bullet_storm") then
			ammo_usage = 0
		end

		ammo_usage = math.min(ammo_usage, self:get_ammo_remaining_in_clip())

		self:set_ammo_remaining_in_clip(math.max(self:get_ammo_remaining_in_clip() - ammo_usage, 0))
		self:set_ammo_total(math.max(self:get_ammo_total() - ammo_usage, 0))
		self:_check_ammo_total(user_unit)
	else
		self:_stop_sawing_effect()
	end

	if self._alert_events and ray_res.rays then
		if hit_something then
			self._alert_size = self._hit_alert_size
		else
			self._alert_size = self._no_hit_alert_size
		end

		self._current_stats.alert_size = self._alert_size

		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	return ray_res
end


local function ray_table_contains(table, unit)
	for i, hit in pairs(table) do
		if hit.unit == unit then
			return true
		end
	end

	return false
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec3_add = mvector3.add

function SawWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	local result = {}
	local hit_unit = nil
	from_pos = self._obj_fire:position()
	direction = self._obj_fire:rotation():y()

	mvec3_add(from_pos, direction * -30)
	mvector3.set(mvec_spread_direction, direction)
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, 150) -- more range
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local valid_hit = false
	local col_ray = nil

	if self._saw_through_shields then
		local hits = {}
		col_ray = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")

		for i, hit in ipairs(col_ray) do
			local is_shield = hit.unit:in_slot(8) and alive(hit.unit:parent())
			local is_enemy = hit.unit:character_damage() ~= nil

			if not ray_table_contains(hits, hit.unit) then
				table.insert(hits, hit)
			elseif hit.unit:character_damage() and hit.unit:character_damage().is_head and hit.unit:character_damage().is_head(hit.body) then
				ray_copy(hits, hit)
			end
		end

		for i, hit in pairs(hits) do
			hit_unit = SawHit:on_collision(hit, self._unit, user_unit, damage, direction)
		end

		valid_hit = #col_ray > 0
	else
		col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")

		if col_ray then
			hit_unit = SawHit:on_collision(col_ray, self._unit, user_unit, damage, direction)
			valid_hit = true
		end
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	if col_ray then
		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result, valid_hit
end
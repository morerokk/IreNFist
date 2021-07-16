dofile(ModPath .. "infcore.lua")

if IREnFIST.mod_compatibility.sso then
	return
end

-- Note: temporarily on hold until I can figure out these three things:
-- Is this balanced?
-- Is this a good idea?
-- How do I make "result.rays" not suck on shotguns? All it does is give you a normal and a position, no "who was hit" result

-- Returns true for snipers, and now also for semi/pump shotguns that have slugs installed
-- However, shotguns suffer an extra 50% damage penalty for all graze damage, since they already have skills like Last Word
-- Reasoning: snipers like the WA2000 exist and are arguably better than a Reinbeck with slugs, thanks to Graze and the armor regen from Have a Plan
-- Graze is kinda dumb anyway, SSO's Ricochet is cooler
local function weaponUnitCanHaveGraze(weapon_unit)
	if weapon_unit:base():is_category("snp") then
		return true
	end

	if weapon_unit:base():is_category("shotgun") then
		local weapontweak = weapon_unit:base():weapon_tweak_data()
		-- Disallow anything that can have full auto
		if not weapontweak or not weapon_unit:base().can_toggle_firemode or weapon_unit:base():can_toggle_firemode() or weapontweak.FIRE_MODE ~= "single" then
			return false
		end

		-- Disallow anything with more than 1 ray
		if weapon_unit:base()._rays ~= 1 then
			return false
		end

		-- I don't think this ever happens without custom weapons, but also disallow akimbo shotguns
		if weapon_unit:base():is_category("akimbo") then
			return false
		end

		return true
	end

	return false
end

-- Allow graze on slug pump shotguns (not implemented, might not be a good idea)
-- Also fix civilians being affected by graze (this is a good idea)
function SniperGrazeDamage:on_weapon_fired(weapon_unit, result)
	if not alive(weapon_unit) then
		return
	end

	-- On hold until I can figure out how to do this, and whether this is a good idea at all
	-- For shotguns, the "who was hit?" data seems to be absent completely in this function
	--[[
	if not weaponUnitCanHaveGraze(weapon_unit) then
		return
	end
	]]

	if not weapon_unit:base():is_category("snp") then
		return
	end

	if weapon_unit ~= managers.player:equipped_weapon_unit() then
		return
	end

	if not result.hit_enemy then
		return
	end

	if not result.rays then
		return
	end

	local furthest_hit = result.rays[#result.rays]
	local upgrade_value = managers.player:upgrade_value("snp", "graze_damage")
	local enemies_hit = {}
	local best_damage = 0
	local sentry_mask = managers.slot:get_mask("sentry_gun")
	local ally_mask = managers.slot:get_mask("all_criminals")

	for i, hit in ipairs(result.rays) do
		local is_turret = hit.unit:in_slot(sentry_mask)
		local is_ally = hit.unit:in_slot(ally_mask)
		-- Don't trigger graze on a civilian
		local is_civilian = managers.enemy:is_civilian(hit.unit)

		local is_valid_hit = hit.damage_result and hit.damage_result.attack_data and true or false

		if not is_turret and not is_ally and not is_civilian and is_valid_hit then
			local result = hit.damage_result
			local attack_data = result.attack_data
			local headshot_kill = attack_data.headshot and (result.type == "death" or result.type == "healed")
			local damage_mul = headshot_kill and upgrade_value.damage_factor_headshot or upgrade_value.damage_factor
			local damage = attack_data.damage * damage_mul

			if best_damage < damage then
				best_damage = damage
			end

			enemies_hit[hit.unit:key()] = true
		end
	end

	if best_damage == 0 then
		return
	end
	
	-- Cut shotgun slug graze damage in half
	--[[
	if weapon_unit:base():is_category("shotgun") then
		best_damage = best_damage * 0.5
	end
	]]

	local radius = upgrade_value.radius
	local from = mvector3.copy(furthest_hit.position)
	local stopped_by_geometry = furthest_hit.unit:in_slot(managers.slot:get_mask("world_geometry"))
	local distance = stopped_by_geometry and furthest_hit.distance - radius * 2 or weapon_unit:base():weapon_range() - radius

	mvector3.add_scaled(from, furthest_hit.ray, -furthest_hit.distance)
	mvector3.add_scaled(from, furthest_hit.ray, radius)

	local to = mvector3.copy(from)

	mvector3.add_scaled(to, furthest_hit.ray, distance)

	-- Why was civilians ever in this slotmask?
	local hits = World:raycast_all("ray", from, to, "sphere_cast_radius", radius, "disable_inner_ray", "slot_mask", managers.slot:get_mask("enemies"))

	for i, hit in ipairs(hits) do
		local key = hit.unit:key()

		if not enemies_hit[key] then
			hits[key] = hits[key] or hit
		end

		hits[i] = nil
	end

	for _, hit in pairs(hits) do
		hit.unit:character_damage():damage_simple({
			variant = "graze",
			damage = best_damage,
			attacker_unit = managers.player:player_unit(),
			pos = hit.position,
			attack_dir = -hit.normal
		})
	end
end

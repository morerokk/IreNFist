dofile(ModPath .. "infcore.lua")

-- partially unfucking the previous hollow point implementation
--[[
Hooks:PreHook(CopDamage, "damage_bullet", "inf_undohollowpoint", function(self, attack_data)
	if BeardLib.Utils:FindMod("Tactical Operator Attachments") and attack_data.attacker_unit == managers.player:player_unit() then
		local is_headshot = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
		--if is_headshot and self._unit:inventory():check_hollow_lg_unit() then
		if managers.player:player_unit():inventory():check_hollow_lg_unit() then
--log("has hollow")
			attack_data.damage = attack_data.damage / 1.25
		end
	end
end)
--]]


--[[
LazyOzzy's armor piercing rework
--]]

CopDamage._ARMOR_DAMAGE_REDUCTION = 1	--Damage reduction of armor plate hits

local damage_bullet_original = CopDamage.damage_bullet

function CopDamage:damage_bullet(attack_data, ...)
	if self:_chk_armor_piercing(attack_data) then
		return damage_bullet_original(self, attack_data, ...)
	end
end

function CopDamage:_chk_armor_piercing(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name then
		local armor_pierce_value = 0
		if attack_data.attacker_unit == managers.player:player_unit() and not attack_data.weapon_unit:base().thrower_unit then
			armor_pierce_value = attack_data.weapon_unit:base():armor_piercing_chance() + 
				managers.player:upgrade_value("weapon", "armor_piercing_chance", 0) + 
				managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0) + 
				managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0) +
				managers.player:upgrade_value("player", "armor_piercing_chance", 0) +
				(attack_data.weapon_unit:base():weapon_tweak_data().category == "saw" and managers.player:upgrade_value("saw", "armor_piercing_chance", 0) or 0)
		elseif attack_data.attacker_unit == managers.player:player_unit() and attack_data.weapon_unit:base().thrower_unit then
				armor_pierce_value = 1
		elseif attack_data.attacker_unit:base() and attack_data.attacker_unit:base().sentry_gun then
			local owner = attack_data.attacker_unit:base():get_owner()
			if alive(owner) then
				if owner == managers.player:player_unit() then
					armor_pierce_value = managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0) + 
						managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
				else
					armor_pierce_value = armor_pierce_value + 
						(owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0) + 
						(owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
				end
			end
		end
		
		attack_data.damage = attack_data.damage * (math.clamp(CopDamage._ARMOR_DAMAGE_REDUCTION, 0, 1) * (math.clamp(armor_pierce_value, 0, 1) - 1) + 1)
		attack_data.col_ray.body = self._unit:body("body")
	end
	
	return attack_data.damage > 0
end

function CopDamage:_sync_dismember(attacker_unit)
	local dismember_victim = false

	if not attacker_unit then
		return dismember_victim
	end

	local attacker_name = managers.criminals:character_name_by_unit(attacker_unit)
	local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
	local peer = managers.network:session():peer(peer_id)
	local attacker_weapon = peer:melee_id()

	-- don't check for jiro+katana
	dismember_victim = true

	return dismember_victim
end


function CopDamage:_dismember_condition(attack_data)
	local dismember_victim = false
	local target_is_spook = false

	if alive(attack_data.col_ray.unit) and attack_data.col_ray.unit:base() then
		target_is_spook = attack_data.col_ray.unit:base()._tweak_table == "spooc"
	end

	local melee_can_bisect = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].can_bisect
--[[
	local high_damage = attack_data.damage > 12.0
	local weapon_charged = false
	if attack_data.charge_lerp_value then
		weapon_charged = attack_data.charge_lerp_value > 0.5
	end
--]]

	if target_is_spook and melee_can_bisect then
		dismember_victim = true
	end

	return dismember_victim
end



function CopDamage:_check_special_death_conditions(variant, body, attacker_unit, weapon_unit)
	local special_deaths = self._unit:base():char_tweak().special_deaths

	if not special_deaths or not special_deaths[variant] then
		return
	end

	local body_data = special_deaths[variant][body:name():key()]

	if not body_data then
		return
	end

	if body_data.weapon_id and alive(weapon_unit) then
		local factory_id = weapon_unit:base()._factory_id

		if not factory_id then
			return
		end

		if weapon_unit:base():is_npc() then
			factory_id = utf8.sub(factory_id, 1, -5)
		end

		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

		if weapon_unit:base()._taser_hole then -- not checking for bodhi+platypus
			if self._unit:damage():has_sequence(body_data.sequence) then
				self._unit:damage():run_sequence_simple(body_data.sequence)
			end

			if body_data.special_comment and attacker_unit == managers.player:player_unit() then
				return body_data.special_comment
			end
		end
	end
end




-- make dragon's breath not retarded and actually able to headshot
local damage_fire_original = CopDamage.damage_fire
function CopDamage:damage_fire(attack_data)
	-- headshot code pasted from damage_bullet
	local headshot = false
	local headshot_multiplier = 1
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			managers.hud:on_crit_confirmed()

			attack_data.damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			attack_data.damage = attack_data.damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()
			--log("headshot")

			headshot = true
		end
	end

	if not self._char_tweak.ignore_headshot and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			attack_data.damage = attack_data.damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			attack_data.damage = self._health * 10
		end
	end

	if head and attack_data.weapon_unit and attack_data.weapon_unit:base() and attack_data.weapon_unit:base().get_add_head_shot_mul then -- why the fuck this access violation reeeee
		-- that head check should hopefully prevent further REEE?
		local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

		if not head and add_head_shot_mul and self._char_tweak and self._char_tweak.access ~= "tank" then
			local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
			local mul = tweak_headshot_mul * add_head_shot_mul + 1
			attack_data.damage = attack_data.damage * mul
		end
	end
	--log(damage)
	--^^
	
	damage_fire_original(self, attack_data)
end

-- If a converted cop dies, unregister them from the converts list.
Hooks:PostHook(CopDamage, "_on_death", "InF_SkillOverhaulRemoveJoker", function(self)
    if self._unit:unit_data().is_convert and IreNFist._converts then
        for i, unit in pairs(IreNFist._converts) do
            if unit == self._unit then
                table.remove(IreNFist._converts, i)
            end
        end
    end
end)

Hooks:PreHook(CopDamage, "damage_bullet", "inf_copdamage_damagebullet_stopcrashifnoteam", function(self)
	if not self._unit:movement()._team then
		self._unit:movement():set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end)

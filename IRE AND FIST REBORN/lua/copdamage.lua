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

	-- Apply headgear damage reduction
	if self._head_gear and self._char_tweak.headgear_dmg_penalty then
		attack_data = self:_chk_headgear_damage_reduction(attack_data)
	end

	-- Apply plate damage reduction
	if self._char_tweak.body_armor_dmg_penalty then
		attack_data = self:_chk_armor_damage_reduction(attack_data)
	end

	-- This one goes last because it messes with the attack data by modifying the body
	-- EDIT: It now no longer goes at all, this should be merged into armor damage reduction because otherwise this can falsely block bullets
	-- Did this function ever even do anything? The variable up there is set to 1
	--[[
	if not self:_chk_armor_piercing(attack_data) then
		return
	end
	]]

	-- But still set the hit body to be "body" so the game doesn't still eat our bullet damage
	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name then
		attack_data.col_ray.body = self._unit:body("body")
	end

	return damage_bullet_original(self, attack_data, ...)
end

-- Reduce tan headshot damage IF they still have their helmet
function CopDamage:_chk_headgear_damage_reduction(attack_data)
	-- Don't do anything if the target can't be damaged
	if self._dead or self._invulnerable then
		return attack_data
	end

	-- Check if the attack data is sane
	if not attack_data.damage then
		return attack_data
	end

	-- Helmet already missing, return
	if not self._head_gear then
		return attack_data
	end

	-- Not a headshot, return
	local is_headshot = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	if not is_headshot then
		return attack_data
	end

	-- Check if this unit has a damage reduction for headgear hits
	if not self._char_tweak or not self._char_tweak.headgear_dmg_penalty then
		return attack_data
	end

	-- Apply the damage penalty
	-- As with body armor, certain weapons are less susceptible to this penalty
	local penalty = self._char_tweak.headgear_dmg_penalty
	local penalty_mul = attack_data.weapon_unit:base()._body_armor_dmg_penalty_mul
	if penalty_mul then
		penalty = penalty * penalty_mul
	end

	attack_data.damage = attack_data.damage * (1 - penalty)

	-- Randomly make their helmet fly off, which will in turn make them more vulnerable for followup shots
	if self._char_tweak.headgear_flyoff_chance and math.random() < self._char_tweak.headgear_flyoff_chance then
		self:_spawn_head_gadget({
			position = attack_data.col_ray.body:position(),
			rotation = attack_data.col_ray.body:rotation(),
			dir = attack_data.col_ray.ray
		})
	end

	-- Clamp damage to 0
	if attack_data.damage < 0 then
		attack_data.damage = 0
	end

	return attack_data
end

-- Reduce tan chicken plate hit damage
function CopDamage:_chk_armor_damage_reduction(attack_data)
	-- Don't do anything if the target can't be damaged
	if self._dead or self._invulnerable then
		return attack_data
	end

	-- Check if the attack data is sane
	if not attack_data.damage then
		return attack_data
	end

	-- Check if the bullet hit the chicken plate
	if not self._has_plate or not attack_data.col_ray.body or attack_data.col_ray.body:name() ~= self._ids_plate_name then
		return attack_data
	end

	-- Check if this unit has a damage reduction for plate hits
	if not self._char_tweak or not self._char_tweak.body_armor_dmg_penalty then
		return attack_data
	end

	-- Calculate the penalty by taking the unit's body armor damage penalty, and multiplying that penalty by the weapon penalty multiplier
	-- This means that heavier weapons will be penalized less
	local penalty = self._char_tweak.body_armor_dmg_penalty
	local penalty_mul = attack_data.weapon_unit:base()._body_armor_dmg_penalty_mul
	if penalty_mul then
		penalty = penalty * penalty_mul
	end

	-- Apply damage reduction
	attack_data.damage = attack_data.damage * (1 - penalty)

	-- Clamp damage to 0
	if attack_data.damage < 0 then
		attack_data.damage = 0
	end

	return attack_data
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
	if self._unit:movement() and not self._unit:movement()._team then
		self._unit:movement():set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end)

-- Melee headshot multiplier, flat 1.5x
local copdamage_damagemelee_orig = CopDamage.damage_melee
function CopDamage:damage_melee(attack_data)

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	if head and attack_data and attack_data.damage then
		attack_data.damage = attack_data.damage * 1.5
	end

	local result = copdamage_damagemelee_orig(self, attack_data)

	if InFmenu.settings.beta then
		local attacker_unit = attack_data and attack_data.attacker_unit
		local player_unit = managers.player:player_unit()
		-- First check if the unit is cool and if the attacker was the player
		if attacker_unit == player_unit and self._unit:movement():cool() then
			-- Check for pager snatching
			if result and result.type and result.type == "death" and managers.player:has_category_upgrade("player", "inf_snatch_pager") and managers.groupai:state():whisper_mode() and managers.groupai:state():get_nr_successful_alarm_pager_bluffs() < 4 then
				-- If the host did it, we can just set a flag
				-- If we're the client, we have to tell the host
				if not Network or Network:is_server() then
					self._unit:base().inf_pagersnatched = true
				else
					LuaNetworking:SendToPeer(1, "irenfist_pagersnatched", tostring(self._unit:id()))
				end
			end			
		end
	end

	return result
end

-- If we're the host, we need to be able to receive messages from clients that this dude's pager should be snatched
if InFmenu.settings.beta and Network and Network:is_server() then
	Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_irenfist_copdamage_meleesnatchpager', function(sender, messageType, data)
		-- Only check pager messages
		if messageType ~= "irenfist_pagersnatched" then
			return
		end

		-- Attempt to get the actual cop unit from their ID
		local unit_id = tonumber(data)
		if not unit_id then
			return
		end

		local cop = CopUtils:GetCopFromId(unit_id)
		if not cop then
			return
		end

		-- If we're loud, don't do it
		if not managers.groupai:state():whisper_mode() then
			return
		end

		-- If we are already at 4 pagers, don't snatch, this would be a dick move
		if managers.groupai:state():get_nr_successful_alarm_pager_bluffs() >= 4 then
			return
		end

		-- Everything seems fine, set the flag on the cop
		cop:base().inf_pagersnatched = true
	end)
end

Hooks:PreHook(CopDamage, "damage_melee", "inf_copdamage_damagemelee_stopcrashifnoteam", function(self)
	if self._unit:movement() and not self._unit:movement()._team then
		self._unit:movement():set_team(managers.groupai:state()._teams[tweak_data.levels:get_default_team_ID(self._unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end)

-- Workaround for a crash
function CopDamage:_spawn_head_gadget(params)
	if not self._head_gear or not self._unit then
		return
	end

	if self._head_gear_object then
		if self._nr_head_gear_objects then
			for i = 1, self._nr_head_gear_objects do
				local head_gear_obj_name = self._head_gear_object .. tostring(i)
				-- Sometimes this is nil, no idea why
				local head_gear_obje = self._unit:get_object(Idstring(head_gear_obj_name))
				if head_gear_obje then
					head_gear_obje:set_visibility(false)
				end
			end
		else
			local head_gear_obje = self._unit:get_object(Idstring(self._head_gear_object))
			if head_gear_obje then
				head_gear_obje:set_visibility(false)
			end
		end

		if self._head_gear_decal_mesh then
			local mesh_name_idstr = Idstring(self._head_gear_decal_mesh)

			self._unit:decal_surface(mesh_name_idstr):set_mesh_material(mesh_name_idstr, Idstring("flesh"))
		end
	end

	local unit = World:spawn_unit(Idstring(self._head_gear), params.position, params.rotation)

	if not params.skip_push then
		local dir = math.UP - params.dir / 2
		dir = dir:spread(25)
		local body = unit:body(0)

		body:push_at(body:mass(), dir * math.lerp(300, 650, math.random()), unit:position() + Vector3(math.rand(1), math.rand(1), math.rand(1)))
	end

	self._head_gear = false
end

function WeaponLionGadget1:_is_deployable()
--[[
	if tweak_data.weapon[managers.blackmarket:equipped_primary().weapon_id].use_bipod_anywhere == true then
		return true
	end
	return self:_shoot_bipod_rays2()
--]]


	if tweak_data.weapon[managers.blackmarket:equipped_primary().weapon_id].use_bipod_anywhere == true then
		return true
	end

	if self._is_npc or (not self:_get_bipod_obj() and not tweak_data.weapon[managers.blackmarket:equipped_primary().weapon_id].custom_bipod) then
		return false
	end
	if self:_is_in_blocked_deployable_state() then
		return false
	end

	--local bipod_rays = self:_shoot_bipod_rays()
	local bipod_rays = self:_shoot_bipod_rays2()
	if not bipod_rays then
		return false
	end
--[[
	if not bipod_rays then
		bipod_rays = self:_shoot_bipod_rays2()
		if not bipod_rays then
			return false
		end
	end
--]]

	if bipod_rays.forward then
		return false
	end

	if bipod_rays.center then
		return true
	end
	return false
end

-- fucking vectors how do they work
-- transform: left, forward, up
-- rotate: rotate around z (forward goes right), rotate around x (forward goes up), rotate around y (left goes down)
function WeaponLionGadget1:_shoot_bipod_rays2(debug_draw)
	--local player_pos = managers.player:player_unit():position()
	--local player_rot = managers.player:player_unit():rotation()
	local camera_pos = managers.player:player_unit():camera():position()
	--local wpn_pos = managers.player:equipped_weapon_unit():position()
	local wpn_rot = managers.player:equipped_weapon_unit():rotation()


	-- forward check vector
	local forward_vec = Vector3(0, 150, 0)
	mvector3.rotate_with(forward_vec, wpn_rot)
	if math.abs(forward_vec:to_polar().pitch) > 60 then
		return nil
	end
	local bipod_pos = Vector3()
	mvector3.set(bipod_pos, camera_pos)
	mvector3.add(bipod_pos, forward_vec)

	local result = {}
	local forwardtest = self._unit:raycast(camera_pos, bipod_pos) --Utils:GetCrosshairRay(camera_pos, bipod_pos)
	if forwardtest then
		result.forward = true
	end

	-- check if bipod has a surface to rest on
	local forward_values = {80, 100, 120}
	for a, b in ipairs(forward_values) do
		local forward_vec = Vector3(0, b, 0)
		mvector3.rotate_with(forward_vec, wpn_rot)
		local bipod_forward_pos = Vector3()
		mvector3.set(bipod_forward_pos, camera_pos)
		mvector3.add(bipod_forward_pos, forward_vec)

		-- bipod legs (perpendicular to barrel)
		local forward_down_vec = Vector3(0, b, -93)
		mvector3.rotate_with(forward_down_vec, wpn_rot)
		local bipod_down_pos = Vector3()
		mvector3.set(bipod_down_pos, camera_pos)
		mvector3.add(bipod_down_pos, forward_down_vec)

		-- vertical-wall test, must have a surface below to deploy
		-- still doesn't prevent the from-hood-to-license-plate case
		local forward_gravity_vec = Vector3(0, b, 0)
		mvector3.rotate_with(forward_gravity_vec, wpn_rot)
		local bipod_gravity_pos = Vector3()
		mvector3.set(bipod_gravity_pos, camera_pos)
		mvector3.add(bipod_gravity_pos, forward_gravity_vec) -- vector forward at weapon angle
		mvector3.add(bipod_gravity_pos, Vector3(0, 0, -90)) -- check straight down

		local surface_resting_test = self._unit:raycast(bipod_forward_pos, bipod_down_pos)
		local angle_test = self._unit:raycast(bipod_forward_pos, bipod_gravity_pos)
		if surface_resting_test and angle_test then
			result.down = true
		end
	end

	return {forward = result.forward or nil, center = result.down or nil}
end

--[[
function WeaponLionGadget1:_shoot_bipod_rays(debug_draw)
	local mvec1 = Vector3()
	local mvec2 = Vector3()
	local mvec3 = Vector3()
	local mvec_look_dir = Vector3()
	local mvec_gun_down_dir = Vector3()
	local from = mvec1
	local to = mvec2
	local from_offset = mvec3
	local bipod_max_length = WeaponLionGadget1.bipod_length or 120 -- 90
	if not self._bipod_obj then
		return nil
	end
	if not self._bipod_offsets then
		self:get_offsets()
	end

	mrotation.y(self:_get_bipod_alignment_obj():rotation(), mvec_look_dir)
	mrotation.x(self:_get_bipod_alignment_obj():rotation(), mvec_gun_down_dir)
	local bipod_position = Vector3()
	mvector3.set(bipod_position, self._bipod_offsets.direction)
	mvector3.rotate_with(bipod_position, self:_get_bipod_alignment_obj():rotation())
	mvector3.multiply(bipod_position, (self._bipod_offsets.distance or bipod_max_length) * -1)
	mvector3.add(bipod_position, self:_get_bipod_alignment_obj():position())

--log("player position: " .. Vector3.ToString(managers.player:player_unit():position()))
--log("bipod position: " .. Vector3.ToString(self._bipod_offsets.direction))
--log("bipod align position: " .. Vector3.ToString(self:_get_bipod_alignment_obj():position()))

--log("player rotation: " .. managers.player:player_unit():rotation())
--log("bipod align rotation: " .. Vector3.ToString(self:_get_bipod_alignment_obj():rotation()))

	if debug_draw then
		Application:draw_line(bipod_position, bipod_position + Vector3(10, 0, 0), unpack({
			1,
			0,
			0
		}))
		Application:draw_line(bipod_position, bipod_position + Vector3(0, 10, 0), unpack({
			0,
			1,
			0
		}))
		Application:draw_line(bipod_position, bipod_position + Vector3(0, 0, 10), unpack({
			0,
			0,
			1
		}))
	end
	if mvec_look_dir:to_polar().pitch > 60 then
		return nil
	end
	mvector3.set(from, bipod_position)
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length)
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 120))
	mvector3.add(to, from)
	local ray_bipod_left = self._unit:raycast(from, to)
	if not debug_draw then
		self._left_ray_from = Vector3(from.x, from.y, from.z)
		self._left_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_left or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length)
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 60))
	mvector3.add(to, from)
	local ray_bipod_right = self._unit:raycast(from, to)
	if not debug_draw then
		self._right_ray_from = Vector3(from.x, from.y, from.z)
		self._right_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_right or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length * math.cos(30))
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 90))
	mvector3.add(to, from)
	local ray_bipod_center = self._unit:raycast(from, to)
	if not debug_draw then
		self._center_ray_from = Vector3(from.x, from.y, from.z)
		self._center_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_center or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(from_offset, Vector3(0, -100, 0))
	mvector3.rotate_with(from_offset, self:_get_bipod_alignment_obj():rotation())
	mvector3.add(from, from_offset)
	mvector3.set(to, mvec_look_dir)
	mvector3.multiply(to, 150)
	mvector3.add(to, from)
	local ray_bipod_forward = self._unit:raycast(from, to)
	if debug_draw then
		if not ray_bipod_forward or not {
			1,
			0,
			0
		} then
			local color = {
				0,
				1,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	return {
		left = ray_bipod_left,
		right = ray_bipod_right,
		center = ray_bipod_center,
		forward = ray_bipod_forward
	}
end
--]]
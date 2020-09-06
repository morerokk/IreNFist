function PlayerDriving:_set_camera_limits(mode)
	if mode == "driving" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.driver then
			self._camera_unit:base():set_limits(170, 60)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.driver.yaw, self._vehicle_ext._tweak_data.camera_limits.driver.pitch)
		end
	elseif mode == "passenger" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.passenger then
			self._camera_unit:base():set_limits(170, 60)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.passenger.yaw, self._vehicle_ext._tweak_data.camera_limits.passenger.pitch)
		end
	elseif mode == "shooting" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.shooting then
			self._camera_unit:base():set_limits(nil, 80)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.shooting.yaw, self._vehicle_ext._tweak_data.camera_limits.shooting.pitch)
		end
	end
end

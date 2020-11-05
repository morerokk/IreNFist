-- When an ammo bag is set up, register it so we can find it more easily later
local ammo_bags = {}

Hooks:PostHook(AmmoBagBase, "setup", "inf_ammobase_setup", function(self)
    ammo_bags[tostring(self._unit:id())] = self
end)

-- Refill ammo bag with player unit
function AmmoBagBase:refill_ammo(unit)
	local refilled = self:_refill_ammo(unit)

    if refilled > 0 then
        -- Lol
		managers.network:session():send_to_peers_synched("sync_ammo_bag_ammo_taken", self._unit, -refilled)
	end

	self:_set_visual_stage()

	return refilled > 0
end

-- Actually take the ammo out of the reserves into the bag
function AmmoBagBase:_refill_ammo(unit)
	local old_ammo_count = self._ammo_amount
	local inventory = unit:inventory()

	if inventory then
        for _, weapon in pairs(inventory:available_selections()) do
            -- How much ammo is the bag missing? Take no more than this
            local ammo_left_to_refill = self._max_ammo_amount - self._ammo_amount
            -- How much ammo does the weapon still have? Take no more than half of this
            -- This can always only be between 0 and 0.5.
            local wep_ratio_to_take = weapon.unit:base():get_ammo_ratio() * 0.5

            if wep_ratio_to_take > 0.001 and ammo_left_to_refill > 0.001 then
                local ratio_to_refill = math.min(wep_ratio_to_take, ammo_left_to_refill)

                -- Refill the ammo bag
                -- However, it may never be bigger than its max ammo amount
                -- This means you can waste ammo refilling a near-full ammo bag, but that's on you
                self._ammo_amount = self:round_value(math.min(self._ammo_amount + ratio_to_refill, self._max_ammo_amount))
                weapon.unit:base():reduce_ammo_by_procentage_of_total(ratio_to_refill)
                -- Update HUD
                local index = weapon.unit:base():selection_index()
                managers.hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
            end
		end
	end

	return self._ammo_amount - old_ammo_count
end

-- Find a bag to refill
function AmmoBagBase.find_refill_bag(position, max_dist)
    if not position or not max_dist then
        return nil
    end

    local closest_found_dist = 999999
    local closest_bag = nil
    for id, bag in pairs(ammo_bags) do
        local dist = mvector3.distance(bag._unit:position(), position)
        if dist <= max_dist and dist < closest_found_dist then
            closest_bag = bag
        end
    end

    -- Can be nil if no bag was found in the distance
    return closest_bag
end

-- Called after successful refill, blocks bulletstorm from happening on this bag
function AmmoBagBase:forbid_bulletstorm()
    self:sync_forbid_bulletstorm()

    -- Tell peers that the bag was refilled
    LuaNetworking:SendToPeers("inf_forbidbulletstorm", tostring(self._unit:id()))
end

function AmmoBagBase:sync_forbid_bulletstorm()
    self._bullet_storm_level = 0
end

-- Allow peers to tell us that the ammo bag's bulletstorm has been blocked
Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_inf_ammobag_bulletstorm', function(sender, messageType, data)
    if messageType ~= "inf_forbidbulletstorm" or not data then
        return
    end

    -- Try to get the ammo bag by the sent ID
    local bag = ammo_bags[data]
    if not bag or not bag.sync_forbid_bulletstorm then
        return
    end

    bag:sync_forbid_bulletstorm()
end)

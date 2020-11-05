dofile(ModPath .. "infcore.lua")

-- If we successfully pick up an ammo pickup and we have the upgrade, charge the bulletstorm meter
local ammopickup_pickup_orig = AmmoClip._pickup
function AmmoClip:_pickup(unit)
    local result = ammopickup_pickup_orig(self, unit)

    if result and unit == managers.player:player_unit() and managers.player:has_category_upgrade("player", "inf_charge_bulletstorm") then
        IreNFist.current_bulletstorm_charge = IreNFist.current_bulletstorm_charge + tweak_data.upgrades.bulletstorm_second_gain

        -- Clamp to max
        if IreNFist.current_bulletstorm_charge > tweak_data.upgrades.bulletstorm_max_seconds then
            IreNFist.current_bulletstorm_charge = tweak_data.upgrades.bulletstorm_max_seconds
        end
    end

    return result
end

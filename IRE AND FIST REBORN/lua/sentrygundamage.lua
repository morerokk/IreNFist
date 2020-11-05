-- Force the turret to die on the clients' sides when it is killed
Hooks:PostHook(SentryGunDamage, "die", "inf_swatturret_dead_sync_death_manually", function(self)

    -- Don't do anything to regular sentries
    local turret_units = managers.groupai:state():turrets()
    if not turret_units or not table.contains(turret_units, self._unit) then
        return
    end

    if not self._unit or not self._unit:id() then
        return
    end

    -- Notify clients that this turret is dead
    LuaNetworking:SendToPeers("inf_turretdead", tostring(self._unit:id()))
end)

-- Listen for "turret died" notifications and apply the death locally
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_InF_SwatTurretDied", function(sender, messageType, data)
    if messageType ~= "inf_turretdead" or not data then
        return
    end

    local turret_unit_id = tonumber(data)
    if not turret_unit_id then
        return
    end

    local turret_units = managers.groupai:state():turrets()
    if not turret_units then
        return
    end

    for i, unit in pairs(turret_units) do
        if unit:id() == turret_unit_id then
            -- If the turret already died, don't worry about it
            if not alive(unit) then
                return
            end

            -- Probably safe to call without parameters, the game does it on load() too
            unit:character_damage():die()
            -- Ok well fuck the turret, this doesn't always work, so set a flag on the turret that makes you unable to be damaged by it
            unit:base().inf_dead = true
            break
        end
    end
end)

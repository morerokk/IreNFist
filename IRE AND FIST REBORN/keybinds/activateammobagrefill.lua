if not managers or not managers.player or not managers.player.try_refill_nearby_ammo_bag then
    return
end

managers.player:try_refill_nearby_ammo_bag()

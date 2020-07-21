if not IreNFist then

    _G.IreNFist = {}

    -- Heist-specific overrides for assault values
    -- This has to be done because some poorly designed heists like Shacklethorne have assaults that end way too quickly with these tweaks
    -- Default values:
    -- self.besiege.assault.force = {14, 15, 16} -- 14, 16, 18
    -- self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4
    -- 
    -- self.besiege.assault.force_pool = {40, 45, 50} -- originally 150, 175, 225
    -- self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- originally 1, 2, 3, 4
    -- Spawn delay is 0 by default.

    IreNFist.bad_heist_overrides = {
        sah = { -- Shacklethorne Auction, lower max cops but increase the assault pool size
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 },
            initial_spawn_delay = 30 -- Add a 30 second spawn delay because a literal 0 second response time is dumb
        }
    }

end

dofile(ModPath .. "infcore.lua")

-- lib/managers/blackmarketmanager
-- see which mods keep popping up as 'new' every time you launch the game

if InFmenu.settings.clearnewdrops then
    function BlackMarketManager:remove_all_new_drop()
        log("[InF] CHECKING NEW DROPS LIST")
        for a, b in pairs(self._global.new_drops) do
            log(a)
            for c, d in pairs(b) do
                log(c)
                for e, f in pairs(d) do
                    log(e)
                end
            end
        end

        local cleared = table.size(self._global.new_drops) > 0
        self._global.new_drops = {}

        if cleared == true then
            log("[InF] cleared some new weapon mods")
        else
            log("[InF] cleared no weapon mods")
        end

        return cleared
    end

    -- Go away already
    function BlackMarketManager:got_any_new_drop()    
        return false
    end
end

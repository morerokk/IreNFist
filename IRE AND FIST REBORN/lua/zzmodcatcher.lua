-- lib/managers/blackmarketmanager
-- see which mods keep popping up as 'new' every time you launch the game

function BlackMarketManager:remove_all_new_drop()
log("CHECKING NEW DROPS LIST")
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
log("cleared something")
else
log("cleared NOTHIN AT ALL")
end
	return cleared
end
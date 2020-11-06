local function checkfolders(subfolder, file)
	local filename = file or "main.xml"
	if SystemFS:exists("mods/" .. subfolder .. "/" .. filename) or SystemFS:exists("assets/mod_overrides/" .. subfolder .. "/" .. filename) then
		return true
	end
	return false
end

local function kick_mult(array, sv, sh, cv, ch, adsv, adsh)
	if not array.standing then
		log("OH SHIT WHAT YOU ARE DOING WHY DID YOU PASS A NON-KICK TO KICK_MULT")
	else
		local newarray = {}
		newarray.standing = {array.standing[1] * sv, array.standing[2] * sv, array.standing[3] * sh, array.standing[4] * sh}
		newarray.crouching = {array.crouching[1] * cv, array.crouching[2] * cv, array.crouching[3] * ch, array.crouching[4] * ch}
		newarray.steelsight = {array.steelsight[1] * adsv, array.steelsight[2] * adsv, array.steelsight[3] * adsh, array.steelsight[4] * adsh}
		return newarray
	end
end

local function rtable_mult(array, vert, horiz)
	local newarray = {}
	for a = 1, #array do
		newarray[a] = {}
		newarray[a][1] = array[a][1] * vert
		newarray[a][2] = array[a][2] * vert
		newarray[a][3] = array[a][3] * horiz
		newarray[a][4] = array[a][4] * horiz
	end
	return newarray
end

-- New InF table, primarily used for tweakdata
if not IreNFist then

    _G.IreNFist = {}

    -- Keeps a list of converted cops
    -- This is for the skill that allows you to call converted cops over to revive you
    IreNFist._converts = {}

    -- List of peers that have InF installed
    -- Needed for some networking functions
    IreNFist.peersWithMod = {}

    -- List of peers that have the standalone cop cuffing mod installed
    -- Interop with irenfist
    IreNFist.arrestModPeers = {}

    -- Index of newly inserted bunker/holdout perk deck
    IreNFist.holdout_deck_index = nil

    -- Bullet storm charge
    IreNFist.current_bulletstorm_charge = 0

    -- Whether bullet storm is active
    IreNFist.bulletstorm_active = false

    -- NOTE: The below values are not used with the newest assault tweaks.
    -- Only the spawn delay is used.
    -- Heist-specific overrides for assault values
    -- This has to be done because some poorly designed heists like Shacklethorne have assaults that end way too quickly with these tweaks
    -- Default values:
    -- self.besiege.assault.force = {14, 15, 16} -- 14, 16, 18
    -- self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4
    -- 
    -- self.besiege.assault.force_pool = {40, 45, 50} -- originally 150, 175, 225
    -- self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- originally 1, 2, 3, 4
    -- Spawn delay is optional. If not given, is basically 0.
    IreNFist.bad_heist_overrides = {
        sah = { -- Shacklethorne Auction, lower max cops but increase the assault pool size
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 },
            initial_spawn_delay = 45 -- Add a 45 second spawn delay because a literal 0 second response time is dumb
        },
        nmh = { -- No Mercy, same as Shacklethorne Auction but more cops at a time
            force = { 14, 15, 16 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 }
        },
        kenaz = { -- Golden grin casino. Not actually a bad heist at all, but the lowered max cop count makes this too easy otherwise
            force = {14, 16, 18},
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = {45, 50, 55},
            force_pool_balance_mul = { 1, 2, 3, 4 }
        },
        brb = { -- Brooklyn Bank, similar to Shacklethorne auction
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 },
            initial_spawn_delay = 60 -- Spawn delay has to be even longer here
        },
        mex_cooking = { -- Border Crystals spawns them literally on top of you
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 },
        }
    }

    -- Not sure which one of these two names Golden Grin uses, so just override them both.
    IreNFist.bad_heist_overrides.cas = deep_clone(IreNFist.bad_heist_overrides.kenaz)

    -- Fucking sexy NEW overrides
    -- Because some heists just need a little extra care put into their police force counts
    -- This time I made it level-based and not job-based
    -- Beta only for now
    -- NOTE: These force_muls are applied on top of the existing force balance muls, not on the force values directly
    -- and they don't replace anything either, they *multiply* the existing value.
    -- Maybe they *should* multiply the base values instead of the balance_muls?
    IreNFist.level_force_overrides = {
        hox_1 = { -- Hoxout day 1, the "first assault is very light" mechanic doesn't really work if the whole gauntlet is assault 1
            force_mul = { 2, 2, 2, 2 },
            force_pool_mul = { 1.2, 1.2, 1.2, 1.2 } -- Barely matters here, assault is assault
        },
        hox_2 = { -- Hoxout day 2, this just needed a bit more oomph
            force_mul = { 1.75, 1.75, 1.75, 1.75 },
            force_pool_mul = { 1.35, 1.35, 1.35, 1.35 }
        },
        branchbank = {
            too_many_cloakers = true -- Should be enabled for heists that spam too many scripted cloaker spawns. This lessens/removes the cloakers from regular squads.
        }
    }

    -- Mod compatibility detection
    -- Detect if a mod is installed and enabled, if it is then add a table entry so we can keep track of the mod
    IreNFist.mod_compatibility = {}
    -- Sydch's Skill Overhaul
    local sso_compat = BLT.Mods:GetModByName("Skill Overhaul")
    if (sso_compat and sso_compat:IsEnabled()) or BeardLib.Utils:ModLoaded("Skill Overhaul") then
        log("[InF] SSO compatibility enabled")
        IreNFist.mod_compatibility.sso = true
    end
    -- Armor Overhaul
    local armor_overhaul_compat = BLT.Mods:GetModByName("Armor Overhaul")
    if armor_overhaul_compat and armor_overhaul_compat:IsEnabled() then
        log("[InF] Armor Overhaul compatibility enabled")
        IreNFist.mod_compatibility.armor_overhaul = true
    end
    -- Think Faster
    local think_faster_compat = BLT.Mods:GetModByName("Think Faster")
    if think_faster_compat and think_faster_compat:IsEnabled() then
        log("[InF] Think Faster compatibility enabled")
        IreNFist.mod_compatibility.think_faster = true
    end
    -- WolfHUD
    local wolfhud_compat = BLT.Mods:GetModByName("WolfHUD")
    if wolfhud_compat and wolfhud_compat:IsEnabled() then
        log("[InF] WolfHUD compatibility enabled")
        IreNFist.mod_compatibility.wolfhud = true
    end
    -- PDTH HUD Reborn
    local pdthhud_compat = BLT.Mods:GetModByName("PAYDAY: The Heist HUD Reborn")
    if pdthhud_compat and pdthhud_compat:IsEnabled() then
        log("[InF] PDTH HUD Reborn compatibility enabled")
        IreNFist.mod_compatibility.pdthhud = true
    end
    -- Auto-Fire Sound Fix 2
    local afsf_compat = BLT.Mods:GetModByName("Auto-Fire Sound Fix")
    if afsf_compat and afsf_compat:IsEnabled() then
        log("[InF] Auto Fire Sound Fix compatibility enabled")
        IreNFist.mod_compatibility.afsf_compat = true
    end

    -- Include arrest utils
    dofile(ModPath .. "utils/coputils.lua")

    -- Networking functions
    -- Tell others that you have the mod installed
    Hooks:Add('BaseNetworkSessionOnLoadComplete', 'BaseNetworkSessionOnLoadComplete_IREnFIST', function(local_peer, id)
        LuaNetworking:SendToPeers("irenfist_hello", "hello")
    end)

    -- Same as above, if a single peer joins then tell them your dice roll.
    Hooks:Add('BaseNetworkSessionOnPeerEnteredLobby', 'BaseNetworkSessionOnPeerEnteredLobby_IREnFIST', function(peer, peer_id)
        LuaNetworking:SendToPeer(peer_id, "irenfist_hello", "hello")
    end)
    
    -- Network data receiving function
    Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_IREnFIST', function(sender, messageType, data)
        -- Acknowledge that a peer has InF installed
        if messageType == "irenfist_hello" then
            IreNFist.peersWithMod[sender] = true
        end

        -- Cop arrest interop
        if messageType == "coparrest_hello" then
            IreNFist.arrestModPeers[sender] = true
        end
    end)

    -- If a peer leaves, remove them from the list
    Hooks:Add('BaseNetworkSessionOnPeerRemoved', 'BaseNetworkSessionOnPeerRemoved_VocalHeisters', function(peer, peer_id, reason)
        IreNFist.peersWithMod[peer_id] = nil
        IreNFist.arrestModPeers[peer_id] = nil
    end)
end

-- Old table that I don't wanna refactor right now, holds menu settings but also holds tweakdata for the various weapon categories.
if not InFmenu then
    _G.InFmenu = {}
    InFmenu._path = ModPath
    InFmenu._data_path = SavePath .. 'infsave.txt'
    InFmenu.settings = {
        allpenwalls = true,
        reloadbreaksads = true,
        disable_autoreload = true,
        goldeneye = 1,
        changeitemprices = true,
        clearnewdrops = true,

        rainbowassault = true,
        skulldozersahoy = 2,
        sanehp = true,
        copfalloff = true,
        copmiss = true,
        enablenewcopvoices = true,
        enablenewcopdomination = true,
        enablenewassaults = true,
        enablenewcopbehavior = true,
        thinkfaster = true,
        thinkfaster_throughput = 180, -- The defaults are skewed a bit low to not fry people's PC's without asking

        enablewallrun = true,
        runkick = false,
        kickyeet = 1,
        slidestealth = 2,
        slideloud = 3,
        slidewpnangle = 15,
        wallrunwpnangle = 15,
        dashcontrols = 4,

        txt_wpnname = 2,
        because_of_training = false,
        debug = false,
        cbt = false,
        beta = false,
        holdout_waypoint = false,
        homeruncontest = false,

        disablefrogmanwarnings = false
    }

    function InFmenu:Save()
        local file = io.open(InFmenu._data_path, 'w+')
        if file then
            file:write(json.encode(InFmenu.settings))
            file:close()
        end
    end
    
    function InFmenu:Load()
        local file = io.open(InFmenu._data_path, 'r')
        if file then
            for k, v in pairs(json.decode(file:read('*all')) or {}) do
                InFmenu.settings[k] = v
            end
            file:close()
        end
    end
    
    InFmenu:Load()
    -- generate save data even if nobody ever touches the mod options menu
    InFmenu:Save()

    -- Tons of tweakdata stuff ahead
    InFmenu.rtable = {}
    InFmenu.rstance = {}
    InFmenu.wpnvalues = {}
    
    -- Stances and recoil
    InFmenu.rtable.lrifle = {
        {0.5, 0.5, -0.2, -0.2},
        {0.6, 0.6, -0.2, -0.2},
        {0.7, 0.7, -0.3, -0.3},
        {0.8, 0.8, -0.3, -0.3},
        {0.9, 0.9, -0.3, -0.3},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.1, 1.1, -0.5, -0.5},
        {1.2, 1.2, -0.5, 0.5},
        {1.3, 1.3, -0.5, 0.5},
        {1.3, 1.3, -0.2, -0.2}, -- loop
        {1.3, 1.3, 0.1, 0.1},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.2, 0.2},
        {1.3, 1.3, -0.1, -0.1},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5}
    }
    InFmenu.rtable.carbine = deep_clone(InFmenu.rtable.lrifle)
    
    InFmenu.rtable.hrifle = {
        {0.5, 0.5, -0.2, -0.2},
        {0.6, 0.6, -0.2, -0.2},
        {0.7, 0.7, -0.2, -0.2},
        {0.8, 0.8, -0.2, -0.2},
        {0.9, 0.9, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, 0.2, 0.2}, -- loop
        {1.2, 1.2, 0.4, 0.4},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, -0.4, -0.4},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5}
    }
    InFmenu.rtable.mrifle = deep_clone(InFmenu.rtable.hrifle)
    InFmenu.rtable.mcarbine = deep_clone(InFmenu.rtable.hrifle)
    
    InFmenu.rtable.dmr = {
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.4, -0.4},
        {1.0, 1.0, 0.4, -0.4},
        {1.0, 1.0, 0.4, -0.4},
        {1.2, 1.2, 0.2, -0.2},
        {1.2, 1.2, 0.2, -0.2}, -- loop
        {1.2, 1.2, 0.4, -0.4},
        {1.3, 1.3, 0.5, -0.5},
        {1.3, 1.3, 0.5, -0.5},
        {1.2, 1.2, 0.2, -0.2},
        {1.2, 1.2, 0.4, -0.4},
        {1.3, 1.3, 0.5, -0.5},
        {1.3, 1.3, 0.5, -0.5}
    }
    InFmenu.rtable.ldmr = deep_clone(InFmenu.rtable.dmr)
    InFmenu.rtable.hdmr = deep_clone(InFmenu.rtable.dmr)
    
    InFmenu.rtable.shotgun = {
        {1.0, 1.0, 0.35, -0.35},
        {1.0, 1.0, 0.35, -0.35},
        {1.1, 1.1, 0.50, -0.40},
        {1.2, 1.2, 0.70, -0.55},
        {1.3, 1.3, 0.90, -0.60},
        {1.4, 1.4, 1.20, -0.70}
    }
    
    InFmenu.rtable.lmg = {
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.1, -0.1},
        {0.8, 0.8, 0.2, 0.2},
        {0.8, 0.8, 0.4, 0.4},
        {0.8, 0.8, 0.4, 0.4},
        {0.8, 0.8, 0.4, 0.4},
        {1.0, 1.0, -0.2, -0.2}, -- loop
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5}
    }
    
    InFmenu.rtable.lightpis = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, 0.2},
        {1.0, 1.0, -0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1}, -- loop
        {1.0, 1.0, 0.0, 0.0},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, -0.0, -0.0},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3}
    }
    
    InFmenu.rtable.mediumpis = InFmenu.rtable.lightpis
    
    InFmenu.rtable.heavypis = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.2, 1.2, -0.2, -0.2}, -- loop
        {1.2, 1.2, -0.4, -0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, 0.4, 0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, -0.4, -0.4}
    }
    InFmenu.rtable.supermediumpis = InFmenu.rtable.heavypis
    
    InFmenu.rtable.shortsmg = InFmenu.rtable.lrifle
    
    InFmenu.rtable.longsmg = InFmenu.rtable.lrifle
    
    --[[
    InFmenu.rtable.akimbo = {
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.5, 0.5}, -- loop
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 0.5, 0.5},
        {2.0, 2.0, -0.2, -0.2},
        {2.0, 2.0, -1.2, -1.2},
        {2.0, 2.0, -1.2, -1.2},
        {2.0, 2.0, -1.2, -1.2}
    }
    --]]
    
    InFmenu.rtable.minigun = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.2, -0.2}, -- loop
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5}
    }
    
    InFmenu.rtable.norecoil = {
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    }
    
    InFmenu.rtable.snp = {
        {1.25, 1.25, 1.0, -1.0},
        {1.25, 1.25, 1.0, -1.0}
    }
    
    
    -- recoil by stance
    InFmenu.rstance.lrifle = {
        standing = {1.2, 1.2, 0.8, 0.8},
        crouching = {1.0, 1.0, 0.7, 0.7},
        steelsight = {0.6, 0.6, 0.5, 0.5}
    }
    InFmenu.rstance.carbine = InFmenu.rstance.lrifle
    InFmenu.rstance.hrifle = InFmenu.rstance.lrifle
    InFmenu.rstance.mrifle = InFmenu.rstance.hrifle
    InFmenu.rstance.mcarbine = InFmenu.rstance.hrifle
    
    InFmenu.rstance.shortsmg = kick_mult(InFmenu.rstance.lrifle, 1, 0.8, 1, 0.8, 1, 0.8)
    InFmenu.rstance.longsmg = InFmenu.rstance.shortsmg
    
    InFmenu.rstance.dmr = {
        standing = {1.5, 1.5, 0.8, 0.8},
        crouching = {1.3, 1.3, 0.6, 0.6},
        steelsight = {1.0, 1.0, 0.3, 0.3}
    }
    InFmenu.rstance.ldmr = {
        standing = {1.3, 1.3, 0.7, 0.7},
        crouching = {1.2, 1.2, 0.55, 0.55},
        steelsight = {0.9, 0.9, 0.25, 0.25}
    }
    InFmenu.rstance.hdmr = InFmenu.rstance.dmr
    
    InFmenu.rstance.snp = {
        standing = {1.5, 1.5, 0.8, 0.8},
        crouching = {1.3, 1.3, 0.6, 0.6},
        steelsight = {1.0, 1.0, 0.3, 0.3}
    }
    
    InFmenu.rstance.lightpis = {
        standing = {1.2, 1.2, 1.0, 1.0},
        crouching = {1.0, 1.0, 0.9, 0.9},
        steelsight = {0.5, 0.5, 0.5, 0.5}
    }
    
    InFmenu.rstance.mediumpis = {
        standing = {1.2, 1.2, 1.0, 1.0},
        crouching = {1.0, 1.0, 0.8, 0.8},
        steelsight = {0.7, 0.7, 0.6, 0.6}
    }
    InFmenu.rstance.supermediumpis = deep_clone(InFmenu.rstance.mediumpis)
    
    InFmenu.rstance.heavypis = {
        standing = {3.0, 3.0, 1.6, 1.6},
        crouching = {2.6, 2.6, 1.2, 1.2},
        steelsight = {1.6, 1.6, 0.6, 0.6}
    }
    
    InFmenu.rstance.shotgun = {
        standing = {2.5, 2.5, 2.2, 2.2},
        crouching = {2.3, 2.3, 2.1, 2.1},
        steelsight = {1.8, 1.8, 1.6, 1.6}
    }
    
    InFmenu.rstance.lmg = {
        standing = {1.0, 1.0, 0.4, 0.4},
        crouching = {0.8, 0.8, 0.3, 0.3},
        steelsight = {0.6, 0.6, 0.25, 0.25}
    }
    
    InFmenu.rstance.minigun = {
        standing = {0.28, 0.28, 0.12, 0.12},
        crouching = {0.24, 0.24, 0.11, 0.11},
        steelsight = {0.20, 0.20, 0.10, 0.10}
    }
    --[[
    InFmenu.rstance.minigun = {
        standing = {0.35, 0.35, 0.15, 0.15},
        crouching = {0.30, 0.30, 0.13, 0.13},
        steelsight = {0.25, 0.25, 0.12, 0.12}
    }
    --]]
    
    InFmenu.rstance.one = {
        standing = {1, 1, 1, 1},
        crouching = {1, 1, 1, 1},
        steelsight = {1, 1, 1, 1}
    }
    
    InFmenu.rstance.norecoil = {
        standing = {0, 0, 0, 0},
        crouching = {0, 0, 0, 0},
        steelsight = {0, 0, 0, 0}
    }

    -- Weapon values
    InFmenu.wpnvalues.lrifle = {}
    InFmenu.wpnvalues.lrifle.damage = 55
    InFmenu.wpnvalues.lrifle.spread = 81
    InFmenu.wpnvalues.lrifle.recoil = 71
    InFmenu.wpnvalues.lrifle.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.lrifle.recoil_loop_point = 12
    InFmenu.wpnvalues.lrifle.ammo = 180
    InFmenu.wpnvalues.lrifle.body_armor_dmg_penalty_mul = 1
    InFmenu.wpnvalues.lrifle_gl = deep_clone(InFmenu.wpnvalues.lrifle)
    InFmenu.wpnvalues.lrifle_gl.ammo = 120
    InFmenu.wpnvalues.mrifle = {}
    InFmenu.wpnvalues.mrifle.damage = 75
    InFmenu.wpnvalues.mrifle.spread = 81
    InFmenu.wpnvalues.mrifle.recoil = 61
    InFmenu.wpnvalues.mrifle.armor_piercing_chance = 0.67
    InFmenu.wpnvalues.mrifle.recoil_loop_point = 9
    InFmenu.wpnvalues.mrifle.ammo = 120
    InFmenu.wpnvalues.mrifle.body_armor_dmg_penalty_mul = 0.95
    InFmenu.wpnvalues.mrifle_gl = deep_clone(InFmenu.wpnvalues.mrifle)
    InFmenu.wpnvalues.mrifle_gl.ammo = 80
    InFmenu.wpnvalues.hrifle = {}
    InFmenu.wpnvalues.hrifle.damage = 90
    InFmenu.wpnvalues.hrifle.spread = 81
    InFmenu.wpnvalues.hrifle.recoil = 56
    InFmenu.wpnvalues.hrifle.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.hrifle.recoil_loop_point = 9
    InFmenu.wpnvalues.hrifle.ammo = 120
    InFmenu.wpnvalues.hrifle.body_armor_dmg_penalty_mul = 0.8
    InFmenu.wpnvalues.hrifle_gl = deep_clone(InFmenu.wpnvalues.hrifle)
    InFmenu.wpnvalues.hrifle_gl.ammo = 80
    InFmenu.wpnvalues.ldmr = {}
    InFmenu.wpnvalues.ldmr.damage = 120 -- bring this up to 130 if i ever use the tankier death sentence health values
    InFmenu.wpnvalues.ldmr.spread = 81
    InFmenu.wpnvalues.ldmr.recoil = 51
    InFmenu.wpnvalues.ldmr.armor_piercing_chance = 1
    InFmenu.wpnvalues.ldmr.recoil_loop_point = 9
    InFmenu.wpnvalues.ldmr.rof = 600
    InFmenu.wpnvalues.ldmr.ammo = 80
    InFmenu.wpnvalues.ldmr.body_armor_dmg_penalty_mul = 0.7
    InFmenu.wpnvalues.dmr = {}
    InFmenu.wpnvalues.dmr.damage = 170
    InFmenu.wpnvalues.dmr.spread = 86
    InFmenu.wpnvalues.dmr.recoil = 41
    InFmenu.wpnvalues.dmr.armor_piercing_chance = 1
    InFmenu.wpnvalues.dmr.recoil_loop_point = 9
    InFmenu.wpnvalues.dmr.rof = 420
    InFmenu.wpnvalues.dmr.ammo = 50
    InFmenu.wpnvalues.dmr.body_armor_dmg_penalty_mul = 0.5
    InFmenu.wpnvalues.hdmr = {}
    InFmenu.wpnvalues.hdmr.damage = 240
    InFmenu.wpnvalues.hdmr.spread = 91
    InFmenu.wpnvalues.hdmr.recoil = 35
    InFmenu.wpnvalues.hdmr.armor_piercing_chance = 1
    InFmenu.wpnvalues.hdmr.recoil_loop_point = 9
    InFmenu.wpnvalues.hdmr.rof = 240
    InFmenu.wpnvalues.hdmr.ammo = 40
    InFmenu.wpnvalues.hdmr.body_armor_dmg_penalty_mul = 0.3

    -- mag presets
    -- output: mag% * reload%
    InFmenu.wpnvalues.reload = {}
    -- 0.5
    InFmenu.wpnvalues.reload.mag_17 = {reload = 200}
    -- 0.6875
    InFmenu.wpnvalues.reload.mag_25 = {reload = 175}
    -- 0.767
    InFmenu.wpnvalues.reload.mag_33 = {reload = 130}
    -- 0.825
    InFmenu.wpnvalues.reload.mag_50 = {reload = 65}
    -- 0.858
    InFmenu.wpnvalues.reload.mag_66 = {reload = 30}
    -- 0.9
    InFmenu.wpnvalues.reload.mag_75 = {reload = 20}
    -- mag100 = 1
    -- 1.1
    InFmenu.wpnvalues.reload.mag_125 = {reload = -12}
    -- 1.1305
    InFmenu.wpnvalues.reload.mag_133 = {reload = -15}
    -- 1.2
    InFmenu.wpnvalues.reload.mag_150 = {reload = -20}
    -- 1.3
    InFmenu.wpnvalues.reload.mag_200 = {reload = -35}
    --
    InFmenu.wpnvalues.reload.mag_250 = {reload = -40}
    -- 1.65
    InFmenu.wpnvalues.reload.mag_300 = {reload = -45}

        -- PISTOLS
    InFmenu.wpnvalues.lightpis = {}
    InFmenu.wpnvalues.lightpis.damage = 55
    InFmenu.wpnvalues.lightpis.spread = 71
    InFmenu.wpnvalues.lightpis.recoil = 71
    InFmenu.wpnvalues.lightpis.armor_piercing_chance = 0.64
    InFmenu.wpnvalues.lightpis.recoil_loop_point = 6
    InFmenu.wpnvalues.lightpis.ammo = 150
    InFmenu.wpnvalues.lightpis.rof = 600
    InFmenu.wpnvalues.lightpis.body_armor_dmg_penalty_mul = 1
    InFmenu.wpnvalues.mediumpis = {}
    InFmenu.wpnvalues.mediumpis.damage = 85
    InFmenu.wpnvalues.mediumpis.spread = 71
    InFmenu.wpnvalues.mediumpis.recoil = 61
    InFmenu.wpnvalues.mediumpis.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.mediumpis.recoil_loop_point = 6
    InFmenu.wpnvalues.mediumpis.ammo = 80
    InFmenu.wpnvalues.mediumpis.rof = 600
    InFmenu.wpnvalues.mediumpis.body_armor_dmg_penalty_mul = 0.85
    InFmenu.wpnvalues.supermediumpis = {}
    InFmenu.wpnvalues.supermediumpis.damage = 110
    InFmenu.wpnvalues.supermediumpis.spread = 71
    InFmenu.wpnvalues.supermediumpis.recoil = 51
    InFmenu.wpnvalues.supermediumpis.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.supermediumpis.recoil_loop_point = 3
    InFmenu.wpnvalues.supermediumpis.ammo = 60
    InFmenu.wpnvalues.supermediumpis.rof = 600
    InFmenu.wpnvalues.supermediumpis.body_armor_dmg_penalty_mul = 0.75
    InFmenu.wpnvalues.heavypis = {}
    InFmenu.wpnvalues.heavypis.damage = 170
    InFmenu.wpnvalues.heavypis.spread = 71
    InFmenu.wpnvalues.heavypis.recoil = 46
    InFmenu.wpnvalues.heavypis.armor_piercing_chance = 1
    InFmenu.wpnvalues.heavypis.recoil_loop_point = 3
    InFmenu.wpnvalues.heavypis.ammo = 42
    InFmenu.wpnvalues.heavypis.rof = 300
    InFmenu.wpnvalues.heavypis.body_armor_dmg_penalty_mul = 0.5

    -- SUBMACHINE GUNS
    InFmenu.wpnvalues.shortsmg = {}
    InFmenu.wpnvalues.shortsmg.damage = 45
    InFmenu.wpnvalues.shortsmg.spread = 51
    InFmenu.wpnvalues.shortsmg.recoil = 81
    InFmenu.wpnvalues.shortsmg.armor_piercing_chance = 0.60
    InFmenu.wpnvalues.shortsmg.recoil_loop_point = 12
    InFmenu.wpnvalues.shortsmg.ammo = 150
    InFmenu.wpnvalues.shortsmg.body_armor_dmg_penalty_mul = 1
    InFmenu.wpnvalues.longsmg = {}
    InFmenu.wpnvalues.longsmg.damage = 50
    InFmenu.wpnvalues.longsmg.spread = 61
    InFmenu.wpnvalues.longsmg.recoil = 76
    InFmenu.wpnvalues.longsmg.armor_piercing_chance = 0.60 -- not used below
    InFmenu.wpnvalues.longsmg.recoil_loop_point = 12 -- not used below
    InFmenu.wpnvalues.longsmg.ammo = 120
    InFmenu.wpnvalues.carbine = {}
    InFmenu.wpnvalues.carbine.damage = 55
    InFmenu.wpnvalues.carbine.spread = 66
    InFmenu.wpnvalues.carbine.recoil = 71
    InFmenu.wpnvalues.carbine.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.carbine.recoil_loop_point = 12
    InFmenu.wpnvalues.carbine.ammo = 120
    InFmenu.wpnvalues.carbine.body_armor_dmg_penalty_mul = 0.95
    InFmenu.wpnvalues.mcarbine = {}
    InFmenu.wpnvalues.mcarbine.damage = 75
    InFmenu.wpnvalues.mcarbine.spread = 66
    InFmenu.wpnvalues.mcarbine.recoil = 66
    InFmenu.wpnvalues.mcarbine.armor_piercing_chance = 0.67
    InFmenu.wpnvalues.mcarbine.recoil_loop_point = 9
    InFmenu.wpnvalues.mcarbine.ammo = 90
    InFmenu.wpnvalues.mcarbine.body_armor_dmg_penalty_mul = 0.9

    -- LMG's
    InFmenu.wpnvalues.lmg = {}
    InFmenu.wpnvalues.lmg.damage = 50
    InFmenu.wpnvalues.lmg.spread = 46
    InFmenu.wpnvalues.lmg.recoil = 61
    InFmenu.wpnvalues.lmg.ammo = 300
    InFmenu.wpnvalues.lmg.body_armor_dmg_penalty_mul = 1
    InFmenu.wpnvalues.lmg.recoil_loop_point = 12
    InFmenu.wpnvalues.mlmg = {}
    InFmenu.wpnvalues.mlmg.damage = 65
    InFmenu.wpnvalues.mlmg.spread = 46
    InFmenu.wpnvalues.mlmg.recoil = 56
    InFmenu.wpnvalues.mlmg.ammo = 300
    InFmenu.wpnvalues.mlmg.body_armor_dmg_penalty_mul = 0.95
    InFmenu.wpnvalues.mlmg.recoil_loop_point = 12
    InFmenu.wpnvalues.hlmg = {}
    InFmenu.wpnvalues.hlmg.damage = 75
    InFmenu.wpnvalues.hlmg.spread = 46
    InFmenu.wpnvalues.hlmg.recoil = 46
    InFmenu.wpnvalues.hlmg.ammo = 200
    InFmenu.wpnvalues.hlmg.body_armor_dmg_penalty_mul = 0.75
    InFmenu.wpnvalues.hlmg.recoil_loop_point = 12
end

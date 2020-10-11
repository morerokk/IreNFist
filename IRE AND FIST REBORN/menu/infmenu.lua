dofile(ModPath .. "infcore.lua")

Hooks:Add('LocalizationManagerPostInit', 'infmenu_wordswordswords', function(loc)
	InFmenu:Load()
	loc:load_localization_file(InFmenu._path .. 'menu/infmenu_en.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'infmenu_init', function(menu_manager)

	MenuCallbackHandler.infsave = function(this, item)
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_donothing = function(this, item)
		-- do nothing
	end

	MenuCallbackHandler.infcb_enablewallrun = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_runkick = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_kickyeet = function(this, item)
		InFmenu.settings.kickyeet = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_dashcontrols = function(this, item)
		InFmenu.settings.dashcontrols = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_slidestealth = function(this, item)
		InFmenu.settings.slidestealth = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_slideloud = function(this, item)
		InFmenu.settings.slideloud = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_slidewpnangle = function(this, item)
		InFmenu.settings.slidewpnangle = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_wallrunwpnangle = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_allpenwalls = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_reloadbreaksads = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_disable_autoreload = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_ene_rainbowassault = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_skulldozersahoy = function(this, item)
		InFmenu.settings.skulldozersahoy = tonumber(item:value())
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_sanehp = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_copfalloff = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end
	MenuCallbackHandler.infcb_ene_copmiss = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_clearnewdrops = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_txt_wpnname = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_goldeneye = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end
	
	MenuCallbackHandler.infcb_disablefrogmanwarnings = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_enablenewcopvoices = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_enablenewcopdomination = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_changeitemprices = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_enablenewassaults = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_thinkfaster = function(this, item)
		InFmenu.settings[item:name()] = item:value() == 'on'
		InFmenu:Save()
	end

	MenuCallbackHandler.infcb_thinkfaster_throughput = function(this, item)
		InFmenu.settings[item:name()] = tonumber(item:value())
		InFmenu:Save()
	end

	InFmenu:Load()

	MenuHelper:LoadFromJsonFile(InFmenu._path .. 'menu/infmenu.txt', InFmenu, InFmenu.settings)
end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_frogman_fss", function(menu_manager, nodes)
	if not InFmenu.settings.disablefrogmanwarnings then
		local fss = BLT.Mods:GetModByName("Full Speed Swarm")
		if not fss or not fss:IsEnabled() then
			return
		end
	
		QuickMenu:new("FSS Detected", "You are using Full Speed Swarm, which breaks some IREnFIST features and breaks the cop AI. We strongly recommend removing or disabling Full Speed Swarm for the best gameplay experience.\n\nYou can disable this warning in the IreNFist mod options.", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end
end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_frogman_iter", function(menu_manager, nodes)
	if not InFmenu.settings.disablefrogmanwarnings then
		local iter = BLT.Mods:GetModByName("Iter")
		if not iter or not iter:IsEnabled() then
			return
		end
	
		QuickMenu:new("Iter Detected", "You are using Iter, which breaks the cops' flanking AI and forces them to always rush at you. In light of InF's assault tweaks, we strongly recommend removing Iter for the best gameplay experience. If you need the mod for Keepers, you can leave it installed but disabled.\n\nYou can disable this warning in the IreNFist mod options.", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end
end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_inf_assaulttweaks_compat_warning", function(menu_manager, nodes)
	if not InFmenu.settings.disablefrogmanwarnings then
		local ats_found = false
		local assaulttweaks = BLT.Mods:GetModByName("Assault Tweaks Standalone")
		if assaulttweaks and assaulttweaks:IsEnabled() then
			ats_found = true
		end
		
		local assaulttweaks_lite = BLT.Mods:GetModByName("Assault Tweaks Standalone Lite")
		if assaulttweaks_lite and assaulttweaks_lite:IsEnabled() then
			ats_found = true
		end
	
		if ats_found then
			QuickMenu:new("Assault Tweaks Detected", "You are using Assault Tweaks Standalone, which is already included in IREnFIST. We strongly recommend removing Assault Tweaks Standalone to avoid crashes or other issues.\n\nYou can disable this warning in the IreNFist mod options.", {
				[1] = {
					text = "OK",
					is_cancel_button = true
				}
			}):show()
		end
	end
end)

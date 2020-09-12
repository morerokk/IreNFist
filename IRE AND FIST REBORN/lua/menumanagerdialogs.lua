dofile(ModPath .. "infcore.lua")

-- Fix the "buy all assets" menu not working if the total asset cost is $0
if InFmenu.settings.changeitemprices then
    function MenuManager:show_confirm_mission_asset_buy_all(params)
        local dialog_data = {
            title = managers.localization:to_upper_text("menu_asset_buy_all"),
            text = "",
            text_formating_color_table = {},
            use_text_formating = true
        }

        local total_cost = 0
        local unlockable_assets = 0

        for _, asset_id in ipairs(params.locked_asset_ids) do
            local td = managers.assets:get_asset_tweak_data_by_id(asset_id)
            local cost = managers.money:get_mission_asset_cost_by_id(asset_id)
            local can_unlock = managers.assets:get_asset_can_unlock_by_id(asset_id)

            if not can_unlock then
                dialog_data.text = dialog_data.text .. "##"

                table.insert(dialog_data.text_formating_color_table, tweak_data.screen_colors.achievement_grey)
                table.insert(dialog_data.text_formating_color_table, tweak_data.screen_colors.important_1)
            else
                unlockable_assets = unlockable_assets + 1
            end

            dialog_data.text = dialog_data.text .. "-" .. managers.localization:text(td.name_id) .. " (" .. managers.experience:cash_string(cost) .. ")"

            if td.upgrade_lock and not can_unlock then
                dialog_data.text = dialog_data.text .. "##  " .. managers.localization:text("menu_asset_buy_all_req_skill") .. "\n"
            elseif td.dlc_lock and not can_unlock then
                dialog_data.text = dialog_data.text .. "##  " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
                    dlc = managers.localization:text(self:get_dlc_by_id(td.dlc_lock).name_id)
                }) .. "\n"
            else
                total_cost = total_cost + cost
                dialog_data.text = dialog_data.text .. "\n"
            end
        end

        if unlockable_assets ~= 0 then
            dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_asset_buy_all_desc", {
                price = managers.experience:cash_string(total_cost)
            })
            local yes_button = {
                text = managers.localization:text("dialog_yes"),
                callback_func = params.yes_func
            }
            local no_button = {
                text = managers.localization:text("dialog_no"),
                callback_func = params.no_func,
                cancel_button = true
            }
            dialog_data.focus_button = 2
            dialog_data.button_list = {
                yes_button,
                no_button
            }
        else
            dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_asset_buy_all_fail")
            local ok_button = {
                text = managers.localization:text("dialog_ok"),
                callback_func = params.ok_func,
                cancel_button = true
            }
            dialog_data.focus_button = 1
            dialog_data.button_list = {
                ok_button
            }
        end

        managers.system_menu:show(dialog_data)
    end
end

-- pvp_gui_system.lua
-- Complete GUI system for PvP-Ultimate
-- Handles all player-facing interfaces

local ranked_system = require("ranked")
local spectate_system = require("spectate")

local gui = {}

-- ============ MAIN PLAY MENU ============

function gui.show_main_menu(player_name)
    local formspec = "formspec_version[4]" ..
        "size[10,10]" ..
        "bgcolor[#222222]" ..
        
        -- Title
        "label[1,0.5;⚔️ PvP-Ultimate]" ..
        "label[1,1;Choose Your Battle Mode]" ..
        
        -- Main buttons
        "button[0.5,2;4.5,1;ranked;🏆 Ranked]" ..
        "button[5.5,2;4,1;unranked;⚔️ Unranked]" ..
        
        "button[0.5,3.3;4.5,1;parties;👥 Parties]" ..
        "button[5.5,3.3;4,1;kits;🎒 Kits]" ..
        
        "button[0.5,4.6;4.5,1;leaderboard;🏅 Leaderboard]" ..
        "button[5.5,4.6;4,1;stats;📊 Statistics]" ..
        
        "button[0.5,5.9;4.5,1;spectate;👁️ Spectate]" ..
        "button[5.5,5.9;4,1;duel;⚔️ Duel]" ..
        
        -- Bottom info
        "label[0.5,7.3;Quick Access]" ..
        "button[0.5,7.8;2.2,0.6;back_to_play;< Back]" ..
        "button[3.2,7.8;2.2,0.6;close_menu;Close]" ..
        "button[5.9,7.8;3.5,0.6;help;? Help]"
    
    minetest.show_formspec(player_name, "pvp_main_menu", formspec)
end

-- ============ RANKED QUEUE MENU ============

function gui.show_ranked_menu(player_name)
    local kits_data = gui.get_available_kits()
    
    local formspec = "formspec_version[4]" ..
        "size[12,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;🏆 Ranked Queue]" ..
        "label[0.5,1;Select a Kit to Queue]" ..
        
        "tabheader[0.5,1.5;10,0.6;kit_tabs;All Kits;1]"
    
    -- Add kit buttons in a grid
    local x, y = 0.5, 2.3
    local col = 0
    
    for i, kit in ipairs(kits_data) do
        if kit.ranked_enabled then
            local rating_data = ranked_system.getPlayerRating(player_name, kit.id)
            
            formspec = formspec ..
                "button[" .. x .. "," .. y .. ";2.8,1.5;ranked_kit_" .. kit.id .. ";" ..
                kit.name .. "\n" ..
                "Rating: " .. rating_data.rating .. "\n" ..
                "Tier: " .. rating_data.rank .. "]"
            
            col = col + 1
            x = x + 3.2
            
            if col >= 3 then
                col = 0
                x = 0.5
                y = y + 2
            end
        end
    end
    
    formspec = formspec ..
        "button[0.5,8.8;3,0.6;< Back;< Back]" ..
        "button[3.7,8.8;3,0.6;queue_status;Queue Status]" ..
        "button[6.9,8.8;4.5,0.6;leave_queue;Leave Queue]"
    
    minetest.show_formspec(player_name, "pvp_ranked_menu", formspec)
end

-- ============ UNRANKED QUEUE MENU ============

function gui.show_unranked_menu(player_name)
    local kits_data = gui.get_available_kits()
    
    local formspec = "formspec_version[4]" ..
        "size[12,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;⚔️ Unranked Queue]" ..
        "label[0.5,1;Select a Kit to Queue]" ..
        "label[0.5,1.4;Ratings will not be affected]"
    
    -- Add kit buttons in a grid
    local x, y = 0.5, 2.3
    local col = 0
    
    for i, kit in ipairs(kits_data) do
        if kit.unranked_enabled then
            formspec = formspec ..
                "button[" .. x .. "," .. y .. ";2.8,1.5;unranked_kit_" .. kit.id .. ";" ..
                kit.name .. "\n" ..
                kit.description .. "\n" ..
                "Queued: N/A]"
            
            col = col + 1
            x = x + 3.2
            
            if col >= 3 then
                col = 0
                x = 0.5
                y = y + 2
            end
        end
    end
    
    formspec = formspec ..
        "button[0.5,8.8;3,0.6;< Back;< Back]" ..
        "button[3.7,8.8;3,0.6;queue_status;Queue Status]" ..
        "button[6.9,8.8;4.5,0.6;leave_queue;Leave Queue]"
    
    minetest.show_formspec(player_name, "pvp_unranked_menu", formspec)
end

-- ============ STATISTICS MENU ============

function gui.show_stats_menu(player_name, target_player)
    target_player = target_player or player_name
    local player_data = ranked_system.getPlayerRating(target_player)
    
    local formspec = "formspec_version[4]" ..
        "size[10,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;📊 Statistics: " .. target_player .. "]" ..
        
        "label[0.5,1.2;Global Rating]" ..
        "label[1,1.6;Rating: " .. player_data.rating .. "]" ..
        "label[1,2;RD: " .. player_data.ratingDeviation .. "]" ..
        "label[1,2.4;Volatility: " .. player_data.volatility .. "]" ..
        "label[1,2.8;Tier: " .. player_data.rank .. "]" ..
        
        "label[5.5,1.2;Match History]" ..
        "label[6,1.6;Wins: 0]" ..
        "label[6,2;Losses: 0]" ..
        "label[6,2.4;Draws: 0]" ..
        "label[6,2.8;Win Rate: N/A]" ..
        
        "label[0.5,3.5;Kit Statistics]" ..
        "textlist[0.5,4;9,4;kit_stats;Kit 1 - Rating: 1500 Tier: Novice,Kit 2 - Rating: 1400 Tier: Intermediate;1;false]" ..
        
        "button[0.5,8.8;3,0.6;< Back;< Back]" ..
        "button[3.7,8.8;3,0.6;refresh;Refresh]" ..
        "button[6.9,8.8;2.5,0.6;close;Close]"
    
    minetest.show_formspec(player_name, "pvp_stats_menu", formspec)
end

-- ============ LEADERBOARD MENU ============

function gui.show_leaderboard_menu(player_name)
    local leaderboard_data = ranked_system.getLeaderboard(20)
    
    local lb_text = ""
    for i, entry in ipairs(leaderboard_data) do
        lb_text = lb_text .. i .. ". " .. entry.name .. " - " .. entry.rating .. " (" .. entry.rank .. ")"
        if i < #leaderboard_data then
            lb_text = lb_text .. ","
        end
    end
    
    local formspec = "formspec_version[4]" ..
        "size[12,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;🏆 Global Leaderboard]" ..
        "label[0.5,1;Top 20 Players by Rating]" ..
        
        "textlist[0.5,1.5;11,6.5;leaderboard;" .. lb_text .. ";1;false]" ..
        
        "button[0.5,8.3;2.5,0.6;< Back;< Back]" ..
        "button[3.3,8.3;3,0.6;kit_filter;Filter by Kit]" ..
        "button[6.5,8.3;2.5,0.6;refresh;Refresh]" ..
        "button[9.2,8.3;2,0.6;close;Close]"
    
    minetest.show_formspec(player_name, "pvp_leaderboard_menu", formspec)
end

-- ============ SPECTATE MENU ============

function gui.show_spectate_menu(player_name)
    local formspec = "formspec_version[4]" ..
        "size[10,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;👁️ Spectate Matches]" ..
        "label[0.5,1;Available Matches]" ..
        
        "textlist[0.5,1.5;9,5.5;match_list;Match 1: Player A vs Player B (Ranked Sword),Match 2: Player C vs Player D (Unranked Crystal),Match 3: Party Tournament - Round 2;1;false]" ..
        
        "button[0.5,7.3;4.5,0.8;spectate_match;👁️ Spectate Selected]" ..
        "button[5.2,7.3;4.3,0.8;stop_spectating;Stop Spectating]" ..
        
        "button[0.5,8.3;3,0.6;< Back;< Back]" ..
        "button[6.8,8.3;3,0.6;close;Close]"
    
    minetest.show_formspec(player_name, "pvp_spectate_menu", formspec)
end

-- ============ PARTY MENU ============

function gui.show_party_menu(player_name)
    local formspec = "formspec_version[4]" ..
        "size[10,10]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;👥 Party System]" ..
        
        "button[0.5,1.2;4.5,1;create_party;🆕 Create Party]" ..
        "button[5.2,1.2;4.3,1;join_party;🔗 Join Party]" ..
        
        "button[0.5,2.5;4.5,1;party_invite;📤 Invite Players]" ..
        "button[5.2,2.5;4.3,1;party_info;ℹ️ Party Info]" ..
        
        "button[0.5,3.8;4.5,1;party_queue;⏱️ Queue as Party]" ..
        "button[5.2,3.8;4.3,1;party_duel;⚔️ Host Duel]" ..
        
        "button[0.5,5.1;4.5,1;tournament;🏆 Tournament]" ..
        "button[5.2,5.1;4.3,1;team_battle;👥 Team Battle]" ..
        
        "button[0.5,6.4;4.5,0.8;leave_party;❌ Leave Party]" ..
        "button[5.2,6.4;4.3,0.8;disband;🗑️ Disband]" ..
        
        "button[0.5,7.5;3,0.6;< Back;< Back]" ..
        "button[6.8,7.5;3,0.6;close;Close]"
    
    minetest.show_formspec(player_name, "pvp_party_menu", formspec)
end

-- ============ DUEL MENU ============

function gui.show_duel_menu(player_name, target_player)
    local kits_data = gui.get_available_kits()
    local kit_options = ""
    
    for i, kit in ipairs(kits_data) do
        kit_options = kit_options .. kit.name
        if i < #kits_data then
            kit_options = kit_options .. ","
        end
    end
    
    local formspec = "formspec_version[4]" ..
        "size[10,8]" ..
        "bgcolor[#222222]" ..
        
        "label[0.5,0.5;⚔️ Challenge " .. (target_player or "Player") .. "]" ..
        
        "label[0.5,1.2;Select Kit:]" ..
        "dropdown[0.5,1.7;4,0.6;kit_select;" .. kit_options .. ";1]" ..
        
        "label[0.5,2.6;Match Type:]" ..
        "dropdown[0.5,3.1;4,0.6;match_type;Ranked,Unranked;1]" ..
        
        "label[5.2,1.2;Your Rating:]" ..
        "label[5.2,1.7;1500]" ..
        
        "label[5.2,2.6;Opponent Rating:]" ..
        "label[5.2,3.1;1450]" ..
        
        "button[0.5,4.3;4.5,0.8;send_challenge;📤 Send Challenge]" ..
        "button[5.2,4.3;4.3,0.8;cancel;Cancel]"
    
    minetest.show_formspec(player_name, "pvp_duel_menu", formspec)
end

-- ============ HELPER FUNCTIONS ============

function gui.get_available_kits()
    -- Return all available kits
    -- This should be populated from your kits system
    return {
        {id = "sword", name = "Sword", description = "Classic sword combat", icon = "default_sword_steel", ranked_enabled = true, unranked_enabled = true},
        {id = "crystal", name = "Crystal", description = "Magic crystal battles", icon = "default_diamond", ranked_enabled = true, unranked_enabled = true},
        {id = "bow", name = "Bow", description = "Long-range archery", icon = "default_bow_wood", ranked_enabled = false, unranked_enabled = true},
    }
end

-- ============ FORMSPEC HANDLER ============

minetest.register_on_player_receive_fields(function(player, formname, fields, pressed)
    if not pressed then return false end
    
    local player_name = player:get_player_name()
    
    -- Main menu
    if formname == "pvp_main_menu" then
        if fields.ranked then
            gui.show_ranked_menu(player_name)
        elseif fields.unranked then
            gui.show_unranked_menu(player_name)
        elseif fields.parties then
            gui.show_party_menu(player_name)
        elseif fields.kits then
            -- Show kits menu (to be implemented)
        elseif fields.leaderboard then
            gui.show_leaderboard_menu(player_name)
        elseif fields.stats then
            gui.show_stats_menu(player_name)
        elseif fields.spectate then
            gui.show_spectate_menu(player_name)
        elseif fields.duel then
            gui.show_duel_menu(player_name)
        elseif fields.help then
            -- Show help menu (to be implemented)
        elseif fields.close_menu then
            minetest.close_formspec(player_name, formname)
        end
        return true
    end
    
    -- Ranked menu
    if formname == "pvp_ranked_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.queue_status then
            -- Show queue status (to be implemented)
        elseif fields.leave_queue then
            minetest.chat_send_player(player_name, "Left queue!")
        else
            -- Check for kit selection
            for key, _ in pairs(fields) do
                if string.match(key, "^ranked_kit_") then
                    local kit_id = string.sub(key, 12)
                    minetest.chat_send_player(player_name, "Queued for ranked " .. kit_id)
                    -- Call actual queue system
                    break
                end
            end
        end
        return true
    end
    
    -- Unranked menu
    if formname == "pvp_unranked_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.queue_status then
            -- Show queue status
        elseif fields.leave_queue then
            minetest.chat_send_player(player_name, "Left queue!")
        else
            -- Check for kit selection
            for key, _ in pairs(fields) do
                if string.match(key, "^unranked_kit_") then
                    local kit_id = string.sub(key, 14)
                    minetest.chat_send_player(player_name, "Queued for unranked " .. kit_id)
                    break
                end
            end
        end
        return true
    end
    
    -- Stats menu
    if formname == "pvp_stats_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.refresh then
            gui.show_stats_menu(player_name)
        elseif fields.close then
            minetest.close_formspec(player_name, formname)
        end
        return true
    end
    
    -- Leaderboard menu
    if formname == "pvp_leaderboard_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.kit_filter then
            -- Show kit filter (to be implemented)
        elseif fields.refresh then
            gui.show_leaderboard_menu(player_name)
        elseif fields.close then
            minetest.close_formspec(player_name, formname)
        end
        return true
    end
    
    -- Spectate menu
    if formname == "pvp_spectate_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.spectate_match then
            spectate_system.start_spectating(player_name)
            minetest.chat_send_player(player_name, "Started spectating!")
        elseif fields.stop_spectating then
            spectate_system.stop_spectating(player_name)
            minetest.chat_send_player(player_name, "Stopped spectating!")
        elseif fields.close then
            minetest.close_formspec(player_name, formname)
        end
        return true
    end
    
    -- Party menu
    if formname == "pvp_party_menu" then
        if fields["< Back"] then
            gui.show_main_menu(player_name)
        elseif fields.close then
            minetest.close_formspec(player_name, formname)
        else
            minetest.chat_send_player(player_name, "Party system: functionality to be implemented")
        end
        return true
    end
    
    -- Duel menu
    if formname == "pvp_duel_menu" then
        if fields.send_challenge then
            minetest.chat_send_player(player_name, "Challenge sent!")
            minetest.close_formspec(player_name, formname)
        elseif fields.cancel then
            gui.show_main_menu(player_name)
        end
        return true
    end
    
    return false
end)

return gui

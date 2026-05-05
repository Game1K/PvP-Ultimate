-- party_items.lua
-- Undroppable item system for party management and spectating

local party = require("party")
local party_commands = require("party_commands")

-- ============ UNDROPPABLE ITEM BASE ============

local function on_drop(itemstack, dropper, pos)
    minetest.chat_send_player(dropper:get_player_name(), "This item cannot be dropped!")
    return itemstack
end

-- ============ PARTY ITEM ============

minetest.register_craftitem("pvpultimate:party_item", {
    description = "Party Management Item (undroppable)",
    inventory_image = "default_diamond.png", -- Default texture, can be changed
    on_drop = on_drop,
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        show_party_menu(player_name)
        return itemstack
    end,
})

-- ============ SPECTATE ITEM ============

minetest.register_craftitem("pvpultimate:spectate_item", {
    description = "Spectate Toggle Item (undroppable)",
    inventory_image = "default_gold_ingot.png", -- Default texture, can be changed
    on_drop = on_drop,
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        toggle_spectate(player_name)
        return itemstack
    end,
})

-- ============ GIVE ITEM COMMANDS ============

minetest.register_chatcommand("givepartyitem", {
    description = "Give yourself a party management item (admin only)",
    privs = {interact = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end
        
        local inv = player:get_inventory()
        inv:add_item("main", "pvpultimate:party_item")
        return true, "Party item given!"
    end
})

minetest.register_chatcommand("givespectateitem", {
    description = "Give yourself a spectate item (admin only)",
    privs = {interact = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end
        
        local inv = player:get_inventory()
        inv:add_item("main", "pvpultimate:spectate_item")
        return true, "Spectate item given!"
    end
})

-- ============ PARTY MENU SYSTEM ============

function show_party_menu(player_name)
    local formspec = "formspec_version[4]"
    formspec = formspec .. "size[8,9]"
    formspec = formspec .. "label[0.5,0.5;PvP-Ultimate Party System]"
    formspec = formspec .. "button[0.5,1.5;7,0.8;create;Create Party]"
    formspec = formspec .. "button[0.5,2.5;7,0.8;join;Join Party]"
    formspec = formspec .. "button[0.5,3.5;7,0.8;info;Party Info]"
    formspec = formspec .. "button[0.5,4.5;7,0.8;invite;Invite Players]"
    formspec = formspec .. "button[0.5,5.5;7,0.8;duel;Host 1v1 Duel]"
    formspec = formspec .. "button[0.5,6.5;7,0.8;tournament;Start Tournament]"
    formspec = formspec .. "button[0.5,7.5;7,0.8;team;Team Battle]"
    formspec = formspec .. "button[0.5,8.5;7,0.8;leave;Leave/Disband Party]"
    
    minetest.show_formspec(player_name, "party_main_menu", formspec)
end

function show_invite_menu(player_name)
    local formspec = "formspec_version[4]"
    formspec = formspec .. "size[8,9]"
    formspec = formspec .. "label[0.5,0.5;Invite Players to Party]"
    formspec = formspec .. "field[0.5,1.5;7,0.8;players;Player Names (space-separated);]"
    formspec = formspec .. "button[0.5,2.5;3.5,0.8;invite_submit;Invite]"
    formspec = formspec .. "button[4,2.5;3.5,0.8;invite_back;Back]"
    
    minetest.show_formspec(player_name, "party_invite_menu", formspec)
end

function show_duel_menu(player_name)
    local party_data = party.get_party(player_name)
    if not party_data then
        minetest.chat_send_player(player_name, "You are not in a party!")
        return
    end
    
    local members = party_data.members
    local member_list = ""
    for i, member in ipairs(members) do
        if member ~= player_name then
            member_list = member_list .. member .. ","
        end
    end
    
    local formspec = "formspec_version[4]"
    formspec = formspec .. "size[8,9]"
    formspec = formspec .. "label[0.5,0.5;Select Players for 1v1 Duel]"
    formspec = formspec .. "field[0.5,1.5;7,0.8;player1;Player 1;]"
    formspec = formspec .. "field[0.5,2.5;7,0.8;player2;Player 2;]"
    formspec = formspec .. "button[0.5,3.5;3.5,0.8;duel_start;Start Duel]"
    formspec = formspec .. "button[4,3.5;3.5,0.8;duel_back;Back]"
    
    minetest.show_formspec(player_name, "party_duel_menu", formspec)
end

function show_tournament_menu(player_name)
    local formspec = "formspec_version[4]"
    formspec = formspec .. "size[8,9]"
    formspec = formspec .. "label[0.5,0.5;Setup Tournament]"
    formspec = formspec .. "label[0.5,1.2;Rounds determine how many times to repeat the tournament]"
    formspec = formspec .. "field[0.5,2;7,0.8;rounds;Number of Rounds;1]"
    formspec = formspec .. "button[0.5,3;3.5,0.8;tournament_start;Start]"
    formspec = formspec .. "button[4,3;3.5,0.8;tournament_back;Back]"
    
    minetest.show_formspec(player_name, "party_tournament_menu", formspec)
end

function show_leave_menu(player_name)
    local party_data = party.get_party(player_name)
    local is_leader = party_data and party_data.leader == player_name
    
    local formspec = "formspec_version[4]"
    formspec = formspec .. "size[8,5]"
    formspec = formspec .. "label[0.5,0.5;Party Options]"
    
    if is_leader then
        formspec = formspec .. "button[0.5,1.5;7,0.8;disband;Disband Party (Admin Only)]"
    end
    
    formspec = formspec .. "button[0.5,2.5;7,0.8;leave;Leave Party]"
    formspec = formspec .. "button[0.5,3.5;7,0.8;back;Back]"
    
    minetest.show_formspec(player_name, "party_leave_menu", formspec)
end

-- ============ FORMSPEC CALLBACKS ============

minetest.register_on_player_receive_fields(function(player, formname, fields, pressed)
    local player_name = player:get_player_name()
    
    if formname == "party_main_menu" then
        if fields.create then
            party.create_party(player_name)
            minetest.chat_send_player(player_name, "Party created!")
            show_party_menu(player_name)
        elseif fields.invite then
            show_invite_menu(player_name)
        elseif fields.info then
            local party_data = party.get_party(player_name)
            if not party_data then
                minetest.chat_send_player(player_name, "You are not in a party!")
            else
                local info = "Party Leader: " .. party_data.leader .. "\n"
                info = info .. "Members: " .. table.concat(party_data.members, ", ")
                minetest.chat_send_player(player_name, info)
            end
            show_party_menu(player_name)
        elseif fields.duel then
            show_duel_menu(player_name)
        elseif fields.tournament then
            show_tournament_menu(player_name)
        elseif fields.team then
            party.start_team_battle(player_name)
            minetest.chat_send_player(player_name, "Team battle started!")
            show_party_menu(player_name)
        elseif fields.leave then
            show_leave_menu(player_name)
        end
        
    elseif formname == "party_invite_menu" then
        if fields.invite_submit and fields.players ~= "" then
            local players_list = fields.players:split(" ")
            for _, target in ipairs(players_list) do
                party.invite_player(player_name, target)
                minetest.chat_send_player(target, player_name .. " has invited you to their party!")
            end
            minetest.chat_send_player(player_name, "Invitations sent!")
            show_party_menu(player_name)
        elseif fields.invite_back then
            show_party_menu(player_name)
        end
        
    elseif formname == "party_duel_menu" then
        if fields.duel_start and fields.player1 ~= "" and fields.player2 ~= "" then
            party.host_duel(player_name, fields.player1, fields.player2)
            minetest.chat_send_player(player_name, "Duel started!")
            show_party_menu(player_name)
        elseif fields.duel_back then
            show_party_menu(player_name)
        end
        
    elseif formname == "party_tournament_menu" then
        if fields.tournament_start then
            local rounds = tonumber(fields.rounds) or 1
            party.start_tournament(player_name, rounds)
            minetest.chat_send_player(player_name, "Tournament started!")
            show_party_menu(player_name)
        elseif fields.tournament_back then
            show_party_menu(player_name)
        end
        
    elseif formname == "party_leave_menu" then
        if fields.leave then
            party.leave_party(player_name)
            minetest.chat_send_player(player_name, "You left the party!")
        elseif fields.disband then
            local party_data = party.get_party(player_name)
            if party_data and party_data.leader == player_name then
                party.disband_party(player_name)
                minetest.chat_send_player(player_name, "Party disbanded!")
            else
                minetest.chat_send_player(player_name, "Only the leader can disband!")
            end
        elseif fields.back then
            show_party_menu(player_name)
        end
    end
end)

-- ============ SPECTATE SYSTEM ============

local spectators = {}

function toggle_spectate(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end
    
    if spectators[player_name] then
        -- Stop spectating
        spectators[player_name] = nil
        player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
        player:set_properties({makes_footstep_sound = true, visual_size = {x = 1, y = 1}})
        minetest.chat_send_player(player_name, "Stopped spectating!")
    else
        -- Start spectating
        spectators[player_name] = true
        player:set_properties({makes_footstep_sound = false, visual_size = {x = 0, y = 0}})
        minetest.chat_send_player(player_name, "Now spectating! (invisible & invulnerable)")
    end
end

function is_spectating(player_name)
    return spectators[player_name] or false
end

-- Prevent spectators from being damaged
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if is_spectating(player:get_player_name()) then
        return 0 -- No damage to spectators
    end
    return hp_change
end, true)

-- Cleanup on disconnect
minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    spectators[player_name] = nil
end)

return {
    show_party_menu = show_party_menu,
    toggle_spectate = toggle_spectate,
    is_spectating = is_spectating,
}

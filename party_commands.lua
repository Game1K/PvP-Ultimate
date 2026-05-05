-- party_commands.lua
-- Chat commands for party system management

local party = require("party")

-- ============ PARTY MAIN COMMAND ============

minetest.register_chatcommand("party", {
    description = "Party system commands - Usage: /party <subcommand>",
    privs = {},
    func = function(name, param)
        local args = param:split(" ")
        local subcommand = args[1] or ""
        
        if subcommand == "" then
            return show_party_help(name)
        elseif subcommand == "create" then
            local party_id = party.create_party(name)
            return true, "Party created! Party ID: " .. party_id
        elseif subcommand == "invite" then
            if not args[2] then
                return false, "Usage: /party invite <player1> [player2] [player3] ..."
            end
            -- Remove first element (invite)
            table.remove(args, 1)
            local results = {}
            for _, target in ipairs(args) do
                local success, msg = party.invite_player(name, target)
                table.insert(results, msg)
            end
            return true, table.concat(results, "\n")
        elseif subcommand == "accept" then
            return party.accept_invite(name)
        elseif subcommand == "decline" then
            return party.decline_invite(name)
        elseif subcommand == "list" then
            return show_party_members(name)
        elseif subcommand == "info" then
            return show_party_info(name)
        elseif subcommand == "host" then
            if not args[2] or not args[3] then
                return false, "Usage: /party host <player1> <player2>"
            end
            return party.host_duel(name, args[2], args[3])
        elseif subcommand == "tournament" then
            local rounds = tonumber(args[2]) or 1
            return party.start_tournament(name, rounds)
        elseif subcommand == "team" or subcommand == "teambattle" then
            return party.start_team_battle(name)
        elseif subcommand == "leave" then
            return party.leave_party(name)
        elseif subcommand == "disband" then
            return party.disband_party(name)
        elseif subcommand == "help" then
            return show_party_help(name)
        else
            return false, "Unknown party command! Use /party help"
        end
    end
})

-- ============ SHORT ALIAS COMMANDS ============

minetest.register_chatcommand("p", {
    description = "Party system (shortened) - Usage: /p <subcommand>",
    privs = {},
    func = function(name, param)
        -- Forward to /party command
        return minetest.registered_chatcommands["party"].func(name, param)
    end
})

minetest.register_chatcommand("spectate", {
    description = "Toggle spectating",
    privs = {},
    func = function(name, param)
        local spectate_item = require("party_items")
        if param == "leave" or param == "stop" then
            minetest.chat_send_player(name, "Stopped spectating!")
            -- Would call spectate toggle here
        else
            minetest.chat_send_player(name, "Use spectate item to toggle spectating!")
        end
        return true
    end
})

minetest.register_chatcommand("s", {
    description = "Spectate (shortened)",
    privs = {},
    func = function(name, param)
        minetest.chat_send_player(name, "Use spectate item to toggle spectating!")
        return true
    end
})

-- ============ HELPER FUNCTIONS ============

function show_party_help(player_name)
    local help = "\n" .. string.rep("=", 70) .. "\n"
    help = help .. "🎭 PARTY SYSTEM COMMANDS\n"
    help = help .. string.rep("=", 70) .. "\n\n"
    
    help = help .. "BASIC COMMANDS:\n"
    help = help .. "  /party create                   - Create a new party\n"
    help = help .. "  /party invite <player> [player2] ... - Invite player(s)\n"
    help = help .. "  /party accept                   - Accept party invite\n"
    help = help .. "  /party decline                  - Decline party invite\n"
    help = help .. "  /party list                     - List party members\n"
    help = help .. "  /party info                     - Show party info\n\n"
    
    help = help .. "DUEL COMMANDS (Leader Only):\n"
    help = help .. "  /party host <player1> <player2> - Start 1v1 duel\n"
    help = help .. "  /party tournament [rounds]      - Start tournament\n"
    help = help .. "  /party team                     - Start team battle\n\n"
    
    help = help .. "PARTY MANAGEMENT:\n"
    help = help .. "  /party leave                    - Leave party\n"
    help = help .. "  /party disband                  - Disband party (leader)\n\n"
    
    help = help .. "SHORTCUTS:\n"
    help = help .. "  /p <command>                    - Use any command above\n"
    help = help .. "  /s                              - Use spectate item\n\n"
    
    help = help .. "ITEM MENUS:\n"
    help = help .. "  Right-click PARTY ITEM          - Full menu system\n"
    help = help .. "  Right-click SPECTATE ITEM       - Toggle spectating\n"
    help = help .. string.rep("=", 70) .. "\n"
    
    minetest.chat_send_player(player_name, help)
    return true
end

function show_party_members(player_name)
    local party_data = party.get_party(player_name)
    
    if not party_data then
        return false, "You are not in a party!"
    end
    
    local message = "\n=== Party Members ===\n"
    for i, member in ipairs(party_data.members) do
        local leader_mark = (member == party_data.leader) and " 👑" or ""
        message = message .. i .. ". " .. member .. leader_mark .. "\n"
    end
    
    return true, message
end

function show_party_info(player_name)
    local party_data = party.get_party(player_name)
    
    if not party_data then
        return false, "You are not in a party!"
    end
    
    local info = "\n=== Party Information ===\n"
    info = info .. "Leader: " .. party_data.leader .. "\n"
    info = info .. "Members: " .. #party_data.members .. "\n"
    info = info .. "Type: " .. (party_data.ranked and "Ranked" or "Casual") .. "\n"
    
    if party_data.active_match then
        info = info .. "Active Match: " .. party_data.active_match.type .. "\n"
        if party_data.active_match.type == "1v1" then
            info = info .. "  Players: " .. party_data.active_match.player1 .. " vs " .. party_data.active_match.player2 .. "\n"
        end
    else
        info = info .. "Active Match: None\n"
    end
    
    if party_data.tournament_data then
        info = info .. "Tournament: Round " .. party_data.tournament_data.current_round .. "/" .. party_data.tournament_data.max_rounds .. "\n"
        info = info .. "  Matches remaining: " .. party_data.tournament_data.matches_remaining .. "\n"
    end
    
    return true, info
end

-- ============ SPECTATE COMMANDS ============

minetest.register_chatcommand("unspectate", {
    description = "Stop spectating",
    privs = {},
    func = function(name, param)
        minetest.chat_send_player(name, "Right-click spectate item to stop spectating!")
        return true
    end
})

-- ============ AUTO-RESPONSES ============

minetest.register_on_chat_message(function(name, message)
    -- Quick accept/decline responses
    if message:lower() == "accept" or message:lower() == "accept party" then
        return party.accept_invite(name)
    elseif message:lower() == "decline" or message:lower() == "decline party" then
        return party.decline_invite(name)
    end
end)

return {
    show_party_help = show_party_help,
    show_party_members = show_party_members,
    show_party_info = show_party_info,
}

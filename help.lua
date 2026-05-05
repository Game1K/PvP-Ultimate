-- help.lua
-- Help and information commands for PvP-Ultimate mod

-- ============ HELP COMMAND (UNIFIED) ============

minetest.register_chatcommand("help", {
    description = "Show PvP-Ultimate help",
    privs = {},
    func = function(name, param)
        -- Check if player has admin privileges
        local is_admin = minetest.check_player_privs(name, {interact = true})
        
        if param == "admin" and is_admin then
            return show_admin_help(name)
        elseif param == "admin" and not is_admin then
            return false, "You do not have permission to view admin help!"
        else
            return show_player_help(name)
        end
    end
})

-- ============ HELP ALIASES ============

minetest.register_chatcommand("h", {
    description = "Show PvP-Ultimate help (shortened)",
    privs = {},
    func = function(name, param)
        return minetest.registered_chatcommands["help"].func(name, param)
    end
})

-- ============ PLAYER HELP ============

function show_player_help(player_name)
    local help = "\n" .. string.rep("=", 70) .. "\n"
    help = help .. "🎮 PVP-ULTIMATE MOD - QUICK START GUIDE\n"
    help = help .. string.rep("=", 70) .. "\n\n"
    
    help = help .. "📋 QUEUE COMMANDS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /q, /queue              - Join casual queue\n"
    help = help .. "  /rq                     - Join ranked queue\n"
    help = help .. "  /l, /leave              - Leave queue\n"
    help = help .. "  /qstatus                - Check queue status\n\n"
    
    help = help .. "⚔️  DUEL COMMANDS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /d <player>             - Challenge player (shortened)\n"
    help = help .. "  /duel <player>          - Challenge player (full)\n\n"
    
    help = help .. "🏆 LEADERBOARD COMMANDS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /lbs                    - View overall leaderboard\n"
    help = help .. "  /lbs <kit>              - View specific kit leaderboard\n"
    help = help .. "  /lbs overall            - Explicit overall command\n"
    help = help .. "  /leaderboards           - Full command for leaderboards\n\n"
    
    help = help .. "🎭 PARTY SYSTEM:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /p create               - Create a party\n"
    help = help .. "  /p invite <names>       - Invite players (space-separated)\n"
    help = help .. "  /p list                 - List party members\n"
    help = help .. "  /p info                 - Show party information\n"
    help = help .. "  /p host <p1> <p2>       - Start 1v1 duel between members\n"
    help = help .. "  /p tournament [rounds]  - Start tournament (1-10 rounds)\n"
    help = help .. "  /p team                 - Start team battle\n"
    help = help .. "  /p leave                - Leave current party\n"
    help = help .. "  /p disband              - Disband party (leader only)\n"
    help = help .. "  /party <cmd>            - Full party command\n\n"
    
    help = help .. "👁️ SPECTATING:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  Right-click SPECTATE ITEM to toggle spectating\n"
    help = help .. "  When spectating:\n"
    help = help .. "    • You are invisible and invulnerable\n"
    help = help .. "    • You cannot damage others or be damaged\n"
    help = help .. "    • You are confined to the arena\n\n"
    
    help = help .. "🎯 USING ITEMS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  PARTY ITEM (undroppable)\n"
    help = help .. "    • Right-click to open full party menu\n"
    help = help .. "    • Create parties, invite, host duels, tournaments, etc.\n\n"
    help = help .. "  SPECTATE ITEM (undroppable)\n"
    help = help .. "    • Right-click to toggle spectating\n\n"
    
    help = help .. "💡 TIPS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  • Party duels auto-spectate other members\n"
    help = help .. "  • Tournament matches are bracket-based\n"
    help = help .. "  • Team battles split by player ELO rating\n"
    help = help .. "  • Leaving during a fight gives opponent the win\n"
    help = help .. "  • Kit names are case-insensitive (/lbs Sword works too)\n"
    help = help .. "  • Use /h or /help for quick access to this guide\n\n"
    
    help = help .. string.rep("=", 70) .. "\n"
    help = help .. "For admin help, use: /help admin\n"
    help = help .. string.rep("=", 70) .. "\n"
    
    minetest.chat_send_player(player_name, help)
    return true
end

-- ============ ADMIN HELP ============

function show_admin_help(player_name)
    local help = "\n" .. string.rep("=", 70) .. "\n"
    help = help .. "⚙️  ADMIN GUIDE - PVP-ULTIMATE MOD\n"
    help = help .. string.rep("=", 70) .. "\n\n"
    
    help = help .. "🔧 KIT SETUP:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /setup list             - List all available kits\n"
    help = help .. "  /setup kit <name> <item> - Create new kit\n"
    help = help .. "  /setup icon <kit> <icon> - Set kit icon\n"
    help = help .. "  /setup help             - Show setup help\n\n"
    help = help .. "  Example:\n"
    help = help .. "    /setup kit sword default:diamond_sword\n"
    help = help .. "    /setup icon sword ⚔️\n\n"
    
    help = help .. "📦 ITEM DISTRIBUTION:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /givepartyitem          - Give party item to yourself\n"
    help = help .. "  /givespectateitem       - Give spectate item to yourself\n\n"
    
    help = help .. "👥 PLAYER MANAGEMENT:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  /kit <name>             - Give yourself a kit\n"
    help = help .. "  /arena <name>           - Teleport to an arena\n"
    help = help .. "  /resetplayer <player>   - Reset player stats\n"
    help = help .. "  /rankedban <player>     - Ban player from ranked\n\n"
    
    help = help .. "📊 AVAILABLE ITEMS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  Default Minetest items:\n"
    help = help .. "    • default:diamond_sword\n"
    help = help .. "    • default:stone_sword\n"
    help = help .. "    • default:wood_sword\n"
    help = help .. "    • default:bronze_sword\n"
    help = help .. "    • default:steel_axe\n"
    help = help .. "    • default:stone_axe\n"
    help = help .. "    • default:wood_axe\n"
    help = help .. "    • default:bronze_axe\n"
    help = help .. "    • default:bow\n"
    help = help .. "  (Add custom items from other mods)\n\n"
    
    help = help .. "⚡ KEY FEATURES:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  Tournament Brackets:\n"
    help = help .. "    - Auto-generates 2-player matches per round\n"
    help = help .. "    - Winners advance to next round\n"
    help = help .. "    - Chat updates on match progress\n\n"
    help = help .. "  Team Battles:\n"
    help = help .. "    - Automatically splits party evenly\n"
    help = help .. "    - Balanced by ELO rating per kit\n"
    help = help .. "    - Unranked players treated as lower rank\n\n"
    help = help .. "  1v1 Hosting:\n"
    help = help .. "    - Leader selects any 2 party members\n"
    help = help .. "    - Other members auto-spectate\n"
    help = help .. "    - Winner gains ELO for ranked matches\n\n"
    
    help = help .. "💡 ADMIN TIPS:\n"
    help = help .. "───────────────────────────────────────────────────────────────────────\n"
    help = help .. "  • Kit names are case-insensitive internally\n"
    help = help .. "  • Duplicate kits are prevented automatically\n"
    help = help .. "  • Spectators cannot be damaged or damage others\n"
    help = help .. "  • Players leaving fights give opponent the win (no ELO)\n"
    help = help .. "  • Ranked bans prevent specific players from ranked queues\n"
    help = help .. "  • All items are undroppable (cannot be lost)\n"
    help = help .. "  • Use /modhelp to see player-facing help\n\n"
    
    help = help .. string.rep("=", 70) .. "\n"
    help = help .. "For player help, use: /help\n"
    help = help .. string.rep("=", 70) .. "\n"
    

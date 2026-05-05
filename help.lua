-- help.lua
-- Help and information commands for PvP-Ultimate mod

-- ============ MODHELP COMMAND ============

minetest.register_chatcommand("modhelp", {
    description = "Show basic PvP-Ultimate mod help",
    privs = {},
    func = function(name, param)
        local help = "\n" .. string.rep("=", 70) .. "\n"
        help = help .. "🎮 PVP-ULTIMATE MOD - QUICK START GUIDE\n"
        help = help .. string.rep("=", 70) .. "\n\n"
        
        help = help .. "📋 BASIC COMMANDS:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Queue System:\n"
        help = help .. "    /q, /queue         - Join casual queue\n"
        help = help .. "    /rq                - Join ranked queue\n"
        help = help .. "    /l, /leave         - Leave queue\n"
        help = help .. "    /qstatus           - Check queue status\n\n"
        
        help = help .. "  Duels:\n"
        help = help .. "    /d <player>        - Challenge player to duel\n"
        help = help .. "    /duel <player>     - Full command for duel\n\n"
        
        help = help .. "  Leaderboards:\n"
        help = help .. "    /lbs               - View overall leaderboard\n"
        help = help .. "    /lbs <kit>         - View specific kit leaderboard\n"
        help = help .. "    /lbs overall       - Explicit overall command\n"
        help = help .. "    /leaderboards      - Full command for leaderboards\n\n"
        
        help = help .. "🎭 PARTY SYSTEM:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Right-click PARTY ITEM (undroppable) for full menu:\n"
        help = help .. "    - Create/Join parties\n"
        help = help .. "    - Invite multiple players\n"
        help = help .. "    - Host 1v1 duels\n"
        help = help .. "    - Start tournaments\n"
        help = help .. "    - Team battles\n"
        help = help .. "    - Leave/Disband party\n\n"
        
        help = help .. "👁️ SPECTATING:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Right-click SPECTATE ITEM (undroppable) to toggle:\n"
        help = help .. "    - Watch active duels\n"
        help = help .. "    - Cannot be damaged\n"
        help = help .. "    - Cannot damage others\n"
        help = help .. "    - Auto-restore when done\n\n"
        
        help = help .. "🎯 KITS:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  When joining queue, select a kit:\n"
        help = help .. "    - Each kit has unique weapons/abilities\n"
        help = help .. "    - Separate leaderboards per kit\n"
        help = help .. "    - Kit items are undroppable during fights\n\n"
        
        help = help .. "💡 TIPS:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  • Use /setup help for setup information\n"
        help = help .. "  • Party duels auto-spectate other members\n"
        help = help .. "  • Tournament matches are brackets-based\n"
        help = help .. "  • Team battles split by ELO rating\n"
        help = help .. "  • Leaving during a fight gives opponent the win\n"
        help = help .. "  • Case-insensitive commands and kit names\n"
        
        help = help .. string.rep("=", 70) .. "\n"
        
        minetest.chat_send_player(name, help)
        return true
    end
})

-- ============ ADMINMODHELP COMMAND ============

minetest.register_chatcommand("adminmodhelp", {
    description = "Show admin PvP-Ultimate mod help (admin only)",
    privs = {interact = true},
    func = function(name, param)
        local help = "\n" .. string.rep("=", 70) .. "\n"
        help = help .. "⚙️  ADMIN GUIDE - PVP-ULTIMATE MOD\n"
        help = help .. string.rep("=", 70) .. "\n\n"
        
        help = help .. "🔧 ADMIN COMMANDS:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Setup/Configuration:\n"
        help = help .. "    /setup              - Show setup help\n"
        help = help .. "    /setup list         - List all kits\n"
        help = help .. "    /setup kit <name> <item>\n"
        help = help .. "                        - Create new kit with item\n"
        help = help .. "    /setup icon <kit> <icon>\n"
        help = help .. "                        - Set icon for kit\n\n"
        
        help = help .. "  Item Distribution:\n"
        help = help .. "    /givepartyitem      - Give yourself party item\n"
        help = help .. "    /givespectateitem   - Give yourself spectate item\n\n"
        
        help = help .. "  Kit Management:\n"
        help = help .. "    /kit <name>         - Give yourself a kit\n"
        help = help .. "    /arena <name>       - Teleport to arena\n"
        help = help .. "    /resetplayer <player>\n"
        help = help .. "                        - Reset player stats\n"
        help = help .. "    /rankedban <player> - Ban from ranked\n\n"
        
        help = help .. "📊 CONFIGURATION GUIDE:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Creating Kits:\n"
        help = help .. "    1. /setup kit sword default:diamond_sword\n"
        help = help .. "    2. /setup icon sword ⚔️\n"
        help = help .. "    Players can now /q or /rq and select 'sword'\n\n"
        
        help = help .. "  Available Items (Minetest defaults):\n"
        help = help .. "    - default:diamond_sword\n"
        help = help .. "    - default:stone_sword\n"
        help = help .. "    - default:wood_sword\n"
        help = help .. "    - default:bronze_sword\n"
        help = help .. "    - default:steel_axe\n"
        help = help .. "    - default:stone_axe\n"
        help = help .. "    - default:wood_axe\n"
        help = help .. "    - default:bronze_axe\n"
        help = help .. "    - default:bow\n"
        help = help .. "    (Add custom items from other mods)\n\n"
        
        help = help .. "🎯 PARTY SYSTEM FEATURES:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Tournament Brackets:\n"
        help = help .. "    - Auto-generates 2-player matches\n"
        help = help .. "    - Winners advance to next round\n"
        help = help .. "    - Chat updates on match progress\n\n"
        
        help = help .. "  Team Battles:\n"
        help = help .. "    - Splits party evenly into teams\n"
        help = help .. "    - Balanced by ELO rating\n"
        help = help .. "    - Unranked players treated as lower rank\n\n"
        
        help = help .. "  1v1 Hosting:\n"
        help = help .. "    - Leader can select any 2 party members\n"
        help = help .. "    - Others auto-spectate\n"
        help = help .. "    - Winner gets ELO for ranked matches\n\n"
        
        help = help .. "⚡ ADMIN TIPS:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  • Kit names are case-insensitive internally\n"
        help = help .. "  • Duplicate kits are prevented automatically\n"
        help = help .. "  • Spectators cannot be damaged or damage others\n"
        help = help .. "  • Players leaving fights give opponent win\n"
        help = help .. "  • Ranked bans prevent specific players from queuing ranked\n"
        help = help .. "  • All items are undroppable (cannot be lost)\n"
        help = help .. "  • Use /modhelp to see player-facing help\n\n"
        
        help = help .. "📝 DATABASE STRUCTURE:\n"
        help = help .. "───────────────────────────────────────────────────────────────────────\n"
        help = help .. "  Leaderboards:\n"
        help = help .. "    - Per-kit leaderboards (separate scores)\n"
        help = help .. "    - Overall combined leaderboard\n"
        help = help .. "    - ELO ratings stored per kit\n\n"
        
        help = help .. "  Party Data:\n"
        help = help .. "    - Party members and leader\n"
        help = help .. "    - Active tournaments/battles\n"
        help = help .. "    - Spectator lists\n\n"
        
        help = help .. string.rep("=", 70) .. "\n"
        help = help .. "For technical documentation, see mod files\n"
        help = help .. string.rep("=", 70) .. "\n"
        
        minetest.chat_send_player(name, help)
        return true
    end
})

return {
    help = true
}

-- pvp_commands.lua
-- Clean command/GUI entry points. Ranked and unranked are selected via GUI, not separate commands.

local kits = rawget(_G, "pvp_kits") or rawget(_G, "pvp_kit_api") or {}
local queue = rawget(_G, "pvp_queue") or {}
local function esc(v) return minetest.formspec_escape(tostring(v or "")) end
local function btn(x, y, w, h, name, label)
    return ("button[%s,%s;%s,%s;%s;%s]"):format(x, y, w, h, name, esc(label))
end

local function get_rating(player_name, kit_id)
    local ranked_mod = rawget(_G, "pvp_ranked")
    if ranked_mod and ranked_mod.getPlayerRating then
        local ok, data = pcall(ranked_mod.getPlayerRating, player_name, kit_id)
        if ok and data then return data end
    end
    return {rating = 1500, ratingDeviation = 350, volatility = 0.06, rank = "Novice"}
end

local function show_main(name)
    local fs = "formspec_version[4]size[10,9]"
    fs = fs .. "label[0.5,0.4;PvP-Ultimate]"
    fs = fs .. "label[0.5,0.9;Choose a mode or profile]"
    fs = fs .. btn(0.5,1.7,4.2,0.8,"ranked","Ranked")
    fs = fs .. btn(5.0,1.7,4.2,0.8,"unranked","Unranked")
    fs = fs .. btn(0.5,2.9,4.2,0.8,"parties","Parties")
    fs = fs .. btn(5.0,2.9,4.2,0.8,"kits","Kits")
    fs = fs .. btn(0.5,4.1,4.2,0.8,"leaderboard","Leaderboards")
    fs = fs .. btn(5.0,4.1,4.2,0.8,"stats","Statistics")
    fs = fs .. btn(0.5,5.3,4.2,0.8,"spectate","Spectate")
    fs = fs .. btn(5.0,5.3,4.2,0.8,"duel","Duel")
    fs = fs .. btn(3.5,7.0,3.0,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:main", fs)
end

local function show_kits(name, mode)
    local list = kits.list and kits.list(mode) or {}
    local fs = "formspec_version[4]size[12,10]"
    fs = fs .. "label[0.5,0.4;" .. esc(mode == "ranked" and "Ranked kits" or "Unranked kits") .. "]"
    fs = fs .. "label[0.5,0.9;Select a kit to queue. Unranked does not modify ratings.]"
    local x, y, col = 0.5, 1.5, 0
    for _, kit in ipairs(list) do
        if kit.enabled and (mode == "unranked" and kit.unranked_enabled ~= false or mode == "ranked" and kit.ranked_enabled ~= false) then
            local data = get_rating(name, kit.id)
            local text = kit.name .. "\n" .. kit.description
            if mode == "ranked" then
                text = text .. "\nRating: " .. data.rating .. " | RD: " .. data.ratingDeviation .. "\nTier: " .. data.rank
            end
            fs = fs .. "item_image_button[" .. x .. "," .. y .. ";1,1;" .. esc(kit.icon) .. ";" .. mode .. "_kit_" .. kit.id .. ";]"
            fs = fs .. btn(x + 1.2, y, 2.9, 1.0, mode .. "_kit_" .. kit.id, text)
            col = col + 1
            x = x + 4.0
            if col >= 3 then
                col = 0
                x = 0.5
                y = y + 1.8
            end
        end
    end
    fs = fs .. btn(0.5, 8.8, 2.5, 0.7, "back", "Back")
    fs = fs .. btn(9.1, 8.8, 2.5, 0.7, "close", "Close")
    minetest.show_formspec(name, "pvp:kits:"..mode, fs)
end

local function show_player_stats(name, target)
    target = target and target ~= "" and target or name
    local data = get_rating(target, "sword")
    local fs = "formspec_version[4]size[8,7]"
    fs = fs .. "label[0.5,0.4;Statistics: " .. esc(target) .. "]"
    fs = fs .. "label[0.7,1.2;Rating: " .. data.rating .. "]"
    fs = fs .. "label[0.7,1.7;RD: " .. data.ratingDeviation .. "]"
    fs = fs .. "label[0.7,2.2;Volatility: " .. data.volatility .. "]"
    fs = fs .. "label[0.7,2.7;Tier: " .. esc(data.rank) .. "]"
    fs = fs .. "label[0.7,3.5;Win rate and match history are exposed by the match-record module when available.]"
    fs = fs .. btn(0.5,5.8,2.5,0.7,"back","Back")
    fs = fs .. btn(5.0,5.8,2.5,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:stats", fs)
end

local function show_leaderboard(name)
    local ranked_mod = rawget(_G, "pvp_ranked")
    local rows = {}
    if ranked_mod and ranked_mod.getLeaderboard then
        rows = ranked_mod.getLeaderboard(10)
    end
    local text = ""
    for i, row in ipairs(rows) do
        text = text .. i .. ". " .. esc(row.name) .. " - " .. row.rating .. " (" .. esc(row.rank) .. ")"
        if i < #rows then text = text .. "," end
    end
    if text == "" then text = "No rating data available" end
    local fs = "formspec_version[4]size[9,8]"
    fs = fs .. "label[0.5,0.4;Leaderboard]"
    fs = fs .. "textlist[0.5,1;8,5.5;rows;" .. text .. ";1;false]"
    fs = fs .. btn(0.5,7.0,2.5,0.7,"back","Back")
    fs = fs .. btn(6.1,7.0,2.5,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:leaderboard", fs)
end

local function handle_join(name, mode, kit_id)
    if type(queue.joinQueue) ~= "function" then
        return false, "Queue system unavailable"
    end
    if mode == "ranked" then
        return queue.joinRankedQueue(name, kit_id)
    else
        return queue.joinUnrankedQueue(name, kit_id)
    end
end

local function register(name, params, description, cb, privs)
    minetest.register_chatcommand(name, {
        params = params or "",
        description = description,
        privs = privs or {},
        func = cb
    })
end

register("play", nil, "Open the PvP menu", function(name)
    show_main(name)
    return true
end)

register("stats", "[player]", "Open player statistics", function(name, param)
    param = (param or ""):trim()
    show_player_stats(name, param)
    return true
end)

register("rank", "[player]", "Show ranking information", function(name, param)
    param = (param or ""):trim()
    show_player_stats(name, param)
    return true
end)

register("leaderboard", nil, "Open the leaderboard", function(name)
    show_leaderboard(name)
    return true
end)

register("kits", nil, "Open the kit selection GUI", function(name)
    show_kits(name, "unranked")
    return true
end)

register("party", nil, "Open the party interface", function(name)
    if rawget(_G, "party_commands") and party_commands.show_help then
        return party_commands.show_help(name)
    end
    minetest.chat_send_player(name, "Use /play → Parties, or the existing party chat commands.")
    show_main(name)
    return true
end)

register("duel", "[player]", "Open duel flow", function(name, param)
    param = (param or ""):trim()
    if param == "" then
        return false, "Usage: /duel <player>"
    end
    minetest.chat_send_player(name, "Challenge flow for " .. param .. " is available from /play → Duel.")
    return true
end)

register("spectate", nil, "Open spectate flow", function(name)
    minetest.chat_send_player(name, "Use /play → Spectate for the spectator menu.")
    show_main(name)
    return true
end)

register("pvpadmin", nil, "Open admin tools", function(name)
    if not minetest.check_player_privs(name, {server = true}) then
        return false, "Server privilege required"
    end
    minetest.chat_send_player(name, "Admin tools are exposed by the arena and kit management modules.")
    return true
end, {server = true})

register("pvpdebug", nil, "Run basic PvP diagnostics", function(name)
    local status = {
        queue_system = type(queue.joinQueue) == "function" and "ok" or "missing",
        ranked_queue = queue.getQueueInfo and "ok" or "missing",
        unranked_queue = queue.getQueueInfo and "ok" or "missing",
        kit_registration = kits.list and "ok" or "missing",
        glicko2 = rawget(_G, "glicko2") and "ok" or "missing",
        arena_system = rawget(_G, "pvp_arenas") and "ok" or "missing",
        party_system = rawget(_G, "party_commands") and "ok" or "missing"
    }
    local out = "PvP diagnostics\n"
    for key, value in pairs(status) do
        out = out .. key .. ": " .. value .. "\n"
    end
    minetest.chat_send_player(name, out)
    return true
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "pvp:main" then
        if fields.ranked then
            show_kits(name, "ranked")
        elseif fields.unranked then
            show_kits(name, "unranked")
        elseif fields.stats then
            show_player_stats(name, name)
        elseif fields.leaderboard then
            show_leaderboard(name)
        elseif fields.kits then
            show_kits(name, "unranked")
        elseif fields.close then
            minetest.close_formspec(name, formname)
        elseif fields.parties then
            minetest.chat_send_player(name, "Use the existing party system or /party for command-driven controls.")
        elseif fields.spectate then
            minetest.chat_send_player(name, "Use the spectator module from the live match flow.")
        elseif fields.duel then
            minetest.chat_send_player(name, "Use /duel <player> to open the challenge flow.")
        end
        return true
    end

    if formname == "pvp:stats" or formname == "pvp:leaderboard" then
        if fields.back then show_main(name) elseif fields.close then minetest.close_formspec(name, formname) end
        return true
    end

    local mode = formname:match("^pvp:kits:(ranked)$") or formname:match("^pvp:kits:(unranked)$")
    if mode then
        if fields.back then
            show_main(name)
        elseif fields.close then
            minetest.close_formspec(name, formname)
        else
            for key, _ in pairs(fields) do
                local kit_id = key:match("^" .. mode .. "_kit_(.+)$")
                if kit_id then
                    local ok, msg = handle_join(name, mode, kit_id)
                    minetest.chat_send_player(name, msg or (ok and "Queued" or "Queue failed"))
                    break
                end
            end
        end
        return true
    end

    return false
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if queue.leaveQueue then
        pcall(queue.leaveQueue, name)
    end
end)

_G.pvp_commands = {
    show_main = show_main,
    show_kits = show_kits,
    show_stats = show_player_stats,
    show_leaderboard = show_leaderboard,
    join = handle_join
}

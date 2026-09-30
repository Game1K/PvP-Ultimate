-- pvp_commands.lua
-- Single player-facing command/router and formspec UI.
-- Ranked/unranked are GUI modes, not separate commands.

local kits = assert(_G.pvp_kits, "pvp_kits.lua must load first")
local ranked = _G.pvp_ranked or nil
local active_queue = {}
local selected_targets = {}

local function esc(value) return minetest.formspec_escape(tostring(value or "")) end
local function button(x, y, w, h, name, label)
    return ("button[%s,%s;%s,%s;%s;%s]"):format(x, y, w, h, name, esc(label))
end
local function close(name) minetest.close_formspec(name, "pvp:") end

local function rating(name, kit_id)
    if ranked and ranked.getPlayerRating then
        local ok, data = pcall(ranked.getPlayerRating, name, kit_id)
        if ok and data then return data end
    end
    return {rating=1500, ratingDeviation=350, volatility=0.06, rank="Novice"}
end

local function show_main(name)
    local fs = "formspec_version[4]size[10,9]label[0.5,0.4;PvP-Ultimate]label[0.5,0.9;Choose a mode or open your profile]"
    fs = fs .. button(0.5,1.6,4.3,0.8,"ranked","Ranked") .. button(5.1,1.6,4.3,0.8,"unranked","Unranked")
    fs = fs .. button(0.5,2.7,4.3,0.8,"party","Parties") .. button(5.1,2.7,4.3,0.8,"kits","Kits")
    fs = fs .. button(0.5,3.8,4.3,0.8,"leaderboard","Leaderboards") .. button(5.1,3.8,4.3,0.8,"stats","Statistics")
    fs = fs .. button(0.5,4.9,4.3,0.8,"spectate","Spectate") .. button(5.1,4.9,4.3,0.8,"duel","Duel")
    fs = fs .. button(3.5,6.5,3,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:main", fs)
end

local function show_kits(name, mode)
    local list = kits.list(mode)
    local fs = "formspec_version[4]size[12,10]label[0.5,0.4;" .. esc(mode == "ranked" and "Ranked kits" or "Unranked kits") .. "]"
    fs = fs .. "label[0.5,0.9;Select a kit. Rating data is per kit and is unchanged in unranked mode.]"
    local x, y, col = 0.5, 1.5, 0
    for _, kit in ipairs(list) do
        local data = rating(name, kit.id)
        local label = kit.name .. "\n" .. kit.description
        if mode == "ranked" then label = label .. "\nRating " .. data.rating .. " | RD " .. data.ratingDeviation .. "\nTier " .. data.rank end
        fs = fs .. "item_image_button[" .. x .. "," .. y .. ";1,1;" .. esc(kit.icon) .. ";kit_" .. esc(kit.id) .. ";]"
        fs = fs .. button(x+1.1,y,2.5,1.1,"kit_"..kit.id,label)
        col = col + 1; x = x + 4
        if col >= 3 then col = 0; x = 0.5; y = y + 1.7 end
    end
    fs = fs .. button(0.5,8.8,2.5,0.6,"back","Back") .. button(9,8.8,2.5,0.6,"close","Close")
    minetest.show_formspec(name, "pvp:kits:" .. mode, fs)
end

local function queue_status(name)
    local q = active_queue[name]
    return q and (q.mode .. " / " .. q.kit) or "Not queued"
end

local function join(name, mode, kit_id)
    if active_queue[name] then return false, "You are already queued for " .. queue_status(name) end
    local player = minetest.get_player_by_name(name)
    if not player then return false, "Player is not online" end
    local fn = mode == "ranked" and rawget(_G, "joinRankedQueue") or rawget(_G, "joinQueue")
    if type(fn) ~= "function" then return false, "The existing " .. mode .. " queue is unavailable" end
    local ok, err = pcall(fn, name, kit_id)
    if not ok then return false, "Queue error: " .. tostring(err) end
    active_queue[name] = {mode=mode, kit=kit_id}
    return true, "Joined " .. mode .. " queue for " .. kit_id
end

local function show_stats(name, target)
    target = target ~= "" and target or name
    local data = rating(target)
    local fs = "formspec_version[4]size[8,7]label[0.5,0.4;Statistics: "..esc(target).."]"
    fs = fs .. "label[0.7,1.2;Rating: "..data.rating.."]label[0.7,1.7;Rating deviation: "..data.ratingDeviation.."]"
    fs = fs .. "label[0.7,2.2;Volatility: "..data.volatility.."]label[0.7,2.7;Tier: "..esc(data.rank).."]"
    fs = fs .. "label[0.7,3.5;Match history is supplied by the match-storage module when available.]"
    fs = fs .. button(0.5,5.8,2.5,0.6,"back","Back") .. button(5,5.8,2.5,0.6,"close","Close")
    minetest.show_formspec(name, "pvp:stats", fs)
end

local function show_leaderboard(name)
    local rows = {}
    if ranked and ranked.getLeaderboard then rows = ranked.getLeaderboard(10) end
    local text = ""
    for i, row in ipairs(rows) do text = text .. i .. ". " .. esc(row.name) .. " - " .. row.rating .. " (" .. esc(row.rank) .. ")" .. (i < #rows and "," or "") end
    if text == "" then text = "No rating data available" end
    local fs = "formspec_version[4]size[9,8]label[0.5,0.4;Leaderboard]textlist[0.5,1;8,5.5;rows;"..text..";1;false]"
    fs = fs .. button(0.5,7,2.5,0.6,"back","Back") .. button(6,7,2.5,0.6,"close","Close")
    minetest.show_formspec(name, "pvp:leaderboard", fs)
end

local function register(name, description, params, func, privs)
    minetest.register_chatcommand(name, {description=description, params=params or "", privs=privs or {}, func=func})
end

register("play", "Open the PvP menu", nil, function(name) show_main(name); return true end)
register("stats", "Open player statistics", "[player]", function(name, param) show_stats(name, param:trim()); return true end)
register("rank", "Show Glicko-2 rating", "[player]", function(name, param) show_stats(name, param:trim()); return true end)
register("leaderboard", "Open the leaderboard", nil, function(name) show_leaderboard(name); return true end)
register("kits", "Open kit selection", nil, function(name) show_kits(name, "unranked"); return true end)
register("party", "Open the party interface", nil, function(name) minetest.chat_send_player(name, "Use the Parties button in /play; existing party commands remain available."); show_main(name); return true end)
register("duel", "Open duel interface", "[player]", function(name, param) selected_targets[name]=param:trim(); show_main(name); return true end)
register("spectate", "Open spectator interface", nil, function(name) minetest.chat_send_player(name, "Use Spectate from /play."); show_main(name); return true end)
register("arena", "Open arena administration", nil, function(name) if not minetest.check_player_privs(name,{server=true}) then return false,"Server privilege required" end minetest.chat_send_player(name,"Arena administration uses the existing arena manager."); return true end, {server=true})
register("kit", "Open kit administration", nil, function(name) if not minetest.check_player_privs(name,{server=true}) then return false,"Server privilege required" end show_kits(name,"unranked"); return true end, {server=true})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "pvp:main" then
        if fields.ranked then show_kits(name,"ranked") elseif fields.unranked or fields.kits then show_kits(name,"unranked") elseif fields.stats then show_stats(name,name) elseif fields.leaderboard then show_leaderboard(name) elseif fields.close then close(name) elseif fields.party then minetest.chat_send_player(name,"Open the existing party interface with /party <subcommand>.") elseif fields.spectate then minetest.chat_send_player(name,"No public match list is exposed by the existing spectator module.") elseif fields.duel then minetest.chat_send_player(name,"Use /duel <player> to select a challenge target.") end
        return true
    end
    local mode = formname:match("^pvp:kits:(ranked)$") or formname:match("^pvp:kits:(unranked)$")
    if mode then
        if fields.back then show_main(name) elseif fields.close then close(name) else
            for key in pairs(fields) do
                local id = key:match("^kit_(.+)$")
                if id then local ok, msg = join(name,mode,id); minetest.chat_send_player(name,msg); break end
            end
        end
        return true
    end
    if formname == "pvp:stats" or formname == "pvp:leaderboard" then if fields.back then show_main(name) elseif fields.close then close(name) end return true end
end)

minetest.register_on_leaveplayer(function(player) active_queue[player:get_player_name()] = nil end)
_G.pvp_gui = {show_main=show_main, show_kits=show_kits, show_stats=show_stats}

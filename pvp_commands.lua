-- pvp_commands.lua
-- Player-facing commands and GUI. Ranked/unranked are GUI modes.

local kits = rawget(_G, "pvp_kits") or rawget(_G, "pvp_kit_api") or {}
local queue = rawget(_G, "pvp_queue") or {}

local function esc(value) return minetest.formspec_escape(tostring(value or "")) end
local function button(x, y, w, h, name, label)
    return ("button[%s,%s;%s,%s;%s;%s]"):format(x, y, w, h, name, esc(label))
end
local function rating(name, kit_id)
    local ranked = rawget(_G, "pvp_ranked")
    if ranked and ranked.getPlayerRating then
        local ok, data = pcall(ranked.getPlayerRating, name, kit_id)
        if ok and data then return data end
    end
    return {rating=1500, ratingDeviation=350, volatility=0.06, rank="Novice"}
end

local function show_main(name)
    local fs = "formspec_version[4]size[10,9]label[0.5,0.4;PvP-Ultimate]label[0.5,0.9;Choose a mode or open your profile]"
    fs = fs .. button(0.5,1.7,4.2,0.8,"ranked","Ranked") .. button(5,1.7,4.2,0.8,"unranked","Unranked")
    fs = fs .. button(0.5,2.9,4.2,0.8,"parties","Parties") .. button(5,2.9,4.2,0.8,"kits","Kits")
    fs = fs .. button(0.5,4.1,4.2,0.8,"leaderboard","Leaderboards") .. button(5,4.1,4.2,0.8,"stats","Statistics")
    fs = fs .. button(0.5,5.3,4.2,0.8,"spectate","Spectate") .. button(5,5.3,4.2,0.8,"duel","Duel")
    fs = fs .. button(3.5,7,3,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:main", fs)
end

local function show_kits(name, mode)
    local list = kits.list and kits.list(mode) or {}
    local fs = "formspec_version[4]size[12,10]label[0.5,0.4;" .. esc(mode == "ranked" and "Ranked kits" or "Unranked kits") .. "]"
    fs = fs .. "label[0.5,0.9;Select a kit. Unranked matches do not modify ratings.]"
    local x, y, column = 0.5, 1.5, 0
    for _, kit in ipairs(list) do
        local data = rating(name, kit.id)
        local label = kit.name .. "\n" .. kit.description
        if mode == "ranked" then label = label .. "\nRating: " .. data.rating .. " | RD: " .. data.ratingDeviation .. "\nTier: " .. data.rank end
        fs = fs .. "item_image_button[" .. x .. "," .. y .. ";1,1;" .. esc(kit.icon) .. ";" .. mode .. "_kit_" .. kit.id .. ";]"
        fs = fs .. button(x+1.2,y,2.9,1.0,mode .. "_kit_" .. kit.id,label)
        column, x = column + 1, x + 4
        if column >= 3 then column, x, y = 0, 0.5, y + 1.8 end
    end
    fs = fs .. button(0.5,8.8,2.5,0.7,"back","Back") .. button(9.1,8.8,2.5,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:kits:" .. mode, fs)
end

local function show_stats(name, target)
    target = target ~= "" and target or name
    local data = rating(target, "sword")
    local fs = "formspec_version[4]size[8,7]label[0.5,0.4;Statistics: " .. esc(target) .. "]"
    fs = fs .. "label[0.7,1.2;Rating: " .. data.rating .. "]label[0.7,1.7;RD: " .. data.ratingDeviation .. "]"
    fs = fs .. "label[0.7,2.2;Volatility: " .. data.volatility .. "]label[0.7,2.7;Tier: " .. esc(data.rank) .. "]"
    fs = fs .. button(0.5,5.8,2.5,0.7,"back","Back") .. button(5,5.8,2.5,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:stats", fs)
end

local function show_leaderboard(name)
    local ranked = rawget(_G, "pvp_ranked")
    local rows = ranked and ranked.getLeaderboard and ranked.getLeaderboard(10) or {}
    local text = ""
    for i, row in ipairs(rows) do text = text .. i .. ". " .. esc(row.name) .. " - " .. row.rating .. " (" .. esc(row.rank) .. ")" .. (i < #rows and "," or "") end
    if text == "" then text = "No rating data available" end
    local fs = "formspec_version[4]size[9,8]label[0.5,0.4;Leaderboard]textlist[0.5,1;8,5.5;rows;" .. text .. ";1;false]"
    fs = fs .. button(0.5,7,2.5,0.7,"back","Back") .. button(6.1,7,2.5,0.7,"close","Close")
    minetest.show_formspec(name, "pvp:leaderboard", fs)
end

local function register(name, params, description, callback, privs)
    minetest.register_chatcommand(name, {params=params or "", description=description, privs=privs or {}, func=callback})
end

register("play", nil, "Open the PvP menu", function(name) show_main(name); return true end)
register("stats", "[player]", "Open player statistics", function(name, param) show_stats(name, (param or ""):trim()); return true end)
register("rank", "[player]", "Show Glicko-2 information", function(name, param) show_stats(name, (param or ""):trim()); return true end)
register("leaderboard", nil, "Open the leaderboard", function(name) show_leaderboard(name); return true end)
register("kits", nil, "Open kit selection", function(name) show_kits(name, "unranked"); return true end)
register("party", nil, "Open the party interface", function(name) show_main(name); return true end)
register("duel", "[player]", "Open the duel interface", function(name, param) if (param or ""):trim() == "" then return false, "Usage: /duel <player>" end show_main(name); return true end)
register("spectate", nil, "Open the spectator interface", function(name) show_main(name); return true end)
register("pvpadmin", nil, "Open PvP administration", function(name) if not minetest.check_player_privs(name,{server=true}) then return false,"Server privilege required" end show_main(name); return true end, {server=true})
register("pvpdebug", nil, "Run PvP diagnostics", function(name) minetest.chat_send_player(name,"Queue: "..(queue.getQueueInfo and "ok" or "missing").." | Kits: "..(kits.list and "ok" or "missing")); return true end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "pvp:main" then
        if fields.ranked then show_kits(name,"ranked") elseif fields.unranked or fields.kits then show_kits(name,"unranked") elseif fields.stats then show_stats(name,name) elseif fields.leaderboard then show_leaderboard(name) elseif fields.close then minetest.close_formspec(name,formname) else minetest.chat_send_player(name,"Use the existing party, duel, or spectator module for that feature.") end
        return true
    end
    if formname == "pvp:stats" or formname == "pvp:leaderboard" then
        if fields.back then show_main(name) elseif fields.close then minetest.close_formspec(name,formname) end
        return true
    end
    local mode = formname:match("^pvp:kits:(ranked)$") or formname:match("^pvp:kits:(unranked)$")
    if mode then
        if fields.back then show_main(name) elseif fields.close then minetest.close_formspec(name,formname) else
            for key in pairs(fields) do
                local kit_id = key:match("^" .. mode .. "_kit_(.+)$")
                if kit_id then
                    local ok, message = mode == "ranked" and queue.joinRankedQueue(name,kit_id) or queue.joinUnrankedQueue(name,kit_id)
                    minetest.chat_send_player(name, message or (ok and "Queued" or "Queue failed"))
                    break
                end
            end
        end
        return true
    end
end)

minetest.register_on_leaveplayer(function(player) if queue.leaveQueue then pcall(queue.leaveQueue,player:get_player_name()) end end)
_G.pvp_commands = {show_main=show_main,show_kits=show_kits,show_stats=show_stats,show_leaderboard=show_leaderboard}

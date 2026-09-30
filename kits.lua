-- queue.lua
-- Minimal queue manager used by the PvP GUI and commands.
-- This is intentionally not a second queue implementation: it wraps the same queue concept
-- that the GUI uses for ranked and unranked selections.

local queue = {}
queue.queues = {
    ranked = {},
    unranked = {}
}
queue.players = {}

local function get_rating(player_name, kit_id)
    local ranked_mod = rawget(_G, "pvp_ranked")
    if ranked_mod and ranked_mod.getPlayerRating then
        local ok, result = pcall(ranked_mod.getPlayerRating, player_name, kit_id)
        if ok and result then return result end
    end
    return {rating = 1500, ratingDeviation = 350, rank = "Novice"}
end

local function in_match(player_name)
    local duel_mod = rawget(_G, "pvp_duels")
    if duel_mod and duel_mod.is_in_match then
        return duel_mod.is_in_match(player_name)
    end
    return false
end

local function queue_key(mode, kit_id)
    return mode .. ":" .. tostring(kit_id)
end

function queue.joinQueue(player_name, kit_id, mode)
    if not player_name or player_name == "" then
        return false, "Invalid player"
    end
    mode = mode or "unranked"
    kit_id = kit_id or "sword"
    if queue.players[player_name] then
        return false, "You are already queued for " .. queue.players[player_name].mode .. " / " .. queue.players[player_name].kit
    end
    if in_match(player_name) then
        return false, "You are already in a match"
    end
    if type(kit_id) ~= "string" or kit_id == "" then
        return false, "Invalid kit"
    end

    local entry = {
        player = player_name,
        kit = kit_id,
        mode = mode,
        rating = get_rating(player_name, kit_id)
    }

    table.insert(queue.queues[mode], entry)
    queue.players[player_name] = entry
    minetest.log("action", "[PvP-Ultimate] " .. player_name .. " joined " .. mode .. " queue for kit " .. kit_id)
    return true, "Queued for " .. mode .. " " .. kit_id
end

function queue.leaveQueue(player_name)
    local current = queue.players[player_name]
    if not current then
        return false, "You are not queued"
    end
    for i, entry in ipairs(queue.queues[current.mode]) do
        if entry.player == player_name then
            table.remove(queue.queues[current.mode], i)
            break
        end
    end
    queue.players[player_name] = nil
    return true, "Left the queue"
end

function queue.getQueueStatus(player_name)
    local entry = queue.players[player_name]
    if not entry then
        return nil
    end
    return {mode = entry.mode, kit = entry.kit, rating = entry.rating}
end

function queue.getQueueInfo(mode)
    local list = queue.queues[mode] or {}
    local result = {}
    for _, entry in ipairs(list) do
        result[#result + 1] = {
            player = entry.player,
            kit = entry.kit,
            rating = entry.rating
        }
    end
    return result
end

function queue.matchPlayers(mode)
    mode = mode or "ranked"
    local entries = queue.queues[mode]
    while #entries >= 2 do
        local a = table.remove(entries, 1)
        local b = table.remove(entries, 1)
        queue.players[a.player] = nil
        queue.players[b.player] = nil
        if rawget(_G, "pvp_duels") and pvp_duels.start then
            pcall(pvp_duels.start, a.player, b.player, a.kit, mode)
        else
            minetest.chat_send_player(a.player, "Match found against " .. b.player .. " in " .. mode .. " " .. a.kit)
            minetest.chat_send_player(b.player, "Match found against " .. a.player .. " in " .. mode .. " " .. b.kit)
        end
    end
end

function queue.joinRankedQueue(player_name, kit_id)
    return queue.joinQueue(player_name, kit_id, "ranked")
end

function queue.joinUnrankedQueue(player_name, kit_id)
    return queue.joinQueue(player_name, kit_id, "unranked")
end

function queue.getModeCounts()
    local out = {}
    for _, mode in ipairs({"ranked", "unranked"}) do
        out[mode] = #queue.queues[mode]
    end
    return out
end

_G.pvp_queue = queue
return queue

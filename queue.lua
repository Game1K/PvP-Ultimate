-- queue.lua
-- Shared ranked/unranked queue manager used by the PvP GUI.

local queue = {
    queues = {ranked = {}, unranked = {}},
    players = {}
}

local function rating_for(name, kit_id)
    local ranked = rawget(_G, "pvp_ranked")
    if ranked and ranked.getPlayerRating then
        local ok, result = pcall(ranked.getPlayerRating, name, kit_id)
        if ok and result then return result end
    end
    return {rating = 1500, ratingDeviation = 350, rank = "Novice"}
end

local function in_match(name)
    local duels = rawget(_G, "pvp_duels")
    return duels and duels.is_in_match and duels.is_in_match(name) or false
end

function queue.joinQueue(name, kit_id, mode)
    mode = mode or "unranked"
    if mode ~= "ranked" and mode ~= "unranked" then return false, "Invalid queue mode" end
    if not name or name == "" then return false, "Invalid player" end
    if queue.players[name] then
        local current = queue.players[name]
        return false, "Already queued for " .. current.mode .. " / " .. current.kit
    end
    if in_match(name) then return false, "You are already in a match" end
    if type(kit_id) ~= "string" or kit_id == "" then return false, "Invalid kit" end

    local entry = {player = name, kit = kit_id, mode = mode, rating = rating_for(name, kit_id)}
    queue.queues[mode][#queue.queues[mode] + 1] = entry
    queue.players[name] = entry
    minetest.log("action", "[PvP-Ultimate] " .. name .. " joined " .. mode .. " queue for " .. kit_id)
    return true, "Queued for " .. mode .. " " .. kit_id
end

function queue.joinRankedQueue(name, kit_id)
    return queue.joinQueue(name, kit_id, "ranked")
end

function queue.joinUnrankedQueue(name, kit_id)
    return queue.joinQueue(name, kit_id, "unranked")
end

function queue.leaveQueue(name)
    local entry = queue.players[name]
    if not entry then return false, "You are not queued" end
    for index, candidate in ipairs(queue.queues[entry.mode]) do
        if candidate.player == name then
            table.remove(queue.queues[entry.mode], index)
            break
        end
    end
    queue.players[name] = nil
    return true, "Left the queue"
end

function queue.getQueueStatus(name)
    local entry = queue.players[name]
    if not entry then return nil end
    return {mode = entry.mode, kit = entry.kit, rating = entry.rating}
end

function queue.getQueueInfo(mode)
    local result = {}
    for _, entry in ipairs(queue.queues[mode] or {}) do
        result[#result + 1] = {player = entry.player, kit = entry.kit, rating = entry.rating}
    end
    return result
end

function queue.getModeCounts()
    return {ranked = #queue.queues.ranked, unranked = #queue.queues.unranked}
end

function queue.matchPlayers(mode)
    mode = mode or "ranked"
    local list = queue.queues[mode] or {}
    while #list >= 2 do
        local first, second = table.remove(list, 1), table.remove(list, 1)
        queue.players[first.player], queue.players[second.player] = nil, nil
        local duels = rawget(_G, "pvp_duels")
        if duels and duels.start then
            pcall(duels.start, first.player, second.player, first.kit, mode)
        else
            minetest.chat_send_player(first.player, "Match found against " .. second.player)
            minetest.chat_send_player(second.player, "Match found against " .. first.player)
        end
    end
end

_G.pvp_queue = queue
return queue

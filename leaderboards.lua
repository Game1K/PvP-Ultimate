-- leaderboards.lua

local leaderboard = {}

-- Function to add a player to the leaderboard
function addPlayer(kit, playerName, score)
    if not leaderboard[kit] then
        leaderboard[kit] = {}
    end
    leaderboard[kit][playerName] = score
end

-- Function to get the player rankings for a specific kit
function getRankings(kit)
    if not leaderboard[kit] then return nil end
    local rankings = {}
    for playerName, score in pairs(leaderboard[kit]) do
        table.insert(rankings, {name = playerName, score = score})
    end
    table.sort(rankings, function(a, b) return a.score > b.score end)
    return rankings
end

-- Function to post rankings to Discord
function postToDiscord(kit)
    local rankings = getRankings(kit)
    if rankings == nil then return end
    local message = "Leaderboards for kit: " .. kit .. '\n' 
    for i, player in ipairs(rankings) do
        message = message .. i .. ". " .. player.name .. ': ' .. player.score .. '\n'
    end
    -- Assuming we have a function sendToDiscord that handles Discord API requests
    sendToDiscord(message)
end

-- GitHub API integration can be added here, e.g., log score updates
function logToGitHub(playerName, kit, score)
    -- Logic to interact with GitHub API for logging purposes goes here
end

return { addPlayer = addPlayer, getRankings = getRankings, postToDiscord = postToDiscord, logToGitHub = logToGitHub }
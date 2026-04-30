local HttpService = game:GetService("HttpService")

local webhookUrl = "YOUR_DISCORD_WEBHOOK_URL"  -- Replace with your actual Discord webhook URL

local function sendToDiscord(message)
    local data = {
        content = message,
    }
    
    local jsonData = HttpService:JSONEncode(data)
    
    local response = HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    return response
end

local function getPlayerStats(playerId)
    -- Example function to fetch player stats
    -- Replace with your own logic to retrieve player ranks and statistics
    local playerStats = {
        playerId = playerId,
        rank = "Gold",
        stats = {
            wins = 10,
            losses = 5,
            kills = 50,
        }
    }

    return playerStats
end

local function onPlayerRequest(playerId)
    local stats = getPlayerStats(playerId)
    local message = "Player ID: " .. stats.playerId .. "\nRank: " .. stats.rank .. "\nWins: " .. stats.stats.wins .. "\nLosses: " .. stats.stats.losses .. "\nKills: " .. stats.stats.kills
    local response = sendToDiscord(message)
    
    return response
end

-- Example usage
-- onPlayerRequest("12345") -- Uncomment to test with a specific player

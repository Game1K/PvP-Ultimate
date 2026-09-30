-- ranked.lua
-- Ranked system using Glicko-2 rating system

local glicko2 = require("glicko2")

-- Player data storage
local players = {}
local rankThresholds = {
    ["Grandmaster"] = 2000,
    ["Master"] = 1800,
    ["Expert"] = 1600,
    ["Advanced"] = 1400,
    ["Intermediate"] = 1200,
    ["Novice"] = 0
}

-- Function to set configurable rank thresholds
function setRankThresholds(thresholds)
    rankThresholds = thresholds
end

-- Function to get rank from rating
function getRankFromRating(rating)
    for rank, threshold in pairs(rankThresholds) do
        if rating >= threshold then
            return rank
        end
    end
    return "Novice"
end

-- Initialize or get a player's rating data
function initializePlayer(playerName, existingData)
    if players[playerName] then
        return players[playerName]
    end
    
    if existingData then
        players[playerName] = glicko2.createPlayer(
            existingData.rating,
            existingData.ratingDeviation,
            existingData.volatility
        )
    else
        players[playerName] = glicko2.createPlayer()
    end
    
    players[playerName].name = playerName
    players[playerName].rank = getRankFromRating(players[playerName].rating)
    
    return players[playerName]
end

-- Register a match result
function registerMatchResult(player1Name, player2Name, result)
    -- result: 1 = player1 wins, 0 = player2 wins, 0.5 = draw
    
    local player1 = initializePlayer(player1Name)
    local player2 = initializePlayer(player2Name)
    
    -- Prepare outcomes for player1
    local player1Outcomes = {{
        score = result,
        opponentRating = player2.rating,
        opponentRD = player2.ratingDeviation,
        opponentVolatility = player2.volatility
    }}
    
    -- Prepare outcomes for player2
    local player2Outcomes = {{
        score = 1 - result,  -- Opposite result for player2
        opponentRating = player1.rating,
        opponentRD = player1.ratingDeviation,
        opponentVolatility = player1.volatility
    }}
    
    -- Update ratings
    glicko2.updateRating(player1, player1Outcomes)
    glicko2.updateRating(player2, player2Outcomes)
    
    -- Update ranks based on new ratings
    updatePlayerRank(player1)
    updatePlayerRank(player2)
    
    return {
        player1 = player1,
        player2 = player2
    }
end

-- Update player rank based on current rating
function updatePlayerRank(player)
    player.rank = getRankFromRating(player.rating)
end

-- Update a player's rating (new function to replace old updateRank)
function updateRating(playerName, newRating)
    local player = initializePlayer(playerName)
    player.rating = newRating
    updatePlayerRank(player)
    return player
end

-- Get player's current rating info
function getPlayerRating(playerName)
    local player = initializePlayer(playerName)
    return {
        name = player.name,
        rating = math.floor(player.rating),
        ratingDeviation = math.floor(player.ratingDeviation),
        volatility = math.floor(player.volatility * 10000) / 10000,
        rank = player.rank,
        uncertainty = glicko2.getRatingUncertainty(player)
    }
end

-- Get all players' ratings
function getAllPlayersRatings()
    local results = {}
    for playerName, player in pairs(players) do
        table.insert(results, getPlayerRating(playerName))
    end
    
    -- Sort by rating (descending)
    table.sort(results, function(a, b) return a.rating > b.rating end)
    
    return results
end

-- Update inactivity for a player (increase RD over time)
function updatePlayerInactivity(playerName, daysSinceLastMatch)
    local player = initializePlayer(playerName)
    glicko2.updateRDOverTime(player, daysSinceLastMatch)
    return player
end

-- Get expected score between two players
function getExpectedScore(player1Name, player2Name)
    local player1 = initializePlayer(player1Name)
    local player2 = initializePlayer(player2Name)
    
    return glicko2.expectedScore(
        player1.rating, player1.ratingDeviation,
        player2.rating, player2.ratingDeviation
    )
end

-- Reset a player's rating to default
function resetPlayerRating(playerName)
    players[playerName] = glicko2.createPlayer()
    players[playerName].name = playerName
    players[playerName].rank = "Novice"
    return players[playerName]
end

-- Get rating band description
function getRatingBand(playerName)
    local player = initializePlayer(playerName)
    return glicko2.getRatingBand(player.rating)
end

-- Export leaderboard data
function getLeaderboard(limit)
    limit = limit or 10
    local ratings = getAllPlayersRatings()
    local leaderboard = {}
    
    for i = 1, math.min(limit, #ratings) do
        table.insert(leaderboard, {
            position = i,
            name = ratings[i].name,
            rating = ratings[i].rating,
            rank = ratings[i].rank,
            uncertainty = ratings[i].uncertainty
        })
    end
    
    return leaderboard
end

return {
    setRankThresholds = setRankThresholds,
    getRankFromRating = getRankFromRating,
    initializePlayer = initializePlayer,
    registerMatchResult = registerMatchResult,
    updatePlayerRank = updatePlayerRank,
    updateRating = updateRating,
    getPlayerRating = getPlayerRating,
    getAllPlayersRatings = getAllPlayersRatings,
    updatePlayerInactivity = updatePlayerInactivity,
    getExpectedScore = getExpectedScore,
    resetPlayerRating = resetPlayerRating,
    getRatingBand = getRatingBand,
    getLeaderboard = getLeaderboard
}

-- Function to set configurable rank thresholds
function setRankThresholds(thresholds)
    -- Store thresholds in a table
    rankThresholds = thresholds
end

-- Function to get rank from ELO
function getRankFromElo(elo)
    for rank, threshold in pairs(rankThresholds) do
        if elo >= threshold then
            return rank
        end
    end
    return nil -- Return nil if no rank matches
end

-- New updateRank function
function updateRank(player, newElo)
    local newRank = getRankFromElo(newElo)
    if newRank then
        player.rank = newRank
        player.elo = newElo
        -- Additional logic for updating the player's rank in the database
    end
end
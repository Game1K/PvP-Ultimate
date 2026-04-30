-- ranked.lua

local RankedSystem = {}

-- Elo rating system parameters
RankedSystem.kFactor = 32

-- Player ranks
RankedSystem.ranks = {
    "Bronze",
    "Silver",
    "Gold",
    "Platinum",
    "Diamond",
    "Champion"
}

-- Player data storage
RankedSystem.players = {}

-- Function to create a new player with initial elo and rank
function RankedSystem:newPlayer(playerId)
    self.players[playerId] = {
        elo = 1000,
        rank = self.ranks[1],
        bans = {},
    }
end

-- Function to update elo and rank based on match result
function RankedSystem:updatePlayer(playerId, points, opponentElo)
    local player = self.players[playerId]
    if player then
        local expectedScore = 1 / (1 + 10 ^ ((opponentElo - player.elo) / 400))
        player.elo = player.elo + self.kFactor * (points - expectedScore)
        self:updateRank(playerId)
    end
end

-- Function to update rank based on elo
function RankedSystem:updateRank(playerId)
    local player = self.players[playerId]
    local rankIndex = math.floor((player.elo - 1000) / 200)
    if rankIndex < 1 then rankIndex = 1 end
    if rankIndex > #self.ranks then rankIndex = #self.ranks end
    player.rank = self.ranks[rankIndex]
end

-- Function to ban a player from ranked for a specific period
function RankedSystem:banPlayer(playerId, duration)
    local player = self.players[playerId]
    if player then
        table.insert(player.bans, {time = os.time(), duration = duration})
    end
end

-- Function to reset player data
function RankedSystem:resetPlayer(playerId)
    self.players[playerId] = nil
end

-- Function to get current rank of a player
function RankedSystem:getPlayerRank(playerId)
    local player = self.players[playerId]
    return player and player.rank or nil
end

return RankedSystem

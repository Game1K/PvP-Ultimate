-- glicko2.lua
-- Glicko-2 rating system implementation for PvP-Ultimate
-- https://www.glicko.net/glicko/glicko2.pdf

local glicko2 = {}

-- Glicko-2 system constants
local VOLATILITY_CHANGE = 0.5  -- Controls the dynamics of volatility over time
local TAU = 0.5                -- Controls the rate at which ratings change
local CONVERGENCE_TOLERANCE = 1e-6

-- Rating scale conversion constants (Glicko to Glicko-2 and vice versa)
local RATING_SCALE = 173.7178

-- Initialize player data structure
function glicko2.createPlayer(rating, ratingDeviation, volatility)
    return {
        rating = rating or 1500,           -- Rating (µ)
        ratingDeviation = ratingDeviation or 350,  -- Rating Deviation (φ)
        volatility = volatility or 0.06,   -- Volatility (σ)
        lastUpdate = os.time()
    }
end

-- Convert Glicko rating to Glicko-2 rating
function glicko2.convertToGlicko2(rating)
    return (rating - 1500) / RATING_SCALE
end

-- Convert Glicko-2 rating back to Glicko rating
function glicko2.convertFromGlicko2(rating)
    return rating * RATING_SCALE + 1500
end

-- Convert Glicko RD to Glicko-2 RD
function glicko2.convertRDToGlicko2(rd)
    return rd / RATING_SCALE
end

-- Convert Glicko-2 RD back to Glicko RD
function glicko2.convertRDFromGlicko2(rd)
    return rd * RATING_SCALE
end

-- Ensure RD doesn't get too small or too large
function glicko2.constrainRD(rd)
    if rd < 30 then
        return 30
    elseif rd > 350 then
        return 350
    end
    return rd
end

-- Expected score calculation for player1 vs player2
function glicko2.expectedScore(player1Rating, player1RD, player2Rating, player2RD)
    local mu1 = glicko2.convertToGlicko2(player1Rating)
    local phi1 = glicko2.convertRDToGlicko2(player1RD)
    
    local mu2 = glicko2.convertToGlicko2(player2Rating)
    local phi2 = glicko2.convertRDToGlicko2(player2RD)
    
    local g = 1 / math.sqrt(1 + 3 * math.pi * phi2 * phi2 / (math.pi * math.pi))
    local e = 1 / (1 + math.exp(-g * (mu1 - mu2)))
    
    return e
end

-- Calculate the new volatility using iterative algorithm
function glicko2.calculateNewVolatility(mu, phi, sigma, outcomes)
    if #outcomes == 0 then
        return sigma
    end
    
    local a = math.log(sigma * sigma)
    local delta = glicko2.calculateDelta(mu, phi, outcomes)
    local v = glicko2.calculateV(mu, phi, outcomes)
    
    -- Iterative algorithm to find new volatility
    local A = a
    local B = nil
    
    if delta * delta > phi * phi + v then
        B = math.log(delta * delta - phi * phi - v)
    else
        B = a - 2 * TAU
    end
    
    local fA = glicko2.f(A, delta, phi, v, sigma)
    local fB = glicko2.f(B, delta, phi, v, sigma)
    
    while math.abs(B - A) > CONVERGENCE_TOLERANCE do
        local C = A + (A - B) * fA / (fB - fA)
        local fC = glicko2.f(C, delta, phi, v, sigma)
        
        if fC * fB < 0 then
            A = B
            fA = fB
        else
            fA = fA / 2
        end
        
        B = C
        fB = fC
    end
    
    return math.exp(A / 2)
end

-- Helper function for volatility calculation
function glicko2.f(x, delta, phi, v, sigma)
    local sigma_new = math.exp(x / 2)
    return (sigma_new * sigma_new - (sigma * sigma + v) * math.exp(x)) / 
           ((sigma * sigma + v + delta * delta) * math.exp(x)) - 
           (x - math.log(sigma * sigma)) / (TAU * TAU)
end

-- Calculate rating deviation change
function glicko2.calculatePhiStar(phi)
    return math.sqrt(phi * phi + VOLATILITY_CHANGE * VOLATILITY_CHANGE)
end

-- Calculate delta (rating difference strength)
function glicko2.calculateDelta(mu, phi, outcomes)
    local v = glicko2.calculateV(mu, phi, outcomes)
    local delta = 0
    
    for _, outcome in ipairs(outcomes) do
        local g = 1 / math.sqrt(1 + 3 * math.pi * outcome.opponentPhi * outcome.opponentPhi / (math.pi * math.pi))
        delta = delta + g * (outcome.score - outcome.expectedScore)
    end
    
    delta = delta * v
    return delta
end

-- Calculate v
function glicko2.calculateV(mu, phi, outcomes)
    local v = 0
    
    for _, outcome in ipairs(outcomes) do
        local g = 1 / math.sqrt(1 + 3 * math.pi * outcome.opponentPhi * outcome.opponentPhi / (math.pi * math.pi))
        local e = outcome.expectedScore
        v = v + (g * g * e * (1 - e))
    end
    
    return v ~= 0 and (1 / v) or 0
end

-- Update player rating after a match
-- outcomes is a table of {score (0/0.5/1), opponentRating, opponentRD, opponentVolatility}
function glicko2.updateRating(player, outcomes)
    local mu = glicko2.convertToGlicko2(player.rating)
    local phi = glicko2.convertRDToGlicko2(player.ratingDeviation)
    local sigma = player.volatility
    
    -- Prepare outcome data with Glicko-2 values
    local processedOutcomes = {}
    for _, outcome in ipairs(outcomes) do
        local opponentMu = glicko2.convertToGlicko2(outcome.opponentRating)
        local opponentPhi = glicko2.convertRDToGlicko2(outcome.opponentRD)
        local expectedScore = glicko2.expectedScore(player.rating, player.ratingDeviation,
                                                     outcome.opponentRating, outcome.opponentRD)
        
        table.insert(processedOutcomes, {
            score = outcome.score,
            opponentMu = opponentMu,
            opponentPhi = opponentPhi,
            opponentRating = outcome.opponentRating,
            opponentRD = outcome.opponentRD,
            expectedScore = expectedScore
        })
    end
    
    -- Calculate new volatility
    local newSigma = glicko2.calculateNewVolatility(mu, phi, sigma, processedOutcomes)
    
    -- Calculate rating deviation multiplier (phi star)
    local phiStar = glicko2.calculatePhiStar(phi)
    
    -- Calculate delta
    local delta = glicko2.calculateDelta(mu, phi, processedOutcomes)
    
    -- Calculate v
    local v = glicko2.calculateV(mu, phi, processedOutcomes)
    
    -- Calculate new rating
    local newMu = mu
    if v > 0 then
        newMu = mu + (newSigma * newSigma) / phiStar * glicko2.sumOutcomes(mu, newSigma, processedOutcomes)
    end
    
    -- Calculate new RD
    local newPhi = 1 / math.sqrt(1 / (phiStar * phiStar) + 1 / v)
    
    -- Convert back to Glicko scale
    player.rating = glicko2.convertFromGlicko2(newMu)
    player.ratingDeviation = glicko2.constrainRD(glicko2.convertRDFromGlicko2(newPhi))
    player.volatility = newSigma
    player.lastUpdate = os.time()
    
    return player
end

-- Sum of outcome contributions
function glicko2.sumOutcomes(mu, sigma, outcomes)
    local sum = 0
    
    for _, outcome in ipairs(outcomes) do
        local g = 1 / math.sqrt(1 + 3 * math.pi * outcome.opponentPhi * outcome.opponentPhi / (math.pi * math.pi))
        sum = sum + g * (outcome.score - outcome.expectedScore)
    end
    
    return sum
end

-- Calculate RD increase over time (inactivity)
function glicko2.updateRDOverTime(player, daysSinceUpdate)
    local currentRD = player.ratingDeviation
    local phi = glicko2.convertRDToGlicko2(currentRD)
    local sigma = player.volatility
    
    -- Increase RD based on inactivity
    local newPhi = math.sqrt(phi * phi + VOLATILITY_CHANGE * VOLATILITY_CHANGE * daysSinceUpdate)
    
    player.ratingDeviation = glicko2.constrainRD(glicko2.convertRDFromGlicko2(newPhi))
    return player
end

-- Get player's uncertainty in rating
function glicko2.getRatingUncertainty(player)
    return player.ratingDeviation
end

-- Get player's volatility
function glicko2.getVolatility(player)
    return player.volatility
end

-- Simple rating band for display
function glicko2.getRatingBand(rating)
    if rating < 1200 then
        return "Novice"
    elseif rating < 1400 then
        return "Intermediate"
    elseif rating < 1600 then
        return "Advanced"
    elseif rating < 1800 then
        return "Expert"
    elseif rating < 2000 then
        return "Master"
    else
        return "Grandmaster"
    end
end

return glicko2

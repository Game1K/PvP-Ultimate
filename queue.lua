local queue = {}

-- Function to join the queue
function joinQueue(player)
    table.insert(queue, player)
    print(player .. " has joined the queue.")
    matchPlayers()
end

-- Function to match players for duels
function matchPlayers()
    while #queue >= 2 do
        local player1 = table.remove(queue, 1)
        local player2 = table.remove(queue, 1)
        initiateDuel(player1, player2)
    end
end

-- Function to initiate a duel
function initiateDuel(player1, player2)
    print("Duel started between " .. player1 .. " and " .. player2)
    -- Add duel logic here
end

-- Function to check the queue status
function checkQueueStatus()
    if #queue == 0 then
        print("The queue is empty.")
    else
        print("Current queue: ")
        for i, player in ipairs(queue) do
            print(i .. ". " .. player)
        end
    end
end

-- Example usage
-- joinQueue("Player1")
-- joinQueue("Player2")
-- joinQueue("Player3")

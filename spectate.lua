-- spectate.lua
-- Spectator system for PvP-Ultimate

local spectate = {}

local spectators = {}
local spectator_data = {}

-- ============ SPECTATOR MANAGEMENT ============

function spectate.start_spectating(player_name, match_type)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    
    -- Store original properties
    local props = player:get_properties()
    spectator_data[player_name] = {
        original_collide_with_objects = props.collide_with_objects,
        original_pointable = props.pointable,
    }
    
    -- Make spectator invisible and invulnerable
    player:set_properties({
        collide_with_objects = false,
        pointable = false,
    })
    
    player:set_nametag_attributes({
        color = {a = 100, r = 100, g = 100, b = 100},
        text = player_name .. " (Spectating)",
    })
    
    spectators[player_name] = {
        started_at = os.time(),
        match_type = match_type or "1v1",
    }
    
    minetest.chat_send_player(player_name, "👁️ You are now spectating! You cannot be damaged or damage others.")
    return true
end

function spectate.stop_spectating(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    
    local data = spectator_data[player_name]
    if data then
        -- Restore original properties
        player:set_properties({
            collide_with_objects = data.original_collide_with_objects,
            pointable = data.original_pointable,
        })
        spectator_data[player_name] = nil
    end
    
    player:set_nametag_attributes({
        color = {a = 255, r = 255, g = 255, b = 255},
        text = player_name,
    })
    
    spectators[player_name] = nil
    minetest.chat_send_player(player_name, "👁️ Stopped spectating!")
    return true
end

function spectate.is_spectating(player_name)
    return spectators[player_name] ~= nil
end

function spectate.get_spectator_count()
    local count = 0
    for _, _ in pairs(spectators) do
        count = count + 1
    end
    return count
end

-- ============ DAMAGE PREVENTION ============

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local player_name = player:get_player_name()
    
    -- Prevent damage to spectators
    if spectate.is_spectating(player_name) then
        return 0
    end
    
    return hp_change
end, true)

-- ============ PUNCH PREVENTION ============

minetest.register_on_player_punch(function(player, hitter, time_from_last_punch, tool_capabilities, dir)
    local hitter_name = hitter:get_player_name()
    local player_name = player:get_player_name()
    
    -- Spectators cannot punch others
    if spectate.is_spectating(hitter_name) then
        return true -- Cancel punch
    end
    
    -- Others cannot punch spectators
    if spectate.is_spectating(player_name) then
        return true -- Cancel punch
    end
    
    return false
end)

-- ============ ARENA CONFINEMENT ============

local function is_in_arena(player)
    -- This would integrate with your arena system
    -- For now, just a placeholder
    return true
end

minetest.register_globalstep(function(dtime)
    for player_name, spec_data in pairs(spectators) do
        local player = minetest.get_player_by_name(player_name)
        if player then
            -- Keep spectator in arena
            if not is_in_arena(player) then
                -- Could teleport back to arena or kick from spectating
            end
        end
    end
end)

-- ============ CLEANUP ============

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    spectators[player_name] = nil
    spectator_data[player_name] = nil
end)

minetest.register_on_player_death(function(player, reason)
    local player_name = player:get_player_name()
    if spectate.is_spectating(player_name) then
        spectate.stop_spectating(player_name)
    end
    return false
end)

-- ============ MODULE EXPORT ============

return {
    start_spectating = function(player_name, match_type) return spectate.start_spectating(player_name, match_type) end,
    stop_spectating = function(player_name) return spectate.stop_spectating(player_name) end,
    is_spectating = function(player_name) return spectate.is_spectating(player_name) end,
    get_spectator_count = function() return spectate.get_spectator_count() end,
}

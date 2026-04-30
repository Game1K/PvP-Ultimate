local ArenaManager = {}

-- Table to hold active arenas
ArenaManager.arenas = {}

-- Function to create a new arena
function ArenaManager:createArena(name, x, z)
    if self:reuseDetection(name) then
        return false, "Arena already exists!"
    end
    
    -- Setting spawn point above y=20000
    local y = 20001
    self.arenas[name] = {x = x, y = y, z = z}
    return true, "Arena created successfully!"
end

-- Function to check for arena reuse
function ArenaManager:reuseDetection(name)
    return self.arenas[name] ~= nil
end

-- Function to get the location of an arena
function ArenaManager:getArena(name)
    return self.arenas[name]
end

-- Function to list all active arenas
function ArenaManager:listArenas()
    return self.arenas
end

return ArenaManager
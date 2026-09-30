-- init.lua
-- PvP-Ultimate module loader.

local modpath = minetest.get_modpath(minetest.get_current_modname())

local function load_module(filename)
    local ok, err = pcall(dofile, modpath .. "/" .. filename)
    if not ok then
        minetest.log("error", "[PvP-Ultimate] Failed to load " .. filename .. ": " .. tostring(err))
    end
    return ok
end

-- Load dependencies before the command/UI layer.
load_module("glicko2.lua")
load_module("pvp_kits.lua")
load_module("arenas.lua")
load_module("queue.lua")
load_module("ranked.lua")
load_module("duels.lua")
load_module("spectate.lua")
load_module("pvp_commands.lua")

minetest.log("action", "[PvP-Ultimate] loaded")

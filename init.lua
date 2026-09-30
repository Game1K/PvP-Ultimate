-- init.lua
-- PvP-Ultimate entry point.
-- Load modules in dependency order; player-facing commands are registered once below.

local modpath = minetest.get_modpath(minetest.get_current_modname())
local function load(name)
    local ok, err = pcall(dofile, modpath .. "/" .. name)
    if not ok then
        minetest.log("error", "[PvP-Ultimate] Failed to load " .. name .. ": " .. tostring(err))
    end
    return ok
end

load("glicko2.lua")
load("pvp_kits.lua")
load("arenas.lua")
load("queue.lua")
load("ranked.lua")
load("duels.lua")
load("spectate.lua")
load("pvp_commands.lua")

minetest.log("action", "[PvP-Ultimate] loaded")

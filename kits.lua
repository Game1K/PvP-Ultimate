-- kits.lua
-- Compatibility API for the data-driven kit registry.
-- Player-facing kit commands were removed; use /kits or /play.

local registry = rawget(_G, "pvp_kits") or {}

local api = {
    list = function(mode)
        return registry.list and registry.list(mode) or {}
    end,
    get = function(id)
        return registry.get and registry.get(id) or nil
    end,
    register = function(definition)
        return registry.register and registry.register(definition) or nil
    end,
    apply = function(player, id)
        if registry.apply then return registry.apply(player, id) end
        return false, "Kit system unavailable"
    end,
}

_G.pvp_kit_api = api
return api

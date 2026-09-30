-- kits.lua
-- Compatibility layer: the system uses data-driven kit registration and the GUI consumes it.
-- This file intentionally does not register old conflicting player commands.

local registry = rawget(_G, "pvp_kits") or {}

local function has_table(value)
    return type(value) == "table"
end

local exports = {
    list = function(mode)
        if registry and registry.list then
            return registry.list(mode)
        end
        return {}
    end,
    get = function(id)
        if registry and registry.get then
            return registry.get(id)
        end
        return nil
    end,
    register = function(def)
        if registry and registry.register then
            return registry.register(def)
        end
        return nil
    end,
    apply = function(player, id)
        if registry and registry.apply then
            return registry.apply(player, id)
        end
        return false, "Kit system unavailable"
    end,
}

_G.pvp_kit_api = exports
return exports

-- pvp_kits.lua
-- Data-driven kit registry. Queue and GUI code consume this API instead of hardcoding kits.

local kit_registry = { kits = {} }

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

function kit_registry.register(def)
    assert(type(def) == "table" and def.id, "kit id is required")
    local kit = copy(def)
    kit.name = kit.name or kit.id
    kit.description = kit.description or "No description"
    kit.icon = kit.icon or "default_steel_sword.png"
    kit.enabled = kit.enabled ~= false
    kit.ranked_enabled = kit.ranked_enabled ~= false
    kit.unranked_enabled = kit.unranked_enabled ~= false
    kit_registry.kits[kit.id] = kit
    return kit
end

function kit_registry.get(id)
    return kit_registry.kits[id]
end

function kit_registry.list(mode)
    local result = {}
    for _, kit in pairs(kit_registry.kits) do
        if kit.enabled and (not mode or kit[mode .. "_enabled"] ~= false) then
            result[#result + 1] = kit
        end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

function kit_registry.apply(player, id)
    local kit = kit_registry.get(id)
    if not kit or not kit.items then return false, "Kit is not configured" end
    local inv = player:get_inventory()
    inv:set_list("main", {})
    for slot, item in pairs(kit.items) do
        inv:set_stack("main", tonumber(slot), ItemStack(item))
    end
    return true
end

-- Defaults preserve the kits that the original GUI advertised. Servers can register more.
kit_registry.register({id="sword", name="Sword", description="Classic sword combat", icon="default:steel_sword"})
kit_registry.register({id="crystal", name="Crystal", description="Close-range crystal combat", icon="default:diamond"})
kit_registry.register({id="bow", name="Bow", description="Long-range archery", icon="default:bow", ranked_enabled=false})

_G.pvp_kits = kit_registry
return kit_registry

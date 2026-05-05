-- kits.lua

local kits = {}

-- =========================
-- SAVE KIT FROM INVENTORY
-- =========================
minetest.register_chatcommand("kitsave", {
    params = "<kitname>",
    privs = {server = true},
    description = "Save your current inventory as a kit",
    
    func = function(name, param)
        if param == "" then
            return false, "Usage: /kitsave <kitname>"
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local inv = player:get_inventory()
        local list = inv:get_list("main")

        local kit = {}

        for i = 1, #list do
            local stack = list[i]
            if not stack:is_empty() then
                kit[i] = stack:to_string()
            end
        end

        kits[param] = kit

        return true, "Kit '" .. param .. "' saved from your inventory!"
    end
})

-- =========================
-- GIVE KIT TO PLAYER
-- =========================
minetest.register_chatcommand("kit", {
    params = "<kitname>",
    privs = {},
    description = "Receive a saved kit",

    func = function(name, param)
        if param == "" then
            return false, "Usage: /kit <kitname>"
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local inv = player:get_inventory()
        local kit = kits[param]

        if not kit then
            return false, "Kit not found: " .. param
        end

        inv:set_list("main", {}) -- clear inventory

        for slot, itemstring in pairs(kit) do
            inv:set_stack("main", slot, ItemStack(itemstring))
        end

        return true, "You received kit: " .. param
    end
})

-- =========================
-- LIST KITS
-- =========================
minetest.register_chatcommand("kitlist", {
    description = "List saved kits",
    privs = {},

    func = function(name)
        local msg = "Available kits:\n"
        for k, _ in pairs(kits) do
            msg = msg .. "- " .. k .. "\n"
        end

        return true, msg
    end
})

-- =========================
-- OPTIONAL: ADD HELD ITEM TO KIT SLOT
-- =========================
minetest.register_chatcommand("kitaddheld", {
    params = "<kitname>",
    privs = {server = true},
    description = "Add held item to a kit (simple builder)",

    func = function(name, param)
        if param == "" then
            return false, "Usage: /kitaddheld <kitname>"
        end

        local player = minetest.get_player_by_name(name)
        if not player then return false end

        local item = player:get_wielded_item()
        if item:is_empty() then
            return false, "You're not holding anything"
        end

        kits[param] = kits[param] or {}
        table.insert(kits[param], item:to_string())

        return true, "Added " .. item:get_name() .. " to kit " .. param
    end
})

-- init.lua for the PvP-Ultimate mod

-- Basic initialization
local mod_name = "PvP-Ultimate"
local submodules = {
    "submodule1",
    "submodule2",
    "submodule3",
}

-- Require submodules
for _, submodule in ipairs(submodules) do
    require(mod_name .. "." .. submodule)
end

-- Additional initialization code can go here

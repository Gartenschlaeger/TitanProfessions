---@class TitanPanel_ProfessionsCore
local _, core = ...

---@class TitanPanel_ProfessionsHelper
local helper = {}
core.helper = helper

function helper:tableSize(t)
    local size = 0
    for _ in pairs(t) do
        size = size + 1
    end

    return size
end

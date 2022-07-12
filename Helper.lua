---@class TitanPanel_ProfessionsCore
local _, core = ...

local helper = {}
core.helper = helper

function helper:tableSize(t)
    local size = 0
    for _ in pairs(t) do
        size = size + 1
    end

    return size
end

function helper:buildPrimaryProfessionsText(playerInfo, separator, defaultText)
    local prof1 = playerInfo.professions.prof1
    local prof2 = playerInfo.professions.prof2
    if (prof1 or prof2) then
        local result = ''
        if (prof1) then
            result = result .. ProfessionsDB[prof1].name
            if (prof2) then
                result = result .. separator
            end
        end

        if (prof2) then
            result = result .. ProfessionsDB[prof2].name
        end

        return result
    else
        return defaultText
    end
end

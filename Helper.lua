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

function helper:getKeysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    return keys
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

---Joins table values by the given separator
---@param table table
---@param separator string
---@return string
function helper:joinTableValues(table, separator)
    local result = ''

    for _, v in pairs(table) do
        result = strconcat(result, v, separator)
    end

    if (strlen(result) > 0) then
        result = result:sub(1, -(1 + strlen(separator)))
    end

    return result
end

function helper:addButton(text, valueKey, checkCallback)
    local info = {}
    info.text = text;
    info.checked = TitanGetVar(TITAN_PROFESSIONS_ID, valueKey);
    info.func = checkCallback

    TitanPanelRightClickMenu_AddButton(info, TitanPanelRightClickMenu_GetDropdownLevel());
end

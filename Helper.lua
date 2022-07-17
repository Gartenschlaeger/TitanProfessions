---@class TitanPanel_ProfessionsCore
local _, core = ...

---@class TitanPanel_ProfessionsHelper
local helper = {}
core.helper = helper

function helper.tableSize(self, t)
    local size = 0
    for _ in pairs(t) do
        size = size + 1
    end

    return size
end

function helper.getKeysSortedByValue(self, tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    return keys
end

function helper.buildPrimaryProfessionsText(self, playerInfo, separator, defaultText)
    local prof1 = playerInfo.professions.prof1
    local prof2 = playerInfo.professions.prof2
    if (prof1 or prof2) then
        local result = ''
        if (prof1) then
            result = result .. self:getProfessionText(ProfessionsDB[prof1])
            if (prof2) then
                result = result .. separator
            end
        end

        if (prof2) then
            result = result .. self:getProfessionText(ProfessionsDB[prof2])
        end

        return result
    else
        return defaultText
    end
end

function helper.getPlayerName(self, playerInfo)
    local name = playerInfo.name
    if (playerInfo.class and TitanGetVar(TITAN_PROFESSIONS_ID, "ClassColors")) then
        name = RAID_CLASS_COLORS[playerInfo.class]:WrapTextInColorCode(playerInfo.name)
    end

    return name
end

function helper.getProfessionText(self, profession)
    local showProfessionIcons = TitanGetVar(TITAN_PROFESSIONS_ID, "ShowProfessionIcons")
    if (showProfessionIcons) then
        return string.format('|T' .. profession.icon .. ':12|t ' .. profession.name)
    else
        return profession.name
    end
end

---Joins table values by the given separator
---@param table table
---@param separator string
---@return string
function helper.joinTableValues(self, table, separator)
    local result = ''

    for _, v in pairs(table) do
        result = strconcat(result, v, separator)
    end

    if (strlen(result) > 0) then
        result = result:sub(1, -(1 + strlen(separator)))
    end

    return result
end

function helper.addDropdownButton(self, text, valueKey)
    local info = {}
    info.notCheckable = true
    info.text = text;
    info.value = valueKey;
    info.hasArrow = true;
    TitanPanelRightClickMenu_AddButton(info, TitanPanelRightClickMenu_GetDropdownLevel())
end

function helper.addCheckButton(self, text, valueKey, checkCallback)
    local info = {}
    info.text = text;
    info.checked = TitanGetVar(TITAN_PROFESSIONS_ID, valueKey);
    info.func = checkCallback

    TitanPanelRightClickMenu_AddButton(info, TitanPanelRightClickMenu_GetDropdownLevel());
end

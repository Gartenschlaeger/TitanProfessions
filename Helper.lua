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

---Returns true if the given profession should be shown
---@param professionId number|nil
---@return boolean
function helper.isProfessionShown(self, professionId)
    if (professionId) then
        return not ProfessionsDB[professionId].isHidden
    end
    return false
end

---Builds text for primary professions for the given player info
---@param playerInfo table
---@param addIcons boolean
---@return string
function helper.buildPrimaryProfessionsText(self, playerInfo, addIcons, forceShow)
    local prof1Shown = playerInfo.professions.prof1 ~= nil and
    (forceShow or self:isProfessionShown(playerInfo.professions.prof1))
    local prof2Shown = playerInfo.professions.prof2 ~= nil and
    (forceShow or self:isProfessionShown(playerInfo.professions.prof2))

    if (prof1Shown or prof2Shown) then
        local result = ''

        if (prof1Shown) then
            result = result .. self:getProfessionText(ProfessionsDB[playerInfo.professions.prof1], addIcons)
            if (prof2Shown) then
                if (addIcons) then
                    result = result .. ' '
                else
                    result = result .. ' / '
                end
            end
        end

        if (prof2Shown) then
            result = result .. self:getProfessionText(ProfessionsDB[playerInfo.professions.prof2], addIcons)
        end

        return result
    else
        return '-'
    end
end

function helper.getPlayerName(self, playerInfo)
    local name = playerInfo.name
    if (playerInfo.class and TitanGetVar(TITAN_PROFESSIONS_ID, "ClassColors")) then
        name = RAID_CLASS_COLORS[playerInfo.class]:WrapTextInColorCode(playerInfo.name)
    end

    return name
end

---Formates the profession text
---@param professionInfo table
---@param addIcon boolean
---@return string
function helper.getProfessionText(self, professionInfo, addIcon)
    if (addIcon) then
        return string.format('|T' .. professionInfo.icon .. ':12|t ' .. professionInfo.name)
    else
        return professionInfo.name
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

function helper.addCheckButton(self, text, isChecked, checkCallback)
    local info = {}
    info.text = text;
    info.checked = isChecked
    info.func = checkCallback

    TitanPanelRightClickMenu_AddButton(info, TitanPanelRightClickMenu_GetDropdownLevel());
end

function helper.ifNil(self, value, valueIfNil)
    if (value == nil) then
        return valueIfNil
    end

    return value
end

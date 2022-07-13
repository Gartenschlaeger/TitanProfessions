---@class TitanPanel_ProfessionsCore
local _, core = ...

TITAN_PROFESSIONS_VERSION = "9.0.1"
TITAN_PROFESSIONS_ID = "Professions"

RealmsDB = {}
ProfessionsDB = {}
PlayersDB = {}

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

local eventsFrame = CreateFrame("frame")

function TitanPanelProfessionsButton_OnLoad(self)
    --  print('TitanPanelProfessionsButton_OnLoad')

    self.registry = {
        id = TITAN_PROFESSIONS_ID,
        category = "Information",
        version = TITAN_PROFESSIONS_VERSION,
        menuText = core.i18n.PluginName,
        buttonTextFunction = 'TitanPanelProfessionsButton_GetButtonText',
        tooltipTitle = 'Professions',
        tooltipTextFunction = 'TitanPanelProfessionsButton_GetTooltipText',
        icon = "Interface\\ICONS\\INV_Misc_Gear_02",
        iconWidth = 16,
        controlVariables = {
            ShowIcon = true,
            ShowLabelText = true,
            DisplayOnRightSide = false,
        },
        savedVariables = {
            ShowIcon = true,
            ShowLabelText = true,
            GroupByCharacter = true,
            GroupByProfession = false,
            ClassColors = true
        }
    };

    eventsFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    eventsFrame:RegisterEvent('PLAYER_LEAVING_WORLD')
    eventsFrame:SetScript('OnEvent', TitanPanelProfessionsButton_OnUpdate)
end

function TitanPanelRightClickMenu_PrepareProfessionsMenu()
    -- print('TitanPanelRightClickMenu_PrepareProfessionsMenu')

    local dropDownLevel = TitanPanelRightClickMenu_GetDropdownLevel()
    local dropDownValue = TitanPanelRightClickMenu_GetDropdMenuValue()

    if (dropDownLevel == 1) then
        TitanPanelRightClickMenu_AddTitle(core.i18n.PluginName)

        core.helper:addDropdownButton(core.i18n.GroupBy, 'GROUPBY')
        core.helper:addDropdownButton(core.i18n.Options, 'OPTIONS')

        TitanPanelRightClickMenu_AddSeparator()
        TitanPanelRightClickMenu_AddToggleIcon(TITAN_PROFESSIONS_ID)
        TitanPanelRightClickMenu_AddToggleLabelText(TITAN_PROFESSIONS_ID)

        TitanPanelRightClickMenu_AddSeparator()
        TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_PROFESSIONS_ID, TITAN_PANEL_MENU_FUNC_HIDE)

    elseif (dropDownLevel == 2 and dropDownValue == 'GROUPBY') then
        core.helper:addCheckButton(core.i18n.GroupByChar, 'GroupByCharacter', function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", true)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", false)
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end)

        core.helper:addCheckButton(core.i18n.GroupByProf, 'GroupByProfession', function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", false)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", true)
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end)
    elseif (dropDownLevel == 2 and dropDownValue == 'OPTIONS') then
        core.helper:addCheckButton(core.i18n.ClassColors, 'ClassColors', function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "ClassColors", not TitanGetVar(TITAN_PROFESSIONS_ID, "ClassColors"))
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end)
    end
end

function TitanPanelProfessionsButton_OnUpdate(self, event, ...)
    -- print('TitanPanelProfessionsButton_OnUpdate', event, ...)

    if (event == 'PLAYER_ENTERING_WORLD') then
        core.tracking:trackPlayer()
    end
end

function TitanPanelProfessionsButton_GetButtonText(id)
    -- print('TitanPanelProfessionsButton_GetButtonText', id)

    if (id ~= TITAN_PROFESSIONS_ID) then
        return
    end

    local result = ''
    if (TitanGetVar(TITAN_PROFESSIONS_ID, 'ShowLabelText')) then
        result = strconcat(result, core.i18n.PluginName, ': ')
    end

    local playerGuid = UnitGUID('player')
    if (playerGuid) then
        local playerInfo = PlayersDB[playerGuid]
        if (not playerInfo) then
            playerInfo = core.tracking:trackPlayer()
        end

        if (playerInfo) then
            local professions = core.helper:buildPrimaryProfessionsText(playerInfo, ' / ', '-')
            result = strconcat(result, WrapTextInColorCode(professions, 'ffffffff'))
        end
    end

    return result
end

local function getTooltipGroupedByCharacter()
    local sortedKeys = core.helper:getKeysSortedByValue(PlayersDB, function(a, b)
        return a.name < b.name
    end)

    local result = ''
    for _, playerGuid in pairs(sortedKeys) do
        local playerInfo = PlayersDB[playerGuid]
        if (playerInfo.professions.prof1 or playerInfo.professions.prof2) then
            local playerName = core.helper:getPlayerName(playerInfo)
            local professions = core.helper:buildPrimaryProfessionsText(playerInfo, ' / ', '-')
            result = strconcat(result, '\n', playerName, '\t', WrapTextInColorCode(professions, 'ffffffff'))
        end
    end

    return result
end

local function getTooltipGroupedByProfession()
    local sortedProfessionKeys = core.helper:getKeysSortedByValue(ProfessionsDB, function(a, b)
        return a.name < b.name
    end)
    local sortedPlayerKeys = core.helper:getKeysSortedByValue(PlayersDB, function(a, b)
        return a.name < b.name
    end)

    local result = ''
    for _, k in pairs(sortedProfessionKeys) do
        local addProfession = false

        local players = {}
        for _, playerGuid in pairs(sortedPlayerKeys) do
            local playerInfo = PlayersDB[playerGuid]
            if (playerInfo.professions.prof1 == k or
                playerInfo.professions.prof2 == k or
                playerInfo.professions.fishing == k or
                playerInfo.professions.cooking == k or
                playerInfo.professions.archaeology == k) then

                local playerName = core.helper:getPlayerName(playerInfo)
                table.insert(players, playerName)

                addProfession = true
            end
        end

        if (addProfession) then
            local profession = ProfessionsDB[k]
            local players = core.helper:joinTableValues(players, ', ')
            if (not TitanGetVar(TITAN_PROFESSIONS_ID, "ClassColors")) then
                players = WrapTextInColorCode(players, 'ffffffff')
            end
            result = strconcat(result, '\n', profession.name, '\n', players, '\n')
        end
    end

    return result
end

function TitanPanelProfessionsButton_GetTooltipText(self)
    -- print('TitanPanelProfessionsButton_GetTooltipText')

    local groupByCharacter = TitanGetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter")
    if (groupByCharacter) then
        return getTooltipGroupedByCharacter()
    else
        return getTooltipGroupedByProfession()
    end
end

function TitanPanelProfessionsButton_OnClick(self, button)
    -- print('TitanPanelProfessionsButton_OnClick')

end

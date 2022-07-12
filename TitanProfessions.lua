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
        controlVariables = {
            ShowIcon = false, -- TODO: icon
            ShowLabelText = true,
            DisplayOnRightSide = false,
        },
        savedVariables = {
            ShowIcon = false,
            ShowLabelText = true,
            GroupByCharacter = true,
            GroupByProfession = false
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

        local infoGroupBy = {}
        infoGroupBy.notCheckable = true

        infoGroupBy.text = core.i18n.GroupBy;
        -- if (TitanGetVar(TITAN_PROFESSIONS_ID, 'GroupByCharacter') == true) then
        --     infoGroupBy.text = infoGroupBy.text .. 'Character'
        -- else
        --     infoGroupBy.text = infoGroupBy.text .. 'Profession'
        -- end

        infoGroupBy.value = "GROUPBY";
        infoGroupBy.hasArrow = 1;
        TitanPanelRightClickMenu_AddButton(infoGroupBy, dropDownLevel)

        TitanPanelRightClickMenu_AddSeparator()
        TitanPanelRightClickMenu_AddToggleIcon(TITAN_PROFESSIONS_ID)
        TitanPanelRightClickMenu_AddToggleLabelText(TITAN_PROFESSIONS_ID)

        TitanPanelRightClickMenu_AddSeparator()
        TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_PROFESSIONS_ID, TITAN_PANEL_MENU_FUNC_HIDE)

    elseif (dropDownLevel == 2 and dropDownValue == 'GROUPBY') then
        core.helper:addButton(core.i18n.GroupByChar, 'GroupByCharacter', function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", true)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", false)
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end)

        core.helper:addButton(core.i18n.GroupByProf, 'GroupByProfession', function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", false)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", true)
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
            result = strconcat(result, '\n')

            local name = playerInfo.name
            if (playerInfo.class) then
                name = RAID_CLASS_COLORS[playerInfo.class]:WrapTextInColorCode(playerInfo.name)
            end

            local professions = core.helper:buildPrimaryProfessionsText(playerInfo, ' / ', '-')
            result = strconcat(result, name, '\t', WrapTextInColorCode(professions, 'ffffffff'))
        end
    end

    return result
end

local function getTooltipGroupedByProfession()
    local sortedKeys = core.helper:getKeysSortedByValue(ProfessionsDB, function(a, b)
        return a.name < b.name
    end)

    local result = ''
    for _, k in pairs(sortedKeys) do
        local addProfession = false

        local players = {}
        for _, playerInfo in pairs(PlayersDB) do
            if (playerInfo.professions.prof1 == k or
                playerInfo.professions.prof2 == k or
                playerInfo.professions.fishing == k or
                playerInfo.professions.cooking == k or
                playerInfo.professions.archaeology == k) then

                local playerName = playerInfo.name
                if (playerInfo.class) then
                    playerName = RAID_CLASS_COLORS[playerInfo.class]:WrapTextInColorCode(playerInfo.name)
                end

                table.insert(players, playerName)
                addProfession = true
            end
        end

        if (addProfession) then
            local profession = ProfessionsDB[k]
            result = strconcat(result, '\n', profession.name, '\n', core.helper:joinTableValues(players, ', '), '\n')
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

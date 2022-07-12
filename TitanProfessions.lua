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
    --print('TitanPanelRightClickMenu_PrepareProfessionsMenu')

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
        local infoGroupByCharacter = {}
        infoGroupByCharacter.text = core.i18n.GroupByChar;
        infoGroupByCharacter.checked = TitanGetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter");
        infoGroupByCharacter.func = function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", true)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", false)
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end
        TitanPanelRightClickMenu_AddButton(infoGroupByCharacter, TitanPanelRightClickMenu_GetDropdownLevel());

        local infoGroupByProfession = {}
        infoGroupByProfession.text = core.i18n.GroupByProf;
        infoGroupByProfession.checked = TitanGetVar(TITAN_PROFESSIONS_ID, "GroupByProfession");
        infoGroupByProfession.func = function()
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByCharacter", false)
            TitanSetVar(TITAN_PROFESSIONS_ID, "GroupByProfession", true)
            TitanPanelButton_UpdateButton(TITAN_PROFESSIONS_ID)
        end
        TitanPanelRightClickMenu_AddButton(infoGroupByProfession, TitanPanelRightClickMenu_GetDropdownLevel());
    end
end

local function trackRealm()
    local realmId = GetRealmID()
    RealmsDB[realmId] = GetRealmName()

    return realmId
end

local function trackProfession(playerProfessionIndex)
    if (playerProfessionIndex == nil) then
        return nil
    end

    local name, icon = GetProfessionInfo(playerProfessionIndex)
    -- print('|T' .. icon .. ':12|t ' .. name .. ' ' .. skillLevel .. ' / ' .. maxSkillLevel)

    for professionId, professionInfo in pairs(ProfessionsDB) do
        if (professionInfo.name == name) then
            professionInfo.icon = icon
            return professionId
        end
    end

    local professionId = 1000 + core.helper:tableSize(ProfessionsDB)
    ProfessionsDB[professionId] = {
        name = name,
        icon = icon
    }

    return professionId
end

local function trackPlayer(playerGuid)
    local info = PlayersDB[playerGuid] or {}
    PlayersDB[playerGuid] = info

    local _, unitClass = UnitClass('player')

    info.realm = trackRealm()
    info.name = UnitName('player')
    info.class = unitClass

    local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    info.professions = {}
    info.professions.prof1 = trackProfession(prof1)
    info.professions.prof2 = trackProfession(prof2)
    info.professions.archaeology = trackProfession(archaeology)
    info.professions.fishing = trackProfession(fishing)
    info.professions.cooking = trackProfession(cooking)

    return info
end

local function updatePlayerProfessions()
    --print('updatePlayerProfessions')

    local playerGuid = UnitGUID('player')
    if (playerGuid) then
        trackPlayer(playerGuid)
    end
end

function TitanPanelProfessionsButton_OnUpdate(self, event, ...)
    -- print('TitanPanelProfessionsButton_OnUpdate', event, ...)

    if (event == 'PLAYER_ENTERING_WORLD') then
        updatePlayerProfessions()

    end
end

local function buildPrimaryProfessionsText(playerInfo, separator, defaultText)
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

function TitanPanelProfessionsButton_GetButtonText(id)
    -- print('TitanPanelProfessionsButton_GetButtonText', id)

    if (id ~= TITAN_PROFESSIONS_ID) then
        return
    end

    local showLabel = TitanGetVar(TITAN_PROFESSIONS_ID, 'ShowLabelText')

    local result = ''

    if (showLabel) then
        result = core.i18n.PluginName .. ': '
    end

    result = result .. '|cffffffff'

    local playerGuid = UnitGUID('player')
    if (playerGuid) then
        local playerInfo = PlayersDB[playerGuid]
        if (not playerInfo) then
            playerInfo = trackPlayer(playerGuid)
        end

        if (playerInfo) then
            result = result .. buildPrimaryProfessionsText(playerInfo, ' / ', '-')
        end
    end

    return result
end

function TitanPanelProfessionsButton_GetTooltipText(self)
    -- print('TitanPanelProfessionsButton_GetTooltipText')

    local result = ''
    for _, playerInfo in pairs(PlayersDB) do
        if (playerInfo.professions.prof1 or playerInfo.professions.prof2) then
            result = strconcat(result, '\n')

            local name = playerInfo.name
            if (playerInfo.class) then
                name = RAID_CLASS_COLORS[playerInfo.class]:WrapTextInColorCode(playerInfo.name)
            end

            result = strconcat(result, name, '\n')

            if (playerInfo.professions.prof1) then
                local professionName = WrapTextInColorCode(ProfessionsDB[playerInfo.professions.prof1].name, 'ffffffff')
                result = strconcat(result, professionName, '\n') --, '\t', '-', '\n')
            end
            if (playerInfo.professions.prof2) then
                local professionName = WrapTextInColorCode(ProfessionsDB[playerInfo.professions.prof2].name, 'ffffffff')
                result = strconcat(result, professionName, '\n') --, '\t', '-', '\n')
            end

        end
    end

    return result
end

function TitanPanelProfessionsButton_OnEvent(self, event, ...)
    --print('TitanPanelProfessionsButton_OnEvent', event, ...)
end

function TitanPanelProfessionsButton_OnClick(self, button)
    --print('TitanPanelProfessionsButton_OnClick')
end

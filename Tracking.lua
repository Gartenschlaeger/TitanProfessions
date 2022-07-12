---@class TitanPanel_ProfessionsCore
local _, core = ...

local tracking = {}
core.tracking = tracking

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

function tracking:trackPlayer()
    local playerGuid = UnitGUID('player')
    if (not playerGuid) then
        return
    end

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

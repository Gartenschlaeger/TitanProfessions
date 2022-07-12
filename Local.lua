---@class TitanPanel_ProfessionsCore
local _, core = ...

local l = {}
core.i18n = l

l.PluginName = 'Professions'
l.GroupBy = 'Group by'
l.GroupByChar = 'Character'
l.GroupByProf = 'Profession'

if (GetLocale() == 'deDE') then
    l.PluginName = 'Berufe'
    l.GroupBy = 'Gruppieren nach'
    l.GroupByChar = 'Charakter'
    l.GroupByProf = 'Beruf'
end

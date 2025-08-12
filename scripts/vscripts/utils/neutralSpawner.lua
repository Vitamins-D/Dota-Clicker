if neutralSpawner == nil then
	neutralSpawner = class({})
end

local campsUnits = {
	{"npc_dota_clicker_boar", "npc_dota_clicker_boar"}, -- 1
	{"npc_dota_clicker_wolf", "npc_dota_clicker_wolf_alpha", "npc_dota_clicker_wolf"}, -- 2
	{"npc_dota_clicker_murloc", "npc_dota_clicker_murloc2"}, -- 3
	{"npc_dota_clicker_bear"}, -- 4
}
neutralSpawner.campsUnits = campsUnits

local camps = {}
neutralSpawner.camps = camps

function neutralSpawner:InitNeutralCamps()
    local allTriggers = Entities:FindAllByClassname("trigger_multiple")

    for _, trigger in pairs(allTriggers) do
        local name = trigger:GetName()
        if string.find(name, "neutral_camp") then
            local campType = tonumber(string.match(name, 'neutral_camp_(%d+)$') or 1)
			print("campType", campType, string.match(name, 'neutral_camp_(%d+)$') )
            local camp = {
                trigger = trigger,
                campType = campType,
                units = {},
                respawnTime = 30,
                isRespawning = false
            }
            table.insert(camps, camp)

            self:SpawnCamp(camp)
        end
    end

    -- Слушаем смерти крипов только один раз
    ListenToGameEvent("entity_killed", function(keys)
        local killed = EntIndexToHScript(keys.entindex_killed)
        if killed and killed.campRef then
            self:OnCampUnitDeath(killed)
        end
    end, nil)
end

function neutralSpawner:SpawnCamp(camp)
    local unitNames = campsUnits[camp.campType]
    if not unitNames then
        print("Нет юнитов для campType: " .. tostring(camp.campType))
        return
    end

    for _, unitName in pairs(unitNames) do
        local spawnPos = camp.trigger:GetAbsOrigin() + RandomVector(math.random(0, 200))
        local unit = CreateUnitByName(unitName, spawnPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
        unit.campRef = camp -- привязка к кемпу
        table.insert(camp.units, unit)
    end

    camp.isRespawning = false
end

function neutralSpawner:OnCampUnitDeath(unit)
    local camp = unit.campRef
    if not camp then return end

    -- Удаляем из списка кемпа
    for i, u in ipairs(camp.units) do
        if u == unit then
            table.remove(camp.units, i)
            break
        end
    end

    -- Если все крипы мертвы — запускаем таймер респавна
    if #camp.units == 0 and not camp.isRespawning then
        camp.isRespawning = true
        Timers:CreateTimer(camp.respawnTime, function()
            self:SpawnCamp(camp)
        end)
    end
end

return neutralSpawner
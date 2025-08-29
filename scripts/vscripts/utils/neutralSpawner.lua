if ns == nil then
	ns = class({})
end

local campsUnits = {
	{"npc_dota_clicker_boar"}, -- 1
	{"npc_dota_clicker_wolf", "npc_dota_clicker_wolf_alpha", "npc_dota_clicker_wolf"}, -- 2
	{"npc_dota_clicker_murloc", "npc_dota_clicker_murloc2"}, -- 3
	{"npc_dota_clicker_bear"}, -- 4
}
ns.campsUnits = campsUnits
ns.dropTable = {
	["npc_dota_clicker_boar"] = {
		{item = "item_dotac_boar_skin", chance = 85},
	},
	["npc_dota_clicker_wolf"] = {
		{item = "item_dotac_wolf_skin", chance = 85},
	},
	["npc_dota_clicker_wolf_alpha"] = {
		{item = "item_dotac_wolf_skin", chance = 85},
	},
	["npc_dota_clicker_murloc"] = {
		{item = "item_dotac_murloc_skin", chance = 85},
	},
	["npc_dota_clicker_murloc2"] = {
		{item = "item_dotac_murloc_skin", chance = 85},
	},
	["npc_dota_clicker_bear"] = {
		{item = "item_dotac_bear_skin", chance = 85},
		{item = "item_dotac_cheeter_meat", chance = 5},
	},
}

local camps = {}
ns.camps = camps

function ns:InitNeutralCamps()
    local allTriggers = Entities:FindAllByClassname("trigger_multiple")

    for _, trigger in pairs(allTriggers) do
        local name = trigger:GetName()
        if string.find(name, "neutral_camp") then
            local campType = tonumber(string.match(name, 'neutral_camp_(%d+)$') or 1)
            local camp = {
                trigger = trigger,
                campType = 1,
                units = {},
                respawnTime = 30,
                camp_count = 2,
                camp_reward = 1,
                isRespawning = false
            }
            table.insert(camps, camp)

            self:SpawnCamp(camp)
        end
    end

    -- Слушаем смерти крипов только один раз
    ListenToGameEvent("entity_killed", function(keys)
        local killed = EntIndexToHScript(keys.entindex_killed)
		local attacker = EntIndexToHScript(keys.entindex_attacker or -1)
		
		if attacker then
			local playerID = attacker.playerID
			if playerID then
				local playerKey = "player_" .. playerID
				local data = CustomNetTables:GetTableValue("user_stats", playerKey)
				
				data.upgrade_point = data.upgrade_point + killed.campRef.camp_reward
				
				CustomNetTables:SetTableValue("user_stats", playerKey, data)
				
				local data = CustomNetTables:GetTableValue("user_stats", playerKey)
				print("NEW POINTS:", data.upgrade_point)
			end
		end
		
        if killed and killed.campRef then
            self:OnCampUnitDeath(killed)
        end
    end, nil)
end

function ns:SpawnCamp(camp)
    local unitNames = campsUnits[camp.campType]
    if not unitNames then
        print("Нет юнитов для campType: " .. tostring(camp.campType))
        return
    end

    for _, unitName in pairs(unitNames) do
		for i = 1, camp.camp_count do
			local spawnPos = camp.trigger:GetAbsOrigin() + RandomVector(math.random(0, 200))
			local unit = CreateUnitByName(unitName, spawnPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.campRef = camp -- привязка к кемпу

			table.insert(camp.units, unit)
		end
    end

    camp.isRespawning = false
end


function ns:OnCampUnitDeath(unit)
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

return ns
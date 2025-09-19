if u == nil then
	u = class({})
end

local G = require("utils/globalPrms")

function u:indexOf(t, value)
	for i = 1, #t do
		if t[i] == value then
			return i
		end
	end
	return nil
end

function u:countOf(tbl, value)
    local count = 0
    for i = 1, #tbl do
        if tbl[i] == value then
            count = count + 1
        end
    end
    return count
end

function u:ShuffleArray(t)
    local n = #t
    for i = n, 2, -1 do
        local j = RandomInt(1, i) -- случайный индекс от 1 до i
        t[i], t[j] = t[j], t[i]   -- меняем местами
    end
    return t
end

function u:removeAbility(unit, abil)
	local ability = unit:FindAbilityByName(abil)
	table.remove(unit.skills, self:indexOf(unit.skills, ability))
    unit:RemoveAbility(abil)
end

function u:addAbility(unit, abil, level)
	local newAbil = unit:AddAbility(abil)
	newAbil:SetLevel(level or 1)
	table.insert(unit.skills, newAbil)
end

function u:replaceAbility(unit, abil1, abil2)
	local ability = unit:FindAbilityByName(abil1)
	local lvl = ability:GetLevel()
	if ability then
		self:removeAbility(unit, abil1)
		self:addAbility(unit, abil2, lvl)
	end
end

function u:upgradeAbility(unit, abil)
	local ability = unit:FindAbilityByName(abil)
	if ability then
		ability:SetLevel(ability:GetLevel() + 1)
	end
end

function u:GiveGold(gold, playerId)
	if PlayerResource:HasSelectedHero(playerId) then
		local player = PlayerResource:GetPlayer(playerId)
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		hero:ModifyGold(gold, false, 0)
		SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, hero, gold, nil)
	end
end

function u:GivePoint(point, playerId)
	local playerKey = "player_" .. playerId
	local data = CustomNetTables:GetTableValue("user_stats", playerKey)

	if data then
		data.upgrade_point = data.upgrade_point + point
		CustomNetTables:SetTableValue("user_stats", playerKey, data)
	end
end

function u:RemoveItemByName(unit, item_name)
    for slot = 0, 8 do
        local item = unit:GetItemInSlot(slot)
        if item and item:GetName() == item_name then
            unit:RemoveItem(item)
			UTIL_Remove(item)
            return true -- нашли и удалили
        end
    end
    return false -- предмета нет
end

function u:GetPoints(playerID)
	local playerKey = "player_" .. playerID
	return CustomNetTables:GetTableValue("user_stats", playerKey).upgrade_point
end

function u:UpdatePoints(playerID, value)
	local playerKey = "player_" .. playerID
	local data = CustomNetTables:GetTableValue("user_stats", playerKey)
	data.upgrade_point = data.upgrade_point + value
	CustomNetTables:SetTableValue("user_stats", playerKey, data)
end

function u:getArrFromCNT(data)
	local arr = {}
	for _,v in pairs(data) do
		table.insert(arr, v)
	end
	return arr
end

function u:throughPlayers(callback, notHero)
	for index = 0, G.playerCount - 1 do
		if notHero or PlayerResource:HasSelectedHero(index)then
			local player = PlayerResource:GetPlayer(index)
			if player then
				local hero = PlayerResource:GetSelectedHeroEntity(index)
				callback(player, hero, index)
			end
		end
	end
end

return u
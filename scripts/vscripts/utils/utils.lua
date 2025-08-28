if u == nil then
	u = class({})
end

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

function u:RemoveItemByName(unit, item_name)
    for slot = 0, 5 do
        local item = unit:GetItemInSlot(slot)
        if item and item:GetName() == item_name then
            unit:RemoveItem(item)
			UTIL_Remove(item)
            return true -- нашли и удалили
        end
    end
    return false -- предмета нет
end

return u
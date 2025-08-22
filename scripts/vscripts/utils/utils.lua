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
	table.remove(unit.skills, self:indexOf(unit.skills, abil))
    unit:RemoveAbility(abil)
end

function u:addAbility(unit, abil)
	local newAbil = unit:AddAbility(abil)
	newAbil:SetLevel(1)
	table.insert(unit.skills, newAbil)
end

function u:replaceAbility(unit, abil1, abil2)
	local ability = unit:FindAbilityByName(abil1)
	if ability then
		self:removeAbility(unit, ability)
		self:addAbility(unit, abil2)
	end
end

function u:upgradeAbility(unit, abil)
	local ability = unit:FindAbilityByName(abil)
	if ability then
		ability:SetLevel(ability:GetLevel() + 1)
	end
end

return u
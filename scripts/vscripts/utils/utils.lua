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

function u:replaceAbility(unit, abil1, abil2)
    unit:RemoveAbility(abil1)
	unit:AddAbility(abil2)
end

function u:upgradeAbility(unit, abil)
	local ability = unit:FindAbilityByName(abil)
	if ability then
		ability:SetLevel(ability:GetLevel() + 1)
	end
end

return u
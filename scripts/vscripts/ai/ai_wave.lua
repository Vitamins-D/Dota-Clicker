require('ai/ai_core')
require('ai/ai_skills')
local nextPath = true

function Spawn(entityKeyValues)
	if not IsServer() then return end

    thisEntity.currentPathIndex = 1
	thisEntity:SetContextThink("AIThink", AIThink, 0.5)
end

function goPath()
	if nextPath and not thisEntity:IsChanneling() and not thisEntity:IsAttacking() and thisEntity.currentPathIndex <= #thisEntity.path then
        local targetPoint = thisEntity.path[thisEntity.currentPathIndex]
        if targetPoint then
            local distance = (thisEntity:GetAbsOrigin() - targetPoint:GetAbsOrigin()):Length2D()
            if distance < 100 then
                -- Дошёл до точки → следующая
                thisEntity.currentPathIndex = thisEntity.currentPathIndex + 1
            end
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = thisEntity.path[thisEntity.currentPathIndex]:GetAbsOrigin(),
                Queue = false,
            })
        end
    end
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	local skills = thisEntity.skills
	if skills then
		for i = 1, #skills do
			local skill = skills[i]
			local name = skill:GetAbilityName()
			skillsCore.pattern[name]({ability = skill, thisEntity = thisEntity})
		end
	end
	
	goPath()
	
    return 0.5 -- Продолжите обработку на следующем тике
end

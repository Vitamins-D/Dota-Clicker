require('ai/ai_core')
local spawnPoint

function Spawn(entityKeyValues)
	thisEntity:SetContextThink("AIThink", AIThink, 1)
	spawnPoint = thisEntity:GetAbsOrigin()
end

function spawnBack()
	local dist = VectorDistance(spawnPoint, thisEntity:GetAbsOrigin())
	if not thisEntity:GetAggroTarget() or dist > 1500 then
		local order = {
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = spawnPoint
		}
		ExecuteOrderFromTable(order)
	end
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	spawnBack()
	
    return 1 -- Продолжите обработку на следующем тике
end

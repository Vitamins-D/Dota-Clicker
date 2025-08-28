require('ai/ai_core')
local nextPath = true
local returnValue = 2

function Spawn(entityKeyValues)
	if not IsServer() then return end
	
	thisEntity:SetContextThink("AIThink", AIThink, 0.1)
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	local targetPoint
	local finFunction
	returnValue = 2
	if thisEntity.phase == "goMine" then
		targetPoint = thisEntity.mine
		finFunction = thisEntity.mineOre
	elseif thisEntity.phase == "goHome" then
		targetPoint = thisEntity.home
		finFunction = thisEntity.sellOre
	else
		returnValue = 0.5
	end
	
	if targetPoint then
		local distance = (thisEntity:GetAbsOrigin() - targetPoint):Length2D()
		if distance < 400 then
			if finFunction then 
				finFunction() 
				return returnValue
			end
		end
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
			Position = targetPoint,
			Queue = false,
		})
	end

    return returnValue-- Продолжите обработку на следующем тике
end

require('ai/ai_core')
-- local spawnPoint
local back = true

function Spawn(entityKeyValues)
	-- spawnPoint = thisEntity:GetAbsOrigin()
	thisEntity:SetContextThink("AIThink", AIThink, 1)
end

function spawnBack()
	if not thisEntity.spawnPoint then
		thisEntity.spawnPoint = thisEntity:GetAbsOrigin()
	end
	-- local dist = VectorDistance(spawnPoint, thisEntity:GetAbsOrigin())
	local order = {
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = thisEntity.spawnPoint
	}
	ExecuteOrderFromTable(order)
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	do
		local hAbility = thisEntity:FindAbilityByName("dotac_murloc_tentacles")
		if hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(hAbility:GetSpecialValueFor("radius"), thisEntity)
			if #enemies > 0 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = hAbility:entindex(),
				})
				return hAbility:GetCastPoint()
			end
		end
	end
	
	do
		local hAbility = thisEntity:FindAbilityByName("dotac_boar_charge")
		if hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(600, thisEntity)
			if #enemies > 0 then
				local enemy = enemies[math.random(1, #enemies)]
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = enemy:entindex(),
					AbilityIndex = hAbility:entindex(),
				})
				back = false
				Timers:CreateTimer(5, function()
					back = true
					return
				end)
				return hAbility:GetCastPoint()
			end
		end
	end
	
	if back then spawnBack() end
	
    return 1 -- Продолжите обработку на следующем тике
end

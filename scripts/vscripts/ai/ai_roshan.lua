require('ai/ai_core')
local returnValue = 0.5
local abilityReady = true
local abilityCD = true

function Spawn(entityKeyValues)
	if not IsServer() then return end
	
	thisEntity:SetContextThink("AIThink", AIThink, returnValue)
end

function setACD(value)
	abilityReady = false
	abilityCD = value
end

function updateACD()
	if not abilityReady then
		abilityCD = abilityCD - 1
		if abilityCD <= 0 then
			abilityReady = true
		end
	end
end

function goBack()
	local dist = VectorDistance(thisEntity.spawnPoint, thisEntity:GetAbsOrigin())
	if dist > 1000 or not thisEntity:GetAggroTarget() then
		local order = {
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = thisEntity.spawnPoint
		}
		ExecuteOrderFromTable(order)
	end
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	do
		local hAbility = thisEntity:FindAbilityByName("roshan_enrage")
		if hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(1000, thisEntity)
			local hpPct = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
			if hpPct <= 50 and (#enemies > 0 or thisEntity:GetAggroTarget()) then
				print("roshan_enrage")
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
		local hAbility = thisEntity:FindAbilityByName("roshan_pulverize")
		if abilityReady and hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(hAbility:GetCastRange(), thisEntity)
			if #enemies > 0 then
				print("roshan_pulverize")
				local enemy = enemies[1]
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = enemy:entindex(),
					AbilityIndex = hAbility:entindex(),
				})
				setACD(3)
				return hAbility:GetCastPoint() + hAbility:GetSpecialValueFor("channel_time")
			end
		end
	end
	
	do
		local hAbility = thisEntity:FindAbilityByName("roshan_sonic_wave")
		if abilityReady and hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(hAbility:GetCastRange(), thisEntity)
			if #enemies > 0 then
				print("roshan_sonic_wave")
				local enemy = enemies[1]
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = hAbility:entindex(),
					Position = enemy:GetOrigin(),
					Queue = false,
				})
				setACD(3)
				return hAbility:GetCastPoint()
			end
		end
	end
	
	do
		local hAbility = thisEntity:FindAbilityByName("roshan_fissure")
		if abilityReady and hAbility and hAbility:IsFullyCastable() then
			local enemies = AICore:getEnemies(hAbility:GetCastRange(), thisEntity)
			if #enemies > 0 then
				print("roshan_fissure")
				local enemy = enemies[1]
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = hAbility:entindex(),
					Position = enemy:GetOrigin(),
					Queue = false,
				})
				setACD(3)
				return hAbility:GetCastPoint() + 0.1
			end
		end
	end
	
	updateACD()
	goBack()
	
    return returnValue-- Продолжите обработку на следующем тике
end

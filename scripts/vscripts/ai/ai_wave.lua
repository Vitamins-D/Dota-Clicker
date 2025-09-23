require('ai/ai_core')
require('ai/ai_skills')
require('ai/ai_item')

local nextPath = true
local returnValue = 0.5
local rndMin = -0.3
local rndMax = 0.4

function Spawn(entityKeyValues)
	if not IsServer() then return end
	
	if thisEntity.subclass == "air_mage"then
		returnValue = 0.2
		rndMin = 0
		rndMax = 0
	end
	
    thisEntity.currentPathIndex = 1
	thisEntity:SetIdleAcquire(true)
	thisEntity:SetContextThink("AIThink", AIThink, returnValue + math.random(rndMin, rndMax))
end

function goPath()
	if thisEntity and nextPath and not thisEntity:IsChanneling() and not thisEntity:IsAttacking() and thisEntity.currentPathIndex <= #thisEntity.path then
        local targetPoint = thisEntity.path[thisEntity.currentPathIndex]
        if targetPoint then
            local distance = (thisEntity:GetAbsOrigin() - targetPoint:GetAbsOrigin()):Length2D()
            if distance < 500 then
                -- Дошёл до точки → следующая
                thisEntity.currentPathIndex = thisEntity.currentPathIndex + 1
				if thisEntity.currentPathIndex > #thisEntity.path then
					if thisEntity.isCaravan then
						thisEntity:RemoveSelf()
					else
						thisEntity.currentPathIndex = #thisEntity.path
					end
				end
            end
			if thisEntity.currentPathIndex <= #thisEntity.path then
				targetPoint = thisEntity.path[thisEntity.currentPathIndex]
				if targetPoint then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = thisEntity.path[thisEntity.currentPathIndex]:GetAbsOrigin(),
						Queue = false,
					})
				end
			end
        end
    end
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
	
	if thisEntity.subclass == "air_mage"then
		local lAbility = thisEntity:FindAbilityByName("dc_silencer_last_word")
		if lAbility and lAbility:IsFullyCastable() then
			-- returnValue = 0.1
			local enemies = AICore:getEnemies(lAbility:GetCastRange(), thisEntity)
			
			for _, enemy in pairs(enemies) do
				for i=0, 11 do  -- проверяем 6 слотов способностей
					local ab = enemy:GetAbilityByIndex(i)
					if ab and ab:IsInAbilityPhase() then
						
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							AbilityIndex = lAbility:entindex(),
							TargetIndex = enemy:entindex(),
							Queue = false
						})
						Timers:CreateTimer(0.1, function()
							if not lAbility:IsCooldownReady() then
								enemy:Interrupt()  
								ab:StartCooldown(ab:GetCooldown(ab:GetLevel()))
							end
						end)
						-- returnValue = 0.2
						return lAbility:GetCastPoint() + 0.1
					end
				end
			end
		end
	end
	
	local skills = thisEntity.skills
	if skills then
		for i = 1, #skills do
			local skill = skills[i]
			if skill then
				local name = skill:GetAbilityName()
				if skillsCore.pattern[name] then skillsCore.pattern[name]({ability = skill, thisEntity = thisEntity}) end
			end
		end
	end
	
	local items = thisEntity.items
	if items then
		for i = 1, #items do
			local item = items[i]
			if item then
				local name = item:GetAbilityName()
				if itemCore.pattern[name] then itemCore.pattern[name]({item = item, thisEntity = thisEntity}) end
			end
		end
	end
	
	goPath()
	
    return returnValue + math.random(rndMin, rndMax)-- Продолжите обработку на следующем тике
end

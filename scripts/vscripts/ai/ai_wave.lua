require('ai/ai_core')
require('ai/ai_skills')
local nextPath = true
local returnValue = 0.5

function Spawn(entityKeyValues)
	if not IsServer() then return end
	
	if thisEntity.subclass == "air_mage"then
		returnValue = 0.2
	end
	
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
	
	goPath()
	
    return returnValue-- Продолжите обработку на следующем тике
end

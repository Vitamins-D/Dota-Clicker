require('ai/ai_core')

function Spawn(entityKeyValues)
	if not IsServer() then return end
	
	local splitShot = thisEntity:FindAbilityByName("dc_medusa_split_shot_tower")
	if splitShot then
		local name = thisEntity:GetUnitName()
		local number = string.match(name, "%d+")
		if tonumber(number) == 3 then
			splitShot:SetLevel(0)
		else
			splitShot:SetLevel(1)
		end
		splitShot:ToggleAbility()
	end
	
	thisEntity:SetContextThink("AIThink", AIThink, 0.5)
end

function AIThink()
    if not thisEntity:IsAlive() then
        return nil -- Прекратить обработку, если крип мертв
    end
	
    return 5-- Продолжите обработку на следующем тике
end

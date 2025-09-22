if item_dotac_aegis == nil then
    item_dotac_aegis = class({})
end

function item_dotac_aegis:OnSpellStart()
    if IsServer() then
        print("TEST TEST")
		
		local utils = require("utils/utils")

        local caster = self:GetCaster()
        local playerID = caster:GetPlayerOwnerID()
        local playerKey = "player_" .. playerID
	
	
		utils:UpdateRPoints(playerID, 1)
		utils:RemoveItemByName(caster, self:GetName())
    end
end

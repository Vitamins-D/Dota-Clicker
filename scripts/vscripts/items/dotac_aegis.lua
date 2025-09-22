if item_dotac_aegis == nil then
    item_dotac_aegis = class({})
end

local utils = require("utils/utils")

function item_dotac_aegis:OnSpellStart()
    if IsServer() then
        print("TEST TEST")

        local caster = self:GetCaster()
        local playerID = caster:GetPlayerOwnerID()
		
		print("playerID", playerID)
		
        -- правильно через точку
        -- utils:UpdateRPoints(playerID, 1)

        caster:RemoveItem(self)
		-- utils:RemoveItemByName(caster, self:GetName())
    end
end

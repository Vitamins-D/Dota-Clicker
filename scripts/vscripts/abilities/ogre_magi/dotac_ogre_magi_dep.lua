if dotac_ogre_magi_dep == nil then
    dotac_ogre_magi_dep = class({})
end

function dotac_ogre_magi_dep:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local playerID = caster:GetPlayerOwnerID()
    local player = PlayerResource:GetPlayer(playerID)

    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "open_ogre", {})
    end
end

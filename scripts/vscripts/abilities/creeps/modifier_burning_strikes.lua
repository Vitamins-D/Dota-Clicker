LinkLuaModifier( "modifier_burning_strikes_debuff", "abilities/creeps/modifier_burning_strikes_debuff.lua", LUA_MODIFIER_MOTION_NONE )
modifier_burning_strikes = class({})

function modifier_burning_strikes:IsHidden() return true end
function modifier_burning_strikes:IsPurgable() return false end

function modifier_burning_strikes:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_burning_strikes:OnAttackLanded(params)
    if not IsServer() then return end
    local parent = self:GetParent() -- владелец пассивки
    if params.target == parent and params.attacker:IsAlive() and not params.attacker:IsBuilding() then
        local ability = self:GetAbility()
        if ability and ability:GetLevel() > 0 then
            local duration = ability:GetSpecialValueFor("burn_duration")

            params.attacker:AddNewModifier(
                parent,
                ability,
                "modifier_burning_strikes_debuff",
                { duration = duration }
            )
        end
    end
end


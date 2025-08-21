modifier_burning_strikes_debuff = class({})

function modifier_burning_strikes_debuff:IsDebuff() return true end
function modifier_burning_strikes_debuff:IsPurgable() return true end

function modifier_burning_strikes_debuff:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end

function modifier_burning_strikes_debuff:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if ability then
        local burn_dps = ability:GetSpecialValueFor("burn_dps")
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = burn_dps,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability
        })
    end
end

function modifier_burning_strikes_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
end

function modifier_burning_strikes_debuff:GetModifierSpellAmplify_Percentage(params)
        return -self:GetAbility():GetSpecialValueFor("magic_resist_reduction")
end

modifier_dotac_pickaxe = class({})

function modifier_dotac_pickaxe:IsHidden()
    return true
end

function modifier_dotac_pickaxe:IsPurgable()
    return false
end

function modifier_dotac_pickaxe:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dotac_pickaxe:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_dotac_pickaxe:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
    return 0
end
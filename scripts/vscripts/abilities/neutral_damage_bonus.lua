neutral_damage_bonus = class({})

function neutral_damage_bonus:GetIntrinsicModifierName()
    return "modifier_neutral_damage_bonus_passive"
end

-- Modifier для пассивки
neutral_damage_bonus = class({})

function neutral_damage_bonus:GetIntrinsicModifierName()
    return "modifier_neutral_damage_bonus_passive"
end

modifier_neutral_damage_bonus_passive = class({})

function modifier_neutral_damage_bonus_passive:IsHidden()
    return true
end

function modifier_neutral_damage_bonus_passive:IsPurgable()
    return false
end

function modifier_neutral_damage_bonus_passive:IsPassive()
    return true
end

function modifier_neutral_damage_bonus_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_neutral_damage_bonus_passive:GetModifierDamageOutgoing_Percentage(params)
    if not params.target then return 0 end
    
    -- Проверяем что цель - нейтрал
    if params.target:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
        return self:GetAbility():GetSpecialValueFor("damage_bonus")
    end
    
    return 0
end

LinkLuaModifier("modifier_neutral_damage_bonus_passive", "abilities/neutral_damage_bonus", LUA_MODIFIER_MOTION_NONE)
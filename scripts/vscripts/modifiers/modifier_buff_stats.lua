modifier_buff_stats = class({})

function modifier_buff_stats:IsHidden()
    return true -- скрыт
end

function modifier_buff_stats:IsPurgable()
    return false -- нельзя развеять
end

function modifier_buff_stats:RemoveOnDeath()
    return false -- не снимается при смерти
end

function modifier_buff_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,      -- + урон
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,               -- + HP
        MODIFIER_PROPERTY_MANA_BONUS,                 -- + мана
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,      -- + реген HP
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,        -- + реген маны
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- + скорость атаки
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,       -- + броня
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,   -- + маг. сопротивление
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,   -- + усиление маг. урона
    }
end

-- Урон
function modifier_buff_stats:GetModifierBaseAttack_BonusDamage()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["atk"] or 0
end

-- HP
function modifier_buff_stats:GetModifierExtraHealthBonus()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["hp"] or 0
end

-- Мана
function modifier_buff_stats:GetModifierManaBonus()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["mana"] or 0
end

-- Реген HP
function modifier_buff_stats:GetModifierConstantHealthRegen()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["hpreg"] or 0
end

-- Реген маны
function modifier_buff_stats:GetModifierConstantManaRegen()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["manareg"] or 0
end

-- Скорость атаки
function modifier_buff_stats:GetModifierAttackSpeedBonus_Constant()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["atks"] or 0
end

-- Броня
function modifier_buff_stats:GetModifierPhysicalArmorBonus()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["armor"] or 0
end

-- Маг. сопротивление
function modifier_buff_stats:GetModifierMagicalResistanceBonus()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["magr"] or 0
end

-- Усиление магического урона
function modifier_buff_stats:GetModifierSpellAmplify_Percentage()
    local bonus = self:GetParent().bonus
    if not bonus then return 0 end
    return bonus["spell_amp"] or 0
end

function modifier_buff_stats:OnCreated(kv)
    if not IsServer() then return end
    local unit = self:GetParent()

    -- Создаём bonus, если его нет
    if not unit.bonus then
        unit.bonus = {}
    end

    print("unit.bonus", unit.bonus["mana"])
    print("unit name", unit:GetUnitName())
end

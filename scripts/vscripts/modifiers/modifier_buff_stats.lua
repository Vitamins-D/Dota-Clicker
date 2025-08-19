modifier_buff_stats = class({})

function modifier_buff_stats:IsHidden()
    return false -- Сделаем видимым для отладки
end

function modifier_buff_stats:IsPurgable()
    return false
end

function modifier_buff_stats:RemoveOnDeath()
    return false
end

function modifier_buff_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        -- Добавляем эти функции для принудительного обновления статов
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
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

-- Дополнительные функции для принудительного обновления
function modifier_buff_stats:GetModifierBonusStats_Strength()
    return 0
end

function modifier_buff_stats:GetModifierBonusStats_Agility()
    return 0
end

function modifier_buff_stats:GetModifierBonusStats_Intellect()
    return 0
end

function modifier_buff_stats:OnCreated(kv)
    if not IsServer() then return end
    local unit = self:GetParent()
    
    -- Создаём bonus, если его нет
    if not unit.bonus then
        unit.bonus = {}
    end
    
    -- Принудительно обновляем статы через небольшую задержку
    Timers:CreateTimer(0.1, function()
        self:ForceRefresh()
        return nil
    end)
end

function modifier_buff_stats:OnRefresh(kv)
    if not IsServer() then return end
    
    -- Принудительно обновляем статы при обновлении модификатора
    Timers:CreateTimer(0.03, function()
        self:ForceRefresh()
        return nil
    end)
end

-- Функция для принудительного обновления статов
function modifier_buff_stats:ForceRefresh()
    local unit = self:GetParent()
    if not unit or not IsValidEntity(unit) then return end
    
    -- Принудительно пересчитываем статы
    unit:CalculateStatBonus(true)
    
    -- Альтернативный способ - временно убираем и добавляем модификатор
    -- (используйте только если предыдущий способ не работает)
    --[[
    local current_bonus = unit.bonus
    self:Destroy()
    
    Timers:CreateTimer(0.01, function()
        unit.bonus = current_bonus
        unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
        return nil
    end)
    --]]
end

-- Дополнительная функция для ручного обновления статов (можно вызывать извне)
function modifier_buff_stats:UpdateStats()
    self:ForceRefresh()
end
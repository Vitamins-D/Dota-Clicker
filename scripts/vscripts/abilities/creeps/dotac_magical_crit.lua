LinkLuaModifier("modifier_magical_crit", "abilities/creeps/dotac_magical_crit.lua", LUA_MODIFIER_MOTION_NONE)

dotac_magical_crit = class({})

function dotac_magical_crit:GetIntrinsicModifierName()
    return "modifier_magical_crit"
end

------------------------------------------
-- Модификатор
------------------------------------------
modifier_magical_crit = class({})

function modifier_magical_crit:IsHidden() return true end
function modifier_magical_crit:IsPurgable() return false end

function modifier_magical_crit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_magical_crit:GetModifierTotalDamageOutgoing_Percentage(params)
    if not IsServer() then return 0 end

    -- Берём только магический урон
    if params.damage_type == DAMAGE_TYPE_MAGICAL then
        local ability = self:GetAbility()
        if not ability then return 0 end

        local chance = ability:GetSpecialValueFor("chance")
        local crit = ability:GetSpecialValueFor("crit")

        -- Проверка на шанс
        if RollPercentage(chance) then
            -- Можно добавить эффект (например, критический звук или частицы)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, params.damage * (crit/100 - 1), nil)

            return crit - 100 -- Увеличиваем урон на X%
        end
    end

    return 0
end

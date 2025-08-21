-- abilities/creeps/dotac_vampiric_aura.lua
LinkLuaModifier("modifier_dotac_vampiric_aura", "abilities/creeps/dotac_vampiric_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dotac_vampiric_aura_effect", "abilities/creeps/dotac_vampiric_aura.lua", LUA_MODIFIER_MOTION_NONE)

dotac_vampiric_aura = class({})

function dotac_vampiric_aura:GetIntrinsicModifierName()
    return "modifier_dotac_vampiric_aura"
end

-----------------------------------------
-- Аура
-----------------------------------------
modifier_dotac_vampiric_aura = class({})

function modifier_dotac_vampiric_aura:IsHidden() return true end
function modifier_dotac_vampiric_aura:IsPurgable() return false end

function modifier_dotac_vampiric_aura:IsAura() return true end
function modifier_dotac_vampiric_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_dotac_vampiric_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_dotac_vampiric_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_dotac_vampiric_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_dotac_vampiric_aura:GetModifierAura() return "modifier_dotac_vampiric_aura_effect" end

-----------------------------------------
-- Эффект ауры (вампиризм)
-----------------------------------------
modifier_dotac_vampiric_aura_effect = class({})

function modifier_dotac_vampiric_aura_effect:IsHidden() return false end
function modifier_dotac_vampiric_aura_effect:IsPurgable() return false end

function modifier_dotac_vampiric_aura_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_dotac_vampiric_aura_effect:OnTakeDamage(params)
    if not IsServer() then return end

    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not ability then return end

    -- Проверка: атакует ли наш юнит и урон ли физический
    if params.attacker == parent and params.damage_type == DAMAGE_TYPE_PHYSICAL then
        local lifesteal_pct = ability:GetSpecialValueFor("vampiric_perc")

        -- Хилим на процент от нанесённого урона
        local heal = params.damage * lifesteal_pct / 100
        if heal > 0 then
            parent:Heal(heal, ability)

            -- Можно добавить зелёную циферку над героем
            SendOverheadEventMessage(parent:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, parent, heal, nil)
        end
    end
end

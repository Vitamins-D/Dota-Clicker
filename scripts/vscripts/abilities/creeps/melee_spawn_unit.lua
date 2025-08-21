melee_spawn_unit = class({})

function melee_spawn_unit:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local count = self:GetSpecialValueFor("count")
    local unit_name = "npc_dota_clicker_evol_melee_sub"

    local hp_perc = self:GetSpecialValueFor("hp_perc") / 100
    local armor_perc = self:GetSpecialValueFor("def_perc") / 100
    local dmg_perc = self:GetSpecialValueFor("damage_perc") / 100

    for i = 1, count do 
        local spawn_position = caster:GetAbsOrigin() + RandomVector(200)
        local summoned_unit = CreateUnitByName(unit_name, spawn_position, true, caster, caster, caster:GetTeamNumber())
		summoned_unit.path = caster.path
		
        -- Удаление после времени
        summoned_unit:AddNewModifier(caster, self, "modifier_kill", { duration = duration })
		summoned_unit:AddNewModifier(caster, self, "modifier_illusion", {duration = duration})

        -- === СТАТЫ ===
        -- HP
        local max_hp = caster:GetMaxHealth() * hp_perc
        summoned_unit:SetBaseMaxHealth(max_hp)
        summoned_unit:SetMaxHealth(max_hp)
        summoned_unit:SetHealth(max_hp)

        -- Урон
        local base_dmg_min = caster:GetBaseDamageMin() * dmg_perc
        local base_dmg_max = caster:GetBaseDamageMax() * dmg_perc
        summoned_unit:SetBaseDamageMin(base_dmg_min)
        summoned_unit:SetBaseDamageMax(base_dmg_max)

        -- Броня
        local armor = caster:GetPhysicalArmorValue(false) * armor_perc
        summoned_unit:SetPhysicalArmorBaseValue(armor)
    end
end

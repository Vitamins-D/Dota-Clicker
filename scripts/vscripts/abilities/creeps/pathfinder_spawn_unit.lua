pathfinder_spawn_unit = class({})

function pathfinder_spawn_unit:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local count = self:GetSpecialValueFor("count")
    local unit_name = "npc_dota_clicker_boar_sub"

    local hp = self:GetSpecialValueFor("hp")
    local armor = self:GetSpecialValueFor("def")
    local dmg = self:GetSpecialValueFor("damage")

    for i = 1, count do 
        local spawn_position = caster:GetAbsOrigin() + RandomVector(200)
        local summoned_unit = CreateUnitByName(unit_name, spawn_position, true, caster, caster, caster:GetTeamNumber())
		summoned_unit.path = caster.path
		summoned_unit.currentPathIndex = caster.currentPathIndex
		
        -- Удаление после времени
        summoned_unit:AddNewModifier(caster, self, "modifier_kill", { duration = duration })

        -- === СТАТЫ ===
        -- HP
        summoned_unit:SetBaseMaxHealth(hp)
        summoned_unit:SetMaxHealth(hp)
        summoned_unit:SetHealth(hp)

        -- Урон
        summoned_unit:SetBaseDamageMin(dmg-5)
        summoned_unit:SetBaseDamageMax(dmg+5)

        -- Броня
        summoned_unit:SetPhysicalArmorBaseValue(armor)
    end
end
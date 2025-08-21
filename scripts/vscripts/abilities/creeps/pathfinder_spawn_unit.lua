pathfinder_spawn_unit = class({})

local spawn_units = {"npc_dota_clicker_boar_sub"}

function pathfinder_spawn_unit:OnSpellStart()
    local caster = self:GetCaster()
    local unit_id = self:GetSpecialValueFor("unit_id")
    local duration = self:GetSpecialValueFor("duration")
    local count = self:GetSpecialValueFor("count")
    

    -- Проверка, что unit_id корректен
    if unit_id < 1 or unit_id > #spawn_units then
        print("[pathfinder_spawn_unit] Invalid unit_id: " .. unit_id)
        return
    end

    -- Получение имени юнита из массива
    local unit_name = spawn_units[unit_id]

    for i = 1, count do 
        local spawn_position = caster:GetAbsOrigin() + RandomVector(200) -- Случайная позиция рядом с кастером
        -- Призыв юнита
        local summoned_unit = CreateUnitByName(unit_name, spawn_position, true, caster, caster, caster:GetTeamNumber())
        -- Установка удаления через duration
        summoned_unit:AddNewModifier(caster, self, "modifier_kill", { duration = duration })
    end
end
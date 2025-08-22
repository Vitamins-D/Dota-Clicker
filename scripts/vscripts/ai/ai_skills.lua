skillsCore = {}

require('ai/ai_core')

function aroundDanger(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(800, thisEntity)
		if #enemies > 0 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = hAbility:entindex(),
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function takeAim(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(hAbility:GetSpecialValueFor("active_attack_range_bonus") + thisEntity:GetAttackRangeBuffer(), thisEntity)
		if #enemies > 0 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = hAbility:entindex(),
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function targetCast(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(hAbility:GetCastRange(), thisEntity)
		if #enemies > 0 then
			local enemy = enemies[math.random(1, #enemies)]
			local order = {
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = enemy:entindex(),
				AbilityIndex = hAbility:entindex(),
				Queue = false,
			}
			ExecuteOrderFromTable(order)
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function buffYourSelf(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(800, thisEntity)
		if #enemies > 0 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = hAbility:entindex(),
				Queue = false,
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function naturesAttendants(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local hpPct = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
		if hpPct<50 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = hAbility:entindex(),
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function splitShot(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(800, thisEntity)
		if (#enemies > 1 and not hAbility.active) or (hAbility.active and #enemies == 1) then
			hAbility:ToggleAbility()
			if hAbility.active then hAbility.active = false
			else hAbility.active = true end
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function autoCast(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		if not hAbility.active then
			hAbility:ToggleAutoCast()
			hAbility.active = true
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function coldEmbrace(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local allies = AICore:getAllies(hAbility:GetCastRange(), thisEntity)
		local target
		local targetHpPct = 35
		for i = 1, #allies do
			local unit = allies[i]
			local hpPct = (unit:GetHealth() / unit:GetMaxHealth()) * 100
			if hpPct < targetHpPct then
				target = unit
				targetHpPct = hpPct
			end
		end
		
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = hAbility:entindex(),
				Queue = false,
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function summonWard(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(hAbility:GetCastRange(), thisEntity)
		if #enemies > 0 then
			local enemy = enemies[math.random(1, #enemies)]
			
			local direction = (enemy:GetOrigin() - thisEntity:GetOrigin()):Normalized()
            local castPos = enemy:GetOrigin() - direction * 100
			
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = hAbility:entindex(),
				Position = castPos, -- Используйте позицию врага как направление
				Queue = false,
			})
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function chakraMagic(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		if thisEntity.subclass == "fire_mage" then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = hAbility:entindex(),
				Queue = false,
			})
			return hAbility:GetCastPoint()+0.1
		else
			local allies = AICore:getAllies(hAbility:GetCastRange(), thisEntity)
			local target
			local targetManaPct = 95
			for i = 1, #allies do
				local unit = allies[i]
				local manaPct = (unit:GetMana() / unit:GetMaxMana()) * 100
				if manaPct < targetManaPct and not (unit.type ~= "mage" and target.type == "mage" and targetManaPct < 75) then
					target = unit
					targetManaPct = manaPct
				end
			end
			
			local myMana = (thisEntity:GetMana() / thisEntity:GetMaxMana()) * 100
			if myMana < targetManaPct and targetManaPct - myMana > 10 then
				target = thisEntity
			end
			
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = hAbility:entindex(),
					Queue = false,
				})
				return hAbility:GetCastPoint()+0.1
			end
		end
	end
end

function suicide(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local hpPct = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
		if hpPct < 15 then
			local enemies = AICore:getAllEnemies(hAbility:GetCastRange(), thisEntity)
			if #enemies > 0 then
				local enemy = enemies[math.random(1, #enemies)]
				
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = hAbility:entindex(),
					Position = enemy:GetOrigin(), -- Используйте позицию врага как направление
					Queue = false,
				})
				
				Timers:CreateTimer(hAbility:GetCastPoint()+0.1, function()
					if not hAbility:IsCooldownReady() then
						local damage_table = {
							victim = thisEntity,          
							attacker = thisEntity,        
							damage = thisEntity:GetMaxHealth()*1.5,        
							damage_type = DAMAGE_TYPE_PURE, 
							ability = nil,      
						}
						ApplyDamage(damage_table)
					end
				end)
				
				return hAbility:GetCastPoint()+0.1
			end
		end
	end
end

function posCast(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local enemies = AICore:getAllEnemies(hAbility:GetCastRange(), thisEntity)
		if #enemies > 0 then
			local enemy = enemies[math.random(1, #enemies)]
			local order = {
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = hAbility:entindex(),
				Position = enemy:GetOrigin(), -- Используйте позицию врага как направление
				Queue = false,
			}
			ExecuteOrderFromTable(order)
			return hAbility:GetCastPoint()+0.1
		end
	end
end

function castByReady(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = hAbility:entindex(),
		})
		return hAbility:GetCastPoint()+0.1
	end
end

function castShackleshot(prms)
    local thisEntity = prms.thisEntity
    local hAbility = prms.ability

    if not hAbility or not hAbility:IsFullyCastable() then
        return
    end

    local enemies = AICore:getAllEnemies(hAbility:GetCastRange(), thisEntity)
    if #enemies == 0 then return end

    for _, enemy in pairs(enemies) do
        -- ищем ближайший объект для шаклов (крип или дерево)
        local chainTargets = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),
            enemy:GetOrigin(),
            nil,
            300, -- радиус, в котором Shackleshot ищет вторую цель
            DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_CLOSEST,
            false
        )

        -- убираем саму цель из списка
        for i = #chainTargets, 1, -1 do
            if chainTargets[i] == enemy then
                table.remove(chainTargets, i)
            end
        end

        if #chainTargets > 0 then
            -- цель есть, кастуем Shackleshot
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = hAbility:entindex(),
                TargetIndex = enemy:entindex(),
                Queue = false,
            })
            return hAbility:GetCastPoint() + 0.1
        end
    end
end

function voodooRestor(prms)
	local thisEntity = prms.thisEntity
	local hAbility = prms.ability
	if hAbility and hAbility:IsFullyCastable() then
		local manaPct = (thisEntity:GetMana() / thisEntity:GetMaxMana()) * 100
		
		if manaPct > 10 then
			local allies = AICore:getAllies(hAbility:GetSpecialValueFor("radius"), thisEntity)
			local active = false
			
			for i = 1, #allies do
				local unit = allies[i]
				local hpPct = (unit:GetHealth() / unit:GetMaxHealth()) * 100
				if hpPct < 90 then
					active = true
					break
				end
			end
			
			local hpPct = (thisEntity:GetHealth() / thisEntity:GetMaxHealth()) * 100
			if hpPct < 90 then
				active = true
			end
			
			if (active and not hAbility.active) or (not active and hAbility.active) then
				hAbility:ToggleAbility()
				if hAbility.active then hAbility.active = false
				else hAbility.active = true end
				return hAbility:GetCastPoint()+0.1
			end
		end
	end
end


skillsCore.pattern = {
	["dota_clicker_tidehunter_kraken_shell"] = aroundDanger,
	["dota_clicker_sniper_take_aim"] = takeAim,
	["dotac_luna_lucent_beam"] = targetCast,
	["dc_frogmen_water_bubble_small"] = buffYourSelf,
	["dc_enchantress_natures_attendants"] = naturesAttendants,
	["dc_medusa_split_shot"] = splitShot,
	["dc_jakiro_liquid_fire"] = autoCast,
	["dc_winter_wyvern_cold_embrace"] = coldEmbrace,
	["dc_zuus_arc_lightning"] = targetCast,
	["dc_shadow_shaman_mass_serpent_ward"] = summonWard,
	["dc_keeper_of_the_light_chakra_magic"] = chakraMagic,
	["dc_techies_suicide"] = suicide,
	["dc_techies_suicide_big"] = suicide,
	["dc_techies_sticky_bomb"] = posCast,
	["dc_lina_dragon_slave"] = posCast,
	["dc_weaver_geminate_attack"] = autoCast,
	["dc_beastmaster_call_of_the_wild_hawk"] = castByReady,
	["dc_windrunner_shackleshot"] = castShackleshot,
	["dc_batrider_flamebreak"] = posCast,
	["dc_lina_light_strike_array"] = posCast,
	["dc_jakiro_liquid_ice"] = autoCast,
	["dc_witch_doctor_voodoo_restoration"] = voodooRestor,
	["dc_witch_doctor_death_ward"] = summonWard,
	["dc_earthshaker_enchant_totem"] = castByReady,
	["dc_shredder_flamethrower"] = aroundDanger,
	["dc_batrider_sticky_napalm"] = posCast,
	["dc_techies_land_mines"] = posCast,
	["dc_windrunner_powershot"] = posCast,
	["dota_clicker_sniper_take_aim"] = aroundDanger,
	
}

return skillsCore
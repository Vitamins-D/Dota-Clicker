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

skillsCore.pattern = {
	["dota_clicker_tidehunter_kraken_shell"] = aroundDanger,
	["dota_clicker_sniper_take_aim"] = takeAim,
	["dotac_luna_lucent_beam"] = targetCast,
	["dc_frogmen_water_bubble_small"] = buffYourSelf,
}

return skillsCore